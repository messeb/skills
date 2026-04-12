# Entities & Aggregates

## Entity

An entity has **identity** — two entities with the same `id` are the same object regardless of other fields. Entities can change state over time; identity persists.

## Aggregate Root

An aggregate root owns a consistency boundary: all mutations go through it, and it enforces invariants across its value objects. It is also the unit of persistence — one repository per aggregate root.

## Anatomy

```typescript
// domain/User.ts
export class User {
  readonly #id: string
  readonly #username: Username
  readonly #email: Email
  readonly #createdAt: Date
  #domainEvents: UserRegistered[] = []

  private constructor(props: {
    id: string; username: Username; email: Email; createdAt: Date
  }) {
    this.#id        = props.id
    this.#username  = props.username
    this.#email     = props.email
    this.#createdAt = props.createdAt
  }

  static create(props: { username: string; email: string; password: string })
    : Result<User, DomainError> {
    const usernameResult = Username.create(props.username)
    if (!usernameResult.ok) return fail(usernameResult.error)
    const emailResult = Email.create(props.email)
    if (!emailResult.ok) return fail(emailResult.error)

    return ok(new User({
      id:        crypto.randomUUID(),
      username:  usernameResult.value,
      email:     emailResult.value,
      createdAt: new Date(),
    }))
  }

  markAsRegistered(): void {
    this.#domainEvents.push({
      type: 'UserRegistered', occurredAt: new Date(),
      userId: this.#id, username: this.#username.value, email: this.#email.value,
    })
  }

  pullDomainEvents(): UserRegistered[] {
    const events = [...this.#domainEvents]
    this.#domainEvents = []
    return events
  }

  get id()        { return this.#id }
  get username()  { return this.#username }
  get email()     { return this.#email }
  get createdAt() { return this.#createdAt }
}
```

## Stateful Aggregates — Load, Mutate, Save

Some aggregates accumulate state across multiple operations and must be loaded before being mutated. The repository reconstructs the aggregate from storage.

```typescript
// domain/OrderHistory.ts — aggregate that accumulates state over time
export class OrderHistory {
  readonly #customerId: string
  #orders: Order[] = []

  constructor(customerId: string, existingOrders: Order[] = []) {
    this.#customerId = customerId
    this.#orders     = existingOrders
  }

  addOrder(order: Order): Result<Price, DomainError> {
    this.#orders.push(order)

    let price = order.calculateBasePrice()

    // Business rule that requires history context
    if (this.#ordersThisMonth >= 10) {
      price = price.times(0.9)   // 10% loyalty discount after 10 orders
    }

    return ok(price)
  }

  private get #ordersThisMonth(): number {
    const now = new Date()
    return this.#orders.filter(o =>
      o.placedAt.getFullYear() === now.getFullYear() &&
      o.placedAt.getMonth()    === now.getMonth()
    ).length
  }

  get customerId() { return this.#customerId }
}
```

```typescript
// application/use-cases/PlaceOrderUseCase.ts — load → mutate → save
async execute(input: PlaceOrderInput): Promise<PlaceOrderResult> {
  // Load existing aggregate (may already have history)
  const historyResult = await this.repository.findByCustomerId(input.customerId)
  if (!historyResult.ok) return { ok: false, error: historyResult.error }

  const history = historyResult.value ?? new OrderHistory(input.customerId)

  const orderResult = Order.create(input)
  if (!orderResult.ok) return { ok: false, error: orderResult.error }

  // Mutate — price depends on accumulated history
  const priceResult = history.addOrder(orderResult.value)
  if (!priceResult.ok) return { ok: false, error: priceResult.error }

  // Save updated aggregate
  const saveResult = await this.repository.save(history)
  if (!saveResult.ok) return { ok: false, error: saveResult.error }

  return { ok: true, value: { orderId: orderResult.value.id, price: priceResult.value } }
}
```

The pattern: **load → mutate → save**. The aggregate brings its own history and enforces rules that depend on it.

## Aggregate Boundary Rules

| Rule | Reason |
|------|--------|
| Only the root is `public` — VOs are accessed via getters | Ensures all invariants are checked through the root |
| Factory validates all children before constructing | Aggregate is always internally consistent at creation |
| Events raised inside aggregate, dispatched by use case | Aggregate does not know about persistence or transport |
| One repository per aggregate root | Persistence maps to aggregate boundaries |
