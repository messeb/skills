---
description: Storybook setup, story authoring with CSF3, interaction tests, accessibility checks, visual regression testing, and documentation best practices.
---

# Storybook

## Purpose

Storybook serves three jobs simultaneously:

1. **Component workshop** — develop components in isolation without running the full app
2. **Living documentation** — stories are the canonical reference for all component states
3. **Test suite** — interaction tests, accessibility checks, and visual snapshots run in CI

---

## Setup

### Install (Vite + Vue or React)

```bash
pnpm dlx storybook@latest init
```

### Configuration (`/.storybook/main.ts`)

```ts
import type { StorybookConfig } from '@storybook/vue3-vite'

const config: StorybookConfig = {
  stories: ['../src/**/*.stories.@(ts|tsx)'],
  addons: [
    '@storybook/addon-essentials',
    '@storybook/addon-interactions',
    '@storybook/addon-a11y',
    '@chromatic-com/storybook',
  ],
  framework: {
    name: '@storybook/vue3-vite',
    options: {},
  },
}

export default config
```

### Preview (`/.storybook/preview.ts`)

```ts
import type { Preview } from '@storybook/vue3'
import { setup } from '@storybook/vue3'
import { createPinia } from 'pinia'
import { createI18n } from 'vue-i18n'
import '../src/assets/styles/global.css'

setup((app) => {
  app.use(createPinia())
  app.use(createI18n({ legacy: false, locale: 'en' }))
})

const preview: Preview = {
  parameters: {
    controls: { matchers: { color: /(background|color)$/i, date: /Date$/ } },
    layout: 'centered',
    backgrounds: {
      default: 'light',
      values: [
        { name: 'light', value: '#ffffff' },
        { name: 'dark', value: '#1a1a2e' },
        { name: 'surface', value: '#f5f5f5' },
      ],
    },
  },
  tags: ['autodocs'],
}

export default preview
```

---

## Writing Stories (CSF3)

### Single-responsibility stories

Each story represents **one specific, named state**. No conditionals inside stories.

```ts
// components/Badge/Badge.stories.ts
import type { Meta, StoryObj } from '@storybook/vue3'
import Badge from './Badge.vue'

const meta: Meta<typeof Badge> = {
  component: Badge,
  title: 'Components/Badge',
  args: {
    label: 'New',
  },
  argTypes: {
    variant: {
      control: 'select',
      options: ['default', 'success', 'warning', 'danger'],
      description: 'Visual style of the badge',
    },
    size: {
      control: 'radio',
      options: ['sm', 'md', 'lg'],
    },
  },
}

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {}

export const Success: Story = {
  args: { variant: 'success', label: 'Verified' },
}

export const Warning: Story = {
  args: { variant: 'warning', label: 'Pending' },
}

export const Danger: Story = {
  args: { variant: 'danger', label: 'Expired' },
}

export const LongLabel: Story = {
  args: { label: 'This is a very long badge label' },
}

export const WithIcon: Story = {
  args: { label: 'Admin', icon: 'shield' },
}
```

### Stories with slots (Vue)

```ts
// components/Card/Card.stories.ts
import type { Meta, StoryObj } from '@storybook/vue3'
import Card from './Card.vue'
import AppButton from '../AppButton/AppButton.vue'

const meta: Meta<typeof Card> = {
  component: Card,
  title: 'Components/Card',
}

export default meta
type Story = StoryObj<typeof meta>

export const WithActions: Story = {
  render: (args) => ({
    components: { Card, AppButton },
    setup: () => ({ args }),
    template: `
      <Card v-bind="args">
        <template #header>Card Title</template>
        <p>Card content goes here.</p>
        <template #footer>
          <AppButton variant="primary">Confirm</AppButton>
          <AppButton variant="ghost">Cancel</AppButton>
        </template>
      </Card>
    `,
  }),
}
```

### Stories with decorators

```ts
// Add padding/wrapper globally or per-story
export const Centered: Story = {
  decorators: [
    () => ({
      template: '<div style="display:flex;justify-content:center;padding:2rem"><story /></div>',
    }),
  ],
}
```

---

## Interaction Tests

Interaction tests run inside Storybook using `@storybook/addon-interactions` and `@storybook/test`.

```ts
// components/LoginForm/LoginForm.stories.ts
import type { Meta, StoryObj } from '@storybook/vue3'
import { within, userEvent, expect } from '@storybook/test'
import LoginForm from './LoginForm.vue'

const meta: Meta<typeof LoginForm> = {
  component: LoginForm,
  title: 'Forms/LoginForm',
}

export default meta
type Story = StoryObj<typeof meta>

export const SuccessfulLogin: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement)

    // Fill in the form
    await userEvent.type(canvas.getByLabelText('Email'), 'user@example.com')
    await userEvent.type(canvas.getByLabelText('Password'), 'secret123')

    // Submit
    await userEvent.click(canvas.getByRole('button', { name: 'Sign in' }))

    // Assert loading state appears
    await expect(canvas.getByRole('button')).toHaveAttribute('aria-busy', 'true')
  },
}

export const ValidationErrors: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement)

    // Submit empty form
    await userEvent.click(canvas.getByRole('button', { name: 'Sign in' }))

    // Errors should appear
    await expect(canvas.getByText('Email is required')).toBeInTheDocument()
    await expect(canvas.getByText('Password is required')).toBeInTheDocument()
  },
}

export const InvalidEmail: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement)
    await userEvent.type(canvas.getByLabelText('Email'), 'not-an-email')
    await userEvent.tab() // trigger blur validation
    await expect(canvas.getByText('Enter a valid email address')).toBeInTheDocument()
  },
}
```

### Run interaction tests in CI

```bash
# Run all interaction tests headlessly
pnpm storybook --ci &
pnpm wait-on http://localhost:6006
pnpm test-storybook --url http://localhost:6006
```

---

## Accessibility Testing

`@storybook/addon-a11y` runs `axe-core` on every story automatically. Fail CI on violations.

```ts
// .storybook/preview.ts — fail on serious violations
const preview: Preview = {
  parameters: {
    a11y: {
      config: {
        rules: [
          { id: 'color-contrast', enabled: true },
          { id: 'button-name', enabled: true },
        ],
      },
    },
  },
}
```

Suppress known false positives with justification:

```ts
export const IconOnlyButton: Story = {
  args: { icon: 'close', ariaLabel: 'Close dialog' },
  parameters: {
    a11y: {
      config: {
        rules: [{ id: 'button-name', enabled: false }], // label provided via ariaLabel prop
      },
    },
  },
}
```

---

## Visual Regression Testing

Use [Chromatic](https://www.chromatic.com/) for automated visual diffing.

```yaml
# .github/workflows/chromatic.yml
- name: Publish to Chromatic
  uses: chromaui/action@latest
  with:
    projectToken: ${{ secrets.CHROMATIC_PROJECT_TOKEN }}
    exitZeroOnChanges: false   # fail PR if visual changes detected
    onlyChanged: true          # only test stories affected by changed files
```

For self-hosted visual testing with `@storybook/test-runner` + Percy:

```ts
// .storybook/test-runner.ts
import type { TestRunnerConfig } from '@storybook/test-runner'
import { percySnapshot } from '@percy/playwright'

const config: TestRunnerConfig = {
  async postVisit(page, context) {
    await percySnapshot(page, context.id)
  },
}

export default config
```

---

## Auto-Documentation with JSDoc

Storybook generates prop tables from TypeScript types automatically. Add JSDoc for descriptions.

```ts
// components/Input/Input.vue
interface Props {
  /** The input's current value */
  modelValue: string
  /** Label displayed above the input */
  label: string
  /** Helper text shown below the field */
  hint?: string
  /** Error message; when set the field shows an error state */
  error?: string
  /** Disables all interaction */
  disabled?: boolean
}
```

---

## Story Hierarchy and Naming

```text
title: 'Design System/Atoms/Button'       → Atoms > Button
title: 'Design System/Molecules/SearchBar'
title: 'Design System/Organisms/Header'
title: 'Forms/LoginForm'
title: 'Pages/Dashboard'
```

---

## Audit Checklist

1. **Missing states** — only happy-path story exists; no empty, loading, error, disabled, or edge-case stories
2. **Hardcoded story data** — story args use `id: 1` or `name: 'Test'` instead of descriptive, realistic values that resemble production data
3. **Logic inside stories** — stories contain `if`/`computed` to switch between states; each state should be its own named story
4. **No interaction tests for forms** — interactive components (forms, dialogs, dropdowns) have no `play` functions; behavior is unverified
5. **Global decorators missing** — providers (i18n, router, store) not set up in `preview.ts`; stories fail or render incorrectly in CI
6. **Ignored a11y violations** — addon-a11y shows red badges but no one acts on them; violations are accepted in CI
7. **Stale snapshots** — visual regression snapshots never reviewed; PRs always approved even with visual diffs
8. **Stories not co-located** — stories in a separate `stories/` directory, making it hard to find the story next to its component
