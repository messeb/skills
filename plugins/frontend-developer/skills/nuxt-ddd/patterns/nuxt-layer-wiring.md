# Nuxt Layer Wiring

Nuxt runs in two distinct runtimes that share domain and application code but diverge at the infrastructure and presentation layers.

## Full Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  BROWSER (client runtime)                                   │
│                                                             │
│  pages/ & components/                                       │
│    ↓  import from composables only                          │
│  composables/                                               │
│    ↓  wire: HttpRepository + UseCase                        │
│  infrastructure/client/                                     │
│    HttpOrderRepository → $fetch('/api/orders')              │
└──────────────────────────── ↕ HTTP ─────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│  NITRO (server runtime)                                     │
│                                                             │
│  server/api/                                                │
│    ↓  wire: DbRepository + UseCase                          │
│  infrastructure/server/                                     │
│    DatabaseOrderRepository → db.insert                      │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│  SHARED (both runtimes)                                     │
│                                                             │
│  application/    ← use cases, Result type, DTOs             │
│  domain/         ← value objects, entities, ports           │
└─────────────────────────────────────────────────────────────┘
```

**Import rules** — each layer may only import inward:

| Layer | May import from |
| --- | --- |
| `pages/` `components/` | `composables/` only |
| `composables/` | `application/`, `domain/`, `infrastructure/client/` |
| `server/api/` | `application/`, `domain/`, `infrastructure/server/` |
| `infrastructure/` | `application/`, `domain/` |
| `application/` | `domain/` |
| `domain/` | nothing in this project |

## Client-Side Wiring (Composables)

Composables are the DI root on the browser. They create the HTTP repository, instantiate the use case, and expose reactive state to components:

```typescript
// composables/usePlaceOrder.ts
import { reactive, ref } from 'vue'
import { HttpOrderRepository } from '../infrastructure/client/HttpOrderRepository'
import { PlaceOrderUseCase } from '../application/use-cases/PlaceOrderUseCase'

export function usePlaceOrder() {
  const repository = new HttpOrderRepository()          // browser: talks HTTP
  const useCase    = new PlaceOrderUseCase(repository)

  const status = ref<'idle' | 'loading' | 'success' | 'error'>('idle')
  const orderId = ref<string | null>(null)

  async function submit(items: OrderItemDto[]) {
    if (status.value === 'loading') return
    status.value = 'loading'

    const result = await useCase.execute({ items })

    if (result.ok) {
      orderId.value = result.value.orderId
      status.value  = 'success'
    } else {
      status.value = 'error'
    }
  }

  return { status, orderId, submit }
}
```

```typescript
// infrastructure/client/HttpOrderRepository.ts
import type { OrderRepository } from '../../domain/OrderRepository'

export class HttpOrderRepository implements OrderRepository {
  async save(order: Order): Promise<Result<void, DomainError>> {
    try {
      await $fetch('/api/orders', { method: 'POST', body: toDto(order) })
      return ok(undefined)
    } catch {
      return fail(new DomainError('HTTP_ERROR', 'Request failed'))
    }
  }
}
```

## Pages and Components

Pages consume composables — nothing else from the domain or infrastructure:

```vue
<!-- pages/checkout.vue -->
<script setup lang="ts">
const { status, orderId, submit } = usePlaceOrder()
</script>

<template>
  <CheckoutForm @submit="submit" :loading="status === 'loading'" />
  <OrderConfirmation v-if="status === 'success'" :order-id="orderId" />
</template>
```

```vue
<!-- components/CheckoutForm.vue -->
<script setup lang="ts">
// Components receive data and emit events — no use cases, no repositories
defineProps<{ loading: boolean }>()
defineEmits<{ submit: [items: OrderItemDto[]] }>()
</script>
```

**Rules for pages and components:**

- Pages call composable functions and pass results to components via props
- Components emit events upward — they never call use cases or repositories
- Neither pages nor components import from `domain/`, `application/`, or `infrastructure/`

## Server-Side Wiring (Nitro Routes)

The Nitro route handler is the DI root on the server. It parses the HTTP body, wires the database repository, runs the use case, and maps the result to HTTP:

```typescript
// server/api/orders.post.ts
import { DatabaseOrderRepository } from '../../infrastructure/server/DatabaseOrderRepository'
import { PlaceOrderUseCase } from '../../application/use-cases/PlaceOrderUseCase'

export default defineEventHandler(async (event) => {
  // Parse typed DTO here — use cases never see raw HTTP payloads
  const body = await readBody<{ items: OrderItemDto[] }>(event)

  const repository = new DatabaseOrderRepository()   // server: talks to DB
  const useCase    = new PlaceOrderUseCase(repository)

  const result = await useCase.execute(body)

  if (!result.ok) {
    throw createError({ statusCode: 422 })
  }

  return { orderId: result.value.orderId }
})
```

Route handler budget: parse body → wire DI → execute → map result. **No business logic.**

## Context — Composition Root for Shared Dependencies

When multiple use cases in the same route share the same repository or service instances, a `Context` class avoids re-creating them per use case:

```typescript
// application/context.ts
import type { OrderRepository } from '../domain/OrderRepository'
import type { InventoryService } from '../domain/InventoryService'

export class Context {
  // Always typed as interfaces — never as concrete classes
  readonly orders:    OrderRepository
  readonly inventory: InventoryService

  private constructor(orders: OrderRepository, inventory: InventoryService) {
    this.orders    = orders
    this.inventory = inventory
  }

  static initialize(orders: OrderRepository, inventory: InventoryService): Context {
    return new Context(orders, inventory)
  }
}
```

```typescript
// server/api/checkout.post.ts
import { DatabaseOrderRepository } from '../../infrastructure/server/DatabaseOrderRepository'
import { HttpInventoryService }    from '../../infrastructure/server/HttpInventoryService'

let context = Context.initialize(
  new DatabaseOrderRepository(),
  new HttpInventoryService(),
)

export default defineEventHandler(async (event) => {
  const body     = await readBody(event)
  const useCase  = new CheckoutUseCase(context.orders, context.inventory)
  const result   = await useCase.execute(body)

  if (!result.ok) throw createError({ statusCode: 422 })
  return result.value
})
```

Use `Context` when the same dependency is shared across multiple use cases. For single-use-case handlers, inline wiring is simpler.

## File Naming Convention for Nitro Routes

| File | HTTP method | Path |
| --- | --- | --- |
| `server/api/orders.post.ts` | POST | `/api/orders` |
| `server/api/orders.get.ts` | GET | `/api/orders` |
| `server/api/orders/[id].get.ts` | GET | `/api/orders/:id` |
| `server/api/orders/[id].delete.ts` | DELETE | `/api/orders/:id` |

## Shared Packages in a Monorepo

Domain and application code shared across multiple Nuxt apps belongs in a `packages/` workspace package:

```
packages/
  order-domain/
    src/
      domain/
      application/
    package.json   ← "name": "@repo/order-domain"
```

Apps import: `import { Order } from '@repo/order-domain'`

Infrastructure stays in `apps/<app-name>/infrastructure/` — app-specific, never shared.

## TypeScript Path Configuration

Nuxt auto-generates `.nuxt/tsconfig.json` with `"moduleResolution": "Bundler"` and `"verbatimModuleSyntax": true`:

- Use `import type { Foo }` for type-only imports
- Relative paths from `domain/` to `application/` are `../application/…`

```typescript
// domain/Order.ts — CORRECT
import type { Result } from '../application/result/Result'
import { ok, fail } from '../application/result/Result'
```
