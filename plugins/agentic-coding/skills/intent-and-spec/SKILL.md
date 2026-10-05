---
description: Turns a raw ticket, idea or incident into the Plan and Design artifacts of the agentic-coding loop: an intent.md in the originator's words and a spec.md with numbered testable requirements, design, acceptance criteria and flagged concerns, written under the organization's brand, security, compliance and UX skills as constraints. Use by the planner agent for tickets in the intake status, or interactively before a ticket enters Todo.
---

# Intent and spec

Requirements and design collapse into one pass. The agent writes the spec; the product owner reviews it and decides. Policy is applied while the spec is written, not discovered in a review later.

## Inputs

- A ticket in `INTAKE_STATUS` (default `Inbox`), a free-text idea, or an incident record / lessons file.
- The organization's policy skills available in the session: brand, security, compliance, UX, API design, data classification. Selected via `agentic-coding:workflow-config`; each one becomes a constraint on the spec and is named in "Guidance applied".
- `CLAUDE.md` / `AGENTS.md` for the codebase's architecture and boundaries.

## Step 1: intent.md

1. Restate the problem in the originator's terms: what they cannot do today, who is affected, what better looks like, what is out of scope. No solution language yet.
2. Ask the analyst's questions and answer them from the ticket, its comments and linked material: scope, users, constraints, success. Anything unanswerable goes into "Open questions" verbatim, never guessed.
3. Write `intent.md` from the template in `agentic-coding:sdlc-artifacts`. Status `draft`.
4. Unattended: commit it to `SDLC_DIR/<ticket-id>/` on a branch `sdlc/<ticket-id>-intent` and open a PR for the product owner; interactively, show it and let the originator correct it first.

## Step 2: spec.md

Prompt yourself with the playbook's design instruction, adapted: read `intent.md`, produce a requirements and design spec for integrating it into this codebase, apply the available policy skills so the spec conforms to them, document it fully as `spec.md`, and describe clearly every area of concern, especially where policies contradict each other or the intent.

1. Explore the codebase for the affected components; the design must name real modules, not invented ones.
2. Requirements: numbered, each testable by a named check. A requirement without a feasible check is a flagged concern, not a requirement.
3. Design: components touched, data changes, interfaces, one sequence per main flow. Front-end work references the approved mock when one exists.
4. Acceptance criteria: one checkbox per requirement, phrased as an observable outcome ("GET /claims/{id}/status returns 200 with `nextStep` for all four claim states"). These are copied onto the ticket by the planner, since the coder and reviewer work from the ticket.
5. Flagged concerns first: policy conflicts, unanswered open questions from `intent.md`, and a risk class (`routine` or `higher-risk`; higher-risk needs a tech lead before Build). Each concern names the policy owner who has to resolve it.
6. Guidance applied: the skills and repo rules that constrained the spec, by name and version or commit.

## Step 3: hand to the gate

1. Commit `spec.md` next to `intent.md` in the same PR.
2. Write the acceptance criteria into the ticket (`tick_criterion` targets must exist as unchecked boxes), link the PR, `transition` the ticket to `APPROVAL_STATUS` (default `Needs Approval`).
3. Stop. Moving the ticket to Todo is a human decision; the coder will not touch it before that.

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
| -------------- | -------------- | --------- |
| Solution in intent.md | Locks the design before the problem is understood | Problem, outcome, constraints only |
| Requirements that are not testable | Coder cannot verify, reviewer cannot check | Every requirement names its check |
| Resolving a policy conflict yourself | The policy owner was never asked | Flag it, name the owner |
| Moving the ticket to Todo | Skips the human gate | `APPROVAL_STATUS` only |

## Checklist

- [ ] intent.md in the originator's words, open questions verbatim
- [ ] spec.md with numbered testable requirements and real components
- [ ] Acceptance criteria on the ticket, unchecked
- [ ] Flagged concerns with policy owners and risk class
- [ ] Ticket in `APPROVAL_STATUS`, PR linked
