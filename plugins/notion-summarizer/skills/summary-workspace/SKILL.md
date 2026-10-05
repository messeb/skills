---
description: Setting up the Notion structure for a summary — finding the target database or parent page, reading the schema before writing, creating the detail page with every fillable property, cover and icon, the two-column layout with cover image and notes, one subpage per section with titles that carry no chapter number, keeping subpages in source order, and which properties belong to the user and must be left alone.
---

<!-- markdownlint-disable MD010 -- hard tabs are required: Notion nests child blocks by tab indentation -->

# Summary workspace

Goal of this skill: create the container for a summary in Notion so that it fits the user's existing database and conventions, with all metadata filled and nothing of the user's overwritten.

Use this skill at the start of a summary job and again at the end to complete the summary property and the notes. Do not use it for styling page content; that is `notion-page-styling`.

---

## 1. Target structure

```text
<Database or parent page>
└── <Source title>                      detail page: properties, cover, icon, notes
    ├── <Section title>                 one subpage per section, no number in the title
    ├── <Section title>
    ├── ...
    └── Flashcards: <Source title>      learning page (flashcard-page skill)
```

---

## 2. Inspect before you write

1. Fetch the target the user named. If it is a database, the result lists one or more data sources (`collection://...`). Use the data source id as parent, not the database id.
2. Read the schema: exact property names, types, select options, relation targets.
3. Query two or three existing entries to learn the conventions: how authors are separated, how editions are written, whether an icon or cover is used, how the page body is laid out.
4. If the user asked for "the same as" an earlier page, fetch that page and mirror its layout.

Never invent property names or select options. If a needed option does not exist, leave the property empty and tell the user.

---

## 3. Fill the properties

Map the metadata from `source-capture` to the schema. Typical mapping for a book database:

| Property type | Fill with | Notes |
| --------------- | ----------- | ------- |
| Title | Source title without subtitle noise | Exactly as published |
| Author / creator | Names, separated as existing entries do it | |
| Year | Publication year as a number | |
| Pages / length | Number | Numbers as numbers, not strings |
| Edition / version | Text such as `2nd Edition` or `Early Release` | |
| Genre / topic (relation or select) | An **existing** entry | Relations need the page URL of the related entry |
| Description | One or two factual sentences: what it is, publisher, level | |
| Summary | Three to five sentences on the core argument | Write this **last**, after all sections are read |

Leave these to the user unless they ask: status, rating, progress, current page, completed date, file attachments, formats owned. If the database needs a status to show the entry in a view, set the initial one (for example `To Read`) and say so.

Type rules that often break writes:

- Dates are split into `date:<Property>:start` and related keys.
- Checkboxes use `__YES__` and `__NO__`.
- Properties named `id` or `url` need the `userDefined:` prefix.

---

## 4. Cover and icon

- **Cover**: pass an external image URL. Prefer a publicly reachable URL (publisher site, open catalogue). An image behind a login may not render in Notion; if that is the only one available, use it and tell the user it may need a manual upload.
- **Icon**: use Notion's native icons in the form `/icons/<name>_<color>.svg`, for example `/icons/book-closed_gray.svg`. The leading slash and `.svg` are required, otherwise the icon is stored as a broken external link.
- Known good icon names: `book`, `book-closed`, `library`, `list`, `compass`, `puzzle`, `search`, `people`, `gavel`, `chat`, `gear`, `git`, `layout`, `chart`, `database`, `layers`, `briefcase`, `rocket`, `science`, `shield`, `light-bulb`, `info-alternate`, `warning`, `checkmark`, `question-mark`, `pin`, `refresh`, `close`, `arrow-down`.
- Colors: `gray`, `brown`, `orange`, `yellow`, `green`, `blue`, `purple`, `pink`, `red`.
- If the API rejects an icon name, nothing was written. Retry the whole call with a known good name.

---

## 5. Detail page body

Keep the body short; the content lives in the subpages.

```text
<columns>
	<column>
		![<Source title>](<cover url>)
	</column>
	<column>
		### Notes
		---
		- **Author:** ...
		- **Core idea:** one or two sentences
		- **Part 1:** what these sections cover
		- **Part 2:** ...
		- Section summaries and the flashcard page are the subpages below
	</column>
</columns>
```

Children of `<columns>` and `<column>` are indented with one tab per level.

When you update the body later, use a targeted search-and-replace update. A full replace can delete the subpages; if the tool warns about child pages being deleted, stop and switch to a targeted update.

---

## 6. Subpages

- Parent is the detail page id.
- **Title = section title only.** Remove prefixes such as `Chapter 7.`, `Ch 07:`, `7 -`, `Part II`. The number goes into the first callout on the page instead.
- Create subpages in source order, one call per section, synchronously, so the order on the parent page matches the source.
- Give every subpage an icon that fits its topic. Use one color per part of the source (for example blue, green, purple, orange) so the parts are visible in the page list.
- Store the returned page id in the working notes.

Renaming existing pages: update only the `title` property. Do not recreate pages to rename them.

---

## 7. Anti-patterns

| Anti-pattern | Why it fails | Do instead |
| -------------- | -------------- | ----------- |
| Creating the page under the database id | Fails with several data sources | Use the data source id |
| Guessing property names | Write is rejected or lands nowhere | Fetch the schema first |
| Setting rating, status or progress for the user | Overwrites personal data | Leave them, mention it |
| Chapter numbers in titles | Clutters the page list, user asked to avoid it | Number in the intro callout |
| `icons/book_gray` as icon value | Stored as broken external URL | `/icons/book_gray.svg` |
| Full content replace on the parent | Can delete all subpages | Targeted update |
| Writing the summary property first | It describes what you have not read yet | Write it last |

---

## 8. Checklist

- [ ] Schema fetched, conventions checked on existing entries
- [ ] Detail page created under the data source
- [ ] All factual properties filled, personal properties untouched
- [ ] Cover set, render caveat mentioned if the image is not public
- [ ] Native icon set on the detail page and every subpage
- [ ] Subpage titles without numbers, in source order
- [ ] Notes column and summary property completed at the end
