---
description: Principles for evolving the agentic-coding loop itself: every agent, subagent, gate and artifact encodes an assumption about what the model cannot do alone, so components are removed one at a time when a new model lands and added when a task sits beyond what the model does reliably solo. Covers the per-model levers for Claude Opus 5.5 and Claude Fable 5.1 (effort, max_tokens, turn endings, progress notes, tool batching, subagents, history and compaction), context resets with handoff artifacts versus compaction, when the evaluator is worth its cost, sprint-style decomposition, and how to run the removal experiment. Use when a new model is adopted, when the loop feels slow or expensive, or when adding a component.
---

# Harness tuning

Find the simplest loop that works and add complexity only when a measured gap demands it. The loop in this plugin (planner, coder with contract and navigator, evaluator, janitor) is a starting point calibrated against the models available when it was written, not a fixed design.

## Every component is an assumption

| Component | Assumes the model cannot, on its own | Test by |
| ----------- | -------------------------------------- | --------- |
| Planner and spec | scope ambitiously and consistently from a short prompt | run the coder from raw tickets for a week; compare completeness scores |
| Contract before code | bridge user stories to testable behavior without drifting | skip the contract on routine tickets; compare rework rounds |
| Navigator pass per criterion | catch its own edge cases mid-build | disable it; compare reviewer BLOCKER counts |
| Verifier subagent | judge its own finished work | disable it; compare display-only or stubbed findings in review |
| Reviewer agent | be trusted to merge its own work | never removed: separation of duties is governance, not capability |
| Sprint-style decomposition (one criterion per commit) | stay coherent over a long build | allow larger commits on small tickets; compare plan match rate |
| Handoff artifact and context reset | keep coherence when the context fills | measure "context anxiety": premature wrap-ups, skipped criteria late in a run |
| "How the run ends" rules in each agent | keep working unattended instead of stopping to report or ask | remove them from one agent; count runs that end with open work and no stop condition |
| Batching instructions ("request independent calls in one response") | issue independent tool calls in parallel when the task only implies them | remove them; compare turns and wall-clock per run |
| Scope rules in `implement-ticket` | keep a change to what the ticket asks | remove them; compare unrequested files and committed test files per PR |

When the assumption no longer holds, the component is overhead: tokens, latency, and a place for errors to enter.

## Model levers: Claude Opus 5.5 and Claude Fable 5.1

The scheduled tasks pick the model and its settings; the prompts in this plugin are written for both. Re-check these levers whenever the model behind a task changes, and log each change like a removal experiment.

| Lever | Claude Opus 5.5 | Claude Fable 5.1 | In this loop |
| ------- | ----------------- | ------------------ | -------------- |
| Effort | default `medium`; matches or beats Opus 5 at `high` on coding | default `high`; `medium` and `low` often hold quality at lower cost | start each task at the model's default, sweep the other levels against loop metrics, keep `xhigh` / `max` for a measured gain; the janitor rarely needs more than `low`. Level names do not mean the same amount of thinking across models |
| `max_tokens` | thinking always on and counts toward the limit | long deliverables at `xhigh` / `max` think longer first | leave room for thinking plus the reply; 128,000 works for long coder turns |
| Ending the turn | some progress reports end the turn as text | may describe the next step or ask permission instead of doing it | each agent's "How the run ends" section; in the harness, treat a text-only end of turn as a report, send one message naming the open items, and stop after two or three automatic continuations so a stuck run surfaces |
| Progress notes | arrive as progress-update `thinking` blocks, empty unless `display: "updates"` | writes fewer notes in long tool chains | set `display: "updates"` so run logs show the notes; trace reading depends on them |
| Parallel tool calls | batches as asked | may issue implied calls one per turn in coding loops | the agents ask for batching; a harness can append the nudge as a turn-scoped system message |
| Subagents | paces work to elapsed-time signals | lead finishes sooner when it keeps working while subagents run | give the coder an elapsed-time line against a budget; let subagent tools return immediately where the harness allows |
| History and compaction | changing `system` or tools mid-run invalidates earlier thinking | thinking blocks are bound to the exact conversation; cache reads are cheaper | append-only history, turn-scoped system messages for reminders; with client compaction, tell the summary to keep constraints, decisions, open items and exact identifiers; try later compaction points |
| Reasoning in output | requests to reproduce reasoning in the reply may be refused (`reasoning_extraction`) | same | artifacts ask for decisions and a short why (commit bodies, `plan.md` risks), never for the reasoning itself |
| Scope | stays close to the request | may fix nearby code or commit more tests than asked | the scope rules in `agentic-coding:implement-ticket` |

## Context resets versus compaction

Compaction summarizes earlier turns in place; the agent keeps going on a shortened history. A reset starts a fresh agent from a handoff artifact. Compaction keeps continuity but not a clean slate; models that wrap up prematurely as their context fills need the reset. The plugin supports both: the coder writes `handoff.md` (state, decisions, next steps, open findings) at defined points, and a `CONTINUE <ticket-id>` run resumes from it. Set `CONTEXT_RESET = never | on-long-tickets | always` in `WORKFLOW.md` based on the measurement above, and revisit it per model.

## When the evaluator is worth it

The evaluator pays for itself when the task sits beyond what the current model does reliably solo, and becomes overhead inside that boundary. The boundary moves outward with every model. Practical rule: keep the reviewer always (governance), keep the verifier and navigator on tickets labeled `higher-risk` or on repos with a history of display-only findings, and re-measure quarterly.

## The removal experiment

1. Change one component at a time. Cutting several at once made it impossible to tell which piece was load-bearing.
2. Hold the metrics window constant (`agentic-coding:loop-metrics`).
3. Run long enough for the metric to settle: rework rounds and first-pass merge share need at least twenty PRs.
4. Keep the change if the metric held; revert and note the assumption as confirmed if it dropped.
5. Record the result in `docs/sdlc/harness-log.md`: date, model, component, metric before and after, decision.

## Adding a component

Only against a measured gap: a finding class the evaluator keeps reporting, a stop condition that keeps firing, a metric that regressed after a model change. Write the assumption it encodes into the table above before building it, so it can be removed later by the same method.

## Read the traces

The most reliable tuning signal is reading run logs on realistic tickets: where the coder stubbed a feature, where the evaluator softened a finding, where the planner over-specified implementation details that then cascaded. Prompt and skill changes come from those observations, and the evals guard against regressions.

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
| -------------- | -------------- | --------- |
| Radical simplification in one step | Cannot attribute the regression | One component at a time |
| Keeping the harness frozen across model upgrades | Pays for scaffolding the model no longer needs | Re-run the removal experiment per model |
| Removing the reviewer for speed | Breaks separation of duties | Governance components stay |
| Planner that specifies implementation details | Errors cascade into every downstream stage | Planner owns deliverables and constraints; coder owns the path |
| Carrying effort settings over from the previous model | Level names do not map across models; turns get longer or quality drops | Sweep effort per model against loop metrics |
| Treating every text-only end of turn as done | Unattended runs stop with open work | Continue with the open items, capped at two or three nudges |

## Checklist

- [ ] Assumption written down for each component
- [ ] One change at a time, metrics window fixed
- [ ] Decision logged with model and numbers
- [ ] Governance components untouched
- [ ] Effort, `max_tokens` and progress-note display set per model and logged
