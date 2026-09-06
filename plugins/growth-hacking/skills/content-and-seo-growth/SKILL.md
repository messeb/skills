---
description: Content as a growth channel — the content-driven growth loop, choosing topics by search demand and business value rather than volume, the content formats that earn links and citations, programmatic and user-generated content at scale, distribution as the larger half of the work, repurposing, measuring content against pipeline rather than pageviews, and where the dedicated `seo` plugin takes over.
---

# Content and SEO-driven growth

Goal of this skill: build a content engine that compounds — where published work keeps acquiring users months later at no additional cost — rather than a blog that consumes budget and produces traffic nobody converts.

Use this skill when planning a content channel, when traffic grows but pipeline does not, or when content output is high and results are flat.

**Scope**: this skill covers content as a *growth channel* — topic selection, formats, distribution, and measurement. For the technical craft — meta tags, structured data, crawl control, Core Web Vitals, internal linking, URL structure — use the dedicated `seo` plugin, which covers those in depth.

---

## 1. Content as a loop, not a campaign

Content is one of the few channels that compounds, which is its entire justification. The loop:

```text
publish → ranks / gets cited / gets shared → visitors arrive
        → some convert → some create signals (links, mentions, user content)
        → those signals raise the ranking → more visitors
```

Two properties follow. It is **slow** — meaningful results take months, which makes it unsuitable as a rescue for a quarter — and it is **cumulative**, so the asset produced this month keeps working next year. A team that abandons content after eight weeks pays the cost and never collects the return.

The corollary: judge content on the cohort of articles published, not on monthly traffic. An article published in March should be evaluated in September.

---

## 2. Choosing topics

The most common failure is writing about what the company finds interesting.

| Selection criterion | Test |
|---------------------|------|
| **Search demand exists** | People actually search this; there is a query with volume |
| **Business relevance** | Someone searching this could plausibly become a customer |
| **Winnable** | You can produce something better than what currently ranks, given your authority |
| **Intent match** | The searcher's intent matches what you can offer — informational, comparison, or transactional |

Prioritise on **business value × winnability**, not volume. A term with 200 monthly searches and clear purchase intent is worth more than one with 40,000 searches and none. Most teams do the reverse and then wonder why traffic does not convert.

The highest-value content types in practice, roughly in order of conversion rate:

1. **Comparison and alternative pages** — searchers are in a decision, and you are permitted to make your case. This is usually the most under-invested content type.
2. **Problem-solution content** matching the exact wording customers use (from support logs and sales calls — `customer-research`).
3. **Use-case and integration pages** — high intent, easy to write, easy to rank in a niche.
4. **Original research and data** — the format most likely to earn links and citations.
5. **Free tools and calculators** — engineering as marketing; earns links continuously and converts well (`idea-generation`).
6. **Educational content** — broad, useful for authority, weak on direct conversion.

Note the shift worth planning for: a growing share of search-like traffic now arrives via AI assistants and answer engines that cite sources rather than list links. That rewards content that is factually dense, clearly structured, quotable, and attributable — the `seo` plugin's `geo-content` skill covers how to write for it.

---

## 3. Quality, and what actually earns links

"Better content" is not a strategy. Concretely, content that outperforms usually has at least one of:

| Property | Why it works |
|----------|--------------|
| **Original data** | Nobody can copy a survey you ran; it earns citations for years |
| **First-hand experience** | Actual results, screenshots, numbers from doing the thing |
| **Genuine depth on a narrow question** | Beats broad shallow coverage of a big one |
| **A usable artefact** | A template, a calculator, a checklist people keep |
| **Expert contribution** | Named practitioners with real credentials |
| **Better format** | The same information, faster to consume and easier to scan |

Original research deserves special mention: a modest survey of your own customers, or an analysis of data you already hold, produces a citable statistic that accumulates references indefinitely. It is the highest-leverage content investment available to most companies and requires no unusual skill.

Volume without differentiation is now actively counterproductive: cheap generated content is abundant, so producing more of it is competing in the most crowded, least defensible category there is.

---

## 4. Scaling: programmatic and user-generated content

**Programmatic content** generates many pages from structured data — locations, categories, comparisons, integrations. It works when each page is genuinely useful and distinct, the data is real and maintained, and pages are internally linked and indexable. It fails, and can trigger penalties, when pages are near-duplicates differing only by a substituted word. The test: would a human searching for this specific thing find this specific page useful?

**User-generated content** — reviews, questions, community answers, public profiles — creates a content loop that costs nothing per page and grows with usage. It requires moderation, spam control, and a plan for thin or abandoned pages.

---

## 5. Distribution is more than half the work

The common allocation error is spending 90% of effort on production and 10% on distribution. Invert it toward 50/50 at minimum.

| Channel | Practice |
|---------|----------|
| **Owned email list** | The most reliable distribution you have; every piece goes to it |
| **Communities and waterholes** | Only where you are a genuine participant (`idea-generation`) |
| **Direct outreach** | Tell the people cited, quoted, or referenced — high response rate, and the basis for links |
| **Partner and cross-promotion** | Newsletter swaps, co-authored pieces, guest contributions |
| **Social** | Native reformatting per platform, not a link drop (`social-and-community`) |
| **Paid amplification** | A small budget on the pieces that already perform organically |
| **Internal linking** | Cheapest distribution available; new pieces linked from existing relevant ones |
| **Repurposing** | One substantial piece becomes a video, a thread, a newsletter, a talk, a slide deck |

Two practices with unusually good returns: **updating existing content** — refreshing a piece that already ranks typically outperforms writing a new one, and almost nobody schedules it — and **direct outreach to people you cited**, because it is genuinely welcome rather than a cold pitch.

---

## 6. Measurement

Traffic is not the goal. Measure the chain:

| Level | Metric |
|-------|--------|
| Reach | Impressions, sessions, rankings for target queries |
| Engagement | Scroll depth, time, return visits |
| Capture | Email signups, tool usage, trial starts per piece |
| Pipeline | Qualified signups, opportunities, revenue attributed to the piece |
| Compounding | Traffic and conversions by publication cohort over time |
| Efficiency | Cost per piece against value produced over 12 months |

Attribution for content is genuinely hard — it is usually an early touch, and last-click attribution will make it look worthless. Use **self-reported attribution** in the signup flow, assisted-conversion views, and a **holdout or incrementality test** for significant spend (`acquisition`).

Set the review horizon in advance: judge a piece at 6 and 12 months, not at 6 weeks. Cut the topics that never convert regardless of traffic.

---

## 7. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Topics chosen by internal interest | Traffic that never converts |
| Volume as the ranking criterion for topic choice | High-traffic pages with no business relevance |
| Publishing without any distribution plan | Excellent content nobody reads |
| Abandoning the channel after 8 weeks | Cost paid, return never collected |
| Judging content on monthly traffic instead of by cohort | Compounding invisible; the channel looks flat |
| Mass-produced undifferentiated content | Competing in the most crowded category with no advantage |
| Programmatic pages differing by one substituted word | Thin content; penalty risk |
| Never updating existing content | The cheapest wins left on the table |
| Ignoring comparison and alternative pages | The highest-intent content type missing |
| No original data ever produced | Nothing to cite; no links |
| Content measured with last-click attribution only | Systematically undervalued and cut |
| Community distribution by an outsider dropping links | Reputational damage (`idea-generation`) |

---

## 8. Checklist

- [ ] Content treated as a compounding loop with a realistic time horizon
- [ ] Topics selected on business value × winnability, not search volume
- [ ] Comparison, alternative, use-case, and integration pages covered
- [ ] Customer language from support and sales used for topic wording
- [ ] At least one original-data or first-hand-experience asset produced
- [ ] Programmatic pages genuinely distinct and useful per page
- [ ] Distribution effort at least equal to production effort
- [ ] Every piece distributed to the owned list and internally linked
- [ ] People cited or referenced notified directly
- [ ] Update schedule for existing ranking content
- [ ] Repurposing plan per substantial piece
- [ ] Measurement chain from reach to pipeline, tracked by publication cohort
- [ ] Self-reported attribution and incrementality used, not last-click alone
- [ ] Technical SEO handled via the `seo` plugin rather than improvised here
