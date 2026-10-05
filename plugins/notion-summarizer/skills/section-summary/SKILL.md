---
description: Turning one section of a source into a summary that is mostly bullet lists and tables — extracting key takeaways, choosing between table, list, numbered steps, callout, toggle and code pattern for each piece of content, highlighting what matters, keeping numbers and terms exact, sizing the page, and writing in your own words so the page works for later lookup by people and by agents.
---

# Section summary

Goal of this skill: decide **what** goes on a section page and in which form. How it is rendered in Notion is covered by `notion-page-styling`.

Use this skill for every section you summarize. Do not use it for the flashcard page; that has its own rules in `flashcard-page`.

---

## 1. Read for structure, not for sentences

While reading, collect these items:

| Collect | Question to ask |
| --------- | ----------------- |
| Thesis | What is the one claim of this section? |
| Concepts | Which terms are defined? |
| Enumerations | Which lists does the author give (N steps, N types, N principles)? |
| Comparisons | What is contrasted with what, along which dimensions? |
| Procedures | What is done in which order? |
| Rules of thumb | Which decision rules or thresholds are given? |
| Numbers | Which results, sizes, costs, percentages are stated? |
| Warnings | What goes wrong, and what is the fix? |
| Examples | Which worked example carries the section? |

If the author gives a list of N items, the summary shows all N. Never silently drop items from an enumeration.

---

## 2. Choose the form

| Content | Form |
| --------- | ------ |
| Items with two or more attributes | **Table** |
| Comparison of options | Table with one column per dimension, or two columns side by side for exactly two options |
| Ordered procedure | Numbered list |
| Unordered facts | Bullet list, one fact per bullet |
| The few things to remember | "Key takeaways" callout at the top |
| Tip, rule of thumb | Green or blue callout |
| Pitfall, caveat | Orange or red callout |
| Definition or side note | Gray or purple callout |
| Secondary detail, long reference lists | Toggle |
| API pattern or command | Short code block, minimal pattern only |
| Formula | Equation block |
| Closing principles | Recap callout at the bottom |

Prose paragraphs are the exception. If a paragraph has more than three sentences, convert it.

---

## 3. Page skeleton

Every section page has the same order so the reader can navigate all of them the same way.

1. Intro callout: section number in bold and one sentence of context.
2. Table of contents.
3. Key takeaways callout with three to six bullets.
4. Divider.
5. Body: one H2 per major heading of the source, merged where the source is fragmented. Four to eight H2 sections per page.
6. Divider.
7. Recap callout: the closing principles, or the bridge to the next section.

---

## 4. Writing rules

- One fact per bullet. Start with the term or the action, not with filler.
- Bold the term being defined and the one phrase per bullet that carries the meaning. Do not bold whole sentences.
- Put API names, commands, parameters and file names in inline code.
- Keep numbers exact and keep their scope ("on the book's benchmark", "in the author's example"). Do not generalize a single result.
- Keep the author's terminology. Do not rename concepts.
- Attribute opinions ("the author's default", "rule of thumb from the text"); state facts plainly.
- Do not add knowledge that is not in the source. If you add a clarification, mark it as a note.
- Table cells hold phrases, not paragraphs. Three to five columns at most.
- No standalone dashes as sentence punctuation; use colons, commas or a new bullet.
- Write in the language the user asked for, independent of the source language.

---

## 5. Size

| Source section | Target page |
| ---------------- | ------------- |
| Short (under 3,000 words) | 250 to 400 words, 1 to 2 tables |
| Medium (3,000 to 8,000 words) | 500 to 900 words, 3 to 5 tables |
| Long (over 8,000 words) | 900 to 1,400 words, 5 to 8 tables, use toggles |

A page that needs more than this usually contains copied detail. Move detail into toggles or cut it.

---

## 6. Anti-patterns

| Anti-pattern | Why it fails | Do instead |
| -------------- | -------------- | ----------- |
| Retelling the section as prose | Not scannable, close to the original wording | Lists and tables |
| Headings copied one to one with a sentence each | Shallow, misses the content | Extract the enumerations and comparisons |
| Dropping items from an author's list | Reader cannot trust the summary | Show all items |
| Copying code listings | Copyright, noise | Minimal pattern, describe the rest |
| Bold everywhere | Nothing stands out | One highlight per bullet |
| Numbers without scope | Misleading | Say where the number comes from |
| Filling gaps from general knowledge | Summary no longer reflects the source | Only what the section says |

---

## 7. Checklist

- [ ] Thesis visible in the intro callout and takeaways
- [ ] Every enumeration of the source is complete
- [ ] Comparisons are tables, procedures are numbered
- [ ] At most a few short prose paragraphs
- [ ] Numbers exact and scoped
- [ ] Own words, no long quotes, no full code listings
- [ ] Recap at the bottom
- [ ] Working note for the flashcard page written
