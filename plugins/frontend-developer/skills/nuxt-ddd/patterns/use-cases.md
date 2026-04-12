# Use Cases

A use case orchestrates one user-facing action. It holds no business rules — those live in value objects, entities, and policies. It sequences: validate → build aggregate → apply policy → raise event → persist → return result.

## Anatomy

```typescript
// application/use-cases/RegisterUserUseCase.ts

export interface RegisterUserInput {
  username: string
  email:    string
  password: string
}

export interface RegisterUserOutput {
  userId: string
}

export type FieldErrors = {
  username?: string
  email?:    string
  password?: string
}

export type RegisterUserResult =
  | { ok: true;  value: RegisterUserOutput }
  | { ok: false; error: DomainError; fieldErrors?: FieldErrors }

export class RegisterUserUseCase {
  constructor(
    private readonly repository: UserRepository,
    private readonly policy:     UserRegistrationPolicy,
  ) {}

  async execute(input: RegisterUserInput): Promise<RegisterUserResult> {

    // 1. Validate each field independently — collect per-field errors for UI
    const fieldErrors: FieldErrors = {}
    const usernameResult = Username.create(input.username)
    const emailResult    = Email.create(input.email)
    const passwordResult = Password.create(input.password)

    if (!usernameResult.ok) fieldErrors.username = usernameResult.error.message
    if (!emailResult.ok)    fieldErrors.email    = emailResult.error.message
    if (!passwordResult.ok) fieldErrors.password = passwordResult.error.message

    if (Object.keys(fieldErrors).length > 0) {
      return { ok: false, error: new DomainError('VALIDATION_ERROR', 'Validation failed'), fieldErrors }
    }

    // 2. Build aggregate (VOs already validated — aggregate is a consistency gate)
    const userResult = User.create(input)
    if (!userResult.ok) return { ok: false, error: userResult.error }

    const user = userResult.value

    // 3. Apply policy
    const allowed = await this.policy.canRegister(user)
    if (!allowed) {
      return { ok: false, error: new DomainError('POLICY_VIOLATION', 'Registration not allowed') }
    }

    // 4. Raise domain event
    user.markAsRegistered()
    const [event] = user.pullDomainEvents()

    // 5. Persist
    const saveResult = await this.repository.save(user, event)
    if (!saveResult.ok) return { ok: false, error: saveResult.error }

    // 6. Return success
    return { ok: true, value: { userId: user.id } }
  }
}
```

## Why Validate Twice?

VOs are validated individually first (step 1) to collect **per-field errors** for the UI. Then `User.create()` (step 2) validates again as the aggregate's consistency gate — ensuring it is always internally consistent even when called outside the form composable. The cost is negligible; the safety guarantee is absolute.

## Input/Output Contracts

- **Input**: plain primitives — no domain types, no `ref()`, no Vue state. Never pass `request: any` — the HTTP adapter parses the raw body and passes a typed DTO.
- **Output**: discriminated union with `ok` flag — never throws
- **FieldErrors**: optional map of field name → error string for UI display

## One Use Case Per User Action

| User action | Use case |
|-------------|----------|
| Register user | `RegisterUserUseCase` |
| Place order | `PlaceOrderUseCase` |
| Cancel order | `CancelOrderUseCase` |
| Update profile | `UpdateUserProfileUseCase` |

One class, one `execute()` method. Never combine unrelated flows. Use the `UseCase` suffix — not `Service` — to clearly signal this is an application-layer orchestrator.
