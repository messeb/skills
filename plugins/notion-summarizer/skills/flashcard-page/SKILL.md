---
description: Building a flashcard page from a finished summary for spaced-repetition tools — RemNote `::` syntax by default, with Anki and plain question-answer variants — one copyable code block per section inside a toggle heading, rules for atomic cards, card types worth writing, how many cards per section, and keeping cards usable as a compact knowledge base for agents.
---

<!-- markdownlint-disable MD010 -- hard tabs are required: Notion nests child blocks by tab indentation -->

# Flashcard page

Goal of this skill: produce one Notion page from which the user can copy each section's cards straight into a spaced-repetition tool, and which doubles as a compact fact base.

Use this skill after all section pages are written. Write the cards from the working notes and the section pages, not from memory.

---

## 1. Page layout

1. Yellow callout: what the page is and which syntax it uses.
2. Green callout "How to use" with numbered steps for the import.
3. Overview table: parts of the source, which sections, focus.
4. Divider.
5. One **toggle heading** per section, colored like the section page. Inside it one code block with language `text`.

Title: `Flashcards: <Source title>`, or the name of the tool if the user uses one consistently (for example `RemNote Learning: <Source title>`). The toggle headings on this page **keep** the section number (`Ch 03 <title>`) because order matters for learning.

---

## 2. Card syntax

Default is RemNote:

```text
<Source title>: Ch 03 <Section title>
	Front :: Back
	Term :: Definition in one sentence
	Question needing a list :: Item one, item two, item three
```

- The first line is the parent entry. Every card is one line below it, indented with one tab.
- `::` creates a forward card. The user can change it to `:::` for two-way cards on pure term and definition pairs. Mention this in the how-to callout.
- One card per line. No line breaks inside a card.

Variants on request:

| Tool | Format |
|------|--------|
| Anki import | `Front<TAB>Back`, one per line, no parent line; or `Front;Back` with a stated separator |
| Plain Q and A | `Q: ...` and `A: ...` on two lines, blank line between cards |
| Cloze | `The {{c1::term}} does X` for Anki; use sparingly |

Ask which tool only if the user has not said and no earlier page shows it.

---

## 3. Rules for good cards

- **Atomic**: one fact per card. If the back needs "and also", split it.
- **Own words**, short. Back side under 25 words, lists under seven items.
- **Context-free front**: the front must make sense without the book open. Write "Budget formula of optimizer X", not "the formula from this section".
- **Precise**: keep exact names, parameters and numbers. Scope results ("in the book's benchmark").
- **No yes/no cards**, no trivia, no cards about anecdotes.
- Write in the language the user learns in; keep technical terms in their original language.

Card types worth writing:

| Type | Front pattern |
|------|---------------|
| Definition | `Term` |
| Contrast | `A vs B` |
| Enumeration | `Five core abstractions of X` |
| Purpose | `Why do X` |
| Procedure | `Steps to X` or `Debug order for X` |
| Rule of thumb | `When to choose X` |
| API fact | `function_name` |
| Pitfall | `Risk when X` |

---

## 4. How many

| Section size | Cards |
|--------------|-------|
| Short | 8 to 12 |
| Medium | 12 to 20 |
| Long or reference-heavy | 20 to 40 |

Cover every key takeaway and every table of the section page with at least one card. More cards than this usually means non-atomic facts or trivia.

---

## 5. Writing the page

- If the page gets long, create it with the first sections and append the remaining toggles with insert calls. Never replace the whole page to add a section.
- Inside the toggle heading the code fence is indented with one tab. The lines inside the code block are literal: parent line without indentation, cards with one tab.
- Fetch the page afterwards and check that every section has a block and that no card line lost its `::`.

---

## 6. Anti-patterns

| Anti-pattern | Why it fails | Do instead |
|--------------|--------------|-----------|
| Copying sentences from the source as backs | Copyright, poor recall | Rephrase, shorten |
| "What does the author say about X?" | Front gives no cue | Name the concept |
| Ten-item lists on one back | Cannot be recalled | Split or group |
| Cards as Notion bullets | Cannot be copied as a block | Code block per section |
| One giant code block | Hard to import in parts | One block per section |
| Writing cards before the summaries | Cards miss the structure | Cards last |

---

## 7. Checklist

- [ ] Intro and how-to callouts, overview table
- [ ] One toggle heading with one code block per section, in order
- [ ] Parent line plus one-line cards with the right separator
- [ ] Cards atomic, context-free, own words
- [ ] Every takeaway and table covered
- [ ] Page verified after writing
