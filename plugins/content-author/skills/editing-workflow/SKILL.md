---
description: Turning a draft into publishable text — separating writing from editing, the sequence of revision passes from structure down to proofreading, self-editing techniques that work, reading text aloud and other detection methods, testing with real readers, style guide and terminology management, automated checks in CI, review roles, and localisation handover.
---

# Editing workflow

Goal of this skill: a repeatable revision process that fixes the big things before the small ones, and ends with evidence that readers can actually use the text.

Use this skill when editing your own draft, reviewing someone else's, or setting up an editorial process for a team.

---

## 1. Write and edit in separate passes

Drafting and editing use opposing modes: drafting needs momentum and tolerance for bad output, editing needs judgement and ruthlessness. Doing both at once produces a slow first paragraph and no second one.

Practical separation: **draft badly on purpose** and fix it later; put time between drafting and editing where the deadline allows — even an hour helps; and edit on a different surface (printed, a different font, a preview render), because the eye skips what it has already seen in the same layout.

---

## 2. The revision passes, in order

Fixing commas before fixing structure wastes the comma work, because the sentence will be deleted. Work top-down.

| # | Pass | Question | Typical fix |
|---|------|----------|-------------|
| 1 | **Purpose** | What must the reader be able to do after reading? Does the text do that? | Cut whole sections; sometimes rewrite from scratch |
| 2 | **Audience** | Right level, right assumptions, right vocabulary? | Change level, add or remove background (`plain-language`) |
| 3 | **Structure** | Is the answer first? Do the headings form a summary? | Reorder, re-head, split, merge (`text-structure`) |
| 4 | **Completeness** | Missing prerequisite, condition, failure case, next step? | Add what is missing |
| 5 | **Paragraph** | One topic each? Point in the first sentence? | Split, merge, front-load |
| 6 | **Sentence** | One idea, active, verbal, concrete? | The moves in `sentence-craft` |
| 7 | **Word** | Familiar, consistent, precise? | Terminology, filler, hedges |
| 8 | **Measure** | Does the score confirm the rewrite? Any outlier paragraph? | Investigate outliers (`readability`) |
| 9 | **Proofread** | Spelling, grammar, punctuation, formatting, links | Mechanical correction |
| 10 | **Accessibility** | Headings, link text, alt text, contrast | Structural and markup fixes |

Do not start at 9. The most common editing failure is a beautifully proofread document that answers the wrong question.

For a short text, passes 1–3 can take two minutes. Skipping them is what costs an hour later.

---

## 3. Self-editing techniques that actually work

| Technique | Catches |
|-----------|---------|
| **Read it aloud** | Long sentences, missing rhythm, unnatural phrasing, verb brackets in German — the single most effective technique available |
| **Read headings only** | Broken structure |
| **Read first sentences only** | Whether paragraphs are front-loaded |
| **Read it backwards, sentence by sentence** | Typos, because the sense no longer carries you past them |
| **Change the font or print it** | Everything the eye has memorised |
| **Highlight every verb** | Nominal style and passive clusters |
| **Search for `-ung`, `erfolgt`, `wird … geprüft`** | German nominal and passive constructions |
| **Search for `it should be noted`, `grundsätzlich`, `basically`** | Filler openers |
| **Delete the first paragraph** | Throat-clearing — the text often starts better without it |
| **Cut 10% with no loss** | Redundancy; a reliable target on nearly every first draft |
| **Explain it to someone in one sentence** | Whether you know what the text is for |

The 10% rule is worth taking literally. Almost every first draft loses a tenth of its words with no loss of meaning, and the result is measurably easier to read.

---

## 4. Testing with readers

No index and no reviewer replaces watching someone use the text (`readability` §9).

A minimal, cheap protocol:

1. Recruit **five people** resembling the real audience — not colleagues who already know the product.
2. Give them a **realistic task**, phrased in their words, not the document's headings: *"Find out whether you can cancel and what it costs."*
3. **Watch silently.** Do not explain, do not rescue at the first hesitation.
4. Note **where they look, what they skip, where they backtrack, what they say aloud**.
5. Ask afterwards: *what did you expect here? what was unclear? what would you have called this?*
6. Fix the top problems and re-test.

Signals worth acting on: readers using the search box on a short page (structure failed), skipping the section that contains the answer (heading failed), reading a sentence twice (sentence failed), and asking a question the text answers (findability failed).

Five readers surface most severe problems. For a claim about *how many* people struggle, you need many more (`growth-hacking:usability-testing` if that plugin is installed).

---

## 5. Style guide and terminology

Editorial consistency is impossible without a written reference. Keep it short enough to be read.

Minimum contents: **voice and tone** with two examples; **address form** (`Sie`/`du`, or `you`); **gendering rule** (`german-writing`); **terminology list** — term, definition, and forbidden alternatives; **anglicism policy**; **formatting conventions** for headings, lists, numbers, dates, and units; **readability index and target**; and **the accessibility rules that apply**.

Terminology deserves a real list rather than a habit. One term per concept, one concept per term, with the rejected synonyms recorded so the decision is not re-argued (`sentence-craft`).

---

## 6. Automated checks

Useful as a net beneath the human passes, never as a replacement:

| Check | Tooling |
|-------|---------|
| Spelling and grammar | Language tooling with a project dictionary |
| Style rules — passive, nominalisations, filler, long sentences | A prose linter with a configured rule set |
| Readability score per file | A script computing the agreed index, excluding code and tables |
| Terminology violations | Regex or a terminology checker against the forbidden-alternatives list |
| Broken links, missing alt text, heading-level skips | Markdown and accessibility linters |
| Consistency of numbers, units, product names | Custom rules |

Wire them into CI and fail on the ones that are objectively wrong (broken links, heading skips, forbidden terms); **warn** on the subjective ones (readability, passive voice). A build that fails on a legitimate passive sentence teaches people to disable the check.

Report the **worst paragraph**, not the file average — that is the actionable unit.

---

## 7. Review roles

Different reviewers catch different defects; asking one person for "feedback" gets you whatever they happen to notice.

| Reviewer | Reviews for |
|----------|-------------|
| **Subject expert** | Factual correctness, completeness, dangerous omissions |
| **Editor** | Structure, clarity, consistency, style guide compliance |
| **Target reader** | Comprehensibility and findability — the only one who can judge this |
| **Legal / compliance** | Claims, obligations, regulated wording |
| **Accessibility** | Heading structure, link text, alt text, language level |
| **Localisation** | Translatability, before the text is finalised |

Give each a specific question rather than a general request, and separate **factual objections** (must fix) from **stylistic preferences** (discuss). Where reviewers disagree on style, the style guide decides — that is what it is for.

---

## 8. Writing for translation

If the text will be localised, decisions made now determine cost and quality later:

- **Short, simple sentences** translate cleanly; nested clauses do not.
- **Avoid idiom, metaphor, humour, and cultural references** — they do not survive.
- **Consistent terminology** enables translation memory to work; synonyms defeat it.
- **Avoid concatenating strings** in UI text; grammar differs and word order changes.
- **Leave room for expansion** — German runs roughly 30% longer than English, which breaks fixed-width layouts.
- **Do not embed text in images**; it cannot be translated or read by assistive technology.
- **Provide context notes** for translators: who says this, to whom, where it appears.
- **Re-measure readability in the target language** with that language's index — a clean English text can translate into heavy German.

---

## 9. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Editing while drafting | Slow, blocked, no draft |
| Proofreading before restructuring | Careful work on text that gets deleted |
| Editing only on screen, in the same layout | The eye skips what it has memorised |
| Never reading aloud | Long sentences and awkward phrasing survive |
| Publishing without any reader testing | Comprehension assumed, never checked |
| Testing with colleagues | They already know the answer |
| Rescuing the reader during a test | The finding disappears |
| No style guide | Every review re-argues the same points |
| No terminology list | Synonym drift; translation memory fails |
| CI failing on subjective style rules | Checks disabled by the team |
| Reporting only the document average score | The impenetrable paragraph stays hidden |
| One reviewer asked for general "feedback" | Whatever they happened to notice |
| Stylistic preferences treated as blocking | Endless review cycles |
| Localisation considered after the text is final | Expensive rework, or bad translations |

---

## 10. Checklist

- [ ] Drafting and editing separated in time and surface
- [ ] Revision passes run top-down: purpose → audience → structure → sentence → word → proofread
- [ ] Purpose stated as what the reader must be able to do
- [ ] Headings read alone as a summary
- [ ] Text read aloud at least once
- [ ] 10% cut from the first draft with no loss of meaning
- [ ] Readability measured after rewriting; outlier paragraphs investigated
- [ ] Tested with five real readers on a realistic task, without rescuing
- [ ] Top findings fixed and re-tested
- [ ] Style guide and terminology list exist and were applied
- [ ] Automated checks in CI: hard-fail on objective defects, warn on subjective ones
- [ ] Reviewers assigned specific questions by role
- [ ] Factual objections separated from stylistic preferences; style guide arbitrates
- [ ] Accessibility pass completed: headings, link text, alt text, contrast, language level
- [ ] Translatability handled before finalising, with expansion room and context notes
