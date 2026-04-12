---
description: Frontend unit testing with Vitest/Jest — component tests, composable tests, AAA structure, mocking, Vue Test Utils, React Testing Library, and coverage patterns.
---

# Frontend Unit Testing

## Testing Philosophy

Unit tests for frontend code verify **behavior, not implementation**. Test what the component does, not how it does it internally.

```text
        /\
       /  \  E2E (Playwright, Cypress)
      /____\
     /      \
    / Integ. \ Component integration tests
   /__________\
  /            \
 /  Unit Tests  \ Composables, utils, logic
/________________\
```

**Unit (60-70%)**: Composables, utilities, pure logic, isolated components
**Component integration (20-30%)**: Components with real child components, user interactions
**E2E (5-10%)**: Critical user journeys end-to-end

---

## Project Setup

### Vitest (recommended for Vue/Vite projects)

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'happy-dom',
    globals: true,
    setupFiles: ['./tests/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov'],
      exclude: ['**/node_modules/**', '**/dist/**', '**/*.stories.ts'],
      thresholds: { lines: 80, functions: 80, branches: 75 },
    },
  },
})
```

```ts
// tests/setup.ts
import { config } from '@vue/test-utils'
import { createTestingPinia } from '@pinia/testing'

config.global.plugins = [createTestingPinia()]
```

### Jest (React / Next.js projects)

```ts
// jest.config.ts
import type { Config } from 'jest'

const config: Config = {
  testEnvironment: 'jsdom',
  setupFilesAfterFramework: ['<rootDir>/tests/setup.ts'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '\\.(css|scss)$': 'identity-obj-proxy',
  },
  transform: {
    '^.+\\.tsx?$': ['ts-jest', { tsconfig: 'tsconfig.test.json' }],
  },
  coverageThreshold: {
    global: { lines: 80, functions: 80, branches: 75 },
  },
}

export default config
```

---

## Testing Vue Components

### Basic Component Test (Vue Test Utils + Vitest)

```ts
// components/AppButton.test.ts
import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import AppButton from './AppButton.vue'

describe('AppButton', () => {
  it('renders slot content', () => {
    const wrapper = mount(AppButton, {
      slots: { default: 'Click me' },
    })
    expect(wrapper.text()).toBe('Click me')
  })

  it('emits click event when clicked', async () => {
    const wrapper = mount(AppButton)
    await wrapper.trigger('click')
    expect(wrapper.emitted('click')).toHaveLength(1)
  })

  it('does not emit click when disabled', async () => {
    const wrapper = mount(AppButton, {
      props: { disabled: true },
    })
    await wrapper.trigger('click')
    expect(wrapper.emitted('click')).toBeUndefined()
  })

  it('applies variant class', () => {
    const wrapper = mount(AppButton, {
      props: { variant: 'danger' },
    })
    expect(wrapper.classes()).toContain('btn--danger')
  })

  it('shows loading spinner when loading', () => {
    const wrapper = mount(AppButton, {
      props: { loading: true },
    })
    expect(wrapper.find('[data-testid="spinner"]').exists()).toBe(true)
    expect(wrapper.attributes('aria-busy')).toBe('true')
  })
})
```

### Testing Async Components

```ts
// components/UserCard.test.ts
import { describe, it, expect, vi } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import UserCard from './UserCard.vue'
import * as userService from '@/services/userService'

vi.mock('@/services/userService')

describe('UserCard', () => {
  it('shows skeleton while loading', () => {
    vi.mocked(userService.fetchUser).mockReturnValue(new Promise(() => {}))
    const wrapper = mount(UserCard, { props: { userId: '1' } })
    expect(wrapper.find('[data-testid="skeleton"]').exists()).toBe(true)
  })

  it('renders user data after loading', async () => {
    vi.mocked(userService.fetchUser).mockResolvedValue({
      id: '1',
      name: 'Jane Doe',
      email: 'jane@example.com',
    })
    const wrapper = mount(UserCard, { props: { userId: '1' } })
    await flushPromises()
    expect(wrapper.find('[data-testid="user-name"]').text()).toBe('Jane Doe')
  })

  it('shows error message on failure', async () => {
    vi.mocked(userService.fetchUser).mockRejectedValue(new Error('Not found'))
    const wrapper = mount(UserCard, { props: { userId: '999' } })
    await flushPromises()
    expect(wrapper.find('[data-testid="error"]').exists()).toBe(true)
  })
})
```

### Testing with Pinia

```ts
// components/CartSummary.test.ts
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { createTestingPinia } from '@pinia/testing'
import CartSummary from './CartSummary.vue'
import { useCartStore } from '@/stores/cart'

describe('CartSummary', () => {
  it('displays item count from store', () => {
    const wrapper = mount(CartSummary, {
      global: {
        plugins: [
          createTestingPinia({
            initialState: {
              cart: { items: [{ id: '1', qty: 2 }, { id: '2', qty: 1 }] },
            },
          }),
        ],
      },
    })
    expect(wrapper.find('[data-testid="item-count"]').text()).toBe('3')
  })

  it('calls removeItem action when remove button clicked', async () => {
    const wrapper = mount(CartSummary, {
      global: {
        plugins: [
          createTestingPinia({
            initialState: { cart: { items: [{ id: '1', qty: 1, name: 'Hat' }] } },
          }),
        ],
      },
    })
    const store = useCartStore()
    await wrapper.find('[data-testid="remove-item"]').trigger('click')
    expect(store.removeItem).toHaveBeenCalledWith('1')
  })
})
```

---

## Testing React Components

### Basic Component Test (React Testing Library)

```tsx
// components/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Button } from './Button'

describe('Button', () => {
  it('renders children', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument()
  })

  it('calls onClick when clicked', async () => {
    const user = userEvent.setup()
    const handleClick = vi.fn()
    render(<Button onClick={handleClick}>Click me</Button>)
    await user.click(screen.getByRole('button'))
    expect(handleClick).toHaveBeenCalledOnce()
  })

  it('is disabled when disabled prop is set', () => {
    render(<Button disabled>Click me</Button>)
    expect(screen.getByRole('button')).toBeDisabled()
  })

  it('shows loading indicator when loading', () => {
    render(<Button loading>Submit</Button>)
    expect(screen.getByRole('button')).toHaveAttribute('aria-busy', 'true')
    expect(screen.getByLabelText('Loading')).toBeInTheDocument()
  })
})
```

### Testing Custom Hooks

```ts
// hooks/useCounter.test.ts
import { renderHook, act } from '@testing-library/react'
import { useCounter } from './useCounter'

describe('useCounter', () => {
  it('starts at initial value', () => {
    const { result } = renderHook(() => useCounter(5))
    expect(result.current.count).toBe(5)
  })

  it('increments count', () => {
    const { result } = renderHook(() => useCounter(0))
    act(() => result.current.increment())
    expect(result.current.count).toBe(1)
  })

  it('respects max value', () => {
    const { result } = renderHook(() => useCounter(10, { max: 10 }))
    act(() => result.current.increment())
    expect(result.current.count).toBe(10)
  })

  it('resets to initial value', () => {
    const { result } = renderHook(() => useCounter(3))
    act(() => result.current.increment())
    act(() => result.current.reset())
    expect(result.current.count).toBe(3)
  })
})
```

---

## Testing Composables (Vue)

```ts
// composables/useDebounce.test.ts
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { ref } from 'vue'
import { useDebounce } from './useDebounce'

describe('useDebounce', () => {
  beforeEach(() => { vi.useFakeTimers() })
  afterEach(() => { vi.restoreAllMocks() })

  it('returns initial value immediately', () => {
    const input = ref('hello')
    const { debounced } = useDebounce(input, 300)
    expect(debounced.value).toBe('hello')
  })

  it('delays update by specified ms', async () => {
    const input = ref('hello')
    const { debounced } = useDebounce(input, 300)
    input.value = 'world'
    expect(debounced.value).toBe('hello')
    vi.advanceTimersByTime(300)
    expect(debounced.value).toBe('world')
  })

  it('cancels previous timer on rapid changes', () => {
    const input = ref('a')
    const { debounced } = useDebounce(input, 300)
    input.value = 'b'
    vi.advanceTimersByTime(100)
    input.value = 'c'
    vi.advanceTimersByTime(300)
    expect(debounced.value).toBe('c') // not 'b'
  })
})
```

---

## Mocking Strategies

### Mock modules

```ts
// Mock at module level
vi.mock('@/api/client', () => ({
  apiClient: {
    get: vi.fn(),
    post: vi.fn(),
  },
}))

// Mock with factory
vi.mock('@/composables/useAuth', () => ({
  useAuth: () => ({
    user: ref({ id: '1', role: 'admin' }),
    isAuthenticated: computed(() => true),
    logout: vi.fn(),
  }),
}))
```

### Mock timers

```ts
beforeEach(() => vi.useFakeTimers())
afterEach(() => vi.restoreAllMocks())

it('auto-dismisses after 3 seconds', () => {
  const wrapper = mount(Toast, { props: { message: 'Saved!' } })
  expect(wrapper.isVisible()).toBe(true)
  vi.advanceTimersByTime(3000)
  expect(wrapper.isVisible()).toBe(false)
})
```

### Mock fetch / HTTP

```ts
import { http, HttpResponse } from 'msw'
import { setupServer } from 'msw/node'

const server = setupServer(
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'Jane Doe' })
  }),
)

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

---

## Test Organization

```text
tests/
├── setup.ts
├── utils/
│   ├── renderWithProviders.tsx     # React: wrap with context/store
│   └── mountWithPlugins.ts         # Vue: mount with global plugins
├── factories/
│   ├── userFactory.ts              # Build test data
│   └── productFactory.ts
├── mocks/
│   ├── handlers.ts                 # MSW request handlers
│   └── server.ts
└── __snapshots__/                  # Only for stable, intentional snapshots
```

### Test data factories

```ts
// tests/factories/userFactory.ts
import { faker } from '@faker-js/faker'
import type { User } from '@/types'

export function createUser(overrides: Partial<User> = {}): User {
  return {
    id: faker.string.uuid(),
    name: faker.person.fullName(),
    email: faker.internet.email(),
    role: 'user',
    createdAt: faker.date.past().toISOString(),
    ...overrides,
  }
}

// Usage
const adminUser = createUser({ role: 'admin' })
const users = Array.from({ length: 5 }, () => createUser())
```

---

## Snapshot Testing

Use sparingly. Only snapshot stable, intentional output — not entire component trees.

```ts
// Good: snapshot a rendered icon set
it('renders correct icon for each severity level', () => {
  const { container } = render(<AlertIcon severity="error" />)
  expect(container.firstChild).toMatchSnapshot()
})

// Bad: snapshotting a large component that changes often
it('matches snapshot', () => {
  const { container } = render(<FullPageDashboard />)
  expect(container).toMatchSnapshot() // ← fragile, noisy diffs
})
```

---

## Audit Checklist

1. **Testing implementation details** — accessing `wrapper.vm._data`, checking internal state, or testing method calls instead of DOM/behavior
2. **Snapshot tests for large trees** — snapshots fail on every UI change; restrict to small, stable, intentional outputs
3. **Missing async handling** — not using `await flushPromises()` or `waitFor()` after async operations, leading to false positives
4. **Mocking too much** — every dependency mocked; tests pass but integration breaks; prefer real composables/stores in unit tests
5. **No negative cases** — only testing the happy path; missing disabled states, empty states, error states, and boundary values
6. **Brittle selectors** — querying by CSS class or index instead of `data-testid`, role, or accessible name
7. **Test pollution** — shared mutable state between tests; always reset mocks in `afterEach`
8. **Coverage theater** — high coverage from `it('renders without error')` tests that assert nothing meaningful
