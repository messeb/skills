---
description: Tracker adapter for the agentic-coding loop. One set of operations (list candidates, resolve dependencies, claim, transition, comment, assign, tick acceptance criteria, find the PR link) with the concrete implementation for Jira, GitHub Issues and Notion. Use whenever an agent reads or changes ticket state; never call a tracker API without going through these operations.
---

# Ticket tracker adapter

The agents speak in operations; this skill maps each operation to the tracker configured in `TRACKER`. Read the section for your tracker only. Every write operation re-reads the ticket afterwards and confirms the change took effect; a silent failure is treated as a stop condition.

## Operations

| Operation | Input | Output |
| ----------- | ------- | -------- |
| `list_candidates` | status, excluded labels | tickets sorted by priority desc, created asc |
| `get_ticket` | id | title, description, acceptance criteria, labels, assignee, status, comments, links |
| `resolve_dependencies` | id | list of (dependency id, status) |
| `claim` | id | sets In Progress, assigns `BOT_USER`, verifies |
| `transition` | id, target status | verifies status afterwards |
| `comment` | id, markdown | comment id |
| `add_label` / `remove_label` | id, label | verified |
| `tick_criterion` | id, criterion text | checkbox checked, verified |
| `pr_link` | id | PR URL from ticket comments, links or remote links |
| `rework_rounds` | pr url | number of "Request changes" reviews by `BOT_USER` |

Acceptance criteria are recognized in this order: a section titled "Acceptance Criteria" (any case, also "AC", "Akzeptanzkriterien") containing checkboxes or bullets; otherwise any checkbox list in the description; otherwise none. A ticket with none is skipped by the coder and labeled `needs-human`.

## Jira

Use the Atlassian MCP tools when available (`searchJiraIssuesUsingJql`, `getJiraIssue`, `getTransitionsForJiraIssue`, `transitionJiraIssue`, `editJiraIssue`, `addCommentToJiraIssue`, `getJiraIssueRemoteIssueLinks`); otherwise the Jira REST API with the token from the environment.

| Operation | Implementation |
| ----------- | ---------------- |
| `list_candidates` | JQL `project = PROJECT AND status = "Todo" AND labels not in (needs-human, no-bot) ORDER BY priority DESC, created ASC` |
| `resolve_dependencies` | `issuelinks` where `inwardIssue` exists and link type is "Blocks" (the ticket "is blocked by"); plus `parent` if its status is Todo |
| `claim` | `transition` to In Progress, `editJiraIssue` assignee = `BOT_USER` |
| `transition` | `getTransitionsForJiraIssue`, pick the transition whose target name matches, `transitionJiraIssue` |
| `tick_criterion` | description checkboxes in the wiki/ADF text: replace `[ ]` with `[x]` on the matching line via `editJiraIssue`; if the project uses a checklist app field, update that field |
| `pr_link` | remote issue links, then the newest comment containing a PR URL |

## GitHub Issues

Use `gh` (`gh issue list`, `gh issue view --json`, `gh issue edit`, `gh issue comment`, `gh api`). Status lives either in a Projects v2 field named `Status` or in labels `status:<name>`; `WORKFLOW.md` says which. Prefer the Projects field when both exist.

| Operation | Implementation |
| ----------- | ---------------- |
| `list_candidates` | `gh issue list --state open --json number,title,labels,createdAt,body` filtered by status; priority from labels `priority:high/medium/low`, default medium |
| `resolve_dependencies` | body lines matching `Blocked by #N`, `Depends on #N`, `Blocked by owner/repo#N`, and task-list items `- [ ] #N`; each referenced issue's status via the same status source |
| `claim` | transition + `gh issue edit --add-assignee BOT_USER` |
| `transition` | Projects v2: `gh api graphql` `updateProjectV2ItemFieldValue` with the single-select option id; labels: `gh issue edit --remove-label status:<old> --add-label status:<new>` |
| `tick_criterion` | `gh issue edit --body` with the matching `- [ ]` line changed to `- [x]`; edit only that line |
| `pr_link` | `gh api repos/{owner}/{repo}/issues/{n}/timeline` cross-referenced PRs, then comments containing a PR URL |
| `rework_rounds` | `gh pr view --json reviews` count of `CHANGES_REQUESTED` by `BOT_USER` |

## Notion

Use the Notion MCP tools (`notion-query-data-sources`, `notion-fetch`, `notion-update-page`, `notion-create-comment`, `notion-get-comments`). `PROJECT` is the database (data source) id.

| Operation | Implementation |
| ----------- | ---------------- |
| `list_candidates` | query the data source with filter `Status = Todo` and `Labels` not containing the excluded values; sort by `Priority` desc, `Created time` asc |
| `resolve_dependencies` | relation property `Blocked by`; fetch each related page's `Status` |
| `claim` | update `Status` to In Progress and `Assignee` (people property) to `BOT_USER` |
| `transition` | update the `Status` property; the option must exist, never create options |
| `tick_criterion` | fetch page content, find the to-do block whose text matches the criterion, update its `checked` state; if criteria are checkbox properties, update the property |
| `pr_link` | a URL property named `PR` if present, otherwise the newest comment containing a PR URL |

## Comment format

Every agent comment starts with a header line so humans can filter them:

```text
[agentic-coding/<agent>] <one-line action>
<details, links, evidence>
```

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
| -------------- | -------------- | --------- |
| Transition without re-reading | Race with a human or another run goes unnoticed | Verify every write |
| Creating a missing status option | Tracker schema drifts per bot run | Missing status is a stop condition |
| Rewriting the whole description to tick one box | Destroys human edits | Change only the matching line or block |
| Treating a comment "blocked by X" as a dependency | Prose is not a link | Only the structured sources above count |

## Checklist

- [ ] Only the configured tracker's section was used
- [ ] Every write was verified by a read
- [ ] Comments carry the `[agentic-coding/<agent>]` header
- [ ] No status or label was created, only existing ones used
