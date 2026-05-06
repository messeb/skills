---
description: URL structure for SEO — slug formatting (lowercase, hyphens, length), trailing-slash policy, depth and hierarchy, query parameters and faceted URLs, host canonicalization (apex vs www, HTTP vs HTTPS), 301 redirect strategy and chains, URL changes during migrations, multi-locale URL patterns, and a validation checklist for auditing existing URL hygiene.
---

# URL structure — designing URLs that survive

URLs are the single most permanent SEO surface. Every URL change risks breaking external links, internal links, indexed pages, social shares, and shared bookmarks. The cheapest URL strategy is the one you don't have to migrate.

This skill is about **how to design URLs from day one and how to fix them when you can't avoid a migration**. For sitemap discovery see `crawl-control`. For canonical tags see `meta-tags`. For internal-link strategy see `internal-linking`. This skill is the **URL-as-string layer**.

---

## 1. Principles

A good URL is:

1. **Predictable** — a user reading the URL out loud should guess what's on the page.
2. **Stable** — never changes after the page goes live, unless the page itself is fundamentally retitled or moved.
3. **Lowercase** — case-sensitive servers will treat `/Page` and `/page` as separate URLs.
4. **Hyphenated** — `-` is the standard word separator. Underscores work but hyphens are SEO-canonical.
5. **Short** — under ~75 characters where possible. Long URLs get truncated in SERPs and shared previews.
6. **Hierarchical** — the path mirrors site structure: `/category/sub-category/page`.
7. **Free of session, tracking, or filter junk** — those go in query parameters that are stripped from canonicals.
8. **ASCII-safe** — non-ASCII characters work technically but break copy/paste in many contexts. Transliterate.
9. **Free of file extensions** when possible — `/blog/inp-guide` over `/blog/inp-guide.html`.

The default URL pattern for a content site:

```text
https://example.com/<category>/<slug>
```

For an article: `https://example.com/blog/inp-guide`. For a product: `https://example.com/products/acme-pro-mouse`. Consistent, predictable.

---

## 2. Slug formatting

The slug is the last path segment — the human-readable identifier of the page.

### Rules

- **Lowercase only.**
- **Hyphens between words** — never underscores, spaces, or camelCase.
- **No stop words unless they change meaning.** "the", "and", "of", "in" can usually be dropped: `inp-optimization-guide` over `the-inp-optimization-guide`.
- **No dates in slugs** (unless the date is core to the content, e.g. an annual report). `/blog/2026/05/inp-guide` rots; `/blog/inp-guide` doesn't.
- **No author in slugs** — use `/authors/<slug>` and link from the article.
- **No filler words.** `how-to-`, `the-best-`, `a-guide-to-` waste characters and look spammy.
- **Match the page topic, not the title verbatim.** The title can change; the slug should not.
- **30–60 characters of slug** is a good target. Longer is allowed but anything past 75 risks truncation.
- **No special characters.** `/blog/what-is-inp` not `/blog/what-is-inp%3F`.
- **Transliterate non-ASCII.** `/blog/cafe-au-lait` not `/blog/café-au-lait`. (Some sites do use IDN/Punycode and non-ASCII paths; this is fine for non-Latin scripts but stay consistent.)

### Examples

```text
✅ /blog/inp-guide
✅ /blog/measuring-core-web-vitals
✅ /products/acme-pro-mouse
✅ /authors/jane-doe

❌ /blog/INP_Guide.html
❌ /blog/2026/05/06/the-best-guide-to-inp-optimization-for-2026-and-beyond
❌ /Blog/INP-Guide
❌ /blog/inp%20guide
❌ /blog/?p=4837
```

### Multi-word product / brand names

Lowercase the brand name in the slug for consistency, even if the brand uses mixed case visually:

```text
✅ /products/acme-pro-mouse
   (Brand: "Acme Pro™ Mouse" — lowercase + hyphenate the slug)
```

---

## 3. Trailing slash — pick one

`/blog/inp-guide` and `/blog/inp-guide/` are technically different URLs. Engines treat them as duplicates, but only after they've crawled both. Pick a policy site-wide and enforce it.

### Two valid policies

- **No trailing slash** — `/blog/inp-guide`. Cleaner; mainstream for content sites.
- **Trailing slash** — `/blog/inp-guide/`. Common on directory-style hosting (Apache `mod_dir`).

### Rules regardless of which you pick

- **Be consistent across the entire site.** Mixed policies are the source of duplicate-URL bugs.
- **The non-canonical form must 301 to the canonical form.** A request to the wrong shape returns a permanent redirect to the right shape, not 200.
- **Internal links use the canonical shape.** Don't link to `/page` if your policy is `/page/`.
- **The canonical tag matches the served URL.** If you serve trailing-slash, the canonical includes the trailing slash.
- **Sitemap URLs match the canonical shape.**
- **The home page (`/`) always has a trailing slash.** That's the root, not a slug exception.

### Implement at the edge

```nginx
# nginx — strip trailing slashes (no-trailing-slash policy)
rewrite ^/(.*)/$ /$1 permanent;

# nginx — add trailing slashes (trailing-slash policy)
location / {
  if ($request_uri ~ ^([^.\?]*[^/])$) {
    return 301 $scheme://$host$1/;
  }
}
```

```js
// Cloudflare Worker / Vercel edge — no-trailing-slash
export default {
  async fetch(req) {
    const url = new URL(req.url);
    if (url.pathname.length > 1 && url.pathname.endsWith('/')) {
      url.pathname = url.pathname.slice(0, -1);
      return Response.redirect(url.toString(), 301);
    }
    return fetch(req);
  }
};
```

### Don't

- ❌ Serve both shapes with the same content (duplicate URLs).
- ❌ Switch policies after launch without a full 301 plan.
- ❌ Use 302 (temporary) for the slash redirect — it must be 301.

---

## 4. URL hierarchy and depth

### Rules

- **Keep depth shallow.** Three path segments is plenty: `/category/sub-category/page`. More than four is rare and usually the wrong shape.
- **Hierarchy mirrors taxonomy.** A spoke under a pillar lives under the pillar's path: `/performance/inp/measuring`, not `/blog/measuring-inp`.
- **Don't repeat segments.** `/blog/blog-posts/inp-guide` is redundant.
- **Stable parents.** Pages don't move between categories without a redirect plan.
- **The home page is `/`.** Not `/home`, not `/index.html`.

### Hierarchy patterns

```text
Content site / blog
  /
  /blog
  /blog/<slug>
  /tags/<tag-slug>
  /authors/<author-slug>
  /about
  /contact

E-commerce
  /
  /products
  /products/<category>
  /products/<category>/<sub-category>
  /products/<category>/<sub-category>/<product-slug>
  /cart
  /checkout

Documentation
  /
  /docs
  /docs/<section>
  /docs/<section>/<page>
  /api
  /api/<endpoint>

Local business / service
  /
  /services
  /services/<service-slug>
  /locations/<city>
  /about
  /contact
```

### Don't bury the date

```text
❌ /2026/05/06/inp-guide              (deep, date rots)
✅ /blog/inp-guide                    (flat, evergreen)

❌ /news/2026/05/06/google-inp-update (deep)
✅ /news/google-inp-update            (flat — let the page itself show the date)
```

A news site with thousands of articles can defensibly use `/year/slug` (`/2026/google-inp-update`) but rarely needs `/year/month/day/slug`.

---

## 5. Query parameters

Path is for identity. Query parameters are for state.

### Rules

- **Identity goes in the path.** `/products/acme-mouse` is the product. `?color=red` is a state of viewing it.
- **Filtering, sorting, paginating, tracking** go in query parameters.
- **Strip tracking parameters from canonicals.** `?utm_source=newsletter` should never appear in the canonical URL.
- **Decide which parameter combinations are indexable.** Most filtered URLs (`?color=red&size=large`) should not be indexed — they are crawl traps.
- **Sort parameters alphabetically** when generating URLs. `?a=1&b=2` not `?b=2&a=1`. Same parameters in different order create duplicates.
- **Don't put session IDs in URLs.** Use cookies. `/page?sid=abc123` is an indexable session.
- **Encode special characters properly.** `?q=hello%20world` not `?q=hello world`.

### Faceted navigation — the trap

E-commerce category pages with filters generate combinatorial URLs. `?color=red&size=lg&price=under-50&sort=newest` is one of millions.

#### Strategies

- **Canonical to the unfiltered URL.** `https://example.com/products/mice?color=red` has `<link rel="canonical" href="https://example.com/products/mice">`. Filtered version is crawled but not indexed.
- **`noindex` on heavily faceted URLs.** Better than canonical for combinations that have no SEO value at all.
- **Disallow filter parameters in `robots.txt`.** Saves crawl budget. See `crawl-control`.
- **Whitelist a small set of "SEO-worthy" filtered URLs.** `?color=red` for major colors might rank well; index those, `noindex` the rest.

### Pagination URL shape

- ✅ `/blog?page=2` (query parameter — easy to canonical and noindex)
- ✅ `/blog/page/2` (path-based — also fine, very common in WordPress)
- ❌ Both at the same time. Pick one.

### Tracking parameters — strip from canonicals

```text
?utm_source=newsletter&utm_medium=email     ← strip
?gclid=abc123                                ← strip (Google Ads)
?fbclid=xyz                                  ← strip (Facebook)
?msclkid=...                                 ← strip (Bing Ads)
?mc_cid=...&mc_eid=...                       ← strip (Mailchimp)
?ref=newsletter                              ← strip (referral attribution)
?utm_*                                       ← strip all utm_*
```

Cloudflare, Vercel, and most edge runtimes can strip these via a worker before the page is rendered. Or strip in the canonical-URL generator.

---

## 6. Host canonicalization

A site has many possible host forms; pick one canonical and 301 every other.

```text
http://example.com           ┐
http://www.example.com       │
https://example.com          ├─→  301 → https://www.example.com    (canonical)
https://www.example.com:443  ┘
```

### Rules

- **Pick HTTPS.** HTTP is no longer acceptable for any site.
- **Pick apex (`example.com`) or `www.example.com`** and stick with it. Either is fine; both are not.
- **Every non-canonical host returns 301** to the canonical.
- **Search Console treats hosts as separate properties.** Submit only the canonical; the others should be empty (because they redirect).
- **HSTS header** on the canonical host enforces HTTPS for repeat visitors.

```text
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
```

### Apex vs www — choosing

- **Apex** (`example.com`) — cleaner. Requires a CDN/DNS provider that supports apex CNAME (Cloudflare, Vercel, Netlify all do).
- **www** (`www.example.com`) — older convention; supports CDN flexibility (CNAME-only DNS).

For a new project: choose apex unless your DNS host can't CNAME apex (rare in 2026). For a legacy site: don't switch — the migration cost is rarely worth it.

---

## 7. 301 redirects — strategy

A 301 redirect is a **permanent move**. It tells engines to transfer ranking signal to the new URL.

### When to 301

- URL slug changed.
- Page moved to a new category.
- Site re-architecture.
- Domain migration.
- HTTPS migration.
- Trailing-slash policy change.
- Locale path added (`/blog/inp` → `/en/blog/inp`).
- Page deprecated; redirect to the closest equivalent.

### When NOT to 301

- Temporary outage (use 503 with `Retry-After`).
- Geo / language redirect (use 302 or content negotiation; user might come back tomorrow from a different location).
- A/B test (use 302 or render variants without a redirect).
- Personalization (don't redirect at all; render the variant).

### Rules

- **301 (permanent), not 302 (temporary).** Engines transfer ranking signal on 301; not on 302.
- **Single hop, never chains.** A → B not A → B → C → D. Each hop loses signal and adds latency.
- **Update internal links to the new URL.** Don't lean on the redirect — rewrite the links.
- **Preserve the path semantics.** `/blog/old-slug` → `/blog/new-slug` (closest match), not → `/blog`.
- **Don't redirect to the home page** as a fallback for missing pages — Google flags that as a soft 404. Either redirect to the closest equivalent or return a real 404.
- **Keep the redirect for at least 12 months.** Engines may take that long to fully transfer signal. Many SEOs leave them indefinitely.
- **Bulk redirects in a single rules table** at the edge or in nginx, not scattered throughout templates.

### nginx pattern

```nginx
# Single-hop, declared centrally
location = /old-slug   { return 301 /new-slug; }
location = /old/path   { return 301 /new/path; }
```

### Edge worker pattern

```js
// One redirect map; one lookup; one hop
const REDIRECTS = {
  '/old-slug': '/new-slug',
  '/2025/05/06/inp-guide': '/blog/inp-guide',
  // …
};

export default {
  async fetch(req) {
    const url = new URL(req.url);
    const target = REDIRECTS[url.pathname];
    if (target) {
      url.pathname = target;
      return Response.redirect(url.toString(), 301);
    }
    return fetch(req);
  }
};
```

### Detect chains

```bash
curl -sILo /dev/null -w '%{http_code} %{url_effective}\n' \
  -H 'Cookie: ' \
  https://example.com/old-page

# Or follow all redirects and count hops
curl -sILo /dev/null -w '%{num_redirects}\n' https://example.com/old-page
```

A chain count > 1 is a fix.

---

## 8. URL migrations

Migrating URLs is risky. Done badly, a migration drops 30–60% of organic traffic. Done well, the impact is < 5% over 60–90 days.

### Pre-migration

1. **Inventory every old URL** that has any external link, ranking, or traffic. Use Search Console (every URL with > 0 impressions in 90 days) and Ahrefs/Semrush (every URL with external backlinks).
2. **Map old → new** in a spreadsheet. Every old URL must have a target.
3. **Pre-publish the redirect map** at the edge for testing. Don't go live before confirming every map row resolves correctly.
4. **Update internal links** in templates and content to the new URLs. Don't rely on the redirects.
5. **Update the sitemap** to list only new URLs.
6. **Pre-warm the CDN** by crawling new URLs.

### Launch

1. Deploy the new URLs and the redirect map simultaneously.
2. Verify a sample of redirects: every status is 301, single hop, correct destination.
3. Submit the new sitemap to Search Console.
4. Monitor Search Console "Coverage" report daily for the first week.
5. Watch for "Crawl errors" and 404 spikes.

### Post-migration

- Expect a 1–4 week ranking dip; signal redistribution takes time.
- Don't change anything else for 60 days. Layer migrations on top of each other and you can't tell which broke things.
- Update external partners (newsletter, partners with deep links) with the new URLs.
- After 90 days, the redirect map can be slimmed to just the URLs still receiving real traffic.

### Anti-patterns during migration

- ❌ Redirecting all old URLs to the home page (soft 404s, signal loss).
- ❌ Going from HTTPS to HTTP (or apex to www) at the same time as content-URL changes — split migrations into separate releases so the cause of any drop is identifiable.
- ❌ Forgetting `image-` and `video-` URLs from the inventory.
- ❌ Not updating canonical tags on the new URLs.

---

## 9. Multi-locale URL patterns

| Pattern | Example | Strengths | Weaknesses |
|---------|---------|-----------|------------|
| **Path prefix** | `example.com/de/blog/inp` | Single property; simple SEO; cheap CDN | Path is not "natural" for users |
| **Subdomain** | `de.example.com/blog/inp` | Locale-specific CDN routing; per-locale infra | Subdomain SEO weight is independent of apex |
| **ccTLD** | `example.de/blog/inp` | Strongest geo-targeting; native to the locale | Each ccTLD is a separate property; expensive |
| **Query parameter** | `example.com/blog/inp?lang=de` | Easy to add | Bad for SEO; engines often miss locale |

Default for new projects: **path prefix**. Easy CDN, single property, cheap to add locales.

### Rules

- **Every locale variant has a unique URL.** Never serve different content at the same URL based on `Accept-Language`.
- **`x-default` points to the fallback locale** (often English).
- **hreflang declared in `<head>` or sitemap.** See `meta-tags` and `crawl-control`.
- **Canonical points to self per locale.** `https://example.com/de/blog/inp` is canonical to itself, not to the English version.
- **Don't auto-redirect by IP.** Confuses crawlers. Offer a banner suggesting a switch instead.

### Path-prefix pattern

```text
example.com/                             → x-default (or English)
example.com/en/                          → English
example.com/de/                          → German
example.com/fr-CA/                       → French (Canada)
```

Or, to avoid the duplicate root:

```text
example.com/                             → English (root = default)
example.com/de/                          → German
example.com/fr/                          → French
```

The second pattern is cleaner. The English version is at the root; other locales are prefixed.

---

## 10. URL anti-patterns — never ship

- ❌ Mixed-case URLs (`/Blog/Inp-Guide`).
- ❌ Underscores instead of hyphens.
- ❌ Spaces in URLs (`/blog/inp guide` → `%20`).
- ❌ File extensions on dynamic content (`.html`, `.php`, `.aspx`).
- ❌ Session IDs in URLs (`?sid=abc123`).
- ❌ `?p=4837`-style numeric IDs without a slug.
- ❌ Dates in slugs that aren't intrinsic to the content (`/2026/05/06/inp-guide`).
- ❌ Stop-word-heavy slugs (`/the-best-guide-to-inp-optimization-for-the-year-2026`).
- ❌ Mixing trailing-slash policies on the same site.
- ❌ Both `/page` and `/page/` returning 200 (duplicate URLs).
- ❌ Both apex and www returning 200.
- ❌ HTTP and HTTPS both returning 200.
- ❌ HSTS not enabled on the canonical host.
- ❌ Redirect chains > 1 hop.
- ❌ 302 used for permanent moves.
- ❌ Soft 404 (404 page returning 200, or redirect-to-home for missing pages).
- ❌ UTM / tracking parameters reaching canonical URLs.
- ❌ Faceted URLs indexed without a canonicalization or noindex strategy.
- ❌ URLs > 100 characters when shorter would do.
- ❌ Non-ASCII slugs that aren't transliterated when the site's primary script is Latin.
- ❌ Auto-redirect by IP for locale switching.
- ❌ Pagination using `?page=N` AND `/page/N` simultaneously.
- ❌ URLs change on every CMS migration without a redirect plan.

---

## 11. Validation checklist

### Slug + path

- [ ] Lowercase, hyphenated, ASCII-safe.
- [ ] No file extensions on dynamic content.
- [ ] No dates in slugs unless intrinsic.
- [ ] Reasonable length (≤ 75 chars typically).
- [ ] Path mirrors taxonomy / hierarchy.

### Trailing slash

- [ ] Site-wide policy chosen and consistent.
- [ ] Non-canonical shape 301s to canonical.
- [ ] Internal links use canonical shape.
- [ ] Canonical tag and sitemap match the served shape.

### Host

- [ ] HTTPS only.
- [ ] One canonical host (apex OR www); the other 301s.
- [ ] HSTS header set.

### Query parameters

- [ ] Tracking params (utm_*, gclid, fbclid) stripped from canonicals.
- [ ] Sort/filter params canonicalized or noindexed.
- [ ] Faceted navigation strategy documented.
- [ ] No session IDs in URLs.

### Redirects

- [ ] All permanent moves use 301.
- [ ] No redirect chains > 1 hop.
- [ ] No redirect-to-home as a 404 fallback.
- [ ] Redirect map kept in source, edge-deployed.

### Multi-locale

- [ ] Each locale has its own URL (no `Accept-Language` content variation).
- [ ] hreflang declared, reciprocal, x-default present.
- [ ] No IP-based auto-redirect.
- [ ] Canonical per locale is self.

### Hygiene

- [ ] No 404s reachable from internal links.
- [ ] No broken redirects.
- [ ] No orphaned redirects (redirect target is also redirected).
- [ ] No URLs in the sitemap that 301 or 404.

### Severity guide

- `high` — both apex and www returning 200, HTTP serving content, mixed trailing-slash policy, redirect-to-home for missing pages, faceted URLs indexed without strategy, HSTS missing.
- `medium` — redirect chains > 1 hop, UTM params in canonicals, mixed-case URLs, dates baked into slugs that don't need them, multi-locale via query parameter only.
- `low` — slug shorter than ideal, non-ASCII characters not transliterated, file extensions left on legacy URLs, sub-optimal path hierarchy.

---

## 12. Validation tools and commands

```bash
# Check trailing slash policy is consistent
for url in / /blog /blog/inp-guide; do
  echo "$url"
  curl -sILo /dev/null -w '  no-slash:    %{http_code} → %{redirect_url}\n' "https://example.com$url"
  curl -sILo /dev/null -w '  with-slash:  %{http_code} → %{redirect_url}\n' "https://example.com$url/"
done

# Check host canonicalization
for host in example.com www.example.com http://example.com http://www.example.com; do
  curl -sILo /dev/null -w '%{http_code} %{url_effective}\n' "https://$host" 2>/dev/null
done

# Check HSTS
curl -sI https://example.com | grep -i strict-transport-security

# Find redirect chains
curl -sILo /dev/null -w '%{num_redirects} %{url_effective}\n' \
  -L https://example.com/old-page

# Crawl for 404s and 301s
npx screamingfrog --crawl https://example.com --report-tab "Internal:Status Code"

# Check sitemap URLs all return 200
curl -s https://example.com/sitemap.xml \
  | grep -oP '(?<=<loc>)[^<]+' \
  | head -50 \
  | xargs -I{} curl -sILo /dev/null -w '%{http_code} {}\n' "{}"

# Find UTM params in canonical tags
curl -s https://example.com/some-page | grep -oP 'rel="canonical"[^>]+' | grep -E 'utm_|gclid|fbclid'
```

### Tools

- **Screaming Frog SEO Spider** — full URL audit, status codes, redirect chains.
- **Sitebulb** — visual URL hygiene + duplicate detection.
- **Search Console → Pages → Indexing** — canonical evaluation per URL.
- **Ahrefs Site Audit** — internal link audit + broken-link reports.
- **Cloudflare / Vercel logs** — track 404s and redirect hits in production.

---

## 13. Output format

When asked to **design URLs** for a new site or section, return:

1. The canonical URL pattern per page type (home, category, detail, author, tag, search, 404).
2. The trailing-slash policy with rationale.
3. The host policy (apex vs www, HTTPS-only, HSTS).
4. The locale URL pattern if multi-locale.
5. The query-parameter policy (which are tracking-only and stripped, which are indexable, which are noindexed).
6. Open questions — CMS limits, existing URLs to preserve, locale plans.

When asked to **audit** an existing URL structure, return:

```text
# URL Structure Audit — <site>

## Summary
- Canonical host: <yes/no, redirects in place?>
- HTTPS-only: <yes/no, HSTS set?>
- Trailing-slash policy: <consistent/mixed>
- Slug hygiene: <pass/issues>
- Redirect health: <chains found, 302s found>
- Faceted navigation: <strategy/none>
- Multi-locale: <pattern, hreflang health>
- Overall: <PASS | NEEDS WORK | FAIL>

## Findings
**[HIGH]** <URL or rule> — <issue> — <recommended fix>
**[MEDIUM]** ...
**[LOW]** ...

## Recommended fix order
1. ...
```

When asked to **plan a migration**, return:

1. The old → new URL map (sample + complete table or generation rule).
2. The redirect implementation pattern (edge worker, nginx, framework redirect file).
3. The pre-launch / launch / post-launch checklist.
4. The expected ranking impact and recovery timeline.

Then offer to apply the fixes / implement the migration. Apply approved changes one at a time, confirming each.
