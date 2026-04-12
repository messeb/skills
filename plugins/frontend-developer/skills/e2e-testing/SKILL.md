---
description: End-to-end testing with Playwright — test setup, page objects, user journeys, network interception, CI integration, and flakiness prevention.
---

# End-to-End Testing with Playwright

## When to Write E2E Tests

E2E tests are expensive to write and maintain. Reserve them for:

- Critical user journeys (auth, checkout, core workflow)
- Cross-page flows that unit tests cannot cover
- Regressions in previously broken flows

Do **not** E2E-test things that Storybook interaction tests or component tests cover.

---

## Setup

```bash
pnpm create playwright
```

### `playwright.config.ts`

```ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 4 : undefined,
  reporter: [
    ['html', { open: 'never' }],
    ['github'],
  ],
  use: {
    baseURL: process.env.BASE_URL ?? 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'mobile', use: { ...devices['iPhone 14'] } },
  ],
  webServer: {
    command: 'pnpm dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
```

---

## Page Object Model

Encapsulate page interactions in Page Objects so test logic stays readable.

```ts
// e2e/pages/LoginPage.ts
import type { Page, Locator } from '@playwright/test'

export class LoginPage {
  readonly emailInput: Locator
  readonly passwordInput: Locator
  readonly submitButton: Locator
  readonly errorMessage: Locator

  constructor(private readonly page: Page) {
    this.emailInput = page.getByLabel('Email')
    this.passwordInput = page.getByLabel('Password')
    this.submitButton = page.getByRole('button', { name: 'Sign in' })
    this.errorMessage = page.getByRole('alert')
  }

  async goto() {
    await this.page.goto('/login')
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email)
    await this.passwordInput.fill(password)
    await this.submitButton.click()
  }

  async expectError(message: string) {
    await this.errorMessage.waitFor()
    await expect(this.errorMessage).toContainText(message)
  }
}
```

```ts
// e2e/pages/DashboardPage.ts
import type { Page, Locator } from '@playwright/test'

export class DashboardPage {
  readonly heading: Locator
  readonly userMenu: Locator

  constructor(private readonly page: Page) {
    this.heading = page.getByRole('heading', { level: 1 })
    this.userMenu = page.getByTestId('user-menu')
  }

  async waitForLoad() {
    await this.page.waitForURL('/dashboard')
    await this.heading.waitFor()
  }

  async logout() {
    await this.userMenu.click()
    await this.page.getByRole('menuitem', { name: 'Sign out' }).click()
  }
}
```

---

## Writing Tests

```ts
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test'
import { LoginPage } from './pages/LoginPage'
import { DashboardPage } from './pages/DashboardPage'

test.describe('Authentication', () => {
  test('user can log in with valid credentials', async ({ page }) => {
    const login = new LoginPage(page)
    const dashboard = new DashboardPage(page)

    await login.goto()
    await login.login('user@example.com', 'correctpassword')
    await dashboard.waitForLoad()

    await expect(dashboard.heading).toBeVisible()
  })

  test('shows error for invalid credentials', async ({ page }) => {
    const login = new LoginPage(page)

    await login.goto()
    await login.login('user@example.com', 'wrongpassword')
    await login.expectError('Invalid email or password')

    // Should stay on login page
    await expect(page).toHaveURL('/login')
  })

  test('redirects to login when accessing protected route unauthenticated', async ({ page }) => {
    await page.goto('/dashboard')
    await expect(page).toHaveURL('/login?redirect=%2Fdashboard')
  })

  test('redirects to original page after login', async ({ page }) => {
    await page.goto('/dashboard')
    await page.getByLabel('Email').fill('user@example.com')
    await page.getByLabel('Password').fill('correctpassword')
    await page.getByRole('button', { name: 'Sign in' }).click()
    await expect(page).toHaveURL('/dashboard')
  })
})
```

---

## Authentication State

Avoid logging in through the UI for every test — it's slow and couples tests to the auth UI.

### Store and reuse authentication state

```ts
// e2e/fixtures/auth.ts
import { test as base, expect } from '@playwright/test'
import type { Page } from '@playwright/test'

type AuthFixtures = {
  authenticatedPage: Page
}

export const test = base.extend<AuthFixtures>({
  authenticatedPage: async ({ browser }, use) => {
    const context = await browser.newContext({
      storageState: 'e2e/.auth/user.json',
    })
    const page = await context.newPage()
    await use(page)
    await context.close()
  },
})

export { expect }
```

```ts
// e2e/global-setup.ts — runs once before all tests
import { chromium } from '@playwright/test'

export default async function globalSetup() {
  const browser = await chromium.launch()
  const page = await browser.newPage()

  await page.goto('http://localhost:3000/login')
  await page.getByLabel('Email').fill(process.env.TEST_USER_EMAIL!)
  await page.getByLabel('Password').fill(process.env.TEST_USER_PASSWORD!)
  await page.getByRole('button', { name: 'Sign in' }).click()
  await page.waitForURL('/dashboard')

  await page.context().storageState({ path: 'e2e/.auth/user.json' })
  await browser.close()
}
```

```ts
// playwright.config.ts
export default defineConfig({
  globalSetup: './e2e/global-setup.ts',
  // ...
})
```

```ts
// e2e/dashboard.spec.ts — using pre-authenticated fixture
import { test, expect } from './fixtures/auth'

test('dashboard shows user data', async ({ authenticatedPage: page }) => {
  await page.goto('/dashboard')
  await expect(page.getByTestId('user-greeting')).toBeVisible()
})
```

---

## Network Interception

Use network interception to test loading states, errors, and edge cases without a live API.

```ts
test('shows error banner when API fails', async ({ page }) => {
  await page.route('/api/products', (route) =>
    route.fulfill({ status: 500, body: 'Internal Server Error' })
  )

  await page.goto('/products')

  await expect(page.getByRole('alert')).toContainText('Failed to load products')
})

test('shows empty state when no products exist', async ({ page }) => {
  await page.route('/api/products', (route) =>
    route.fulfill({ json: { items: [], total: 0 } })
  )

  await page.goto('/products')

  await expect(page.getByText('No products found')).toBeVisible()
})

test('shows skeleton loader while data loads', async ({ page }) => {
  let resolveRequest: () => void
  const pending = new Promise<void>((resolve) => { resolveRequest = resolve })

  await page.route('/api/products', async (route) => {
    await pending
    await route.fulfill({ json: { items: [] } })
  })

  const navPromise = page.goto('/products')
  await expect(page.getByTestId('skeleton')).toBeVisible()
  resolveRequest!()
  await navPromise
})
```

---

## Flakiness Prevention

### Avoid hard waits

```ts
// Bad
await page.waitForTimeout(1000)

// Good
await page.waitForSelector('[data-testid="result"]')
await expect(page.getByTestId('result')).toBeVisible()
```

### Use auto-retrying assertions

```ts
// Playwright auto-retries expect() assertions — lean into this
await expect(page.getByText('Item saved')).toBeVisible() // retries for up to 5s
```

### Isolate test data

```ts
test.beforeEach(async ({ request }) => {
  // Seed fresh test data before each test via API
  await request.post('/api/test/reset', {
    data: { fixture: 'products-with-inventory' },
  })
})
```

---

## CI Integration

```yaml
# .github/workflows/e2e.yml
- name: Install Playwright Browsers
  run: pnpm exec playwright install --with-deps chromium

- name: Run E2E Tests
  run: pnpm exec playwright test
  env:
    BASE_URL: http://localhost:3000
    TEST_USER_EMAIL: ${{ secrets.TEST_USER_EMAIL }}
    TEST_USER_PASSWORD: ${{ secrets.TEST_USER_PASSWORD }}

- name: Upload Report
  uses: actions/upload-artifact@v4
  if: always()
  with:
    name: playwright-report
    path: playwright-report/
    retention-days: 30
```

---

## Audit Checklist

1. **Tests depend on test execution order** — shared database state mutated by previous tests; each test must be self-contained or reset state in `beforeEach`
2. **Logging in through the UI every test** — slow; use stored auth state via `storageState` for non-auth tests
3. **`waitForTimeout` calls** — fixed sleeps cause both slowness and flakiness; replace with auto-retrying `expect()` or `waitForSelector`
4. **Selecting by CSS class or XPath** — brittle; prefer `getByRole`, `getByLabel`, `getByTestId`
5. **No retry strategy in CI** — transient failures (network, CI load) cause false negatives; set `retries: 2` in CI config
6. **Testing too much through E2E** — unit-testable logic verified end-to-end; slow suite that duplicates component test coverage
7. **No trace/screenshot on failure** — failures in CI are impossible to debug; enable `trace: 'on-first-retry'` and upload artifacts
8. **Hardcoded `localhost:3000`** — not using `baseURL` from config; tests break when port changes or run against staging
