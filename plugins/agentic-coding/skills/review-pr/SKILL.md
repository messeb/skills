---
description: Review procedure for bot pull requests in the agentic-coding loop. Runs the review passes from the repo's REVIEW.md (default: bugs, security, compliance against spec.md, plan.md and the acceptance criteria) after reproducing the quality gates and independently verifying every ticked criterion, classifies findings as BLOCKER / SHOULD / NIT, decides between Changes Requested and merge, and feeds repeated mistakes back into CLAUDE.md. Use in every reviewer run.
---

# Review a pull request

The reviewer protects the default branch. The coder's checkboxes, evidence tables and "tests pass" claims are input, not proof. Separation of duties is absolute: the reviewer never writes to the PR branch, the coder never merges.

## Review policy source

1. `REVIEW.md` in the repo root, when present, defines the passes, what counts as Important, the nit cap and what to skip. It wins over everything below.
2. Otherwise use the default passes below, plus the best-practice skills selected by `agentic-coding:workflow-config` as review lenses (a security skill for the security pass, a testing skill for the test findings, stack skills for conventions).

## Step 1: Intent

Read the ticket, its acceptance criteria, `intent.md` and `spec.md` when they exist for this ticket (see `agentic-coding:sdlc-artifacts`), `plan.md` on the branch, and the PR body. Answer in one line each: what the change is supposed to do, what it must not change, and whether the PR body claims exactly that. Scope creep is a finding.

## Step 2: Reproduce

In the local repo: `git fetch`, check out the PR branch, run `BUILD_CMD`, `LINT_CMD`, `TEST_CMD` in a clean tree. A red gate is an automatic Changes Requested; stop reviewing details and report the gate.

## Step 3: Verify the claims

For every ticked acceptance criterion, run the verification the coder cited (test name or command) yourself. Then check the plan: does the diff touch the files `plan.md` names, in the order it describes, with the proof it promised? A ticked criterion that does not hold, or a diff that departed from `plan.md` without `plan.md` being updated in the same commit, is an automatic Changes Requested.

Bug fixes: confirm a failing test was committed before the fix (git history), and that no test file was weakened, deleted or marked skipped in the diff. A test edited in the same commit as the fix it proves is a BLOCKER.

## Step 4: Passes

Read the full diff (`git diff DEFAULT_BRANCH...HEAD`) file by file, once per pass, tagging each finding with its pass:

| Pass | Looks for |
|------|-----------|
| Bugs | logic errors, unhandled error paths, race conditions, off-by-one, null and optional handling, broken edge cases, subtle regressions |
| Security | injection, secrets in the diff, unsafe deserialization, missing authorization, PII in logs or error messages |
| Compliance | the change matches `spec.md`, `plan.md`, the acceptance criteria, the repo's conventions in `CLAUDE.md` / `AGENTS.md`, and the selected design-principle skills |
| Tests | missing tests for new behavior, tests that cannot fail, tests that mirror the implementation, missing regression test for a bug fix |

Skip generated paths, vendored code and anything the linter or CI already enforces. Do not report style the linter does not enforce.

## Step 5: Classify

| Class | Meaning |
|-------|---------|
| BLOCKER | would break behavior, leak data, breach a policy, or the claim it supports is false |
| SHOULD | fix unless there is a stated reason: missing edge case, weak test, convention deviation |
| NIT | naming, readability, dead code; optional; at most five per review, the rest as a count |

## Step 6: Decide

**Changes Requested** when there is at least one BLOCKER or more than `MAX_SHOULD_FINDINGS` SHOULDs:

1. Inline comments on the exact lines: what is wrong, why it matters, a concrete suggestion, prefixed `[BLOCKER]`, `[SHOULD]` or `[NIT]`, plus the pass name and the skill or repo rule it cites when one applies.
2. Submit "Request changes" with the blocker list.
3. `transition` the ticket to Changes Requested, `comment` the review link and blockers.
4. `rework_rounds` for this PR: if it has reached `MAX_REWORK_ROUNDS`, `add_label needs-human`, comment "Escalated: rework limit reached", end. Otherwise hand off to the coder per `HANDOFF` with `REWORK <ticket-id> <pr-url>`.

**Approve** otherwise:

1. NITs as non-blocking comments.
2. Submit "Approve" stating exactly what you reproduced and verified.
3. Wait for required checks up to `CI_WAIT_MINUTES`, polling every 2 minutes. No conflicts, all required checks green, otherwise Changes Requested with the reason.
4. Merge with `MERGE_STRATEGY`, PR title as the merge title, delete the remote branch.
5. `transition` the ticket to Ready for Release, `comment` "Merged <sha> via <pr-url>", and record the SHA in the ticket per the linkage rule.
6. Locally `git checkout DEFAULT_BRANCH && git pull --ff-only`, delete the local branch.

## Step 7: Feed the knowledge back

A mistake the review catches for the second time in this repo (search previous bot reviews for the same finding text) belongs in `CLAUDE.md`, not in another comment. Because the reviewer never pushes to the PR, it opens a separate one-line PR against `CLAUDE.md` titled `docs: CLAUDE.md, <correction>` with the `agent-workflow: v1` marker for a human to merge, and links it from the review. Likewise flag when the change made `CLAUDE.md` or `AGENTS.md` outdated.

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
|--------------|--------------|---------|
| Trusting the evidence table | It was written by the party being reviewed | Re-run every cited verification |
| Fixing the one-character typo yourself | Breaks separation of duties and the audit trail | Comment, hand back |
| Merging on "CI is probably fine" | Red main blocks every other run | Wait or request changes |
| Twenty nits, no blockers, Changes Requested | Rework rounds burned on style | Cap nits, approve with comments |
| Same finding on every PR | Nobody wrote it down | CLAUDE.md follow-up PR |

## Checklist

- [ ] REVIEW.md or default passes applied, skills used as lenses
- [ ] Gates reproduced locally in a clean tree
- [ ] Every ticked criterion re-verified, plan.md matched
- [ ] Findings classified and tagged with pass and source
- [ ] Decision follows the thresholds, rework limit checked
- [ ] Ticket status, comment, SHA and hand-off done
- [ ] Repeated mistakes routed to CLAUDE.md
