---
description: Re-verifies every acceptance criterion against the finished branch with recorded evidence, runs the full quality gates, and only then ticks the criteria on the ticket. Never ticks from memory. Use after implement-ticket and before pull-request; the reviewer uses the same evidence format to re-check.
---

# Verify acceptance criteria

A ticked checkbox is a claim the reviewer will test. This skill makes the claim true before it is made.

## Method

1. Run the full gates in a clean state: `git status --porcelain` must be empty, then `BUILD_CMD`, `LINT_CMD`, `TEST_CMD`. Any failure returns you to `agentic-coding:implement-ticket`.
2. For every acceptance criterion, in ticket order, execute the verification mapped in the plan comment against the current branch, not from memory:
   - **Automated**: run the named test in isolation and record its name and result.
   - **Command**: run it and record the exact command and the relevant output lines.
   - **Manual**: perform the check with the tools available (start the app, call the endpoint, render the view) and record what you observed. If it cannot be performed unattended, the criterion is not verifiable by you.
3. Write the evidence table (below). One row per criterion.
4. `tick_criterion` only for rows with a passing result (via `agentic-coding:ticket-tracker`). Rows without a pass stay unticked.
5. `comment` on the ticket with the evidence table and the header `[agentic-coding/coder] Verification`.
6. If a criterion cannot be met: comment what blocks it, `add_label needs-human`, leave status In Progress, end the run. Do not open a PR for a partially met ticket.

## Evidence table

```text
| Criterion | Verification | Result | Evidence |
|-----------|--------------|--------|----------|
| <text> | test: <name> | pass | <runner line> |
| <text> | cmd: <command> | pass | <output excerpt> |
| <text> | manual: <check> | not verifiable unattended | <why> |
```

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
|--------------|--------------|---------|
| Ticking because "the test suite is green" | The suite may not cover the criterion | One named verification per criterion |
| Ticking a criterion verified earlier, before the last commit | Later commits can regress it | Verify the final branch |
| Opening the PR with unticked criteria and a note | Shifts the ticket's work to the reviewer | Fix or stop |

## Checklist

- [ ] Clean tree, all gates green
- [ ] Every criterion verified against the final branch
- [ ] Evidence table posted on the ticket
- [ ] Only verified criteria ticked
