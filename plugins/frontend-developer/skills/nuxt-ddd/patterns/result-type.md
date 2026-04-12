# Result Type

`Result<T, E>` is a discriminated union — success or failure without exceptions. Return type for every failable operation in domain and application layers.

## Definition

```typescript
// application/result/Result.ts
export type Result<T, E = Error> =
  | { readonly ok: true;  readonly value: T }
  | { readonly ok: false; readonly error: E }

// Async convenience alias
export type AsyncResult<T, E = DomainError> = Promise<Result<T, E>>
```

## Constructors and Type Guards

```typescript
// Constructors — infer the narrowest possible type
export const ok   = <T>(value: T): Result<T, never> => ({ ok: true,  value })
export const fail = <E>(error: E): Result<never, E>  => ({ ok: false, error })

// Type guards — use in `if` branches for narrowing
export const isOk   = <T, E>(r: Result<T, E>): r is Extract<Result<T, E>, { ok: true }>  => r.ok
export const isFail = <T, E>(r: Result<T, E>): r is Extract<Result<T, E>, { ok: false }> => !r.ok
```

After a `if (!result.ok) return` the compiler narrows `result.value` as `T` — no cast needed.

## Utility Functions

```typescript
// application/result/Result.ts (continued)

// Transform the success value, pass errors through unchanged
export const mapResult = <T, U, E>(
  result: Result<T, E>,
  fn: (value: T) => U,
): Result<U, E> => result.ok ? ok(fn(result.value)) : result

// Chain failable operations — flat, no nested Result<Result<…>>
export const flatMapResult = <T, U, E>(
  result: Result<T, E>,
  fn: (value: T) => Result<U, E>,
): Result<U, E> => result.ok ? fn(result.value) : result

// Collect multiple Results: all values on success, all errors on failure
export const combineResults = <T, E>(
  results: ReadonlyArray<Result<T, E>>,
): Result<T[], E[]> => {
  const errors: E[] = []
  const values: T[] = []
  for (const r of results) {
    if (r.ok) values.push(r.value)
    else      errors.push(r.error)
  }
  return errors.length > 0 ? fail(errors) : ok(values)
}

// Provide a fallback value instead of propagating failure
export const unwrapOr = <T, E>(result: Result<T, E>, fallback: T): T =>
  result.ok ? result.value : fallback

// Exhaustiveness helper — causes a compile error if a switch is missing a case
export const assertNever = (x: never): never => {
  throw new Error(`Unhandled Result case: ${JSON.stringify(x)}`)
}
```

## Usage Patterns

### Early return (most common in use cases)

```typescript
const nameResult = Name.create(input.name)
if (!nameResult.ok) return fail(nameResult.error)
const name = nameResult.value   // TypeScript narrows to Name here
```

### Exhaustive switch with compile-time safety

```typescript
const result = Name.create(raw)
if (!result.ok) {
  switch (result.error.type) {
    case 'empty':             return 'Name is required'
    case 'tooShort':          return `${result.error.delta} more characters needed`
    case 'tooLong':           return `${result.error.delta} characters over limit`
    case 'invalidCharacters': return 'Only letters, numbers, _ and - allowed'
    default: return assertNever(result.error)  // compile error if a case is added but not handled
  }
}
```

### Chaining with `flatMapResult`

```typescript
// Use case: validate → load → check policy — no intermediate `if (!result.ok)` noise
const result = flatMapResult(
  Name.create(input.name),
  (name) => flatMapResult(
    Identifier.create(input.id),
    (id) => ok({ name, id }),
  ),
)
```

### Collecting multiple field errors

```typescript
// Use case: validate all fields before returning, not just the first failure
const fieldErrors: Record<string, string> = {}

const nameResult   = Name.create(input.name)
const statusResult = Status.create(input.status)

if (!nameResult.ok)   fieldErrors.name   = nameResult.error.message
if (!statusResult.ok) fieldErrors.status = statusResult.error.message

if (Object.keys(fieldErrors).length > 0) {
  return fail(new ValidationError('INPUT', JSON.stringify(fieldErrors)))
}

const name   = nameResult.value    // safe — errors already returned above
const status = statusResult.value
```

### Async chaining (`AsyncResult`)

```typescript
// All async boundaries return AsyncResult — no mixing of Promise and throw
async function execute(input: Input): AsyncResult<Output> {
  const nameResult = Name.create(input.name)
  if (!nameResult.ok) return fail(nameResult.error)

  const loadResult = await this.repository.findById(input.id)  // AsyncResult
  if (!loadResult.ok) return fail(loadResult.error)

  const entity = loadResult.value   // narrowed, safe
  entity.rename(nameResult.value)

  return this.repository.save(entity)  // AsyncResult<void, DomainError>
}
```

## Layer Boundaries

| Layer | Signature |
| --- | --- |
| `domain/` VO (external input) | `Result<VO, ValidationError>` from `create()` |
| `domain/` entity / aggregate | `Result<Entity, DomainError>` from `create()` |
| `application/` use case | `AsyncResult<Output, DomainError>` from `execute()` |
| `infrastructure/` repository `save()` | `AsyncResult<void, DomainError>` — never `Promise<void>` |
| `server/api/` Nitro route | Unwraps Result, maps to HTTP status, **throws** via `createError` |
| `composables/` | Unwraps Result, maps to Vue reactive state |

## Nitro Boundary: Result → HTTP

Nitro is the **only** layer that throws. Everything below uses `Result`:

```typescript
// server/api/orders.post.ts
const result = await useCase.execute(body)

if (!result.ok) {
  const { error } = result
  if (error.code === 'VALIDATION_ERROR') throw createError({ statusCode: 422, message: error.message })
  if (error.code === 'NOT_FOUND')        throw createError({ statusCode: 404 })
  if (error.code === 'CONFLICT')         throw createError({ statusCode: 409 })
  throw createError({ statusCode: 500 })
}

return { orderId: result.value.orderId }
```

## Why Not Exceptions?

- TypeScript does not track thrown types — callers cannot know what a function may throw without reading the implementation
- Exceptions propagate silently through call stacks until an unexpected handler catches them
- `Result` makes failure **visible in the type signature** — callers are forced to handle it
- `Result`-returning functions are easier to test — no `expect(() => …).toThrow()` needed
- Async boundaries are especially dangerous with exceptions: an unhandled rejection in a Nitro handler crashes the request silently
