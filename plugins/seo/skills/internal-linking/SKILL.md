---
description: Internal linking strategy for SEO and topical authority — site architecture (hub-and-spoke / topic clusters), anchor-text variety, contextual links, link equity flow, orphan detection, breadcrumbs, navigation patterns, related-content blocks, broken-link hygiene, and a validation checklist for auditing a site's link graph.
---

# Internal linking — site architecture and link equity

Internal links are the cheapest, most controllable SEO signal. They tell crawlers what's important, distribute ranking signal (PageRank-equivalent) across the site, and define topical relationships that LLM-based search uses for entity disambiguation. A well-linked content site can outrank a heavier-but-flatter competitor.

This skill is about **the link graph**: which pages link to which, with what anchor text, in what positions, and what gets crawled vs ignored.

For the per-link HTML rules (anchor text, `rel` attributes) see `seo-page-structure`. For URL hygiene see `url-structure`. This skill is the **strategy layer**.

---

## 1. The mental model

A search engine treats internal links as votes:

- A link from A to B says "A thinks B is relevant".
- The vote's weight depends on **A's own authority** (ultimately rooted in external links).
- Anchor text **describes B** — it's a topical signal nearly as strong as B's own H1.
- Link **position** matters: a link in the body counts more than a link in the footer.
- A link from a **topically related** page counts more than from an unrelated page.
- **Crawl budget** flows through links — pages that aren't reachable from the home page within ~3 clicks are crawled less often.

Three corollaries:

1. **Every important page must be reachable in ≤ 3 clicks from the home page.**
2. **Anchor text on internal links is a free SEO signal — most teams waste it.**
3. **Orphan pages (no internal links pointing to them) get de-indexed.** Find and fix them.

---

## 2. Site architecture — hub-and-spoke / topic clusters

The dominant pattern for content sites since ~2017. One pillar page per major topic, surrounded by detail pages.

```text
                   Home
                    │
                    ▼
         ┌──────────────────────┐
         │   Pillar (Hub)       │  "What is INP?"
         │   /performance/inp   │  long, comprehensive
         └──────────────────────┘
            │  ▲      │  ▲
            ▼  │      ▼  │
     ┌────────┐    ┌────────┐
     │ Spoke  │    │ Spoke  │   "How to measure INP"
     │        │    │        │   "Common INP causes"
     └────────┘    └────────┘   "INP fixes for React"
```

Rules:

- **Pillar links to every spoke.** Spokes link back to the pillar.
- **Spokes link to each other** when contextually relevant (related sub-topics).
- **Pillar URL is short and stable** (`/performance/inp`); spoke URLs sit underneath (`/performance/inp/measuring`, `/performance/inp/react`).
- **Pillar is the canonical answer** to the broad query; spokes target long-tail queries.

### Sizing the cluster

A healthy cluster has 5–15 spokes per pillar. Fewer than 5 → the topic is thin; merge into a sibling cluster. More than 15 → split into sub-pillars, or the cluster has lost focus.

---

## 3. The link types you control

| Type | Purpose | Authority weight |
|------|---------|------------------|
| **Primary navigation** | Discoverability, structure | Low per link (every page has it) — but crawl-friendly |
| **Breadcrumbs** | Hierarchy, context | Low — but engines extract them as `BreadcrumbList` |
| **Body / contextual** | Topical relevance, ranking signal | **Highest** — most important type |
| **Hub / index pages** | Topic-cluster aggregation | High when authoritative |
| **Related-content blocks** | Cross-pollination, dwell time | Medium |
| **Pagination** | Crawl reach for paginated content | Low; necessary for deep archives |
| **Footer** | Site-wide pages (legal, about) | Low — diluted by being on every page |

The single highest-value lever is **contextual body links**. A team that adds 3–8 well-anchored body links per article will out-rank one that doesn't, all else equal.

---

## 4. Anchor text — the most-wasted SEO signal

Every internal link's anchor text is a chance to tell the engine what the destination is about.

### Rules

- **Descriptive, not generic.** "Read the INP optimization guide" beats "click here", "read more", "this article".
- **Vary the anchor text** across the site for the same destination. Always the same anchor → keyword-stuffing penalty risk. Use natural variations: "INP optimization guide", "guide to fixing INP", "how to optimize INP".
- **Match the destination's primary topic** but don't keyword-stuff. The anchor describes the link's destination as a human would phrase it.
- **Avoid bare URLs as anchors** (`https://example.com/inp`) — wastes the signal.
- **Don't link to the same destination twice in the same paragraph.** The first link is the one engines weight.
- **The first link from a page to a destination wins.** A second link to the same URL on the same page is largely ignored. If the choice is between linking with strong anchor text in the body or weak anchor text in a sidebar, put the strong one first in source order.

### Bad

```html
<p>For more details, <a href="/inp-guide">click here</a>.</p>
<p>You can also <a href="/inp-guide">read this</a>.</p>
```

### Good

```html
<p>For details on the 200 ms threshold, see the
   <a href="/blog/inp-guide">INP optimization guide</a>.</p>
```

### Anchor variety pattern

For a destination at `/blog/inp-guide`, healthy anchor distribution might look like:

```text
30%  "INP optimization guide"
20%  "guide to fixing INP"
15%  "how to optimize INP"
15%  "the INP guide"
10%  "INP best practices"
10%  other natural variants
```

Auditable via `link-checker` tools that report anchor text per destination.

---

## 5. Contextual link patterns

Where to put links inside an article body.

### Inline body links (highest value)

Embedded in sentences where the topic is mentioned, anchor describes the destination:

```html
<p>
  INP replaced
  <a href="/blog/fid-deprecation">First Input Delay</a>
  as a Core Web Vital in March 2024.
</p>
```

### "See also" / "Learn more" callouts

A bordered block inside the article pointing at related content:

```html
<aside class="callout">
  <p><strong>Related:</strong>
    <a href="/blog/long-tasks">Breaking up long tasks</a>
    is the highest-leverage INP fix.</p>
</aside>
```

### End-of-article "Next steps"

Numbered list of 3–5 logical follow-up reads:

```html
<section aria-labelledby="next-steps">
  <h2 id="next-steps">Next steps</h2>
  <ol>
    <li><a href="/blog/measuring-inp">Measure INP on your site</a></li>
    <li><a href="/blog/inp-react">Optimize INP for React apps</a></li>
    <li><a href="/blog/web-vitals-monitoring">Set up Web Vitals monitoring</a></li>
  </ol>
</section>
```

### Density target

3–8 internal links per 1,000 words on a typical content article. More than 12 looks like spam to readers and engines.

---

## 6. Related-content blocks

The "Related articles" / "You might also like" sidebar or footer of an article.

### Rules

- **Topically related**, not just chronologically recent. A "latest posts" widget on every article is weaker than a curated related list.
- **3–6 items.** More dilutes the signal.
- **Generated from explicit metadata** (tags, content-cluster mapping) when possible; not just "newest 5 in the same category".
- **Avoid `noindex,follow`** on the parent article's tags — engines do follow these links.
- **Don't link to the same article from itself.** Filter the current URL out of the candidates.

### Pattern

```html
<aside aria-labelledby="related">
  <h2 id="related">Related articles</h2>
  <ul>
    <li>
      <a href="/blog/measuring-inp">
        <span>How to measure INP in production</span>
      </a>
    </li>
    <li>
      <a href="/blog/inp-react">
        <span>Optimizing INP in React apps</span>
      </a>
    </li>
  </ul>
</aside>
```

---

## 7. Crawl reach — the 3-click rule

Every page that should rank must be **reachable from the home page in 3 clicks or fewer**. Pages that take 4+ clicks are crawled less often, indexed less reliably, and less competitive in search.

### Diagnose

1. Crawl the site (Screaming Frog, Sitebulb, or a custom Playwright crawler).
2. For each indexable URL, record the shortest click-path from `/`.
3. Flag pages with path > 3.

### Fix

- **Add hub pages** for topic clusters. A pillar page becomes a 1-click jump that puts every spoke at 2 clicks.
- **Surface deep content from the home page** for newly published, high-priority articles.
- **Improve pagination + filtering**. Don't bury page 12 of an archive behind 11 "next" clicks; add jump-links.
- **Add cross-cluster links** so deep content in one cluster is reachable from others.

---

## 8. Orphan pages — the silent ranking killer

An orphan page has zero internal links pointing to it. It is in the sitemap (sometimes) but unreachable by crawl.

### Symptoms

- Indexed but ranking nowhere.
- High bounce rate via direct traffic only.
- Slow re-indexing after edits (no crawl signal to re-fetch).

### Detect

```bash
# Crawl the site, dump every URL and its inbound link count
# Pseudo — wire to a real crawler
crawl https://example.com --output edges.csv
awk -F, '{print $2}' edges.csv | sort | uniq -c | sort -n | head -50
# URLs with count 0 (or only sitemap entry) are orphans
```

Tools: Screaming Frog ("Orphan Pages" report), Sitebulb, Ahrefs Site Audit, or a custom crawler that compares the sitemap URL set against the URLs reachable from `/`.

### Fix

- Add at least one body link from a topically related page.
- Add to the appropriate hub / pillar.
- Add to the related-content list of an established article.
- If the page genuinely shouldn't be indexable, `noindex` it and remove from the sitemap — don't leave it adrift.

---

## 9. Link equity flow

PageRank-equivalent flows along internal links. Some practical rules:

- **A link from a high-authority page is worth more.** The home page, the pillar pages, and pages with strong external links pass more equity.
- **A page divides its outbound equity among its links.** A page with 100 outbound links passes less per link than a page with 20.
- **`nofollow` was historically used to block equity flow on internal links** ("PageRank sculpting"). Google now treats internal `nofollow` as a hint and may still pass equity. Don't try to sculpt — write fewer, more focused links.
- **Footer links to legal/about pages bleed equity.** That's fine — those pages need a small amount and the dilution is acceptable.
- **404s and redirect chains lose equity.** A link to a 404 passes nothing; a link to a redirect loses some at each hop.

### Rules of thumb

- **Important destinations get linked from many pages**, with descriptive anchors, in the body.
- **The home page is the most powerful linker.** Don't waste its link slots on auto-rotating banners that link to the same place every day.
- **Pillar pages link out generously** (5–15 spokes) and get linked back generously.
- **Keep total outbound link count per page reasonable** — content sites: < 100 internal links per page; product/category: < 200 (because of category nav).

---

## 10. Navigation patterns

### Primary navigation

- **Stable across the site.** Engines learn the structure faster.
- **Includes the top-level topic pillars**, not just transactional pages.
- **Uses descriptive anchors** in the nav itself ("Performance" not "Resources").
- **Rendered as `<nav aria-label="Primary"><ul>…</ul></nav>`** so engines extract the structure.
- **Don't put critical pillars in a hamburger menu only** on desktop.

### Footer navigation

- **Site map–like.** A footer that lists every top-level category gives engines a complete reachability map even when primary nav is shallow.
- **Group by category** with `<nav aria-label="Footer">` and headings.
- **Don't link to every page in the site.** "Mega footers" with 200+ links dilute equity.

### Breadcrumbs

Required on every non-home page. See `seo-page-structure` for the markup.

```text
Home → Blog → Performance → What is INP?
```

Rules:

- Mirror URL hierarchy.
- Each crumb is a real, indexable page.
- Last item is the current page, not linked.
- Wrapped in `<nav aria-label="Breadcrumb">` with `BreadcrumbList` schema.

---

## 11. Pagination

For long archives (blog index page 5, category page 12), pagination is the only way crawlers reach deep entries.

### Rules

- **Each paginated page self-canonicals.** Don't canonical page 2 → page 1 (hides page 2's content).
- **Visible "previous / next" links**, with descriptive anchor text ("Page 2 of articles") not just "Next".
- **Optional `<link rel="prev">` / `<link rel="next">`** in `<head>` — Google deprecated them as a signal but they're harmless and still understood by some engines.
- **Add jump-links** ("Page 1, 2, 3, …, 12") so the user (and crawler) can reach the last page without 11 clicks.
- **Each paginated page has a unique title** ("Performance articles — page 3 | Example").

### Don't

- ❌ Replace pagination with infinite scroll without a non-JS fallback. Crawlers don't fire scroll events.
- ❌ Use `?page=N` AND `/page/N` — pick one URL form and stick with it.

---

## 12. Tags, categories, and faceted navigation

Tag and category pages can be powerful hubs — or thin-content drains.

### Rules

- **Categories are top-level, planned, and few** (usually < 30). They are pillars of their own.
- **Tags are flat and many.** Most tag pages are thin (<5 posts) and dilute the index — `noindex,follow` them by default; index only tags with substantial post counts (> 10).
- **Faceted URLs** (`?color=red&size=lg`) are crawl traps. `noindex` them or canonical to the unfiltered URL.
- **A category with one or two posts is not a category.** Merge or delete.

### Pattern

```html
<head>
  <!-- Tag with ≥ 10 posts -->
  <meta name="robots" content="index,follow,max-image-preview:large">

  <!-- Tag with < 10 posts -->
  <meta name="robots" content="noindex,follow">
</head>
```

---

## 13. Broken links and redirect chains

Internal links to 404s or chained redirects waste crawl budget and lose equity.

### Detect

```bash
# Crawl the site, find broken internal links
npx broken-link-checker https://example.com -ro --filter-level 0

# Find redirect chains
curl -sILo /dev/null -w '%{http_code} %{url_effective}\n' https://example.com/some-page
```

Or use Screaming Frog (Internal → Status Code = 404 / 301).

### Fix

- **Update the link** to point at the new URL (don't rely on the redirect).
- **Collapse redirect chains** to a single hop. A → B → C → D should become A → D.
- **Repurpose 404'd URLs**: redirect to the closest equivalent live page (301), not to the home page (Google treats home-page redirects as "soft 404").

---

## 14. Anti-patterns — never ship

- ❌ "Click here" / "Read more" / "Learn more" anchor text.
- ❌ Linking to the same destination 5× on one page hoping for stacked signal — only the first counts.
- ❌ Hiding important pages 5+ clicks deep.
- ❌ Orphan pages indexed in the sitemap but unlinked from any content.
- ❌ Tag pages with 1–2 posts indexed (thin content).
- ❌ Faceted URLs (`?sort=`, `?filter=`) indexed without canonicalization.
- ❌ Internal `nofollow` to "save PageRank" — doesn't work and looks adversarial.
- ❌ Mega-footer with 300 links to every page on the site.
- ❌ Auto-rotating hero linking to the same destination every day, wasting the home page's most valuable link slot.
- ❌ Pagination via infinite-scroll-only with no non-JS fallback.
- ❌ Broken internal links left in production for weeks.
- ❌ Redirect chains > 1 hop.
- ❌ Pillar pages with no internal links to their spokes (or vice versa).
- ❌ Same anchor text every time for the same destination across the entire site (looks manipulative).
- ❌ Bare URL as anchor text (`https://example.com/inp` rendered as the link text).
- ❌ Linking to staging or preview URLs by accident.
- ❌ Using JS-only navigation that doesn't render server-side links — crawlers may not see them.

---

## 15. Validation checklist

### Architecture

- [ ] Every indexable page reachable in ≤ 3 clicks from the home page.
- [ ] Each major topic has a pillar page with 5–15 spokes.
- [ ] Pillar pages link to every spoke; spokes link back.
- [ ] Spokes link to topically adjacent spokes when relevant.
- [ ] No orphan pages (or all orphans are intentionally `noindex`).

### Anchor text

- [ ] No "click here" / "read more" anchors on internal links.
- [ ] Anchor text describes the destination.
- [ ] Anchor text varies across pages for the same destination.
- [ ] No bare URL anchors.

### Density and placement

- [ ] 3–8 internal body links per 1,000 words on content articles.
- [ ] First link to a destination is in the body, with strong anchor.
- [ ] Related-content block on every article (3–6 topically related items).
- [ ] Breadcrumbs on every non-home page.

### Navigation

- [ ] Primary nav stable across the site, includes pillars.
- [ ] Footer nav covers top-level categories.
- [ ] Pagination on archives includes jump-links to far pages.
- [ ] Each paginated page self-canonicals; unique title.
- [ ] Tags with < 10 posts are `noindex,follow`.
- [ ] Faceted URLs canonicalized or `noindex`.

### Hygiene

- [ ] Zero broken internal links (404s).
- [ ] Zero redirect chains > 1 hop.
- [ ] No links to staging / preview URLs.
- [ ] No internal `nofollow` (unless explicitly justified).
- [ ] Server-rendered links (not JS-only navigation).

### Tooling

- [ ] Site crawl run weekly; orphan + broken-link reports reviewed.
- [ ] Anchor-text distribution per destination spot-checked.
- [ ] CI / monitoring catches new broken links before deploy.

### Severity guide

- `high` — orphan pages indexed, important destinations unreachable in ≤ 3 clicks, generic anchor text site-wide, broken internal links in nav, infinite-scroll-only pagination.
- `medium` — same anchor text every time, thin tag pages indexed, related-content block missing, 4-hop redirect chains, faceted URLs not canonicalized.
- `low` — sub-optimal anchor variety, footer links could be tighter, breadcrumbs missing on a small page type.

---

## 16. Validation tools and commands

```bash
# Crawl and dump link graph
npx screamingfrog --crawl https://example.com --export-tabs internal,external

# Find orphan pages (sitemap URLs minus reachable URLs)
comm -23 <(curl -s https://example.com/sitemap.xml | grep -oP '(?<=<loc>)[^<]+' | sort) \
         <(node crawler.js https://example.com | sort)

# Find broken internal links
npx broken-link-checker https://example.com -ro

# Anchor-text audit
node -e '
  const cheerio = require("cheerio");
  const fetch = (await import("node-fetch")).default;
  const html = await (await fetch(process.argv[1])).text();
  const $ = cheerio.load(html);
  $("a[href^=\"/\"], a[href^=\"https://example.com\"]").each((i, a) => {
    console.log(`${$(a).attr("href")}\t${$(a).text().trim()}`);
  });
' "https://example.com/blog/inp-guide" | sort | uniq -c

# Click-depth analysis
# (Screaming Frog: View → Site Structure → Crawl Depth)
```

### Tools

- **Screaming Frog SEO Spider** — most complete site crawl + orphan detection.
- **Sitebulb** — visual link graph + auditing.
- **Ahrefs / Semrush Site Audit** — internal link reports.
- **Google Search Console → Links → Internal links** — Google's view of your link graph.
- **PageRankCheck (open-source)** — recompute internal PageRank from your own crawl.

---

## 17. Output format

When asked to **plan** internal linking for a topic or site, return:

1. The cluster map: pillar URL + 5–15 spoke URLs with topics.
2. The link plan: which pillar links to which spoke and vice versa, with proposed anchor text.
3. Cross-cluster links: 1–3 outbound from each spoke to topically adjacent spokes in other clusters.
4. The home-page surface: which pillars and recent articles get linked from `/`.
5. Open questions: existing content gaps, URLs that need to be created or merged.

When asked to **audit** internal linking, return:

```text
# Internal Linking Audit — <site or section>

## Summary
- Pages crawled: <count>
- Indexable orphans: <count>
- Pages > 3 clicks deep: <count>
- Broken internal links: <count>
- Redirect chains > 1 hop: <count>
- Most-linked destination: <url, link count>
- Top generic anchors used: <list>
- Overall: <PASS | NEEDS WORK | FAIL>

## Findings
**[HIGH]** <page or destination> — <issue> — <recommended fix>
**[MEDIUM]** ...
**[LOW]** ...

## Recommended fix order
1. ...
```

Then offer to apply each fix. Apply approved fixes one at a time, confirming each.
