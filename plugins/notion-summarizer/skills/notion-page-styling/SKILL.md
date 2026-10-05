---
description: Rendering summary content with native Notion blocks through the Notion MCP's enhanced Markdown — full-width tables with header row and column, colored headings, callouts with native icons, table of contents, toggles and toggle headings, columns, dividers, code and equation blocks, the tab-indentation rule for nested blocks, escaping, a copy-ready page template, and how to restyle existing pages without losing content.
---

<!-- markdownlint-disable MD010 -- hard tabs are required: Notion nests child blocks by tab indentation -->

# Notion page styling

Goal of this skill: make a summary page easy to scan by using Notion's native blocks instead of plain Markdown, and avoid the syntax mistakes that make blocks render as raw text.

Use this skill whenever you create or restyle a page through the Notion MCP. Before the first write in a session, fetch the resource `notion://docs/enhanced-markdown-spec` once; it is the authority if anything here differs.

---

## 1. The two rules that prevent most failures

1. **Children are indented with one tab per nesting level.** Everything inside a callout, toggle, column or toggle heading is a child. Spaces do not work. Content at the wrong level silently ends up outside the block.
2. **Do not repeat the page title in the content.** The title is a property.

---

## 2. Block reference

### Tables: always full width

```text
<table fit-page-width="true" header-row="true" header-column="true">
<tr color="gray_bg"><td>Option</td><td>Pros</td><td>Cons</td></tr>
<tr><td>A</td><td color="green_bg">Readable</td><td>Needs the class</td></tr>
<tr><td>B</td><td>Portable</td><td color="red_bg">Opaque</td></tr>
</table>
```

- `fit-page-width="true"` makes the table span the page. Set it on **every** table. Pipe tables cannot do this, so do not use pipe tables.
- `header-row="true"` always. `header-column="true"` when the first column names the row.
- Gray background on the header row. Use cell colors sparingly to mark good (`green_bg`), bad (`red_bg`) or group membership.
- Cells take inline formatting only: bold, inline code, links. No lists or blocks inside cells.
- One `<tr>` per line keeps the content readable and diffable.

### Callouts

```text
<callout icon="icons/light-bulb_yellow" color="yellow_bg">
	**Key takeaways**
	- First point
	- Second point
</callout>
```

| Purpose | Icon | Color |
| --------- | ------ | ------- |
| Section intro / context | `icons/info-alternate_<part color>` | `<part color>_bg` |
| Key takeaways | `icons/light-bulb_yellow` | `yellow_bg` |
| Tip, do this | `icons/checkmark_green` | `green_bg` |
| Rule of thumb, decision aid | `icons/compass_blue` | `blue_bg` |
| Caveat | `icons/warning_orange` | `orange_bg` |
| Danger, do not | `icons/warning_red` or `icons/close_red` | `red_bg` |
| Definition, concept | `icons/science_purple` | `purple_bg` |
| Side note | `icons/search_gray` or `icons/puzzle_gray` | `gray_bg` |
| Recap | `icons/pin_<part color>` | `<part color>_bg` |

Inside content, callout icons are written `icons/<name>_<color>` without slash and extension. For the **page** icon the form is `/icons/<name>_<color>.svg` (see `summary-workspace`). An unknown icon name rejects the whole write; retry with a name from the known list.

### Headings, navigation, dividers

```text
<table_of_contents color="gray"/>

## Section heading {color="blue"}

---
```

- One heading color per part of the source, the same color as the page icon.
- H2 for sections, H3 for subsections. No H1.

### Toggles

```text
<details>
<summary>Optimizer options</summary>

	Children, indented with one tab.
</details>

### Skill discovery {toggle="true"}
	- Children of a toggle heading, indented with one tab.
```

Use toggles for secondary detail and long reference lists. Tables, callouts and code blocks may be nested inside. Do not hide the main content in toggles.

### Columns

```text
<columns>
	<column>
		### Async
		- point
	</column>
	<column>
		### Streaming
		- point
	</column>
</columns>
```

Use for exactly two or three parallel items. Two callouts side by side make a strong contrast.

### Code and equations

````text
```python
program.save("optimized.json")
```

$$
budget = evals \times (train + val)
$$
````

- Always give the code block a language. Use `text` or `plain text` for flashcard blocks.
- Lines inside a code block are literal. Inside a nested code block only the fence needs the tab indentation.

### Escaping

- Escape a literal dollar sign as `\$` outside code, otherwise two of them on a line turn into an inline equation.
- Angle brackets in text that are not tags go into inline code.

---

## 3. Page template

```text
<callout icon="icons/info-alternate_blue" color="blue_bg">
	**Chapter 3** · One sentence on what this section covers and why it matters.
</callout>

<table_of_contents color="gray"/>

<callout icon="icons/light-bulb_yellow" color="yellow_bg">
	**Key takeaways**
	- ...
</callout>

---

## First topic {color="blue"}

- bullet
- bullet

<table fit-page-width="true" header-row="true" header-column="true">
<tr color="gray_bg"><td>Item</td><td>What</td><td>When</td></tr>
<tr><td>...</td><td>...</td><td>...</td></tr>
</table>

<callout icon="icons/warning_orange" color="orange_bg">
	Caveat in one or two sentences.
</callout>

## Second topic {color="blue"}

...

---

<callout icon="icons/pin_blue" color="blue_bg">
	**Recap**
	1. ...
	2. ...
</callout>
```

Density guide per page: one intro callout, one takeaways callout, one recap, and at most one further callout per H2. If everything is highlighted, nothing is.

---

## 4. Restyling existing pages

1. Fetch the page and keep its content as the source of truth.
2. Rebuild it in the template: convert pipe tables to full-width XML tables, wrap the summary bullets in the takeaways callout, turn "Note:" and "Warning:" paragraphs into callouts, move long detail into toggles, color the headings.
3. Write with a full content replace **only** if the page has no child pages or databases. Otherwise use targeted updates.
4. Do not change wording while restyling unless asked.
5. Fetch the page again and compare: same number of tables and headings, no raw tags visible as text.

Restyle one page first, verify it, then apply the pattern to the rest.

---

## 5. Anti-patterns

| Anti-pattern | Symptom | Fix |
| -------------- | --------- | ----- |
| Pipe tables | Narrow table, no full width | XML table with `fit-page-width="true"` |
| Spaces for nesting | Children appear below the callout, not inside | One tab per level |
| Lists inside table cells | Raw Markdown in the cell | Split into rows or use a toggle below |
| Callout around every paragraph | Visual noise | One per H2 at most |
| Unknown icon name | Whole write rejected | Use the known list |
| Unescaped `$` | Text turns into an equation | `\$` |
| Title repeated as H1 | Double title | Remove it |
| Full replace on a page with subpages | Subpages deleted | Targeted update |

---

## 6. Checklist

- [ ] Spec resource fetched once in this session
- [ ] Every table has `fit-page-width="true"` and a header row
- [ ] Nested content indented with tabs
- [ ] Intro callout, table of contents, takeaways, dividers, recap present
- [ ] Heading and icon colors match the part of the source
- [ ] Dollar signs escaped, code blocks have a language
- [ ] Page fetched after writing, no raw tags in the rendered text
