---
description: Structuring text so readers find and use it — front-loading the answer with the inverted pyramid and BLUF, heading hierarchy that works for scanning and screen readers, paragraph and chunking discipline, when to use lists and tables instead of prose, information order for instructions and reference, progressive disclosure, and layout properties that affect reading (line length, typography, alignment).
---

# Text structure and scannability

Goal of this skill: make the reader able to **find** the relevant part and **use** it — which is at least half of what plain language means, and the half readability scores cannot see.

Use this skill when a text is correct but nobody reads it, when support keeps answering questions the documentation already covers, or when writing anything longer than a screen.

---

## 1. People do not read; they scan

Reading behaviour on screen is search-driven: readers scan headings, first sentences, links, and anything visually distinct, until they find what looks like the answer. Then they read that part.

Two consequences shape everything below. **The first sentence of each section carries most of the weight**, because it is read far more often than the rest. And **structure is not decoration** — it is the interface through which the text is used.

---

## 2. Front-load the answer

Put the conclusion first, then the detail. Journalism calls it the inverted pyramid; military and business writing call it BLUF (bottom line up front). Academic writing does the opposite, which is why academic prose is hard to use as reference.

> **Buried** — In the course of migrating to the new authentication service, several approaches were evaluated. After considering token lifetimes, refresh behaviour, and the impact on mobile clients, it became apparent that … Therefore, sessions now expire after 12 hours.
>
> **Front-loaded** — **Sessions now expire after 12 hours.** Previously they lasted 30 days. We shortened them because … Mobile clients refresh automatically, so users stay logged in.

Apply it at three levels: the document opens with what it is and who it is for; each section opens with its conclusion; each paragraph opens with its point.

Exception worth knowing: for genuinely persuasive or bad-news writing, some context before the conclusion is appropriate. For anything informational or instructional, front-load.

---

## 3. Headings

Headings are the table of contents, the navigation, and the scanning surface — and for screen-reader users they are the primary means of moving through a page.

| Rule | Why |
|------|-----|
| **Descriptive, not clever** | `Cancel a subscription`, not `The end of the road` |
| **Answer or task oriented** | Write the heading a reader would search for |
| **One `h1` per page** | The page's subject |
| **Never skip levels** | `h2` → `h4` breaks screen-reader navigation |
| **Hierarchy reflects meaning** | Not chosen for font size |
| **Front-load keywords** | `Password reset — troubleshooting`, not `Troubleshooting the process of resetting passwords` |
| **A section under every heading** | A heading with one sentence under it is probably not a section |
| **Roughly every 3–5 paragraphs** | Longer stretches lose the scanner |

Test: read only the headings top to bottom. They should form a usable summary. If they do not, the structure is wrong — no amount of sentence editing will fix it.

---

## 4. Paragraphs and chunking

- **One topic per paragraph**, stated in the first sentence.
- **Three to five sentences** as a working range on screen; a single-sentence paragraph is a legitimate emphasis device, used sparingly.
- **No wall of text**: a paragraph longer than about six lines on screen is skipped by many readers regardless of its quality.
- **Chunk by meaning**, not by length — break where the topic turns, not where the paragraph looks long.
- **White space is functional**, not wasted; it marks boundaries and gives the eye a return point.

---

## 5. Lists and tables instead of prose

Prose is the wrong container for parallel information. Convert when you see these signals:

| Signal in the prose | Convert to |
|---------------------|------------|
| A sequence of steps | Numbered list |
| Several conditions joined by `and`/`or` | Bulleted list, with the logic stated |
| Options being compared on the same attributes | Table |
| A sentence with three or more semicolons | List |
| Repeated sentence patterns (`X does A. Y does B.`) | Table |
| Nested conditions | Decision table, or `if … then` list |

Rules that keep lists usable: **parallel grammatical structure** across items; a **lead-in sentence** that says what the list contains; **numbers only for sequence or reference**, bullets otherwise; **items short** — a list of paragraphs is prose with bullets; and **nesting at most one level deep**.

The most valuable conversion is conditional logic. A sentence carrying three conditions is the hardest thing in bureaucratic prose; the same content as a table with a condition column and a result column is trivial to use.

---

## 6. Information order

Different text types have different correct orders:

| Type | Order |
|------|-------|
| **Instruction** | Goal → prerequisites → numbered steps → result → what to do if it fails |
| **Reference** | Alphabetical or logical, with a stable, predictable per-entry shape |
| **Explanation** | Conclusion → context → detail → implications |
| **Decision support** | Recommendation → criteria → options against the criteria → trade-offs |
| **Bad news / persuasion** | Brief context → the message → what happens next → what the reader can do |
| **Troubleshooting** | Symptom → most likely cause → fix → next candidate cause |

Two failures that recur. In instructions, **prerequisites arriving after the steps** — the reader is already stuck at step 3 when told they needed an admin account. And in troubleshooting, **causes ordered by the author's interest** rather than by likelihood.

---

## 7. Progressive disclosure

Give every reader the shortest sufficient path, and put depth behind a step.

- **Summary first**, detail below.
- **Common case in the main flow**, edge cases in a clearly labelled section afterwards.
- **Collapsible detail** for optional depth — provided the collapsed content is still findable by search and by screen readers.
- **Link rather than inline** for background a minority needs.
- **Layered documents**: a one-paragraph answer, a one-page version, and the full reference — each complete at its own level.

The constraint: each layer must stand alone. A summary that cannot be acted on without the detail is not a summary, it is a teaser.

---

## 8. Layout properties that change reading

Text structure includes how it is set:

| Property | Guidance |
|----------|----------|
| **Line length** | Roughly 45–75 characters; long lines lose the return sweep |
| **Line spacing** | Around 1.5 for body text |
| **Alignment** | Left-aligned; justified text creates uneven word spacing, which is harder for many readers |
| **Type size** | ≥ 16 px body on screen; Leichte Sprache typically ≥ 14 pt in print |
| **Contrast** | Meet WCAG minimums; low-contrast grey body text is a common accessibility failure |
| **Emphasis** | Bold for scanning anchors; avoid long italic passages and all-caps |
| **Links** | Descriptive text — never `click here`; the link text must make sense read alone |
| **Hyphenation in German** | Long compounds may need soft hyphens to avoid breaking layouts |

Emphasis has a budget: if a third of the paragraph is bold, nothing is emphasised.

---

## 9. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Conclusion at the end | Readers leave before reaching it |
| Clever or vague headings | Unscannable; unsearchable |
| Skipped heading levels | Screen-reader navigation breaks |
| Headings chosen for visual size | Structure misrepresents meaning |
| Walls of text | Skipped regardless of quality |
| Steps in prose instead of a numbered list | Readers lose their place |
| Conditions in a sentence instead of a table | The hardest possible presentation of the easiest content |
| Prerequisites after the steps | Reader stuck mid-task |
| Non-parallel list items | Reader assumes a distinction that is not there |
| Deeply nested lists | Structure becomes unreadable |
| Collapsed content that is not searchable | Information effectively deleted |
| `click here` links | Useless out of context and to screen readers |
| Justified text with long lines | Measurably harder to read |
| Everything emphasised | Nothing is emphasised |

---

## 10. Checklist

- [ ] Document opens with what it is and who it is for
- [ ] Conclusion front-loaded at document, section, and paragraph level
- [ ] Headings descriptive, task- or answer-oriented, keyword-first
- [ ] One `h1`; no skipped levels; hierarchy reflects meaning
- [ ] Headings read alone form a usable summary
- [ ] One topic per paragraph, stated in the first sentence
- [ ] No paragraph longer than about six screen lines
- [ ] Steps as numbered lists; conditions and comparisons as tables
- [ ] List items grammatically parallel, with a lead-in sentence
- [ ] Nesting at most one level deep
- [ ] Information order matches the text type; prerequisites before steps
- [ ] Progressive disclosure used, with each layer complete on its own
- [ ] Collapsed content still findable by search and assistive technology
- [ ] Line length, spacing, size, and contrast within accessible ranges
- [ ] Left-aligned body text; emphasis used sparingly; link text descriptive
