---
description: Selects and claims exactly one ticket for the coder agent. Lists Todo tickets, excludes needs-human and no-bot, applies the dependency rule, requires acceptance criteria, claims the first eligible ticket by setting it In Progress and assigning the bot user, and verifies the claim held. Use at the start of a coder run that was not started with a REWORK payload.
---

# Pick a ticket

One coder, one ticket, one claim that is verified. The lock is the combination of status In Progress plus assignment to `BOT_USER`.

## Method

1. `list_candidates` with status Todo and excluded labels `needs-human`, `no-bot` (via `agentic-coding:ticket-tracker`). Order: priority descending, then oldest first.
2. Walk the list. For each candidate:
   - `resolve_dependencies`. Eligible only if every dependency is in Ready for Release or Done. A dependency in any other status, or a dependency the tracker cannot resolve, makes the ticket ineligible; move on without commenting.
   - `get_ticket`. Eligible only if it has at least one acceptance criterion. If it has none and `PLANNER_ENABLED = true`: `transition` it to `INTAKE_STATUS` with the comment "Moved to intake: no acceptance criteria, planner will write intent and spec"; otherwise `comment` "Skipped by coder: no acceptance criteria" and `add_label needs-human`. Move on either way.
   - A ticket whose title or labels mark it as spike, research or discussion is ineligible; it has no code deliverable.
3. `claim` the first eligible ticket. Then `get_ticket` again: if status is not In Progress or assignee is not `BOT_USER`, someone else was faster; unclaim nothing, continue with the next candidate.
4. `comment` on the claimed ticket: "[agentic-coding/coder] Started. Branch: `<prefix>/<id>-<slug>`."
5. If the list is exhausted, end the run with the line "Coder: no eligible ticket" and the count of candidates seen, blocked, and skipped.

## Slug rule

Lowercase, ASCII, words joined by `-`, max 40 characters, from the ticket title with stop words removed. Example: "Add rate limiter to booking API" → `add-rate-limiter-booking-api`.

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
| -------------- | -------------- | --------- |
| Claiming two tickets "to be efficient" | Second one blocks a human for hours | One per run, always |
| Picking a blocked ticket because the blocker "looks done" | Merged is not released; the dependency rule exists for a reason | Only Ready for Release or Done counts |
| Commenting on every skipped ticket | Notification noise | Comment only when adding `needs-human` |

## Checklist

- [ ] Excluded labels honored
- [ ] Dependency rule applied with structured links only
- [ ] Acceptance criteria present
- [ ] Claim verified by a second read
- [ ] Start comment posted with the branch name
