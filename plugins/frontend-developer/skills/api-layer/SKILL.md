---
description: Frontend API layer — typed HTTP clients, error handling, request/response interceptors, caching with TanStack Query, OpenAPI codegen, and auth patterns.
---

# Frontend API Layer

## Goals

A well-designed API layer:
- Provides **type safety** from network response to component
- Centralizes **error handling** and **auth token injection**
- Makes the app **testable** by swapping the HTTP client in tests
- Keeps **business logic out of components** — components call functions, not `fetch()`

---

## HTTP Client

### Typed `fetch` wrapper

```ts
// lib/http.ts
import { ApiError } from './errors'

interface RequestOptions extends RequestInit {
  params?: Record<string, string | number | boolean | undefined>
}

export async function http<T>(url: string, options: RequestOptions = {}): Promise<T> {
  const { params, ...init } = options

  const fullUrl = new URL(url, window.location.origin)
  if (params) {
    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined) fullUrl.searchParams.set(key, String(value))
    })
  }

  const response = await fetch(fullUrl.toString(), {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...getAuthHeaders(),
      ...init.headers,
    },
  })

  if (!response.ok) {
    const body = await response.json().catch(() => null)
    throw new ApiError(response.status, body?.message ?? response.statusText, body)
  }

  // 204 No Content
  if (response.status === 204) return undefined as T

  return response.json() as Promise<T>
}

function getAuthHeaders(): Record<string, string> {
  const token = localStorage.getItem('token')
  return token ? { Authorization: `Bearer ${token}` } : {}
}
```

### Custom error class

```ts
// lib/errors.ts
export class ApiError extends Error {
  constructor(
    public readonly status: number,
    message: string,
    public readonly body?: unknown,
  ) {
    super(message)
    this.name = 'ApiError'
  }

  get isUnauthorized() { return this.status === 401 }
  get isForbidden() { return this.status === 403 }
  get isNotFound() { return this.status === 404 }
  get isConflict() { return this.status === 409 }
  get isServerError() { return this.status >= 500 }
}
```

### Using ky (recommended for complex apps)

```ts
import ky, { HTTPError } from 'ky'
import { useAuthStore } from '@/stores/auth'

export const apiClient = ky.create({
  prefixUrl: import.meta.env.VITE_API_URL,
  timeout: 10_000,
  retry: { limit: 1, statusCodes: [408, 429, 503] },
  hooks: {
    beforeRequest: [
      (request) => {
        const token = useAuthStore().token
        if (token) request.headers.set('Authorization', `Bearer ${token}`)
      },
    ],
    afterResponse: [
      async (request, options, response) => {
        if (response.status === 401) {
          const auth = useAuthStore()
          await auth.refreshToken()
          // Retry original request with new token
          return ky(request)
        }
      },
    ],
    beforeError: [
      async (error) => {
        const body = await error.response?.json().catch(() => null)
        error.message = body?.message ?? error.message
        return error
      },
    ],
  },
})
```

---

## API Module Pattern

Organize by resource. Each module encapsulates all HTTP calls for one domain entity.

```ts
// api/products.ts
import type { Product, ProductFilters, CreateProductInput, UpdateProductInput } from '@/types'
import { http } from '@/lib/http'

export interface ProductsResponse {
  items: Product[]
  total: number
  page: number
  pageSize: number
}

export const productsApi = {
  list(filters: ProductFilters): Promise<ProductsResponse> {
    return http<ProductsResponse>('/api/products', { params: filters })
  },

  get(id: string): Promise<Product> {
    return http<Product>(`/api/products/${id}`)
  },

  create(input: CreateProductInput): Promise<Product> {
    return http<Product>('/api/products', {
      method: 'POST',
      body: JSON.stringify(input),
    })
  },

  update(id: string, input: UpdateProductInput): Promise<Product> {
    return http<Product>(`/api/products/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(input),
    })
  },

  delete(id: string): Promise<void> {
    return http<void>(`/api/products/${id}`, { method: 'DELETE' })
  },
}
```

---

## OpenAPI Codegen

If the backend has an OpenAPI spec, generate types and client automatically.

```bash
# Install
pnpm add -D openapi-typescript openapi-fetch

# Generate types from spec
pnpm openapi-typescript https://api.example.com/openapi.json -o src/api/schema.d.ts

# Or from local file
pnpm openapi-typescript ./openapi.yaml -o src/api/schema.d.ts
```

```ts
// api/client.ts
import createClient from 'openapi-fetch'
import type { paths } from './schema'

export const client = createClient<paths>({
  baseUrl: import.meta.env.VITE_API_URL,
})

// Usage: fully typed, no manual interfaces
const { data, error } = await client.GET('/products/{id}', {
  params: { path: { id: '123' } },
})

const { data: created } = await client.POST('/products', {
  body: { name: 'Widget', price: 9.99 },
})
```

---

## Error Handling

### Global error handler

```ts
// Centralized error handler
export function handleApiError(error: unknown): string {
  if (error instanceof ApiError) {
    if (error.isUnauthorized) {
      // Redirect to login
      router.push({ name: 'login', query: { redirect: router.currentRoute.value.fullPath } })
      return 'Your session has expired. Please sign in again.'
    }
    if (error.isForbidden) return "You don't have permission to do this."
    if (error.isNotFound) return 'The requested resource was not found.'
    if (error.isServerError) return 'Something went wrong on our end. Please try again.'
    return error.message
  }
  if (error instanceof TypeError && error.message.includes('Failed to fetch')) {
    return 'Network error. Please check your connection.'
  }
  return 'An unexpected error occurred.'
}
```

### Error boundaries in components

```vue
<!-- Compose: component handles its own error display -->
<script setup lang="ts">
const { data, error, isPending } = useQuery({ queryKey: ['user'], queryFn: fetchUser })
const errorMessage = computed(() => error.value ? handleApiError(error.value) : null)
</script>

<template>
  <div v-if="isPending"><Skeleton /></div>
  <ErrorMessage v-else-if="errorMessage" :message="errorMessage" @retry="refetch" />
  <UserProfile v-else :user="data!" />
</template>
```

---

## Authentication Patterns

### Token refresh with request queue

```ts
// lib/http.ts — queue requests while refreshing
let isRefreshing = false
let refreshQueue: Array<() => void> = []

async function withTokenRefresh<T>(fn: () => Promise<T>): Promise<T> {
  try {
    return await fn()
  } catch (error) {
    if (!(error instanceof ApiError) || !error.isUnauthorized) throw error

    if (!isRefreshing) {
      isRefreshing = true
      try {
        await useAuthStore().refreshToken()
        refreshQueue.forEach(resolve => resolve())
        refreshQueue = []
      } catch {
        useAuthStore().logout()
        throw error
      } finally {
        isRefreshing = false
      }
    } else {
      // Wait for ongoing refresh
      await new Promise<void>(resolve => refreshQueue.push(resolve))
    }

    // Retry with new token
    return fn()
  }
}
```

### CSRF protection

```ts
// Read CSRF token from cookie, send as header
function getCsrfToken(): string | null {
  return document.cookie
    .split('; ')
    .find(row => row.startsWith('csrftoken='))
    ?.split('=')[1] ?? null
}

// Add to all mutating requests
beforeRequest: [
  (request) => {
    if (['POST', 'PUT', 'PATCH', 'DELETE'].includes(request.method)) {
      const csrf = getCsrfToken()
      if (csrf) request.headers.set('X-CSRFToken', csrf)
    }
  },
],
```

---

## Request Deduplication and Cancellation

### Abort on component unmount

```ts
// composables/useFetchOnMount.ts
export function useFetchOnMount<T>(fn: (signal: AbortSignal) => Promise<T>) {
  const data = ref<T | null>(null)
  const error = ref<Error | null>(null)
  const loading = ref(false)

  onMounted(async () => {
    const controller = new AbortController()
    onUnmounted(() => controller.abort())

    loading.value = true
    try {
      data.value = await fn(controller.signal)
    } catch (e) {
      if (e instanceof Error && e.name === 'AbortError') return
      error.value = e instanceof Error ? e : new Error(String(e))
    } finally {
      loading.value = false
    }
  })

  return { data, error, loading }
}
```

### TanStack Query handles this automatically

```ts
// TanStack Query automatically cancels in-flight requests
// when a new query starts with the same key
const { data } = useQuery({
  queryKey: computed(() => ['products', filters.value]),
  queryFn: ({ signal }) => productsApi.list(filters.value, signal),
})
```

---

## Mocking in Tests

```ts
// tests/mocks/handlers.ts — MSW handlers
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/products', () => {
    return HttpResponse.json({
      items: [{ id: '1', name: 'Widget', price: 9.99 }],
      total: 1,
    })
  }),

  http.post('/api/products', async ({ request }) => {
    const body = await request.json()
    return HttpResponse.json({ id: '2', ...body }, { status: 201 })
  }),

  http.get('/api/products/:id', ({ params }) => {
    if (params.id === 'not-found') {
      return new HttpResponse(null, { status: 404 })
    }
    return HttpResponse.json({ id: params.id, name: 'Widget' })
  }),
]
```

---

## Audit Checklist

1. **`fetch` calls scattered in components** — components directly call `fetch('/api/...')` with manual error handling; there is no reusable API layer to mock or extend
2. **No typed responses** — `response.json()` cast to `any`; type errors from API changes are only caught at runtime in production
3. **Token sent as query parameter** — `?token=...` in URLs; tokens appear in server logs, browser history, and referrer headers; use `Authorization` header
4. **No request cancellation** — navigating away from a page leaves in-flight requests running; if they resolve after navigation, they may update stale state
5. **Silent error swallowing** — `catch(() => {})` on API calls; errors are lost silently; users see no feedback and developers see no logs
6. **Auth state checked in every API module** — each module checks `localStorage.getItem('token')`; should be centralized in an interceptor
7. **No retry strategy** — transient server errors (503, timeouts) treated the same as permanent errors; brief outages cause user-visible failures
8. **OpenAPI spec exists but types are hand-maintained** — types written manually instead of generated; drift between API contract and frontend types leads to runtime errors
