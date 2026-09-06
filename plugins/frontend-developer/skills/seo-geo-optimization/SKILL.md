---
description: Implementing SEO and GEO in a component-based frontend — choosing a rendering strategy that keeps content crawlable, hydration and islands policy, producing head tags and JSON-LD from components, protecting LCP/CLS/INP at the component level, asset and third-party discipline, and gating pull requests with Lighthouse CI. Complements the `seo` plugin, which owns the canonical tag, schema, and crawl rules.
---

# SEO and GEO in a frontend codebase

Goal of this skill: make the **frontend implementation decisions** that determine whether a page can be crawled, quoted by an AI engine, and pass a Lighthouse gate — rendering mode, hydration boundaries, where head tags and structured data come from, and which component patterns quietly destroy Core Web Vitals.

Use this skill when building or auditing an Astro, Nuxt, or Vue application whose pages must rank and be cited, when a site is losing traffic after a framework migration, or when Lighthouse SEO and performance scores are below target and nobody knows which component is responsible.

**Scope boundary.** This skill covers the *implementation* in a component framework. The canonical rules for what those artifacts must contain live in the `seo` plugin:

| Topic | Owned by |
|-------|----------|
| `<head>` tag content, Open Graph, canonical, hreflang | `seo:meta-tags` |
| JSON-LD entity shapes and rich-result eligibility | `seo:structured-data-jsonld` |
| Semantic body structure and heading hierarchy | `seo:seo-page-structure` |
| Article shape for generative engines, E-E-A-T | `seo:geo-content` |
| `robots.txt`, sitemaps, AI-crawler policy | `seo:crawl-control` |
| Core Web Vitals thresholds and budgets | `seo:core-web-vitals` |
| Image formats, `srcset`, OG image specs | `seo:image-optimization` |
| Resource hints and Speculation Rules | `seo:resource-hints` |
| Analytics, tag managers, consent gating | `seo:third-party-scripts` |
| URLs, redirects, internal linking | `seo:url-structure`, `seo:internal-linking` |

Within this plugin, `frontend-developer:performance` owns bundle size and rendering optimisation generally, and `frontend-developer:a11y-testing` owns accessibility testing. This skill covers only where those intersect with being found and quoted.

---

## 1. Rendering strategy decides crawlability

The single highest-impact decision. Traditional crawlers execute JavaScript with a delay and a budget; most AI crawlers **do not execute it at all**. Content that exists only after hydration is invisible to them.

| Content | Required rendering | Why |
|---------|--------------------|-----|
| Article body, headings, lead paragraph | Static HTML (SSG or SSR) | Must be in the initial response for both crawlers and LLM ingestion |
| Title, meta description, canonical, JSON-LD | Static HTML | Client-injected head tags are unreliable for AI crawlers and social unfurlers |
| Navigation and internal links | Real `<a href>` in the initial HTML | Router-only navigation is not a discoverable link graph |
| Breadcrumbs, related links, tags | Static HTML | Cheap, and they carry the link graph |
| Pagination and list pages | Server-rendered or prerendered per page | Infinite scroll alone hides everything past page one |
| Search, filters, favourites | Client island | Genuinely interactive, not indexable content |
| Personalised or authenticated content | Client, and excluded from indexing | Not a public document |

Framework rules:

- **Astro** — static by default; add `client:*` only to genuinely interactive components.
- **Nuxt** — prerender content routes (`routeRules: { '/blog/**': { prerender: true } }`); reserve `ssr: false` for authenticated app shells. Never ship an SPA fallback for indexable routes.
- **Vue SPA without SSR** — accept that content pages will underperform, or move them to prerendered routes. "Google can render JavaScript" is not an answer for Perplexity, ChatGPT, or a Slack unfurl.

**Verification, not belief**: check what the server actually returns.

```bash
# Does the content exist without JavaScript?
curl -s "$URL" | grep -c "the phrase you expect in the article body"

# Are the head tags server-rendered?
curl -s "$URL" | grep -E '<title>|rel="canonical"|application/ld\+json'

# Are internal links real anchors in the initial HTML?
curl -s "$URL" | grep -oE '<a [^>]*href="[^"]+"' | head -20
```

---

## 2. Hydration and islands policy

Every hydrated component costs bytes, main-thread time, and INP. Decide per component, not per page.

| Component | Hydration |
|-----------|-----------|
| Header, footer, navigation | None — plain HTML and CSS |
| Article body, breadcrumbs, tag lists, related links | None |
| FAQ / disclosure | Native `<details>` — no JavaScript |
| Tabs, accordions | CSS or `<details>` first; hydrate only if genuinely dynamic |
| Share buttons | On idle, or on interaction — never on load |
| Search box, filters | Small island, on load or on visible |
| Save / favourite | Island, on interaction |
| Analytics and consent | Deferred, after consent, off the critical path |

```astro
<!-- Good: targeted islands -->
<SearchBox client:load />
<RelatedItems client:visible />
<ShareButtons client:idle />

<!-- Bad: hydrates the whole document -->
<Page client:load />
```

Rules:

- No page-wide client app for static content.
- Never render the article body on the client.
- Split search, favourites, and sharing into separate islands so one interactive feature does not drag in the rest.
- Do not ship development helpers, console logging, or debug libraries to production.
- Run a bundle analysis before optimising anything else — unused JavaScript is usually the largest single win.

---

## 3. LCP at the component level

The LCP element is normally the hero image or the H1 block. It must be discoverable in the initial HTML and prioritised.

```html
<picture>
  <source srcset="/images/hero.avif" type="image/avif" />
  <source srcset="/images/hero.webp" type="image/webp" />
  <img
    src="/images/hero.jpg"
    width="1200"
    height="630"
    alt="Descriptive alt text for the hero image"
    loading="eager"
    decoding="async"
    fetchpriority="high"
  />
</picture>
```

| Rule | Reason |
|------|--------|
| Never lazy-load the LCP image | Delays the metric by a full round trip |
| Always set intrinsic `width` and `height` | Prevents layout shift |
| `fetchpriority="high"` on the LCP image only | Priority is zero-sum |
| Modern format with a fallback | Fewer bytes on the critical path |
| No CSS background images for meaningful content | Not discoverable by the preload scanner, and not indexable |
| Preload **only** if the image is discovered late | An unnecessary preload steals bandwidth from something else |

If the LCP element is text: avoid render-blocking web fonts, use `font-display: swap`, preload at most one critical font file, never animate the H1 into view, and never render the H1 on the client.

```html
<!-- Bad: the LCP element starts invisible -->
<h1 class="opacity-0 animate-in-later">Page title</h1>

<!-- Good -->
<h1>Page title</h1>
```

> **Correction worth stating explicitly**: `preconnect` is a connection hint, **not** HTTP/2 Server Push. Chrome disabled HTTP/2 Server Push by default in Chrome 106; do not design around it. Use `preload`, `preconnect`, `fetchpriority`, and better asset discovery instead. See `seo:resource-hints`.

---

## 4. CLS in components

Every block must reserve its final space before its content arrives.

- Intrinsic `width`/`height` on every image; `aspect-ratio` on media containers and cards.
- Reserve space for embeds, ads, cookie banners, and any widget injected after load.
- Never insert a banner above existing content after the page has painted.
- No sticky bars that push content down once they appear.
- Skeletons must match the final layout's dimensions, not merely occupy "some" space.
- Animate `transform` and `opacity` only; both are off the layout path.
- Honour `prefers-reduced-motion`.

```css
.card__media {
  aspect-ratio: 1200 / 630;
}

@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

---

## 5. INP in event handlers

INP is the responsiveness Core Web Vital. Keep handlers short and off the critical path.

```js
// Bad: tracking and a large DOM update block the interaction
button.addEventListener('click', () => {
  expensiveTracking();
  hugeDomUpdate();
  navigate();
});

// Better: do the user's work first, defer the rest
button.addEventListener('click', () => {
  navigate();
  requestIdleCallback(() => trackInteraction());
});
```

- Debounce expensive work in search and filter inputs.
- Filtering must not re-render the whole page — scope reactivity to the list.
- Do not render huge client-side lists on category pages; use server-rendered pagination or prerendered pages.
- Never block navigation on an analytics call.
- Break long tasks into chunks; yield to the main thread between them.

---

## 6. Head tags and structured data from components

These artifacts must be **server-rendered**, produced from one source, and validated in CI.

| Framework | Mechanism |
|-----------|-----------|
| Astro | A single `<BaseHead>` component taking typed props; JSON-LD as a `<script type="application/ld+json" set:html={...}>` in the layout |
| Nuxt | `useSeoMeta()` / `useHead()` in the page or a composable; `useSchemaOrg()` or a rendered JSON-LD script — during SSR, not `onMounted` |
| Vue SPA | Only viable with SSR or prerendering; otherwise head tags reach neither AI crawlers nor unfurlers |

Implementation rules:

- **One source of truth per page.** Title, description, canonical, OG image, and JSON-LD derive from the same page data object — never typed twice.
- **No head mutation in `onMounted`** or any client-only lifecycle hook.
- **JSON-LD must match the visible content.** A mismatch between markup and page text is a manual-action risk, and the two diverge the moment they have separate sources.
- **Escape user-supplied values** before embedding them into a JSON-LD script block.
- **Type the props** so a page cannot be published without a title or a canonical.
- Content collections (Astro) or typed content queries (Nuxt) should carry the SEO fields in their schema, so a missing description is a build error rather than a silent gap.

See `seo:meta-tags` and `seo:structured-data-jsonld` for what these tags must contain.

---

## 7. Assets, CSS, and third parties

- Configure Tailwind's `content` globs correctly; verify the shipped CSS size rather than assuming purging worked.
- Do not import whole icon libraries for a handful of icons.
- Self-host fonts; subset them; preload at most one.
- Inline only genuinely critical above-the-fold CSS; defer the rest.
- No third-party script in `<head>` unless it is legally or functionally required.
- Load analytics, pixels, heatmaps, and A/B tooling after consent and on idle.
- Use static share links instead of embedded social SDKs.
- Never load external analytics in development, preview, or test environments.

```js
if (import.meta.env.PROD && hasAnalyticsConsent()) {
  requestIdleCallback(() => loadAnalytics());
}
```

Details and per-page-type budgets: `seo:third-party-scripts`, `seo:core-web-vitals`.

---

## 8. Lighthouse CI as a pull-request gate

Audit **production builds only** — never a dev server, whose unbundled modules and HMR client make the numbers meaningless. Use at least three runs and take the median.

```js
// lighthouserc.cjs
module.exports = {
  ci: {
    collect: {
      staticDistDir: './dist',
      numberOfRuns: 3,
      url: ['/', '/category/example', '/article/example', '/search', '/404'],
      settings: { preset: 'desktop' },
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
      },
    },
    upload: { target: 'temporary-public-storage' },
  },
};
```

Run Lighthouse CI on every pull request that touches templates, layouts, CSS, images, scripts, or SEO components. Audit one URL per **page type** — home, category, detail, search, 404 — not one representative page.

Additional CI checks worth automating alongside it, because Lighthouse does not catch them:

- JSON-LD parses and validates against the expected type.
- Canonical is present, absolute, and self-referencing on canonical pages.
- Exactly one `<h1>` per page.
- No accidental `noindex` on an indexable route.
- The 404 route returns HTTP 404, not 200.
- Content phrases are present in the raw HTML response (the crawlability check from §1).

Lighthouse CI is the pull-request gate; PageSpeed Insights is the production monitor, because it adds Chrome UX Report field data. Do not expect field data to move immediately after a release — it reflects real users over a trailing window.

---

## 9. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Hydrating the whole page when only search or sharing is interactive | Large bundle, poor INP and TBT, no benefit |
| Article body rendered on the client | Invisible to AI crawlers; delayed indexing |
| Head tags or JSON-LD set in `onMounted` | Missing for AI crawlers and social unfurlers |
| Router-only navigation with no real `<a href>` | The internal link graph does not exist for crawlers |
| Infinite scroll as the only path to older content | Everything past the first page is undiscoverable |
| Lazy-loading the LCP image | Guaranteed LCP regression |
| Missing `width`/`height` on images | Guaranteed CLS |
| Animating the hero or H1 into view | The LCP element starts invisible |
| CSS background images for meaningful content | Invisible to the preload scanner and to image search |
| Injecting banners above content after load | Large layout shift at the worst moment |
| Analytics, pixels, or heatmaps in the critical path | The cheapest way to lose performance points |
| Blocking navigation until tracking completes | Direct INP damage |
| JSON-LD that contradicts the visible page | Rich-result loss, manual-action risk |
| Duplicating title and description in two places | They diverge, and the wrong one ships |
| Whole icon library imported for three icons | Dead weight on every page |
| Lighthouse run against the dev server | Numbers that mean nothing |
| Auditing one page and assuming the rest match | Page types fail independently |

---

## 10. Audit checklist

### Crawlability

- [ ] Article body, headings, and lead paragraph present in the raw HTML response
- [ ] Title, description, canonical, and JSON-LD server-rendered
- [ ] Internal links are real anchors in the initial HTML
- [ ] Paginated content reachable without JavaScript
- [ ] 404 route returns HTTP 404; no indexable route returns an SPA fallback

### Hydration

- [ ] Hydration decided per component, not per page
- [ ] No client rendering of indexable content
- [ ] FAQ, breadcrumbs, tags, and related links ship without JavaScript
- [ ] Bundle analysis run; unused JavaScript removed

### Core Web Vitals

- [ ] LCP element identified per page type
- [ ] LCP image eager, prioritised, and correctly sized; not a CSS background
- [ ] All images carry intrinsic dimensions; media containers use `aspect-ratio`
- [ ] Nothing is injected above existing content after load
- [ ] Input handlers do only the user's work synchronously
- [ ] `prefers-reduced-motion` honoured

### Head and structured data

- [ ] One typed source of truth per page for title, description, canonical, OG image, JSON-LD
- [ ] JSON-LD validates and matches the visible content
- [ ] User-supplied values escaped before embedding
- [ ] Missing SEO fields fail the build rather than shipping silently

### Assets and third parties

- [ ] Shipped CSS size verified, not assumed
- [ ] Fonts self-hosted and subset; at most one preloaded
- [ ] No third-party script in `<head>` without justification
- [ ] Analytics deferred, consent-gated, and disabled outside production

### CI

- [ ] Lighthouse CI runs on production builds, three runs, median compared
- [ ] One URL per page type audited
- [ ] SEO category asserted at 100; accessibility and best practices at 95+
- [ ] JSON-LD, canonical, single-H1, and no-`noindex` checks automated
- [ ] PageSpeed Insights used for post-release field monitoring
