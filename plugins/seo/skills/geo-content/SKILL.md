---
description: Generative Engine Optimization (GEO) for article content — how to structure, write, and validate articles so that ChatGPT, Perplexity, Google AI Overviews, Claude, and Gemini will quote, cite, and surface them. Covers content shape, citable facts, schema.org markup, E-E-A-T signals, snippet-ready chunks, and a creation/validation checklist.
---

# GEO content — writing and validating articles for generative engines

This skill is about **what an article should look like** so that LLM-powered search engines (ChatGPT Search, Perplexity, Google AI Overviews, Gemini, Claude, Bing Copilot) extract, cite, and quote it. Use this skill for editorial work — content shape, citability, structured data on the article level.

Two modes:

1. **Create** — when writing a new article, follow the rules in sections 1–9.
2. **Validate** — when auditing an existing article, run the checklist in section 10 and report findings with severity.

---

## 1. The mental model

Classic SEO rewards pages that rank in a list of ten blue links. GEO rewards **passages** that an LLM can lift into an answer with attribution. The unit is no longer the page — it is the chunk.

Optimize for three behaviours that retrieval-augmented LLMs share:

- **Chunk and embed**: text is split into 200–800-token chunks, embedded, and retrieved by similarity to a user's question.
- **Synthesize and attribute**: the model paraphrases the chunks but cites the source if a clear, attributable claim is present.
- **Prefer the explicit**: when two sources cover the same topic, the one with named authors, dated claims, structured data, and direct definitions is more likely to be cited.

Implication: every section should look like a self-contained, citable block that answers a specific question — not like a paragraph in a flowing essay.

---

## 2. Article skeleton

Use this shape unless you have a reason not to.

```text
H1: <The exact question or topic the user is searching for>

[TL;DR block — 2–4 bullets, plain text, no marketing language]

[Direct-answer lead paragraph — 40–80 words, fully defines the topic]

H2: <Question phrased naturally — e.g. "What is X?">
  [Definition paragraph — 40–80 words, self-contained]
  [Supporting detail — 1–3 paragraphs OR a table OR a bullet list]

H2: <Next question — e.g. "How does X work?">
  ...

H2: <Comparison or alternatives — e.g. "X vs Y">
  [Table with explicit columns: Feature | X | Y]

H2: <Common pitfalls / things to avoid>

H2: FAQ
  H3: <One short question per H3>
    [50–120 word answer, complete on its own]

[Author block — name, role, credentials, link to bio]
[Last reviewed: YYYY-MM-DD]
[Sources — numbered list with full URLs and publication dates]
```

The TL;DR, the lead, the question-headings, and the FAQ are the four blocks most often lifted by generative engines. They must each stand alone.

---

## 3. Headings — phrase them as questions

Generative engines retrieve by semantic similarity to a user query. A heading like "Performance considerations" embeds far less specifically than "Why is React slower than Svelte for large lists?".

Rules:

- Use **natural-language questions** for H2/H3 wherever possible.
- Use the **exact phrasing** a user would type or speak. Avoid jargon-only headings.
- Keep H2 ≤ 70 characters.
- One visible `<h1>` per page (this is also a hard SEO rule).
- Don't repeat keywords across headings — each heading should target a distinct sub-question.

Bad:

```markdown
## Configuration
## Advanced usage
## Notes
```

Good:

```markdown
## What does the `mode: "strict"` flag do?
## How do I migrate an existing project from `loose` to `strict`?
## When should I avoid strict mode?
```

---

## 4. The direct-answer paragraph

Open every H2 with a paragraph that fully answers the heading question in **40–80 words**, in plain language, without forward references.

Rules:

- First sentence is a complete definition or claim.
- No "In this section, we will…" preamble.
- No pronouns that point outside the paragraph ("it", "this") in the first sentence.
- Restate the subject by name so the chunk is self-contained when retrieved alone.
- Numbers, dates, and proper nouns belong in this paragraph if they exist.

Example:

> **What is INP?**
>
> Interaction to Next Paint (INP) is a Core Web Vital introduced by Google in March 2024 that measures how quickly a web page responds to user input across the lifetime of a visit. A "good" INP is 200 ms or less at the 75th percentile, measured in the field via the Chrome User Experience Report. INP replaced First Input Delay (FID) as a stable Core Web Vital.

That paragraph survives extraction. It names the subject, gives a date, gives a threshold, names the source, and explains the relationship to the prior metric.

---

## 5. Citable atomic facts

Generative engines preferentially cite passages that contain **specific, attributable claims**. Vague writing is paraphrased without credit.

In each section, include at least one of:

- A **number with units** ("180 ms", "12 % faster", "3.4 GB").
- A **date** ("released in March 2024", "deprecated in v18.2").
- A **named entity** (person, product, standard, RFC, study).
- A **direct quote** with attribution.
- A **first-party measurement** ("we measured", "our benchmark on a 2024 M3 Pro").

Avoid:

- "Many users report…" — who, when, where?
- "Studies have shown…" — which study?
- "Recent data suggests…" — date and source?

Hedged claims without sources are filtered out. Specific claims with sources are quoted.

---

## 6. Snippet-ready blocks

Some block types are disproportionately surfaced by AI Overviews and Perplexity-style answers. Use them where they fit honestly.

### TL;DR / key takeaways

Place after H1, before the lead paragraph.

```markdown
**Key takeaways**

- INP is the Core Web Vital that measures interaction responsiveness.
- A good INP is 200 ms or less at the 75th percentile.
- INP replaced FID in March 2024.
- The biggest INP wins usually come from breaking up long tasks.
```

Each bullet is a complete sentence. No bullet depends on another.

### Comparison table

Use when the article includes "X vs Y" or "should I use A or B".

```markdown
| Aspect              | Server Components | Client Components |
| ------------------- | ----------------- | ----------------- |
| Bundle cost         | 0 KB              | Ships JS          |
| Can use hooks       | No                | Yes               |
| Can fetch directly  | Yes (async)       | Via useEffect     |
| Renders on          | Server only       | Server + Client   |
```

Tables are extracted verbatim. Keep cells short. First column names the dimension; subsequent columns name the alternatives. Avoid merged cells.

### Step lists

Use for procedures. Number them. One action per step.

```markdown
1. Install the package: `pnpm add @lhci/cli -D`.
2. Create `lighthouserc.cjs` at the repo root.
3. Add `pnpm lhci autorun` to the CI pipeline after the build job.
4. Set the `assert.assertions` budget to fail builds below the threshold.
```

### Definition lists for terminology

```markdown
**LCP (Largest Contentful Paint)** — The time from navigation start to when the largest visible element renders. Good: ≤ 2.5 s.

**CLS (Cumulative Layout Shift)** — The sum of unexpected layout shifts during a page's lifetime. Good: ≤ 0.1.
```

### FAQ section

Always include 3–8 FAQs at the end. Each H3 is a question; the answer is 50–120 words and complete on its own. This is also where `FAQPage` JSON-LD lives (see section 8).

---

## 7. E-E-A-T signals (Experience, Expertise, Authoritativeness, Trust)

Google's AI Overviews and most LLM-based engines weight content from sources that look authored, dated, and accountable.

Required:

- **Visible author byline** with the author's real name and role.
- **Author bio block** at the bottom or in a sidebar with credentials and a link to a profile page (`/authors/<slug>`) marked up with `Person` schema.
- **Date published** and **date last reviewed** — both visible to readers, both in `Article` JSON-LD.
- **Sources / references block** at the bottom listing every external fact, with URL and access date for non-stable URLs.
- **Methodology note** for any first-party data ("we tested on …", "n = 124 sessions, …").

Avoid:

- Anonymous bylines like "The team" or "Editorial staff" on substantive articles.
- Fake authors. AI engines and Google increasingly detect fabricated personas.
- Stale "last updated" dates that don't match the actual content. Update the date only when content changes.

---

## 8. Schema.org / structured data

LLM crawlers and Google's grounding pipeline parse structured data to extract citable facts from articles. Every article should ship at least:

- **`Article`** (or `NewsArticle` / `BlogPosting`) with `headline`, `description`, `datePublished`, `dateModified`, `author`, `publisher`, `image`, `mainEntityOfPage`.
- **`FAQPage`** when the article has an FAQ block — questions and answers must match the visible body verbatim.
- **`BreadcrumbList`** for navigation hierarchy.
- **`Person`** on author bylines (with `sameAs` to LinkedIn, GitHub, ORCID).
- **`Organization`** site-wide.

Pick a format and stick with it:

- **JSON-LD** — Google-preferred, separated from DOM, refactor-safe. Full type recipes, `@graph` patterns, framework integration in **`structured-data-jsonld`**.
- **Microdata** — inline attributes; no source-of-truth drift. Full recipes in **`html5-microdata`**.

Validation rule (regardless of format): every structured fact must agree with the visible content. Hidden FAQ entries and fake aggregate ratings risk a manual action. See either skill's "mismatch prevention" section.

---

## 9. Style rules for LLM extraction

LLMs are trained to filter for clarity and signal. Style choices that hurt human readers also hurt extractability.

### Do

- Write short sentences. ≤ 25 words on average.
- Write concrete subjects: "React's reconciler diffs the virtual DOM" beats "It performs a comparison".
- Restate the subject at the start of each section.
- Use precise verbs ("measures", "replaces", "deprecates") not vague ones ("addresses", "supports", "involves").
- Define every acronym on first use within each H2 — sections are retrieved out of order.
- Link out to canonical sources (MDN, RFCs, Wikipedia, primary research). Outbound links increase trust.

### Don't

- Don't write filler intros ("In today's fast-paced world…").
- Don't bury the answer below 200 words of context.
- Don't use vague intensifiers ("very", "really", "quite") in factual claims.
- Don't keyword-stuff. Repetition past the point of natural usage signals manipulation.
- Don't pad with synonyms. "Fast, quick, speedy and rapid" looks like SEO spam.
- Don't use "click here" or "learn more" link text. Use descriptive anchors.
- Don't put critical facts only inside images. Engines can extract alt text, but body text is more reliable.

---

## 10. Validation checklist

Use this when auditing an existing article. Score each item; report findings with severity (`high` / `medium` / `low`).

### Structure

- [ ] One visible `<h1>` matching the article topic.
- [ ] TL;DR / key-takeaways block within the first 200 words.
- [ ] Direct-answer lead paragraph (40–80 words) immediately after the H1.
- [ ] H2 headings phrased as natural-language questions where applicable.
- [ ] Each H2 opens with a 40–80-word self-contained definition or answer.
- [ ] FAQ block with 3–8 questions at the end.

### Citability

- [ ] Each major claim has a number, date, named entity, or citation.
- [ ] No vague hedges ("many", "studies show", "recent data") without sources.
- [ ] Direct quotes include attribution.
- [ ] First-party data includes methodology.

### E-E-A-T

- [ ] Visible author byline with real name and role.
- [ ] Author bio block with credentials and profile link.
- [ ] `datePublished` and `dateModified` visible and accurate.
- [ ] Sources / references list at the bottom with URLs.

### Schema

- [ ] `Article` JSON-LD present, parses, agrees with visible content.
- [ ] `FAQPage` JSON-LD present if FAQ block exists.
- [ ] `Person` schema on author, `Organization` on publisher.
- [ ] No hidden facts that exist only in JSON-LD.

### Style

- [ ] Average sentence length ≤ 25 words.
- [ ] No filler intro paragraph.
- [ ] Acronyms defined on first use within each H2.
- [ ] Descriptive link anchors, no "click here".

### Snippet blocks

- [ ] At least one of: comparison table, step list, definition list — where appropriate to topic.
- [ ] Tables have a header row, no merged cells, short cells.
- [ ] Step lists are numbered, one action per step.

### Anti-patterns

- [ ] No keyword stuffing or synonym padding.
- [ ] No anonymous byline on substantive content.
- [ ] No stale `dateModified` (matches the most recent meaningful edit).
- [ ] No critical facts trapped inside images only.
- [ ] No fabricated stats, dates, or quotes.

Severity guide:

- `high` — missing direct answer paragraphs, missing author/date, broken JSON-LD, fabricated facts, no sources for substantive claims.
- `medium` — vague headings instead of questions, no TL;DR, no FAQ, missing schema types where applicable, average sentence length far above 25 words.
- `low` — minor style issues, missing optional schema (BreadcrumbList, Person.sameAs), table polish.

---

## 11. Output formats

When this skill is used in **create** mode, return the article in Markdown using the section 2 skeleton, plus a separate fenced JSON-LD block for `Article` and (if applicable) `FAQPage`.

When this skill is used in **validate** mode, return:

```text
# GEO Content Audit — <article title or URL>

## Summary
- Direct answer present: yes/no
- Headings as questions: X/Y
- Citable facts per H2: median N
- E-E-A-T signals: <list>
- Schema present: <Article | FAQPage | …>
- Overall: <PASS | NEEDS WORK | FAIL>

## Findings
**[HIGH]** <location> — <issue> — <recommended fix>
**[MEDIUM]** ...
**[LOW]** ...

## Recommended fix order
1. ...
```

Then offer to apply each fix. Apply approved fixes one at a time, confirming each.

---

## 12. Things to never do

- ❌ Open with a filler intro instead of the answer.
- ❌ Use generic noun-phrase headings like "Overview" or "Considerations".
- ❌ Bury the definition below 200 words of context.
- ❌ Use anonymous bylines on substantive articles.
- ❌ Date-stuff (changing `dateModified` without changing content).
- ❌ Put the only copy of a fact inside an image.
- ❌ Stuff JSON-LD with claims not present in the visible body.
- ❌ Fabricate authors, statistics, quotes, or studies.
- ❌ Pad with synonyms or repeat target keywords beyond natural usage.
- ❌ Use vague link anchors like "click here" or "read more".
- ❌ Ship a wall of text with no tables, lists, or definition blocks.
- ❌ Mix two unrelated topics in one article — split them so each chunk is on-topic.
