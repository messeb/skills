# Domain Events

A domain event is an immutable record of something significant that happened in the domain. Named in past tense: `OrderPlaced`, `PaymentConfirmed`, `AccountSuspended`.

Events decouple producers (aggregates) from consumers (infrastructure: email, audit log, analytics). The aggregate only records that the event occurred — it never sends email or calls external APIs.

## Anatomy

```typescript
// domain/events/OrderPlaced.ts
export interface OrderPlaced {
  readonly type:      'OrderPlaced'
  readonly occurredAt: Date
  readonly orderId:   string
  readonly customerId: string
  readonly totalAmount: number
}
```

Rules:

- All fields `readonly` — events are facts, never mutated after creation
- `type` is a string literal — enables discriminated unions across multiple event types
- `occurredAt` = when the state change happened in the domain, not when the event is processed
- Primitive values only — no aggregate references, no VOs, no domain objects

## Multiple Event Types

Group all domain events under a union type for type-safe dispatch:

```typescript
// domain/events/DomainEvent.ts
export type DomainEvent =
  | OrderPlaced
  | PaymentConfirmed
  | AccountSuspended
```

## Raising Events

Events are raised inside aggregate methods that represent state transitions. The aggregate pushes the event into an internal list — nothing more:

```typescript
// domain/Order.ts
export class Order {
  readonly #domainEvents: DomainEvent[] = []

  place(): void {
    // ... state transition logic ...
    this.#domainEvents.push({
      type:        'OrderPlaced',
      occurredAt:  new Date(),
      orderId:     this.#id,
      customerId:  this.#customerId,
      totalAmount: this.#total.value.amount,
    })
  }

  pullDomainEvents(): DomainEvent[] {
    const events = [...this.#domainEvents]
    this.#domainEvents.length = 0   // clear — dispatched exactly once
    return events
  }
}
```

`pullDomainEvents()` clears the internal list. Call it once in the use case after a successful save.

## Dispatching — Two Approaches

### Approach A: Repository receives events (simple, tight coupling)

Pass events directly to `save()`. The repository implementation handles persistence and side effects atomically:

```typescript
// application/use-cases/PlaceOrderUseCase.ts
order.place()
const events = order.pullDomainEvents()
const saveResult = await this.repository.save(order, events)
if (!saveResult.ok) return fail(saveResult.error)
return ok({ orderId: order.id })
```

```typescript
// infrastructure/server/DatabaseOrderRepository.ts
async save(order: Order, events: DomainEvent[]): Promise<Result<void, DomainError>> {
  await db.transaction(async (tx) => {
    await tx.orders.upsert(toRow(order))
    for (const event of events) {
      if (event.type === 'OrderPlaced') await this.#emailService.sendConfirmation(event)
      await tx.auditLog.insert({ type: event.type, occurredAt: event.occurredAt })
    }
  })
  return ok(undefined)
}
```

Use when side effects are few and tightly related to persistence.

### Approach B: Event bus port (loose coupling, scales better)

Define a domain port for the event bus. The use case publishes after save:

```typescript
// domain/EventBus.ts
export interface EventBus {
  publish(event: DomainEvent): Promise<void>
}
```

```typescript
// application/use-cases/PlaceOrderUseCase.ts
const saveResult = await this.repository.save(order)
if (!saveResult.ok) return fail(saveResult.error)

const events = order.pullDomainEvents()
for (const event of events) await this.eventBus.publish(event)

return ok({ orderId: order.id })
```

The infrastructure implementation of `EventBus` dispatches to handlers registered per event type:

```typescript
// infrastructure/server/NitroEventBus.ts
export class NitroEventBus implements EventBus {
  readonly #handlers = new Map<string, ((e: DomainEvent) => Promise<void>)[]>()

  on<T extends DomainEvent>(type: T['type'], handler: (e: T) => Promise<void>): void {
    const list = this.#handlers.get(type) ?? []
    this.#handlers.set(type, [...list, handler as (e: DomainEvent) => Promise<void>])
  }

  async publish(event: DomainEvent): Promise<void> {
    const handlers = this.#handlers.get(event.type) ?? []
    await Promise.all(handlers.map(h => h(event)))
  }
}
```

Use when multiple independent consumers need to react to the same event, or when the list of handlers will grow independently.

## Nuxt / Nitro Integration

Domain events are a **server-side concern** in Nuxt. They are raised and dispatched inside Nitro route handlers — never in composables or Vue components.

```
Nitro route handler (server/api/orders.post.ts)
  ↓ wire use case + repository + event bus
  ↓ use case runs: aggregate raises event, use case dispatches
  ↓ infrastructure handles email, audit, webhooks
  ↓ HTTP response → browser learns the outcome
```

The browser does **not** receive domain events directly. The HTTP response is how the result reaches the client. If the browser needs real-time updates (e.g. after another user's action), use Server-Sent Events or WebSockets as a separate infrastructure concern — not domain events.

```typescript
// server/api/orders.post.ts
export default defineEventHandler(async (event) => {
  const body = await readBody<{ customerId: string; items: OrderItemDto[] }>(event)

  const repository = new DatabaseOrderRepository()
  const emailService = new NitroEmailService()
  const eventBus = new NitroEventBus()
  eventBus.on('OrderPlaced', async (e) => emailService.sendConfirmation(e.customerId, e.orderId))

  const useCase = new PlaceOrderUseCase(repository, eventBus)
  const result  = await useCase.execute(body)

  if (!result.ok) throw createError({ statusCode: 422 })
  return { orderId: result.value.orderId }
})
```

## Rules

- **Never dispatch before save** — an unsaved aggregate is not yet a fact; the event must not leave the process
- **Never raise events in composables** — composables react to HTTP responses, not domain events
- **Never put domain objects in events** — only primitives; events may outlive the aggregate's in-memory lifetime
- **`pullDomainEvents()` called once** — always in the use case, always after a successful save
