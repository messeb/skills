---
description: The committed artifact chain of the AI-native SDLC as used by the agentic-coding loop. Defines intent.md, spec.md, plan.md, REVIEW.md, CLAUDE.md and the lessons file: where they live in the repo, their templates, which stage writes and which reads them, the source-of-truth choice between tracker and repo, and the linkage rule (ticket id in every artifact, commit SHA in every ticket). Use whenever an agent writes or reads one of these files.
---

# SDLC artifacts

Every stage of the loop ends by committing an artifact the next stage reads, and the chain of commits is the audit trail: who asked for what, what the agent produced, who approved it. This follows the artifact model of Anthropic's AI-Native SDLC Playbook; the templates below are this plugin's concrete form of it.

## The chain

| Stage | Artifact | Written by | Read by | Gate |
|-------|----------|------------|---------|------|
| Plan | `intent.md` | originator with Claude, or the planner agent from a ticket or incident | planner (spec) | product owner accepts |
| Design | `spec.md` | planner agent, constrained by the organization's skills | coder (plan), reviewer (compliance) | product owner moves the ticket to Todo |
| Build | `plan.md` | coder before writing code | reviewer (plan match) | coder accepts its own plan for routine work; higher-risk classes need a human |
| Build | `handoff.md` (long runs) | coder at reset points | the next coder run (`CONTINUE`) | none |
| Build | the diff and its tests | coder | reviewer | quality gates |
| Deploy | PR with review findings | reviewer | humans, metrics | branch protection |
| Maintain | incident record, lessons file, new `intent.md` | on-call agent or human | planner | triage |

## Where they live

```text
SDLC_DIR = docs/sdlc            # WORKFLOW.md key; default shown
docs/sdlc/<ticket-id>/intent.md
docs/sdlc/<ticket-id>/spec.md
docs/sdlc/<ticket-id>/plan.md
docs/sdlc/<ticket-id>/handoff.md
docs/sdlc/harness-log.md        # harness-tuning decisions
REVIEW.md                       # repo root, review policy
CLAUDE.md, AGENTS.md            # repo root, working knowledge
docs/sdlc/lessons/<date>-<slug>.md
```

A monorepo keeps one `SDLC_DIR` per package. A dedicated intent repository is only worth it when intent spans many repos.

## Source of truth

`SOURCE_OF_TRUTH` in `WORKFLOW.md` names one system per artifact:

- `repo`: the markdown files are authoritative; the ticket carries links to the commits. Cleanest for engineering-led teams.
- `tracker`: Jira, GitHub Issues or Notion holds the record; the markdown files are working copies written back in the same session that produced them (`ticket-tracker` operations).
- `linkage` (default and minimum bar): both exist; every artifact carries the ticket id in its first line, every ticket carries the commit SHA of each artifact. Accept two sources, keep them linked.

## Linkage rule

Every artifact starts with a header line `Ticket: <ref>` and every artifact commit is reported on the ticket as `[agentic-coding/<agent>] <artifact> committed: <sha>`. The janitor repairs missing links.

## Templates

Copy-ready versions of every template below live in `templates/` next to this skill: `intent.md`, `spec.md`, `plan.md`, `handoff.md`, `REVIEW.md`, `lessons.md`. Agents copy the file and fill it; the outlines here are for reading.

`intent.md` (the proto-spec, in the originator's words):

```markdown
# Intent: <title>
Ticket: <ref>. Author: <name or agent>. Status: draft | accepted.

## Problem
## Proposed outcome
## Affected users and systems
## Constraints
## Open questions
```

`spec.md` (requirements and design, policy applied while writing):

```markdown
# Spec: <title>
Ticket: <ref>. From: intent.md <sha>. Status: draft | accepted.

## Scope and non-goals
## Requirements (numbered, testable)
## Design (components, data, interfaces, sequence)
## Acceptance criteria (one per requirement, checkbox list)
## Flagged concerns (policy conflicts, unanswered open questions, risk class)
## Guidance applied (skills and repo rules, by name)
```

`plan.md` (implementation plan, committed before code):

```markdown
# Plan: <title>
Ticket: <ref>. From: spec.md <sha>.

## Files that change
## Order of work
## Risks (what could break, the riskiest step, options rejected)
## Proof (test per acceptance criterion, commands, visual checks)
```

`handoff.md` (state carried across a context reset):

```markdown
# Handoff: <title>
Ticket: <ref>. Branch: <name>. Written: <timestamp>.

## Done (criterion → commit)
## Decisions and why
## Open findings (navigator, verifier)
## Next steps, in order
## Resume commands
```

`REVIEW.md` (review policy, owned by the tech lead):

```markdown
# Review instructions
## Passes            (bugs, security, compliance, tests; add organization passes)
## What Important means here
## Cap the nits      (default five)
## Do not report     (generated paths, anything CI enforces)
## Calibration       (two or three worked findings with scores, see evaluator-qa)
```

## CLAUDE.md working rules

`CLAUDE.md` is the new-joiner page: commands with an example of healthy output, the conventions that matter, architecture in five lines, and the mistakes the team keeps seeing. Keep it under a page; everything stale costs context. The rule the agents enforce: a mistake made twice goes into `CLAUDE.md` (the reviewer opens that PR, see `agentic-coding:review-pr`). Skills hold institutional knowledge that must apply consistently across repos; `CLAUDE.md` holds what is specific to this one.

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
|--------------|--------------|---------|
| Writing plan.md after the code | It documents instead of governs | Plan first, update in the same commit as a deviation |
| spec.md without flagged concerns | Concerns surface in review, weeks later | Flag every policy conflict and open question |
| Two sources of truth, no links | Auditors and agents read different stories | Linkage rule, minimum |
| CLAUDE.md as a wiki | Context spent on stale text | One page, corrections only |

## Checklist

- [ ] Artifact in `SDLC_DIR/<ticket-id>/` with the `Ticket:` header
- [ ] Commit reported on the ticket with the SHA
- [ ] Template sections present, none empty without a reason
- [ ] Source-of-truth rule from `WORKFLOW.md` respected
