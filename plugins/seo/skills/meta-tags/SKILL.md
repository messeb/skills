---
description: Complete reference for HTML meta tags that maximize SEO, social sharing, and AI/LLM discoverability — title, description, canonical, robots, Open Graph, Twitter Card, hreflang, viewport, theme-color, favicons, verification, and AI-crawler controls. Includes per-page-type templates, framework patterns (Astro, Nuxt, Next), an anti-pattern list, and a validation checklist.
---

# Meta tags — the complete `<head>` for SEO, social, and AI

Goal of this skill: produce the **best possible** set of `<head>` meta tags for any page type. Every tag listed here either improves search ranking, controls how the page appears in search/social/AI results, or is required for correct rendering.

Use this skill when authoring `<head>` templates, building an SEO component, or auditing existing meta tags.

---

## 1. Who reads `<head>` and why it matters

| Consumer | Reads |
|----------|-------|
| Google / Bing / DuckDuckGo | `title`, `meta description`, `canonical`, `robots`, hreflang, structured data |
| Google Discover / News | `og:image`, `max-image-preview`, publication metadata |
| Facebook / LinkedIn / Slack / iMessage / Discord | Open Graph |
| X / Twitter | Twitter Card (falls back to Open Graph) |
| Pinterest | Open Graph + `article:` properties |
| ChatGPT / Perplexity / Claude / Gemini | `title`, `description`, JSON-LD, canonical, robots, AI-specific tokens |
| Browsers | `viewport`, `theme-color`, `color-scheme`, favicons, manifest |
| Verification (Search Console, Bing Webmaster) | site-verification meta tags |

A page with a great body but broken `<head>` will rank, share, and surface badly. Treat `<head>` as a product surface.

---

## 2. The minimum every page must have

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <title>Page title — Brand</title>
  <meta name="description" content="One-sentence answer to the user's likely query, 140–160 characters.">

  <link rel="canonical" href="https://example.com/page-path">

  <meta name="robots" content="index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1">
</head>
```

Anything below is built on top of this base. If a page is missing any of the six tags above, fix that first.

---

## 3. `<title>` — the most important tag

The `<title>` is the single highest-impact meta tag. It is the SERP click target, the browser tab label, the bookmark text, the social fallback, and the LLM citation label.

### Rules

- **Length**: 50–60 characters of visible text. Google truncates around 580 px; counting characters is a good proxy.
- **Structure**: `Primary phrase — Secondary qualifier — Brand`. Use an em dash or pipe, pick one and use it consistently across the site.
- **Front-load**: put the most important keyword in the first 30 characters. Engines weight position.
- **Uniqueness**: every URL must have a unique `<title>`. Duplicates trigger Google to rewrite them.
- **Match intent, not just keywords**: write the title that matches what a user would click, not what stuffs the most terms.
- **One per page**. Only one `<title>` element.

### Templates by page type

```text
Home:        Brand — One-line value proposition
Category:    {Category} — {Site type or qualifier} | Brand
Article:     {Question or topic} — {Date or context} | Brand
Product:     {Product name} {key spec} — Buy at Brand
Comparison:  {A} vs {B} — Differences explained | Brand
Search:      Search results for "{query}" | Brand
Author:      {Author name} — Articles | Brand
404:         Page not found — Brand
```

### Examples

```html
<!-- Good -->
<title>What is INP? Core Web Vital thresholds and fixes — Example</title>

<!-- Bad: keyword-stuffed -->
<title>INP, Interaction to Next Paint, INP Score, Web Vitals INP — Example, Best Site</title>

<!-- Bad: brand-first wastes the click target -->
<title>Example — INP guide</title>
```

---

## 4. `<meta name="description">`

The description is not a direct ranking factor, but it controls click-through rate and is the snippet surfaced by both Google and most AI engines.

### Rules

- **Length**: 140–160 characters. Mobile snippets sometimes truncate at 120; keep the punchline early.
- **Match the title's promise**. If the title asks a question, the description starts answering it.
- **Active voice, action verb**. "Learn", "Compare", "See", "Find" outperform passive forms.
- **No double quotes** inside the attribute. Use straight quotes only at the boundaries.
- **No emoji** on substantive content. Emoji can survive in commerce/category pages but dilute trust on serious topics.
- **Unique per page**. Duplicates are filtered by Google and replaced with auto-generated snippets.
- **Don't repeat the title verbatim**. Add new information.

### Examples

```html
<!-- Good -->
<meta name="description" content="INP measures how fast a page responds to clicks and taps. See the 200 ms threshold, common causes of slow INP, and concrete fixes for React and Vue apps.">

<!-- Bad: vague -->
<meta name="description" content="Learn about INP and how to improve it on your website today.">
```

If a page legitimately has no good description (search results, paginated archives), it is acceptable to **omit** the meta description and let Google generate one rather than ship a weak one.

---

## 5. `<link rel="canonical">`

The canonical tells engines which URL is the source of truth for the content, consolidating ranking signals across duplicates.

This section covers the **canonical tag** itself. For trailing-slash policy, host canonicalization (apex vs www, HTTP vs HTTPS), redirect strategy, and tracking-parameter handling at the URL level, see **`url-structure`**.

### Rules

- **Always absolute URL**. `https://example.com/page`, never `/page`.
- **Self-canonical by default**. Every indexable page should canonical to itself.
- **Lowercase, no trailing slash inconsistency**. Pick a convention site-wide and stick to it.
- **No tracking parameters**. Strip `utm_*`, `gclid`, `fbclid` before generating canonical.
- **Match the rendered URL**. Mismatches between canonical and rendered URL are silently ignored.
- **One per page**. Multiple canonicals are ignored entirely.
- **Cross-domain canonical** is valid for syndicated content; the original publisher canonicals to itself, the syndicator canonicals to the original.
- **Pagination**: each page in a series should self-canonical. Do not canonical page 2 to page 1 — that hides page 2's content. (Google deprecated `rel=prev/next` as a signal but it is still harmless.)

### Examples

```html
<link rel="canonical" href="https://example.com/blog/inp-guide">
```

For a campaign URL like `https://example.com/blog/inp-guide?utm_source=newsletter`:

```html
<link rel="canonical" href="https://example.com/blog/inp-guide">
```

---

## 6. `<meta name="robots">` and per-bot variants

Controls indexing, link following, and snippet behaviour. The default for any indexable page should be:

```html
<meta name="robots" content="index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1">
```

### The directives

| Directive | Effect |
|-----------|--------|
| `index` / `noindex` | Allow / disallow indexing |
| `follow` / `nofollow` | Follow / don't follow links on the page |
| `noarchive` | Don't show cached copy |
| `nosnippet` | Don't show any text snippet (also disables AI Overviews use) |
| `max-snippet:-1` | No length limit on text snippets |
| `max-image-preview:large` | Allow large image previews (required for Discover) |
| `max-video-preview:-1` | No length limit on video previews |
| `noimageindex` | Don't index images on the page |
| `unavailable_after: <RFC-850 date>` | Stop indexing after a date |
| `notranslate` | Don't offer translation |

### When to use `noindex`

- Internal search result pages
- Filtered category URLs (`?color=red&size=lg`) — prefer canonical to the unfiltered URL
- Thin author pages with one post
- Staging / preview environments (use `X-Robots-Tag: noindex` HTTP header at the edge instead of the meta, to cover non-HTML responses)
- Thank-you / confirmation pages
- Deprecated pages awaiting removal

### Per-bot variants

```html
<!-- Block AI training but keep search indexing -->
<meta name="googlebot" content="index,follow">
<meta name="GPTBot" content="noindex,nofollow">
<meta name="Google-Extended" content="noindex">
<meta name="CCBot" content="noindex,nofollow">
```

These are advisory. The robust enforcement happens in `robots.txt` (see section 14).

---

## 7. Open Graph — the social fallback for everyone

Every link unfurler on the internet (Facebook, LinkedIn, Slack, iMessage, Discord, WhatsApp, Telegram, Pinterest, Mastodon) reads Open Graph. X falls back to Open Graph when Twitter Card tags are missing. Some LLM previews use Open Graph for thumbnails.

### Required for every shareable page

```html
<meta property="og:type" content="article">
<meta property="og:title" content="What is INP? Core Web Vital thresholds and fixes">
<meta property="og:description" content="INP measures how fast a page responds to clicks and taps. See the 200 ms threshold, common causes, and concrete fixes for React and Vue apps.">
<meta property="og:url" content="https://example.com/blog/inp-guide">
<meta property="og:site_name" content="Example">
<meta property="og:locale" content="en_US">

<meta property="og:image" content="https://example.com/og/inp-guide.png">
<meta property="og:image:secure_url" content="https://example.com/og/inp-guide.png">
<meta property="og:image:type" content="image/png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:alt" content="INP — the Core Web Vital that measures interaction responsiveness">
```

### `og:image` rules (markup)

- **Absolute URL**, including protocol.
- **Always set `og:image:width` and `og:image:height`** — some unfurlers won't fetch without them.
- **Always set `og:image:alt`**.
- **Multiple images allowed**: repeat `og:image` blocks. The first is the default.

For dimensions, format, file size, transparency, and OG image generation patterns see **`image-optimization`** (OG section). Quick rule of thumb: 1200 × 630 PNG/JPG, ≤ 1 MB, no alpha channel.

### Type-specific properties

For `og:type=article`:

```html
<meta property="article:published_time" content="2026-04-12T09:00:00Z">
<meta property="article:modified_time" content="2026-05-06T14:30:00Z">
<meta property="article:author" content="https://example.com/authors/jane-doe">
<meta property="article:section" content="Performance">
<meta property="article:tag" content="Core Web Vitals">
<meta property="article:tag" content="INP">
```

For `og:type=product`:

```html
<meta property="product:price:amount" content="49.00">
<meta property="product:price:currency" content="USD">
<meta property="product:availability" content="in stock">
```

For `og:type=video.other`:

```html
<meta property="og:video" content="https://example.com/videos/inp.mp4">
<meta property="og:video:type" content="video/mp4">
<meta property="og:video:width" content="1280">
<meta property="og:video:height" content="720">
```

### Common `og:type` values

`website`, `article`, `book`, `profile`, `music.song`, `music.album`, `video.movie`, `video.episode`, `video.tv_show`, `video.other`, `product`.

---

## 8. Twitter Card

X uses its own tags but falls back to Open Graph for missing fields. Set both for safety.

```html
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:site" content="@example">
<meta name="twitter:creator" content="@janedoe">
<meta name="twitter:title" content="What is INP? Core Web Vital thresholds and fixes">
<meta name="twitter:description" content="INP measures how fast a page responds to clicks and taps. See the threshold, causes, and fixes.">
<meta name="twitter:image" content="https://example.com/og/inp-guide.png">
<meta name="twitter:image:alt" content="INP — the Core Web Vital that measures interaction responsiveness">
```

### Card types

| Type | When to use |
|------|-------------|
| `summary` | Short preview with small thumbnail. Default for category/index pages. |
| `summary_large_image` | Large hero image. Default for articles, products, landing pages. |
| `app` | Mobile app card. Specific iOS/Android tags. |
| `player` | Inline media player. Requires HTTPS player URL and dimensions. |

### Notes

- Twitter title is shorter than OG: keep ≤ 70 characters.
- Twitter description is shorter: keep ≤ 200 characters.
- Twitter image min 300 × 157, max 4096 × 4096, ≤ 5 MB. Use the same 1200 × 630 OG image to avoid duplication.

---

## 9. `hreflang` — locale and language alternates

If the site serves more than one language or region, every alternate URL must declare its peers, including itself.

```html
<link rel="alternate" hreflang="en" href="https://example.com/blog/inp-guide">
<link rel="alternate" hreflang="en-GB" href="https://example.com/en-gb/blog/inp-guide">
<link rel="alternate" hreflang="de" href="https://example.com/de/blog/inp-guide">
<link rel="alternate" hreflang="de-AT" href="https://example.com/de-at/blog/inp-guide">
<link rel="alternate" hreflang="x-default" href="https://example.com/blog/inp-guide">
```

### Rules

- **Self-reference required**. The English page must list itself as `hreflang="en"`.
- **Reciprocity required**. If A points to B, B must point to A. Missing reciprocity invalidates the cluster.
- **Language codes**: ISO 639-1 (`en`, `de`, `fr`).
- **Region codes**: ISO 3166-1 alpha-2 (`GB`, `DE`, `AT`). Combine as `en-GB`, `de-AT`. Do not invent combinations.
- **`x-default`** points to the fallback URL for unmatched locales (often the global English version or a language picker).
- **Use absolute URLs**. Never relative.
- **One cluster per `Page` group**. Pagination has its own cluster (page 2 EN ↔ page 2 DE), not cross-page.
- **Alternative**: serve hreflang via `Link` HTTP header or sitemap. For sites with thousands of locale variants, **sitemap-based hreflang** is more reliable than per-page `<link>` tags — see **`crawl-control`** for the sitemap pattern. For URL-shape rules across locales (path prefix vs subdomain vs ccTLD) see **`url-structure`**.

---

## 10. Viewport, theme color, color scheme

```html
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">

<meta name="theme-color" content="#0b1220" media="(prefers-color-scheme: dark)">
<meta name="theme-color" content="#ffffff" media="(prefers-color-scheme: light)">

<meta name="color-scheme" content="light dark">
```

### Notes

- **`viewport-fit=cover`** required for edge-to-edge layouts on iPhone (notched devices).
- **`user-scalable=no`** is an accessibility violation. Never use it.
- **`theme-color`** colours the browser chrome on Android Chrome, Safari (macOS Sonoma+, iOS 15+), and PWAs. Provide one per scheme.
- **`color-scheme`** tells the browser to render system UI (form controls, scrollbars) for the supported themes — prevents white form widgets on a dark site.

---

## 11. Favicons and the touch icon set

The bare minimum that survives modern browsers, iOS, Android, Windows tiles, and Safari pinned tabs:

```html
<link rel="icon" href="/favicon.ico" sizes="32x32">
<link rel="icon" href="/favicon.svg" type="image/svg+xml">
<link rel="apple-touch-icon" href="/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">
<link rel="mask-icon" href="/safari-pinned-tab.svg" color="#0b1220">
<meta name="apple-mobile-web-app-title" content="Example">
<meta name="application-name" content="Example">
<meta name="msapplication-TileColor" content="#0b1220">
<meta name="msapplication-config" content="/browserconfig.xml">
```

### Required files

| File | Size | Notes |
|------|------|-------|
| `/favicon.ico` | 32×32 (multi-res) | Legacy browsers, IE, fallback |
| `/favicon.svg` | scalable | Modern browsers; supports dark mode via `<style>` inside SVG |
| `/apple-touch-icon.png` | 180×180 | iOS home screen |
| `/icon-192.png`, `/icon-512.png` | 192, 512 | Referenced from the manifest |
| `/site.webmanifest` | JSON | PWA manifest |
| `/safari-pinned-tab.svg` | monochrome | Safari pinned tab |

### Minimal `site.webmanifest`

```json
{
  "name": "Example",
  "short_name": "Example",
  "icons": [
    { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ],
  "theme_color": "#0b1220",
  "background_color": "#ffffff",
  "display": "standalone",
  "start_url": "/"
}
```

---

## 12. Search engine and platform verification

These are issued by the platforms; copy the value they give you.

```html
<meta name="google-site-verification" content="...">
<meta name="msvalidate.01" content="...">          <!-- Bing -->
<meta name="yandex-verification" content="...">
<meta name="facebook-domain-verification" content="...">
<meta name="p:domain_verify" content="...">         <!-- Pinterest -->
```

Place verification meta on the homepage at minimum. Prefer DNS TXT verification when the platform offers it — it survives a homepage redesign.

---

## 13. AI / LLM crawler controls

LLM and AI-search crawlers are partially out of band from the standard `robots` meta. AI policy lives in two surfaces:

- **Meta tags** (per-bot, page-level) — covered here.
- **`robots.txt`** (per-bot, site-wide) + **`/.well-known/ai.txt`** + per-bot reference table + decision matrix — see **`crawl-control`** (AI bot recipes section).

Use both layers. Meta tags travel with cached HTML; `robots.txt` enforces at the crawler level.

### Per-bot meta tags

```html
<meta name="GPTBot" content="noindex,nofollow">
<meta name="ChatGPT-User" content="noindex,nofollow">
<meta name="OAI-SearchBot" content="noindex,nofollow">
<meta name="Google-Extended" content="noindex">
<meta name="ClaudeBot" content="noindex,nofollow">
<meta name="anthropic-ai" content="noindex,nofollow">
<meta name="PerplexityBot" content="noindex,nofollow">
<meta name="CCBot" content="noindex,nofollow">
<meta name="cohere-ai" content="noindex,nofollow">
<meta name="Bytespider" content="noindex,nofollow">
```

The **policy decision** (allow all / partial / block all) is documented in `crawl-control`. Apply the same decision in both layers — diverging meta and robots.txt produces ambiguous signals.

---

## 14. RSS, sitemaps, and feed discovery

```html
<link rel="alternate" type="application/rss+xml" title="Example — Articles" href="/rss.xml">
<link rel="alternate" type="application/atom+xml" title="Example — Atom" href="/atom.xml">
<link rel="alternate" type="application/json" title="Example — JSON Feed" href="/feed.json">
```

Sitemaps are referenced from `robots.txt`, not from `<head>`.

---

## 15. Per-page-type templates

### 15.1 Homepage

```html
<title>Example — Sub-200 ms web performance for content sites</title>
<meta name="description" content="Example helps content publishers ship sub-200 ms INP and pass Core Web Vitals on every page. Audits, monitoring, and concrete fixes for React, Vue, and Astro stacks.">

<link rel="canonical" href="https://example.com/">
<meta name="robots" content="index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1">

<meta property="og:type" content="website">
<meta property="og:title" content="Example — Sub-200 ms web performance for content sites">
<meta property="og:description" content="Audits, monitoring, and concrete fixes for Core Web Vitals.">
<meta property="og:url" content="https://example.com/">
<meta property="og:site_name" content="Example">
<meta property="og:locale" content="en_US">
<meta property="og:image" content="https://example.com/og/home.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:alt" content="Example — web performance audits">

<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:site" content="@example">
```

### 15.2 Article

```html
<title>What is INP? Core Web Vital thresholds and fixes — Example</title>
<meta name="description" content="INP measures how fast a page responds to clicks and taps. See the 200 ms threshold, common causes, and concrete fixes for React and Vue apps.">

<link rel="canonical" href="https://example.com/blog/inp-guide">

<meta name="robots" content="index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1">

<meta property="og:type" content="article">
<meta property="og:title" content="What is INP? Core Web Vital thresholds and fixes">
<meta property="og:description" content="The 200 ms threshold, common causes, and concrete fixes for React and Vue.">
<meta property="og:url" content="https://example.com/blog/inp-guide">
<meta property="og:site_name" content="Example">
<meta property="og:locale" content="en_US">
<meta property="og:image" content="https://example.com/og/inp-guide.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:alt" content="INP — the Core Web Vital that measures interaction responsiveness">

<meta property="article:published_time" content="2026-04-12T09:00:00Z">
<meta property="article:modified_time" content="2026-05-06T14:30:00Z">
<meta property="article:author" content="https://example.com/authors/jane-doe">
<meta property="article:section" content="Performance">
<meta property="article:tag" content="Core Web Vitals">
<meta property="article:tag" content="INP">

<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:site" content="@example">
<meta name="twitter:creator" content="@janedoe">
```

### 15.3 Product

```html
<title>Acme Pro Mouse — 240 Hz wireless ergonomic mouse | Example</title>
<meta name="description" content="The Acme Pro Mouse delivers 240 Hz polling, 95-hour battery, and a sculpted ergonomic shell. Free shipping, 30-day returns.">

<link rel="canonical" href="https://example.com/products/acme-pro-mouse">

<meta property="og:type" content="product">
<meta property="og:title" content="Acme Pro Mouse — 240 Hz wireless ergonomic mouse">
<meta property="og:description" content="240 Hz polling, 95-hour battery, ergonomic shell.">
<meta property="og:url" content="https://example.com/products/acme-pro-mouse">
<meta property="og:image" content="https://example.com/og/acme-pro-mouse.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="product:price:amount" content="129.00">
<meta property="product:price:currency" content="USD">
<meta property="product:availability" content="in stock">
```

Combine with `Product` JSON-LD (price, availability, ratings, GTIN). Meta tags alone are not enough for rich results on commerce.

### 15.4 Category / archive

```html
<title>Performance — Articles on Core Web Vitals and INP | Example</title>
<meta name="description" content="In-depth articles on Core Web Vitals, INP, LCP, CLS, and concrete fixes for content sites.">

<link rel="canonical" href="https://example.com/category/performance">
<meta name="robots" content="index,follow,max-image-preview:large">
```

For paginated archives, **self-canonical** each page.

### 15.5 Internal search results

```html
<title>Search results for "{query}" — Example</title>
<meta name="robots" content="noindex,follow">
<link rel="canonical" href="https://example.com/search?q={query-url-encoded}">
```

`noindex,follow` is the right call — don't pollute the index with thin search pages, but let crawlers walk to linked targets.

### 15.6 404

```html
<title>Page not found — Example</title>
<meta name="robots" content="noindex,follow">
```

The HTTP status must be 404, not 200. A "soft 404" (404 page returning 200) is the most common SEO hidden failure.

### 15.7 Author profile

```html
<title>Jane Doe — Senior Performance Engineer | Example</title>
<meta name="description" content="Articles by Jane Doe on Core Web Vitals, INP, and front-end performance for React and Vue applications.">

<link rel="canonical" href="https://example.com/authors/jane-doe">
<meta property="og:type" content="profile">
<meta property="profile:first_name" content="Jane">
<meta property="profile:last_name" content="Doe">
<meta property="profile:username" content="janedoe">
```

Combine with `Person` JSON-LD and `sameAs` links to LinkedIn, GitHub, ORCID.

---

## 16. Framework patterns

### 16.1 Astro — `src/components/SeoHead.astro`

```astro
---
interface Props {
  title: string;
  description: string;
  canonical: string;
  image?: string;
  type?: 'website' | 'article' | 'product' | 'profile';
  publishedTime?: string;
  modifiedTime?: string;
  author?: string;
  noindex?: boolean;
}

const {
  title,
  description,
  canonical,
  image = 'https://example.com/og/default.png',
  type = 'website',
  publishedTime,
  modifiedTime,
  author,
  noindex = false,
} = Astro.props;

const fullTitle = `${title} | Example`;
const robots = noindex
  ? 'noindex,follow'
  : 'index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1';
---

<title>{fullTitle}</title>
<meta name="description" content={description} />
<link rel="canonical" href={canonical} />
<meta name="robots" content={robots} />

<meta property="og:type" content={type} />
<meta property="og:title" content={title} />
<meta property="og:description" content={description} />
<meta property="og:url" content={canonical} />
<meta property="og:site_name" content="Example" />
<meta property="og:locale" content="en_US" />
<meta property="og:image" content={image} />
<meta property="og:image:width" content="1200" />
<meta property="og:image:height" content="630" />
<meta property="og:image:alt" content={title} />

{publishedTime && <meta property="article:published_time" content={publishedTime} />}
{modifiedTime && <meta property="article:modified_time" content={modifiedTime} />}
{author && <meta property="article:author" content={author} />}

<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:site" content="@example" />
<meta name="twitter:title" content={title} />
<meta name="twitter:description" content={description} />
<meta name="twitter:image" content={image} />
```

### 16.2 Nuxt 3 — `useSeoMeta`

```ts
useSeoMeta({
  title: () => `${article.title} | Example`,
  description: () => article.description,
  ogType: 'article',
  ogTitle: () => article.title,
  ogDescription: () => article.description,
  ogUrl: () => `https://example.com${route.path}`,
  ogImage: () => article.ogImage,
  ogImageWidth: 1200,
  ogImageHeight: 630,
  ogImageAlt: () => article.title,
  ogLocale: 'en_US',
  twitterCard: 'summary_large_image',
  twitterSite: '@example',
  twitterCreator: () => article.authorTwitter,
  articlePublishedTime: () => article.publishedAt,
  articleModifiedTime: () => article.updatedAt,
  articleAuthor: () => article.authorUrl,
  robots: 'index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1',
});

useHead({
  link: [
    { rel: 'canonical', href: `https://example.com${route.path}` },
  ],
});
```

### 16.3 Next.js (App Router) — `generateMetadata`

```ts
export async function generateMetadata({ params }): Promise<Metadata> {
  const article = await getArticle(params.slug);
  const url = `https://example.com/blog/${params.slug}`;

  return {
    title: `${article.title} | Example`,
    description: article.description,
    alternates: { canonical: url },
    robots: { index: true, follow: true, 'max-image-preview': 'large' },
    openGraph: {
      type: 'article',
      url,
      title: article.title,
      description: article.description,
      siteName: 'Example',
      locale: 'en_US',
      images: [{ url: article.ogImage, width: 1200, height: 630, alt: article.title }],
      publishedTime: article.publishedAt,
      modifiedTime: article.updatedAt,
      authors: [article.authorUrl],
    },
    twitter: {
      card: 'summary_large_image',
      site: '@example',
      creator: article.authorTwitter,
      title: article.title,
      description: article.description,
      images: [article.ogImage],
    },
  };
}
```

---

## 17. Anti-patterns — never ship

- ❌ Multiple `<title>` tags. Engines ignore all of them.
- ❌ Multiple canonicals. Same.
- ❌ Title length over 70 characters or under 20.
- ❌ Description over 200 characters or under 70.
- ❌ Description that is identical across pages (templated `Welcome to Example`).
- ❌ Canonical to a redirect chain. Canonical must point to the final 200 URL.
- ❌ Canonical with `http://` while the site serves `https://`.
- ❌ Canonical with tracking parameters (`?utm_*`, `?gclid`).
- ❌ `og:image` as relative URL. Unfurlers will not resolve it.
- ❌ `og:image` smaller than 600 × 315. LinkedIn drops them.
- ❌ `og:image` in WebP / AVIF. Unfurlers reject many of them.
- ❌ Missing `og:image:width` / `og:image:height` — some unfurlers won't fetch.
- ❌ `viewport` with `user-scalable=no`. Accessibility failure.
- ❌ `<meta name="keywords">`. Ignored by all major engines since 2009. Pure noise.
- ❌ `noindex` set globally and forgotten on a staging deploy that became prod.
- ❌ `noindex` plus canonical to the same URL — contradictory; engines pick the conservative one (drop).
- ❌ Hreflang cluster missing self-reference or reciprocal partner.
- ❌ Hreflang with invalid region (`en-UK` instead of `en-GB`).
- ❌ JSON-LD claiming facts not visible in the body.
- ❌ Mixing `og:type=article` on a homepage.
- ❌ Stale `article:modified_time` (newer than actual content edit).
- ❌ Title-cased emojis or unicode tricks for "🚀 standout 🚀" SERP appearance — Google strips them.
- ❌ `<title>` rendered client-side only (the bot reads the SSR'd HTML; ensure SSR/SSG renders the title).

---

## 18. Validation checklist

Run through every page type. Score each item; report findings with severity.

### Required minimum

- [ ] `<meta charset="utf-8">` present, first child of `<head>` (in the first 1024 bytes).
- [ ] `<meta name="viewport" content="width=device-width, initial-scale=1">` present.
- [ ] `<title>` present, unique, 50–60 chars.
- [ ] `<meta name="description">` present, unique, 140–160 chars.
- [ ] `<link rel="canonical">` present, absolute URL, self-canonical, matches rendered URL.
- [ ] `<meta name="robots">` set deliberately (default for indexable pages includes `max-image-preview:large`).

### Open Graph

- [ ] `og:type`, `og:title`, `og:description`, `og:url`, `og:site_name`, `og:locale` present.
- [ ] `og:image` present, absolute URL, 1200 × 630, PNG/JPG, ≤ 1 MB.
- [ ] `og:image:width`, `og:image:height`, `og:image:alt` present.
- [ ] For articles: `article:published_time`, `article:modified_time`, `article:author`.
- [ ] For products: `product:price:amount`, `product:price:currency`, `product:availability`.

### Twitter

- [ ] `twitter:card` present (`summary_large_image` for content).
- [ ] `twitter:site` present (publication account).
- [ ] `twitter:creator` present where there is a named author.

### Locale

- [ ] If multi-locale: every alternate `hreflang` URL listed including self.
- [ ] `x-default` present.
- [ ] No invalid region codes; reciprocal pairs verified.

### Browser / PWA

- [ ] `theme-color` per scheme.
- [ ] `color-scheme` matches the design system.
- [ ] Favicon set: `.ico`, `.svg`, `apple-touch-icon`, manifest.
- [ ] Manifest references real `192` and `512` PNGs.

### AI

- [ ] `robots.txt` decision documented (allow / partial / block AI bots).
- [ ] If blocking: per-bot `User-agent` blocks present in `robots.txt` AND meta tags.
- [ ] `ai.txt` aligned with `robots.txt`.

### Verification

- [ ] Search Console / Bing / etc verification meta on the homepage if used.

### Anti-patterns

- [ ] No duplicate `<title>` or `<canonical>`.
- [ ] No `keywords` meta.
- [ ] No `user-scalable=no` viewport.
- [ ] No relative `og:image` URLs.
- [ ] No staging `noindex` leaked to production.
- [ ] No mismatch between canonical and rendered URL.

Severity guide:

- `high` — missing title / description / canonical, broken canonical, `noindex` on prod, missing OG image, broken hreflang cluster, soft 404.
- `medium` — title or description outside length range, missing Twitter Card on articles, no `theme-color`, missing favicons, missing `og:image` dimensions.
- `low` — missing optional fields (`og:image:alt`, `article:section`), no verification tags, no AI policy yet.

---

## 19. Validation tools and commands

```bash
# Curl the rendered head
curl -sL https://example.com/page | sed -n '/<head/,/<\/head>/p'

# Check for required tags
curl -sL https://example.com/page | grep -E -o '<(title|meta|link)[^>]*>' | head -50

# Validate Open Graph (debugger)
# https://developers.facebook.com/tools/debug/?q=https://example.com/page

# Validate Twitter Card
# https://cards-dev.twitter.com/validator

# Validate LinkedIn unfurl
# https://www.linkedin.com/post-inspector/

# Validate hreflang cluster
# https://technicalseo.com/tools/hreflang/

# Validate canonical / robots / structured data
# https://search.google.com/test/rich-results
# https://search.google.com/search-console/

# Check that title and description survive SSR
curl -sL https://example.com/page | grep -E '<title>|name="description"'
```

After every meaningful template change, run at least the Facebook Sharing Debugger and Google Rich Results Test against the changed page type.

---

## 20. Output format when used as a generator

When asked to generate meta tags for a specific page, return:

1. A **JSON object** with all field values (so the caller can wire it through any framework).
2. A **rendered HTML block** ready to paste into `<head>`.
3. A short **rationale** noting any choices that depended on assumptions (e.g. "assumed `og:locale=en_US`; change to your primary locale").
4. **Open questions** for any field that needs the project's input (Twitter handle, OG image, verification IDs).

When asked to validate existing tags, return the validation checklist (section 18) marked up with findings and severity, plus a recommended fix order.
