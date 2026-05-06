---
description: Loading third-party scripts (analytics, tag managers, A/B test platforms, chat widgets, social embeds, ad/marketing pixels) without wrecking Core Web Vitals — defer/async/idle policies, consent gating, Partytown for off-main-thread execution, allowlist/budget per page type, and an audit checklist for the third-party origins crowding the critical path.
---

# Third-party scripts — keeping them off the critical path

Third-party scripts are the single most common cause of bad Core Web Vitals on otherwise well-built sites. They land in `<head>`, run synchronously on the main thread, fetch from untrusted origins, push other work behind them, and degrade INP for the rest of the visit. Worse: a clean page can ship in the morning and be tanked by 4 PM after the marketing team adds two pixels in the tag manager.

This skill is the policy + tactics for letting marketing, analytics, and product still ship third parties — without giving them the critical path.

For runtime image and CSS rules see `core-web-vitals` and `image-optimization`. For the connection-hint half of script optimization see `resource-hints`. This skill is the **script management layer**.

---

## 1. The mental model

Every third-party script costs:

1. **DNS + TCP + TLS** — one new origin per provider, ~100–500 ms on slow connections.
2. **Bytes downloaded** — the script itself, plus any sub-resources it fetches.
3. **Main-thread time** — parsing, compiling, executing JS. The biggest INP cost.
4. **Render blocking** — if loaded synchronously in `<head>`, the parser pauses until the script loads and runs.
5. **Layout shift** — chat widgets, banners, and embeds that inject DOM after load (CLS).
6. **Long tasks** — ad scripts and tag managers fire long tasks in click handlers, killing INP.

The default for any third-party script is therefore **"not on the critical path, gated behind consent, deferred until the user can already use the page."**

---

## 2. The four loading strategies

| Strategy | Trigger | Use for |
|----------|---------|---------|
| **Sync in `<head>`** | Parsing of `<head>` | Almost never — only for things that must run before paint (consent banner) |
| **`async`** | Available; runs as soon as it downloads, in any order | Independent scripts that don't block render and don't depend on others |
| **`defer`** | After HTML parsed, before `DOMContentLoaded`, in document order | Scripts that need the DOM and depend on each other |
| **Idle / on-interaction** | After page is interactive, often after consent | Almost everything else — analytics, pixels, chat, A/B tests, heatmaps |

### Bad

```html
<head>
  <script src="https://www.googletagmanager.com/gtm.js?id=GTM-XXX"></script>
  <script src="https://widget.intercom.io/widget/xxx.js"></script>
  <script src="https://static.hotjar.com/c/hotjar-xxx.js"></script>
</head>
```

Three new origins, three render-blocking scripts, all firing before the user sees anything.

### Good

```html
<head>
  <!-- Self-hosted, deferred -->
  <script type="module" src="/js/app.js" defer></script>
</head>

<body>
  <!-- … the actual content … -->

  <!-- Third parties, idle-loaded, gated on consent -->
  <script>
    if (window.requestIdleCallback) {
      requestIdleCallback(() => loadAnalytics(), { timeout: 4000 });
    } else {
      setTimeout(loadAnalytics, 2000);
    }

    function loadAnalytics() {
      if (!hasAnalyticsConsent()) return;
      const s = document.createElement('script');
      s.src = 'https://plausible.io/js/script.js';
      s.defer = true;
      s.dataset.domain = 'example.com';
      document.head.appendChild(s);
    }
  </script>
</body>
```

---

## 3. Per-category recipes

### 3.1 Analytics (GA4, Plausible, Fathom, Matomo, Umami)

- Load **after consent**, **after idle**.
- Self-host where possible (Plausible, Fathom, Matomo all support it).
- Don't ship multiple analytics tools — pick one.
- Don't run analytics in dev/preview/test environments.

```js
if (import.meta.env.PROD && hasAnalyticsConsent()) {
  requestIdleCallback(() => loadAnalytics(), { timeout: 4000 });
}
```

### 3.2 Tag managers (Google Tag Manager, Tealium)

Tag managers are the worst CWV offender because they load N child scripts at runtime, with no static budget and no review.

- **Avoid in critical path.** Self-hosted server-side tagging beats client GTM (Google's `Tag Server`, `stape.io`).
- If client-side GTM is required: load via Partytown (section 4) or via an idle callback.
- **Audit GTM container regularly.** A weekly diff against the last known-good container.
- **Block all tags from injecting third parties of their own.** Most tag managers can sandbox; turn it on.

### 3.3 Customer support / chat (Intercom, Zendesk, Crisp, Drift)

These are the heaviest single category — Intercom alone can ship 800 KB of JS.

- **Defer until user interaction.** Show a placeholder button; load the real widget on hover or click.
- **Don't auto-open** on page load.
- Reserve fixed pixel space for the chat-icon button so it doesn't cause CLS when it appears.

```html
<button id="chat-trigger" aria-label="Open chat">Chat</button>
<script>
  document.getElementById('chat-trigger').addEventListener('click', () => {
    if (window.Intercom) return window.Intercom('show');
    loadIntercom().then(() => window.Intercom('show'));
  }, { once: true });
</script>
```

### 3.4 A/B testing (Optimizely, VWO, Google Optimize successors, GrowthBook, Statsig)

A/B test scripts are the worst kind of render-blocker because they typically load synchronously in `<head>` to flicker-prevent.

- **Server-side variant assignment** beats client-side splitting. Render the variant directly; no flicker, no script.
- If client-side is required: keep the script tiny (<10 KB), ship variants as plain CSS rules, avoid running JS to mutate the DOM after load.
- Consider `next-experiments`, GrowthBook SDK, or a custom edge-rendered solution.

### 3.5 Marketing pixels (Meta, Reddit, X, LinkedIn, Pinterest, TikTok)

Each pixel is its own origin, its own script, its own connection. They compound fast.

- **Load idle, after consent.** Pixels can fire 5+ seconds after page load and still attribute correctly.
- **Server-side conversions API** (Meta CAPI, LinkedIn Conversions API) eliminates the pixel for conversion events. Use it for purchases / sign-ups; keep client pixels only for page-view-level tracking.
- **Cap the number of pixels.** Marketing will keep adding them. Set a budget (e.g. ≤ 3 client-side pixels per site) and enforce it.

### 3.6 Heatmaps / session replay (Hotjar, FullStory, LogRocket, Microsoft Clarity)

These are heavy and they record DOM, which is slow.

- **Sample.** Don't record 100% of sessions. 5–10% is enough to find issues.
- **Idle-load only.**
- **Disable on slow devices** (`navigator.deviceMemory < 4`, `navigator.connection.effectiveType !== '4g'`).
- **Mask sensitive content** at the markup level (`data-hj-suppress`, etc.) so PII doesn't leak.

### 3.7 Social embeds (X / Twitter, Instagram, TikTok, YouTube, Facebook posts)

Embeds are entire iframed apps. They load megabytes of JS and external CSS.

- **Don't auto-embed.** Use a click-to-load placeholder showing the post's text + author + a "Click to load" button. The user opts into the JS cost.
- **YouTube specifically**: use `lite-youtube-embed` or a `<picture>` poster with click-to-load. The default YouTube iframe is ~600 KB before any video plays.
- **Lazy-load via `loading="lazy"` on the `<iframe>`** at minimum.

```html
<iframe
  src="https://www.youtube-nocookie.com/embed/xyz"
  loading="lazy"
  width="560" height="315"
  title="…"
  allow="accelerometer; encrypted-media; picture-in-picture"
  allowfullscreen></iframe>
```

### 3.8 Fonts from third-party hosts

If using Google Fonts, Adobe Fonts, etc., self-host the WOFF2s instead. Removes a third-party origin and a connection. See `resource-hints` for the font preload pattern.

### 3.9 Captchas (reCAPTCHA, hCaptcha, Turnstile)

reCAPTCHA v3 ships ~400 KB and runs continuously. Alternatives:

- **Cloudflare Turnstile** is much smaller and free.
- **Lazy-load on form interaction.** Load the script when the user focuses the form, not on page load.

### 3.10 Cookie / consent banners

The one third-party script that legitimately must run before paint (so the banner appears).

- **Self-host the banner script** if possible — many CMP vendors offer it.
- **Inline the banner CSS** so it doesn't blink.
- **Reserve the banner's space** with `aspect-ratio` or fixed dimensions to avoid CLS.

---

## 4. Partytown — third parties off the main thread

[Partytown](https://partytown.builder.io/) runs scripts inside a web worker via a service-worker proxy. The third party never touches the main thread.

```html
<script>
  partytown = {
    forward: ['dataLayer.push', 'gtag', 'fbq']
  };
</script>
<script src="/~partytown/partytown.js"></script>

<script type="text/partytown" src="https://www.googletagmanager.com/gtag/js?id=GA-XXX"></script>
```

### When Partytown wins

- GTM and the tags it loads.
- Single analytics scripts (GA4, Hotjar's heatmap script).
- Pixels that just send beacons.

### When Partytown doesn't help

- Scripts that need to mutate the DOM directly (chat widgets, banners) — they need the main thread.
- Scripts that depend on `window` features unavailable in workers.

Always benchmark before/after. Partytown adds its own JS cost; for tiny single-script setups it can be a wash.

---

## 5. Consent integration

Most jurisdictions require user consent before loading analytics or marketing scripts. Failing to gate is both a privacy violation and a CWV anti-pattern (loads scripts you can't measure with).

### Pattern

```js
// Wait for consent state, then load gated scripts
window.addEventListener('cookieConsentGiven', (e) => {
  const c = e.detail; // { analytics: true, marketing: false }

  if (c.analytics) {
    requestIdleCallback(() => loadPlausible(), { timeout: 4000 });
  }
  if (c.marketing) {
    requestIdleCallback(() => loadMetaPixel(), { timeout: 4000 });
  }
});
```

### Rules

- **Consent before load.** Don't fire the script and "respect consent server-side" — the request alone is the privacy violation in EU/UK.
- **Per-category consent.** Analytics and marketing are usually separate categories; some users accept analytics but not marketing.
- **Persist the consent state** so returning users skip the banner.
- **`Sec-CH-Prefers-Reduced-Data`** — if respected, skip non-essential scripts entirely.

---

## 6. Budgets per page type

A measurable guardrail for "how many third parties is too many".

| Route | Max third-party origins | Max third-party JS bytes (gzip) | Critical path third-party JS |
|-------|-------------------------|--------------------------------|------------------------------|
| Home | 4 | 80 KB | 0 |
| Article / blog | 3 | 60 KB | 0 |
| Category | 3 | 60 KB | 0 |
| Product | 5 | 120 KB | 0 |
| Checkout | 5 | 150 KB | Payment SDK only (Stripe/PayPal) |
| Search | 2 | 30 KB | 0 |

"Critical path" = synchronous in `<head>`. The budget for critical-path third parties is **zero** for everything except checkout's payment SDK, where it's unavoidable and well-understood.

---

## 7. Origin allowlist + CSP

A Content Security Policy is the only robust enforcement against rogue third parties. It also doubles as documentation of what's allowed.

```text
Content-Security-Policy:
  default-src 'self';
  script-src 'self' https://plausible.io https://www.googletagmanager.com 'sha256-…';
  connect-src 'self' https://plausible.io https://*.google-analytics.com;
  frame-src https://www.youtube-nocookie.com;
  img-src 'self' data: https://images.example.com https://www.google-analytics.com;
  font-src 'self';
  style-src 'self' 'unsafe-inline';
  report-uri /csp-report;
```

### Rules

- **Allowlist origins** — never `*`.
- **`'unsafe-inline'` for `script-src` is unacceptable.** Use nonces or hashes.
- **`report-uri` (or `report-to`)** to a backend — surfaces violations and rogue scripts.
- **Test in `Content-Security-Policy-Report-Only`** mode first to find false positives.

---

## 8. Detecting what's actually loading

The shipped `<head>` is rarely the whole picture — tag managers and consent platforms inject scripts at runtime.

### Audit a page

```bash
# Headless run that dumps every network request
npx lighthouse "$URL" --output json --output-path lh.json --only-categories=performance --view

# Extract third-party origins and bytes
jq '.audits["third-party-summary"].details.items' lh.json
```

### WebPageTest "Third Party" tab

WebPageTest categorizes every request by provider and shows total bytes + main-thread time per provider. The single most useful third-party audit view.

### Site-wide regression detection

Diff the third-party request list per route weekly. A surprise +1 origin is usually a marketing change. Catch it before users do.

```bash
# Crawl a list of routes, snapshot 3rd-party origins
for url in $(cat routes.txt); do
  npx lighthouse "$url" --output json --quiet | jq -r '.audits["third-party-summary"].details.items[].entity'
done | sort | uniq -c | sort -rn
```

---

## 9. Anti-patterns — never ship

- ❌ Synchronous third-party `<script>` in `<head>`. Almost always wrong.
- ❌ More than one analytics tool.
- ❌ More than 3 marketing pixels firing client-side.
- ❌ Chat widget loading on page load instead of on user interaction.
- ❌ YouTube embed without lazy load or click-to-load.
- ❌ Hotjar / FullStory recording 100% of sessions.
- ❌ Tag manager with unaudited containers.
- ❌ Consent banner that loads after content (CLS) instead of with reserved space.
- ❌ Loading the third-party script even when consent was denied.
- ❌ Pixel scripts running in dev / preview / staging.
- ❌ A/B test client script in critical path causing flicker delay.
- ❌ Fonts loaded from a third-party origin when self-hosting is possible.
- ❌ reCAPTCHA on every page even when no form is visible.
- ❌ CSP `script-src 'unsafe-inline'`.
- ❌ Adding a new third-party origin without measuring the LCP / INP impact.
- ❌ Treating the tag manager as someone else's problem — it's the SEO team's CWV problem.
- ❌ Production page loads ≥ 1 MB of third-party JS for marketing reasons no one can name.

---

## 10. Validation checklist

### Critical path

- [ ] Zero synchronous third-party scripts in `<head>`.
- [ ] Self-hosted JS is the only critical-path script.
- [ ] All third parties use `defer`, `async`, idle loading, or click-to-load.

### Consent

- [ ] No analytics or marketing scripts load before consent.
- [ ] Per-category consent (analytics vs marketing) honored.
- [ ] Consent state persisted across visits.
- [ ] Banner CSS inlined; banner space reserved (no CLS).

### Loading strategy

- [ ] Analytics: idle-loaded after consent.
- [ ] Tag manager: Partytown or idle-loaded; container audited.
- [ ] Chat / support: click-to-load with placeholder button.
- [ ] Heatmaps: sampled, idle-loaded, disabled on slow devices.
- [ ] Social embeds: click-to-load placeholders; YouTube uses `lite-youtube-embed` or facade.
- [ ] Fonts: self-hosted (no third-party font origin).
- [ ] Captchas: lazy-loaded on form interaction.

### Budgets

- [ ] Third-party origin count per page-type budget met.
- [ ] Third-party JS byte budget met.
- [ ] Number of marketing pixels ≤ documented limit.

### CSP

- [ ] `script-src` allowlists every origin (no `*`, no `'unsafe-inline'`).
- [ ] `connect-src`, `img-src`, `frame-src` similarly tight.
- [ ] `report-uri` or `report-to` configured and monitored.

### Detection

- [ ] Lighthouse "Third-party summary" reviewed per page type.
- [ ] WebPageTest "Third Party" tab reviewed per page type.
- [ ] Weekly regression diff of third-party origins per route.
- [ ] No third parties firing in dev/preview/staging.

### Severity guide

- `high` — sync `<script>` in `<head>` from a third party, scripts loading before consent, chat widget auto-loading, ad pixel in critical path, missing CSP.
- `medium` — multiple analytics tools, fonts from third-party host, YouTube embeds without lazy load, pixel firing in dev.
- `low` — tag manager container not regularly audited, no third-party regression diff, no Partytown for GTM where it would help.

---

## 11. Validation tools and commands

```bash
# List third-party origins on a page
curl -s "$URL" | grep -oP '<(script|link|iframe)[^>]*(src|href)="[^"]+"' \
  | grep -oP 'https?://[^"]+' \
  | grep -v "^$URL" \
  | sed -E 's#^(https?://[^/]+).*#\1#' \
  | sort -u

# Lighthouse third-party summary
npx lighthouse "$URL" --output json --quiet \
  | jq '.audits["third-party-summary"].details.items'

# Bundle analysis (webpack-bundle-analyzer or rollup-plugin-visualizer)
pnpm build && pnpm bundle-analyze

# WebPageTest API
curl -s "https://www.webpagetest.org/runtest.php?url=$URL&k=$WPT_API_KEY&f=json" | jq

# Partytown integration check
curl -s "$URL" | grep -c 'type="text/partytown"'

# CSP check
curl -sI "$URL" | grep -i 'content-security-policy'
```

### Tools

- **Lighthouse → Diagnostics → "Reduce the impact of third-party code"**
- **WebPageTest → Third Party tab** (provider-categorized timing)
- **Chrome DevTools → Performance → Bottom-up filtered by third-party domains**
- **Request Map (<https://requestmap.webperf.tools>)** — visual graph of all requests by origin
- **CSP Evaluator (Google)** — validates CSP correctness

---

## 12. Output format

When asked to **set up third-party loading**, return:

1. The recommended loading strategy per script (sync, defer, async, idle, on-interaction, Partytown).
2. The exact code change for each script — `<head>` removal + new deferred load pattern.
3. Consent gating wiring with the project's CMP (Cookiebot, OneTrust, custom).
4. CSP entries needed for each allowed origin.
5. Open questions — which scripts can move to server-side, which must stay client-side, what CMP is in use.

When asked to **audit** third parties, return:

```text
# Third-Party Script Audit — <URL>

## Summary
- Origins: <count>
- Total third-party JS (gzip): <KB>
- Critical-path third parties: <count>
- Consent gating: <pass/fail>
- Pre-consent leaks: <list>
- Most expensive provider: <name, bytes, main-thread time>
- Overall: <PASS | NEEDS WORK | FAIL>

## Findings
**[HIGH]** <provider/origin> — <issue> — <recommended fix>
**[MEDIUM]** ...
**[LOW]** ...

## Recommended fix order
1. ...
```

Then offer to apply each fix. Apply approved fixes one at a time, confirming each.
