---
description: Nuxt.js best practices — rendering modes, data fetching, routing conventions, middleware, modules, SEO, and performance.
---

# Nuxt.js Best Practices

## Rendering Modes — Choose the Right One

| Mode | When to use |
|------|-------------|
| **SSR** (Server-Side Rendering) | SEO-critical pages, authenticated dashboards, personalized content |
| **SSG** (Static Site Generation) | Marketing pages, docs, content that rarely changes |
| **ISR** (Incremental Static Regeneration) | SSG pages that need periodic revalidation |
| **SPA** (Client-only) | Internal tools with no SEO need, complex interactive UIs |
| **Hybrid** | Mix per-route — most Nuxt apps need this |

```ts
// nuxt.config.ts — default for entire app
export default defineNuxtConfig({
  ssr: true,  // default; set false for SPA mode
})
```

```ts
// Per-route rendering (Nuxt 3 hybrid mode)
// pages/blog/[slug].vue
defineRouteRules({
  swr: 3600,          // ISR: revalidate every hour
})

// pages/dashboard.vue
defineRouteRules({
  ssr: false,         // SPA for this route
  prerender: false,
})

// pages/about.vue
defineRouteRules({
  prerender: true,    // Static at build time
})
```

---

## Data Fetching

### `useFetch` — primary data fetching composable

```ts
// Basic usage
const { data: products, status, error, refresh } = await useFetch('/api/products')

// With query params (auto-refetches when query changes)
const search = ref('')
const { data } = await useFetch('/api/products', {
  query: { q: search, page: currentPage },
  watch: [search, currentPage],
})

// With transform — shape data as it comes in
const { data: users } = await useFetch('/api/users', {
  transform: (response) => response.items.map(normalizeUser),
  default: () => [],
})

// POST request
const { data, execute } = await useFetch('/api/orders', {
  method: 'POST',
  body: orderPayload,
  immediate: false,   // don't fetch on mount
})
```

### `useAsyncData` — when you need fine-grained control

```ts
// Use when fetching from a non-HTTP source or needing custom caching key
const { data: user } = await useAsyncData(
  `user-${route.params.id}`,  // explicit cache key
  () => $fetch(`/api/users/${route.params.id}`),
  {
    watch: [() => route.params.id],
    default: () => null,
    getCachedData: (key) => nuxtApp.payload.data[key],  // use SSR payload
  }
)
```

### Server-side only fetching (`$fetch` in server routes)

```ts
// server/api/products.get.ts
export default defineEventHandler(async (event) => {
  const query = getQuery(event)
  const products = await db.product.findMany({
    where: { active: true },
    take: Number(query.limit) || 20,
  })
  return products
})
```

### Avoid double-fetching

```ts
// Bad: fetching in both server and client
onMounted(() => {
  fetch('/api/user').then(...)  // ← this refetches on client after SSR
})

// Good: useFetch/useAsyncData handle SSR state transfer automatically
const { data: user } = await useFetch('/api/user')
// Data is serialized into the HTML payload and rehydrated — no second request
```

---

## Routing Conventions

```text
pages/
├── index.vue              → /
├── about.vue              → /about
├── blog/
│   ├── index.vue          → /blog
│   └── [slug].vue         → /blog/:slug
├── users/
│   ├── [id]/
│   │   ├── index.vue      → /users/:id
│   │   └── settings.vue   → /users/:id/settings
│   └── index.vue          → /users
└── [...path].vue          → catch-all
```

### Route params with TypeScript

```ts
// pages/users/[id].vue
const route = useRoute()

// Type-safe route params
const userId = computed(() => route.params.id as string)
```

### Programmatic navigation

```ts
const router = useRouter()

// Navigate
await router.push('/dashboard')
await router.push({ name: 'users-id', params: { id: '42' } })

// Replace history entry
await router.replace({ query: { tab: 'settings' } })
```

---

## Middleware

```ts
// middleware/auth.ts — runs on every route change
export default defineNuxtRouteMiddleware((to, from) => {
  const { isAuthenticated } = useAuthStore()

  if (!isAuthenticated.value && to.path !== '/login') {
    return navigateTo({
      path: '/login',
      query: { redirect: to.fullPath },
    })
  }
})
```

```ts
// Apply globally in nuxt.config.ts
export default defineNuxtConfig({
  router: {
    middleware: ['auth'],
  },
})

// Or per-page
definePageMeta({
  middleware: ['auth', 'check-permissions'],
})

// Or inline (anonymous middleware)
definePageMeta({
  middleware: (to) => {
    if (to.params.id === 'forbidden') return abortNavigation()
  },
})
```

---

## Layouts

```text
layouts/
├── default.vue      → used automatically
├── auth.vue         → minimal layout for login/register
└── dashboard.vue    → sidebar + header layout

pages/login.vue
<script setup>
definePageMeta({ layout: 'auth' })
</script>
```

---

## State Management

Prefer Pinia for global state. Use `useState` for simple SSR-compatible reactive state.

```ts
// Simple SSR-safe shared state (no Pinia needed)
// composables/useTheme.ts
export const useTheme = () => useState('theme', () => 'light')

// Pinia store for complex domain state
// stores/cart.ts
export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([])
  const total = computed(() => items.value.reduce((sum, i) => sum + i.price * i.qty, 0))

  function addItem(item: CartItem) { /* ... */ }
  function removeItem(id: string) { /* ... */ }

  return { items, total, addItem, removeItem }
})
```

---

## SEO with `useSeoMeta`

```ts
// pages/blog/[slug].vue
const { data: post } = await useFetch(`/api/posts/${route.params.slug}`)

useSeoMeta({
  title: () => post.value?.title ?? 'Blog',
  description: () => post.value?.excerpt,
  ogTitle: () => post.value?.title,
  ogDescription: () => post.value?.excerpt,
  ogImage: () => post.value?.coverImage,
  ogUrl: () => `https://example.com/blog/${route.params.slug}`,
  twitterCard: 'summary_large_image',
})
```

---

## Plugins and App Lifecycle

```ts
// plugins/analytics.client.ts  (runs only in browser)
export default defineNuxtPlugin(() => {
  const router = useRouter()

  router.afterEach((to) => {
    window.analytics?.page(to.fullPath)
  })
})

// plugins/sentry.ts  (runs on both server and client)
export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.vueApp.config.errorHandler = (error, instance, info) => {
    Sentry.captureException(error, { extra: { info } })
  }
})
```

---

## `nuxt.config.ts` Best Practices

```ts
export default defineNuxtConfig({
  devtools: { enabled: true },

  // Runtime config — server-only secrets vs public values
  runtimeConfig: {
    databaseUrl: process.env.DATABASE_URL,   // server-only
    stripeSecret: process.env.STRIPE_SECRET, // server-only
    public: {
      apiBase: process.env.API_BASE_URL,     // exposed to client
      googleMapsKey: process.env.MAPS_KEY,   // exposed to client
    },
  },

  // App config — non-secret, overridable at runtime
  appConfig: {
    theme: { primary: '#3b82f6' },
  },

  modules: [
    '@pinia/nuxt',
    '@nuxtjs/i18n',
    '@vueuse/nuxt',
    '@nuxt/image',
  ],

  // Auto-imports
  imports: {
    dirs: ['stores', 'composables/**'],
  },

  typescript: {
    strict: true,
    typeCheck: true,
  },
})
```

---

## Audit Checklist

1. **All pages use SSR when SSG/prerender would suffice** — every product page fetches on every request instead of being statically generated at build time
2. **`onMounted` fetch duplicates SSR fetch** — `useFetch` already handles server-to-client state transfer; an additional `onMounted` fetch causes a second network request
3. **Secrets in `runtimeConfig.public`** — API keys, database URLs, or secret tokens placed in the public config are exposed to the browser
4. **No route-level middleware** — authentication or authorization logic duplicated inside components instead of centralized in middleware
5. **Missing `default` in `useFetch`** — no `default: () => []` causes template to receive `null` before data loads, leading to runtime errors
6. **`definePageMeta` called conditionally** — `definePageMeta` must be called statically at compile time; wrapping it in `if` breaks the compiler macro
7. **Large client bundles not code-split** — heavy libraries imported at the top level instead of inside `defineAsyncComponent` or dynamic `import()`
8. **No error handling for server routes** — `server/api/*.ts` handlers don't validate input or return proper HTTP status codes on failure
