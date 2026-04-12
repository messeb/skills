# Domain Errors

Domain errors communicate what went wrong in domain terms, not HTTP terms. They carry a `code` (machine-readable) and a `message` (human-readable for logs or UI fallback).

## Base Hierarchy

```typescript
// domain/DomainError.ts
export class DomainError extends Error {
  constructor(readonly code: string, message: string) {
    super(message)
    this.name = 'DomainError'
  }
}

export class ValidationError extends DomainError {
  constructor(readonly field: string, message: string) {
    super('VALIDATION_ERROR', message)
    this.name = 'ValidationError'
  }
}
```

## Error Codes

Error codes are string constants in `SCREAMING_SNAKE_CASE`. They identify the failure reason independently of the message text (which may be localised or change).

| Code | Meaning |
|------|---------|
| `VALIDATION_ERROR` | A value object or aggregate rejected an input value |
| `POLICY_VIOLATION` | A business policy blocked the operation |
| `HTTP_ERROR` | Infrastructure: network or server error from client repo |
| `NOT_FOUND` | Aggregate looked up by ID does not exist |
| `CONFLICT` | Optimistic concurrency conflict or duplicate detection |

## Rich Error Types (Discriminated Unions)

Use a discriminated union instead of `ValidationError` when a VO has multiple distinct failure modes. Callers pattern-match on `type` — no string parsing, no `instanceof` checks, full type narrowing:

```typescript
// domain/Name.ts — error type co-located with the VO that produces it
export type NameValidationError =
  | { type: 'empty' }
  | { type: 'tooShort'; delta: number }
  | { type: 'tooLong';  delta: number }
  | { type: 'invalidCharacters' }
```

Discriminant values use **camelCase** — consistent with TypeScript naming conventions and avoids kebab-case string literals that can't be accessed as identifiers.

Callers get precise branches and typed payloads:

```typescript
if (!result.ok) {
  const err = result.error
  if (err.type === 'tooShort') showHint(`${err.delta} more characters needed`)
  if (err.type === 'tooLong')  showHint(`${err.delta} characters over limit`)
  if (err.type === 'empty')    showHint('Required')
}
```

**When to use which:**

| Error form | Use when |
| --- | --- |
| `ValidationError` (class) | Single failure mode; the message string is enough for the caller |
| Discriminated union | Multiple failure modes; callers need to branch or access extra data (`delta`, `conflictingId`, …) |

Never use discriminated unions AND a `ValidationError` subclass for the same VO — pick one.

## Extending the Hierarchy

Add a subclass only when a new error category needs its own typed fields that callers must access:

```typescript
// domain/DomainError.ts
export class NotFoundError extends DomainError {
  constructor(readonly entityType: string, readonly id: string) {
    super('NOT_FOUND', `${entityType} with id ${id} not found`)
    this.name = 'NotFoundError'
  }
}

export class ConflictError extends DomainError {
  constructor(readonly conflictingField: string, message: string) {
    super('CONFLICT', message)
    this.name = 'ConflictError'
  }
}
```

Use case and policy code catches these by `error.code` (string match) or `instanceof` — both work because `code` is always set:

```typescript
// application use case
if (!result.ok) {
  if (result.error.code === 'NOT_FOUND') return fail(result.error)
  if (result.error instanceof ConflictError) {
    // access result.error.conflictingField
  }
}
```

**Rule**: never add HTTP status knowledge (`.statusCode`, `.httpStatus`) to domain error classes. HTTP mapping belongs exclusively in Nitro route handlers — see [Nuxt Layer Wiring](nuxt-layer-wiring.md).

## Mapping to HTTP at the Boundary

Domain errors are mapped to HTTP status codes **only** in Nitro route handlers — never inside domain or application code:

```typescript
// server/api/users.post.ts
if (!result.ok) {
  const { error } = result
  if (error.code === 'VALIDATION_ERROR' && result.fieldErrors) {
    throw createError({ statusCode: 422, data: { fieldErrors: result.fieldErrors } })
  }
  if (error.code === 'POLICY_VIOLATION') {
    throw createError({ statusCode: 403, message: error.message })
  }
  if (error.code === 'CONFLICT') {
    throw createError({ statusCode: 409, message: error.message })
  }
  throw createError({ statusCode: 500 })
}
```
