---
description: Accessibility testing — WCAG compliance, axe-core, keyboard navigation, ARIA patterns, screen reader testing, and audit checklist.
---

# Accessibility (a11y) Testing

## Why Accessibility is Non-Negotiable

- Legal requirement in many jurisdictions (ADA, EN 301 549, EAA)
- ~15% of users have a disability affecting how they use the web
- Accessible code is better code: clear semantics, keyboard support, and focus management benefit all users

**Target: WCAG 2.1 Level AA** (Level AAA for high-impact features)

---

## The Four Principles (POUR)

| Principle | Means |
|-----------|-------|
| **Perceivable** | Content can be seen, heard, or sensed |
| **Operable** | All functionality is accessible via keyboard |
| **Understandable** | UI is predictable, errors are clear |
| **Robust** | Works with current and future assistive technology |

---

## Automated Testing

Automated tools catch ~30-40% of accessibility issues. They are necessary but not sufficient.

### axe-core with Vitest / Jest

```bash
pnpm add -D axe-core vitest-axe
# or for React:
pnpm add -D @axe-core/react jest-axe
```

```ts
// tests/setup.ts
import { toHaveNoViolations } from 'vitest-axe'
expect.extend(toHaveNoViolations)
```

```ts
// components/Modal/Modal.test.ts
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { axe } from 'vitest-axe'
import Modal from './Modal.vue'

describe('Modal accessibility', () => {
  it('has no axe violations', async () => {
    const wrapper = mount(Modal, {
      props: { open: true, title: 'Confirm action' },
      slots: { default: '<p>Are you sure?</p>' },
      attachTo: document.body,
    })
    const results = await axe(wrapper.element)
    expect(results).toHaveNoViolations()
  })
})
```

### axe-core with Playwright

```ts
// e2e/a11y.spec.ts
import { test, expect } from '@playwright/test'
import AxeBuilder from '@axe-core/playwright'

test.describe('Accessibility', () => {
  test('homepage has no critical violations', async ({ page }) => {
    await page.goto('/')
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .analyze()
    expect(results.violations).toEqual([])
  })

  test('dashboard is accessible when authenticated', async ({ page }) => {
    // ... setup auth
    await page.goto('/dashboard')
    const results = await new AxeBuilder({ page })
      .exclude('[data-third-party]')  // exclude known third-party widget
      .analyze()
    expect(results.violations).toEqual([])
  })
})
```

### Storybook a11y addon (real-time feedback)

```ts
// .storybook/preview.ts
import type { Preview } from '@storybook/vue3'

const preview: Preview = {
  parameters: {
    a11y: {
      // Fail CI on serious and critical violations
      config: { rules: [{ id: 'color-contrast', enabled: true }] },
    },
  },
}
```

---

## Semantic HTML First

Before reaching for ARIA, use the right HTML element.

```html
<!-- Bad -->
<div class="btn" onclick="submit()">Submit</div>
<div class="heading">Page Title</div>
<span class="link" onclick="navigate()">Go back</span>

<!-- Good -->
<button type="submit">Submit</button>
<h1>Page Title</h1>
<a href="/back">Go back</a>
```

**The first rule of ARIA**: Don't use ARIA if a native HTML element already provides the semantics.

---

## ARIA Patterns

### Labeling interactive elements

```html
<!-- Form inputs: use <label> -->
<label for="search-input">Search products</label>
<input id="search-input" type="search" />

<!-- Icon buttons: use aria-label -->
<button aria-label="Close dialog" type="button">
  <svg aria-hidden="true" focusable="false">...</svg>
</button>

<!-- Input with visible label AND description -->
<label for="email">Email address</label>
<input
  id="email"
  type="email"
  aria-describedby="email-hint email-error"
/>
<p id="email-hint">We'll never share your email.</p>
<p id="email-error" role="alert">{{ errorMessage }}</p>
```

### Live regions for dynamic content

```html
<!-- Announce status updates without moving focus -->
<div role="status" aria-live="polite" aria-atomic="true">
  {{ statusMessage }}
</div>

<!-- For urgent, interruptive announcements -->
<div role="alert" aria-live="assertive">
  {{ errorMessage }}
</div>
```

### Dialog / Modal

```html
<dialog
  role="dialog"
  aria-modal="true"
  aria-labelledby="dialog-title"
  aria-describedby="dialog-desc"
>
  <h2 id="dialog-title">Confirm deletion</h2>
  <p id="dialog-desc">This action cannot be undone.</p>
  <!-- Focus must be trapped inside while open -->
  <button type="button">Cancel</button>
  <button type="button">Delete</button>
</dialog>
```

### Navigation landmarks

```html
<header role="banner">
  <nav aria-label="Main navigation">...</nav>
</header>
<main id="main-content">
  <nav aria-label="Breadcrumb">...</nav>
</main>
<footer role="contentinfo">...</footer>
```

---

## Keyboard Navigation

Every interactive element must be reachable and operable via keyboard alone.

```ts
// composables/useFocusTrap.ts — trap focus inside modal/drawer
import { ref, onMounted, onUnmounted } from 'vue'

export function useFocusTrap(containerRef: Ref<HTMLElement | null>) {
  const focusableSelectors = [
    'a[href]', 'button:not([disabled])',
    'input:not([disabled])', 'select:not([disabled])',
    'textarea:not([disabled])', '[tabindex]:not([tabindex="-1"])',
  ].join(', ')

  function handleKeydown(e: KeyboardEvent) {
    if (e.key !== 'Tab' || !containerRef.value) return

    const focusable = Array.from(
      containerRef.value.querySelectorAll<HTMLElement>(focusableSelectors)
    )
    const first = focusable[0]
    const last = focusable[focusable.length - 1]

    if (e.shiftKey && document.activeElement === first) {
      e.preventDefault()
      last.focus()
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault()
      first.focus()
    }
  }

  onMounted(() => document.addEventListener('keydown', handleKeydown))
  onUnmounted(() => document.removeEventListener('keydown', handleKeydown))
}
```

### Return focus after dialog closes

```ts
// composables/useDialog.ts
export function useDialog() {
  const isOpen = ref(false)
  let triggerElement: HTMLElement | null = null

  function open(event: Event) {
    triggerElement = event.currentTarget as HTMLElement
    isOpen.value = true
  }

  function close() {
    isOpen.value = false
    // Return focus to the element that triggered the dialog
    nextTick(() => triggerElement?.focus())
  }

  return { isOpen, open, close }
}
```

### Skip navigation link

```html
<!-- First element in <body> — allows keyboard users to skip nav -->
<a class="skip-link" href="#main-content">Skip to main content</a>

<style>
.skip-link {
  position: absolute;
  transform: translateY(-100%);
  transition: transform 0.2s;
}
.skip-link:focus {
  transform: translateY(0);
}
</style>
```

---

## Color and Contrast

```ts
// Minimum contrast ratios (WCAG 2.1 AA)
// Normal text (< 18pt / < 14pt bold): 4.5:1
// Large text (>= 18pt / >= 14pt bold): 3:1
// UI components and graphics: 3:1

// Test with automated tools or manually:
// https://webaim.org/resources/contrastchecker/
// Chrome DevTools > Rendering > Emulate vision deficiencies
```

Never rely on color alone to convey information:

```html
<!-- Bad: red/green only -->
<span class="status-dot" :class="{ red: isError, green: isSuccess }"></span>

<!-- Good: color + icon + text -->
<span class="status" :class="status">
  <svg aria-hidden="true">...</svg>
  {{ status === 'error' ? 'Failed' : 'Success' }}
</span>
```

---

## Keyboard Testing Checklist

Run through these manually with only a keyboard (no mouse):

- [ ] Tab through every interactive element — does focus move logically?
- [ ] Is focus always visible? (no `outline: none` without a replacement)
- [ ] Can every action be triggered with Enter/Space?
- [ ] Are custom dropdowns/selects operable with arrow keys?
- [ ] Does opening a modal trap focus inside it?
- [ ] Does closing a modal return focus to the trigger element?
- [ ] Is there a skip-to-main-content link at the top of every page?

---

## Screen Reader Testing

| Platform | Screen Reader | Browser |
|----------|---------------|---------|
| macOS/iOS | VoiceOver | Safari |
| Windows | NVDA | Firefox/Chrome |
| Windows | JAWS | Chrome |
| Android | TalkBack | Chrome |

Basic VoiceOver test (macOS):

1. `Cmd + F5` to enable VoiceOver
2. `Tab` / `Shift+Tab` to navigate
3. `VO + Right` to read content in sequence
4. Verify headings, regions, and form labels are announced correctly

---

## Audit Checklist

1. **Missing alt text** — `<img>` without `alt`; decorative images must have `alt=""`; informative images need descriptive alt text
2. **Non-semantic interactive elements** — `<div>` or `<span>` used as buttons without `role="button"` and `tabindex="0"`
3. **No visible focus indicator** — `outline: none` applied globally with no replacement; keyboard users cannot see where they are
4. **Missing form labels** — inputs identified only by placeholder text; placeholder disappears when typing and is not read consistently by screen readers
5. **Insufficient color contrast** — text/background fails 4.5:1 minimum ratio; check in both light and dark modes
6. **Focus not managed in modals** — dialog opens but focus stays on trigger; focus not trapped; focus not returned on close
7. **Dynamic content not announced** — search results, status messages, or error states update the DOM but are not in a live region
8. **Inaccessible custom components** — custom dropdowns, date pickers, or tabs missing keyboard support and ARIA roles/states
