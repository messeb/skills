---
description: Continuous evals for the configuration that steers the agentic-coding loop. Builds a suite of real tasks with pass criteria, runs it in CI on every change to CLAUDE.md, skills, hooks or WORKFLOW.md and on a schedule, gates those changes on the pass rate, and turns every production incident into a permanent eval. Use when changing agent configuration or after an incident.
---

# Agent evals

`CLAUDE.md`, skills, hooks and `WORKFLOW.md` steer the agents, so they get the regression testing code gets. An eval is a prompt plus the checks that define acceptable: tests pass, lint clean, behavior unchanged, policy followed.

## Build the suite

1. Collect 20 to 50 real tasks from recent merged tickets: the ticket text as the prompt, the merged PR as the reference.
2. For each, write `evals/<id>.json`: `prompt`, `allowed_tools`, `checks` (commands that must exit 0, files that must or must not change, strings that must appear in the summary, policies that must be cited).
3. Keep the suite live: cases every model passes stop discriminating and are retired; monitoring findings add new ones.

## Bundled files

```text
agent-evals.yml                    copy to .github/workflows/agent-evals.yml
evals/check.sh                     runs one eval's checks against the repo state and the claude -p result; exit 0 pass, 1 fail
evals/example-null-handling.json   the eval format: prompt, allowed_tools, checks
```

`check.sh` supports five check kinds: `commands` (must exit 0), `files_changed`, `files_unchanged`, `summary_contains` (strings in the agent's final summary, for policy citations and evidence), `diff_excludes` (strings that must not appear in the diff, such as `skip` markers). It resets the working tree after each eval.

## Run it

Copy `agent-evals.yml`, `evals/check.sh` and your eval files into the repo. The workflow runs every eval with `claude -p`, calls `check.sh`, and fails the job when the pass rate is below `EVAL_PASS_RATE`.

Gate: a configuration PR that lowers the pass rate below the threshold in `WORKFLOW.md` (`EVAL_PASS_RATE`, default 0.9) needs review by the configuration's owner before merge.

## Incidents become evals

When a fix for a production incident merges, the team that owned the incident adds an eval reproducing the task that would have prevented it. The janitor's weekly metrics report lists incidents in the lessons folder without a matching eval.

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
| -------------- | -------------- | --------- |
| Evals only on model upgrades | Skill drift goes unnoticed | On every configuration change and nightly |
| Checks by reading the transcript | Subjective, not repeatable | Commands that exit non-zero |
| Frozen suite | Stops discriminating | Retire and add cases continuously |

## Checklist

- [ ] Suite of real tasks with executable checks
- [ ] CI runs on configuration paths and on a schedule
- [ ] Pass-rate threshold enforced as a merge check
- [ ] Every incident in `lessons/` has an eval
