---
description: SEO + GEO optimized HTML page structure — semantic landmarks, heading hierarchy, content order, lists, tables, figures, breadcrumbs, links, time/address elements, and the anti-patterns that hurt crawlers, AI engines, and assistive technology. Includes per-page-type skeletons and a validation checklist.
---

# SEO page structure — semantic HTML for search and generative engines

Goal: produce HTML that crawlers, AI retrievers, and assistive technology can parse without guessing. The same structural rules satisfy Googlebot, AI Overviews, Perplexity, ChatGPT Search, and screen readers — they all rely on landmarks, heading hierarchy, and source order to understand a page.

This skill is about the **document body**. It pairs with `meta-tags` (the `<head>`) and `geo-content` (the article copy itself).

---

## 1. The mental model

A search bot or LLM retriever does four things with a page:

1. **Parse the DOM** into a tree of landmarks (`header`, `nav`, `main`, `article`, `aside`, `footer`).
2. **Walk headings** to build an outline of the page's topics.
3. **Read content in source order**, not visual order. CSS reordering is invisible.
4. **Extract structured chunks** — lists, tables, figures, definitions, FAQs — as candidates for snippet extraction.

Three implications:

- A `<div>`-only document forces the bot to guess. It will guess badly.
- Visual order created with CSS Grid / Flex `order` does not change source order. Put the content the bot should read first **first in the markup**.
- Hidden content (`display:none`, behind tabs/accordions) is downweighted by Google and ignored by some AI retrievers. Critical content must be in the initial DOM.

---

## 2. The landmark skeleton

Every page should have exactly one of each top-level landmark, in this source order:

```html
<!doctype html>
<html lang="en">
  <head>...</head>
  <body>
    <a class="skip-link" href="#main">Skip to main content</a>

    <header role="banner">
      <a href="/" aria-label="Example — home">
        <img src="/logo.svg" alt="" width="120" height="32">
      </a>
      <nav aria-label="Primary">
        <ul>
          <li><a href="/products">Products</a></li>
          <li><a href="/pricing">Pricing</a></li>
          <li><a href="/blog">Blog</a></li>
        </ul>
      </nav>
    </header>

    <main id="main">
      <!-- The page's primary content lives here -->
    </main>

    <aside aria-label="Related">
      <!-- Optional: related articles, sidebar widgets -->
    </aside>

    <footer role="contentinfo">
      <nav aria-label="Footer">
        <ul>
          <li><a href="/about">About</a></li>
          <li><a href="/legal/privacy">Privacy</a></li>
          <li><a href="/legal/terms">Terms</a></li>
        </ul>
      </nav>
      <p>&copy; 2026 Example, Inc.</p>
    </footer>
  </body>
</html>
```

### Landmark rules

- **One `<main>` per page**. It is the unique anchor for "the page's primary content".
- **One `<header>` and one `<footer>` at the document level** (top-level header/footer). Section-level headers/footers are also allowed *inside* `<article>`/`<section>` and are unrelated to the document banner/contentinfo roles.
- **Every `<nav>` needs a label**. Multiple `<nav>` elements (primary, footer, breadcrumb, in-article TOC) must each have a unique `aria-label`. Without labels they collapse into one in the accessibility tree.
- **Skip link** to `#main` is the first focusable element in `<body>`.
- **`<aside>` is for tangential content**, not for "anything on the right side". Sidebars of unrelated promo content are not asides.

### HTML5 landmarks vs ARIA roles

Use HTML5 elements first; add ARIA only to fill gaps.

| Element | Implicit role | Add `role=` only if… |
|---------|---------------|----------------------|
| `<header>` (top-level) | `banner` | the element is a custom component |
| `<nav>` | `navigation` | never — already implicit |
| `<main>` | `main` | never |
| `<article>` | `article` | never |
| `<aside>` | `complementary` | never |
| `<footer>` (top-level) | `contentinfo` | the element is a custom component |
| `<section>` (with accessible name) | `region` | never |

Never write `<div role="main">` when you can write `<main>`.

---

## 3. Heading hierarchy

Headings are how engines build a page's outline. A clean hierarchy directly improves snippet extraction.

### Rules

- **Exactly one visible `<h1>` per page**, matching the page's primary topic.
- **Don't skip levels** going down. `H1 → H2 → H3` is correct; `H1 → H3` is broken.
- **You may skip levels going back up**. `H3 → H2` is fine when starting a new section.
- **Headings reflect document structure, not visual size**. Don't choose a heading level for its default font size — use CSS for styling.
- **Each `<section>` and `<article>` should have its own heading** as its first child. A section without a heading is invisible in the outline.
- **No empty headings**. `<h2></h2>` breaks outlining tools.
- **Headings are not decoration**. Don't wrap pull quotes, eyebrows, or marketing taglines in `<h2>` because they look big.
- **The H1 should not be the site logo**. The logo is in the `<header>` banner; the H1 is the page topic.

### Outline pattern for an article

```html
<main id="main">
  <article>
    <header>
      <h1>What is INP and how do I optimize it?</h1>
      <p class="byline">
        By <a rel="author" href="/authors/jane-doe">Jane Doe</a> ·
        <time datetime="2026-04-12">April 12, 2026</time> ·
        Last reviewed <time datetime="2026-05-06">May 6, 2026</time>
      </p>
    </header>

    <p class="lead">Direct-answer paragraph (40–80 words)…</p>

    <section aria-labelledby="what-is-inp">
      <h2 id="what-is-inp">What is INP?</h2>
      <p>…</p>
    </section>

    <section aria-labelledby="thresholds">
      <h2 id="thresholds">What is a good INP score?</h2>
      <p>…</p>

      <section aria-labelledby="thresholds-mobile">
        <h3 id="thresholds-mobile">On mobile</h3>
        <p>…</p>
      </section>

      <section aria-labelledby="thresholds-desktop">
        <h3 id="thresholds-desktop">On desktop</h3>
        <p>…</p>
      </section>
    </section>

    <section aria-labelledby="faq">
      <h2 id="faq">FAQ</h2>

      <section aria-labelledby="faq-1">
        <h3 id="faq-1">Does INP replace First Input Delay?</h3>
        <p>…</p>
      </section>
    </section>

    <footer>
      <h2>About the author</h2>
      <p>Jane Doe is a Senior Performance Engineer…</p>
    </footer>
  </article>
</main>
```

`aria-labelledby` connects each `<section>` to its heading; combined with the heading itself, it produces an accessible name for the region. Anchor IDs on headings double as deep-link targets.

---

## 4. Content order in source

Crawlers and assistive tech read source order. Visual reordering with CSS is irrelevant to them.

### Rules

- **Most important content first** in the source. The H1 and direct-answer paragraph live in the first 200 lines of body markup.
- **Don't put primary content after a sidebar in source.** Use CSS Grid to swap visually.
- **Above-the-fold ≠ first in source automatically.** Verify by viewing the unstyled DOM (`view-source:` or DevTools "Disable styles").
- **Long lists and footnotes go after** the article body — never before.
- **Cookie banners, modals, and announcement bars** should be appended to the end of `<body>` or via portals, not injected at the top of source.

### Bad

```html
<main>
  <aside>...sidebar...</aside>
  <article>...the actual article...</article>
</main>
```

### Good

```html
<main>
  <article>...the actual article...</article>
  <aside>...sidebar...</aside>
</main>

<style>
  main { display: grid; grid-template-columns: 1fr 280px; }
  aside { grid-column: 2; grid-row: 1; }
</style>
```

---

## 5. Article structure

The `<article>` element marks self-contained, syndicatable content. Every blog post, news piece, product description, and FAQ entry should sit inside one.

```html
<article itemscope itemtype="https://schema.org/Article">
  <header>
    <h1 itemprop="headline">…</h1>
    <p>
      By <a rel="author" itemprop="author" href="/authors/jane-doe">Jane Doe</a> ·
      Published <time itemprop="datePublished" datetime="2026-04-12T09:00:00Z">April 12, 2026</time> ·
      Updated <time itemprop="dateModified" datetime="2026-05-06T14:30:00Z">May 6, 2026</time>
    </p>
  </header>

  <p itemprop="description" class="lead">…</p>

  <!-- sections with H2 question-headings -->

  <footer>
    <p>Tags:
      <a href="/tags/inp" rel="tag">INP</a>,
      <a href="/tags/core-web-vitals" rel="tag">Core Web Vitals</a>
    </p>
  </footer>
</article>
```

Notes:

- `itemprop`/`itemtype` (microdata) is optional when you ship JSON-LD. Pick one source of truth — duplicating in both is fine but contradictions are penalized.
- `rel="author"` on the byline link, `rel="tag"` on tag links — these are documented relationships engines use.
- `<time datetime="…">` — always include the machine-readable attribute. Date in the attribute must be ISO 8601 (`YYYY-MM-DD` or full timestamp).

---

## 6. Lists — `<ul>`, `<ol>`, `<dl>`

Lists are one of the most extracted block types in AI Overviews. Use the right element and engines will lift the list verbatim.

### Rules

- **`<ul>`** for unordered items.
- **`<ol>`** for sequence-dependent items (steps, ranked lists, recipes).
- **`<dl>`** for term/definition pairs — glossaries, spec sheets, key/value data.
- **One concept per list item.** Don't pack multiple sentences with multiple ideas into one `<li>`.
- **Don't fake lists with `<br>` or `•` characters.** Engines see flowing text.
- **Don't fake lists with `<div>` siblings.** Use `<ul>` / `<ol>`.

### Definition list example

```html
<dl>
  <dt>LCP (Largest Contentful Paint)</dt>
  <dd>Time from navigation start to render of the largest visible element. Good: ≤ 2.5 s.</dd>

  <dt>INP (Interaction to Next Paint)</dt>
  <dd>How quickly the page responds to user input. Good: ≤ 200 ms at the 75th percentile.</dd>

  <dt>CLS (Cumulative Layout Shift)</dt>
  <dd>Sum of unexpected layout shifts during a page's lifetime. Good: ≤ 0.1.</dd>
</dl>
```

### Step list example

```html
<ol>
  <li>Install the CLI: <code>pnpm add -D @lhci/cli</code>.</li>
  <li>Create <code>lighthouserc.cjs</code> at the repo root.</li>
  <li>Add <code>pnpm lhci autorun</code> to the CI workflow.</li>
  <li>Set assertion thresholds to fail builds below the budget.</li>
</ol>
```

---

## 7. Tables

Tables are extracted whole by AI Overviews and are excellent for comparisons.

### Rules

- **Tabular data only.** Never use `<table>` for layout.
- **Use `<thead>`, `<tbody>`, `<tfoot>`** to mark structural regions.
- **`<th scope="col">`** on column headers; **`<th scope="row">`** on row headers.
- **`<caption>`** as the first child of `<table>` — it's the table's name in the accessibility tree and is read by engines.
- **Avoid `colspan` / `rowspan`** for the rows engines will extract; they confuse retrieval.
- **Keep cells short.** Long prose belongs outside the table.
- **No nested tables.**

### Example

```html
<table>
  <caption>Core Web Vitals — field thresholds at the 75th percentile</caption>
  <thead>
    <tr>
      <th scope="col">Metric</th>
      <th scope="col">Good</th>
      <th scope="col">Needs improvement</th>
      <th scope="col">Poor</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">LCP</th>
      <td>≤ 2.5 s</td>
      <td>2.5 – 4.0 s</td>
      <td>&gt; 4.0 s</td>
    </tr>
    <tr>
      <th scope="row">INP</th>
      <td>≤ 200 ms</td>
      <td>200 – 500 ms</td>
      <td>&gt; 500 ms</td>
    </tr>
    <tr>
      <th scope="row">CLS</th>
      <td>≤ 0.1</td>
      <td>0.1 – 0.25</td>
      <td>&gt; 0.25</td>
    </tr>
  </tbody>
</table>
```

---

## 8. Figures, images, media

This section covers the **structural** rules — semantics and accessibility. For format choice (AVIF/WebP/JPEG), responsive `srcset`/`sizes`, `<picture>` patterns, `fetchpriority`, eager/lazy rules, compression targets, and OG image specs, see **`image-optimization`**.

### Structural rules

- **`alt` is required on every `<img>`.** Use `alt=""` (empty) for decorative images, never omit the attribute.
- **`alt` describes the image's purpose, not its appearance.** "Architecture diagram showing X feeding Y" beats "diagram with arrows".
- **`<figure>` + `<figcaption>`** for any image that needs explanatory text. The caption is associated with the image in the accessibility tree.
- **Decorative images go in CSS as `background-image`**; meaningful images go in HTML as `<img>`. Engines extract `<img>`, not CSS backgrounds.
- **SVG with text content** should expose the text either inline (preferred) or via `<title>` / `<desc>` children, with `role="img"` on the `<svg>`.
- **Don't put critical text only inside an image.** Body text first, image as supporting.

```html
<figure>
  <img src="/images/inp-flame-chart.webp"
       alt="Flame chart showing a 380 ms long task during click handling"
       width="1200" height="630">
  <figcaption>Long-task profile of a slow click handler before optimization.</figcaption>
</figure>
```

### Video and audio

```html
<figure>
  <video controls preload="metadata" poster="/videos/inp.jpg" width="1280" height="720">
    <source src="/videos/inp.mp4" type="video/mp4">
    <source src="/videos/inp.webm" type="video/webm">
    <track kind="captions" src="/videos/inp.en.vtt" srclang="en" label="English" default>
    <p>Your browser does not support HTML5 video. <a href="/videos/inp.mp4">Download the MP4</a>.</p>
  </video>
  <figcaption>Demonstration of slow INP on a real-world button click.</figcaption>
</figure>
```

Add `VideoObject` JSON-LD with `name`, `description`, `thumbnailUrl`, `uploadDate`, `duration`, and `transcript` URL.

---

## 9. Links and internal navigation

This section covers the **markup-level** link rules — anchor element, `rel` attributes, JS-link anti-patterns. For link strategy (anchor variety, hub-and-spoke architecture, related-content blocks, orphan detection, link equity) see **`internal-linking`**.

### Anchor element rules

- **Use `<a href>` for navigation.** `<div onclick>` and `<button>` cannot be crawled.
- **Descriptive anchor text.** "INP optimization guide" beats "click here", "read more", "this article".
- **No JavaScript-only links.** `href="javascript:void(0)"`, `<a href="#" onclick>` are uncrawlable.
- **Same-page anchors** use `id` targets, not `name=`. `<a href="#section-id">…</a>`.

### `rel` attributes

| `rel` | Purpose |
|-------|---------|
| `noopener` | Required on `target="_blank"` (security) |
| `nofollow` | Untrusted links |
| `ugc` | User-generated content |
| `sponsored` | Paid / affiliate |
| `external` | Cross-origin (optional) |
| `author` | Byline link to author profile |
| `tag` | Tag links from an article |

### Bad

```html
<p>For more on this topic, <a href="/inp-guide">click here</a>.</p>
<a href="javascript:void(0)" onclick="navigate()">Go</a>
<div onclick="open()">Read more</div>
```

### Good

```html
<p>For details on the 200 ms threshold, see the
   <a href="/blog/inp-guide">INP optimization guide</a>.</p>
```

---

## 10. Breadcrumbs

Breadcrumbs help engines understand site hierarchy and are surfaced in SERPs.

```html
<nav aria-label="Breadcrumb">
  <ol itemscope itemtype="https://schema.org/BreadcrumbList">
    <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
      <a itemprop="item" href="/"><span itemprop="name">Home</span></a>
      <meta itemprop="position" content="1">
    </li>
    <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
      <a itemprop="item" href="/blog"><span itemprop="name">Blog</span></a>
      <meta itemprop="position" content="2">
    </li>
    <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
      <span itemprop="name" aria-current="page">What is INP?</span>
      <meta itemprop="position" content="3">
    </li>
  </ol>
</nav>
```

### Rules

- **`<nav aria-label="Breadcrumb">`** wraps the `<ol>`.
- **`<ol>`** is required (breadcrumbs are sequence-dependent).
- **Last item is the current page**, not linked, marked `aria-current="page"`.
- **Mirror the URL hierarchy**: each crumb's URL is a prefix of the current URL.
- **Add `BreadcrumbList` JSON-LD** in addition to (or instead of) inline microdata.

---

## 11. Forms

Forms are not a major SEO surface but they affect a11y scoring (which Google now weights) and AI assistants surfacing form actions.

### Rules

- **Every input has a real `<label>`** with `for` matching the input's `id`. Placeholders are not labels.
- **`<fieldset>` + `<legend>`** group related fields (radio groups, address blocks).
- **`<button type="submit">`** for submit. `<button type="button">` for everything else. Default is `submit` — explicit is safer.
- **`autocomplete` attributes** on every applicable field (`name`, `email`, `street-address`, `cc-number`).
- **`<form>` element** wraps inputs, even single-input forms — engines and browsers detect form intent.
- **Errors associated** via `aria-describedby` pointing at the error message ID; `aria-invalid="true"` on the failing field.

### Example

```html
<form action="/newsletter" method="post">
  <fieldset>
    <legend>Subscribe to the newsletter</legend>
    <p>
      <label for="email">Email address</label>
      <input
        id="email"
        name="email"
        type="email"
        required
        autocomplete="email"
        aria-describedby="email-help">
      <span id="email-help">We send one email per month.</span>
    </p>
    <button type="submit">Subscribe</button>
  </fieldset>
</form>
```

---

## 12. Time, addresses, contact info

### `<time>`

Every visible date must be wrapped in `<time>` with a machine-readable `datetime` attribute. Engines extract these for `datePublished`, `dateModified`, event dates, deadlines, etc.

```html
Published <time datetime="2026-04-12T09:00:00Z">April 12, 2026</time>
```

### `<address>`

The contact info **for the author of the nearest `<article>` or for the site overall (when in `<footer>`)**. Don't use it for any random street address.

```html
<address>
  Written by <a rel="author" href="/authors/jane-doe">Jane Doe</a>.
  Email <a href="mailto:jane@example.com">jane@example.com</a>.
</address>
```

For physical business addresses, use `Organization` / `LocalBusiness` JSON-LD instead.

### Contact links

```html
<a href="mailto:hello@example.com">hello@example.com</a>
<a href="tel:+1-555-123-4567">+1 (555) 123-4567</a>
```

`tel:` links use the international format with country code.

---

## 13. Per-page-type skeletons

### 13.1 Article page

```html
<body>
  <a class="skip-link" href="#main">Skip to main content</a>
  <header>...</header>

  <main id="main">
    <nav aria-label="Breadcrumb">...</nav>

    <article>
      <header>
        <h1>Page-specific topic phrased as the user's question</h1>
        <p class="byline">By <a rel="author" href="/authors/jane">Jane Doe</a> · <time datetime="2026-04-12">April 12, 2026</time></p>
      </header>

      <p class="lead">Direct-answer paragraph (40–80 words).</p>

      <section aria-labelledby="s1"><h2 id="s1">What is X?</h2>...</section>
      <section aria-labelledby="s2"><h2 id="s2">How does X work?</h2>...</section>
      <section aria-labelledby="s3"><h2 id="s3">When should I use X?</h2>...</section>
      <section aria-labelledby="faq"><h2 id="faq">FAQ</h2>...</section>

      <footer>
        <h2>About the author</h2>
        <address>...</address>
      </footer>
    </article>
  </main>

  <aside aria-label="Related articles">
    <h2>Related articles</h2>
    <ul>...</ul>
  </aside>

  <footer>...</footer>
</body>
```

### 13.2 Product page

```html
<main id="main">
  <nav aria-label="Breadcrumb">...</nav>

  <article itemscope itemtype="https://schema.org/Product">
    <h1 itemprop="name">Acme Pro Mouse</h1>

    <figure>
      <img itemprop="image" src="..." alt="..." width="1200" height="900">
    </figure>

    <p itemprop="description">…</p>

    <div itemprop="offers" itemscope itemtype="https://schema.org/Offer">
      <p>
        <span itemprop="priceCurrency" content="USD">$</span><span itemprop="price">129.00</span>
        <link itemprop="availability" href="https://schema.org/InStock">
      </p>
      <button type="button">Add to cart</button>
    </div>

    <section aria-labelledby="specs">
      <h2 id="specs">Specifications</h2>
      <table>...</table>
    </section>

    <section aria-labelledby="reviews">
      <h2 id="reviews">Reviews</h2>
      ...
    </section>
  </article>
</main>
```

### 13.3 Category / archive page

```html
<main id="main">
  <nav aria-label="Breadcrumb">...</nav>

  <header>
    <h1>Articles on Core Web Vitals</h1>
    <p>Short descriptive intro — what this archive is.</p>
  </header>

  <ol class="article-list">
    <li>
      <article>
        <h2><a href="/blog/inp-guide">What is INP?</a></h2>
        <p><time datetime="2026-04-12">April 12, 2026</time> · 8 min read</p>
        <p>Excerpt…</p>
      </article>
    </li>
    <!-- … -->
  </ol>

  <nav aria-label="Pagination">
    <a rel="prev" href="/category/perf?page=1">Previous</a>
    <a rel="next" href="/category/perf?page=3">Next</a>
  </nav>
</main>
```

Use `<ol>` for the article list — search results are sequence-dependent (relevance-ranked) even if visually unordered.

### 13.4 Home page

```html
<main id="main">
  <h1>One-line value proposition for the site</h1>

  <section aria-labelledby="features">
    <h2 id="features">What we do</h2>
    <ul>...</ul>
  </section>

  <section aria-labelledby="latest">
    <h2 id="latest">Latest articles</h2>
    <ol>...</ol>
  </section>

  <section aria-labelledby="cta">
    <h2 id="cta">Get started</h2>
    <p>...</p>
    <a href="/signup">Create an account</a>
  </section>
</main>
```

### 13.5 404 page

```html
<main id="main">
  <h1>Page not found</h1>
  <p>The page you requested no longer exists. Try one of these:</p>
  <ul>
    <li><a href="/">Home</a></li>
    <li><a href="/blog">Blog</a></li>
    <li><a href="/sitemap.xml">Sitemap</a></li>
  </ul>
  <form action="/search" method="get" role="search">
    <label for="q">Search</label>
    <input id="q" name="q" type="search">
    <button type="submit">Go</button>
  </form>
</main>
```

The HTTP status must be 404.

---

## 14. Anti-patterns — never ship

- ❌ `<div>` soup with no landmarks.
- ❌ Multiple `<h1>` elements per page.
- ❌ Missing `<h1>` (logo wrapped in `<h1>` doesn't count — that's not the page topic).
- ❌ Skipping heading levels going down (`H1 → H3`).
- ❌ Choosing heading level for visual size instead of structure.
- ❌ Using `<h2>` for pull quotes, eyebrows, or marketing copy.
- ❌ Empty headings (`<h2></h2>`) for spacing.
- ❌ `<nav>` without `aria-label` when there are multiple navs.
- ❌ More than one `<main>` per page.
- ❌ Putting the H1 below a sidebar in source order.
- ❌ Critical content hidden in tabs/accordions that require interaction to reveal (Google downweights it; some AI retrievers ignore it).
- ❌ Critical content rendered only client-side. The bot reads SSR'd HTML; CSR-only content may not be indexed.
- ❌ Lists faked with `<br>`, `•`, or sibling `<div>`s.
- ❌ Tables for layout.
- ❌ Tables without `<thead>` / `<th scope>`.
- ❌ Images without `alt` (use `alt=""` for decorative — never omit).
- ❌ Critical body text trapped inside an image.
- ❌ `<div onclick>` masquerading as a button.
- ❌ `<a href="#">` or `<a href="javascript:void(0)">` for actions — use `<button>`.
- ❌ Anchor text that is "click here", "read more", "this".
- ❌ Skip link missing or not the first focusable element.
- ❌ Duplicate IDs anywhere on the page.
- ❌ Iframes with no `title`.
- ❌ Removing focus outlines without replacement.
- ❌ `tabindex` values greater than 0.
- ❌ Auto-playing videos with sound.
- ❌ Cookie banners injected at the **top** of source — push critical content down in the DOM.
- ❌ Modals rendered inside `<main>` rather than at the end of `<body>` or via a portal.
- ❌ Same-page links using `name=` instead of `id=`.
- ❌ Breadcrumbs as a `<ul>` instead of `<ol>`.
- ❌ `<address>` used for any street address (it's for the article/site author).

---

## 15. Validation checklist

Use when auditing an existing page. Score each item; report findings with severity (`high` / `medium` / `low`).

### Landmarks

- [ ] Exactly one `<main>`.
- [ ] One top-level `<header>` and one top-level `<footer>`.
- [ ] Every `<nav>` has a unique `aria-label`.
- [ ] Skip link is the first focusable element and points to `#main`.
- [ ] No fake landmarks (`<div role="main">` instead of `<main>`).

### Headings

- [ ] Exactly one visible `<h1>` matching the page topic.
- [ ] No skipped levels going down.
- [ ] Each `<section>` and `<article>` has its own heading as first child.
- [ ] No empty headings.
- [ ] No `<h2>` used for decoration / pull quotes / eyebrows.

### Source order

- [ ] H1 and direct-answer content are within the first 200 lines of body markup.
- [ ] Sidebars / asides come after primary content in source.
- [ ] Cookie banners and modals are not at the top of source.
- [ ] Critical content rendered server-side, not only client-side.

### Lists and tables

- [ ] Sequence-dependent lists use `<ol>`.
- [ ] No fake lists with `<br>` or sibling `<div>`s.
- [ ] Tables have `<thead>`, `<tbody>`, `<th scope>`, `<caption>`.
- [ ] No tables for layout.
- [ ] Glossaries / spec sheets use `<dl>`.

### Media

- [ ] Every `<img>` has `alt` (empty for decorative).
- [ ] Every `<img>` has `width` and `height`.
- [ ] Decorative images use CSS backgrounds; meaningful images use `<img>`.
- [ ] `<figure>` + `<figcaption>` for images that need explanatory text.
- [ ] Videos have `<track kind="captions">` and a poster.

### Links

- [ ] Anchor text describes destination; no "click here".
- [ ] No `<div onclick>` masquerading as buttons / links.
- [ ] `target="_blank"` paired with `rel="noopener"`.
- [ ] User-generated and sponsored links use `rel="ugc"` / `rel="sponsored"`.
- [ ] Internal links to 3–8 related articles per detail page.

### Article + dates

- [ ] Article wrapped in `<article>`.
- [ ] Byline visible with author name and link to profile.
- [ ] `<time datetime="…">` on every visible date.
- [ ] `dateModified` matches the most recent meaningful edit.

### Breadcrumbs

- [ ] Present on every non-home page.
- [ ] `<nav aria-label="Breadcrumb">` wrapping `<ol>`.
- [ ] Last item is current page, not linked, `aria-current="page"`.
- [ ] Matches URL hierarchy.

### Forms

- [ ] Every input has a real `<label>`.
- [ ] `<button type="submit">` and `type="button">` set explicitly.
- [ ] `autocomplete` attributes on common fields.
- [ ] Errors associated via `aria-describedby` and `aria-invalid`.

### Anti-patterns absent

- [ ] No multiple H1s.
- [ ] No `<div>` soup.
- [ ] No critical content in image-only form.
- [ ] No `tabindex > 0`.
- [ ] No duplicate IDs.
- [ ] No iframes without `title`.

### Severity guide

- `high` — missing `<main>`, multiple H1s or no H1, skipped heading levels, critical content client-only, breadcrumb missing on detail pages, `<div>`-soup with no landmarks.
- `medium` — `<nav>` without label, sidebars before content in source, tables for layout, list faked with `<br>`, missing alt text, generic anchor text.
- `low` — missing `<figcaption>` where helpful, missing `rel` attributes on byline/tags, single-nav pages without `aria-label`, missing `BreadcrumbList` JSON-LD when inline microdata is present.

---

## 16. Validation tools and commands

```bash
# Dump rendered DOM and inspect landmarks
curl -sL https://example.com/page | grep -E -o '<(header|nav|main|article|aside|footer|section|h[1-6])[^>]*>' | head -40

# Count H1s — must be 1
curl -sL https://example.com/page | grep -c '<h1'

# Check for skip link
curl -sL https://example.com/page | grep -i 'skip-link\|skip to'

# Inspect heading outline
# Use the HTML5 Outliner extension or `axe DevTools`

# Validate semantic structure
# https://wave.webaim.org/
# https://validator.w3.org/nu/

# Verify breadcrumbs
# https://search.google.com/test/rich-results

# Check for client-only critical content
# Disable JavaScript in DevTools and reload — H1 and lead must still be there

# Check source vs visual order
# DevTools → Rendering → Disable styles → reload
```

After a layout change, always run: H1 count, heading outline, JS-disabled load, and Rich Results Test for the affected page type.

---

## 17. Output format

When asked to **generate** a page skeleton, return:

1. A complete `<body>` markup matching one of the section 13 templates.
2. A short rationale for non-obvious choices (e.g. "used `<ol>` for the article list because it is relevance-ranked").
3. Open questions for any field that needs project input (author URL, breadcrumb labels, related links).

When asked to **validate** existing markup, return:

```text
# Page Structure Audit — <URL or file path>

## Summary
- Landmarks: <pass/fail>
- Heading hierarchy: <H1 count, skipped levels>
- Source order: <H1 within first 200 lines: yes/no>
- Lists/tables: <semantic: yes/no>
- Media: <alt coverage %>
- Links: <generic anchor count>
- Anti-patterns flagged: <count>
- Overall: <PASS | NEEDS WORK | FAIL>

## Findings
**[HIGH]** <selector or line> — <issue> — <recommended fix>
**[MEDIUM]** ...
**[LOW]** ...

## Recommended fix order
1. ...
```

Then offer to apply each fix. Apply approved fixes one at a time, confirming each.
