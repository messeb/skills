---
description: The janitor's checks for the agentic-coding loop. Detects and repairs stale In Progress claims, tickets whose PR was closed unmerged, stuck reviews, stuck rework, merged-but-not-released tickets and missing artifact linkage, each with the evidence required before acting. Use in every janitor run, or by hand when the loop looks stuck.
---

# Workflow hygiene

An unattended loop drifts: sessions die, triggers get lost, humans move tickets by hand. These checks restore the invariant that ticket status, PR state and branches agree. Every check names the evidence it needs; without that evidence, do nothing and let tomorrow's run look again.

## Checks, in order

| # | Condition | Evidence required | Action |
|---|-----------|-------------------|--------|
| 1 | In Progress, assignee `BOT_USER`, older than `STALE_CLAIM_HOURS` | no ticket comment by the bot and no commit on the ticket branch inside the window | comment "Stale claim released", unassign, `transition` Todo, keep the branch |
| 2 | Ready for Review or In Review, PR closed without merge | `gh pr view` state CLOSED, `mergedAt` null | comment why, `transition` Todo |
| 3 | In Review longer than `STALE_REVIEW_HOURS` | no review submitted on the PR inside the window | `transition` Ready for Review, hand off `REVIEW <id> <pr>` per `HANDOFF` |
| 4 | Changes Requested longer than `STALE_CLAIM_HOURS` | no new commit on the PR inside the window | hand off `REWORK <id> <pr>` per `HANDOFF` (if rounds < `MAX_REWORK_ROUNDS`, else `needs-human`) |
| 5 | In Review or Ready for Review, PR merged | `mergedAt` set | `transition` Ready for Release, comment the merge SHA |
| 6 | Ready for Release without a merge SHA in the ticket | PR merged, ticket lacks the SHA | add the SHA comment (linkage rule from `agentic-coding:sdlc-artifacts`) |
| 7 | Bot branch with no open PR and no ticket in In Progress or Changes Requested, older than 7 days | `git branch -r --merged` or no PR references it | list it in the report; never delete branches |

Tickets labeled `needs-human` or `no-bot` are skipped by every check.

## Weekly report

On the first run of the week additionally run `agentic-coding:loop-metrics` and post the numbers as a comment on the tracker's workflow ticket (`METRICS_TICKET` in `WORKFLOW.md`) or, when none is configured, in the run summary only.

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
|--------------|--------------|---------|
| Releasing a claim because it "looks old" | The coder may be mid-run on a long test suite | Require both no comment and no commit |
| Deleting stale branches | Destroys evidence and possibly unpushed work | Report only |
| Re-firing a hand-off every run | Duplicate sessions on the same PR | Only when the stale window has passed |
| Fixing a merge conflict "while here" | The janitor does not write code | Label `needs-human` |

## Checklist

- [ ] Checks run in order, each with its evidence
- [ ] `needs-human` and `no-bot` untouched
- [ ] One comment per corrected ticket with evidence
- [ ] Action table in the run summary
