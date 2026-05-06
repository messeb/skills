---
description: Image optimization for SEO, Core Web Vitals, and social sharing — modern formats (AVIF, WebP) with fallbacks, responsive srcset/sizes, the picture element, intrinsic dimensions to prevent CLS, eager vs lazy loading, fetchpriority for LCP, decoding hints, alt text rules for SEO and a11y, OG image specs for unfurlers, image sitemaps, automation pipelines, and a complete validation checklist.
---

# Image optimization — performance, SEO, and social

Images are the single biggest contributor to page weight, the most common LCP element, the most common CLS source, and a major SEO surface (image search + alt text). One skill, three audiences: Core Web Vitals, search engines, and link-preview unfurlers.

For LCP-specific timing rules see `core-web-vitals`. For OG image meta tags see `meta-tags`. This skill is about **the image asset itself**: format, size, markup, and pipeline.

---

## 1. The decisions, in order

For every image on a page, decide in this order:

1. **Is this a content image or a decorative image?**
   - Decorative → CSS `background-image`, `alt=""` is not required (don't use `<img>`).
   - Content → `<img>` with real `alt`.
2. **What is the rendered size at every breakpoint?** Compute the largest CSS pixel size × DPR. This is the upper bound on bytes you need.
3. **What format(s) does the source allow?** Photos → AVIF + WebP + JPEG fallback. Diagrams / UI / line art → SVG. Lossless screenshots → AVIF + WebP + PNG fallback.
4. **Is this above the fold?** If yes, eager + `fetchpriority="high"` (only for the LCP candidate). If no, lazy.
5. **Will the layout collapse if the image fails to load?** Always set `width` and `height` (or `aspect-ratio` on the container).

Skip a step and a regression follows.

---

## 2. Formats — pick the right one

| Format | Use for | Strengths | Weaknesses |
|--------|---------|-----------|------------|
| **AVIF** | Photos, hero images | Best compression (~50% smaller than JPEG at equal quality) | Slow encoder, some unfurlers reject |
| **WebP** | Photos, screenshots | 25–35% smaller than JPEG, ~95% browser support | Larger than AVIF |
| **JPEG** | Photo fallback | Universal | Largest |
| **PNG** | UI assets, transparent images, fallback for screenshots | Lossless, alpha | Large for photos |
| **SVG** | Logos, icons, diagrams, line art | Scales infinitely, tiny | Wrong for photos |
| **GIF** | Never (use video for animation) | Animation | Huge for motion content |

### Format decision

- Photos → **AVIF + WebP + JPEG fallback**.
- Screenshots → AVIF + WebP + PNG (lossless if quality matters).
- Logos / icons → **SVG**.
- Charts and diagrams → **SVG** when authored vector; PNG/WebP only if rasterized.
- Animation → **MP4/WebM video**, never GIF.

### Critical exception: OG images

Open Graph images (Facebook, LinkedIn, Slack, X unfurls) **must be PNG or JPEG**. Many unfurlers still reject WebP and AVIF. Even if your site uses modern formats everywhere else, ship the OG image as PNG or JPEG.

---

## 3. The `<picture>` pattern

```html
<picture>
  <source srcset="/images/hero.avif" type="image/avif">
  <source srcset="/images/hero.webp" type="image/webp">
  <img
    src="/images/hero.jpg"
    width="1200"
    height="630"
    alt="A flame chart showing a 380 ms long task during click handling"
    loading="eager"
    decoding="async"
    fetchpriority="high">
</picture>
```

### Rules

- **Order matters**: most-preferred format first. Browser picks the first supported `<source>`.
- The fallback `<img>` carries the `alt`, `width`, `height`, `loading`, `decoding`, `fetchpriority`. **Do not put `alt` on `<source>`.**
- The `<img>` `src` is the **fallback** format only. Browsers that support `<source>` formats won't fetch it.

---

## 4. Responsive images — `srcset` and `sizes`

Use `srcset` whenever the image renders at different sizes on different breakpoints (most images on most sites).

```html
<img
  src="/images/card-800.webp"
  srcset="
    /images/card-400.webp   400w,
    /images/card-800.webp   800w,
    /images/card-1200.webp 1200w,
    /images/card-1600.webp 1600w
  "
  sizes="(min-width: 1024px) 33vw, (min-width: 640px) 50vw, 100vw"
  width="800"
  height="450"
  alt="…"
  loading="lazy"
  decoding="async">
```

### Width descriptors (`Nw`)

Each entry tells the browser the image's intrinsic width in CSS pixels. Combined with `sizes`, the browser picks the best variant for the viewport and DPR.

### `sizes` attribute

Tells the browser the image's rendered width at each breakpoint **before layout**. Wrong `sizes` values force the browser to download too-large or too-small images.

```text
sizes="(min-width: 1024px) 33vw, (min-width: 640px) 50vw, 100vw"
```

Reads: "above 1024 px viewport → image is 33% of viewport width; above 640 px → 50%; otherwise → 100%."

### Pixel density (`Nx`) — only for fixed-size images

```html
<img
  src="/icons/logo-1x.png"
  srcset="/icons/logo-1x.png 1x, /icons/logo-2x.png 2x, /icons/logo-3x.png 3x"
  width="120"
  height="32"
  alt="Example">
```

Use `1x/2x/3x` only when the rendered size is **fixed** (logos, icons). Otherwise use `w` descriptors with `sizes`.

### Variant generation

Generate at least 4 widths covering the responsive range. A typical set for a content card:

`400`, `800`, `1200`, `1600` widths in each format (AVIF + WebP + fallback). 12 files per source image. Automate it (section 11).

---

## 5. Intrinsic dimensions — preventing CLS

Every `<img>` and `<iframe>` must have `width` and `height` attributes. The browser uses them to reserve layout space before the asset loads, preventing layout shift.

### Rules

- **`width` and `height` are the intrinsic pixel dimensions** (the actual image's pixels). Not the rendered size.
- **CSS resizes from those dimensions.** `<img width="1200" height="630">` rendered with `style="width: 100%; height: auto"` correctly preserves aspect ratio.
- **Aspect ratio is computed automatically** by the browser from the attributes.

### When you can't know the dimensions

For dynamic images of unknown size (user uploads), wrap in a container with `aspect-ratio`:

```html
<div class="card__media">
  <img src="…" alt="…">
</div>

<style>
  .card__media {
    aspect-ratio: 16 / 9;
  }
  .card__media img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
</style>
```

But ideally store the dimensions in your CMS at upload time and emit them.

---

## 6. Loading priority — eager, lazy, fetchpriority

### `loading`

| Value | When |
|-------|------|
| `eager` | Above-the-fold images. The default for `<img>` is `eager`, so this is mostly for explicit clarity. |
| `lazy` | Below-the-fold content images. Native browser lazy loading. |

### `decoding`

| Value | When |
|-------|------|
| `async` | Almost always. Lets the browser decode off the main thread. |
| `sync` | Rarely needed; only when you need the image to be ready before the next paint of an animation. |

### `fetchpriority`

| Value | When |
|-------|------|
| `high` | The LCP image only. One per page. |
| `low` | Below-the-fold images that should be deprioritized (e.g. social proof images that don't matter for first paint). |
| `auto` | Default. |

### Combinations

| Image role | loading | decoding | fetchpriority |
|------------|---------|----------|---------------|
| LCP (hero) | `eager` | `async` | `high` |
| Above-the-fold (non-LCP) | `eager` | `async` | `auto` |
| Below-the-fold | `lazy` | `async` | `auto` |
| Decorative (background) | n/a (CSS) | n/a | n/a |

### The most common bug

Setting `loading="lazy"` on the LCP image. The browser delays the fetch, LCP times out, ranking drops. Run a Lighthouse check after every template change to confirm the LCP image is eager + high priority.

---

## 7. Alt text — SEO + accessibility in one attribute

`alt` is read by screen readers, indexed by Google Image Search, used in AI image-context retrieval, and shown when the image fails. The attribute is **required on every `<img>`** — use `alt=""` for decorative, but **never omit**.

### Rules for content images

- **Describe purpose, not appearance.** "Diagram showing data flow from API to client" beats "diagram with arrows and boxes".
- **Don't start with "Image of" / "Picture of"** — screen readers already announce that.
- **Keep concise** — 125 characters is a reasonable upper bound, but length is not a rule. Match the image's role on the page.
- **Don't keyword-stuff.** "Acme Pro Mouse 240 Hz wireless ergonomic mouse for computer office gaming" is spam. "Acme Pro Mouse with sculpted ergonomic shell" is fine.
- **Match the page's topic.** An image's `alt` is a contextual signal for the surrounding text, not for search terms in isolation.

### Rules for decorative images

- `alt=""` (empty), but **the attribute must be present**. Missing `alt` is a serious a11y violation.
- Better: don't use `<img>` at all — make decorative imagery a CSS background.

### Special cases

- **Images that are also links**: the `alt` describes the link's destination, not the image. `<a href="/cart"><img src="cart.svg" alt="Cart (3 items)"></a>`.
- **Image is the only content of a button**: `alt` describes the action. `<button><img src="trash.svg" alt="Delete row"></button>`.
- **SVG inline**: use `<title>` and `<desc>` children, plus `role="img"` on the SVG.
- **Charts and graphs**: short `alt` summarizing the takeaway, with a longer description in adjacent text or `aria-describedby`.
- **Captions exist already**: `<figure>` + `<figcaption>` provides the caption; `alt` can be more compact since the caption carries detail.

### Bad

```html
<img src="hero.jpg">                                <!-- missing alt -->
<img src="hero.jpg" alt="hero">                     <!-- generic -->
<img src="hero.jpg" alt="image">                    <!-- meaningless -->
<img src="hero.jpg" alt="Acme Pro Mouse 240 Hz wireless ergonomic gaming mouse computer office">   <!-- stuffed -->
<img src="logo.svg">                                <!-- missing alt -->
```

### Good

```html
<img src="hero.jpg" alt="Flame chart of a slow click handler taking 380 ms">
<img src="logo.svg" alt="Example">
<img src="decorative-pattern.svg" alt="">
```

---

## 8. OG / social sharing images

Social unfurlers (Facebook, LinkedIn, Slack, iMessage, Discord, X) read `og:image`. They have stricter requirements than browser images.

| Requirement | Value |
|-------------|-------|
| Dimensions | 1200 × 630 px (1.91:1) |
| Format | PNG or JPEG |
| File size | ≤ 1 MB; ≤ 300 KB preferred |
| URL | Absolute, including `https://` |
| Transparency | None — many unfurlers render the alpha channel as black |
| Title baked in | Strongly recommended — bare product photos lose to designed cards in feeds |

### Markup

See the `meta-tags` skill for full Open Graph wiring. The image rules:

```html
<meta property="og:image"           content="https://example.com/og/inp-guide.png">
<meta property="og:image:type"      content="image/png">
<meta property="og:image:width"     content="1200">
<meta property="og:image:height"    content="630">
<meta property="og:image:alt"       content="INP — the Core Web Vital that measures interaction responsiveness">
```

### Common mistakes

- Shipping a WebP / AVIF as `og:image` (LinkedIn and others drop it).
- Relative URL (`/og/foo.png` instead of `https://example.com/og/foo.png`).
- Missing `og:image:width` / `og:image:height` (some unfurlers won't fetch).
- Using a 16:9 marketing render (1920×1080) — Facebook crops badly.
- Using the page's hero image as OG without the title baked in — bad in-feed CTR.
- One generic OG image for the whole site — kills per-article share CTR.

### Generating OG images

Per-article OG images at scale:

- **Build-time**: render an HTML/CSS template per article using Playwright/Puppeteer.
- **Edge function**: Vercel OG, Cloudflare's `@cloudflare/pages-plugin-vercel-og`, or a custom worker.
- **Static + variations**: ship a default per category, override per article when worth it.

---

## 9. Image SEO — sitemaps and structured data

### Image sitemaps

Inline image entries in the URL sitemap (see `crawl-control` for syntax):

```xml
<url>
  <loc>https://example.com/blog/inp-guide</loc>
  <image:image>
    <image:loc>https://example.com/og/inp-guide.png</image:loc>
    <image:title>INP — Core Web Vital responsiveness metric</image:title>
    <image:caption>…</image:caption>
  </image:image>
</url>
```

### Image structured data

Google reads `image` properties from structured data. Provide multiple aspect ratios (1:1, 4:3, 16:9) for rich-result eligibility on Article, Product, and Recipe types. For full schema patterns see **`structured-data-jsonld`** (JSON-LD) and **`html5-microdata`** (inline). Quick example:

```json
{
  "@type": "Article",
  "image": [
    "https://example.com/images/hero-1x1.jpg",
    "https://example.com/images/hero-4x3.jpg",
    "https://example.com/images/hero-16x9.jpg"
  ]
}
```

### File names

Image filenames are a weak ranking signal. Use descriptive kebab-case:

- ✅ `inp-flame-chart.webp`
- ❌ `IMG_4837.webp`
- ❌ `screenshot-2026-04-12-at-09-23-58.webp`

---

## 10. Compression targets

| Image type | Target |
|------------|--------|
| Hero / LCP image | ≤ 200 KB (AVIF), ≤ 250 KB (WebP), ≤ 400 KB (JPEG fallback) |
| Above-the-fold card images (combined) | ≤ 300 KB |
| Article inline images | ≤ 80 KB each |
| Thumbnails | ≤ 30 KB |
| OG images | ≤ 300 KB |
| Logos (SVG) | ≤ 5 KB raw |

### Quality targets

- AVIF: quality 50–60 (perceptually equivalent to JPEG 85).
- WebP: quality 75–80.
- JPEG: quality 80–85.

Use `cwebp`, `avifenc`, `mozjpeg`, or a build-tool plugin (`sharp`, `imagemin`).

### Automation

```bash
# WebP from JPEG
cwebp -q 80 source.jpg -o source.webp

# AVIF
avifenc --speed 6 -q 55 source.jpg source.avif

# Optimize JPEG
mozjpeg -quality 82 -outfile source.opt.jpg source.jpg

# Generate responsive variants with sharp (Node)
node -e '
  const sharp = require("sharp");
  const widths = [400, 800, 1200, 1600];
  for (const w of widths) {
    sharp("source.jpg").resize(w).avif({ quality: 55 }).toFile(`out/source-${w}.avif`);
    sharp("source.jpg").resize(w).webp({ quality: 80 }).toFile(`out/source-${w}.webp`);
    sharp("source.jpg").resize(w).jpeg({ quality: 82 }).toFile(`out/source-${w}.jpg`);
  }
'
```

### Build-tool integration

| Stack | Plugin / loader |
|-------|-----------------|
| Astro | `astro:assets` (built-in `<Image />` and `<Picture />`) |
| Next.js | `next/image` with the default loader or Cloudinary/Imgix loader |
| Nuxt | `@nuxt/image` |
| Vite (generic) | `vite-imagetools` |
| Eleventy | `@11ty/eleventy-img` |
| Static | `sharp` script in CI |

These produce variants automatically; don't ship hand-cropped JPEGs in 2026.

---

## 11. CDN / image service

For sites with large catalogs (e-commerce, UGC, image-heavy publishing), a dedicated image CDN solves on-demand resizing, format negotiation, and edge caching:

- **Cloudflare Images / Cloudflare Polish**
- **Imgix**
- **Cloudinary**
- **Bunny Image Optimizer**
- **AWS CloudFront + Lambda@Edge with Sharp**

Negotiation: serve AVIF/WebP/JPEG based on the request `Accept` header, automatic responsive sizes via URL parameters.

```text
https://images.example.com/cdn-cgi/image/format=auto,width=800,quality=80/source.jpg
```

A real CDN beats hand-rolled `<picture>` for catalogs above ~1k images.

---

## 12. Decorative vs content — a rule

If removing the image leaves the page's meaning intact, it's decorative.

- ✅ Background gradients, hero ambient art, decorative dividers, brand patterns → **CSS `background-image`**, no markup needed.
- ✅ Author photos, product photos, charts, diagrams, screenshots → **`<img>` with real `alt`**.
- ⚠ Stock photos in marketing pages — they often add no semantic value but are rendered as `<img>` anyway. Use a short `alt` describing the scene; do not invent SEO value that isn't there.

---

## 13. Anti-patterns — never ship

- ❌ `loading="lazy"` on the LCP image.
- ❌ Hero / LCP image as CSS `background-image` (no `fetchpriority`, late discovery).
- ❌ Missing `alt` attribute (write `alt=""` for decorative).
- ❌ Missing `width` / `height` — guaranteed CLS.
- ❌ One huge image scaled down with CSS (`<img src="hero-4000x3000.jpg" style="width: 200px">`).
- ❌ JPEG / PNG when AVIF / WebP would do (and the toolchain supports it).
- ❌ WebP / AVIF as `og:image` (unfurlers reject).
- ❌ Generic alt text: "image", "photo", "graphic".
- ❌ Keyword-stuffed alt text.
- ❌ Same `alt` on every product image in a gallery (`alt="Acme Pro Mouse"` × 8).
- ❌ Filename `IMG_4837.jpg` shipped to production.
- ❌ GIFs for animation (use MP4/WebM).
- ❌ More than one `fetchpriority="high"` per page.
- ❌ Inline SVG without `role="img"` / `<title>` when the SVG is meaningful.
- ❌ Linking the same image at multiple aspect ratios with the same `src` and only `srcset` differing — provide actual cropped variants.
- ❌ Lazy-loading every image — the first 1–2 above-the-fold images must be eager.
- ❌ `decoding="sync"` on large images — blocks rendering.
- ❌ Auto-rotating hero carousel with non-equal slide heights (CLS).
- ❌ Hand-rolled responsive images on a site with thousands of images instead of using an image CDN.

---

## 14. Validation checklist

### Per-image

- [ ] `<img>` (or `<picture>` + `<img>`) is the right element (not a `<div>` background for a content image).
- [ ] `alt` attribute is present (empty for decorative, descriptive otherwise).
- [ ] `width` and `height` set to intrinsic pixel dimensions.
- [ ] Modern format(s) provided via `<source>` with appropriate `type`.
- [ ] `srcset` and `sizes` provided when the image renders at variable sizes.
- [ ] `loading="lazy"` for below-the-fold; **not** for above-the-fold.
- [ ] `decoding="async"` for non-critical images.
- [ ] `fetchpriority="high"` only on the LCP image.

### Per-page

- [ ] Exactly one `fetchpriority="high"` image (the LCP).
- [ ] LCP image is in the initial server-rendered HTML.
- [ ] Above-the-fold image weight ≤ 300 KB total.
- [ ] No CSS `background-image` for the LCP element.
- [ ] No layout shift from images during reload (record in DevTools).
- [ ] Cached images use long `Cache-Control` (`public, max-age=31536000, immutable` for hashed filenames).

### Site-wide

- [ ] Image CDN or build-tool variant generation in place; no hand-cropped JPEGs.
- [ ] Image filenames are descriptive kebab-case.
- [ ] OG images shipped as PNG/JPEG, 1200×630, ≤ 1 MB, absolute URL.
- [ ] OG images per article (or per template), not one global default.
- [ ] Image sitemap entries for content-relevant images.
- [ ] Structured data (`Article.image`, `Product.image`) provides multiple aspect ratios where applicable.
- [ ] Compression targets met (sample ten images per page type).

### Severity guide

- `high` — LCP image lazy-loaded, missing `alt` on content images, missing `width/height`, OG image broken (relative URL, WebP, missing dimensions), images served at 4× rendered size.
- `medium` — JPEG-only when modern formats are available, no `srcset` on responsive images, generic alt text, `fetchpriority="high"` on more than one image, one global OG image.
- `low` — non-descriptive filenames, missing `decoding="async"`, no image sitemap, missing `Article.image` aspect-ratio variants.

---

## 15. Validation tools and commands

```bash
# Inspect images on a page
curl -s "$URL" | grep -oP '<img[^>]+>'

# Find images without width/height
curl -s "$URL" | grep -oP '<img[^>]+>' | grep -vP 'width=' \
  && echo "WARN: images without width attr"

# Find lazy-loaded images that might be the LCP
curl -s "$URL" | grep -oP '<img[^>]+loading="lazy"[^>]+fetchpriority="high"[^>]*>'

# Identify the LCP element (DevTools Performance Insights, or:)
npx lighthouse "$URL" --only-categories=performance --view
# → Diagnostics → "Largest Contentful Paint element"

# Validate OG image
curl -sI "$(curl -s "$URL" | grep -oP 'og:image[^>]*content="[^"]+"' | grep -oP 'https?://[^"]+')"
# → must be 200, image/png or image/jpeg, ≤ 1 MB

# Inspect image weight
curl -sI "https://example.com/images/hero.webp" | grep -i content-length

# Compress check (WebP)
identify -format "%[width]x%[height] %[filesize]\n" hero.webp

# Crawl all images and audit
npx site-audit-seo --url=https://example.com --json | jq '.images'
```

### Browser tools

- **Chrome DevTools → Network tab** filter to "Img" — see byte size, format, and fetch order.
- **DevTools → Lighthouse** — "Properly size images", "Serve images in next-gen formats", "Defer offscreen images".
- **PageSpeed Insights** — opportunities section flags oversized and wrong-format images.
- **WebPageTest** — image analysis tab gives per-image savings estimates.

---

## 16. Output format

When asked to **generate** image markup, return:

1. The full `<picture>` (or `<img>` with `srcset`) for the requested image, with the right format chain and loading attributes for its position on the page.
2. A note on the source image specs needed (intrinsic resolution, variants to generate, format).
3. The corresponding OG image markup if the page is shareable.
4. Open questions (does the project have an image CDN? variant strategy? alt text from CMS?).

When asked to **audit** existing images, return:

```text
# Image Audit — <URL or directory>

## Summary
- Images sampled: <count>
- LCP image identified: <url>
- LCP image lazy-loaded: <yes/no>
- Missing width/height: <count>
- Missing/empty alt on content images: <count>
- Modern format coverage: <% of images with AVIF or WebP>
- OG image: <pass/fail>
- Total above-the-fold image weight: <KB>

## Findings
**[HIGH]** <url> — <issue> — <recommended fix>
**[MEDIUM]** ...
**[LOW]** ...

## Recommended fix order
1. ...
```

Then offer to apply each fix. Apply approved fixes one at a time, confirming each.
