---
description: Principles for evolving the agentic-coding loop itself: every agent, subagent, gate and artifact encodes an assumption about what the model cannot do alone, so components are removed one at a time when a new model lands and added when a task sits beyond what the model does reliably solo. Covers context resets with handoff artifacts versus compaction, when the evaluator is worth its cost, sprint-style decomposition, and how to run the removal experiment. Use when a new model is adopted, when the loop feels slow or expensive, or when adding a component.
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

When the assumption no longer holds, the component is overhead: tokens, latency, and a place for errors to enter.

## Context resets versus compaction

Compaction summarizes earlier turns in place; the agent keeps going on a shortened history. A reset starts a fresh agent from a handoff artifact. Compaction keeps continuity but not a clean slate; models that wrap up prematurely as their context fills need the reset. The plugin supports both: the coder writes `handoff.md` (state, decisions, next steps, open findings) at defined points, and a `CONTINUE <ticket-id>` run resumes from it. Set `CONTEXT_RESET = never | on-long-tickets | always` in `WORKFLOW.md` based on the measurement above, and revisit it per model.

## When the evaluator is worth it

The evaluator pays for itself when the task sits beyond what the current model does reliably solo, and becomes overhead inside that boundary. The boundary moves outward with every model. Practical rule: keep the reviewer always (governance), keep the verifier and navigator on tickets labeled `higher-risk` or on repos with a history of display-only findings, and re-measure quarterly.

## The removal experiment

1. Change one component at a time. Cutting several at once made it impossible to tell which piece was load-bearing.
2. Hold the eval suite and the metrics window constant (`agentic-coding:agent-evals`, `agentic-coding:loop-metrics`).
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

## Checklist

- [ ] Assumption written down for each component
- [ ] One change at a time, metrics window fixed
- [ ] Decision logged with model and numbers
- [ ] Governance components untouched
