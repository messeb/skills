---
description: Requirements baselining — immutable, approved snapshots of a requirement set for a release, contract, or audit. Covers what a baseline is and what it contains, entry criteria and the approval process, naming and immutability rules, partial and rolling baselines in agile delivery, the relationship to change control and traceability, audit and evidence obligations, and Markdown templates for a baseline record and a baseline comparison.
---

# Requirements baselining

Goal of this skill: freeze an **agreed, approved, immutable snapshot** of what is to be built, so that everyone — team, customer, auditor — can point at the same version and say "this is what we agreed".

Use this skill before a contractual delivery, for a regulatory or certification submission, at a release scope commitment, before a supplier handover, and at any point where "what did we agree?" must have a single answer.

Do **not** baseline a backlog that is meant to keep evolving. A baseline is a commitment device; applying it to exploratory work converts learning into change requests and kills the reason for working iteratively.

---

## 1. What a baseline is

A baseline is:

- **A snapshot** — the state of a defined set of artifacts at one moment.
- **Approved** — by named people with the authority to approve.
- **Immutable** — it is never edited. Changes create a *new* baseline (`change-management`).
- **Referenceable** — it has a stable identifier that appears in contracts, test reports, and audit evidence.
- **Complete for its purpose** — it contains everything needed to know what was agreed.

A baseline is not: the current state of a wiki page, the latest version of a document, or "the backlog as of Friday" with no approval.

---

## 2. What goes into a baseline

| Artifact | Include when |
|----------|--------------|
| Requirement set with versions and ids | Always |
| Constraints and assumptions | Always — assumptions are half the contract |
| Quality attribute scenarios | Always (`quality-attributes`) |
| Interface contracts and their versions | Any external interface (`api-contracts`) |
| Domain and behaviour models | Where they define agreed behaviour (`state-machines`, `process-modeling`, `data-modeling`) |
| Glossary version | Always — meaning is part of the agreement |
| Acceptance criteria / acceptance test definitions | Always (`acceptance-test-definition`) |
| Traceability matrix and coverage report | Regulated, contractual (`traceability`) |
| Open items and known gaps | Always — a baseline with hidden gaps is a trap |
| Review and approval records | Regulated, contractual (`requirements-reviews`) |
| Prioritisation and scope decisions, including "won't do" | Always |

Reference artifacts by **id and version**, and pin the versions. A baseline that points at "the latest" points at nothing.

---

## 3. Entry criteria and approval

Do not baseline a draft. Before approval:

- [ ] All requirements reviewed; critical and major defects closed (`requirements-reviews`)
- [ ] Every requirement has a rationale, a source, and a verification method
- [ ] Conflicts resolved or explicitly accepted with a decider (`risk-conflict-analysis`)
- [ ] Feasibility assessed; infeasible items removed or converted into spikes
- [ ] Traceability complete, with exceptions named
- [ ] Open questions either answered or listed as known gaps with owners and dates
- [ ] Assumptions listed with owners and validation status
- [ ] Scope decisions recorded, including what is explicitly out

**Approval**: name the approvers and their roles, record the date and the version approved, and record dissent. Approval by silence is not approval; if an approver did not respond, that is an open item, not consent.

---

## 4. Naming and immutability

| Rule | Detail |
|------|--------|
| Stable identifier | `BL-<scope>-<YYYY-MM>` or a release name — never "final", "final2", "final_approved" |
| Immutable storage | Git tag, signed release, or a document management system with version control |
| Content hash or commit id recorded | So the snapshot can be proven unchanged |
| Never edited | Corrections create a new baseline referencing the corrected one |
| Superseded, not deleted | Old baselines stay retrievable for the required retention period |
| Referenced by id everywhere | Contracts, test reports, audit evidence, release notes |

The cheapest robust implementation: keep the specification in version control and cut a **git tag** for each baseline. You get immutability, diffs, history, approval via pull request, and a content hash without any extra tooling.

---

## 5. Baselining in agile delivery

Baselining and iterative delivery are compatible if you baseline the right things at the right granularity.

| Approach | How | Use when |
|----------|-----|----------|
| **Release baseline** | Baseline the scope committed for one release; the backlog beyond it stays fluid | Most product teams with external commitments |
| **Rolling baseline** | Re-baseline each increment; each is a snapshot of what that increment delivered | Continuous delivery with periodic audit needs |
| **Partial baseline** | Baseline only the regulated, safety, or contractual subset; leave the rest agile | Mixed products — the most common practical answer |
| **Contractual baseline** | Full set, formal approval, strict change control | Fixed-price and public-tender work |

Rule of thumb: **baseline the commitments, not the candidates.** Regulatory obligations, contractual scope, published interfaces, and safety requirements belong in a baseline. Discovery, ideas, and next-quarter guesses do not.

---

## 6. Intake — ask before baselining

Ask only what is missing; batch into one message, five or fewer.

1. **Why baseline** — contract, release commitment, audit, certification, supplier handover?
2. **What is in scope** — which requirements, models, contracts, and criteria?
3. **Who approves**, and what is their authority?
4. **What must be provable afterwards**, and to whom (auditor, customer, certification body)?
5. **What is the retention and storage requirement** — how long, in what system?

---

## 7. Output templates

### 7.1 Baseline record

````markdown
# Baseline BL-BOOKING-2026-09

| | |
|---|---|
| Purpose | Release R2 scope commitment + EU 261 compliance evidence |
| Created | 2026-09-05 |
| Status | approved |
| Supersedes | BL-BOOKING-2026-06 |
| Storage | git tag `baseline/BL-BOOKING-2026-09`, commit `a3f9c21` |
| Retention | 10 years (tax + regulatory) |

## Approvals

| Role | Name | Decision | Date | Note |
|------|------|----------|------|------|
| Product owner | <name> | approved | 2026-09-04 | |
| Engineering lead | <name> | approved | 2026-09-04 | |
| Legal / compliance | <name> | approved | 2026-09-05 | conditional on gap G1 closing before release |
| Customer representative | <name> | approved | 2026-09-05 | dissent on scope of partial refunds, recorded |

## Contents

| Artifact | Version | Location |
|----------|---------|----------|
| Requirements | SRS-booking v2.0 | `docs/specs/srs-booking.md` |
| Quality scenarios | v1.3 | `docs/architecture/quality-attributes-booking.md` |
| API contract | booking-v1.3.0 | `openapi/booking-v1.yaml` |
| Event contract | booking-events-v1.1.0 | `asyncapi/booking-events-v1.yaml` |
| State machine | v1.2 | `docs/discovery/state-machine-booking.md` |
| Glossary | v1.4 | `docs/discovery/glossary-ordering.md` |
| Acceptance tests | v2.0 | `docs/specs/acceptance-*.md` |
| Traceability matrix | generated 2026-09-05 | `docs/specs/traceability-booking.md` |

## Scope

**In**: cancellation self-service, refund initiation, audit logging, EU 261 compensation calculation
**Out (explicitly)**: partial refunds, group changes, offline agent tooling — see `prioritization` "Won't this time"

## Known gaps and open items

| # | Gap | Impact | Owner | Due | Blocks release? |
|---|-----|--------|-------|-----|-----------------|
| G1 | EU 261 Art. 5(3) extraordinary circumstances not covered | compliance | <name> | 2026-09-20 | **yes** |
| G2 | QA-9 accessibility: 1 serious axe violation | usability, legal | <name> | 2026-09-18 | yes |

## Assumptions carried

| # | Assumption | Owner | Validated | Risk if wrong |
|---|------------|-------|-----------|---------------|
| A2 | Carrier API sustains 300 rps at peak | <name> | load test 2026-08-30 ✅ | high |
| A6 | Partner X accepts a 30-day notice period | <name> | not validated ⚠️ | medium |

## Traceability summary

| Check | Total | Passing | Exceptions |
|-------|-------|---------|------------|
| Requirements with verification | 84 | 84 | — |
| Requirements with passing evidence | 84 | 79 | 4 planned R3, QA-9 open |
| Regulatory clauses covered | 12 | 11 | Art. 5(3) → G1 |

## Change control from here

All changes to this baseline require a change request (`change-management`). Threshold: PO decides below 5 points; CCB above.
````

### 7.2 Baseline comparison

````markdown
# Baseline comparison — BL-BOOKING-2026-06 → BL-BOOKING-2026-09

| Change | Item | CR | Driver | Type |
|--------|------|----|--------|------|
| added | REQ-041 audit log retention 10 years | CR-12 | regulatory | scope |
| changed | REQ-014 confirmation window 5 s → 2 s | CR-15 | performance data | tightening |
| changed | REQ-018 cancellation window 24 h → 48 h | CR-17 | market | scope |
| removed | REQ-029 SMS notification | CR-14 | cost | descope |
| clarified | REQ-032 "30 days" → "30 calendar days from invoice date" | CR-15 | review defect | clarification |

## Summary

| Metric | Value |
|--------|-------|
| Requirements added / changed / removed | 4 / 7 / 2 |
| Volatility (changed ÷ baselined) | 13 % — above the 10 % trigger |
| Changes by driver | regulatory 2 · market 3 · defect 4 · cost 2 · **missing failure-path analysis 2** |
| Contract-affecting changes | 1 (Partner X notified 2026-08-20) |

**Action**: volatility above trigger — add obstacle analysis to refinement (see `change-management` metrics).
````

---

## 8. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Baselining a draft to hit a milestone date | Immediate change requests; the baseline means nothing | Entry criteria before approval |
| Editing an approved baseline | Nobody knows what was agreed | Immutable; corrections create a new baseline |
| "final_v3_approved_REALLY.docx" | Version chaos, unprovable history | Stable ids in version control with tags |
| Referencing artifacts as "latest" | The snapshot is not a snapshot | Pin every version |
| Hiding known gaps to get approval | Trust destroyed when they surface | List gaps with owners, dates, and release-blocking status |
| Approval by silence | No real accountability | Named approvers, recorded decisions, recorded dissent |
| Baselining the whole backlog in an agile team | Learning becomes paperwork | Baseline commitments only; partial baselines |
| No comparison between consecutive baselines | Scope drift invisible | Diff every baseline; track volatility |
| Assumptions not carried into the baseline | Contract disputes about who was responsible | Assumptions section with owners and validation status |
| Baseline stored where only one team can reach it | Unusable as evidence | Storage and retention defined by the audience |
| No change control after baselining | The baseline diverges from reality within weeks | Change control starts at approval |

---

## 9. Checklist

- [ ] Purpose of the baseline stated, with the audience it must satisfy
- [ ] Entry criteria met: reviewed, conflicts resolved, feasibility assessed, traceability complete
- [ ] Every requirement carries a rationale, a source, and a verification method
- [ ] Contents listed by artifact **and pinned version**
- [ ] Scope stated, including what is explicitly out
- [ ] Known gaps listed with owners, dates, and release-blocking status
- [ ] Assumptions carried forward with validation status
- [ ] Traceability summary included with named exceptions
- [ ] Approvers named with roles, decisions, dates, and any dissent
- [ ] Stable identifier assigned; no "final" in the name
- [ ] Stored immutably with a commit id or content hash
- [ ] Retention period defined and the storage location accessible to the audience
- [ ] Previous baseline superseded, not deleted; comparison produced
- [ ] Volatility measured and acted on
- [ ] Change control effective from the moment of approval
