# Value Objects

A value object wraps a primitive and guarantees it is always valid. Validation lives in the factory method, not scattered at call sites.

## Invariants

- **Truly private fields**: use JavaScript native `#` fields — private at runtime, not just at compile time
- **Self-validating**: factory method returns `Result<VO, E>`, never throws, for external/user input
- **Private constructor**: prevents bypassing validation
- **Value equality**: `equals()` compares by value, not reference
- **Printable**: `toString()` for safe display

## Anatomy

```typescript
// domain/Identifier.ts
import type { Result } from '../application/result/Result'
import { ok, fail } from '../application/result/Result'
import { ValidationError } from './DomainError'

const FORMAT_REGEX = /^[a-z0-9-]{3,64}$/

export class Identifier {
  readonly #value: string

  private constructor(value: string) {
    this.#value = value
  }

  static create(raw: string): Result<Identifier, ValidationError> {
    const trimmed = raw.trim().toLowerCase()
    if (!FORMAT_REGEX.test(trimmed)) {
      return fail(new ValidationError('identifier', 'Must be 3–64 lowercase alphanumeric characters or hyphens'))
    }
    return ok(new Identifier(trimmed))
  }

  get value(): string { return this.#value }
  equals(other: Identifier): boolean { return this.#value === other.#value }
  toString(): string { return this.#value }
}
```

Note: `#value` is invisible outside the class at runtime. Unlike TypeScript's `private`, it cannot be accessed via `(obj as any)._value`, JSON tricks, or reflection.

## Rich Error Variants

When a VO has multiple distinct failure modes, use a discriminated union instead of a generic `ValidationError`. Callers pattern-match on `type` without string parsing:

```typescript
// domain/Name.ts
export type NameValidationError =
  | { type: 'empty' }
  | { type: 'tooShort'; delta: number }
  | { type: 'tooLong';  delta: number }
  | { type: 'invalidCharacters' }

export namespace NameValidationError {
  export const empty        = (): NameValidationError => ({ type: 'empty' })
  export const tooShort     = (n: number): NameValidationError => ({ type: 'tooShort', delta: n })
  export const tooLong      = (n: number): NameValidationError => ({ type: 'tooLong',  delta: n })
  export const invalidChars = (): NameValidationError => ({ type: 'invalidCharacters' })
}

export class Name {
  static readonly #MIN = 2
  static readonly #MAX = 50
  readonly #value: string

  private constructor(value: string) { this.#value = value }

  static create(raw: string): Result<Name, NameValidationError> {
    const trimmed = raw.trim()
    if (trimmed.length === 0)                  return fail(NameValidationError.empty())
    if (trimmed.length < Name.#MIN)            return fail(NameValidationError.tooShort(Name.#MIN - trimmed.length))
    if (trimmed.length > Name.#MAX)            return fail(NameValidationError.tooLong(trimmed.length - Name.#MAX))
    if (!/^[\p{L}\p{N} _-]+$/u.test(trimmed)) return fail(NameValidationError.invalidChars())
    return ok(new Name(trimmed))
  }

  get value(): string { return this.#value }
  equals(other: Name): boolean { return this.#value === other.#value }
  toString(): string { return this.#value }
}
```

The `type` discriminant lets callers branch precisely: `if (err.type === 'tooShort') show(err.delta)`. Min/max constants are `static #` — invisible outside the class.

Use `ValidationError` for simple single-mode failures. Use discriminated unions when callers need to branch on the reason or access additional data (like `delta`).

## Factory Method Naming Conventions

Choose the factory name that signals where the data comes from:

| Factory | Input | Returns | Use when |
| --- | --- | --- | --- |
| `create(props)` | Structured user/form data | `Result<VO, E>` | Primary construction from untrusted input |
| `fromString(raw)` | Raw string | `Result<VO, E>` | Parsing and validating a single string value |
| `fromExternal(dto)` | External / API DTO | `Result<VO, E>` or VO | ACL boundary: translating a third-party model |
| `fromPersisted(row)` | Database row | VO (no Result) | Reconstruction from trusted storage — no re-validation |

```typescript
// domain/Status.ts
export type StatusValue = 'draft' | 'active' | 'archived'
const ALLOWED: StatusValue[] = ['draft', 'active', 'archived']

export class Status {
  readonly #value: StatusValue

  private constructor(value: StatusValue) { this.#value = value }

  // create — structured input, Result for the caller to handle
  static create(raw: string): Result<Status, ValidationError> {
    if (!ALLOWED.includes(raw as StatusValue))
      return fail(new ValidationError('status', `Unknown status: ${raw}`))
    return ok(new Status(raw as StatusValue))
  }

  // fromPersisted — DB row is trusted, no Result needed, no re-validation
  static fromPersisted(row: { status: string }): Status {
    return new Status(row.status as StatusValue)
  }

  get value(): StatusValue { return this.#value }
  equals(other: Status): boolean { return this.#value === other.#value }
}
```

`fromPersisted` calls `new` directly — it bypasses `create()` because the database is a trusted source within the system. Never expose this constructor publicly; always route untrusted input through a `Result`-returning factory.

## Trusted vs. Untrusted Construction

Not every VO needs a `Result`-returning factory. The deciding question: *can a programming mistake produce an invalid value, or can only bad external input do so?*

| Context | Pattern | Rationale |
| --- | --- | --- |
| **External / user input** — form fields, API payloads, URL params | `static create()` returning `Result` | Input is untrusted; caller must handle failure |
| **Internal / domain assembly** — constructed from already-validated VOs | Public constructor that `assert()`s | Invalid value = programming error, not user error; `assert` failure surfaces it immediately |

```typescript
// domain/Quantity.ts — internal VO, assembled from validated domain data
function assert(condition: boolean, message: string): asserts condition {
  if (!condition) throw new Error(message)
}

export class Quantity {
  readonly #amount: number
  readonly #unit: Unit

  // Public constructor — callers are trusted domain code
  constructor(amount: number, unit: Unit) {
    assert(amount >= 0, `Quantity amount must be non-negative, got ${amount}`)
    assert(Number.isFinite(amount), `Quantity amount must be finite`)
    this.#amount = amount
    this.#unit   = unit
  }

  add(other: Quantity): Quantity {
    assert(this.#unit === other.#unit, `Unit mismatch: ${this.#unit} vs ${other.#unit}`)
    return new Quantity(this.#amount + other.#amount, this.#unit)
  }

  subtract(other: Quantity): Quantity {
    assert(this.#unit === other.#unit, `Unit mismatch`)
    assert(this.#amount >= other.#amount, `Result would be negative`)
    return new Quantity(this.#amount - other.#amount, this.#unit)
  }

  isZero(): boolean { return this.#amount === 0 }
  equals(other: Quantity): boolean { return this.#amount === other.#amount && this.#unit === other.#unit }
  get value() { return { amount: this.#amount, unit: this.#unit } }
}
```

The local `assert()` helper reads like a specification, not a control-flow statement. Keep it file-local — it is not part of the public API.

## Rich VO Operations

Value objects expose domain operations that return new instances (immutability preserved). Domain arithmetic stays inside the domain rather than scattered at call sites:

```typescript
// use case or aggregate — domain arithmetic, no raw numbers leak out
const total = lineItems.reduce(
  (sum, item) => sum.add(item.price.times(item.quantity.value.amount)),
  new Amount(0, Currency.EUR),
)
```

Common rich operations by VO type:

| VO | Operations |
| --- | --- |
| `Amount` / `Money` | `add(other)`, `subtract(other)`, `times(factor)`, `isGreaterThan(other)` |
| `Quantity` | `add(other)`, `subtract(other)`, `isZero()` |
| `DateRange` | `contains(date)`, `overlaps(other)`, `duration()` |
| `Percentage` | `of(amount)`, `add(other)` |

Operations must return new VO instances — never mutate `#` fields.

## VO Composition

A value object can hold other value objects, assembling a richer domain concept from simpler ones:

```typescript
// domain/OrderLine.ts — VO composed of two other VOs
export class OrderLine {
  readonly #productId: Identifier
  readonly #quantity: Quantity

  constructor(productId: Identifier, quantity: Quantity) {
    // Both VOs already validated — no additional checks needed
    this.#productId = productId
    this.#quantity  = quantity
  }

  get productId() { return this.#productId }
  get quantity()  { return this.#quantity }
}
```

Key points:

- The constructor receives already-validated VOs — no need to re-validate inside
- The composed VO is immutable because its fields are immutable VOs
- Use `ReadonlyArray<T>` for collection parameters — signals the domain does not mutate the input

```typescript
// Prefer ReadonlyArray at domain boundaries
constructor(
  orderId:   Identifier,
  lines:     ReadonlyArray<OrderLine>,   // not plain OrderLine[]
  placedAt:  Date,
)
```

## Nuxt-Specific: VOs in Live Validation

Because factory methods are pure functions returning `Result`, composables can call them inside `computed()` for zero-latency UI feedback without a server round-trip:

```typescript
// composables/useNameLiveValidation.ts
import { computed } from 'vue'
import type { Ref } from 'vue'
import { Name } from '../domain/Name'

export function useNameLiveValidation(name: Ref<string>) {
  const result = computed(() => Name.create(name.value))

  const status = computed((): 'empty' | 'tooShort' | 'tooLong' | 'invalidCharacters' | 'valid' => {
    if (result.value.ok) return 'valid'
    return result.value.error.type
  })

  const hint = computed((): string => {
    if (result.value.ok) return `${name.value.trim().length} characters`
    const err = result.value.error
    if (err.type === 'tooShort')          return `${err.delta} more characters needed`
    if (err.type === 'tooLong')           return `${err.delta} characters over limit`
    if (err.type === 'invalidCharacters') return 'Only letters, numbers, spaces, _ and - allowed'
    return 'Name is required'
  })

  return { status, hint }
}
```

Domain logic runs synchronously in the browser — no network call, no debounce required.
