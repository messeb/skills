# Repository Pattern

The repository abstracts any external dependency — persistence, email, payment, external APIs. The domain defines the interface (a port); infrastructure provides the adapter.

## Domain Interface

```typescript
// domain/UserRepository.ts
import type { Result } from '../application/result/Result'
import type { DomainError } from './DomainError'
import type { User } from './User'
import type { UserRegistered } from './UserRegistered'

export interface UserRepository {
  save(user: User, event: UserRegistered): Promise<Result<void, DomainError>>
  findById(id: string): Promise<Result<User | null, DomainError>>
}
```

Rules:

- Interface lives in `domain/` — zero infrastructure imports
- Returns `Promise<Result<…>>` — async, never `void` (which silently swallows errors)
- Accepts aggregates + events, not raw primitives or DTOs

## Domain Ports Cover All External Dependencies

The same port pattern applies to **any** external dependency, not just persistence:

```typescript
// domain/EmailService.ts — notification port
export interface EmailService {
  sendWelcome(userId: string, email: string): Promise<Result<void, DomainError>>
}

// domain/PaymentService.ts — payment provider port
export interface PaymentService {
  charge(amount: Price, token: string): Promise<Result<PaymentId, DomainError>>
}

// domain/ExternalInventoryService.ts — third-party API port
export interface ExternalInventoryService {
  getStockLevel(productId: string): Promise<Result<number, DomainError>>
}
```

The domain never knows whether email goes through Resend, Mailgun, or a test double. Infrastructure fulfills the contract.

## Nuxt Has Two Runtimes — Two Implementations

```typescript
// infrastructure/client/HttpUserRepository.ts  (browser)
export class HttpUserRepository implements UserRepository {
  async save(user: User, _event: UserRegistered): Promise<Result<void, DomainError>> {
    try {
      await $fetch('/api/users', {
        method: 'POST',
        body: { username: user.username.value, email: user.email.value },
      })
      return ok(undefined)
    } catch {
      return fail(new DomainError('HTTP_ERROR', 'Failed to register user'))
    }
  }

  async findById(_id: string): Promise<Result<User | null, DomainError>> {
    return ok(null)
  }
}

// infrastructure/server/DatabaseUserRepository.ts  (Nitro)
export class DatabaseUserRepository implements UserRepository {
  async save(user: User, event: UserRegistered): Promise<Result<void, DomainError>> {
    try {
      await db.insert(usersTable).values({
        id: user.id, username: user.username.value, email: user.email.value,
      })
      await eventBus.publish(event)
      return ok(undefined)
    } catch {
      return fail(new DomainError('DB_ERROR', 'Failed to persist user'))
    }
  }
}
```

## Where Each Repository Is Used

| Context | Repository | Created By |
|---------|-----------|-----------|
| Browser composable | `HttpUserRepository` | `useRegistrationForm()` |
| Nitro server route | `DatabaseUserRepository` | `server/api/users.post.ts` |

Never inject a server repository into a composable or vice versa.

## Adding a New Repository

1. Define the interface in `domain/` if it doesn't exist
2. Create `infrastructure/server/YourRepository.ts` implementing the interface
3. Create `infrastructure/client/YourRepository.ts` if the browser also needs one
4. Inject in the composable (client) and Nitro route (server)
