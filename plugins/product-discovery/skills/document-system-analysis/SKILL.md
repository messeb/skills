---
description: Document and system analysis — mine existing specs, regulations, contracts, tickets, logs, databases, and legacy code for requirements. Covers source inventory and trust ranking, regulatory traceability (requirement → clause → test), legacy code archaeology, data and log analysis, contradiction handling, and Markdown templates for the source inventory, requirements register, regulatory traceability matrix, and system findings.
---

# Document and system analysis

Goal of this skill: extract requirements from what already exists — regulation, contracts, specifications, tickets, telemetry, database contents, and running code — so that discovery starts from the real constraints instead of rediscovering them in acceptance testing.

Use this skill in regulated domains (aviation passenger rights, finance, medical, safety), for brownfield replacement projects, when the domain expert has left, when behaviour must be preserved exactly, or before any workshop — so that you walk in already knowing what the documents claim.

Do **not** treat it as a substitute for talking to people. Documents describe the intended process; `contextual-inquiry` shows the actual one. Run both and diff them.

---

## 1. Source types and how far to trust them

| Source | Yields | Trust | Caveat |
|--------|--------|-------|--------|
| **Law / regulation** (e.g. EU 261/2004, GDPR, PSD2, MDR) | Hard, non-negotiable rules | Highest for *what* is required | Needs interpretation; check consolidated versions, amendments, and national implementations |
| **Regulatory guidance / case law** | How the rule is applied in practice | High | Changes over time; date every citation |
| **Contracts and SLAs** | Obligations, penalties, deadlines | High | Often contradicts the product's actual behaviour |
| **Standards** (ISO, EN, internal) | Interfaces, quality attributes | High | Versioned — pin the version |
| **Existing specifications** | Intended behaviour, vocabulary | Medium | Frequently stale; verify against code |
| **Runbooks, SOPs, work instructions** | The official process | Medium | Reality has usually drifted |
| **Support tickets / incident reports** | Real failure modes, real user language | High for pain, low for solutions | Biased to what people complain about |
| **Analytics and telemetry** | What users actually do, at scale | High for behaviour | Cannot explain *why* |
| **Production logs** | Real volumes, real error rates, real edge cases | High | Sampling and retention limits |
| **Database contents** | The de-facto data model, actual value ranges, orphan states | Highest for "what is really true" | Explains what schema and docs cannot |
| **Legacy source code** | Actual implemented behaviour | Highest for *what happens today* | Says nothing about intent |
| **Config, feature flags, cron jobs** | Hidden behaviour, silent business rules | High | Often undocumented entirely |
| **Emails / chat threads / meeting minutes** | Decision history and rationale | Low–medium | Selective, political |

Ranking principle: **code and data say what the system does; documents say what someone once intended; people say what they believe.** All three are needed, and disagreement between them is a finding.

---

## 2. Intake — ask before starting

Ask only what is missing; batch into one message, five or fewer.

1. **What is the analysis for** — replacement, extension, compliance evidence, migration, audit?
2. **Which sources are available and accessible?** Repos, databases (prod or copy?), regulations, contracts, ticket system, log platform — and who grants access?
3. **What is in and out of scope** — which modules, which regulations, which time range of tickets and logs?
4. **What must be preserved exactly**, and what is explicitly allowed to change?
5. **What is the deadline and the deliverable format** — a requirements register, a traceability matrix, an ADR set, a migration plan?

Also confirm: are you allowed to look at production data, and under which anonymisation rules?

---

## 3. Method

### Step 1 — Inventory before reading

List every source with owner, location, version, date, and a trust rating. Estimate reading effort. Do not start reading the biggest document first — start with the one that constrains the most decisions.

### Step 2 — Read with a question list

Never read passively. Enter with the open questions from interviews and workshops, and extract against them. Everything you extract gets an identifier and a citation to the exact location — clause number, file and line, ticket id, query.

### Step 3 — Extract atomic requirements

One requirement per row, traceable to its source. Classify each as:

| Class | Meaning | Handling |
|-------|---------|----------|
| **Mandatory (legal)** | Non-negotiable, externally enforced | Must trace to a test |
| **Contractual** | Owed to a specific counterparty | Must trace to a test; check penalties |
| **Business rule** | Company decision, changeable | Confirm ownership; candidate for simplification |
| **Implemented behaviour** | What the code does now | Decide explicitly: preserve, change, or drop |
| **Accidental behaviour** | A bug or a side effect that users now depend on | Flag loudly — these cause the worst migration surprises |

### Step 4 — Cross-check the sources against each other

For every important rule, check the document, the code, the data, and a human. Record disagreements as findings with a decision owner — do not silently pick one.

### Step 5 — Regulatory traceability

For each regulatory obligation: clause → interpretation → requirement → implementation → test → evidence. Anything without a test is not compliant, it is merely hoped for.

### Step 6 — Feed the next method

Vocabulary → glossary; processes → `domain-storytelling`; contradictions → `stakeholder-interviews`; unknown flows → `event-storming`; ambiguous rules → `example-mapping`.

---

## 4. Legacy code archaeology

When the documentation is gone, the code is the specification.

| Technique | What it reveals |
|-----------|-----------------|
| Follow one real transaction end to end | The true flow, including the surprises |
| Read the tests first | Intended behaviour and known edge cases, cheaper than reading implementation |
| `git log` on the rule-heavy files | Why a rule exists, and which ticket forced it |
| Look for date and threshold constants | Regulatory or contractual limits hard-coded |
| Search for `if` clusters around customer/tenant ids | Undocumented special cases and one-off deals |
| Inspect cron jobs, schedulers, batch scripts | Business processes nobody mentions in workshops |
| Inspect config and feature flags per environment | Behaviour that differs in production |
| Check database constraints, triggers, views | Rules that live in the data layer |
| Query actual value distributions and orphan rows | Which states really occur — usually more than the enum suggests |
| Search error handling and retries | Real failure modes and integration reliability |
| Check dead code and unreachable branches | Rules that were abandoned but never removed |

Distinguish carefully between **intended** rules and **accidental** behaviour that users have come to rely on. Both must be decided on explicitly; only one deserves to be reimplemented.

---

## 5. Data and log analysis

Ask questions the documents cannot answer:

- Which paths are actually used, and how often? (rank features by real usage before rewriting them)
- What is the real volume, peak, and growth?
- Which error occurs most, and what does the user do next?
- Which fields are always empty, always the same, or full of sentinel values like `9999-12-31`?
- Which states exist in the data that the state machine does not allow? (they are the truth about historic bugs)
- What is the actual distribution behind "usually a few items"? Check p50, p95, p99 — the p99 is what will break the design.

Document each finding with the query that produced it, so it can be re-run.

---

## 6. Output templates

### 6.1 Source inventory

````markdown
# Source inventory — <initiative>

| # | Source | Type | Version / date | Owner | Access | Trust | Scope covered | Read status |
|---|--------|------|----------------|-------|--------|-------|---------------|-------------|
| S1 | Regulation (EC) 261/2004, consolidated | law | 2004-02-11, consolidated <date> | legal | public | high | compensation rules | read |
| S2 | `billing-service` repo | code | commit `abc1234` | Team B | granted | high (behaviour) | invoicing | partial |
````

### 6.2 Requirements register

````markdown
# Requirements register — <scope>

| # | Requirement | Class | Source | Citation | Confirmed by | Conflict | Decision |
|---|-------------|-------|--------|----------|--------------|----------|----------|
| R1 | Compensation of €250 for flights ≤1500 km delayed ≥3 h | mandatory (legal) | S1 | Art. 7(1)(a) + Sturgeon C-402/07 | legal <name> | none | implement |
| R2 | Invoices are rounded half-up per line | implemented behaviour | S2 | `Invoice.kt:212` | none | contradicts spec S3 §4 | decide: <owner> |
````

### 6.3 Regulatory traceability matrix

````markdown
# Traceability — <regulation>

| Clause | Obligation | Interpretation (by, date) | Requirement | Implementation | Test | Evidence | Status |
|--------|-----------|---------------------------|-------------|----------------|------|----------|--------|
| Art. 7(1)(a) | €250 compensation | legal, <date> | R1 | `CompensationPolicy` | `CompensationPolicyTest#shortHaul` | test report <link> | covered |
| Art. 5(3) | Extraordinary circumstances exemption | legal, <date> | R4 | — | — | — | **gap** |
````

### 6.4 System findings

````markdown
# System findings — <system>

## Behaviour discovered

| # | Behaviour | Where | Intended or accidental? | Users depend on it? | Decision |
|---|-----------|-------|-------------------------|---------------------|----------|

## Data reality

| # | Question | Query | Finding | Implication |
|---|----------|-------|---------|-------------|
| D1 | How many orders have >10 lines? | `select …` | p99 = 340 lines | pagination and batch limits required |

## Hidden processes

| # | Trigger (cron/flag/script) | What it does | Owner | Documented? |
|---|----------------------------|--------------|-------|-------------|

## Contradictions

| # | Topic | Document says | Code does | Data shows | People say | Decider | Resolution |
|---|-------|---------------|-----------|------------|------------|---------|------------|

## Risks

| Risk | Evidence | Impact | Mitigation | Owner |
|------|----------|--------|------------|-------|

## Open questions for the next method

| Question | Method | Owner |
|----------|--------|-------|
````

---

## 7. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Trusting a specification without checking the code | You reimplement a document, not the system | Cross-check document, code, data, people |
| Reading everything before asking anything | Weeks spent, wrong focus | Enter with a question list; read against it |
| Requirements without citations | Unverifiable, unmaintainable | Clause, file:line, ticket id, query for every row |
| Copying regulation text as a requirement | Untestable, and hides the interpretation | Requirement + explicit interpretation, dated and owned |
| Interpreting law without legal review | Compliance built on a developer's reading | Every interpretation signed off and dated |
| Ignoring accidental behaviour | The migration breaks workflows nobody documented | Flag it and decide explicitly |
| Ignoring config, crons, and feature flags | Whole processes vanish in the rewrite | Inventory them explicitly |
| Averaging over contradictions | The conflict resurfaces at acceptance | Escalate as a decision with an owner |
| Using an outdated regulation version | Compliance gap | Pin version and consolidation date |
| Analysis paralysis | Nothing shipped | Timebox; scope by what constrains the most decisions |

---

## 8. Checklist

- [ ] Purpose and scope of the analysis stated
- [ ] Source inventory complete with version, owner, access, and trust rating
- [ ] Data access permissions and anonymisation rules confirmed
- [ ] Reading driven by an explicit question list
- [ ] Every requirement is atomic, classified, and cited to an exact location
- [ ] Legal/contractual requirements interpreted with named sign-off and date
- [ ] Regulation versions and consolidation dates pinned
- [ ] Code cross-checked against documents for every important rule
- [ ] Database and log findings recorded with re-runnable queries
- [ ] Config, feature flags, cron jobs, and batch scripts inventoried
- [ ] Accidental behaviour flagged and explicitly decided on
- [ ] Contradictions escalated with a decider and a due date
- [ ] Traceability matrix has no clause without a test
- [ ] Open questions routed to the appropriate follow-up method
