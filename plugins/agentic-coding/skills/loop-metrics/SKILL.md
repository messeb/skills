---
description: Measures whether the agentic-coding loop works, from git and PR history only: time to first review, rework rounds per PR, first-pass merge share, plan.md match rate, review comments resolved without a human touching the branch, intent-to-spec and spec-to-merge lead times, and escalations to needs-human. Use for the janitor's weekly report or when tuning WORKFLOW.md limits.
---

# Loop metrics

Every number comes from `git` and `gh` (or the tracker API); the model only aggregates and interprets. Report patterns and process recommendations, never rankings of people.

## Indicators

| Indicator | Source | Direction |
| ----------- | -------- | ----------- |
| Time from Todo to PR opened | ticket transitions, PR `createdAt` | down |
| Time to first review | PR `createdAt` to first bot review | minutes |
| Rework rounds per PR | `CHANGES_REQUESTED` reviews by `BOT_USER` per PR | down, then stable |
| First-pass merge share | PRs merged with zero rework rounds / all bot PRs | up |
| plan.md match rate | merged diffs whose files equal `plan.md` "Files that change" | up |
| Review comments resolved without a human commit | resolved threads where every commit after the review is by the bot | up |
| Escalations | tickets that received `needs-human`, by reason text | down |
| intent → spec, spec → merge lead time | commit timestamps of the artifacts | down |
| Spec rework after build start | `spec.md` commits dated after the first `plan.md` commit | down |
| CLAUDE.md corrections | PRs titled `docs: CLAUDE.md` per month | rising then falling |
| Incidents without eval | `lessons/*.md` without a matching `evals/*.json` | zero |

## Method

1. Window: last 7 days for the weekly report, last 90 for tuning.
2. Collect bot PRs: `gh pr list --search "agent-workflow: v1 in:body" --state all --json number,createdAt,mergedAt,reviews,commits,body`.
3. Join with ticket transitions from the tracker (`ticket-tracker` `get_ticket` history) by the `Closes <ref>` line.
4. Compute the table with `jq`; write `metrics.json` and the markdown table.
5. Interpret: a rising rework rate with stable first-review time points at the coder's guidance (CLAUDE.md, skills); a falling plan match rate points at plans written too early or specs changing after build; escalations by reason say which stop condition dominates.

## Tuning WORKFLOW.md

- Rework rounds consistently 1 with few escalations: consider lowering `MAX_SHOULD_FINDINGS` (stricter reviews cost nothing).
- Frequent "rework limit reached": raise `MAX_REWORK_ROUNDS` only if the rework is converging; otherwise the specs are the problem.
- Stale claims every week: the coder runs are too long for the schedule; shorten tickets or raise `STALE_CLAIM_HOURS`.

## Checklist

- [ ] Numbers from git, gh and the tracker only
- [ ] Window stated
- [ ] Recommendations cite the indicator behind them
- [ ] No per-person rankings
