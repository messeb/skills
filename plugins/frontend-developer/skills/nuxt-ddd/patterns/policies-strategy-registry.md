# Policies & Strategy Registry

## Policy

A policy encodes a business rule that does not naturally belong inside a single value object or entity. Policies span multiple aggregates, require external data, or change independently of the aggregate.

```typescript
// domain/<Concept>Policy.ts
export class EligibilityPolicy {
  readonly #eligibilityRepo: EligibilityRepository

  constructor(eligibilityRepo: EligibilityRepository) {
    this.#eligibilityRepo = eligibilityRepo
  }

  async isEligible(entity: Entity): Promise<boolean> {
    const record = await this.#eligibilityRepo.findFor(entity.id)
    return record !== null && !record.isExpired()
  }
}
```

For simple stateless rules, a stub that always returns `true` is the correct starting point — it reserves the slot for future rules without over-engineering:

```typescript
export class EligibilityPolicy {
  isEligible(_entity: Entity): boolean {
    return true   // extend without touching the use case
  }
}
```

## When to Use a Policy vs. a VO or Entity Method

| Where the rule lives | Use when |
| --- | --- |
| **Value object** | Rule concerns only the VO's own value (format, length, range) |
| **Entity / aggregate method** | Rule concerns the aggregate's own state (must be in state X to do Y) |
| **Policy** | Rule spans multiple aggregates, requires external data, or changes independently |
| **Strategy registry** | The applicable rule is selected at runtime from a set of strategies |

## Naming Conventions

- Policy class: `<Concept>Policy` — `EligibilityPolicy`, `FulfillmentPolicy`, `AccessPolicy`
- Policy method: verb phrase — `isEligible`, `canFulfill`, `mayAccess`
- Registry interface: `<Concept>Strategies` or `<Concept>Calculators`
- Registry methods: `get(…)` returning the strategy, `register(key, definition)` for setup

## Strategy Registry

A strategy registry is a domain-level interface that looks up the right strategy at runtime by a composite key. Use it when which rule applies depends on runtime data (user tier + product category, location + group + item type, etc.).

### Type-Safe Composite Keys

Use TypeScript template literal types to prevent typos in lookup keys:

```typescript
// domain/<Concept>Strategy.ts
export type GroupType    = 'groupA' | 'groupB'
export type CategoryType = 'categoryX' | 'categoryY'
export type StrategyKey  = `${CategoryType}_${GroupType}_${string}`

export function strategyKey(
  context:      string,
  group:        GroupType,
  category:     CategoryType,
): StrategyKey {
  return `${category}_${group}_${context}`
}
```

`StrategyKey` is a type — the compiler rejects strings that don't match the template, preventing silent lookup failures.

### Domain Interface (the Port)

The strategy receives the full domain object — not broken-out primitives. This keeps the interface stable when new context is added to the object:

```typescript
// domain/<Concept>Strategy.ts
export interface Strategy {
  apply(item: Item): Amount   // domain object, not a raw number
}

// Registry: get() receives the full Context object, not individual fields
export interface Strategies {
  get(context: Context, category: CategoryType): Strategy
}
```

Passing the full object avoids repeated destructuring at every call site and does not break callers when the registry needs more context.

### Stateless Strategy

For rules that depend only on the item being processed — no shared state across calls:

```typescript
// domain/FlatStrategy.ts
export class FlatStrategy implements Strategy {
  readonly #rate: number

  constructor(rate: number) {
    this.#rate = rate
  }

  apply(item: Item): Amount {
    return new Amount(item.quantity.value.amount * this.#rate, item.unit)
  }
}
```

### Stateful Strategy

A strategy may accumulate state across multiple calls within one session — for example, tracking cumulative usage against a limit:

```typescript
// domain/TieredStrategy.ts — stateful: tracks cumulative usage
export class TieredStrategy implements Strategy {
  readonly #limit:      number
  readonly #belowRate:  number
  readonly #aboveRate:  number
  #usedSoFar:           number = 0

  constructor(limit: number, belowRate: number, aboveRate: number) {
    this.#limit     = limit
    this.#belowRate = belowRate
    this.#aboveRate = aboveRate
  }

  apply(item: Item): Amount {
    const quantity  = item.quantity.value.amount
    const remaining = Math.max(0, this.#limit - this.#usedSoFar)
    const below     = Math.min(quantity, remaining)
    const above     = Math.max(0, quantity - below)

    this.#usedSoFar += quantity   // mutable internal counter

    return new Amount(below * this.#belowRate + above * this.#aboveRate, item.unit)
  }
}
```

**Because the strategy is stateful, the registry must create and cache one instance per session** — not one shared global:

### Infrastructure: Registry with Per-Session Cache

```typescript
// infrastructure/InMemoryStrategies.ts
export class InMemoryStrategies implements Strategies {
  readonly #definitions: Map<StrategyKey, StrategyDefinition> = new Map()
  // Per-session cache — each session gets its own stateful strategy instance
  readonly #cache: Map<string, Strategy> = new Map()

  register(key: StrategyKey, definition: StrategyDefinition): void {
    this.#definitions.set(key, definition)
  }

  get(context: Context, category: CategoryType): Strategy {
    // Cache key includes the session/aggregate unit — one strategy instance per session
    const cacheKey  = `${context.sessionId}-${category}`
    const lookupKey = strategyKey(context.group, context.type, category)

    if (!this.#cache.has(cacheKey)) {
      const definition = this.#definitions.get(lookupKey)
      if (!definition) throw new Error(`No strategy registered for: ${lookupKey}`)
      this.#cache.set(cacheKey, buildStrategy(definition))
    }

    return this.#cache.get(cacheKey)!
  }
}
```

If strategy state must survive across requests (e.g. a monthly usage allowance), add `save()` / `load()` to the `Strategies` interface and persist in infrastructure — the same port/adapter pattern as repositories.

### Using the Registry in an Aggregate

```typescript
// domain/Session.ts — aggregate uses the strategy registry via injection
export class Session {
  readonly #strategies: Strategies
  readonly #context:    Context
  #processedItems:      Item[] = []

  constructor(context: Context, strategies: Strategies) {
    this.#context    = context
    this.#strategies = strategies
  }

  processItem(item: Item): Amount {
    this.#processedItems.push(item)

    // Ask registry for the right strategy — aggregate never contains the rules itself
    const strategy = this.#strategies.get(this.#context, item.category)
    const base     = strategy.apply(item)

    return this.#applyOverride(base)
  }

  #applyOverride(amount: Amount): Amount {
    if (this.#context.type === 'groupA' && this.#processedItems.length > 3) {
      return amount.times(1.05)   // 5% surcharge after the third item
    }
    return amount
  }
}
```

The aggregate asks the registry — it never contains strategy selection logic itself.
