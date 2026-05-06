---
description: Core Web Vitals from an SEO ranking perspective — LCP, INP, CLS field thresholds, performance budgets per page type, Lighthouse target scores, Lighthouse CI configuration with assertions, PageSpeed Insights workflow, lab vs field data, the shipping checklist that gates a page from going live, and the anti-patterns that fail Web Vitals at the 75th percentile.
---

# Core Web Vitals — the SEO performance gate

Core Web Vitals are part of Google's page-experience ranking signals. A page that fails CWV at the 75th percentile loses ranking against equivalent competitors, regardless of meta tags, structured data, or content quality. This skill is the **SEO-side gate**: the budgets, thresholds, CI checks, and shipping checklist that decide whether a page is allowed to ship.

This skill focuses on **measurement, budgets, and gating**. For tactical fixes per topic, see the specialist skills:

- **`image-optimization`** — LCP image markup, format choice, `fetchpriority`, CLS dimensions, OG images.
- **`resource-hints`** — `preconnect`, `preload`, font preloading, `fetchpriority` on link tags.
- **`third-party-scripts`** — analytics/pixels/chat widgets without wrecking INP.

For deeper engineering fixes (bundle splitting, virtualized lists, hydration architecture), defer to the host project's frontend skills.

---

## 1. The three Core Web Vitals

| Metric | Measures | Good (75th %ile) | Needs improvement | Poor |
|--------|----------|------------------|-------------------|------|
| **LCP** — Largest Contentful Paint | Time to render the largest visible element | ≤ 2.5 s | 2.5 – 4.0 s | > 4.0 s |
| **INP** — Interaction to Next Paint | Page's responsiveness to user input across the visit | ≤ 200 ms | 200 – 500 ms | > 500 ms |
| **CLS** — Cumulative Layout Shift | Sum of unexpected layout shifts during the visit | ≤ 0.1 | 0.1 – 0.25 | > 0.25 |

### Field vs lab

- **Field data** (CrUX — Chrome User Experience Report) is what Google actually ranks on. Aggregates real user sessions over the trailing 28 days at the 75th percentile.
- **Lab data** (Lighthouse, WebPageTest) is a synthetic single-run snapshot used for development and CI. Lab and field can disagree — fix lab regressions to prevent field regressions, but use field data for go/no-go decisions on ranking impact.

### Mobile first

Google's CWV ranking signal evaluates mobile separately from desktop. **Optimize for mobile**. A site that passes on desktop but fails on mobile loses ranking; the reverse rarely matters.

---

## 2. Lighthouse target scores

Run Lighthouse against production builds, not dev. Three runs, take the median.

| Category | Minimum | Target |
|----------|---------|--------|
| Performance | 90 | 95+ |
| Accessibility | 95 | 100 |
| Best Practices | 95 | 100 |
| SEO | 100 | 100 |

Performance fluctuates between runs by 5–10 points. Use the median of three runs. A single bad run is not a regression.

---

## 3. Performance budgets

Budgets are project guardrails, not Google rules. They keep field metrics from creeping over time.

### Page-weight budgets (per page, gzipped/brotli)

| Asset | Content site | App / commerce |
|-------|--------------|-----------------|
| Initial JS | ≤ 120 KB | ≤ 200 KB |
| Initial CSS | ≤ 80 KB | ≤ 120 KB |
| HTML document | ≤ 70 KB | ≤ 100 KB |
| Hero image | ≤ 200 KB | ≤ 250 KB |
| Total above-the-fold image weight | ≤ 300 KB | ≤ 400 KB |
| Third-party scripts in critical path | 0 | 0 |

### Lab metric budgets

| Metric | Budget |
|--------|--------|
| LCP (mobile, 4G) | ≤ 2.5 s |
| TBT (Total Blocking Time) | ≤ 150 ms |
| CLS | ≤ 0.1 |
| Speed Index | ≤ 3.4 s |

### Page-type budgets

Different page types have different reasonable weights. Document budgets per route:

| Route | JS | CSS | Image (above fold) |
|-------|----|----|-------------------|
| Home | 120 KB | 80 KB | 300 KB |
| Article / blog post | 100 KB | 60 KB | 250 KB |
| Category / archive | 120 KB | 80 KB | 200 KB |
| Product detail | 180 KB | 100 KB | 350 KB |
| Search results | 100 KB | 60 KB | 100 KB |
| Checkout | 250 KB | 120 KB | 150 KB |

A PR that exceeds the budget must explain why in the description. A budget that is exceeded routinely is the wrong number — adjust it deliberately.

---

## 4. LCP — practical rules

The LCP element is usually the hero image, an H1 block, or a lead text element. Make it discoverable in the initial HTML and give it priority.

### Identify the LCP element

Open DevTools → Performance Insights → record reload → inspect the LCP marker. Or use the Web Vitals extension. Don't optimize blind — fixing the wrong element is wasted work.

### Hero image LCP

The non-negotiables for an LCP image:

- Never `loading="lazy"`.
- `fetchpriority="high"`.
- Intrinsic `width` and `height`.
- Modern format with fallback (AVIF / WebP / JPEG).
- Server-rendered as `<img>`, not a CSS `background-image`.
- Preload only when discovery is late (image referenced via JS or CSS).

For the full `<picture>` / `srcset` / `sizes` markup, format trade-offs, and compression targets, see the **`image-optimization`** skill. For `<link rel="preload">` patterns and font preloading, see **`resource-hints`**.

### Text-based LCP

If the H1 / lead paragraph is the LCP element:

- SSR it. Don't render the H1 client-side only.
- Don't animate the H1 into view (`opacity-0` → `opacity-1` delays LCP).
- Avoid blocking web fonts; use `font-display: swap`.
- Prefer system fonts for body text where possible.

For font preload + metric-override patterns, see **`resource-hints`** (font section).

---

## 5. INP — practical rules

INP measures responsiveness to user input across the lifetime of a visit. The slowest interaction (at the 98th percentile of interactions) is reported.

### Rules

- **Break up long tasks.** Anything over 50 ms blocks the main thread. Use `scheduler.yield()`, `setTimeout(0)`, or `requestIdleCallback()` to chunk work.
- **Debounce expensive input handlers.** Search inputs, filter changes, large lists.
- **Don't run analytics inside click handlers synchronously.** Defer.
- **Don't block navigation on tracking calls.**
- **Use `requestIdleCallback` for non-critical work.**
- **Avoid huge client-side rendered lists.** Server-render, paginate, or virtualize.
- **Don't re-render the whole page** when one filter changes.

### Bad

```js
button.addEventListener('click', () => {
  expensiveTracking();
  hugeDomUpdate();
  navigate();
});
```

### Good

```js
button.addEventListener('click', () => {
  navigate();
  requestIdleCallback(() => trackInteraction());
});
```

### Quick wins for INP regressions

- Remove unused JS (bundle analysis).
- Move analytics off the critical path.
- Replace global "click anywhere" listeners with scoped delegation.
- Replace synchronous large state updates with batched/transitioned ones (React `startTransition`, Vue `useTransition`).
- Defer non-essential work past the next paint.

---

## 6. CLS — practical rules

CLS is the sum of unexpected layout shifts during a page's lifetime. Every visual block must reserve its final space before its asset loads.

### Rules

- **Always set `width` and `height` on images and iframes.**
- **Use `aspect-ratio` on cards and media containers.**
- **Reserve space for ads, embeds, cookie banners, and dynamic widgets.**
- **Don't inject banners above the hero after page load.**
- **Don't swap fonts in a way that changes layout dramatically** — use fallback metric overrides (`size-adjust`, `ascent-override`).
- **Don't show sticky bars that push content down after load** — overlay them.
- **Skeletons and loaders must match the final element's dimensions.**

For full image dimension and `aspect-ratio` patterns see **`image-optimization`** (CLS section). For web-font metric-override and preload patterns see **`resource-hints`** (font section). For cookie banner / third-party widget CLS prevention see **`third-party-scripts`**.

---

## 7. Lighthouse CI

Every PR that changes templates, CSS, JS, images, or third-party integrations must run Lighthouse CI against representative pages.

### Install

```bash
pnpm add -D @lhci/cli
```

### `lighthouserc.cjs`

```js
module.exports = {
  ci: {
    collect: {
      staticDistDir: './dist',
      numberOfRuns: 3,
      url: [
        '/',
        '/category/performance',
        '/blog/inp-guide',
        '/search?q=inp',
        '/404'
      ],
      settings: {
        preset: 'desktop'
      }
    },
    assert: {
      assertions: {
        'categories:performance': ['warn', { minScore: 0.9 }],
        'categories:accessibility': ['error', { minScore: 0.95 }],
        'categories:best-practices': ['error', { minScore: 0.95 }],
        'categories:seo': ['error', { minScore: 1 }],
        'largest-contentful-paint': ['warn', { maxNumericValue: 2500 }],
        'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
        'total-blocking-time': ['warn', { maxNumericValue: 150 }],
        'unused-javascript': ['warn', { maxNumericValue: 30000 }],
        'render-blocking-resources': ['warn', { maxNumericValue: 0 }],
        'uses-responsive-images': 'warn',
        'modern-image-formats': 'warn',
        'efficient-animated-content': 'warn',
        'meta-description': 'error',
        'document-title': 'error',
        'canonical': 'error',
        'http-status-code': 'error'
      }
    },
    upload: {
      target: 'temporary-public-storage'
    }
  }
};
```

### Run locally

```bash
pnpm build
pnpm lhci autorun
```

### Run a second config for mobile

```js
// lighthouserc.mobile.cjs
module.exports = {
  ci: {
    collect: {
      ...,
      settings: { preset: 'mobile' }
    },
    assert: {
      assertions: {
        'categories:performance': ['warn', { minScore: 0.85 }],
        'largest-contentful-paint': ['warn', { maxNumericValue: 2500 }],
        ...
      }
    }
  }
};
```

Mobile budgets are softer than desktop — that is expected. The 75th-percentile field metric on mobile is what Google ranks on, but lab thresholds need slack to avoid CI flake.

### CI must fail on

- SEO score < 100
- Accessibility < 95
- Best Practices < 95
- Missing canonical
- Missing title
- Missing meta description
- Missing alt text
- Multiple H1s
- Accidental `noindex`
- Soft 404 (404 page returning HTTP 200)

---

## 8. PageSpeed Insights workflow

Use Lighthouse CI for PRs (lab data). Use PageSpeed Insights post-deploy and weekly for monitoring (combines lab diagnostics with field CrUX data).

### Post-deploy check

```bash
URL="https://example.com/blog/inp-guide"
KEY="$PSI_API_KEY"

curl -s "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=${URL}&strategy=mobile&category=performance&category=seo&category=accessibility&category=best-practices&key=${KEY}" \
  | jq '.loadingExperience.metrics, .lighthouseResult.categories'
```

### What to look at

- `loadingExperience.metrics` — **field** data (real users, last 28 days). This is what ranks.
- `lighthouseResult.categories` — **lab** data (synthetic single run). This is what CI gates on.

### When field and lab disagree

- Field worse than lab → real users hit slow networks, slow devices, or third-party scripts that don't load in lab. Investigate field-only signals (slow CPU, geo, ISP).
- Lab worse than field → the page hasn't been deployed long enough for field data to update, or the field 75th-percentile masks the worst pages. Check field data again in 28 days.

Field data updates with a delay. After a fix ships, expect 14–28 days before CrUX reflects it. Don't panic during the lag.

---

## 9. Web Vitals monitoring

Lab + PSI is not enough — instrument real users.

```html
<script type="module">
  import { onLCP, onINP, onCLS } from 'https://unpkg.com/web-vitals@4?module';

  function send(metric) {
    const body = JSON.stringify(metric);
    if (navigator.sendBeacon) {
      navigator.sendBeacon('/web-vitals', body);
    } else {
      fetch('/web-vitals', { method: 'POST', body, keepalive: true });
    }
  }

  onLCP(send);
  onINP(send);
  onCLS(send);
</script>
```

Send to a backend or analytics tool that supports the Web Vitals attribution build (which gives the offending element/script per metric). Watch the 75th percentile per page type.

---

## 10. Things that quietly fail Core Web Vitals

- ❌ Lazy-loading the LCP image (`loading="lazy"` on hero).
- ❌ Hero image as CSS `background-image` (no `fetchpriority`, late discovery).
- ❌ Web font `font-display: block` (text invisible until font loads → bad LCP).
- ❌ No `width`/`height` on images.
- ❌ Cookie banner / GDPR banner injected at the **top** of the page after load — guaranteed CLS.
- ❌ Sticky promo bar that pushes content down after load.
- ❌ Auto-rotating hero carousel with non-equal slide heights.
- ❌ Synchronous third-party scripts in `<head>` (analytics, A/B tests, chat widgets, fonts from a third-party CDN).
- ❌ Full-page client hydration (`client:load` everywhere) on a static content page.
- ❌ Heavy JS bundles that don't code-split per route.
- ❌ Long tasks in click handlers (analytics, large state updates) — INP killer.
- ❌ Re-rendering huge lists on every keystroke in a search box.
- ❌ Loading multiple competing analytics tools (Plausible + GA + Hotjar + Segment).
- ❌ Lighthouse run against `npm run dev` (dev mode HMR + uncompressed bundles).
- ❌ Lighthouse score from a single run treated as definitive.
- ❌ Optimizing desktop only and shipping mobile failures.
- ❌ Accepting "needs improvement" as good enough — Google ranks "good" higher than "needs improvement".
- ❌ Fixing lab without checking field data 28 days later.

---

## 11. Shipping checklist

Before a page type ships:

- [ ] Production build tested, not dev server.
- [ ] Lighthouse run on **mobile** and desktop (3 runs each, median taken).
- [ ] Performance ≥ 90 (target 95+) on both.
- [ ] Accessibility ≥ 95.
- [ ] Best Practices ≥ 95.
- [ ] SEO = 100.
- [ ] LCP element identified (Performance Insights or Web Vitals extension).
- [ ] LCP image/text visible in initial server-rendered HTML.
- [ ] Hero image is **not** `loading="lazy"`.
- [ ] Hero image has `fetchpriority="high"` when it is the LCP element.
- [ ] All images and iframes have `width` and `height`.
- [ ] No unexpected layout shift (record a session in DevTools, check CLS marker).
- [ ] No unnecessary hydration / `client:load` on static content.
- [ ] No console errors in production build.
- [ ] No render-blocking third-party scripts in `<head>`.
- [ ] Fonts use `font-display: swap` and metric overrides if web-font CLS shows up.
- [ ] Long tasks (> 50 ms) absent from initial load and primary interactions.
- [ ] Web Vitals monitoring fires on production for LCP, INP, CLS.
- [ ] PSI mobile run passes after deploy (or queued for 14-day field re-check).
- [ ] 404 returns HTTP 404, not 200.

Stop the ship if any item is red.

---

## 12. Validation tools and commands

```bash
# Local Lighthouse run
npx lighthouse https://example.com/blog/inp-guide \
  --only-categories=performance,accessibility,best-practices,seo \
  --preset=desktop \
  --view

npx lighthouse https://example.com/blog/inp-guide \
  --preset=perf \
  --form-factor=mobile \
  --view

# Lighthouse CI
pnpm build && pnpm lhci autorun

# PageSpeed Insights API (post-deploy / monitoring)
curl -s "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=${URL}&strategy=mobile&category=performance&category=seo&category=accessibility&category=best-practices" \
  | jq '.loadingExperience.metrics'

# Manual: confirm no lazy-loaded LCP image
curl -s "$URL" | grep -oP '<img[^>]+>' | grep -E 'loading="lazy".*fetchpriority="high"|fetchpriority="high".*loading="lazy"' \
  && echo "FAIL: image is both lazy and high priority"

# Manual: confirm images have dimensions
curl -s "$URL" | grep -oP '<img[^>]+>' | grep -v 'width=' \
  && echo "WARN: images without explicit width"

# Manual: check H1 SSR'd (Lighthouse SEO score 100 requires this)
curl -s "$URL" | grep -c '<h1'   # must be 1

# DevTools — Performance → Record reload → inspect Long Tasks (red bars > 50 ms)
# DevTools — Rendering → "Show Core Web Vitals overlay"
# DevTools — Lighthouse → Mobile + Performance
```

### Browser tools

- **Web Vitals extension** (Chrome) — live LCP/INP/CLS overlay during browsing.
- **Chrome DevTools → Performance Insights** — automated bottleneck detection per metric.
- **PageSpeed Insights** — combined lab + field, with diagnostics.
- **Search Console → Core Web Vitals report** — aggregate field data per page group, 28-day rolling.

---

## 13. Output format

When asked to **set up CWV gating** for a project, return:

1. A `lighthouserc.cjs` (and a mobile variant if requested) with assertions tuned to the project's page types.
2. Page-type budgets matching section 3.
3. CI workflow snippet that runs Lighthouse CI on PRs and blocks merges on assertion failure.
4. A web-vitals beacon snippet for production monitoring.
5. Open questions for any field that needs project input (URLs to test, mobile vs desktop priority, monitoring backend).

When asked to **audit** a page or site, return:

```text
# Core Web Vitals Audit — <URL>

## Field data (CrUX, last 28 days)
- LCP: <value> — <Good/Needs Improvement/Poor>
- INP: <value> — <…>
- CLS: <value> — <…>

## Lab data (Lighthouse, median of 3 runs)
- Performance: <score>
- LCP: <value>
- TBT: <value>
- CLS: <value>

## Findings
**[HIGH]** <element/file> — <issue> — <recommended fix>
**[MEDIUM]** ...
**[LOW]** ...

## Recommended fix order
1. ...
```

Then offer to apply each fix. Apply approved fixes one at a time, confirming each.
