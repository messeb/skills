---
description: Measuring text readability in English and German — Flesch Reading Ease and the Amstad German adaptation, Flesch-Kincaid, Gunning Fog, SMOG, Dale-Chall, LIX, and the Wiener Sachtextformeln, with exact formulas, interpretation scales, target values per text type, why English formulas must not be applied to German, counting pitfalls that corrupt scores, tooling, and the difference between improving a text and gaming its score.
---

# Readability indices (English and German)

Goal of this skill: measure how hard a text is to read, in the right index for the language, and use the number as a **diagnostic signal** rather than a target to be gamed.

Use this skill when setting a readability standard for documentation, marketing, UI text, or public-sector content; when a text "feels heavy" and you need evidence; or when a client or regulator requires a stated readability level.

---

## 1. What these indices actually measure

Almost every classical index combines exactly two surface proxies:

- **Sentence length** — average words per sentence
- **Word difficulty** — average syllables per word, share of long words, or share of words outside a common-word list

That is all. They do **not** measure whether the text is coherent, correctly ordered, well structured, factually right, or appropriate for its audience. A random word salad with short sentences and short words scores excellently.

Treat a score the way you treat a temperature: a fast, cheap indicator that something may be wrong, never a description of the patient's health. The score tells you *where to look*; reading the text tells you what is actually wrong.

---

## 2. The central rule: formulas are language-specific

**Do not apply an English formula to German text.** German has systematically longer words — compounds (`Geschwindigkeitsbegrenzung`), inflection, and a preference for nominal constructions — so an English formula reports German as far harder than it is to a German reader.

| Index type | Travels between languages? | Why |
|------------|---------------------------|-----|
| **Syllable-based** (Flesch, Flesch-Kincaid, Gunning Fog, SMOG) | **No** — needs recalibration per language | Syllable norms differ; German averages more syllables per word |
| **Letter-based** (LIX, ARI, Coleman-Liau) | **Better** — more robust across languages | Character counts avoid language-specific syllabification |
| **Word-list-based** (Dale-Chall) | **No** — the list is the formula | Requires a validated list for that language |

Two practical consequences: use the German-calibrated formulas (Amstad Flesch, Wiener Sachtextformel) for German, and prefer **LIX** when you need one number that is comparable across a German and English version of the same content.

---

## 3. English formulas

### Flesch Reading Ease

```text
FRE = 206.835 − 1.015 × ASL − 84.6 × ASW

ASL = words ÷ sentences          (average sentence length)
ASW = syllables ÷ words          (average syllables per word)
```

Higher is easier. Roughly: 90–100 very easy, 60–70 standard, 30–50 difficult, 0–30 very difficult (academic).

### Flesch-Kincaid Grade Level

```text
FKGL = 0.39 × ASL + 11.8 × ASW − 15.59
```

Result is a US school grade level. Note that it uses the same two inputs as Flesch Reading Ease but is scaled the opposite way: **higher means harder**.

### Gunning Fog Index

```text
GFI = 0.4 × ( W/S + 100 × D/W )

W = total words
S = total sentences
D = words with three or more syllables
```

Result is a US school grade level. The `D` term makes it more sensitive to jargon than Flesch.

### SMOG

```text
SMOG grade = 3 + √(polysyllable count)

polysyllable count = words with more than two syllables, in a sample of 30 sentences
```

Requires the 30-sentence sample to be valid as specified. Widely used for health and safety material, where it is generally regarded as conservative — that is, it errs toward demanding easier text.

### Dale-Chall

```text
raw = 0.1579 × PDW + 0.0496 × ASL                (if PDW < 5%)
raw = 0.1579 × PDW + 0.0496 × ASL + 3.6365       (if PDW ≥ 5%)

PDW = percentage of words NOT on the Dale-Chall list of ~3,000 familiar words
ASL = average sentence length
```

The only formula here that models **word familiarity** rather than word length, which makes it closer to how comprehension actually works — at the cost of depending on a curated list.

**ARI** and the **Coleman-Liau index** are character-based alternatives that avoid syllable counting entirely. They are useful for automated pipelines; take their coefficients from a primary source rather than from this document, as they were not verified here.

---

## 4. German formulas

### Flesch Reading Ease, German (Amstad)

Toni Amstad recalibrated Flesch for German:

```text
FRE_de = 180 − ASL − 58.5 × ASW

ASL = words ÷ sentences
ASW = syllables ÷ words
```

| Score | Label | Suitable for |
|-------|-------|--------------|
| 0–30 | Sehr schwer (very difficult) | Academics |
| 30–50 | Schwer (difficult) | |
| 50–60 | Mittelschwer (moderately difficult) | |
| 60–70 | Mittel (medium) | Ages 13–15 |
| 70–80 | Mittelleicht (moderately easy) | |
| 80–90 | Leicht (easy) | |
| 90–100 | Sehr leicht (very easy) | Age 11 and up |

The coefficients differ substantially from the English version (`180` versus `206.835`, and `58.5` versus `84.6`). Running German text through the English formula and comparing against the English bands is the single most common error in this field.

### Wiener Sachtextformel (WSTF)

Developed in Vienna for German non-fiction. Four variants, using progressively fewer inputs:

```text
WSTF₁ = 0.1935 × MS + 0.1672 × SL + 0.1297 × IW − 0.0327 × ES − 0.875
WSTF₂ = 0.2007 × MS + 0.1682 × SL + 0.1373 × IW − 2.779
WSTF₃ = 0.2963 × MS + 0.1905 × SL − 1.1144
WSTF₄ = 0.2744 × MS + 0.2656 × SL − 1.693

MS = percentage of words with three or more syllables
SL = average sentence length (words)
IW = percentage of words with six or more letters
ES = percentage of single-syllable words
```

The result is a **school grade level from 4 to 15**, where 4 is very easy and 15 very difficult. Above 12, read the number as a difficulty level rather than a literal grade.

Use `WSTF₁` when you can compute all four inputs; the shorter variants exist for hand calculation and give slightly coarser results. Report which variant you used — the numbers are not interchangeable.

### LIX (Björnsson)

```text
LIX = A/B + (C × 100)/A

A = number of words
B = number of sentences
C = number of long words (more than six letters)
```

Roughly: 20 very easy, 30 easy, 40 medium, 50 difficult, 60 very difficult. Developed in Sweden and used across Scandinavian languages and German.

LIX is the most useful index in a bilingual setting because it counts letters rather than syllables, so a German and an English version of the same text can be compared on one scale without recalibration.

---

## 5. Target values by text type

Targets, not laws. Choose one index, state it, and hold the whole team to the same one.

| Text type | German Flesch (Amstad) | WSTF grade | LIX |
|-----------|------------------------|-----------|-----|
| Public-sector information for the general public | 60–70+ | ≤ 8 | ≤ 40 |
| Consumer marketing, landing pages | 60–70 | 6–9 | 35–45 |
| Product documentation, help centre | 50–65 | 8–11 | 40–50 |
| Developer documentation | 40–60 | 10–13 | 45–55 |
| B2B whitepaper, professional audience | 40–55 | 11–14 | 45–55 |
| Legal, scientific, regulatory | 30–50 | 12–15 | 50–60 |

Two adjustments worth making. **Set the target from the audience, not from the genre** — developer documentation read by non-native speakers should aim easier than the row suggests. And **the target is a floor for the hardest paragraph, not an average**: a document averaging 60 that contains one paragraph at 15 still fails the reader exactly where it matters.

---

## 6. Counting pitfalls that corrupt the score

Two tools will give you different scores for the same text. Before comparing anything, know how yours counts:

| Element | Problem | Practice |
|---------|---------|----------|
| **Headings** | Verbless fragments count as sentences, inflating ease | Measure body text separately from headings |
| **Lists** | Bullets counted as one long sentence, or as many tiny ones | Decide and apply consistently |
| **Abbreviations** | `z. B.`, `etc.`, `Dr.` split sentences at the period | Use a tool with abbreviation handling, or expand before measuring |
| **Numbers, URLs, code** | Syllable counting is meaningless for them | Exclude code blocks, tables, and URLs |
| **Syllable counting** | Heuristic and error-prone, especially for German compounds and loanwords | Prefer letter-based indices when precision matters |
| **Sample size** | Short texts produce unstable scores | At least ~100 words; SMOG needs its specified 30 sentences |
| **Mixed language** | Anglicisms in German text distort syllabification | Note it; do not over-interpret small differences |

Because of all this: **report the index, the tool, and the version**, and compare only like with like. A drift from 62 to 58 between two tools is noise; a drift from 62 to 35 is a finding.

---

## 7. Improving a text versus gaming a score

Both raise the number. Only one helps the reader.

| Gaming the score | Genuinely improving readability |
|------------------|--------------------------------|
| Splitting a sentence at a comma into two fragments | Splitting one sentence carrying three ideas into three sentences |
| Replacing a precise term with a vaguer short one | Introducing the precise term once, in plain words, then using it |
| Deleting subordinate clauses that carried the condition | Moving the condition to its own sentence, keeping the meaning |
| Cutting connectives (`therefore`, `however`, `weil`) | Keeping connectives — they are what make text coherent |
| Chopping German compounds arbitrarily | Replacing a nominalisation with a verb |
| Shortening by removing examples | Shortening by removing repetition |

The documented criticism of these formulas is precisely this: *"an attempt to simplify the text only by changing the length of the words and sentences may result in text that is more difficult to read."* Removing the connectives that signal logical relations raises the score and destroys comprehension.

The honest workflow is the reverse of score-chasing: **rewrite for the reader first** (`sentence-craft`, `text-structure`, `plain-language`), then measure to confirm, then investigate any paragraph that remains an outlier.

---

## 8. Tooling

| Need | Approach |
|------|----------|
| Quick check while writing | Editor extension or web tool; verify it supports German formulas before trusting German numbers |
| German-specific | A tool implementing Amstad and/or WSTF explicitly — not an English tool with German text pasted in |
| Automated in CI | A script over the source files, excluding code blocks, failing the build above a threshold |
| Bilingual comparison | LIX for both languages |
| Beyond formulas | Style linters that flag passive voice, nominalisations, and long sentences give more actionable output than a single score |

For a documentation repository, a CI check is worth the effort: compute the score per file, and fail or warn when a file crosses the agreed threshold. Report the **worst paragraph** in the failure message, not the document average — that is the actionable unit.

---

## 9. Limitations to state whenever you report a score

- Measures surface features only: no coherence, no logical order, no terminology familiarity, no layout.
- Blind to whether the text is correct or complete.
- Blind to the reader: prior knowledge, motivation, and native language dominate real comprehension.
- Language- and genre-specific; cross-language comparison requires a letter-based index.
- Unstable on short texts.
- Gameable, and optimising the number in isolation reliably produces worse text.
- No index replaces testing the text with actual readers — five people attempting the task the text supports will tell you more than any formula (`editing-workflow`).

---

## 10. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| English Flesch applied to German text | German text judged far harder than it is; wrong rewrites follow |
| Comparing scores from different tools or indices | Meaningless deltas treated as progress |
| Optimising the score instead of the text | Fragmented, connective-free prose that scores well and reads badly |
| Deleting `however`, `because`, `therefore` to shorten sentences | Logical relations lost; comprehension falls as the score rises |
| Replacing precise terms with vague short ones | Ambiguity introduced to gain points |
| Reporting a document average only | The one impenetrable paragraph stays hidden |
| Measuring headings, code, and tables with body text | Score reflects formatting, not prose |
| Using SMOG on fewer than 30 sentences | Formula applied outside its definition |
| Treating a score as proof of comprehension | No index tests understanding |
| Setting a target without naming the index | Nobody can verify or reproduce it |

---

## 11. Checklist

- [ ] Index chosen to match the language: Amstad Flesch or WSTF for German, Flesch/FKGL for English, LIX for both
- [ ] English formulas never applied to German text
- [ ] Index, variant, and tool named wherever a score is reported
- [ ] Target value set from the audience, not only the genre
- [ ] Target applied to the hardest paragraph, not only the document average
- [ ] Headings, lists, code, tables, and URLs excluded or handled consistently
- [ ] Abbreviations handled so sentence counts are correct
- [ ] Sample long enough for the index to be stable
- [ ] Text rewritten for the reader first, then measured
- [ ] Connectives, conditions, and precise terms preserved during simplification
- [ ] Outlier paragraphs investigated individually
- [ ] Limitations stated alongside the number
- [ ] Score treated as a signal, with real reader testing as the actual evidence
