---
description: Resource hints for the browser preloader — preconnect, dns-prefetch, preload, modulepreload, prefetch, fetchpriority, and Speculation Rules. When each hint helps Core Web Vitals (LCP especially), when it hurts, font-preload patterns, the deprecated HTTP/2 Server Push status, hint ordering, and a validation checklist for auditing existing pages.
---

# Resource hints — telling the browser what to fetch and when

Resource hints are `<link>` tags that influence the browser's fetch priority, connection setup, and discovery order. Used correctly they shave 200–800 ms off LCP. Used carelessly they waste bandwidth, downgrade competing requests, and trigger Lighthouse warnings.

This skill is about **knowing which hint to use, when, and how few of them to ship**. The single most common mistake: shotgun-preconnecting every third-party origin.

For LCP timing rules see `core-web-vitals`. For image-specific `fetchpriority` see `image-optimization`. This skill covers the head-tag hint mechanics.

---

## 1. The hint catalog

| Hint | Saves | Costs | Use for |
|------|-------|-------|---------|
| `dns-prefetch` | DNS lookup (~20–120 ms) | DNS query | Older fallback for third-party origins |
| `preconnect` | DNS + TCP + TLS (~100–500 ms) | One open connection | Critical third-party origins discovered late |
| `preload` | Late-discovery fetch latency | Bytes — fetched eagerly | Late-discovered LCP image, critical font, hero CSS |
| `modulepreload` | Same as preload, plus module-graph parsing | Bytes | ES module dependencies |
| `prefetch` | Future-navigation fetch latency | Bytes — low priority | Likely-next-page resources |
| `fetchpriority` | Re-prioritizes any fetch | None | LCP candidate, deprioritized assets |
| Speculation Rules | Full prerender of a future navigation | Bytes + memory | Strongly predicted next page |

Pick the **least-aggressive** hint that solves the measured problem. Each hint is a hint *and* a cost.

---

## 2. `dns-prefetch` — resolve a hostname early

Tells the browser to do a DNS lookup for an origin before the URL is referenced. Cheap; one query. Useful only when you don't need a full connection (the resource won't be fetched immediately).

```html
<link rel="dns-prefetch" href="//cdn.example.com">
```

### When

- A fallback for browsers that don't support `preconnect` (Safari did support it for a long time, but coverage is now universal — `dns-prefetch` is mostly historical).
- An origin you might fetch from later but not on the critical path.

### Notes

- Most browsers ignore `dns-prefetch` if `preconnect` to the same origin is already declared (preconnect is a superset).
- The `//host` form (protocol-relative) is the legacy convention; `https://host` works too.
- Don't add for the same-origin host — already resolved.

---

## 3. `preconnect` — open a connection early

Establishes DNS + TCP + TLS handshake to an origin before any resource from that origin is fetched. Saves ~100–500 ms on third-party origins, especially on slow connections.

```html
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="preconnect" href="https://cdn.example.com">
```

### Rules

- **Use `crossorigin`** when fetching credentialed resources (fonts, fetch with credentials). Omitting it for fonts is the most common bug — the browser opens two separate connections (one without credentials, one with) and the one you need races last.
- **Limit to 2–4 origins.** Each preconnect holds an open connection. More than four wastes resources.
- **Only for origins that matter for the initial render.** Preconnecting the analytics origin doesn't help LCP.
- **Place before any other resource references** that need the connection. Order in `<head>` matters — earlier preconnects start earlier.
- **Pair with `dns-prefetch` as a fallback** for older browsers (rare in 2026):

```html
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="dns-prefetch" href="https://fonts.gstatic.com">
```

### When NOT to preconnect

- Same-origin resources — already connected.
- Non-critical-path origins (analytics, chat widgets, A/B test SaaS).
- More origins than you have measurable LCP wins for. Preconnects are not free; the budget is small.

---

## 4. `preload` — fetch eagerly, before discovery

Declares a resource the browser must fetch with high priority right now, regardless of when it would normally be discovered. Used to fix late-discovery problems for the LCP element.

```html
<link rel="preload" as="image" href="/images/hero.webp" type="image/webp" fetchpriority="high">
<link rel="preload" as="font"  href="/fonts/inter-var.woff2" type="font/woff2" crossorigin>
<link rel="preload" as="style" href="/css/critical.css">
<link rel="preload" as="script" href="/js/critical.js">
```

### Rules

- **`as` is required.** Tells the browser the destination type so it sets the right Accept headers and CSP context.
- **`type` is required for fonts** (and recommended for images) so the browser doesn't preload an unsupported format.
- **`crossorigin` is required for fonts**, even from the same origin.
- **`fetchpriority="high"`** boosts the preload above other early fetches.
- **Use sparingly.** Preload for the LCP image, the one critical font, and the critical CSS — not every asset.
- **Only when discovery is genuinely late.** If the LCP image is in the initial HTML as a normal `<img>` with `fetchpriority="high"`, you don't need to preload it. Preload only when the asset is referenced via JS, a CSS background, or imported lazily.

### Common preloads worth shipping

```html
<!-- Late-discovered LCP image (referenced in CSS or JS) -->
<link rel="preload" as="image" href="/images/hero.webp" type="image/webp" fetchpriority="high">

<!-- Critical self-hosted font for above-the-fold text -->
<link rel="preload" as="font" href="/fonts/inter-var.woff2" type="font/woff2" crossorigin>

<!-- Hero CSS bundle when split from main -->
<link rel="preload" as="style" href="/css/hero.css">
```

### Anti-patterns

- ❌ Preloading the same image twice (once via `<link rel="preload">` and once via `<img>` with `fetchpriority="high"`) — duplicate fetch.
- ❌ Preloading below-the-fold images.
- ❌ Preloading every font weight; preload one critical weight, let others load via `font-display: swap`.
- ❌ Preloading CSS the browser would discover anyway (already in `<head>`).
- ❌ Preloading without `as` — silently ignored, wastes the tag.
- ❌ Preloading without `crossorigin` for fonts — double-fetch.

---

## 5. `modulepreload` — preload an ES module and its imports

```html
<link rel="modulepreload" href="/js/app.js">
```

### Rules

- **Use for JS modules** loaded via `<script type="module" src="…">`.
- The browser also preloads imports of the module (transitive graph). Use one tag for the entry point, not for every imported file.
- Saves the round-trips of discovering imports during parsing.
- Works only for entries that are part of the module graph the browser will execute. Not for general script preloading.

---

## 6. `prefetch` — fetch for the next navigation

Low-priority fetch of a resource the user will probably need soon (next page, hover-target route).

```html
<link rel="prefetch" href="/blog/inp-guide" as="document">
<link rel="prefetch" href="/js/dashboard.chunk.js" as="script">
```

### Rules

- **Low priority** — runs only when the network is idle. Won't compete with current-page resources.
- **`as="document"`** for full-page prefetches.
- **For SPA routers**, framework-level prefetching (Next's `<Link prefetch>`, Nuxt's auto-prefetch) is usually better than hand-rolled `<link rel="prefetch">`.
- **Don't prefetch from heavy pages.** A homepage prefetching every linked sub-page on initial load wastes mobile bandwidth.
- **Honor data-saver / `prefers-reduced-data`** if the project supports it.

---

## 7. `fetchpriority` — re-prioritize a single fetch

Modifies the priority of a specific request. Works on `<link rel="preload">`, `<img>`, `<script>`, `<iframe>`, and `fetch()` calls.

```html
<img src="/images/hero.webp" fetchpriority="high" …>
<script src="/js/analytics.js" fetchpriority="low" defer></script>
<link rel="preload" as="image" href="/images/hero.webp" fetchpriority="high">
```

### Values

- `high` — boost above default for this resource type.
- `low` — defer below default.
- `auto` — browser default.

### Rules

- **One `fetchpriority="high"` image per page** — the LCP candidate.
- **Use `low` for images that are above the fold but not LCP** (avatars next to a hero, decorative cards) so they don't compete with the LCP image.
- **Combine with `loading="lazy"` only carefully.** `loading="lazy"` already deprioritizes; `fetchpriority="high"` on a lazy image is contradictory. The browser respects the lazy directive first.

In `fetch()`:

```js
fetch('/api/critical', { priority: 'high' });
fetch('/api/analytics', { priority: 'low' });
```

---

## 8. Fonts — the most common preload pattern

Web fonts are the most frequent legitimate preload because they are discovered late (referenced from CSS) and block text rendering.

### Rules

- **Self-host fonts** when possible. Cross-origin font hosts add a connection cost that often outweighs the CDN benefit.
- **Preload at most one font file** per font family — the variable-font WOFF2 covering the weights/styles used above the fold.
- **`font-display: swap`** in `@font-face` so text remains visible during font load.
- **`crossorigin` is required** even for same-origin fonts.

### Pattern

```html
<link rel="preload" as="font" href="/fonts/inter-var.woff2" type="font/woff2" crossorigin>
```

```css
@font-face {
  font-family: "Inter";
  src: url("/fonts/inter-var.woff2") format("woff2-variations");
  font-weight: 100 900;
  font-style: normal;
  font-display: swap;
  size-adjust: 100.06%;
  ascent-override: 90%;
  descent-override: 22%;
  line-gap-override: 0%;
}
```

The `size-adjust` / override values match the fallback metrics to the web font, eliminating CLS during the swap. Compute them with Capsize, `fontaine`, or `next/font`.

### Google Fonts

If using Google Fonts (third-party host):

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700&display=swap">
```

The two preconnects matter: `fonts.googleapis.com` serves the CSS, `fonts.gstatic.com` serves the actual font files (which is why it needs `crossorigin`).

Better: download the WOFF2s once, self-host, drop the third-party origin entirely.

---

## 9. Speculation Rules — full prerender of a future page

A newer Chrome/Edge mechanism that fully prerenders a likely-next navigation. Far more aggressive than `prefetch`.

```html
<script type="speculationrules">
{
  "prerender": [
    {
      "where": { "href_matches": "/blog/*" },
      "eagerness": "moderate"
    }
  ],
  "prefetch": [
    {
      "where": { "href_matches": "/*" },
      "eagerness": "conservative"
    }
  ]
}
</script>
```

### Rules

- **`eagerness`**: `conservative` (on hover/click), `moderate` (on hover after a delay), `eager` (on page load), `immediate` (now).
- **Prerendered pages cost memory and CPU** on the user's device. Use for high-confidence next-step navigations only.
- **Only Chromium implements it currently.** Safari and Firefox ignore the script.
- **Don't prerender pages with side effects** on first paint (analytics that fires before user navigates, etc.). Use the `prerender` API events to gate them.

For most sites, framework-level prefetching is enough. Reach for Speculation Rules when you have measurable wins on a high-traffic flow.

---

## 10. HTTP/2 Server Push — don't

HTTP/2 Server Push was the early-2020s answer to late discovery. **Chrome 106 (October 2022) disabled support by default**, and most CDNs have removed it. Modern equivalents:

- **Late image discovery** → `<link rel="preload">` and `fetchpriority`
- **Late CSS discovery** → inline critical CSS or `<link rel="preload">`
- **Late JS discovery** → `modulepreload`

Don't design around Server Push. If you see `link: rel=preload` HTTP headers being treated as Server Push, switch to inline `<link>` tags or remove the header — modern Chromium ignores the push.

---

## 11. Hint ordering and where they live

Resource hints belong in `<head>` and run earlier the higher up they sit. Recommended order:

```html
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- Connection hints first -->
  <link rel="preconnect" href="https://cdn.example.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="dns-prefetch" href="https://fonts.gstatic.com">

  <!-- Then preloads — fetched eagerly -->
  <link rel="preload" as="image" href="/images/hero.webp" type="image/webp" fetchpriority="high">
  <link rel="preload" as="font"  href="/fonts/inter-var.woff2" type="font/woff2" crossorigin>

  <!-- Then critical CSS and JS -->
  <link rel="stylesheet" href="/css/main.css">
  <script type="module" src="/js/app.js"></script>

  <!-- Lower-priority module preloads and prefetches -->
  <link rel="modulepreload" href="/js/dashboard.js">
  <link rel="prefetch" href="/js/charts.chunk.js" as="script">
</head>
```

### Sending hints via HTTP `Link` header

For server-rendered pages, the `Link` HTTP response header gets resource hints to the browser earlier than parsing the HTML head:

```text
Link: <https://fonts.gstatic.com>; rel=preconnect; crossorigin,
      </images/hero.webp>; rel=preload; as=image; fetchpriority=high
```

Most CDNs (Cloudflare, Vercel, Netlify) accept these as response headers configured per route. The advantage: the browser can act on them while the HTML is still being downloaded.

---

## 12. Anti-patterns — never ship

- ❌ Preconnect to every origin "just in case". Limit to 2–4.
- ❌ Preconnect without `crossorigin` for font origins (`fonts.gstatic.com`).
- ❌ `preload` without `as`. Silently ignored.
- ❌ `preload` without `type` for fonts. Wrong format may be fetched.
- ❌ `preload` for the same image already declared as `<img fetchpriority="high">` — duplicate fetch.
- ❌ Preload for below-the-fold assets.
- ❌ Preloading more than one font weight.
- ❌ `dns-prefetch` for an origin that already has `preconnect` (redundant; second is ignored).
- ❌ More than one `fetchpriority="high"` image per page.
- ❌ Preloading every chunk in the JS bundle — defeats code splitting.
- ❌ `prefetch`-ing every link on the homepage on mobile.
- ❌ Designing around HTTP/2 Server Push.
- ❌ Calling `preconnect` "HTTP/2 push" in docs/comments — they are unrelated.
- ❌ Putting hints at the end of `<head>` — they run too late to matter.
- ❌ Adding hints without measuring before/after in Lighthouse / WebPageTest.

---

## 13. Validation checklist

### Connection hints

- [ ] `preconnect` count ≤ 4.
- [ ] Font preconnects have `crossorigin`.
- [ ] No `preconnect` to same-origin host.
- [ ] No `preconnect` to non-critical-path origins.

### Preload

- [ ] Each preload has `as` attribute.
- [ ] Font preloads have `type` and `crossorigin`.
- [ ] Image preloads have `type` matching served format.
- [ ] At most one image preload (the LCP candidate, only if late-discovered).
- [ ] At most one font preload per family.
- [ ] No preloads for below-the-fold assets.
- [ ] No duplicates with regular `<img fetchpriority="high">`.

### fetchpriority

- [ ] Exactly one `fetchpriority="high"` image per page (LCP).
- [ ] No conflicting `loading="lazy"` + `fetchpriority="high"` combinations.
- [ ] Above-the-fold non-LCP imagery uses `fetchpriority="low"` if it would compete.

### Module / SPA

- [ ] `modulepreload` used for module entry, not every imported file.
- [ ] Framework-level prefetching configured (Next/Nuxt/Astro defaults).
- [ ] Speculation Rules only on high-confidence flows, with appropriate `eagerness`.

### Ordering

- [ ] Connection hints precede preloads in `<head>`.
- [ ] Preloads precede the elements that reference them.
- [ ] Hints are within the first ~20 lines of `<head>`.

### Measurement

- [ ] Lighthouse run before and after each hint addition.
- [ ] LCP measurably improved by each preload (or it's reverted).
- [ ] WebPageTest waterfall confirms preconnect / preload fired before discovery.

### Anti-patterns absent

- [ ] No HTTP/2 Server Push assumptions.
- [ ] No preconnect to every third-party origin.
- [ ] No `preload` without `as` or `type`.
- [ ] No more than one `fetchpriority="high"` image.

### Severity guide

- `high` — preload without `as`, font preload without `crossorigin` (double-fetch), `fetchpriority="high"` on non-LCP element while LCP is starved, > 6 preconnects, hints at the end of `<head>`.
- `medium` — preconnect without measurement, redundant `dns-prefetch` + `preconnect`, multiple font weights preloaded, prefetch shotgun on mobile.
- `low` — using `dns-prefetch` only when `preconnect` would fit, hint placed mid-`<head>` instead of top, design references to "HTTP/2 push".

---

## 14. Validation tools and commands

```bash
# List hints on a page
curl -s "$URL" | grep -oP '<link[^>]*rel="(preconnect|dns-prefetch|preload|modulepreload|prefetch)"[^>]*>'

# Count preconnects (cap at ~4)
curl -s "$URL" | grep -oc '<link[^>]*rel="preconnect"'

# Check font preload has crossorigin
curl -s "$URL" | grep -oP '<link[^>]*as="font"[^>]*>' | grep -v crossorigin \
  && echo "WARN: font preload without crossorigin"

# Check preload has as
curl -s "$URL" | grep -oP '<link[^>]*rel="preload"[^>]*>' | grep -v 'as="' \
  && echo "FAIL: preload without as attribute"

# Check fetchpriority high count (must be ≤ 1 for images)
curl -s "$URL" | grep -oP '<img[^>]*fetchpriority="high"' | wc -l

# Lighthouse — Diagnostics will flag wasted preloads
npx lighthouse "$URL" --view
```

### WebPageTest

WebPageTest's waterfall view shows exactly when each preconnect/preload fired. Use the "Connection View" to verify a preconnect actually opened a connection in time for the resource that needed it.

### Browser DevTools

- **Network tab → Initiator column** shows whether a request came from a preload.
- **Network tab → Priority column** confirms `fetchpriority` took effect.
- **Performance tab → Network track** visualizes parallelism and connection setup.

---

## 15. Output format

When asked to **add hints** to a page, return:

1. A short audit of the current `<head>` (what's there, what's missing or wrong).
2. The exact `<link>` tags to add and where in `<head>` they go.
3. The exact `<link>` tags or attributes to remove (redundant, wrong).
4. The Lighthouse / WebPageTest measurement before-and-after the user should run.

When asked to **audit** existing hints, return:

```text
# Resource Hints Audit — <URL>

## Summary
- preconnect: <count, with crossorigin status>
- dns-prefetch: <count>
- preload: <count, by `as`>
- modulepreload: <count>
- fetchpriority="high" images: <count>
- LCP image: <preloaded? high priority? eager?>
- Position in <head>: <near top / scattered>
- Overall: <PASS | NEEDS WORK | FAIL>

## Findings
**[HIGH]** <hint or element> — <issue> — <recommended fix>
**[MEDIUM]** ...
**[LOW]** ...

## Recommended fix order
1. ...
```

Then offer to apply each fix. Apply approved fixes one at a time, confirming each.
