---
description: Authoring and auditing robots.txt and sitemap.xml — syntax, per-bot directives (Googlebot, Bingbot, GPTBot, Google-Extended, ClaudeBot, PerplexityBot, CCBot), AI-crawler policy, sitemap formats (URL, image, video, news, sitemap index), hreflang in sitemaps, lastmod hygiene, host/protocol rules, common conflicts (disallow + canonical, noindex in sitemap), validation tools, CI checks, per-page-type recipes, and a complete validation checklist.
---

# robots.txt and sitemap.xml — crawl control and discovery

These two files are the contract between a site and its crawlers. `robots.txt` says **what may be crawled**; `sitemap.xml` says **what should be discovered**. They sit next to each other but solve different problems, and the most common bugs come from confusing the two.

This skill is for authoring both files from scratch, integrating them with a build pipeline, and auditing existing files for the conflicts that silently de-rank a site.

---

## 1. The mental model

| File | Purpose | Audience |
|------|---------|----------|
| `robots.txt` | **Crawl** control — which URLs a bot may fetch | All well-behaved crawlers (search bots, AI bots, archivers) |
| `sitemap.xml` | **Discovery** — which URLs the site wants found and crawled | Search engines and AI crawlers that respect sitemaps |

Critical distinctions:

- `robots.txt` does **not** control indexing. It controls fetching. A URL disallowed in `robots.txt` can still appear in search results without a snippet if other sites link to it. Use `<meta name="robots" content="noindex">` or the `X-Robots-Tag` HTTP header to control indexing — see **`meta-tags`** for the meta side.
- `sitemap.xml` is a **hint**, not a guarantee. Listing a URL does not force indexing.
- Sitemaps must list **only canonical, indexable URLs** that return HTTP 200. The canonical tag itself is in **`meta-tags`**; canonical URL design (trailing slash, host, parameters) is in **`url-structure`**.
- `robots.txt` lives at the **protocol+host root** (`https://example.com/robots.txt`). One per host. Subdomains and HTTP vs HTTPS each need their own.

---

## 2. `robots.txt` — file rules

### 2.1 Location and discovery

- Must be at `https://<host>/robots.txt`. Not `/robots/`, not `/seo/robots.txt`.
- Must be served as `text/plain` with `200 OK`.
- A **404** for `robots.txt` is interpreted as "no rules; crawl everything".
- A **5xx** for more than ~30 days is interpreted as "do not crawl anything" by Google. A persistent server error here will tank a site.
- Maximum size: 500 KiB (Google). Beyond that, content is ignored.
- UTF-8 encoded. BOM is allowed but not recommended.

### 2.2 Syntax

```text
# Comments start with #
User-agent: <bot name OR *>
Disallow: <path>
Allow: <path>
Sitemap: <absolute URL>
Crawl-delay: <seconds>   # not honoured by Googlebot
```

Rules:

- Grouped by `User-agent`. Each group ends at the next `User-agent` line or end of file.
- A blank line between groups is conventional; it does not split groups.
- Paths are case-sensitive and start with `/`. They are URL-paths, not regex.
- Wildcards: `*` matches any sequence; `$` anchors the end.
- Most-specific match wins between `Allow` and `Disallow` in Googlebot and Bingbot. In ambiguous cases, `Allow` wins.
- Multiple `User-agent` lines for one group is allowed (rules apply to all listed bots).
- The `*` group is the **fallback** for bots that don't match any specific group. Once a bot matches a specific group, the `*` group does not apply to it.
- `Sitemap:` is global — its location in the file does not matter; it is not associated with any user-agent group.

### 2.3 Minimum recommended `robots.txt`

```text
# Allow all crawlers; declare sitemap
User-agent: *
Allow: /

Sitemap: https://example.com/sitemap.xml
```

This is the right default for almost every site. Deviate only with reason.

### 2.4 Common patterns

#### Block search results, filters, and other crawl traps

```text
User-agent: *
Disallow: /search
Disallow: /*?utm_*
Disallow: /*?sort=
Disallow: /*?filter=
Disallow: /cart
Disallow: /checkout
Allow: /

Sitemap: https://example.com/sitemap.xml
```

#### Block staging / preview

Block at the **edge** (HTTP basic auth, IP allowlist, or `X-Robots-Tag: noindex` header) — relying on `robots.txt` alone is fragile. If you must use `robots.txt`:

```text
User-agent: *
Disallow: /
```

Ship a different `robots.txt` per environment. Never let production deploy with a `Disallow: /` `robots.txt`.

#### Allow CSS / JS

Never block CSS or JS. Google needs them to render the page and assess Core Web Vitals.

```text
# Bad — Google cannot render the page
User-agent: *
Disallow: /assets/

# Good
User-agent: *
Allow: /
```

If a directory mixes assets and admin code, allow the assets explicitly:

```text
User-agent: *
Disallow: /admin/
Allow: /admin/static/
```

### 2.5 Per-bot recipes

This section covers `robots.txt` rules per bot. For the per-bot **meta tag** version (`<meta name="GPTBot" …>`) see **`meta-tags`** (AI crawler controls). The two layers should agree — diverging robots.txt and meta tags produces ambiguous signals.

#### Search bots — keep crawled

```text
User-agent: Googlebot
Allow: /

User-agent: Bingbot
Allow: /

User-agent: DuckDuckBot
Allow: /
```

Specific groups are usually unnecessary because the `*` group already allows them. Add them only when one bot needs different rules.

#### AI / LLM bots — three policy levels

The right policy is a business decision. Surface it to the team rather than guessing.

**Level A — Allow all (maximum AI surface area):**

```text
User-agent: *
Allow: /

Sitemap: https://example.com/sitemap.xml
```

**Level B — Allow AI search, block AI training:**

```text
# Allow AI-powered search to read pages live
User-agent: OAI-SearchBot
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: ChatGPT-User
Allow: /

# Block scraping for model training
User-agent: GPTBot
Disallow: /

User-agent: Google-Extended
Disallow: /

User-agent: ClaudeBot
Disallow: /

User-agent: anthropic-ai
Disallow: /

User-agent: CCBot
Disallow: /

User-agent: cohere-ai
Disallow: /

User-agent: Bytespider
Disallow: /

# Default
User-agent: *
Allow: /

Sitemap: https://example.com/sitemap.xml
```

**Level C — Block all AI bots:**

```text
User-agent: GPTBot
Disallow: /

User-agent: ChatGPT-User
Disallow: /

User-agent: OAI-SearchBot
Disallow: /

User-agent: Google-Extended
Disallow: /

User-agent: PerplexityBot
Disallow: /

User-agent: ClaudeBot
Disallow: /

User-agent: anthropic-ai
Disallow: /

User-agent: CCBot
Disallow: /

User-agent: cohere-ai
Disallow: /

User-agent: Bytespider
Disallow: /

# Keep search bots
User-agent: *
Allow: /

Sitemap: https://example.com/sitemap.xml
```

#### Bot reference

| User-agent | Operator | Purpose |
|------------|----------|---------|
| `Googlebot` | Google | Search index |
| `Googlebot-Image` | Google | Image search |
| `Googlebot-News` | Google | News |
| `Googlebot-Video` | Google | Video |
| `Google-Extended` | Google | Gemini training & grounding |
| `Bingbot` | Microsoft | Search index (also feeds Bing Chat / Copilot) |
| `DuckDuckBot` | DuckDuckGo | Search index |
| `Yandex` | Yandex | Search index |
| `Baiduspider` | Baidu | Search index |
| `GPTBot` | OpenAI | Training |
| `ChatGPT-User` | OpenAI | On-demand fetch when ChatGPT user clicks a link |
| `OAI-SearchBot` | OpenAI | ChatGPT Search index |
| `ClaudeBot` | Anthropic | Training & search |
| `anthropic-ai` | Anthropic | Legacy / training |
| `Claude-Web` | Anthropic | On-demand fetch |
| `PerplexityBot` | Perplexity | Index |
| `Perplexity-User` | Perplexity | On-demand fetch |
| `cohere-ai` | Cohere | Training |
| `CCBot` | Common Crawl | Open dataset (used by many model trainers) |
| `Bytespider` | ByteDance | Training |
| `Applebot` | Apple | Siri / Spotlight search |
| `Applebot-Extended` | Apple | Apple Intelligence training |
| `Amazonbot` | Amazon | Alexa / search |
| `FacebookExternalHit` | Meta | Link previews |
| `Twitterbot` | X / Twitter | Link previews |
| `LinkedInBot` | LinkedIn | Link previews |
| `Slackbot` | Slack | Link previews |
| `Discordbot` | Discord | Link previews |
| `TelegramBot` | Telegram | Link previews |

Link-preview bots (`FacebookExternalHit`, `Twitterbot`, etc.) should **always** be allowed unless you intentionally do not want shareable previews. Blocking them breaks social sharing.

### 2.6 `robots.txt` gotchas

- **`Disallow:` with empty value means "disallow nothing"**, i.e. allow all. `Disallow: /` means "disallow everything".
- **`User-agent:` matches the longest token prefix** for Googlebot. `Googlebot` matches both `Googlebot` and `Googlebot-Image` (the latter via fallback if it has no specific group, but if `Googlebot-Image` has its own group it overrides).
- **Most-specific path wins.** With `Disallow: /admin/` and `Allow: /admin/login`, `/admin/login` is allowed.
- **`Crawl-delay:` is ignored by Googlebot** (Google uses its own crawl-budget logic). Bingbot and Yandex honour it. Do not rely on it for Google.
- **Comments (`#`) work only at line start or after content on the same line.** No `/* */` block comments.
- **Don't use `noindex:` in `robots.txt`.** Google supported it briefly and dropped support in 2019. It is silently ignored.
- **Disallowed URLs can still appear in SERPs** (without snippet) if other sites link to them. To prevent indexing, use `<meta name="robots" content="noindex">` and **do not** disallow the URL in `robots.txt` — Google must be allowed to crawl the URL to see the noindex.
- **HTTP vs HTTPS and bare vs www subdomain are separate hosts.** `robots.txt` for each.
- **Trailing slashes matter.** `Disallow: /admin` blocks `/admin`, `/admin/anything`, `/administrator`. `Disallow: /admin/` only blocks paths under `/admin/`.

---

## 3. `sitemap.xml` — structure and rules

### 3.1 The basic URL sitemap

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://example.com/</loc>
    <lastmod>2026-05-06</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://example.com/blog/inp-guide</loc>
    <lastmod>2026-05-06T14:30:00+00:00</lastmod>
  </url>
</urlset>
```

### 3.2 Element rules

| Element | Required | Notes |
|---------|----------|-------|
| `<loc>` | Yes | Absolute URL. Must match canonical exactly. URL-encoded. ≤ 2048 chars. |
| `<lastmod>` | Recommended | Last meaningful update of the page. ISO 8601 (`YYYY-MM-DD` or full timestamp). |
| `<changefreq>` | No | `always`, `hourly`, `daily`, `weekly`, `monthly`, `yearly`, `never`. **Ignored by Google.** Skip it. |
| `<priority>` | No | 0.0–1.0. **Ignored by Google.** Skip it. |

What Google actually uses:

- **`<loc>`** — the canonical URL.
- **`<lastmod>`** — only when it is honest. If the value drifts from reality, Google ignores `<lastmod>` site-wide for the host.

`changefreq` and `priority` are vestigial. Including them is harmless but wastes file size.

### 3.3 Hard limits

| Limit | Value |
|-------|-------|
| URLs per sitemap | 50,000 |
| Uncompressed file size | 50 MB |
| Compressed file (`.xml.gz`) size | 50 MB (decompressed) |
| Sitemaps per sitemap index | 50,000 |
| Sitemap index file size | 50 MB |

Hit any of these limits and split into multiple sitemaps with a sitemap index (section 3.5).

### 3.4 What belongs in the sitemap

**Include**:

- All **canonical** URLs that should be indexed.
- All HTTP 200 URLs.
- All localized variants (each in its own `<loc>`; see hreflang section 3.7).

**Exclude**:

- URLs with `<meta name="robots" content="noindex">`.
- Redirected URLs (301/302). List the **target**, not the source.
- 4xx / 5xx URLs.
- URLs blocked by `robots.txt`.
- Non-canonical URLs (filter parameters, sort orders, tracking variants).
- Internal search result pages.
- Login-walled pages and admin pages.
- HTTP versions when the site serves HTTPS.

A sitemap with non-indexable URLs is a quality signal in the wrong direction.

### 3.5 Sitemap index — for large sites

When a site exceeds 50k URLs or you want to track lastmod per content type, split into multiple sitemaps and reference them from a sitemap index.

**`/sitemap.xml`** (the index):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>https://example.com/sitemap-pages.xml</loc>
    <lastmod>2026-05-06</lastmod>
  </sitemap>
  <sitemap>
    <loc>https://example.com/sitemap-blog.xml</loc>
    <lastmod>2026-05-06</lastmod>
  </sitemap>
  <sitemap>
    <loc>https://example.com/sitemap-products-1.xml</loc>
    <lastmod>2026-05-06</lastmod>
  </sitemap>
  <sitemap>
    <loc>https://example.com/sitemap-products-2.xml</loc>
    <lastmod>2026-05-05</lastmod>
  </sitemap>
  <sitemap>
    <loc>https://example.com/sitemap-images.xml</loc>
    <lastmod>2026-05-06</lastmod>
  </sitemap>
</sitemapindex>
```

Then each child sitemap is a normal `<urlset>`.

Splitting strategies:

- By content type (pages, blog, products, authors).
- By language (`sitemap-en.xml`, `sitemap-de.xml`).
- By date / shard for very large sites (`sitemap-blog-2025.xml`, `sitemap-blog-2026.xml`).

### 3.6 Image sitemaps

Inline image entries in URL sitemaps (not separate files):

```xml
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
  <url>
    <loc>https://example.com/blog/inp-guide</loc>
    <lastmod>2026-05-06</lastmod>
    <image:image>
      <image:loc>https://example.com/og/inp-guide.png</image:loc>
      <image:title>INP — Core Web Vital responsiveness metric</image:title>
      <image:caption>Diagram of INP measurement across the lifetime of a page visit</image:caption>
    </image:image>
    <image:image>
      <image:loc>https://example.com/images/inp-flame-chart.webp</image:loc>
      <image:title>Long-task profile of a slow click handler</image:title>
    </image:image>
  </url>
</urlset>
```

Limit: 1,000 images per `<url>`.

### 3.7 Video sitemaps

```xml
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:video="http://www.google.com/schemas/sitemap-video/1.1">
  <url>
    <loc>https://example.com/blog/inp-guide</loc>
    <video:video>
      <video:thumbnail_loc>https://example.com/videos/inp.jpg</video:thumbnail_loc>
      <video:title>INP — what it is and how to fix it</video:title>
      <video:description>A 4-minute walkthrough of INP, its threshold, and three concrete fixes.</video:description>
      <video:content_loc>https://example.com/videos/inp.mp4</video:content_loc>
      <video:duration>240</video:duration>
      <video:publication_date>2026-05-06T09:00:00+00:00</video:publication_date>
      <video:family_friendly>yes</video:family_friendly>
    </video:video>
  </url>
</urlset>
```

### 3.8 News sitemaps

For sites eligible for Google News only. Articles must be ≤ 2 days old at the time of crawl.

```xml
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:news="http://www.google.com/schemas/sitemap-news/0.9">
  <url>
    <loc>https://example.com/news/2026-05-06-inp-update</loc>
    <news:news>
      <news:publication>
        <news:name>Example News</news:name>
        <news:language>en</news:language>
      </news:publication>
      <news:publication_date>2026-05-06T09:00:00+00:00</news:publication_date>
      <news:title>Google updates INP threshold for Core Web Vitals</news:title>
    </news:news>
  </url>
</urlset>
```

Drop news entries automatically once they age past 2 days.

### 3.9 hreflang in sitemaps

For multi-locale sites, declaring hreflang in the sitemap is more reliable than declaring it inline on every page (it scales and avoids missing reciprocal links). For the per-page `<link rel="alternate" hreflang>` version see **`meta-tags`**; for URL-shape decisions across locales (path prefix vs subdomain vs ccTLD) see **`url-structure`**.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:xhtml="http://www.w3.org/1999/xhtml">
  <url>
    <loc>https://example.com/blog/inp-guide</loc>
    <xhtml:link rel="alternate" hreflang="en" href="https://example.com/blog/inp-guide"/>
    <xhtml:link rel="alternate" hreflang="de" href="https://example.com/de/blog/inp-guide"/>
    <xhtml:link rel="alternate" hreflang="fr" href="https://example.com/fr/blog/inp-guide"/>
    <xhtml:link rel="alternate" hreflang="x-default" href="https://example.com/blog/inp-guide"/>
  </url>
  <url>
    <loc>https://example.com/de/blog/inp-guide</loc>
    <xhtml:link rel="alternate" hreflang="en" href="https://example.com/blog/inp-guide"/>
    <xhtml:link rel="alternate" hreflang="de" href="https://example.com/de/blog/inp-guide"/>
    <xhtml:link rel="alternate" hreflang="fr" href="https://example.com/fr/blog/inp-guide"/>
    <xhtml:link rel="alternate" hreflang="x-default" href="https://example.com/blog/inp-guide"/>
  </url>
  <!-- repeat for every locale variant -->
</urlset>
```

Rules:

- Every locale variant is a separate `<url>` entry.
- Every `<url>` entry lists **all** alternates including itself.
- All `hreflang` clusters must be reciprocal across `<url>` entries.

### 3.10 `lastmod` hygiene

Google ignores `lastmod` site-wide if it consistently does not match real changes.

- Use the **actual modification time** of the page's content. For static-site generators, this is the file mtime or the latest commit touching the source.
- Don't bump `lastmod` on every build. If only the layout/CSS changed and the URL's primary content is the same, do not change `lastmod`.
- Use full ISO 8601 timestamps when possible (`2026-05-06T14:30:00+00:00`), not just the date.
- Match `lastmod` in the sitemap to `dateModified` in the page's JSON-LD and the visible "Last updated" date — these three should agree.

---

## 4. Wiring `robots.txt` and `sitemap.xml` together

### 4.1 Declare sitemaps in `robots.txt`

```text
User-agent: *
Allow: /

Sitemap: https://example.com/sitemap.xml
Sitemap: https://example.com/news-sitemap.xml
```

Multiple `Sitemap:` lines are allowed. Use absolute URLs, including protocol.

### 4.2 Submit sitemap to Search Console / Bing Webmaster

`robots.txt` declaration is enough for discovery; explicit submission gives faster status feedback (errors, indexed counts). Submit:

- The sitemap index URL (not each child sitemap separately).
- One per host (HTTPS bare and HTTPS www are separate hosts in Search Console — verify both, submit to whichever is canonical).

### 4.3 Don't disallow your sitemap

```text
# Bad — blocks the sitemap itself
User-agent: *
Disallow: /sitemap

# Good
User-agent: *
Allow: /sitemap.xml
Allow: /sitemap-pages.xml
```

The default-allow rule already covers this; only an over-aggressive disallow can break it.

### 4.4 Don't disallow URLs that are in the sitemap

A URL listed in the sitemap and disallowed in `robots.txt` is a contradiction. Google logs it as a crawl error.

### 4.5 Don't list `noindex` URLs in the sitemap

Same conflict in the other direction. The sitemap is a discovery hint that says "please index this"; a `noindex` page says "do not index". The sitemap entry is wasted and can throttle crawl budget on legitimate URLs.

---

## 5. Per-page-type recipes

### 5.1 Static marketing site

`robots.txt`:

```text
User-agent: *
Allow: /

Sitemap: https://example.com/sitemap.xml
```

`sitemap.xml`: every public page, generated at build.

### 5.2 Blog / content site

`robots.txt`:

```text
User-agent: *
Disallow: /search
Disallow: /tag/*?page=
Allow: /

Sitemap: https://example.com/sitemap.xml
```

`sitemap.xml` index pointing at:

- `sitemap-pages.xml` — static pages (home, about, contact).
- `sitemap-blog.xml` — articles, with `<lastmod>` per article.
- `sitemap-authors.xml` — author profile pages with substantive content.
- `sitemap-tags.xml` — tag/category pages with at least 5 posts.

Exclude:

- Pagination (`/blog?page=2`) — canonical to page 1 with self-canonical, or list only page 1 in sitemap.
- Tag pages with fewer than 5 posts — they are thin and dilute.

### 5.3 E-commerce

`robots.txt`:

```text
User-agent: *
Disallow: /cart
Disallow: /checkout
Disallow: /account
Disallow: /*?sort=
Disallow: /*?filter=
Disallow: /*?utm_*
Allow: /

Sitemap: https://example.com/sitemap.xml
```

`sitemap.xml` index:

- `sitemap-pages.xml`
- `sitemap-categories.xml`
- `sitemap-products-1.xml` … `sitemap-products-N.xml` (50k each)
- `sitemap-images.xml`

`<lastmod>` updates whenever:

- Title, description, price, or availability changes.
- Reviews are added (stale-product penalty).
- Stock comes back in.

### 5.4 Multi-locale content site

```text
User-agent: *
Allow: /

Sitemap: https://example.com/sitemap.xml
```

`sitemap.xml` index:

- `sitemap-en.xml`
- `sitemap-de.xml`
- `sitemap-fr.xml`

Each locale sitemap uses the `xhtml:link` pattern from section 3.9. Every locale variant lists every alternate including itself.

### 5.5 Single-page application

The app shell is one URL; the actual pages must each have their own URL (history API or hash-bang resolution server-side). The sitemap lists those URLs.

For hybrid sites, only list **server-rendered** URLs in the sitemap. Client-only routes are not reliably indexed.

### 5.6 Documentation site

`robots.txt`:

```text
User-agent: *
Disallow: /search
Allow: /

Sitemap: https://docs.example.com/sitemap.xml
```

For versioned docs (`/v1/`, `/v2/`):

- Only the **latest stable** version belongs in the sitemap by default.
- Older versions: `<meta name="robots" content="noindex">` on each page, and exclude from sitemap.
- Self-canonical each version's pages — never canonical from `/v1/foo` to `/v2/foo`.

### 5.7 Staging and preview environments

```text
User-agent: *
Disallow: /
```

But also enforce at the edge with HTTP basic auth or `X-Robots-Tag: noindex` header. `robots.txt` alone is fragile; the file can be ignored or cached.

The most expensive incident in this skill: shipping `Disallow: /` to production. Guard against it:

- Different `robots.txt` per environment.
- A CI smoke test that fails the deploy if production `robots.txt` contains `Disallow: /`.
- Search Console alert on indexed-page count drop.

---

## 6. Validation tools and commands

### 6.1 Inspect

```bash
# Fetch robots.txt
curl -sI https://example.com/robots.txt    # 200, text/plain
curl -s  https://example.com/robots.txt

# Fetch sitemap
curl -sI https://example.com/sitemap.xml   # 200, application/xml or text/xml
curl -s  https://example.com/sitemap.xml | head -50

# Count URLs in a sitemap
curl -s https://example.com/sitemap.xml | grep -c '<loc>'

# Walk a sitemap index
curl -s https://example.com/sitemap.xml | grep -oP '(?<=<loc>)[^<]+'

# Validate XML
curl -s https://example.com/sitemap.xml | xmllint --noout -
```

### 6.2 Test robots.txt rules

```bash
# Search Console robots.txt tester (per-site, recommended)
# https://search.google.com/search-console/

# Tools that simulate Googlebot evaluation
# https://technicalseo.com/tools/robots-txt/

# Locally — match a path against a robots.txt
python3 -c '
from urllib.robotparser import RobotFileParser
rp = RobotFileParser()
rp.set_url("https://example.com/robots.txt")
rp.read()
print(rp.can_fetch("Googlebot", "https://example.com/admin/"))
print(rp.can_fetch("GPTBot", "https://example.com/blog/"))
'
```

### 6.3 Validate sitemap

```bash
# Validate against the schema
xmllint --schema https://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd https://example.com/sitemap.xml

# Search Console — submit and watch for errors
# Bing Webmaster — Sitemaps tab

# Online validators
# https://www.xml-sitemaps.com/validate-xml-sitemap.html
# https://technicalseo.com/tools/sitemap/
```

### 6.4 Smoke tests for CI

```bash
# Fail if production robots.txt accidentally disallows everything
curl -sf https://example.com/robots.txt | grep -E '^Disallow:\s*/\s*$' && {
  echo "FAIL: production robots.txt contains Disallow: /"
  exit 1
}

# Fail if sitemap is missing or returns non-200
curl -sf -o /dev/null -w '%{http_code}\n' https://example.com/sitemap.xml | grep -q '^200$' || {
  echo "FAIL: sitemap.xml not reachable"
  exit 1
}

# Fail if sitemap declares <0 URLs
[ "$(curl -s https://example.com/sitemap.xml | grep -c '<loc>')" -gt 0 ] || {
  echo "FAIL: sitemap.xml has 0 URLs"
  exit 1
}

# Sample-check that sitemap URLs return 200 and are not noindex
curl -s https://example.com/sitemap.xml \
  | grep -oP '(?<=<loc>)[^<]+' \
  | shuf -n 20 \
  | while read url; do
      code=$(curl -sf -o /tmp/page -w '%{http_code}' "$url")
      if [ "$code" != "200" ]; then
        echo "FAIL: $url returned $code"; exit 1
      fi
      if grep -q 'name="robots"[^>]*content="[^"]*noindex' /tmp/page; then
        echo "FAIL: $url has noindex but is in sitemap"; exit 1
      fi
    done
```

Wire these into the post-deploy job.

---

## 7. Anti-patterns — never ship

- ❌ `robots.txt` returning 5xx for more than a few minutes (Google interprets persistent error as block-everything).
- ❌ `Disallow: /` shipped to production from a staging template.
- ❌ Disallowing CSS or JS — breaks Google's render and Core Web Vitals scoring.
- ❌ Using `robots.txt` to deindex — it controls crawling, not indexing. Use `noindex` meta or `X-Robots-Tag`.
- ❌ `noindex:` directive in `robots.txt` — unsupported since 2019.
- ❌ Listing `noindex` URLs in the sitemap — contradictory signal.
- ❌ Listing URLs blocked by `robots.txt` in the sitemap — same.
- ❌ Listing redirected URLs in the sitemap — list the target.
- ❌ Listing 4xx / 5xx URLs — wastes crawl budget.
- ❌ Listing both HTTP and HTTPS variants — only the canonical protocol.
- ❌ Listing both bare-domain and www variants — only the canonical host.
- ❌ Listing URLs that disagree with the page's `<link rel="canonical">`.
- ❌ Bumping `<lastmod>` on every build, regardless of actual content change — Google starts ignoring `lastmod` site-wide.
- ❌ Hand-maintained sitemap.xml on a content site — generate at build time.
- ❌ Sitemap larger than 50 MB or more than 50,000 URLs — split into a sitemap index.
- ❌ Sitemap not declared in `robots.txt`.
- ❌ Sitemap URL using a relative path in `robots.txt` (`Sitemap: /sitemap.xml`). Must be absolute.
- ❌ One giant sitemap covering the whole catalog when content types have very different update cadences.
- ❌ Blocking link-preview bots (`FacebookExternalHit`, `Twitterbot`, `LinkedInBot`, `Slackbot`) — kills social previews.
- ❌ Hreflang declared inline on pages but missing from sitemap when the site is large — high error rate; declare in sitemap.
- ❌ Hreflang clusters in the sitemap that aren't reciprocal — invalidates the cluster.
- ❌ Pagination URLs (`?page=2`, `?page=3`) listed in the sitemap when the canonical is page 1 only.
- ❌ Internal search results listed in the sitemap.
- ❌ Tag / filter pages with fewer than ~5 items listed — thin content dilution.
- ❌ Sitemap served with `text/html` content type — must be `application/xml` or `text/xml`.
- ❌ Sitemap behind authentication.

---

## 8. Validation checklist

Use when auditing existing files. Score each item; report findings with severity.

### `robots.txt`

- [ ] Lives at `https://<host>/robots.txt`, returns 200, `Content-Type: text/plain`.
- [ ] No `Disallow: /` in production.
- [ ] CSS, JS, image directories are crawlable.
- [ ] AI-bot policy matches the team's declared policy (allow / partial / block).
- [ ] Link-preview bots not blocked.
- [ ] At least one absolute `Sitemap:` line.
- [ ] No `noindex:` directive (unsupported).
- [ ] No conflicting `Disallow` for URLs that are in the sitemap.
- [ ] `Crawl-delay` not relied on for Google.
- [ ] Different file for staging; staging blocks crawlers via headers, not just robots.

### `sitemap.xml`

- [ ] Lives at the declared URL, returns 200, served as `application/xml` or `text/xml`.
- [ ] Validates against the sitemaps.org schema.
- [ ] All `<loc>` URLs are absolute, canonical, return HTTP 200.
- [ ] No `noindex` URLs included.
- [ ] No URLs blocked by `robots.txt`.
- [ ] No HTTP variants when site is HTTPS.
- [ ] No bare-domain variants when site is www-canonical (or vice versa).
- [ ] `<lastmod>` reflects real content changes.
- [ ] `<lastmod>` agrees with `dateModified` in JSON-LD and visible "Last updated".
- [ ] No `<changefreq>` or `<priority>` (or accept that they are ignored).
- [ ] ≤ 50,000 URLs and ≤ 50 MB per sitemap; otherwise sitemap index used.
- [ ] Multi-locale sites use `xhtml:link` hreflang; clusters reciprocal.
- [ ] Image / video sitemap entries used where the site has substantial media.
- [ ] News sitemap drops articles older than 2 days.
- [ ] Sitemap referenced in `robots.txt` and submitted to Search Console.

### CI / deployment

- [ ] Smoke test fails the deploy if production `robots.txt` disallows everything.
- [ ] Smoke test verifies `sitemap.xml` returns 200 with > 0 URLs.
- [ ] Smoke test samples sitemap URLs for 200 status and absence of `noindex`.
- [ ] Sitemap regenerated on every content change.
- [ ] Search Console / Bing Webmaster sitemap submission is part of release docs.

### Severity guide

- `high` — `Disallow: /` in production, sitemap missing or 5xx, sitemap full of redirects/404s, sitemap and `robots.txt` contradict, CSS/JS blocked from Googlebot, link-preview bots blocked, sitemap >50 MB / >50k URLs without index.
- `medium` — `noindex` URLs in sitemap, `lastmod` bumped on every build, multi-locale site without sitemap hreflang, missing `Sitemap:` line in `robots.txt`, AI-bot policy not documented, internal search / filter URLs listed.
- `low` — `<changefreq>`/`<priority>` present (harmless), `lastmod` is date-only when timestamp is available, sitemap not split by content type, no smoke tests in CI yet.

---

## 9. Output format

When asked to **generate** these files, return:

1. The complete `robots.txt` for the requested policy level (A, B, or C from section 2.5), with comments.
2. The complete `sitemap.xml` (or sitemap index + child sitemaps) for the site's content shape.
3. A short rationale for non-obvious choices (which AI bots are blocked, why the sitemap is split a particular way).
4. Open questions for any field that needs the project's input (host, locales, staging environment behaviour, AI policy decision).

When asked to **validate** existing files, return:

```text
# robots.txt + sitemap.xml Audit — <host>

## Summary
- robots.txt: <fetched status, size, group count, sitemap declarations>
- sitemap.xml: <fetched status, format, URL count, lastmod sample>
- AI-bot policy: <Allow all | Partial | Block all | Undeclared>
- Conflicts found: <count>
- Overall: <PASS | NEEDS WORK | FAIL>

## Findings
**[HIGH]** <file>:<line or rule> — <issue> — <recommended fix>
**[MEDIUM]** ...
**[LOW]** ...

## Recommended fix order
1. ...
```

Then offer to apply each fix. Apply approved fixes one at a time, confirming each.
