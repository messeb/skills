---
description: Implements a claimed ticket in the local repository the way the repo and the matching best-practice skills prescribe. Covers reading the ticket and review comments, branch setup, code exploration, a plan.md negotiated as a contract with a fresh-context reviewer before any code, the driver/navigator loop with one commit per acceptance criterion, test-first bug fixes with frozen test files, the handoff.md for long runs, and a verifier subagent at the end. Use after pick-ticket, or with a REWORK or CONTINUE payload.
---

# Implement a ticket

The coder brings no style of its own. It writes code the way the repository says (`AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`), and where the repository is silent, the way the best-practice skills selected by `agentic-coding:workflow-config` say. Nothing is implemented without an accepted plan.

## Step 1: Understand

1. `get_ticket`: description, acceptance criteria, comments, linked tickets, attachments, and `SDLC_DIR/<ticket-id>/intent.md` and `spec.md` when they exist (`agentic-coding:sdlc-artifacts`). On rework additionally read every review comment on the PR; each unresolved one is a requirement with the same weight as an acceptance criterion. On `CONTINUE`, read `handoff.md` first and resume from its "Next steps".
2. Restate the ticket in three lines: what changes for the user, what must not change, how you will know it works. If the third line cannot be written, the criteria are not verifiable; that is a stop condition.

## Step 2: Branch

```bash
git -C "$REPO_PATH" fetch --prune
git -C "$REPO_PATH" checkout "$DEFAULT_BRANCH" && git -C "$REPO_PATH" pull --ff-only
git -C "$REPO_PATH" checkout -b "$BRANCH_PREFIX/<id>-<slug>"
```

Bug tickets use the prefix `fix`. On rework or continue: check out the existing branch and `git pull --ff-only`. Rebasing or amending is forbidden on a branch with an open PR; conflicts with the default branch are resolved by merging it in with a merge commit.

## Step 3: Explore

1. Find the code the ticket touches: search by domain terms, follow the call graph one level each way.
2. Find the tests covering that code and the test conventions (framework, placement, naming, fixtures).
3. Find two existing examples of the kind of change you are about to make and match their structure.
4. Read the best-practice skills selected in configuration for exactly the files you will touch. Note each rule you will apply; you will cite them in the PR.

## Step 4: Plan as a contract

Write `SDLC_DIR/<ticket-id>/plan.md` from the template: files that change, order of work, risks (what could break, the riskiest step, options rejected), and proof: one named test, command or observable check per acceptance criterion. The proof section is the contract: it defines what "done" means for this ticket before any code exists.

Negotiate it: spawn a contract-reviewer subagent with fresh context (`agentic-coding:evaluator-qa`), giving it only the ticket, `spec.md` if present, `plan.md` and the repo's instruction files. Ask whether the plan builds the right thing, whether every criterion has a verification that can fail, and what the plan would break. Iterate until it has no BLOCKER; at most three rounds, then a remaining BLOCKER is a stop condition. Commit the agreed `plan.md` as the first commit on the branch and report its SHA on the ticket. When the ticket is classed `higher-risk` in `spec.md`, do not proceed past this commit: `comment` "Plan ready for tech-lead acceptance", `add_label needs-human`, end the run.

The plan owns deliverables and verification, not implementation detail; when the implementation departs from it, update `plan.md` in the same commit.

## Step 5: Pair-programming loop

One acceptance criterion at a time, as a driver/navigator pair with yourself:

1. **Driver**: the test for the criterion first when the codebase has tests, then the smallest implementation that satisfies it, in the repo's style.
2. **Gates**: `LINT_CMD` and `TEST_CMD`. Red means fix the code; never skip, delete, weaken or mark a test as expected failure.
3. **Navigator**: spawn a subagent with the ticket text, the selected skills' names and the diff (`git diff DEFAULT_BRANCH...HEAD`). Ask for the three most important problems only, in order: correctness and edge cases, violation of a repo rule or selected skill, missing test. Style the linter does not enforce is out of scope.
4. Decide: refine the current approach when the navigator's findings are shrinking, or pivot to a different approach when the same class of finding returns twice; say which in the commit body. Rejected findings are answered there too.
5. Commit `<id>: <imperative summary>` with a body that says why. One commit per criterion; a criterion that needs a refactor first gets two commits, refactor then behavior.
6. Next criterion.

On rework the review comments are the criteria: one commit per addressed comment, the commit body names the comment.

## Bug fixes

1. Reproduce the bug as a failing test. Run it and confirm it fails for the expected reason. Commit the test alone.
2. Create `.claude/fix-mode` so the test-freeze hook (`agentic-coding:guardrails`) blocks edits to test files from here on.
3. Make the test pass by changing the code only. Remove `.claude/fix-mode` after the gates are green. A test that existed before the fix and could not be rewritten is the proof the bug is gone; the reviewer checks the commit order.

## Long runs: handoff

When the ticket has more than `HANDOFF_AFTER_CRITERIA` criteria (default 6), or `CONTEXT_RESET = always`, write `SDLC_DIR/<ticket-id>/handoff.md` after every third committed criterion and before ending a run that could not finish: state (criteria done and their commits), decisions taken and why, open navigator findings, next steps in order, and commands to resume. Commit it, `comment` "Handoff written, resume with CONTINUE <id>", and end the run when `CONTEXT_RESET` says so; a fresh run continues from the file instead of from a compacted memory.

## Step 6: Verify with fresh eyes

When all criteria are committed, spawn the verifier subagent (`agentic-coding:evaluator-qa`): fresh context, only the ticket, `plan.md` and the run command. It starts the app or service, exercises every behavioral criterion plus the two nearest neighboring flows, and reports findings with location and cause. It fixes nothing. Its BLOCKERs go back into the loop as criteria; then continue with `agentic-coding:verify-acceptance`.

## Scope rules

- Only what the ticket asks. A necessary refactor is allowed when it stays in the files you touch anyway and gets its own commit.
- No dependency upgrades, CI changes, secrets or lockfile edits unless the ticket is about them.
- No TODOs for skipped work; write the follow-up under "Notes for reviewer" in the PR.
- No debug output, commented-out code or feature flags the ticket did not ask for.
- A feature is not done while any part of it is display-only or stubbed; a stub you cannot complete is a stop condition, not a note.

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
|--------------|--------------|---------|
| Code before the plan is agreed | Rework discovered in review instead of in a document | Contract first, one commit |
| One big commit at the end | Reviewer cannot map commits to criteria | One commit per criterion |
| Tests written after the code to match it | They cannot fail, so they prove nothing | Test first, watch it fail once |
| Fix and test in the same commit | Nobody can tell the test was not bent to the fix | Test commit, fix mode, fix commit |
| Verifier that shares the coder's context | Inherits the assumptions that produced the bug | Fresh subagent, artifacts only |
| Applying a skill rule the repo contradicts | Repo owner loses control | Repo rule wins |

## Checklist

- [ ] Ticket restated, criteria verifiable, artifacts read
- [ ] Branch from a fresh default branch, no rebase on rework
- [ ] Two neighboring examples matched, selected skills read
- [ ] plan.md negotiated, committed first, SHA on the ticket
- [ ] One green commit per criterion, navigator pass after each
- [ ] Bug fixes: failing test committed first, fix mode used
- [ ] handoff.md when the run is long
- [ ] Verifier subagent run, its BLOCKERs resolved
