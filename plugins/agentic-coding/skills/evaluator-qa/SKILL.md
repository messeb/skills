---
description: How the evaluating side of the agentic-coding loop (the reviewer agent, the verifier subagent, the contract reviewer) grades without the leniency LLMs show toward LLM output. Covers the generator/evaluator separation, exercising the running application instead of reading the diff, rubric criteria with hard thresholds, the failure modes of talking yourself out of a finding and superficial testing, calibration examples, and the log-driven tuning loop. Use whenever an agent judges work it did not produce.
---

# Evaluator and QA

Agents grade their own work generously, and an evaluator that is a separate agent is still inclined to be generous toward LLM-generated output. Separating the roles is the lever; tuning the evaluator to be skeptical is the work. This skill is that tuning, written as rules. It follows the generator/evaluator pattern from Anthropic's harness-design work for long-running application development.

## Where it applies

| Evaluator | Judges | Fresh context |
| ----------- | -------- | --------------- |
| Reviewer agent | the PR (`agentic-coding:review-pr`) | yes, separate run |
| Verifier subagent | the running app at the end of a coder run | yes, spawned with only the ticket, `plan.md` and the run command |
| Contract reviewer subagent | the coder's proposed `plan.md` before code | yes |
| Navigator subagent | the diff after each criterion | yes, per invocation |

The evaluator never receives the generator's reasoning, only its artifacts. Its verdict must not be colored by the assumptions that produced the code.

## Exercise, do not read

Reading a diff finds bugs in logic; it does not find features that are display-only, wiring that is missing, routes that shadow each other, or flows a user cannot complete. For every acceptance criterion that describes behavior:

1. Start the application or service with the repo's run command.
2. Drive it the way a user or client would: a browser tool for UI (`Playwright` MCP, Claude in Chrome, the built-in browser), `curl` or the API client for endpoints, direct queries for database state.
3. Exercise the criterion, its edge cases (empty, maximum, invalid, concurrent, unauthorized) and the two nearest neighboring flows that the change could have broken.
4. Record what you ran and what you observed, with file and line references when you locate the cause. A finding is actionable when the coder can fix it without re-investigating: "PUT /frames/reorder is defined after /{frame_id}, so FastAPI parses 'reorder' as an integer and returns 422" is the standard.

## Rubric with hard thresholds

Grade each criterion below independently, 1 to 5, and treat every threshold as a gate: one criterion under its threshold fails the work regardless of the others.

| Criterion | Question | Threshold |
| ----------- | ---------- | ----------- |
| Completeness | Is every acceptance criterion and contract item implemented with interactive depth, not stubbed or display-only? | 4 |
| Correctness | Do the exercised flows behave as specified, including edge cases? | 4 |
| Code quality | Does the change follow the repo's conventions and the selected skills, with tests that can fail? | 3 |
| Usability (UI work) | Can a user find the primary action and complete the task without guessing? | 3 |
| Design (UI work, when a mock or design skill applies) | Does it match the approved mock or the design principles, or does it fall back to generic defaults? | 3 |

Organizations put their own criteria and thresholds into `REVIEW.md`; these are the defaults.

## Failure modes to refuse

- **Talking yourself out of a finding.** You identify a real issue, then decide it is "not a big deal" and approve. Rule: once written down as a finding, it is classified by the rubric, never dismissed by tone. If it is truly minor it is a NIT, and NITs are still reported.
- **Superficial testing.** Clicking the happy path once. Rule: every criterion gets its edge cases and neighbors, and the evidence lists them.
- **Praise as verdict.** "Strong work overall" is not a grade. Rule: scores per criterion, findings per failure, then a one-line verdict.
- **Grading the description.** The PR body says it works. Rule: only what you exercised counts.
- **Anchoring on the generator's tests.** Green tests written by the generator prove the generator's assumptions. Rule: write or run at least one check the generator did not.

## Calibration

`REVIEW.md` may carry two or three worked examples: a finding with its score breakdown and why it was a BLOCKER, a finding that looked severe but was a NIT and why. The evaluator reads them before grading. They anchor the scale and reduce drift between runs.

## Tuning loop

Evaluator prompts drift from the tech lead's judgment. Monthly, or after an incident the evaluator should have caught:

1. Read the evaluator's run logs for the period.
2. Mark every verdict a human would have graded differently, in either direction.
3. Turn each divergence into a rule or an example in `REVIEW.md` (or, for repo-independent divergence, in this skill via the plugin's normal change process).
4. Re-run the evals (`agentic-coding:agent-evals`) to confirm the pass rate did not drop for the wrong reasons.

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
| -------------- | -------------- | --------- |
| Evaluator shares context with the generator | Inherits its assumptions | Fresh context, artifacts only |
| Screenshot instead of interaction | Misses everything behind the first click | Drive the app |
| Averaging scores | One broken core feature hides behind polish | Per-criterion thresholds |
| Feedback without location | Generator re-investigates | File, line, cause, expected |

## Checklist

- [ ] Evaluator ran in fresh context with artifacts only
- [ ] Every behavioral criterion exercised in the running app with edge cases and neighbors
- [ ] Scores per criterion against thresholds, findings with location and cause
- [ ] No finding dismissed after being written down
- [ ] Verdict follows the thresholds, not the tone
