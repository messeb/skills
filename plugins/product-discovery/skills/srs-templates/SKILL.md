---
description: Formal software requirements specifications — Volere, IEEE 830, and ISO/IEC/IEEE 29148:2018. Covers when a formal SRS is justified, the structure of each template, the Volere shell and fit criterion, 29148 quality characteristics and required clauses, tailoring and traceability obligations, review and approval, and a Markdown SRS skeleton plus a requirement shell template.
---

# Volere, IEEE 830, and ISO/IEC/IEEE 29148

Goal of this skill: produce a **formal, complete, reviewable specification** when the situation genuinely demands one — a contract, a regulator, a certification body, a supplier handover, or a system whose failure is expensive.

Use this skill for fixed-price or public-tender contracts, regulated and safety-relevant systems, outsourced development, certification evidence, and long-lived systems where the specification must outlive the team.

Do **not** produce an SRS for ordinary agile product work. A 120-page document that is obsolete on delivery is worse than a story map plus scenarios. If nobody will read it cover to cover and nobody is contractually bound by it, do not write it.

---

## 1. Choosing a template

| Template | Status | Strength | Weakness | Choose when |
|----------|--------|----------|----------|-------------|
| **IEEE 830-1998** | Withdrawn, superseded by 29148 — still widely referenced | Familiar structure, simple | Superseded; weak on process and traceability | A client explicitly asks for "an IEEE 830 SRS" |
| **ISO/IEC/IEEE 29148:2018** | Current standard | Covers stakeholder needs (StRS), system (SyRS), and software (SRS); defines quality characteristics and process | Heavier; needs tailoring | Regulated, contractual, or certification work — the default formal choice |
| **Volere** (Robertson) | Method + template, widely used commercially | The requirement **shell** with a **fit criterion**; strong on non-functional coverage; practical | Not a standard body's document | You want rigour without full standards conformance |

They compose: use the **29148 document structure** with **Volere shells** for individual requirements.

---

## 2. ISO/IEC/IEEE 29148 essentials

**Three document types:**

| Document | Scope | Audience |
|----------|-------|----------|
| **StRS** — Stakeholder Requirements Specification | What stakeholders need, in their terms | Business, users |
| **SyRS** — System Requirements Specification | What the whole system (hardware, software, people, process) must do | Systems engineering |
| **SRS** — Software Requirements Specification | What the software must do | Development, test, suppliers |

**Requirement quality characteristics** (each requirement): necessary · appropriate · unambiguous · complete · singular · feasible · verifiable · correct · conforming.

**Requirement set characteristics**: complete · consistent · feasible · comprehensible · able to be validated.

**Required content of an SRS** (tailorable, but justify every omission): purpose and scope · product perspective, functions, users, constraints, assumptions · specific requirements (functional, interfaces, usability, performance, logical database, design constraints, software system attributes) · verification method per requirement · supporting information and traceability.

**Traceability is mandatory** in 29148: every requirement traces backwards to a stakeholder need and forwards to design and verification (`traceability`).

---

## 3. The Volere requirement shell

Volere's most valuable idea is that every single requirement is a small record with a **fit criterion** — the quantification that makes it testable.

| Field | Content |
|-------|---------|
| Requirement # | Unique, stable identifier |
| Requirement type | Functional / look and feel / usability / performance / operational / maintainability / security / cultural / legal |
| Event / use case # | What it belongs to |
| Description | One sentence, in a controlled template (`requirement-templates`) |
| Rationale | Why it exists — the field that lets you delete it later |
| Originator | Who asked for it |
| **Fit criterion** | The measurable test of satisfaction |
| Customer satisfaction / dissatisfaction | 1–5 each — reveals which requirements actually matter |
| Priority | MoSCoW or ranked (`prioritization`) |
| Conflicts | Requirement numbers it conflicts with (`risk-conflict-analysis`) |
| Supporting materials | Links to models, scenarios, regulations |
| History | Created, changed, approved — with dates |

The **fit criterion** is the discipline: *"the system shall be easy to learn"* becomes *"a new agent completes their first claim registration unaided within 15 minutes, in 8 of 10 trials"*. If you cannot write the fit criterion, you do not have a requirement yet.

---

## 4. Intake — ask before writing

Ask only what is missing; batch into one message, five or fewer.

1. **Why is a formal SRS needed** — contract, regulator, certification, supplier handover? Who is contractually bound by it?
2. **Which template is required** by the client, the regulator, or the tender?
3. **What is the system boundary**, and which parts are software, hardware, and manual process?
4. **What is already documented** — models, goal trees, quality scenarios, an existing system?
5. **Who approves it**, by when, and what is the change process after approval (`change-management`, `baselining`)?

If nobody can name who is bound by the document, propose the lighter path (story map + scenarios + quality attributes) and say what it would cost to formalise later.

---

## 5. Practical tailoring

- **Tailor and record it.** 29148 expects tailoring; write a short clause stating which sections are omitted and why. Silent omission is a finding in an audit.
- **Do not duplicate the models.** Reference `data-model-*.md`, `state-machine-*.md`, `process-*.md`, `c4-*.md` rather than redrawing them in the document. Duplication guarantees divergence.
- **One requirement per identifier, never reused.** When a requirement is deleted, mark it deleted; never recycle the number.
- **Separate constraints from requirements.** Constraints are given; requirements are decided.
- **Assumptions and dependencies get their own section**, each with an owner and a validation date (`risk-conflict-analysis`).
- **Verification method per requirement**: inspection, analysis, demonstration, or test. A requirement with no verification method is not conforming.
- **Baseline and version it** (`baselining`); after approval, every change goes through change control.

---

## 6. Output template

Write to `docs/specs/srs-<system>.md`.

````markdown
# Software Requirements Specification — <System>

| | |
|---|---|
| Document id / version | SRS-<system>-1.0 |
| Status | draft / in review / approved / baselined |
| Standard | ISO/IEC/IEEE 29148:2018, tailored (see §1.5) |
| Author / owner | <name> |
| Approvers | <name (role)>, <name (role)> |
| Date | <YYYY-MM-DD> |
| Baseline | <baseline id> |

## 1. Introduction

1.1 **Purpose** — what this document specifies and for whom.
1.2 **Scope** — the software product, what it does, what it explicitly does not do.
1.3 **Definitions** — reference `glossary-<context>.md`; do not restate.
1.4 **References** — regulations, standards, contracts, models, with versions and dates.
1.5 **Tailoring** — sections of 29148 omitted, and the justification for each.

## 2. Overall description

2.1 **Product perspective** — context in the system landscape; reference `c4-<system>.md` level 1.
2.2 **Product functions** — summary list, referencing the use cases.
2.3 **User characteristics** — roles, expertise, accessibility needs; reference personas.
2.4 **Constraints** — legal, technical, organisational (given, not derived).
2.5 **Assumptions and dependencies** — each with an owner and a validation status.
2.6 **Apportioning of requirements** — what is deferred to a later release.

## 3. Specific requirements

### 3.1 Functional requirements

| ID | Requirement | Type | Rationale | Fit criterion | Source | Priority | Verification | Traces to | Status |
|----|-------------|------|-----------|---------------|--------|----------|--------------|-----------|--------|
| SRS-F-014 | When a payment confirmation is received, the Booking Service shall set the booking to `Confirmed` within 2 seconds. | functional | Customers abandon on delay | p95 ≤ 2 s over 1,000 confirmations under nominal load | StRS-7, QA-2 | must | test `LT-4` | UC-12 step 6, `state-machine-booking.md` | approved |

### 3.2 External interface requirements

| ID | Interface | Party | Contract | Protocol | Error behaviour | Verification |
|----|-----------|-------|----------|----------|-----------------|--------------|
| SRS-I-003 | Payment authorisation | Payment Provider | `openapi/payment-v2.yaml` | REST/HTTPS + webhook | see SRS-F-015 | contract test |

### 3.3 Quality and performance requirements

Reference `quality-attributes-<system>.md`; each scenario appears here with its identifier and fit criterion.

| ID | Scenario | Response measure | Verification |
|----|----------|------------------|--------------|
| SRS-Q-001 | QA-1 Search under peak load | p95 ≤ 800 ms, p99 ≤ 2 s at 5,000 concurrent | load test LT-4, weekly |

### 3.4 Design constraints

| ID | Constraint | Source | Rationale |
|----|-----------|--------|-----------|
| SRS-C-002 | Personal data processed and stored only in EU regions | GDPR, company policy | legal |

### 3.5 Logical database requirements

Reference `data-model-<context>.md`; state retention, historisation, and erasure obligations here.

## 4. Verification

| Requirement class | Method | Evidence produced | Owner |
|-------------------|--------|-------------------|-------|
| Functional | test | automated scenario report | QA |
| Constraint | inspection | architecture review record | Architect |

## 5. Traceability

Reference `traceability-<system>.md`. Summary coverage:

| From | To | Coverage |
|------|----|----------|
| Stakeholder needs → requirements | StRS → SRS | 100 % (0 orphans) |
| Requirements → verification | SRS → tests | 96 % (SRS-F-031, SRS-F-032 open) |

## 6. Supporting information

Models, prototypes, regulatory citations, decision records.

## 7. Change history

| Version | Date | Change | Change request | Approved by |
|---------|------|--------|----------------|-------------|
````

### Volere shell (per requirement, when full shells are used)

````markdown
| Field | Value |
|-------|-------|
| # | SRS-F-014 |
| Type | functional |
| Event / use case | UC-12 Cancel a booking |
| Description | When a payment confirmation is received, the Booking Service shall set the booking to `Confirmed`. |
| Rationale | A customer who has paid must see an immediate confirmation, or support contacts spike |
| Originator | <name>, Commercial |
| Fit criterion | p95 ≤ 2 s measured at the API boundary over 1,000 confirmations at nominal load |
| Customer satisfaction | 4 · **dissatisfaction** | 5 |
| Priority | must |
| Conflicts | SRS-F-022 (synchronous fraud check) — resolved by C2 |
| Supporting materials | `state-machine-booking.md`, QA-2 |
| History | created <date>, approved <date>, changed by CR-17 <date> |
````

---

## 7. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Writing an SRS because "the process says so" | Expensive document nobody reads | Formalise only what someone is bound by |
| Requirements without fit criteria | Unverifiable; disputes at acceptance | Fit criterion on every requirement |
| Redrawing models inside the SRS | Divergence between document and model | Reference the model files |
| Reusing deleted requirement numbers | Traceability corruption | Mark deleted; never recycle |
| Constraints mixed into requirements | Effort spent "deciding" what is fixed | Separate section |
| Assumptions undocumented | Contract disputes about who was responsible | Assumptions section with owners and dates |
| No verification method per requirement | Non-conforming to 29148; unprovable | Inspection / analysis / demonstration / test |
| Silent tailoring | Audit finding | Tailoring clause with justification |
| Approved but not baselined | Uncontrolled drift | Baseline and change control after approval |
| A 200-page SRS for a 3-month product | Obsolete on delivery | Story map, scenarios, quality attributes |

---

## 8. Checklist

- [ ] Justification recorded for why a formal SRS is needed and who is bound by it
- [ ] Template chosen and named; tailoring clause written with justification
- [ ] Document identifier, version, status, approvers, and baseline recorded
- [ ] Scope states explicitly what is out of scope
- [ ] Glossary referenced, not restated
- [ ] Constraints separated from requirements
- [ ] Assumptions and dependencies listed with owners and validation status
- [ ] Every requirement singular, verifiable, and uniquely identified
- [ ] Fit criterion or response measure on every requirement
- [ ] Rationale and originator recorded per requirement
- [ ] Verification method assigned per requirement
- [ ] Interfaces specified with contract references and error behaviour
- [ ] Quality requirements referenced from the quality attribute scenarios
- [ ] Models referenced rather than duplicated
- [ ] Backward and forward traceability demonstrated with coverage figures
- [ ] Reviewed (`requirements-reviews`), approved, and baselined
