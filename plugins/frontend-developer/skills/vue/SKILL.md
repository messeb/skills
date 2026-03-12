---
description: Vue.js best practices — Composition API, composables, reactivity model, component design, performance, and common pitfalls.
---

# Vue.js Best Practices

## Composition API Over Options API

Use `<script setup>` for all new components. It is more concise, better TypeScript support, and has superior tree-shaking.

```vue
<!-- Bad: Options API -->
<script>
export default {
  data() {
    return { count: 0 }
  },
  computed: {
    doubled() { return this.count * 2 }
  },
  methods: {
    increment() { this.count++ }
  }
}
</script>

<!-- Good: Composition API with <script setup> -->
<script setup lang="ts">
const count = ref(0)
const doubled = computed(() => count.value * 2)
function increment() { count.value++ }
</script>
```

---

## Reactivity System

### `ref` vs `reactive`

```ts
// ref: primitives and values you'll reassign
const count = ref(0)
const user = ref<User | null>(null)
user.value = fetchedUser  // ← reassignment works

// reactive: objects you'll never reassign
const form = reactive({ name: '', email: '' })
form.name = 'Jane'       // ← fine

// Common mistake: destructuring reactive loses reactivity
const { name } = form    // ← name is now a plain string, not reactive!

// Fix: use toRefs
const { name, email } = toRefs(form)
```

### Computed properties

```ts
// Read-only computed
const fullName = computed(() => `${firstName.value} ${lastName.value}`)

// Writable computed (use sparingly)
const fullName = computed({
  get: () => `${firstName.value} ${lastName.value}`,
  set: (value) => {
    const [first, ...rest] = value.split(' ')
    firstName.value = first
    lastName.value = rest.join(' ')
  },
})

// Don't create computed properties with side effects
const expensiveList = computed(() => {
  // Good: pure transformation
  return items.value.filter(i => i.active).sort(...)
})
```

### Watch

```ts
// watch: run side effects when reactive data changes
watch(userId, async (newId, oldId) => {
  if (newId === oldId) return
  user.value = await fetchUser(newId)
}, { immediate: true })

// watchEffect: track dependencies automatically
watchEffect(() => {
  // Every reactive access here is tracked automatically
  document.title = `${pageTitle.value} | ${siteName.value}`
})

// Watch deep object changes
watch(
  () => ({ ...form }),  // shallow copy to detect nested changes
  (newForm) => { validate(newForm) },
  { deep: true }
)

// Cleanup side effects
watchEffect((onCleanup) => {
  const controller = new AbortController()
  onCleanup(() => controller.abort())
  fetch(`/api/users/${userId.value}`, { signal: controller.signal })
    .then(r => r.json())
    .then(data => { user.value = data })
})
```

---

## Composables

Composables are the primary code reuse mechanism in Vue 3. Extract any stateful logic shared between components.

### Anatomy of a composable

```ts
// composables/usePagination.ts
import { ref, computed } from 'vue'

interface UsePaginationOptions {
  initialPage?: number
  pageSize?: number
}

export function usePagination(total: Ref<number>, options: UsePaginationOptions = {}) {
  const { initialPage = 1, pageSize = 20 } = options

  const currentPage = ref(initialPage)

  const totalPages = computed(() => Math.ceil(total.value / pageSize))
  const offset = computed(() => (currentPage.value - 1) * pageSize)
  const hasPrev = computed(() => currentPage.value > 1)
  const hasNext = computed(() => currentPage.value < totalPages.value)

  function goTo(page: number) {
    currentPage.value = Math.max(1, Math.min(page, totalPages.value))
  }

  function next() { if (hasNext.value) goTo(currentPage.value + 1) }
  function prev() { if (hasPrev.value) goTo(currentPage.value - 1) }

  return {
    currentPage: readonly(currentPage),
    totalPages,
    offset,
    hasPrev,
    hasNext,
    goTo,
    next,
    prev,
  }
}
```

### Async composable with error handling

```ts
// composables/useAsync.ts
export function useAsync<T>(fn: () => Promise<T>) {
  const data = ref<T | null>(null)
  const error = ref<Error | null>(null)
  const loading = ref(false)

  async function execute() {
    loading.value = true
    error.value = null
    try {
      data.value = await fn()
    } catch (e) {
      error.value = e instanceof Error ? e : new Error(String(e))
    } finally {
      loading.value = false
    }
  }

  return { data, error, loading, execute }
}

// Usage
const { data: user, loading, error, execute: loadUser } = useAsync(() => fetchUser(userId.value))
watch(userId, loadUser, { immediate: true })
```

### Lifecycle-aware composable

```ts
// composables/useEventListener.ts
export function useEventListener<K extends keyof WindowEventMap>(
  target: Ref<EventTarget | null> | Window,
  event: K,
  handler: (e: WindowEventMap[K]) => void,
  options?: AddEventListenerOptions,
) {
  onMounted(() => {
    const el = isRef(target) ? target.value : target
    el?.addEventListener(event, handler as EventListener, options)
  })

  onUnmounted(() => {
    const el = isRef(target) ? target.value : target
    el?.removeEventListener(event, handler as EventListener, options)
  })
}
```

---

## Component Design

### Props: be explicit and typed

```ts
// Bad: loose typing
const props = defineProps({
  user: Object,
  size: String,
})

// Good: typed interface
interface Props {
  user: User
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
}
const props = withDefaults(defineProps<Props>(), {
  size: 'md',
  loading: false,
})
```

### Emit: declare and type all events

```ts
const emit = defineEmits<{
  'update:modelValue': [value: string]
  'submit': [formData: FormData]
  'cancel': []
}>()
```

### v-model on custom components

```vue
<!-- ParentComponent.vue -->
<AppInput v-model="name" />

<!-- AppInput.vue -->
<script setup lang="ts">
const props = defineProps<{ modelValue: string }>()
const emit = defineEmits<{ 'update:modelValue': [value: string] }>()

// Writable computed is the clean pattern
const value = computed({
  get: () => props.modelValue,
  set: (v) => emit('update:modelValue', v),
})
</script>
<template>
  <input v-model="value" />
</template>
```

### Slots with type safety

```vue
<script setup lang="ts">
defineSlots<{
  default(props: { item: Product; index: number }): any
  empty(): any
  header(props: { total: number }): any
}>()
</script>
```

---

## Performance

### `v-once` and `v-memo`

```html
<!-- Render once and never update (for static content) -->
<AppLogo v-once />

<!-- Only re-render when dependencies change -->
<UserRow
  v-for="user in users"
  :key="user.id"
  v-memo="[user.name, user.status]"
  :user="user"
/>
```

### Lazy load components

```ts
// Lazy-load heavy components
const RichTextEditor = defineAsyncComponent(() =>
  import('./RichTextEditor.vue')
)

// With loading/error states
const DataGrid = defineAsyncComponent({
  loader: () => import('./DataGrid.vue'),
  loadingComponent: Skeleton,
  errorComponent: ErrorBoundary,
  delay: 200,
  timeout: 10000,
})
```

### `shallowRef` for large non-reactive objects

```ts
// If you have a large object that Vue shouldn't deeply track
const chart = shallowRef<ChartInstance | null>(null)
// Mutations won't be tracked — only chart.value replacement
```

---

## Provide / Inject

For dependency injection that avoids prop drilling:

```ts
// Parent (provide)
import { provide, readonly } from 'vue'
import type { InjectionKey } from 'vue'

export const ThemeKey: InjectionKey<{ theme: Ref<string>; setTheme: (t: string) => void }> =
  Symbol('theme')

const theme = ref('light')
provide(ThemeKey, {
  theme: readonly(theme),
  setTheme: (t) => { theme.value = t },
})

// Child (inject)
const { theme, setTheme } = inject(ThemeKey)!
```

---

## Teleport

Render modal/tooltip content outside the component tree (e.g., to `<body>`) to avoid CSS stacking context issues:

```html
<Teleport to="body">
  <Modal v-if="isOpen" @close="isOpen = false">
    <slot />
  </Modal>
</Teleport>
```

---

## Audit Checklist

1. **`.value` forgotten in templates** — accessing `ref.value` in `<template>` (auto-unwrapped); accessing it in nested objects does require `.value`
2. **Mutating props** — modifying `props.x = ...` directly; always emit an update event or use a writable computed
3. **Reactive object destructuring** — `const { name } = reactive({ name: 'x' })` loses reactivity; use `toRefs`
4. **Missing `key` on `v-for`** — causes subtle rendering bugs when list items reorder or change
5. **Side effects in `computed`** — API calls, mutations, or DOM manipulation inside computed properties; use `watchEffect` or `watch` instead
6. **Memory leaks in composables** — adding event listeners or intervals in `onMounted` without removing them in `onUnmounted`
7. **`watch` without cleanup** — async watchers that fire a new request before the previous resolves; use `onCleanup` to abort
8. **Large composable files** — one composable doing three different things; split by single responsibility
