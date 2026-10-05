---
description: How work enters the agentic-coding loop without a person starting it: deterministic control-band monitoring with tiered responses (log, diagnose, propose), tickets and chat mentions triaged into either a small bounded PR or an intent.md, and the lessons file that keeps incident knowledge in the repo. Use when wiring monitoring, on-call or channel triggers into the loop.
---

# Closing the loop

The loop closes when a trigger invokes an agent with no person in the invocation path, and what the agent finds re-enters the pipeline as a ticket with an `intent.md`. Detection stays deterministic; the model is invoked only once a band is breached, and the tier sets what it may do.

## Control bands

1. Pick one metric with a stable rolling baseline: CI test failure rate, post-deploy 5xx rate, PR cycle time, rework rounds per PR.
2. A version-controlled, unit-tested script computes mean and standard deviation over a rolling window with drift rules (Western Electric or similar). No model in detection.
3. Tiers live in `bands.yaml` (full annotated template in `templates/bands.yaml` of this skill):

   ```yaml
   metric: ci_test_failure_rate
   baseline: rolling_30d
   rules: western_electric
   tiers:
     1sigma: { action: log }
     2sigma: { action: diagnose, tools: "Read,Grep,Bash(gh run view *)" }
     3sigma: { action: propose, routes: [ticket_with_intent, pull_request, runbook:rollback-deploy] }
   ```

4. The trigger layer is a scheduled workflow, a monitoring webhook, or a scheduled task; the agent runs stateless and non-interactively.
5. At `diagnose`, the agent writes its finding as `intent.md` (template in `agentic-coding:sdlc-artifacts`): anomaly and evidence, proposed outcome, affected systems, open questions. It creates a ticket in `INTAKE_STATUS` linking the file. The planner agent takes it from there.
6. At `propose`, the agent may additionally open a PR into the review gate (a quarantined flaky test, a revert) or trigger a pre-approved runbook such as a rehearsed rollback. It never passes the production gate itself.
7. The service owner triages the intake queue: fix now, schedule, dismiss. Dismissals tune the bands.
8. Every shipped fix gets an eval (`agentic-coding:agent-evals`) and a lessons file.

## Work from tickets and channels

A ticket filed by a human, or a mention in an incident channel, is triaged the same way: a small, well-bounded fix with clear acceptance criteria goes straight to `Todo` for the coder; anything larger is written as `intent.md` and lands in `INTAKE_STATUS` for the planner. The channel or ticket thread stays the audit trail: request, diagnosis, human authorization, fix.

## Lessons file

`SDLC_DIR/lessons/<date>-<slug>.md`: what breached, evidence, cause, what was done, what would have caught it earlier, the eval added. Future diagnoses read this folder first.

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
| -------------- | -------------- | --------- |
| Model decides when to alert | Non-deterministic, unauditable | Script detects, model diagnoses |
| Agent deploys the rollback in production on its own | Passes the production gate | Runbook pre-approved, hook-gated |
| Findings posted to chat only | Lost by the next fire | intent.md plus ticket |

## Checklist

- [ ] Deterministic detection script, version controlled and tested
- [ ] Tiers in `bands.yaml`, tools scoped per tier
- [ ] Findings become `intent.md` plus an intake ticket
- [ ] Rollback rehearsed before the agent may trigger it
- [ ] Lessons file and eval per incident
