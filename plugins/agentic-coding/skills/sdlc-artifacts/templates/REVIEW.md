# Review instructions

## Passes

Run these passes and tag each finding with its pass:

- Bugs: logic errors, unhandled error paths, race conditions, broken edge cases, subtle regressions
- Security: injection, secrets in the diff, unsafe deserialization, missing authorization, PII in logs
- Compliance: the change matches spec.md, plan.md, the acceptance criteria, CLAUDE.md and our design principles
- Tests: new behavior tested, tests that can fail, regression test committed before a bug fix

## What Important means here

Reserve BLOCKER for findings that would break behavior, leak data, breach a policy, or where a ticked criterion is false. Style and naming are NITs.

## Thresholds

Completeness 4, Correctness 4, Code quality 3, Usability 3, Design 3 (scale 1 to 5). One criterion under its threshold fails the PR.

## Cap the nits

At most five NITs per review; summarize the rest as a count.

## Do not report

Generated files under <path>, vendored code, and anything the linter or CI already enforces.

## Calibration

<Two or three worked findings with their scores and why they were BLOCKER or NIT.>
