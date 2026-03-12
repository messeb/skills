---
description: Frontend component design — props API, slots, composability, atomic design, avoiding prop drilling, and component boundary decisions.
---

# Component Design

## The Core Question

Before writing a component, answer: **what is this component's single responsibility?**

A component should do one thing well. If you need "and" to describe it, split it.

---

## Component Granularity — Atomic Design

```
Atoms       → AppButton, AppInput, AppBadge, AppIcon
Molecules   → SearchField (Input + Button), FormField (Label + Input + Error)
Organisms   → NavigationBar, ProductCard, UserProfileHeader
Templates   → DashboardLayout, AuthLayout
Pages       → DashboardPage, LoginPage
```

Rules:
- Atoms have no business logic — only visual variants and user interaction events
- Molecules compose atoms with minor coordination logic
- Organisms contain business-meaningful structure; may connect to stores
- Templates define layout; no data fetching
- Pages fetch data, connect stores, and assemble organisms into templates

---

## Props API Design

### Be explicit about what varies

```ts
// Bad: loose, implicit API
interface Props {
  config: Record<string, any>
  data: any[]
  options?: any
}

// Good: explicit, typed, minimal surface area
interface Props {
  items: Product[]
  selectedId?: string
  loading?: boolean
  emptyLabel?: string
  onSelect?: (id: string) => void
}
```

### Use string unions, not booleans for variants

```ts
// Bad: boolean explosion
interface Props {
  isPrimary?: boolean
  isDanger?: boolean
  isOutline?: boolean
  isSmall?: boolean
  isLarge?: boolean
}

// Good: enum-style union
interface Props {
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
}
```

### Defaults belong in the component, not the parent

```ts
// Vue
const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  loading: false,
  disabled: false,
})

// React
function Button({ variant = 'primary', size = 'md', loading = false, ...rest }: Props) {}
```

### Avoid deep props

```ts
// Bad: component requires full user object but only uses name + avatar
interface Props {
  user: User  // User has 20 fields
}

// Good: only what you need
interface Props {
  userName: string
  userAvatarUrl: string
}
```

---

## Slots (Vue) / Render Props (React)

Slots are the primary extension point. Prefer them over complex conditional rendering.

### Vue slots

```vue
<!-- DataTable.vue — flexible, composable -->
<template>
  <table>
    <thead>
      <slot name="header" :columns="columns" />
    </thead>
    <tbody>
      <tr v-for="row in rows" :key="row.id">
        <slot name="row" :row="row" :index="index" />
      </tr>
    </tbody>
    <tfoot>
      <slot name="footer" :total="rows.length">
        <!-- Default footer -->
        <tr><td>{{ rows.length }} items</td></tr>
      </slot>
    </tfoot>
  </table>
</template>
```

```vue
<!-- Usage: parent controls rendering -->
<DataTable :rows="products" :columns="columns">
  <template #header="{ columns }">
    <th v-for="col in columns" :key="col.key" @click="sortBy(col.key)">
      {{ col.label }}
    </th>
  </template>
  <template #row="{ row }">
    <td>{{ row.name }}</td>
    <td><AppBadge :variant="row.status" /></td>
  </template>
</DataTable>
```

### React render props / children

```tsx
// List.tsx — accepts render function for item
interface Props<T> {
  items: T[]
  keyExtractor: (item: T) => string
  renderItem: (item: T, index: number) => React.ReactNode
  renderEmpty?: () => React.ReactNode
}

function List<T>({ items, keyExtractor, renderItem, renderEmpty }: Props<T>) {
  if (items.length === 0) {
    return renderEmpty?.() ?? <p>No items.</p>
  }
  return (
    <ul>
      {items.map((item, i) => (
        <li key={keyExtractor(item)}>{renderItem(item, i)}</li>
      ))}
    </ul>
  )
}

// Usage
<List
  items={products}
  keyExtractor={(p) => p.id}
  renderItem={(product) => <ProductCard product={product} />}
  renderEmpty={() => <EmptyState message="No products found" />}
/>
```

---

## Avoiding Prop Drilling

### When to use each solution

| Depth | Solution |
|-------|----------|
| 1-2 levels | Pass props directly |
| 2-3 levels, rarely changes | Slot/render prop to skip intermediate |
| 3+ levels, shared across subtree | `provide/inject` (Vue) or Context (React) |
| Global, changes frequently | Pinia store / Zustand |

### Vue `provide/inject` with type safety

```ts
// tokens.ts — define injection keys
import type { InjectionKey, Ref } from 'vue'

export interface TableContext {
  selectedRows: Ref<Set<string>>
  toggleRow: (id: string) => void
  isSelected: (id: string) => boolean
}

export const TableContextKey: InjectionKey<TableContext> = Symbol('TableContext')
```

```ts
// DataTable.vue — provide context to all descendants
import { TableContextKey } from './tokens'

const selectedRows = ref<Set<string>>(new Set())

provide(TableContextKey, {
  selectedRows,
  toggleRow: (id) => {
    if (selectedRows.value.has(id)) selectedRows.value.delete(id)
    else selectedRows.value.add(id)
  },
  isSelected: (id) => selectedRows.value.has(id),
})
```

```ts
// TableRow.vue — consume context without props
const { isSelected, toggleRow } = inject(TableContextKey)!
```

---

## Component Boundaries

### When to split a component

Split when:
- The component has more than ~200 lines of template
- Part of the component could be reused elsewhere
- Part of the component has different update frequency (static header vs dynamic body)
- You need to test a behavior in isolation

### When NOT to split

Don't split just because it looks big. Premature decomposition creates indirection without value.

```
One Form.vue at 300 lines
  ↓ don't split into
NameSection.vue + AddressSection.vue + PaymentSection.vue
  (unless those sections are genuinely reusable elsewhere)
```

---

## Component Communication Patterns

### Events flow up, data flows down

```
ParentPage
  ↓ props (data down)
  ProductList
    ↓ props
    ProductCard
      ↑ emits('add-to-cart', id)   (events up)
  ↑ handles add-to-cart
```

### Never mutate props

```ts
// Bad
const props = defineProps<{ count: number }>()
props.count++  // ← mutates parent's state silently

// Good: emit the intent, let parent decide
const emit = defineEmits<{ 'update:count': [value: number] }>()
function increment() {
  emit('update:count', props.count + 1)
}
```

---

## Compound Components

For complex, tightly-coupled UI (tabs, accordion, select), use the compound pattern:

```vue
<!-- Usage: natural, readable, flexible -->
<Tabs v-model="activeTab">
  <TabList>
    <Tab value="profile">Profile</Tab>
    <Tab value="security">Security</Tab>
    <Tab value="billing" :disabled="!isPremium">Billing</Tab>
  </TabList>
  <TabPanel value="profile"><ProfileForm /></TabPanel>
  <TabPanel value="security"><SecuritySettings /></TabPanel>
  <TabPanel value="billing"><BillingSettings /></TabPanel>
</Tabs>
```

Implementation uses `provide/inject` to share state between `Tabs`, `Tab`, and `TabPanel` without exposing it externally.

---

## Headless Components

Separate logic from presentation for maximum reusability:

```ts
// composables/useDropdown.ts — pure logic, no template
export function useDropdown() {
  const isOpen = ref(false)
  const selectedValue = ref<string | null>(null)
  const triggerRef = ref<HTMLElement | null>(null)

  function open() { isOpen.value = true }
  function close() { isOpen.value = false }
  function toggle() { isOpen.value = !isOpen.value }
  function select(value: string) {
    selectedValue.value = value
    close()
  }

  // Keyboard handling
  function handleKeydown(e: KeyboardEvent) {
    if (e.key === 'Escape') close()
    if (e.key === 'Enter' || e.key === ' ') toggle()
  }

  return { isOpen, selectedValue, triggerRef, open, close, toggle, select, handleKeydown }
}

// DesignSystem/Dropdown.vue  — branded, styled
// ProjectCustomDropdown.vue  — project-specific style
// Both use the same useDropdown() composable
```

---

## Audit Checklist

1. **God components** — one component handles data fetching, business logic, layout, and multiple visual states; break by responsibility
2. **Props as configuration objects** — `config={{ mode: 'edit', showFooter: true, ... }}` hides the API; each configurable aspect should be its own prop
3. **Boolean trap** — `<Button primary large outline round />` — multiple boolean props that can contradict each other; use `variant` and `size` unions instead
4. **Direct store access in atoms/molecules** — a Button or Input imports a Pinia store; dumb components should receive data via props only
5. **Missing default slot** — component renders fixed structure with no override points; adding slots costs nothing and saves a rewrite later
6. **Prop drilling through 4+ levels** — data passed through components that don't use it; use `provide/inject`, a store, or restructure the tree
7. **Emit names not matching v-model convention** — custom `v-model` props emit wrong event name (`change` instead of `update:modelValue`); breaks two-way binding
8. **Components that know too much about their parent** — a child component imports the parent's store or reads from parent-specific context; breaks reusability
