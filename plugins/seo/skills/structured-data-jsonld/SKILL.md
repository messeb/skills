---
description: Structured data via JSON-LD — the Google-preferred format for Article, Product, Organization, Person, BreadcrumbList, FAQPage, HowTo, Recipe, Event, LocalBusiness, VideoObject, Course, JobPosting, SoftwareApplication, and Dataset. Includes @graph for multi-entity pages, framework integration (Astro/Nuxt/Next), id-based entity linking, dynamic per-page generation, validation, mismatch prevention, and a complete checklist for rich-result eligibility.
---

# Structured data with JSON-LD — the Google-preferred format

JSON-LD is Google's preferred format for structured data. Unlike inline Microdata (covered by `html5-microdata`), JSON-LD lives in a single `<script type="application/ld+json">` block, separated from the rendered DOM. That separation is its strength — markup refactors don't break it — and its weakness — the JSON can drift from what the user sees.

This skill covers JSON-LD authoring: type recipes, multi-entity graphs with `@id`, framework integration, dynamic generation, validation, and the patterns that pass Google's Rich Results Test.

For the Microdata equivalent see `html5-microdata`. For the markup-level meta tags that pair with structured data see `meta-tags`. This skill is the **JSON-LD layer**.

---

## 1. Why JSON-LD won

| Criterion | JSON-LD | Microdata | RDFa |
|-----------|---------|-----------|------|
| Google preferred | ✅ | ✅ supported | ✅ supported |
| DOM-coupled | No — in `<script>` | Yes — inline attributes | Yes — inline attributes |
| Refactor-safe | ✅ | Brittle | Brittle |
| SPA / hydration safe | ✅ — static script tag | Risky | Risky |
| Nested entity verbosity | Low — JSON objects | High — attribute soup | High |
| Drift from visible content | High — separate source | Low — same DOM | Low |
| Framework-native support | ✅ (every meta lib) | Manual | Manual |

The trade-off: JSON-LD is a **second source of truth**. The price for refactor safety is the discipline of keeping JSON facts in sync with visible facts.

---

## 2. The basic shape

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "What is INP?",
  "datePublished": "2026-04-12T09:00:00Z",
  "dateModified": "2026-05-06T14:30:00Z",
  "author": {
    "@type": "Person",
    "name": "Jane Doe",
    "url": "https://example.com/authors/jane-doe"
  }
}
</script>
```

### Rules

- **`@context`** is required. `https://schema.org` covers all standard types.
- **`@type`** declares the entity's type.
- **JSON must be valid** — no trailing commas, no comments, no JS-style single quotes.
- **One `<script type="application/ld+json">` per logical entity**, or one combined `@graph` (section 6).
- **Place in `<head>` or anywhere in `<body>`.** `<head>` is canonical; `<body>` is fine for components that own their own structured data.
- **Server-render it.** Don't inject JSON-LD only after JS hydration — Googlebot may see the page before hydration runs.

---

## 3. Type-by-type recipes

### 3.1 Article

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "What is INP and how do I optimize it?",
  "description": "INP measures how fast a page responds to clicks and taps. Learn the 200 ms threshold, common causes, and concrete fixes.",
  "image": [
    "https://example.com/images/inp-1x1.jpg",
    "https://example.com/images/inp-4x3.jpg",
    "https://example.com/images/inp-16x9.jpg"
  ],
  "datePublished": "2026-04-12T09:00:00Z",
  "dateModified": "2026-05-06T14:30:00Z",
  "author": {
    "@type": "Person",
    "name": "Jane Doe",
    "url": "https://example.com/authors/jane-doe"
  },
  "publisher": {
    "@type": "Organization",
    "name": "Example",
    "logo": {
      "@type": "ImageObject",
      "url": "https://example.com/logo.png",
      "width": 600,
      "height": 60
    }
  },
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": "https://example.com/blog/inp-guide"
  }
}
</script>
```

**Required for rich results**: `headline`, `image` (1:1, 4:3, 16:9), `datePublished`, `author`. Add `dateModified` whenever the article is meaningfully edited.

### 3.2 NewsArticle / BlogPosting

Subtypes of `Article`. Use the most specific:

- `NewsArticle` — journalism with a publication date and reporter byline.
- `BlogPosting` — blog post.
- `Article` — generic fallback.

The schema is identical except for the `@type`.

### 3.3 Product

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Acme Pro Mouse",
  "image": [
    "https://example.com/products/acme-pro-mouse-1x1.jpg",
    "https://example.com/products/acme-pro-mouse-4x3.jpg",
    "https://example.com/products/acme-pro-mouse-16x9.jpg"
  ],
  "description": "240 Hz polling, 95-hour battery, ergonomic shell.",
  "sku": "ACM-MS-PRO-001",
  "gtin13": "0123456789012",
  "brand": {
    "@type": "Brand",
    "name": "Acme"
  },
  "offers": {
    "@type": "Offer",
    "url": "https://example.com/products/acme-pro-mouse",
    "priceCurrency": "USD",
    "price": "129.00",
    "priceValidUntil": "2026-12-31",
    "availability": "https://schema.org/InStock",
    "itemCondition": "https://schema.org/NewCondition",
    "seller": {
      "@type": "Organization",
      "name": "Example"
    }
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.7",
    "reviewCount": "312",
    "bestRating": "5",
    "worstRating": "1"
  },
  "review": [
    {
      "@type": "Review",
      "author": { "@type": "Person", "name": "Sam K." },
      "datePublished": "2026-04-15",
      "reviewRating": { "@type": "Rating", "ratingValue": "5" },
      "reviewBody": "Most comfortable mouse I've used."
    }
  ]
}
</script>
```

**Critical**: visible price, currency, and availability **must match** the JSON. Mismatches disqualify the product from rich results and can earn a manual action.

### 3.4 Organization (site-wide)

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "@id": "https://example.com/#organization",
  "name": "Example",
  "url": "https://example.com/",
  "logo": {
    "@type": "ImageObject",
    "url": "https://example.com/logo.png",
    "width": 600,
    "height": 60
  },
  "sameAs": [
    "https://www.linkedin.com/company/example",
    "https://github.com/example",
    "https://x.com/example"
  ],
  "contactPoint": [
    {
      "@type": "ContactPoint",
      "telephone": "+1-555-123-4567",
      "contactType": "customer support",
      "email": "support@example.com",
      "areaServed": "US",
      "availableLanguage": ["English"]
    }
  ]
}
</script>
```

Place once site-wide (e.g. in the layout's `<head>`) with a stable `@id`. Other entities reference it.

### 3.5 WebSite (with SearchAction)

Powers the Google Sitelinks Searchbox.

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "@id": "https://example.com/#website",
  "url": "https://example.com/",
  "name": "Example",
  "publisher": { "@id": "https://example.com/#organization" },
  "potentialAction": {
    "@type": "SearchAction",
    "target": {
      "@type": "EntryPoint",
      "urlTemplate": "https://example.com/search?q={search_term_string}"
    },
    "query-input": "required name=search_term_string"
  }
}
</script>
```

### 3.6 Person (author profile)

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Person",
  "@id": "https://example.com/authors/jane-doe#person",
  "name": "Jane Doe",
  "jobTitle": "Senior Performance Engineer",
  "url": "https://example.com/authors/jane-doe",
  "image": "https://example.com/authors/jane-doe.jpg",
  "description": "Performance engineer working on Core Web Vitals.",
  "worksFor": { "@id": "https://example.com/#organization" },
  "sameAs": [
    "https://www.linkedin.com/in/janedoe",
    "https://github.com/janedoe",
    "https://orcid.org/0000-0000-0000-0000"
  ]
}
</script>
```

### 3.7 BreadcrumbList

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    {
      "@type": "ListItem",
      "position": 1,
      "name": "Home",
      "item": "https://example.com/"
    },
    {
      "@type": "ListItem",
      "position": 2,
      "name": "Blog",
      "item": "https://example.com/blog"
    },
    {
      "@type": "ListItem",
      "position": 3,
      "name": "What is INP?"
    }
  ]
}
</script>
```

The last item omits `item` (or includes the current URL — both are accepted). Always include `position` starting at 1.

### 3.8 FAQPage

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is a good INP score?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "A good INP is 200 ms or less at the 75th percentile, measured in the field."
      }
    },
    {
      "@type": "Question",
      "name": "Did INP replace First Input Delay?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. INP replaced FID as a Core Web Vital in March 2024."
      }
    }
  ]
}
</script>
```

**Important**: The questions and answers in the JSON-LD **must exist verbatim in the visible page body**. Hidden FAQ-only-in-schema risks a manual action.

### 3.9 HowTo

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "How to set up Lighthouse CI",
  "description": "Install and configure Lighthouse CI to run on every pull request.",
  "totalTime": "PT15M",
  "tool": [
    { "@type": "HowToTool", "name": "Node.js" },
    { "@type": "HowToTool", "name": "pnpm" }
  ],
  "step": [
    {
      "@type": "HowToStep",
      "name": "Install the CLI",
      "text": "Run pnpm add -D @lhci/cli at the repo root.",
      "url": "https://example.com/blog/lhci-setup#install"
    },
    {
      "@type": "HowToStep",
      "name": "Create the config",
      "text": "Create lighthouserc.cjs with assertions for the page types you care about.",
      "url": "https://example.com/blog/lhci-setup#config"
    },
    {
      "@type": "HowToStep",
      "name": "Wire to CI",
      "text": "Add pnpm lhci autorun to the CI workflow after the build step.",
      "url": "https://example.com/blog/lhci-setup#ci"
    }
  ]
}
</script>
```

**Note**: Google deprecated the `HowTo` rich result for non-recipe content (May 2024). The schema is still valid and useful for AI search; it just won't appear as a rich result in standard search.

### 3.10 Recipe

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Recipe",
  "name": "Sourdough loaf",
  "image": [
    "https://example.com/recipes/sourdough-1x1.jpg",
    "https://example.com/recipes/sourdough-4x3.jpg",
    "https://example.com/recipes/sourdough-16x9.jpg"
  ],
  "author": { "@type": "Person", "name": "Jane Doe" },
  "datePublished": "2026-04-12",
  "description": "A simple country sourdough.",
  "prepTime": "PT30M",
  "cookTime": "PT45M",
  "totalTime": "PT24H",
  "recipeYield": "1 loaf",
  "recipeCategory": "Bread",
  "recipeCuisine": "European",
  "nutrition": {
    "@type": "NutritionInformation",
    "calories": "220 calories"
  },
  "recipeIngredient": [
    "500 g bread flour",
    "350 g water",
    "100 g active starter",
    "10 g salt"
  ],
  "recipeInstructions": [
    {
      "@type": "HowToStep",
      "name": "Mix",
      "text": "Mix flour and water; rest 30 min."
    },
    {
      "@type": "HowToStep",
      "name": "Bulk ferment",
      "text": "Add starter and salt; bulk ferment 4 h."
    },
    {
      "@type": "HowToStep",
      "name": "Cold proof",
      "text": "Shape, cold proof overnight."
    },
    {
      "@type": "HowToStep",
      "name": "Bake",
      "text": "Bake at 250 °C for 45 min."
    }
  ],
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.8",
    "reviewCount": "42"
  }
}
</script>
```

Durations use **ISO 8601 duration format** (`PT30M`, `PT24H`).

### 3.11 Event

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Event",
  "name": "Performance Summit 2026",
  "description": "A one-day conference on web performance.",
  "image": "https://example.com/events/perf-summit-2026.jpg",
  "startDate": "2026-09-15T09:00-07:00",
  "endDate":   "2026-09-15T17:00-07:00",
  "eventStatus": "https://schema.org/EventScheduled",
  "eventAttendanceMode": "https://schema.org/OfflineEventAttendanceMode",
  "location": {
    "@type": "Place",
    "name": "Moscone West",
    "address": {
      "@type": "PostalAddress",
      "streetAddress": "800 Howard St",
      "addressLocality": "San Francisco",
      "addressRegion": "CA",
      "postalCode": "94103",
      "addressCountry": "US"
    }
  },
  "offers": {
    "@type": "Offer",
    "url": "https://example.com/summit/tickets",
    "price": "399",
    "priceCurrency": "USD",
    "availability": "https://schema.org/InStock",
    "validFrom": "2026-04-01T00:00-07:00"
  },
  "organizer": {
    "@type": "Organization",
    "name": "Example",
    "url": "https://example.com/"
  },
  "performer": [
    { "@type": "Person", "name": "Jane Doe" }
  ]
}
</script>
```

`startDate` / `endDate` use ISO 8601 with timezone offset.

### 3.12 LocalBusiness

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Restaurant",
  "@id": "https://example.com/#restaurant",
  "name": "Acme Bistro",
  "image": "https://example.com/photos/exterior.jpg",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "123 Main St",
    "addressLocality": "San Francisco",
    "addressRegion": "CA",
    "postalCode": "94105",
    "addressCountry": "US"
  },
  "geo": {
    "@type": "GeoCoordinates",
    "latitude": 37.7749,
    "longitude": -122.4194
  },
  "telephone": "+1-555-123-4567",
  "url": "https://example.com/",
  "priceRange": "$$",
  "servesCuisine": "French",
  "openingHoursSpecification": [
    {
      "@type": "OpeningHoursSpecification",
      "dayOfWeek": ["Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
      "opens": "17:00",
      "closes": "22:00"
    }
  ],
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.6",
    "reviewCount": "128"
  }
}
</script>
```

Use the most specific subtype of `LocalBusiness` (`Restaurant`, `MedicalClinic`, `AutoRepair`, `Bakery`, `Hotel`, …) — Google parses the type for category-specific features.

### 3.13 VideoObject

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "VideoObject",
  "name": "What is INP?",
  "description": "A 4-minute walkthrough of INP, its threshold, and three concrete fixes.",
  "thumbnailUrl": [
    "https://example.com/videos/inp-1x1.jpg",
    "https://example.com/videos/inp-4x3.jpg",
    "https://example.com/videos/inp-16x9.jpg"
  ],
  "uploadDate": "2026-05-06T09:00:00Z",
  "duration": "PT4M",
  "contentUrl": "https://example.com/videos/inp.mp4",
  "embedUrl": "https://example.com/videos/inp/embed",
  "transcript": "https://example.com/videos/inp/transcript",
  "publisher": { "@id": "https://example.com/#organization" }
}
</script>
```

### 3.14 Course

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Course",
  "name": "Web Performance Foundations",
  "description": "An eight-week course covering Core Web Vitals, image optimization, and JavaScript performance.",
  "provider": {
    "@type": "Organization",
    "name": "Example",
    "sameAs": "https://example.com/"
  },
  "courseCode": "PERF-101",
  "educationalLevel": "Intermediate"
}
</script>
```

### 3.15 JobPosting

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "JobPosting",
  "title": "Senior Performance Engineer",
  "description": "Own Core Web Vitals across the product. Lead measurement, budget enforcement, and per-team enablement.",
  "datePosted": "2026-05-01",
  "validThrough": "2026-06-30",
  "employmentType": "FULL_TIME",
  "hiringOrganization": { "@id": "https://example.com/#organization" },
  "jobLocation": {
    "@type": "Place",
    "address": {
      "@type": "PostalAddress",
      "addressLocality": "San Francisco",
      "addressRegion": "CA",
      "postalCode": "94105",
      "addressCountry": "US"
    }
  },
  "baseSalary": {
    "@type": "MonetaryAmount",
    "currency": "USD",
    "value": {
      "@type": "QuantitativeValue",
      "minValue": 180000,
      "maxValue": 230000,
      "unitText": "YEAR"
    }
  }
}
</script>
```

### 3.16 SoftwareApplication

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "Example Lighthouse Reporter",
  "applicationCategory": "DeveloperApplication",
  "operatingSystem": "Linux, macOS, Windows",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.5",
    "reviewCount": "87"
  }
}
</script>
```

### 3.17 Dataset

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Dataset",
  "name": "Core Web Vitals — top 10k sites — Q2 2026",
  "description": "LCP, INP, and CLS at the 75th percentile for the Alexa top 10k.",
  "url": "https://example.com/datasets/cwv-q2-2026",
  "license": "https://creativecommons.org/licenses/by/4.0/",
  "creator": { "@id": "https://example.com/#organization" },
  "distribution": [
    {
      "@type": "DataDownload",
      "encodingFormat": "text/csv",
      "contentUrl": "https://example.com/datasets/cwv-q2-2026.csv"
    },
    {
      "@type": "DataDownload",
      "encodingFormat": "application/json",
      "contentUrl": "https://example.com/datasets/cwv-q2-2026.json"
    }
  ],
  "temporalCoverage": "2026-04-01/2026-06-30"
}
</script>
```

---

## 4. `@id` — entity references across the page and site

When a page describes multiple entities that reference each other (an Article whose `author` is a Person whose `worksFor` is an Organization), inline-nesting each entity bloats the JSON. Use `@id` to declare each entity once and reference by ID.

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "Organization",
      "@id": "https://example.com/#organization",
      "name": "Example",
      "url": "https://example.com/",
      "logo": "https://example.com/logo.png"
    },
    {
      "@type": "Person",
      "@id": "https://example.com/authors/jane-doe#person",
      "name": "Jane Doe",
      "url": "https://example.com/authors/jane-doe",
      "worksFor": { "@id": "https://example.com/#organization" }
    },
    {
      "@type": "WebSite",
      "@id": "https://example.com/#website",
      "url": "https://example.com/",
      "name": "Example",
      "publisher": { "@id": "https://example.com/#organization" }
    },
    {
      "@type": "WebPage",
      "@id": "https://example.com/blog/inp-guide#webpage",
      "url": "https://example.com/blog/inp-guide",
      "name": "What is INP?",
      "isPartOf": { "@id": "https://example.com/#website" },
      "primaryImageOfPage": { "@id": "https://example.com/blog/inp-guide#image" }
    },
    {
      "@type": "ImageObject",
      "@id": "https://example.com/blog/inp-guide#image",
      "url": "https://example.com/og/inp-guide.png",
      "width": 1200,
      "height": 630
    },
    {
      "@type": "BreadcrumbList",
      "@id": "https://example.com/blog/inp-guide#breadcrumb",
      "itemListElement": [
        { "@type": "ListItem", "position": 1, "name": "Home", "item": "https://example.com/" },
        { "@type": "ListItem", "position": 2, "name": "Blog", "item": "https://example.com/blog" },
        { "@type": "ListItem", "position": 3, "name": "What is INP?" }
      ]
    },
    {
      "@type": "Article",
      "@id": "https://example.com/blog/inp-guide#article",
      "isPartOf": { "@id": "https://example.com/blog/inp-guide#webpage" },
      "mainEntityOfPage": { "@id": "https://example.com/blog/inp-guide#webpage" },
      "headline": "What is INP?",
      "image": { "@id": "https://example.com/blog/inp-guide#image" },
      "datePublished": "2026-04-12T09:00:00Z",
      "dateModified": "2026-05-06T14:30:00Z",
      "author": { "@id": "https://example.com/authors/jane-doe#person" },
      "publisher": { "@id": "https://example.com/#organization" }
    }
  ]
}
</script>
```

### Rules for `@id`

- **`@id` is a URL or URN** — globally unique, dereferenceable when possible.
- **Site-wide entities** (Organization, WebSite) get a stable site-rooted `@id`: `https://example.com/#organization`.
- **Per-page entities** include the page URL plus a fragment: `https://example.com/blog/inp-guide#article`.
- **Reference by `{ "@id": "…" }`** — no need to re-declare the full entity.
- **`@graph` wraps the array of entities** under one `@context`. Use it whenever a page declares 3+ entities; cleaner than 3+ separate `<script>` tags.

---

## 5. `@graph` vs multiple `<script>` tags

Two ways to ship multiple entities on one page:

### Option A — single `@graph`

```html
<script type="application/ld+json">
{ "@context": "https://schema.org", "@graph": [ … ] }
</script>
```

One block. One context. Cross-references via `@id` are local. Cleaner for pages with related entities.

### Option B — multiple scripts

```html
<script type="application/ld+json">{"@context":"https://schema.org","@type":"Article", …}</script>
<script type="application/ld+json">{"@context":"https://schema.org","@type":"BreadcrumbList", …}</script>
<script type="application/ld+json">{"@context":"https://schema.org","@type":"FAQPage", …}</script>
```

Multiple blocks. Each is a standalone entity. No cross-references needed if the entities are truly independent.

### When to use which

- **`@graph`** when entities reference each other (Article → author → Organization).
- **Separate scripts** when entities are independent (Article + FAQPage + BreadcrumbList that don't share references).
- **Mix** if a section of the page (e.g. a footer-injected Organization block from a CMS) is generated separately from the article.

Google parses both equivalently.

---

## 6. Framework integration

### 6.1 Astro

```astro
---
const { article } = Astro.props;

const jsonLd = {
  "@context": "https://schema.org",
  "@type": "Article",
  headline: article.title,
  datePublished: article.publishedAt,
  dateModified: article.updatedAt,
  image: article.images,
  author: {
    "@type": "Person",
    name: article.author.name,
    url: `https://example.com/authors/${article.author.slug}`
  },
  publisher: {
    "@type": "Organization",
    name: "Example",
    logo: {
      "@type": "ImageObject",
      url: "https://example.com/logo.png"
    }
  },
  mainEntityOfPage: {
    "@type": "WebPage",
    "@id": `https://example.com/blog/${article.slug}`
  }
};
---

<script type="application/ld+json" set:html={JSON.stringify(jsonLd)}></script>
```

`set:html` is critical — without it Astro escapes the JSON.

### 6.2 Nuxt

```ts
// composables/useArticleJsonLd.ts
export function useArticleJsonLd(article: Article) {
  useHead({
    script: [
      {
        type: 'application/ld+json',
        innerHTML: JSON.stringify({
          '@context': 'https://schema.org',
          '@type': 'Article',
          headline: article.title,
          datePublished: article.publishedAt,
          dateModified: article.updatedAt,
          image: article.images,
          author: {
            '@type': 'Person',
            name: article.author.name,
            url: `https://example.com/authors/${article.author.slug}`
          },
          publisher: {
            '@type': 'Organization',
            name: 'Example',
            logo: {
              '@type': 'ImageObject',
              url: 'https://example.com/logo.png'
            }
          }
        })
      }
    ]
  });
}
```

Or use `@nuxtjs/seo` / `nuxt-schema-org` for typed builders.

### 6.3 Next.js (App Router)

```tsx
// app/blog/[slug]/page.tsx
export default async function Page({ params }) {
  const article = await getArticle(params.slug);

  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: article.title,
    datePublished: article.publishedAt,
    dateModified: article.updatedAt,
    image: article.images,
    author: {
      '@type': 'Person',
      name: article.author.name
    },
    publisher: {
      '@type': 'Organization',
      name: 'Example'
    }
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <article>…</article>
    </>
  );
}
```

`dangerouslySetInnerHTML` is the safe pattern here — JSON-LD must not be JSX-escaped.

### 6.4 Static HTML

Just write the `<script>` tag.

---

## 7. Dynamic per-page generation

A typed builder beats hand-written JSON for any non-trivial site.

### Pattern — typed builder

```ts
// lib/jsonld.ts
import type { Article, Person } from 'schema-dts';

export function articleJsonLd(input: {
  url: string;
  title: string;
  description: string;
  publishedAt: string;
  updatedAt: string;
  images: string[];
  author: { name: string; url: string };
}): Article {
  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: input.title,
    description: input.description,
    image: input.images,
    datePublished: input.publishedAt,
    dateModified: input.updatedAt,
    author: { '@type': 'Person', name: input.author.name, url: input.author.url },
    publisher: {
      '@type': 'Organization',
      name: 'Example',
      logo: { '@type': 'ImageObject', url: 'https://example.com/logo.png' }
    },
    mainEntityOfPage: { '@type': 'WebPage', '@id': input.url }
  };
}
```

`schema-dts` (npm) provides full TypeScript types for Schema.org. Use it.

### Avoid hand-written JSON in templates

Repeated literal JSON blocks inevitably drift. Centralize into a builder per type.

---

## 8. Mismatch prevention — JSON must match visible content

Google explicitly states that structured data must reflect the visible page. Mismatches disqualify rich results and risk a manual action.

### Sources of drift

- Article publishes; engineer hardcodes `datePublished` in template; never updates.
- Product price changes in CMS but JSON-LD generator caches the old price.
- Aggregate rating displayed as 4.7 stars; JSON-LD says 4.9.
- FAQ added in JSON-LD without adding the question/answer to the page body.
- Author byline shows "Jane Doe"; JSON-LD `author.name` says "Editorial team".

### Defense

- **One source of truth per fact.** Visible price → CMS field → both the visible UI and the JSON-LD builder read from the same field.
- **Snapshot tests.** A test that loads each page type, extracts JSON-LD and visible facts, and diffs them. Fail the build on disagreement.
- **CI rule**: never hardcode prices, dates, or ratings in templates.
- **Per-PR check**: when a CMS field changes, the JSON-LD output diff is visible.

```bash
# Example snapshot extractor
node -e '
  const { JSDOM } = require("jsdom");
  const html = require("fs").readFileSync(process.argv[2], "utf8");
  const dom = new JSDOM(html);
  const blocks = dom.window.document.querySelectorAll(\"script[type=\\\"application/ld+json\\\"]\");
  for (const b of blocks) console.log(JSON.parse(b.textContent));
' page.html
```

---

## 9. JSON-LD + Microdata together

If both formats ship on the same page (legacy templates + new JSON-LD):

- **Pick one as the source of truth per fact.** JSON-LD typically wins because it's centralized.
- **Don't ship contradictory data.** Engines pick the conservative option (drop the entity).
- **Long-term goal**: migrate fully to JSON-LD; phase out the inline Microdata as templates are touched.

---

## 10. Anti-patterns — never ship

- ❌ Invalid JSON (trailing commas, single quotes, comments).
- ❌ Hidden facts that aren't visible on the page (especially aggregate ratings, FAQ entries).
- ❌ Visible price `$129`; JSON-LD price `99`. Mismatch.
- ❌ FAQ in JSON-LD that doesn't appear in the page body.
- ❌ `dateModified` hardcoded in a template, never updated.
- ❌ JSON-LD only injected after JS hydration (Googlebot may miss it).
- ❌ Multiple entities of the same type that should have been one (`Organization` declared on every page with different content).
- ❌ Generic `Article` when a more specific type exists (`NewsArticle`, `BlogPosting`).
- ❌ Generic `Place` for a business that should be `LocalBusiness` (or a subtype).
- ❌ Wrong duration / date formats. Use ISO 8601 (`PT30M`, `2026-04-12T09:00:00Z`).
- ❌ `aggregateRating` without a visible rating UI.
- ❌ `Review` blocks fabricated to inflate apparent ratings.
- ❌ JSON-LD `image` as a string when an array is expected (Article/Recipe/Product expect 1×1, 4×3, 16×9 variants).
- ❌ `@id` collisions — two entities with the same `@id` referring to different things.
- ❌ Forgetting to `JSON.stringify` and shipping `[object Object]`.
- ❌ JSX rendering JSON-LD without `dangerouslySetInnerHTML` (HTML entities mangle the JSON).
- ❌ `astro:set:html` missing — Astro otherwise escapes the JSON content.
- ❌ JSON-LD that the Rich Results Test passes but contradicts the page anyway.
- ❌ Adding JSON-LD without testing in Rich Results Test.
- ❌ Same JSON-LD on every page (e.g. the homepage Article schema cloned to all routes).

---

## 11. Validation checklist

### Validity

- [ ] JSON parses (no trailing commas, single quotes, comments).
- [ ] `@context` set to `https://schema.org`.
- [ ] Each entity has a valid `@type`.
- [ ] Server-rendered, not client-only injected.
- [ ] No HTML escaping of the JSON content.

### Coverage by page type

- [ ] Article pages: `Article` (or subtype) + `BreadcrumbList` + (optional) `FAQPage`.
- [ ] Product pages: `Product` with `offers`, `aggregateRating` (if reviews exist), `review` (sample).
- [ ] Author profiles: `Person` with `sameAs`.
- [ ] Site-wide: `Organization` + `WebSite` (with `SearchAction` if internal search exists).
- [ ] Local business: most-specific `LocalBusiness` subtype with `address`, `geo`, `telephone`, `openingHoursSpecification`, `priceRange`.
- [ ] Recipes: `Recipe` with `recipeIngredient`, `recipeInstructions`, durations, image array.
- [ ] Events: `Event` with `startDate`, `location`, `eventStatus`, `eventAttendanceMode`, `offers`.
- [ ] Job listings: `JobPosting` with `validThrough`.

### Consistency

- [ ] Every structured value matches its visible counterpart (price, currency, availability, rating, review count, dates, author, FAQ Q&A).
- [ ] No facts that exist only in JSON-LD.
- [ ] If Microdata also present, no conflicts.

### Identity

- [ ] Site-wide `Organization` and `WebSite` declared once with stable `@id`.
- [ ] Per-page entities use `@id` with page-URL fragment (`#article`, `#breadcrumb`, `#image`).
- [ ] References to other entities use `{ "@id": "…" }` form.

### Rich-result eligibility

- [ ] Rich Results Test passes for every page type that ships eligible markup.
- [ ] Image arrays provided in 1:1, 4:3, 16:9 where Google requires.
- [ ] Required properties for the targeted rich result feature all present.

### Framework / SSR

- [ ] JSON-LD appears in server-rendered HTML.
- [ ] Astro: `set:html` used on the script tag.
- [ ] React/Next: `dangerouslySetInnerHTML` used.
- [ ] Vue/Nuxt: `innerHTML` (not `textContent`) used.
- [ ] Type-safe builder in use; no hand-written JSON in templates.

### Severity guide

- `high` — invalid JSON, hidden facts, mismatched price/rating/availability, JSON-LD client-only injected, missing required properties for a targeted rich result.
- `medium` — generic types where specific exists, image array missing required aspect ratios, `dateModified` hardcoded / stale, multiple sources of truth.
- `low` — sub-optimal `@id` strategy, missing optional fields (`sameAs`, `description`), hand-written JSON instead of typed builder.

---

## 12. Validation tools and commands

```bash
# Google Rich Results Test (per page)
# https://search.google.com/test/rich-results

# Schema.org Markup Validator (no Google constraints)
# https://validator.schema.org/

# Extract JSON-LD from a page
curl -s "$URL" \
  | grep -oP '<script[^>]*type="application/ld\+json"[^>]*>[^<]+</script>' \
  | sed -E 's#<script[^>]*>##; s#</script>##'

# Validate JSON
curl -s "$URL" \
  | grep -oP '<script[^>]*type="application/ld\+json"[^>]*>[^<]+</script>' \
  | sed -E 's#<script[^>]*>##; s#</script>##' \
  | jq .

# Use python extruct
python3 -c '
import sys, extruct, json
data = extruct.extract(sys.stdin.read(), syntaxes=["json-ld"])
print(json.dumps(data, indent=2))
' < page.html

# Diff visible facts vs JSON-LD facts (snapshot test)
# Wire to your test framework; pseudo:
node tests/structured-data-snapshot.js https://example.com/blog/inp-guide
```

### Tools

- **Google Rich Results Test** — primary test for rich-result eligibility.
- **Schema.org Markup Validator** — no Google constraints, broader vocabulary check.
- **`schema-dts` (npm)** — TypeScript types for every Schema.org type.
- **`structured-data-testing-tool` (npm)** — programmatic validation against custom rules.
- **Search Console → Enhancements** — per-type indexed counts and errors.
- **Yoast structured-data block validators** — useful baseline if using WordPress.

---

## 13. Output format

When asked to **generate** JSON-LD, return:

1. The complete `<script type="application/ld+json">` block(s) for the requested entities, using the right Schema.org type and the patterns from section 3.
2. A note on which properties are required vs recommended for the targeted rich result feature.
3. Open questions for any field that needs project input (canonical URL, author URL, image variants, organization @id).
4. A pointer to test the URL in the Rich Results Test.

When asked to **audit** existing JSON-LD, return:

```text
# JSON-LD Audit — <URL or template>

## Summary
- Entities detected: <count by type>
- @graph used: <yes/no>
- @id strategy: <consistent/missing>
- Visible/structured mismatches: <count>
- Missing required properties: <count by type>
- Rich Results Test: <pass/fail per type>
- SSR coverage: <yes/no>
- Overall: <PASS | NEEDS WORK | FAIL>

## Findings
**[HIGH]** <entity / property> — <issue> — <recommended fix>
**[MEDIUM]** ...
**[LOW]** ...

## Recommended fix order
1. ...
```

Then offer to apply each fix. Apply approved fixes one at a time, confirming each.
