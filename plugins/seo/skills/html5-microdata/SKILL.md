---
description: HTML5 Microdata for inline structured data — itemscope, itemtype, itemprop, itemid, itemref, value-extraction rules, Schema.org vocabulary, nested entities, type-by-type recipes (Article, Product, Organization, Person, BreadcrumbList, Recipe, Event, FAQPage, LocalBusiness), JSON-LD vs Microdata trade-offs, common conflicts and mismatches, validation tools, anti-patterns, and a complete validation checklist.
---

# HTML5 Microdata — inline structured data done right

HTML5 Microdata is a WHATWG-specified way to embed machine-readable data **directly inside visible HTML** using a small set of attributes. It is parsed by Google, Bing, Yandex, social unfurlers, and many AI retrievers. Compared to JSON-LD (a separate `<script>` block, covered in **`structured-data-jsonld`**), Microdata's appeal is that the structured data lives next to the rendered content — there is no second source of truth that can drift.

This skill covers when to choose Microdata, the full attribute set, how property values are extracted, type-specific recipes, the conflicts that silently invalidate markup, and a validation checklist for auditing existing pages. Every type recipe here has a JSON-LD equivalent in **`structured-data-jsonld`** — the choice is format, not content.

---

## 1. When to use Microdata vs JSON-LD

Both are valid; both are accepted by Google. The default for new projects is **JSON-LD**, but Microdata has real strengths and the choice should be deliberate.

| Criterion | Microdata | JSON-LD |
|-----------|-----------|---------|
| Google support | ✅ Supported | ✅ Preferred |
| Source of truth | Single — same DOM as rendered content | Separate `<script>` block |
| Drift risk | Low — facts are wired to visible elements | High — JSON can lag behind UI changes |
| SPA / hydration risk | Higher — markup must SSR with attributes intact | Lower — can be a static script tag |
| Verbosity for nested entities | Higher — deep nesting balloons attribute counts | Lower — nested objects are concise |
| Editor / CMS authoring | Easier when the CMS owns templates | Easier when an SEO module owns it centrally |
| Visual / DOM coupling | Tight — refactors break it | None — survives DOM refactors |

### Choose Microdata when

- The CMS or template already uses it and rewriting to JSON-LD is out of scope.
- The structured facts are simple and live alongside the visible elements (Article header, Product offer, Breadcrumb).
- You want one source of truth so the "Price: $39.99" the user sees is literally the value Google reads.
- You can't inject `<script>` into the rendered output (some embed contexts, restricted CMSs).

### Choose JSON-LD when

- You're starting a new project and the templates are yours.
- You need deeply nested entities (recipes, events with offers, products with variants and reviews).
- You ship a SPA where DOM nodes mount/unmount and consistent attribute coverage is fragile.
- Multiple teams own different parts of the page and a centralized SEO module is cleaner than touching every component.

### Don't ship both with conflicting data

Both formats together is allowed and sometimes useful (Microdata for the visible Article, JSON-LD for the rich FAQ that doesn't fit neatly inline). But **the facts must agree**. Google has explicitly warned that conflicting structured data can disqualify a page from rich results. Pick one as the authoritative source per fact.

---

## 2. The five attributes

All five can be applied to any HTML element.

| Attribute | Purpose | Notes |
|-----------|---------|-------|
| `itemscope` | Marks the element as describing one item | Boundary of an item; descendant `itemprop`s belong to it |
| `itemtype` | Vocabulary URL for the item (Schema.org) | Required to be paired with `itemscope`. Use `https://` |
| `itemprop` | Names a property of the enclosing item | One element can carry multiple props: `itemprop="name url"` |
| `itemid` | Globally unique identifier for the item | Only valid with `itemscope` + `itemtype`. URL form preferred |
| `itemref` | Pulls properties from elements outside the scope by `id` | Space-separated list of IDs |

### Example skeleton

```html
<article itemscope itemtype="https://schema.org/Article" itemid="https://example.com/blog/inp-guide">
  <h1 itemprop="headline">What is INP and how do I optimize it?</h1>
  <p>By <span itemprop="author">Jane Doe</span></p>
</article>
```

---

## 3. How values are extracted

Microdata reads the value from the element it sits on, not from a separate attribute you choose. The element type drives what's read.

| Element | Value source |
|---------|--------------|
| Most elements (`span`, `div`, `p`, `h1`, …) | Inner text content |
| `<a>`, `<area>`, `<link>` | `href` attribute (resolved to absolute URL) |
| `<img>`, `<audio>`, `<source>`, `<track>`, `<video>`, `<embed>`, `<iframe>` | `src` (resolved) |
| `<object>` | `data` |
| `<time>` | `datetime` (or text fallback if `datetime` is absent) |
| `<meta>` | `content` |
| `<data>` | `value` |

### Practical implications

**Use the element that carries the right attribute** so the visible text and the extracted value agree:

```html
<!-- Good: time element exposes a machine-readable date -->
Published <time itemprop="datePublished" datetime="2026-04-12T09:00:00Z">April 12, 2026</time>

<!-- Bad: span loses the ISO date entirely -->
Published <span itemprop="datePublished">April 12, 2026</span>
```

```html
<!-- Good: link href is read directly -->
<a itemprop="url" href="https://example.com/blog/inp-guide">Read the article</a>

<!-- Bad: span reads the visible text "https://..." which may be truncated -->
<span itemprop="url">https://example.com/blog/inp-guide</span>
```

### `<meta>` for invisible machine-readable values

When the visible text is human-friendly but the structured value needs a different form, use `<meta itemprop="…" content="…">`:

```html
<div itemscope itemtype="https://schema.org/AggregateRating">
  Rated <span itemprop="ratingValue">4.7</span> out of 5
  by <span itemprop="reviewCount">312</span> readers
  <meta itemprop="bestRating" content="5">
  <meta itemprop="worstRating" content="1">
</div>
```

`<meta>` inside body is allowed by the Microdata spec, even though it's normally a `<head>` element.

### `<link>` for invisible URL values

```html
<div itemprop="offers" itemscope itemtype="https://schema.org/Offer">
  <span itemprop="price">39.99</span>
  <span itemprop="priceCurrency" content="USD">USD</span>
  <link itemprop="availability" href="https://schema.org/InStock">
  <link itemprop="url" href="https://example.com/products/acme-mouse">
</div>
```

`<link itemprop="availability" href="https://schema.org/InStock">` is the standard pattern for enum values that aren't visible to readers.

---

## 4. Schema.org vocabulary basics

`itemtype` points at a Schema.org type URL. Use `https://schema.org/<Type>` (Schema.org redirects HTTP to HTTPS but consumers are happier with HTTPS directly).

Every type has a fixed set of expected properties documented at its page (e.g. `https://schema.org/Article`). Properties not in the type are silently ignored by Google. Required vs recommended varies by **rich-result feature** rather than by the type itself — Google's Rich Results gallery is the authoritative checklist per feature (Article, Product, Recipe, etc.).

### Multiple itemtypes (rare)

A single item can declare multiple types, space-separated. Useful for dual-natured entities:

```html
<article itemscope itemtype="https://schema.org/Article https://schema.org/NewsArticle">
  ...
</article>
```

In practice, pick the most specific single type. Multiple types confuse some consumers.

---

## 5. Nested items

Items nest by adding `itemscope` (and usually `itemtype`) to a child element that is also an `itemprop` of the parent.

```html
<article itemscope itemtype="https://schema.org/Article">
  <h1 itemprop="headline">What is INP?</h1>

  <div itemprop="author" itemscope itemtype="https://schema.org/Person">
    <span itemprop="name">Jane Doe</span>
    <link itemprop="url" href="https://example.com/authors/jane-doe">
    <link itemprop="sameAs" href="https://www.linkedin.com/in/janedoe">
    <link itemprop="sameAs" href="https://github.com/janedoe">
  </div>

  <div itemprop="publisher" itemscope itemtype="https://schema.org/Organization">
    <span itemprop="name">Example</span>
    <div itemprop="logo" itemscope itemtype="https://schema.org/ImageObject">
      <link itemprop="url" href="https://example.com/logo.png">
      <meta itemprop="width" content="600">
      <meta itemprop="height" content="60">
    </div>
  </div>
</article>
```

### Nesting rules

- A nested item is both a property of its parent (`itemprop="author"`) **and** an item in its own right (`itemscope itemtype="https://schema.org/Person"`).
- Properties of the nested item belong to it, not to the parent.
- Nesting can go many levels deep. Keep it shallow when possible — verbosity grows fast.

---

## 6. `itemref` — when content lives outside the scope

`itemref` lets an item pull in `itemprop`s from elsewhere in the DOM by element `id`. Use it when the layout forces split content (a sidebar with the price, a footer with the author).

```html
<article itemscope itemtype="https://schema.org/Article" itemref="byline tags">
  <h1 itemprop="headline">What is INP?</h1>
  <p itemprop="description">…</p>
</article>

<aside id="byline">
  <p>By <span itemprop="author">Jane Doe</span> ·
  <time itemprop="datePublished" datetime="2026-04-12">April 12, 2026</time></p>
</aside>

<footer id="tags">
  <span itemprop="keywords">INP</span>,
  <span itemprop="keywords">Core Web Vitals</span>
</footer>
```

### Rules

- `itemref` value is a **space-separated list of element IDs** (not selectors).
- Referenced elements can sit anywhere in the document.
- Avoid circular references (item A refs item B refs item A). Some parsers reject the cluster.
- **Prefer wrapping the elements together over `itemref`.** It is a real escape hatch but it's brittle: a refactor that renames an `id` silently breaks the structured data. Reach for it only when the DOM truly cannot be restructured.

---

## 7. `itemid` — global identifiers

`itemid` provides a stable, globally unique identifier for an item, separate from the canonical URL. Useful for entities that are referenced from multiple pages (an author profile, a product across category pages, a book by ISBN).

```html
<div itemscope itemtype="https://schema.org/Book"
     itemid="urn:isbn:978-0-13-468599-1">
  <span itemprop="name">Designing Data-Intensive Applications</span>
  <span itemprop="author" itemscope itemtype="https://schema.org/Person"
        itemid="https://example.com/authors/martin-kleppmann">
    <span itemprop="name">Martin Kleppmann</span>
  </span>
</div>
```

Rules:

- Only valid when both `itemscope` and `itemtype` are present.
- Should be a URL or URN. Plain strings (e.g. just an SKU) are technically allowed but less useful — consumers expect to dereference it.
- Often the same as the canonical URL of the entity's primary page (`https://example.com/products/acme-mouse`).
- Use the same `itemid` for the same entity across all pages of the site — that's how engines know it's the same thing.

---

## 8. Type-by-type recipes

### 8.1 Article (blog post, news article)

```html
<article itemscope itemtype="https://schema.org/Article"
         itemid="https://example.com/blog/inp-guide">

  <header>
    <h1 itemprop="headline">What is INP and how do I optimize it?</h1>

    <p>
      By
      <span itemprop="author" itemscope itemtype="https://schema.org/Person"
            itemid="https://example.com/authors/jane-doe">
        <a itemprop="url" href="/authors/jane-doe"
           ><span itemprop="name">Jane Doe</span></a>
      </span>
      ·
      <time itemprop="datePublished" datetime="2026-04-12T09:00:00Z">April 12, 2026</time>
      · Updated
      <time itemprop="dateModified" datetime="2026-05-06T14:30:00Z">May 6, 2026</time>
    </p>
  </header>

  <p itemprop="description" class="lead">
    INP measures how fast a page responds to clicks and taps.
  </p>

  <figure itemprop="image" itemscope itemtype="https://schema.org/ImageObject">
    <img itemprop="url" src="https://example.com/og/inp-guide.png"
         alt="INP — the Core Web Vital that measures interaction responsiveness"
         width="1200" height="630">
    <meta itemprop="width" content="1200">
    <meta itemprop="height" content="630">
  </figure>

  <div itemprop="publisher" itemscope itemtype="https://schema.org/Organization">
    <meta itemprop="name" content="Example">
    <div itemprop="logo" itemscope itemtype="https://schema.org/ImageObject">
      <link itemprop="url" href="https://example.com/logo.png">
      <meta itemprop="width" content="600">
      <meta itemprop="height" content="60">
    </div>
  </div>

  <link itemprop="mainEntityOfPage" href="https://example.com/blog/inp-guide">

  <!-- Article body … -->
</article>
```

### 8.2 Product

```html
<div itemscope itemtype="https://schema.org/Product"
     itemid="https://example.com/products/acme-pro-mouse">

  <h1 itemprop="name">Acme Pro Mouse</h1>

  <img itemprop="image"
       src="https://example.com/products/acme-pro-mouse.jpg"
       alt="Acme Pro Mouse — sculpted ergonomic shell" width="1200" height="900">

  <p itemprop="description">240 Hz polling, 95-hour battery, ergonomic shell.</p>

  <span itemprop="brand" itemscope itemtype="https://schema.org/Brand">
    <meta itemprop="name" content="Acme">
  </span>

  <meta itemprop="sku" content="ACM-MS-PRO-001">
  <meta itemprop="gtin13" content="0123456789012">

  <div itemprop="offers" itemscope itemtype="https://schema.org/Offer">
    <span itemprop="priceCurrency" content="USD">$</span><span itemprop="price">129.00</span>
    <link itemprop="availability" href="https://schema.org/InStock">
    <link itemprop="itemCondition" href="https://schema.org/NewCondition">
    <link itemprop="url" href="https://example.com/products/acme-pro-mouse">
    <meta itemprop="priceValidUntil" content="2026-12-31">

    <div itemprop="seller" itemscope itemtype="https://schema.org/Organization">
      <meta itemprop="name" content="Example">
    </div>
  </div>

  <div itemprop="aggregateRating" itemscope itemtype="https://schema.org/AggregateRating">
    <span itemprop="ratingValue">4.7</span> out of
    <meta itemprop="bestRating" content="5">5
    based on <span itemprop="reviewCount">312</span> reviews
  </div>
</div>
```

### 8.3 Organization (site-wide, usually in footer)

```html
<footer itemscope itemtype="https://schema.org/Organization"
        itemid="https://example.com/#organization">
  <a itemprop="url" href="https://example.com/">
    <img itemprop="logo" src="https://example.com/logo.png"
         alt="Example" width="120" height="32">
    <span itemprop="name">Example</span>
  </a>

  <div itemprop="address" itemscope itemtype="https://schema.org/PostalAddress">
    <span itemprop="streetAddress">123 Main St</span>,
    <span itemprop="addressLocality">San Francisco</span>,
    <span itemprop="addressRegion">CA</span>
    <span itemprop="postalCode">94105</span>,
    <span itemprop="addressCountry">US</span>
  </div>

  <a itemprop="telephone" href="tel:+1-555-123-4567">+1 (555) 123-4567</a>
  <a itemprop="email" href="mailto:hello@example.com">hello@example.com</a>

  <link itemprop="sameAs" href="https://www.linkedin.com/company/example">
  <link itemprop="sameAs" href="https://github.com/example">
  <link itemprop="sameAs" href="https://x.com/example">
</footer>
```

### 8.4 Person (author profile page)

```html
<article itemscope itemtype="https://schema.org/Person"
         itemid="https://example.com/authors/jane-doe">

  <h1 itemprop="name">Jane Doe</h1>
  <p itemprop="jobTitle">Senior Performance Engineer</p>

  <img itemprop="image" src="/authors/jane-doe.jpg" alt="" width="240" height="240">

  <p itemprop="description">
    Jane has worked on Core Web Vitals for nine years and contributed to the
    INP specification.
  </p>

  <a itemprop="url" href="https://example.com/authors/jane-doe">Profile</a>

  <link itemprop="sameAs" href="https://www.linkedin.com/in/janedoe">
  <link itemprop="sameAs" href="https://github.com/janedoe">
  <link itemprop="sameAs" href="https://orcid.org/0000-0000-0000-0000">

  <div itemprop="worksFor" itemscope itemtype="https://schema.org/Organization">
    <meta itemprop="name" content="Example">
  </div>
</article>
```

### 8.5 BreadcrumbList

```html
<nav aria-label="Breadcrumb">
  <ol itemscope itemtype="https://schema.org/BreadcrumbList">
    <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
      <a itemprop="item" href="https://example.com/">
        <span itemprop="name">Home</span>
      </a>
      <meta itemprop="position" content="1">
    </li>
    <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
      <a itemprop="item" href="https://example.com/blog">
        <span itemprop="name">Blog</span>
      </a>
      <meta itemprop="position" content="2">
    </li>
    <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
      <span itemprop="name" aria-current="page">What is INP?</span>
      <meta itemprop="position" content="3">
    </li>
  </ol>
</nav>
```

The last item's `name` is required; the `item` URL is optional for the current page.

### 8.6 FAQPage

```html
<section itemscope itemtype="https://schema.org/FAQPage">
  <h2>FAQ</h2>

  <div itemprop="mainEntity" itemscope itemtype="https://schema.org/Question">
    <h3 itemprop="name">What is a good INP score?</h3>
    <div itemprop="acceptedAnswer" itemscope itemtype="https://schema.org/Answer">
      <div itemprop="text">
        <p>A good INP is 200 ms or less at the 75th percentile, measured in the field.</p>
      </div>
    </div>
  </div>

  <div itemprop="mainEntity" itemscope itemtype="https://schema.org/Question">
    <h3 itemprop="name">Did INP replace First Input Delay?</h3>
    <div itemprop="acceptedAnswer" itemscope itemtype="https://schema.org/Answer">
      <div itemprop="text">
        <p>Yes. INP replaced FID as a Core Web Vital in March 2024.</p>
      </div>
    </div>
  </div>
</section>
```

### 8.7 Recipe

```html
<article itemscope itemtype="https://schema.org/Recipe">
  <h1 itemprop="name">Sourdough loaf</h1>
  <img itemprop="image" src="/recipes/sourdough.jpg" alt="" width="1200" height="800">
  <p itemprop="description">A simple country sourdough.</p>

  <span itemprop="author" itemscope itemtype="https://schema.org/Person">
    <span itemprop="name">Jane Doe</span>
  </span>

  <time itemprop="datePublished" datetime="2026-04-12">April 12, 2026</time>

  <meta itemprop="prepTime" content="PT30M">
  <meta itemprop="cookTime" content="PT45M">
  <meta itemprop="totalTime" content="PT24H">
  <meta itemprop="recipeYield" content="1 loaf">

  <span itemprop="recipeCategory">Bread</span>
  <span itemprop="recipeCuisine">European</span>

  <div itemprop="nutrition" itemscope itemtype="https://schema.org/NutritionInformation">
    <meta itemprop="calories" content="220 calories">
  </div>

  <h2>Ingredients</h2>
  <ul>
    <li itemprop="recipeIngredient">500 g bread flour</li>
    <li itemprop="recipeIngredient">350 g water</li>
    <li itemprop="recipeIngredient">100 g active starter</li>
    <li itemprop="recipeIngredient">10 g salt</li>
  </ul>

  <h2>Instructions</h2>
  <ol>
    <li itemprop="recipeInstructions">Mix flour and water; rest 30 min.</li>
    <li itemprop="recipeInstructions">Add starter and salt; bulk ferment 4 h.</li>
    <li itemprop="recipeInstructions">Shape, cold proof overnight.</li>
    <li itemprop="recipeInstructions">Bake at 250 °C for 45 min.</li>
  </ol>
</article>
```

Durations use **ISO 8601 duration format** (`PT30M`, `PT24H`).

### 8.8 Event

```html
<div itemscope itemtype="https://schema.org/Event">
  <h1 itemprop="name">Performance Summit 2026</h1>

  <time itemprop="startDate" datetime="2026-09-15T09:00:00-07:00">Sep 15, 2026, 9:00 AM PDT</time> –
  <time itemprop="endDate"   datetime="2026-09-15T17:00:00-07:00">5:00 PM PDT</time>

  <link itemprop="eventStatus" href="https://schema.org/EventScheduled">
  <link itemprop="eventAttendanceMode" href="https://schema.org/OfflineEventAttendanceMode">

  <div itemprop="location" itemscope itemtype="https://schema.org/Place">
    <span itemprop="name">Moscone West</span>
    <div itemprop="address" itemscope itemtype="https://schema.org/PostalAddress">
      <span itemprop="streetAddress">800 Howard St</span>,
      <span itemprop="addressLocality">San Francisco</span>,
      <span itemprop="addressRegion">CA</span>
      <span itemprop="postalCode">94103</span>,
      <span itemprop="addressCountry">US</span>
    </div>
  </div>

  <div itemprop="offers" itemscope itemtype="https://schema.org/Offer">
    <span itemprop="priceCurrency" content="USD">USD</span>
    <span itemprop="price">399</span>
    <link itemprop="availability" href="https://schema.org/InStock">
    <link itemprop="url" href="https://example.com/summit/tickets">
    <meta itemprop="validFrom" content="2026-04-01T00:00:00-07:00">
  </div>

  <div itemprop="organizer" itemscope itemtype="https://schema.org/Organization">
    <span itemprop="name">Example</span>
    <link itemprop="url" href="https://example.com/">
  </div>
</div>
```

### 8.9 LocalBusiness

```html
<div itemscope itemtype="https://schema.org/Restaurant"
     itemid="https://example.com/#restaurant">

  <h1 itemprop="name">Acme Bistro</h1>
  <img itemprop="image" src="/photos/exterior.jpg" alt="" width="1600" height="900">

  <div itemprop="address" itemscope itemtype="https://schema.org/PostalAddress">
    <span itemprop="streetAddress">123 Main St</span>,
    <span itemprop="addressLocality">San Francisco</span>,
    <span itemprop="addressRegion">CA</span>
    <span itemprop="postalCode">94105</span>,
    <span itemprop="addressCountry">US</span>
  </div>

  <span itemprop="geo" itemscope itemtype="https://schema.org/GeoCoordinates">
    <meta itemprop="latitude" content="37.7749">
    <meta itemprop="longitude" content="-122.4194">
  </span>

  <a itemprop="telephone" href="tel:+1-555-123-4567">+1 (555) 123-4567</a>

  <span itemprop="priceRange">$$</span>
  <link itemprop="servesCuisine" href="https://schema.org/FrenchCuisine">

  <meta itemprop="openingHours" content="Tu-Sa 17:00-22:00">

  <div itemprop="aggregateRating" itemscope itemtype="https://schema.org/AggregateRating">
    <span itemprop="ratingValue">4.6</span>
    (<span itemprop="reviewCount">128</span> reviews)
    <meta itemprop="bestRating" content="5">
  </div>
</div>
```

Use the most specific subtype of `LocalBusiness` (`Restaurant`, `MedicalClinic`, `AutoRepair`, …) — Google parses the type for category-specific features.

---

## 9. Multiple property values

Two patterns for properties that can repeat.

### Same property, multiple elements

```html
<div itemscope itemtype="https://schema.org/Person">
  <link itemprop="sameAs" href="https://www.linkedin.com/in/janedoe">
  <link itemprop="sameAs" href="https://github.com/janedoe">
  <link itemprop="sameAs" href="https://orcid.org/0000-0000-0000-0000">
</div>
```

### One element, multiple properties

```html
<a itemprop="name url" href="https://example.com/products/acme-mouse">Acme Mouse</a>
```

The `name` becomes the inner text (`Acme Mouse`); the `url` becomes the `href`. Space-separated `itemprop` values let one element carry multiple roles.

---

## 10. Framework integration

Microdata is plain HTML attributes — every framework supports it.

### Astro

```astro
---
const { article } = Astro.props;
---
<article itemscope itemtype="https://schema.org/Article" itemid={article.url}>
  <h1 itemprop="headline">{article.title}</h1>
  <p>By
    <span itemprop="author" itemscope itemtype="https://schema.org/Person">
      <span itemprop="name">{article.author.name}</span>
    </span>
  </p>
  <time itemprop="datePublished" datetime={article.publishedAt}>
    {formatDate(article.publishedAt)}
  </time>
</article>
```

### Vue / Nuxt

```vue
<template>
  <article itemscope itemtype="https://schema.org/Article" :itemid="article.url">
    <h1 itemprop="headline">{{ article.title }}</h1>
    <span itemprop="author" itemscope itemtype="https://schema.org/Person">
      <span itemprop="name">{{ article.author.name }}</span>
    </span>
    <time itemprop="datePublished" :datetime="article.publishedAt">
      {{ formatDate(article.publishedAt) }}
    </time>
  </article>
</template>
```

In Vue/React/Svelte, **make sure attributes survive SSR**. Hydration must not strip or re-order them. Test by viewing the rendered HTML with JavaScript disabled — the `itemscope`/`itemprop` attributes must already be in the source.

### React (JSX)

JSX accepts the attributes as-is:

```jsx
<article itemScope itemType="https://schema.org/Article" itemID={article.url}>
  <h1 itemProp="headline">{article.title}</h1>
</article>
```

Note camelCase: `itemScope`, `itemType`, `itemID`, `itemProp`, `itemRef`. JSX serializes them back to lowercase HTML.

---

## 11. Mismatches and conflicts

The most common silent failure is **structured data that disagrees with what the user sees**. Google explicitly penalizes this — and the page can be excluded from rich results without notice.

### The mismatches that get pages punished

- Price visible as `$129.00`; `<meta itemprop="price" content="99.00">` says `99.00`.
- Aggregate rating shows `4.7`; `itemprop="ratingValue"` says `4.9`.
- Recipe says "30 min prep"; `prepTime` is `PT2H`.
- Article says updated yesterday; `dateModified` is six months old.
- Availability badge says "Out of stock"; `availability` is `InStock`.

### Rules

- **The structured value must match what the user sees.** If the user sees `$129.00`, the structured price must be `129.00` USD.
- **Never inject structured facts that aren't present in the visible content.** A hidden `aggregateRating` of 4.9 with no visible rating is grounds for a manual action.
- **Update both at once.** When the visible price changes, the `itemprop="price"` element changes in the same render.

### Don't ship Microdata + JSON-LD that disagree

When both are present (sometimes inevitable across legacy + new templates), make one the source of truth and **derive** the other from the same data. The fastest way to see drift in a CI pipeline is a snapshot test that diffs the extracted Microdata against the extracted JSON-LD for the same fields.

---

## 12. Validation tools and commands

### Live tests

```bash
# Google's Rich Results Test — supports Microdata + JSON-LD + RDFa
# https://search.google.com/test/rich-results

# Schema.org Markup Validator (the schema-only, non-Google one)
# https://validator.schema.org/

# Google Search Console → Enhancements → see indexed structured data per type
```

### Local extraction

```bash
# Use a Microdata parser. The Yandex / live spec implementation in JS:
#   npm install microdata-node
node -e '
  import("microdata-node").then(({ default: parse }) => {
    const html = require("fs").readFileSync(0, "utf8");
    console.log(JSON.stringify(parse(html), null, 2));
  });
' < page.html

# Or via Python:
#   pip install extruct
python3 -c '
import sys, extruct, json
data = extruct.extract(sys.stdin.read(), syntaxes=["microdata"])
print(json.dumps(data, indent=2))
' < page.html
```

### CI smoke checks

```bash
# Fail if a product page has no itemtype="Product"
curl -sf https://example.com/products/acme-mouse \
  | grep -q 'itemtype="https://schema.org/Product"' \
  || { echo "FAIL: missing Product microdata"; exit 1; }

# Fail if visible price and itemprop=price disagree on a sample of products
# (pseudo — wire into the build's product fixtures)
```

---

## 13. Anti-patterns — never ship

- ❌ `itemtype` without `itemscope` — silently invalid.
- ❌ `itemprop` outside any `itemscope` — orphaned, ignored.
- ❌ `itemtype="schema.org/Article"` (missing protocol). Use full URL.
- ❌ `itemtype="http://..."` on a site that serves HTTPS only — works but inconsistent. Prefer `https://`.
- ❌ Hidden facts: `<meta itemprop="aggregateRating" content="4.9">` with no visible rating.
- ❌ Visible price `$129`; structured price `99`. Mismatch.
- ❌ `<span itemprop="datePublished">April 12, 2026</span>` — no machine-readable date. Use `<time datetime>`.
- ❌ `<span itemprop="url">https://example.com/foo</span>` — text URL extraction is fragile. Use `<a href>` or `<link href>`.
- ❌ Putting `itemprop="image"` on a `<div>` with a CSS background. Microdata reads `src`/`href` from media elements; a div has neither.
- ❌ One giant Microdata graph for the whole page (`<body itemscope itemtype="WebPage">` with everything underneath). It's allowed but it makes refactors brittle. Mark up entities at their natural boundaries.
- ❌ `itemref` to an element that doesn't exist (typo'd `id`).
- ❌ `itemref` cycles (A refs B, B refs A).
- ❌ Properties not part of the type's vocabulary (`itemprop="vibes"`). Ignored, but pollutes diffs.
- ❌ Using a generic `Thing` or `Article` when a more specific type exists (`NewsArticle`, `Recipe`, `Restaurant`).
- ❌ Wrong duration / date formats. Durations are ISO 8601 (`PT30M`); dates are ISO 8601 (`2026-04-12` or full timestamp).
- ❌ Recipe `recipeIngredient` items concatenated as one string. One `<li itemprop="recipeIngredient">` per ingredient.
- ❌ Both Microdata and JSON-LD with conflicting facts. Pick one source of truth.
- ❌ Stripping `itemscope`/`itemprop` attributes during minification — some HTML minifiers drop "non-standard" attributes by default. Disable that.
- ❌ Hydration mismatches: SSR'd attributes don't survive the client render. Test with JS disabled.

---

## 14. Validation checklist

Use when auditing existing markup. Score each item; report findings with severity.

### Structure

- [ ] Every `itemscope` is paired with `itemtype` (a Schema.org URL).
- [ ] Every `itemprop` lives inside an `itemscope` (or is referenced via `itemref`).
- [ ] `itemtype` URLs use `https://` and the full path (`https://schema.org/Article`).
- [ ] Each item uses the most specific Schema.org type that fits.
- [ ] Nested entities are themselves both an `itemprop` of the parent and an `itemscope`+`itemtype` of their own.
- [ ] `itemref` IDs all exist in the DOM and contain the expected `itemprop`s.

### Value extraction

- [ ] Dates wrapped in `<time datetime="…">` not `<span>`.
- [ ] URLs in `<a href>` or `<link href>`, not text content.
- [ ] Image properties on `<img>` (or nested `ImageObject`) — never on a `<div>` with a CSS background.
- [ ] Enum values (`availability`, `eventStatus`) use `<link href="https://schema.org/…">`.
- [ ] Hidden machine-readable values use `<meta itemprop="…" content="…">`.

### Consistency

- [ ] Every structured value matches its visible counterpart.
- [ ] Price, currency, availability, rating, review count, dates: all match the user-visible UI.
- [ ] No structured facts that are absent from the visible content.
- [ ] If JSON-LD is also present, the two formats agree on every shared field.

### Rich-result coverage

- [ ] Articles include `headline`, `author`, `datePublished`, `dateModified`, `image`, `publisher`.
- [ ] Products include `name`, `image`, `description`, `offers` (with `price`, `priceCurrency`, `availability`), `aggregateRating` if reviews exist.
- [ ] Breadcrumbs use `BreadcrumbList` with `position`-numbered `ListItem`s.
- [ ] FAQs use `FAQPage` with `Question` + `acceptedAnswer`.
- [ ] Recipes include `prepTime`, `cookTime`, `totalTime`, `recipeYield`, ingredients, instructions, image, author.
- [ ] Events include `startDate`, `location`, `eventStatus`, `eventAttendanceMode`, `offers` if ticketed.
- [ ] LocalBusiness includes `address`, `telephone`, `geo`, `openingHours`, `priceRange`.

### Identity

- [ ] `itemid` used for entities that are referenced from multiple pages (authors, products, the organization).
- [ ] Same `itemid` used consistently across the site for the same entity.

### SSR / framework

- [ ] Microdata attributes appear in the SSR'd HTML, not added only after hydration.
- [ ] Minifier configured to preserve `itemscope`, `itemtype`, `itemprop`, `itemid`, `itemref`.

### Testing

- [ ] Rich Results Test passes for every page type that ships rich-result-eligible markup.
- [ ] Schema.org validator has zero errors for every page type.
- [ ] Search Console shows valid items in "Enhancements" for the relevant categories.

### Severity guide

- `high` — `itemtype` without `itemscope`, hidden facts that don't match visible content, missing required properties for a rich-result type, conflicting Microdata + JSON-LD, stripped attributes after minification.
- `medium` — wrong type granularity (`Article` instead of `NewsArticle`), `itemref` typos, missing `itemid` for cross-referenced entities, dates as plain text instead of `<time>`.
- `low` — missing optional properties (`sameAs`, `mainEntityOfPage`), suboptimal nesting, generic anchor text inside an `itemprop`.

---

## 15. Output format

When asked to **generate** Microdata for a page, return:

1. The complete HTML for the marked-up section, using the right Schema.org type and the patterns from section 8.
2. A note on which properties are required vs recommended for the rich-result feature being targeted.
3. Open questions for any field that needs project input (canonical URLs, brand name, image URLs, organization details).
4. A pointer to the Rich Results Test URL with the page's URL pre-filled (or instructions to test locally).

When asked to **validate** existing Microdata, return:

```text
# HTML5 Microdata Audit — <URL or file path>

## Summary
- Items detected: <count by type>
- Schema.org types in use: <list>
- Visible/structured mismatches: <count>
- Missing required properties: <count by type>
- Rich Results Test: <pass/fail per type>
- Overall: <PASS | NEEDS WORK | FAIL>

## Findings
**[HIGH]** <selector or line> — <issue> — <recommended fix>
**[MEDIUM]** ...
**[LOW]** ...

## Recommended fix order
1. ...
```

Then offer to apply each fix. Apply approved fixes one at a time, confirming each.
