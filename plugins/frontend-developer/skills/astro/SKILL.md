---
description: Astro best practices — Islands Architecture, component hydration, content collections, rendering modes, performance, and SEO.
---

# Astro Best Practices

## Islands Architecture — The Core Concept

Astro ships **zero JavaScript by default**. Every component renders to static HTML unless you explicitly opt into interactivity with a `client:*` directive. Each interactive component is an isolated "island" hydrated independently.

```text
┌──────────────────────────────────────────────────────┐
│  Static HTML (no JS)                                 │
│  ┌─────────────────┐   ┌──────────────────────────┐  │
│  │  Island         │   │  Island                  │  │
│  │  client:load    │   │  client:visible           │  │
│  │  (hydrates now) │   │  (hydrates on scroll-in)  │  │
│  └─────────────────┘   └──────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

### Hydration Directives — Choose the Right One

| Directive | When it hydrates | Use for |
|-----------|-----------------|---------|
| `client:load` | Immediately on page load | Above-the-fold interactive UI |
| `client:idle` | When browser is idle | Secondary UI, non-critical widgets |
| `client:visible` | When component enters viewport | Below-the-fold, carousels, accordions |
| `client:media="(query)"` | When media query matches | Mobile-only menus, responsive interactions |
| `client:only="framework"` | Client-only, skips SSR | Components that cannot run on server |

```astro
---
import Counter from '../components/Counter.tsx'
import HeavyChart from '../components/HeavyChart.vue'
import MobileNav from '../components/MobileNav.svelte'
---

<!-- Hydrates immediately — user needs this right away -->
<Counter client:load />

<!-- Hydrates when scrolled into view — saves JS on initial load -->
<HeavyChart client:visible />

<!-- Hydrates only on mobile viewports -->
<MobileNav client:media="(max-width: 768px)" />
```

### No Directive = No JavaScript

```astro
---
import Card from '../components/Card.tsx'
---

<!-- Renders as pure HTML — zero JS shipped -->
<Card title="Hello" description="Static content" />
```

---

## Project Structure

```text
src/
├── components/       # Reusable UI components (.astro, .tsx, .vue, etc.)
├── layouts/          # Page layout wrappers
├── pages/            # File-based routing — every file becomes a route
│   ├── index.astro   → /
│   ├── about.astro   → /about
│   └── blog/
│       ├── index.astro     → /blog
│       └── [slug].astro    → /blog/:slug
├── content/          # Content collections (Markdown, MDX, YAML, JSON)
└── styles/           # Global CSS
public/               # Static assets served as-is (images, fonts, robots.txt)
```

---

## Content Collections — Type-Safe Content

Define a schema for your Markdown/MDX content to get full TypeScript validation and auto-completion.

```ts
// src/content/config.ts
import { defineCollection, z } from 'astro:content'

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    author: z.string(),
    tags: z.array(z.string()).default([]),
    draft: z.boolean().default(false),
    cover: z.object({
      src: z.string(),
      alt: z.string(),
    }).optional(),
  }),
})

const docs = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    order: z.number(),
  }),
})

export const collections = { blog, docs }
```

```astro
---
// src/pages/blog/[slug].astro
import { getCollection, getEntry, render } from 'astro:content'

export async function getStaticPaths() {
  const posts = await getCollection('blog', ({ data }) => !data.draft)
  return posts.map((post) => ({
    params: { slug: post.slug },
    props: { post },
  }))
}

const { post } = Astro.props
const { Content, headings } = await render(post)
---

<article>
  <h1>{post.data.title}</h1>
  <time>{post.data.pubDate.toLocaleDateString()}</time>
  <Content />
</article>
```

---

## Rendering Modes

### Static (SSG) — Default

All pages pre-rendered at build time. Fastest delivery via CDN.

```ts
// astro.config.mjs
import { defineConfig } from 'astro/config'

export default defineConfig({
  // output: 'static'  ← default, can be omitted
})
```

### Server (SSR)

Pages rendered on every request. Required for dynamic, personalized, or auth-protected content.

```ts
// astro.config.mjs
import { defineConfig } from 'astro/config'
import node from '@astrojs/node'

export default defineConfig({
  output: 'server',
  adapter: node({ mode: 'standalone' }),
})
```

### Hybrid — Best of Both

Default to static, opt individual pages into SSR.

```ts
// astro.config.mjs
export default defineConfig({
  output: 'hybrid',  // most pages are static
  adapter: node({ mode: 'standalone' }),
})
```

```astro
---
// src/pages/dashboard.astro — opt this page into SSR
export const prerender = false

const user = Astro.locals.user
if (!user) return Astro.redirect('/login')
---
<h1>Welcome, {user.name}</h1>
```

---

## Astro Components

### Frontmatter — Server-Only JavaScript

Code in the `---` fence runs only on the server (or at build time). It never ships to the browser.

```astro
---
// This runs server-side only
import { getCollection } from 'astro:content'
import BlogCard from '../components/BlogCard.astro'

const posts = await getCollection('blog')
const recentPosts = posts
  .sort((a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf())
  .slice(0, 5)
---

{recentPosts.map((post) => (
  <BlogCard post={post} />
))}
```

### Props with TypeScript

```astro
---
interface Props {
  title: string
  description?: string
  variant?: 'primary' | 'secondary'
}

const { title, description, variant = 'primary' } = Astro.props
---

<div class:list={['card', `card--${variant}`]}>
  <h2>{title}</h2>
  {description && <p>{description}</p>}
</div>
```

### Slots

```astro
---
// src/layouts/BaseLayout.astro
interface Props {
  title: string
}
const { title } = Astro.props
---

<html lang="en">
  <head>
    <title>{title}</title>
    <slot name="head" />
  </head>
  <body>
    <header><slot name="header" /></header>
    <main><slot /></main>
    <footer><slot name="footer" /></footer>
  </body>
</html>
```

```astro
---
import BaseLayout from '../layouts/BaseLayout.astro'
---

<BaseLayout title="Home">
  <meta slot="head" name="description" content="My site" />
  <nav slot="header">...</nav>
  <p>Main content goes in the default slot.</p>
</BaseLayout>
```

---

## UI Framework Integration

Astro supports React, Vue, Svelte, Solid, Preact, and more — in the same project.

```ts
// astro.config.mjs
import { defineConfig } from 'astro/config'
import react from '@astrojs/react'
import vue from '@astrojs/vue'

export default defineConfig({
  integrations: [react(), vue()],
})
```

### Passing Data from Astro to Framework Components

```astro
---
import ReactSearch from '../components/Search.tsx'

const categories = await db.query('SELECT * FROM categories')
---

<!-- Server data flows down as props; component hydrates on client -->
<ReactSearch categories={categories} client:load />
```

### Sharing State Between Islands

Islands are isolated — they don't share a React/Vue tree. Use a **nano-store** (e.g., `nanostores`) for cross-island state.

```ts
// src/stores/cart.ts
import { atom, computed } from 'nanostores'

export interface CartItem { id: string; qty: number; price: number }

export const cartItems = atom<CartItem[]>([])
export const cartTotal = computed(
  cartItems,
  (items) => items.reduce((sum, i) => sum + i.price * i.qty, 0)
)

export function addToCart(item: CartItem) {
  cartItems.set([...cartItems.get(), item])
}
```

```tsx
// src/components/AddToCartButton.tsx
import { useStore } from '@nanostores/react'
import { cartItems, addToCart } from '../stores/cart'

export default function AddToCartButton({ product }) {
  const items = useStore(cartItems)
  return (
    <button onClick={() => addToCart(product)}>
      Add to Cart ({items.length})
    </button>
  )
}
```

```astro
<!-- Both islands share the same store state -->
<AddToCartButton product={product} client:load />
<CartIcon client:load />
```

---

## API Routes (Server Endpoints)

```ts
// src/pages/api/subscribe.ts
import type { APIRoute } from 'astro'

export const POST: APIRoute = async ({ request }) => {
  const body = await request.json()
  const { email } = body

  if (!email || !email.includes('@')) {
    return new Response(JSON.stringify({ error: 'Invalid email' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  await newsletter.subscribe(email)

  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  })
}

// Prerender this endpoint as a static JSON file
export const prerender = false
```

---

## Image Optimization

Use the built-in `<Image>` and `<Picture>` components — they optimize, resize, and convert images at build time.

```astro
---
import { Image, Picture } from 'astro:assets'
import heroImage from '../assets/hero.jpg'
---

<!-- Optimized image with fixed dimensions -->
<Image src={heroImage} alt="Hero" width={800} height={400} />

<!-- Art direction with multiple sources -->
<Picture
  src={heroImage}
  formats={['avif', 'webp']}
  alt="Hero"
  widths={[400, 800, 1200]}
  sizes="(max-width: 640px) 400px, (max-width: 1024px) 800px, 1200px"
/>
```

**Never** use raw `<img>` tags for local assets — you lose optimization and type-safety.

---

## SEO and `<head>` Management

```astro
---
// src/components/SEO.astro
interface Props {
  title: string
  description: string
  image?: string
  canonicalURL?: URL
}

const {
  title,
  description,
  image = '/og-default.png',
  canonicalURL = Astro.url,
} = Astro.props

const siteTitle = 'My Site'
---

<title>{title} | {siteTitle}</title>
<meta name="description" content={description} />
<link rel="canonical" href={canonicalURL} />

<!-- Open Graph -->
<meta property="og:title" content={title} />
<meta property="og:description" content={description} />
<meta property="og:image" content={new URL(image, Astro.site)} />
<meta property="og:url" content={canonicalURL} />
<meta property="og:type" content="website" />

<!-- Twitter -->
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content={title} />
<meta name="twitter:description" content={description} />
<meta name="twitter:image" content={new URL(image, Astro.site)} />
```

---

## Performance Best Practices

### Scoped Styles

Styles in `.astro` files are **automatically scoped** — they don't leak.

```astro
<style>
  /* Scoped to this component only */
  h1 { color: var(--color-primary); }
</style>

<style is:global>
  /* Escapes scoping — use sparingly */
  :root { --color-primary: #3b82f6; }
</style>
```

### Inline Critical CSS

```astro
---
import criticalCSS from '../styles/critical.css?raw'
---

<style set:html={criticalCSS} is:inline />
```

### View Transitions

```astro
---
import { ViewTransitions } from 'astro:transitions'
---

<head>
  <ViewTransitions />
</head>
```

```astro
<!-- Name elements for matched transitions between pages -->
<img transition:name={`hero-${post.slug}`} src={post.cover} alt="" />
```

---

## Middleware

```ts
// src/middleware.ts
import { defineMiddleware } from 'astro:middleware'

export const onRequest = defineMiddleware(async (context, next) => {
  const { request, locals, cookies } = context

  // Attach user to locals for use in pages and API routes
  const token = cookies.get('session')?.value
  if (token) {
    locals.user = await validateSession(token)
  }

  // Protect routes
  const isProtected = request.url.includes('/dashboard')
  if (isProtected && !locals.user) {
    return context.redirect('/login')
  }

  return next()
})
```

```ts
// src/env.d.ts — extend locals type
declare namespace App {
  interface Locals {
    user: { id: string; name: string; email: string } | null
  }
}
```

---

## Audit Checklist

1. **Using `client:load` everywhere** — most islands don't need to hydrate immediately; prefer `client:visible` or `client:idle` to reduce initial JS
2. **Fetching data inside a framework component** — data fetching belongs in the Astro frontmatter (server-side); pass results as props to keep islands thin
3. **Cross-island state via props drilling or custom events** — use `nanostores` or another framework-agnostic store to share state between islands
4. **Raw `<img>` tags for local images** — use `<Image>` from `astro:assets` to get automatic optimization, correct dimensions, and format conversion
5. **No content collection schema** — unvalidated frontmatter causes runtime errors; always define a Zod schema in `src/content/config.ts`
6. **Server secrets in client components** — environment variables accessed inside `client:*` components are bundled and exposed; keep secrets in server-only frontmatter or API routes
7. **Importing heavy libraries at the top of `.astro` files** — if a library is only used in a client island, import it inside that island component to avoid bundling it into server output
8. **Missing `prerender = false` on dynamic SSR pages in hybrid mode** — pages that depend on request-time data must explicitly opt out of prerendering
9. **No `<ViewTransitions />` with full page navigations** — without view transitions, every navigation is a full reload; add the component to your base layout for SPA-like navigation
10. **Forgetting `Astro.site` for absolute URLs in SEO tags** — og:image and canonical URLs must be absolute; use `new URL(path, Astro.site)` to construct them correctly
