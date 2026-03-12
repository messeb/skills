---
description: CSS architecture — design tokens, utility-first with Tailwind, CSS Modules, scoped styles, avoiding specificity wars, and dark mode.
---

# CSS Architecture

## The Core Problem

CSS is globally scoped by default. Without architecture, every project degrades into:
- Specificity wars (`!important` everywhere)
- Dead code (nothing deleted because "it might break something")
- Unpredictable cascades (changing one style breaks another)

The solution: **predictable scope and a single source of truth for design values.**

---

## Design Tokens — Single Source of Truth

Design tokens encode design decisions (colors, spacing, typography) as named variables. They are the bridge between design tools and code.

```css
/* tokens.css — the design system foundation */
:root {
  /* Color palette (raw values) */
  --color-blue-50: #eff6ff;
  --color-blue-500: #3b82f6;
  --color-blue-900: #1e3a8a;
  --color-red-500: #ef4444;
  --color-neutral-0: #ffffff;
  --color-neutral-950: #0a0a0a;

  /* Semantic tokens (purpose-based, reference palette) */
  --color-primary: var(--color-blue-500);
  --color-primary-hover: var(--color-blue-600);
  --color-danger: var(--color-red-500);
  --color-background: var(--color-neutral-0);
  --color-surface: #f8fafc;
  --color-text: #0f172a;
  --color-text-muted: #64748b;
  --color-border: #e2e8f0;

  /* Spacing scale */
  --space-1: 0.25rem;   /* 4px */
  --space-2: 0.5rem;    /* 8px */
  --space-3: 0.75rem;   /* 12px */
  --space-4: 1rem;      /* 16px */
  --space-6: 1.5rem;    /* 24px */
  --space-8: 2rem;      /* 32px */
  --space-12: 3rem;     /* 48px */

  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
  --text-xl: 1.25rem;
  --text-2xl: 1.5rem;
  --leading-tight: 1.25;
  --leading-normal: 1.5;

  /* Radius */
  --radius-sm: 0.25rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);

  /* Transitions */
  --duration-fast: 150ms;
  --duration-normal: 250ms;
  --easing-default: cubic-bezier(0.4, 0, 0.2, 1);
}
```

---

## Option A: Tailwind CSS (Utility-First)

Best for: teams that want fast iteration, design-system alignment, and predictable CSS output.

### Configuration

```ts
// tailwind.config.ts
import type { Config } from 'tailwindcss'

export default {
  content: ['./src/**/*.{vue,ts,tsx,html}'],
  theme: {
    extend: {
      colors: {
        primary: {
          50: 'var(--color-blue-50)',
          500: 'var(--color-blue-500)',
          900: 'var(--color-blue-900)',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
} satisfies Config
```

### Component patterns with Tailwind

```vue
<!-- Extract repeated class combinations into components, not @apply -->
<script setup lang="ts">
interface Props {
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
})

const variantClasses = {
  primary: 'bg-blue-600 text-white hover:bg-blue-700 focus-visible:ring-blue-500',
  secondary: 'bg-white text-gray-900 border border-gray-300 hover:bg-gray-50',
  danger: 'bg-red-600 text-white hover:bg-red-700 focus-visible:ring-red-500',
  ghost: 'text-gray-600 hover:bg-gray-100 hover:text-gray-900',
}

const sizeClasses = {
  sm: 'px-3 py-1.5 text-sm',
  md: 'px-4 py-2 text-base',
  lg: 'px-6 py-3 text-lg',
}
</script>

<template>
  <button
    :class="[
      'inline-flex items-center gap-2 rounded-md font-medium transition-colors',
      'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2',
      'disabled:pointer-events-none disabled:opacity-50',
      variantClasses[variant],
      sizeClasses[size],
    ]"
  >
    <slot />
  </button>
</template>
```

### `@apply` — use with restraint

```css
/* Good: extracting a complex utility combination used in many places */
.prose-link {
  @apply text-blue-600 underline decoration-2 underline-offset-2
         hover:text-blue-800 hover:decoration-blue-800;
}

/* Bad: @apply just to avoid writing Tailwind classes in HTML */
.btn {
  @apply px-4 py-2 bg-blue-500 text-white rounded;  /* just write it inline */
}
```

---

## Option B: CSS Modules

Best for: teams that prefer scoped vanilla CSS with local class names.

```vue
<!-- Vue: scoped styles (native CSS Modules equivalent) -->
<style module>
.button {
  display: inline-flex;
  align-items: center;
  padding: var(--space-2) var(--space-4);
  background: var(--color-primary);
  color: white;
  border-radius: var(--radius-md);
  font-weight: 500;
  transition: background var(--duration-fast) var(--easing-default);
}

.button:hover { background: var(--color-primary-hover); }
.button:disabled { opacity: 0.5; pointer-events: none; }

.button--danger { background: var(--color-danger); }
.button--sm { padding: var(--space-1) var(--space-3); font-size: var(--text-sm); }
</style>

<script setup lang="ts">
const { button } = useCssModule()
// Classes are locally scoped: .button → ._button_abc12_1
</script>
```

```tsx
// React: CSS Modules
import styles from './Button.module.css'

function Button({ variant = 'primary', ...props }) {
  return (
    <button
      className={`${styles.button} ${styles[`button--${variant}`] ?? ''}`}
      {...props}
    />
  )
}
```

---

## Vue Scoped Styles

```vue
<style scoped>
/* :deep() for child components */
.card :deep(.badge) {
  margin-left: 0.5rem;
}

/* :slotted() for slot content */
.card :slotted(p) {
  margin: 0;
  color: var(--color-text-muted);
}

/* :global() for intentional global overrides */
:global(.tippy-box) {
  background: var(--color-neutral-950);
}
</style>
```

---

## Dark Mode

### System preference with class override

```css
/* tokens.css */
:root {
  --color-background: #ffffff;
  --color-surface: #f8fafc;
  --color-text: #0f172a;
  --color-border: #e2e8f0;
}

/* System dark preference */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme='light']) {
    --color-background: #0f172a;
    --color-surface: #1e293b;
    --color-text: #f1f5f9;
    --color-border: #334155;
  }
}

/* Manual dark theme override */
[data-theme='dark'] {
  --color-background: #0f172a;
  --color-surface: #1e293b;
  --color-text: #f1f5f9;
  --color-border: #334155;
}
```

```ts
// composables/useTheme.ts
const THEME_KEY = 'preferred-theme'

export function useTheme() {
  const theme = ref<'light' | 'dark' | 'system'>(
    (localStorage.getItem(THEME_KEY) as 'light' | 'dark' | 'system') ?? 'system'
  )

  watch(theme, (value) => {
    localStorage.setItem(THEME_KEY, value)
    document.documentElement.setAttribute('data-theme', value === 'system' ? '' : value)
  }, { immediate: true })

  return { theme }
}
```

### Tailwind dark mode

```ts
// tailwind.config.ts
export default {
  darkMode: ['class', '[data-theme="dark"]'],
}
```

```html
<div class="bg-white dark:bg-slate-900 text-gray-900 dark:text-gray-100">
```

---

## Specificity Management

### Specificity hierarchy (lowest to highest)

```
0-0-0: * { }
0-0-1: h1 { }, .foo h1 { } (element)
0-1-0: .foo { } (class)
1-0-0: #foo { } (id — avoid in CSS)
```

Rules:
- Never use `#id` selectors in component CSS
- Never use `!important` except for utility classes by design
- Prefer class selectors; use element selectors only for global resets
- CSS Modules / scoped styles eliminate the problem entirely

---

## Global Styles Structure

```
src/assets/styles/
├── tokens.css           # Design tokens (CSS custom properties)
├── reset.css            # Modern CSS reset
├── typography.css       # Global type styles (h1-h6, p, a, code)
├── utilities.css        # Low-level utility classes
└── index.css            # Imports everything above
```

---

## Audit Checklist

1. **Hardcoded color values** — `color: #3b82f6` or `background: rgba(0,0,0,0.8)` scattered through component files; all values should reference design tokens
2. **Specificity wars** — `!important` appearing in component styles, or overly specific selectors like `.page .container .section .card button`; indicates missing scoping strategy
3. **Dark mode with hardcoded colors** — component has explicit dark styles but uses hardcoded values instead of semantic tokens; adding a theme variant requires touching every component
4. **`@apply` everything** — every Tailwind utility extracted with `@apply`; loses the benefit of utility-first and creates large generated CSS
5. **Global side-effecting styles in components** — `<style>` without `scoped` or CSS Modules; styles leak to other components and cause unpredictable behavior
6. **No design token layer** — components reference palette tokens (`--color-blue-500`) directly instead of semantic tokens (`--color-primary`); rebrand requires touching every component
7. **Unused CSS** — components removed from codebase but their CSS files remain; no purge/content configuration in Tailwind or PostCSS
8. **Missing `:focus-visible` styles** — `outline: none` without a replacement; keyboard users have no visible focus indicator
