---
description: Frontend performance — Core Web Vitals, bundle analysis, lazy loading, rendering optimization, image optimization, and profiling.
---

# Frontend Performance

## Core Web Vitals (The Metrics That Matter)

Google's user experience metrics that affect search ranking and real user perception:

| Metric | Good | Needs Work | Poor | What it measures |
|--------|------|------------|------|-----------------|
| **LCP** Largest Contentful Paint | ≤2.5s | ≤4s | >4s | Loading speed |
| **INP** Interaction to Next Paint | ≤200ms | ≤500ms | >500ms | Responsiveness |
| **CLS** Cumulative Layout Shift | ≤0.1 | ≤0.25 | >0.25 | Visual stability |

**FCP** (First Contentful Paint) and **TTFB** (Time to First Byte) are supporting metrics.

---

## Measuring Performance

### Real User Monitoring

```ts
// Report Core Web Vitals
import { onCLS, onINP, onLCP, onFCP, onTTFB } from 'web-vitals'

function sendToAnalytics({ name, value, rating, id }: Metric) {
  window.gtag('event', name, {
    value: Math.round(name === 'CLS' ? value * 1000 : value),
    event_category: 'Web Vitals',
    event_label: id,
    non_interaction: true,
    metric_rating: rating,
  })
}

onCLS(sendToAnalytics)
onINP(sendToAnalytics)
onLCP(sendToAnalytics)
onFCP(sendToAnalytics)
onTTFB(sendToAnalytics)
```

### Profiling in Chrome DevTools

1. **Performance tab**: record a page load; find Long Tasks (>50ms), Layout Shifts, LCP element
2. **Network tab**: waterfall view; identify render-blocking resources, slow API calls
3. **Coverage tab**: find unused JS/CSS in the initial bundle
4. **Lighthouse**: overall score with specific recommendations

### Bundle analysis

```bash
# Vite
ANALYZE=true vite build  # with rollup-plugin-visualizer

# Next.js
ANALYZE=true next build  # with @next/bundle-analyzer
```

---

## Bundle Size Optimization

### Code splitting — never load what you don't need

```ts
// Vue: async components
const AdminPanel = defineAsyncComponent(() => import('./AdminPanel.vue'))
const RichTextEditor = defineAsyncComponent(() => import('./RichTextEditor.vue'))
const MapView = defineAsyncComponent(() => import('./MapView.vue'))

// React: lazy + Suspense
const AdminPanel = lazy(() => import('./AdminPanel'))
const Chart = lazy(() => import('./ChartComponent'))
```

### Route-level splitting

```ts
// Vue Router
const routes = [
  { path: '/', component: () => import('./pages/Home.vue') },
  { path: '/dashboard', component: () => import('./pages/Dashboard.vue') },
  { path: '/admin', component: () => import('./pages/Admin.vue') },
]
```

### Tree-shake lodash properly

```ts
// Bad: imports entire library (70kb+)
import _ from 'lodash'
_.debounce(fn, 300)

// Bad: still bundles everything with lodash
import { debounce } from 'lodash'

// Good: import specific function (~2kb)
import debounce from 'lodash-es/debounce'

// Best: use native or VueUse alternatives
import { useDebounceFn } from '@vueuse/core'
```

### Analyze and eliminate large deps

```ts
// Common culprits and alternatives
moment (330kb)        → date-fns (tree-shakable, ~5-20kb per function)
axios (40kb)          → native fetch (0kb) or ky (5kb)
lodash (70kb)         → lodash-es (tree-shakable) or native array methods
numeral (15kb)        → Intl.NumberFormat (built-in)
validator (60kb)      → zod (13kb) or manual validation
```

---

## Loading Performance

### Preload critical resources

```html
<!-- Preload the hero image (LCP candidate) -->
<link rel="preload" as="image" href="/images/hero.webp" fetchpriority="high" />

<!-- Preload critical fonts -->
<link rel="preload" as="font" href="/fonts/inter.woff2" type="font/woff2" crossorigin />

<!-- Prefetch next-page likely resources -->
<link rel="prefetch" href="/js/dashboard.chunk.js" />
```

### Resource hints

```html
<!-- Connect early to third-party origins -->
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="dns-prefetch" href="https://api.example.com" />
```

### Script loading strategy

```html
<!-- Never block rendering -->
<script src="analytics.js" defer></script>
<script src="chat-widget.js" async></script>

<!-- Critical inline scripts (tiny) don't need defer -->
<script>window.__INITIAL_STATE__ = {{ serializedState }}</script>
```

---

## Image Optimization

Images account for ~50% of bytes on the average page.

### Modern formats

```html
<!-- WebP with JPEG fallback -->
<picture>
  <source type="image/avif" srcset="/img/hero.avif" />
  <source type="image/webp" srcset="/img/hero.webp" />
  <img src="/img/hero.jpg" alt="Hero image" width="1200" height="630" loading="eager" fetchpriority="high" />
</picture>
```

### Responsive images

```html
<!-- Browser picks the right size -->
<img
  srcset="/img/product-300.webp 300w, /img/product-600.webp 600w, /img/product-1200.webp 1200w"
  sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 400px"
  src="/img/product-600.webp"
  alt="Product"
  width="600"
  height="400"
  loading="lazy"
/>
```

### Always set `width` and `height`

Setting explicit dimensions prevents Cumulative Layout Shift (CLS):

```html
<!-- Bad: no dimensions → layout shift as image loads -->
<img src="photo.jpg" alt="..." />

<!-- Good: browser reserves space before image loads -->
<img src="photo.jpg" alt="..." width="800" height="600" />
```

### Lazy loading

```html
<!-- Lazy-load images below the fold -->
<img src="product.jpg" alt="..." loading="lazy" decoding="async" />

<!-- Never lazy-load the LCP image -->
<img src="hero.jpg" alt="..." loading="eager" fetchpriority="high" />
```

---

## Rendering Performance

### Avoid Layout Thrashing

```ts
// Bad: interleaves reads and writes, causes multiple reflows
function badAnimation() {
  elements.forEach(el => {
    const height = el.offsetHeight  // read (forces layout)
    el.style.height = `${height + 10}px`  // write (invalidates layout)
  })
}

// Good: batch reads, then writes
function goodAnimation() {
  const heights = elements.map(el => el.offsetHeight)  // all reads
  elements.forEach((el, i) => {
    el.style.height = `${heights[i] + 10}px`           // all writes
  })
}
```

### Use CSS for animations, not JS

```css
/* Bad: JS animation changes layout-affecting properties */
/* element.style.left = ... */

/* Good: GPU-composited properties only */
.animate {
  transform: translateX(100px);
  opacity: 0;
  transition: transform 0.3s ease, opacity 0.3s ease;
  will-change: transform, opacity;  /* hint browser to create GPU layer */
}

/* will-change is not free — only on elements that actually animate */
```

### Virtualize long lists

Don't render 10,000 DOM nodes. Render only what's visible.

```ts
// Vue: vue-virtual-scroller
import { RecycleScroller } from 'vue-virtual-scroller'
import 'vue-virtual-scroller/dist/vue-virtual-scroller.css'

// React: TanStack Virtual
import { useVirtualizer } from '@tanstack/react-virtual'

const virtualizer = useVirtualizer({
  count: items.length,
  getScrollElement: () => parentRef.current,
  estimateSize: () => 50,
})
```

### Vue-specific: `v-memo` for expensive list items

```html
<!-- Only re-render when name or isSelected changes -->
<div
  v-for="item in list"
  :key="item.id"
  v-memo="[item.name, item.isSelected]"
>
  <ExpensiveComponent :item="item" />
</div>
```

### React-specific: `memo`, `useMemo`, `useCallback`

```tsx
// Memoize component (only re-render if props change)
const ProductCard = memo(function ProductCard({ product, onSelect }: Props) {
  return <div>...</div>
}, (prev, next) => prev.product.id === next.product.id && prev.onSelect === next.onSelect)

// Memoize expensive computations
const sortedItems = useMemo(
  () => items.slice().sort((a, b) => a.name.localeCompare(b.name)),
  [items]
)

// Stable callback reference (avoid re-renders of memoized children)
const handleSelect = useCallback((id: string) => {
  setSelectedId(id)
}, [])
```

---

## Font Performance

```css
/* Prevent invisible text during font load */
@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter.woff2') format('woff2');
  font-display: swap;     /* show fallback immediately, swap when ready */
  font-weight: 100 900;   /* variable font: one file for all weights */
}

/* Size-adjust to reduce layout shift when swapping fonts */
@font-face {
  font-family: 'Inter Fallback';
  src: local('Arial');
  size-adjust: 107%;      /* match Inter's metrics */
}
```

---

## Audit Checklist

1. **LCP image loaded lazily** — hero/banner image has `loading="lazy"`; it delays the most important paint by 500-1000ms; use `loading="eager"` with `fetchpriority="high"`
2. **No explicit image dimensions** — images without `width`/`height` cause CLS as they load; always declare both attributes
3. **Synchronous third-party scripts** — analytics, chat widgets, or A/B testing scripts without `defer`/`async` block parsing and delay FCP
4. **Single giant bundle** — entire app in one JS file; no route splitting; 500kb+ initial download for a landing page
5. **Lodash/moment not tree-shaken** — `import _ from 'lodash'` includes 70kb of utilities the app barely uses
6. **Unvirtualized long lists** — rendering 500+ items as full DOM nodes; UI freezes on scroll and filter operations
7. **Missing `will-change` on animated elements** — animations that skip GPU compositing; causes jank on low-end devices
8. **No performance budget** — team has no Lighthouse score targets or bundle size limits; regressions are not caught in CI
