---
description: Frontend state management — choosing between local state, composables, Pinia/Zustand, and server state; patterns for each layer.
---

# State Management

## The State Decision Tree

Before reaching for a global store, ask:

```text
Is the state used in only one component?
  → Local state (ref/useState)

Is the state shared between a few nearby components?
  → Lift to common parent or use provide/inject

Is the state UI-only (open/closed, active tab)?
  → Local state, never put in global store

Is the state fetched from a server?
  → Server state library (TanStack Query, SWR, useFetch)

Is the state truly global and mutable from many places?
  → Global store (Pinia, Zustand)
```

Over-using global state is as harmful as prop drilling.

---

## Local State

The right choice for most things.

```vue
<!-- Vue: component-level state -->
<script setup lang="ts">
// Purely local UI state
const isDropdownOpen = ref(false)
const activeTab = ref<'details' | 'reviews' | 'shipping'>('details')

// Derived state
const tabCount = computed(() => tabs.length)
</script>
```

```tsx
// React: component-level state
function ProductPage() {
  const [activeTab, setActiveTab] = useState<'details' | 'reviews'>('details')
  const [isDropdownOpen, setIsDropdownOpen] = useState(false)
  // ...
}
```

---

## Server State — TanStack Query

Server state is fundamentally different from client state:

- It lives on the server; local state is a cache
- It can become stale
- Multiple components might display the same data
- It needs loading, error, and refetch handling

Use TanStack Query (Vue Query / React Query) for all server state.

### Vue Query setup

```ts
// main.ts
import { VueQueryPlugin } from '@tanstack/vue-query'

app.use(VueQueryPlugin, {
  queryClientConfig: {
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000,     // data fresh for 1 minute
        gcTime: 5 * 60 * 1000,    // cache kept for 5 minutes
        retry: 1,
        refetchOnWindowFocus: true,
      },
    },
  },
})
```

### Queries

```ts
// composables/useProducts.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { productsApi } from '@/api/products'

export const productKeys = {
  all: ['products'] as const,
  lists: () => [...productKeys.all, 'list'] as const,
  list: (filters: ProductFilters) => [...productKeys.lists(), filters] as const,
  detail: (id: string) => [...productKeys.all, 'detail', id] as const,
}

export function useProducts(filters: Ref<ProductFilters>) {
  return useQuery({
    queryKey: computed(() => productKeys.list(filters.value)),
    queryFn: () => productsApi.list(filters.value),
    placeholderData: keepPreviousData,  // no flicker on filter change
  })
}

export function useProduct(id: Ref<string>) {
  return useQuery({
    queryKey: computed(() => productKeys.detail(id.value)),
    queryFn: () => productsApi.get(id.value),
    enabled: computed(() => !!id.value),
  })
}
```

### Mutations

```ts
export function useUpdateProduct() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (payload: UpdateProductPayload) => productsApi.update(payload),

    // Optimistic update
    onMutate: async (payload) => {
      await queryClient.cancelQueries({ queryKey: productKeys.detail(payload.id) })
      const previous = queryClient.getQueryData(productKeys.detail(payload.id))
      queryClient.setQueryData(productKeys.detail(payload.id), (old: Product) => ({
        ...old,
        ...payload,
      }))
      return { previous }
    },

    onError: (err, payload, context) => {
      // Rollback on error
      queryClient.setQueryData(productKeys.detail(payload.id), context?.previous)
    },

    onSettled: (data, err, payload) => {
      // Always refetch to sync with server
      queryClient.invalidateQueries({ queryKey: productKeys.detail(payload.id) })
      queryClient.invalidateQueries({ queryKey: productKeys.lists() })
    },
  })
}
```

### Usage in component

```vue
<script setup lang="ts">
const filters = ref<ProductFilters>({ category: 'all', page: 1 })
const { data: products, isPending, isError, error } = useProducts(filters)
const { mutate: updateProduct, isPending: isUpdating } = useUpdateProduct()
</script>

<template>
  <div v-if="isPending"><Skeleton /></div>
  <div v-else-if="isError">{{ error.message }}</div>
  <ul v-else>
    <li v-for="product in products?.items" :key="product.id">
      <ProductRow :product="product" @update="updateProduct" />
    </li>
  </ul>
</template>
```

---

## Global Client State — Pinia

Use Pinia for state that is:

- Global (auth, user preferences, notifications)
- Client-only (not from the server)
- Mutated from multiple places

### Store setup (Composition API style — preferred)

```ts
// stores/auth.ts
import { defineStore } from 'pinia'
import { authApi } from '@/api/auth'

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref<User | null>(null)
  const token = ref<string | null>(localStorage.getItem('token'))

  // Getters
  const isAuthenticated = computed(() => !!token.value)
  const isAdmin = computed(() => user.value?.role === 'admin')

  // Actions
  async function login(credentials: LoginCredentials) {
    const response = await authApi.login(credentials)
    token.value = response.token
    user.value = response.user
    localStorage.setItem('token', response.token)
  }

  async function logout() {
    await authApi.logout()
    token.value = null
    user.value = null
    localStorage.removeItem('token')
  }

  async function fetchCurrentUser() {
    if (!token.value) return
    user.value = await authApi.me()
  }

  return { user, token, isAuthenticated, isAdmin, login, logout, fetchCurrentUser }
})
```

### Store for UI state

```ts
// stores/notifications.ts
export const useNotificationStore = defineStore('notifications', () => {
  const notifications = ref<Notification[]>([])

  function push(notification: Omit<Notification, 'id'>) {
    const id = crypto.randomUUID()
    notifications.value.push({ ...notification, id })
    if (notification.duration !== 0) {
      setTimeout(() => remove(id), notification.duration ?? 4000)
    }
    return id
  }

  function remove(id: string) {
    const index = notifications.value.findIndex(n => n.id === id)
    if (index !== -1) notifications.value.splice(index, 1)
  }

  return { notifications: readonly(notifications), push, remove }
})
```

---

## Zustand (React)

```ts
// stores/auth.ts
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface AuthState {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  login: (credentials: LoginCredentials) => Promise<void>
  logout: () => Promise<void>
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      get isAuthenticated() { return !!get().token },

      async login(credentials) {
        const response = await authApi.login(credentials)
        set({ user: response.user, token: response.token })
      },

      async logout() {
        await authApi.logout()
        set({ user: null, token: null })
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({ token: state.token }),  // only persist token
    }
  )
)
```

---

## State Colocation

Keep state as close to where it's used as possible.

```text
Bad: Everything in global store
  ├── useGlobalStore
  │   ├── user (global: ✓)
  │   ├── searchQuery (local to SearchBar: ✗)
  │   ├── activeTab (local to ProductPage: ✗)
  │   └── isModalOpen (local to UserMenu: ✗)

Good: Colocated state
  ├── useAuthStore → user, token
  ├── SearchBar.vue → searchQuery (local ref)
  ├── ProductPage.vue → activeTab (local ref)
  └── UserMenu.vue → isMenuOpen (local ref)
```

---

## Form State

Use a form library for complex forms. Don't reinvent validation.

```ts
// Vue: VeeValidate + Zod
import { useForm } from 'vee-validate'
import { toTypedSchema } from '@vee-validate/zod'
import { z } from 'zod'

const schema = toTypedSchema(z.object({
  email: z.string().email('Enter a valid email'),
  password: z.string().min(8, 'At least 8 characters'),
}))

const { handleSubmit, errors, defineField, isSubmitting } = useForm({ validationSchema: schema })
const [email, emailProps] = defineField('email')
const [password, passwordProps] = defineField('password')

const onSubmit = handleSubmit(async (values) => {
  await authStore.login(values)
  router.push('/dashboard')
})
```

```tsx
// React: React Hook Form + Zod
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

const schema = z.object({
  email: z.string().email('Enter a valid email'),
  password: z.string().min(8, 'At least 8 characters'),
})

function LoginForm() {
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm({
    resolver: zodResolver(schema),
  })
  // ...
}
```

---

## Audit Checklist

1. **Server state in a Pinia/Zustand store** — fetching data from an API and storing it in a global store with manual loading/error flags; use TanStack Query instead
2. **UI state in a global store** — `isModalOpen`, `activeTab`, `searchQuery` in the store; these are local component concerns
3. **Missing stale-time configuration** — every query refetches on every component mount; leads to excessive API calls and flickering
4. **No query key factory** — query keys are inline strings; invalidation and cache management become unreliable; use a structured key factory
5. **Mutating store state directly in components** — reading from a store and writing back directly without going through an action; bypasses validation and logging
6. **Stores importing other stores in setup** — circular dependencies between stores cause initialization order bugs; extract shared logic into a composable
7. **Form state managed manually** — hand-rolled validation with `ref` + `watch` for each field; use VeeValidate or React Hook Form
8. **Global store reset not handled** — on logout, stale data from the previous user's session remains in stores; implement a `$reset()` or clear action for all user-specific stores
