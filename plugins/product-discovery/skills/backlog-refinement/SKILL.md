---
description: Backlog refinement and the Definition of Ready and Done — keeping requirements actionable in agile delivery. Covers the refinement funnel and horizons, cadence and timeboxing, what happens in a refinement session, sizing approaches, writing a DoR/DoD that is a checklist rather than a wish list, refinement health metrics, backlog hygiene and pruning, and Markdown templates for the DoR/DoD and a refinement session record.
---

# Backlog refinement, Definition of Ready and Definition of Done

Goal of this skill: keep a continuously flowing supply of items that are **understood, sized, and unblocked** just before they are needed — without over-refining work that will change before it is built.

Use this skill for any team running an iterative or flow-based delivery, when planning meetings turn into analysis sessions, when stories stall mid-iteration, or when "done" is renegotiated at every review.

Do **not** use it to write the requirements themselves — refinement is where `example-mapping`, `three-amigos`, and `acceptance-test-definition` happen; this skill is about the *rhythm* and the *gates*.

---

## 1. The refinement funnel

Refinement is progressive: detail is added as an item approaches implementation, and no earlier.

| Horizon | Item size | Detail level | Effort spent |
|---------|-----------|--------------|--------------|
| **Now** (this iteration) | Small stories | Acceptance criteria agreed, tests defined, sized, unblocked | High |
| **Next** (1–2 iterations out) | Stories | Rules known, examples drafted, open questions being answered | Medium |
| **Later** (a quarter out) | Epics / features | Outcome and rough shape known, coarse size | Low |
| **Someday** | Ideas | One line, traced to a goal or discarded | Almost none |

Healthy inventory: **1.5–2 iterations of ready items**. Less, and planning becomes analysis under time pressure. More, and you are polishing work that will be reprioritised or invalidated.

The most common failure is uniform detail: either everything is a one-liner (planning collapses) or everything is fully specified (waste when priorities shift).

---

## 2. Cadence and format

| Practice | Recommendation |
|----------|----------------|
| Frequency | Short and frequent — 30–60 minutes, twice a week — beats a single long session |
| Time budget | Roughly 5–10 % of the team's capacity |
| Attendance | Whole team, or a rotating subset plus the three amigos for the items being refined |
| Preparation | The product owner brings ordered candidates; nobody refines an unordered pile |
| Focus | Items entering the *Next* horizon; occasional coarse sizing of *Later* items |
| Output | Every item leaves with a state: ready · needs work (with an owner) · blocked · split · dropped |

**Session flow** for each item: read it aloud → confirm the outcome it serves → surface rules and examples (`example-mapping`) → identify open questions and assign them → check dependencies → size → apply the Definition of Ready → decide the state. Timebox each item; if it needs more than about 20 minutes, it is too big or too unclear, and that is the finding.

---

## 3. Sizing

| Approach | Use when |
|----------|----------|
| **Relative points (planning poker)** | The team wants a shared complexity conversation; keep the discussion, not the number |
| **T-shirt sizes** | Coarse sizing of epics on the *Later* horizon |
| **Right-sizing / "fits in a few days?"** | Flow-based teams — the only question that matters is whether it is small enough |
| **Magic / affinity estimation** | Sizing a large backlog quickly, silently, in relative order |
| **#NoEstimates / count of items** | Stable item sizes and reliable historic throughput |

The value of sizing is the disagreement it surfaces: when two people give wildly different numbers, they are describing different solutions. Chase that, not the average. Never convert points into hours, and never compare velocity across teams.

---

## 4. Definition of Ready — a gate, not a wish list

Keep it short enough to be applied honestly, and treat it as a *pull* criterion rather than a bureaucratic gate that blocks learning.

| Criterion | Test |
|-----------|------|
| Value is clear | The team can state who benefits and what changes for them |
| Traces to an outcome | Linked to a goal, impact, or obligation |
| Acceptance criteria written | Objective, boundary cases covered |
| Examples agreed | From `example-mapping` / `three-amigos` |
| Non-functional constraints identified | Performance, accessibility, security, observability that apply to *this* item |
| Dependencies known | External work identified and either done or scheduled |
| No blocking open questions | Non-blocking questions may remain, with owners |
| Sized | Small enough to finish inside one iteration |
| Design available | Where the item needs UI, the states are specified (`prototyping`) |
| Test data and environment available | Verification is actually possible |

Caution: a DoR that requires perfect information reproduces waterfall inside the sprint. It should require *enough* to start with confidence, not everything.

---

## 5. Definition of Done — the release-quality gate

One DoD for the team, applied to every item, with any exception recorded explicitly.

| Criterion | Note |
|-----------|------|
| Acceptance criteria demonstrably met | Passing agreed tests (`acceptance-test-definition`) |
| Automated tests written and passing at the agreed layers | Unit, service, contract as applicable |
| Non-functional criteria checked | Performance, accessibility, security, observability |
| Code reviewed and merged | |
| Documentation and contracts updated | Including `api-contracts` and the glossary if terms changed |
| Deployed to the agreed environment | Production or the agreed stage |
| Feature flag / rollout state defined | |
| Telemetry in place | You can tell whether it works in production |
| No known defects knowingly deferred without a ticket | |
| Traceability links updated | (`traceability`) |

**"Done" means releasable.** A separate "done-done" category is a sign the DoD is not honest; fix the DoD instead.

---

## 6. Backlog hygiene

| Practice | Why |
|----------|-----|
| Prune ruthlessly — delete items older than a chosen age that nobody has pulled | A 900-item backlog is an archive, not a plan |
| Keep only the *Now* and *Next* horizons detailed | Detail on unprioritised items is waste |
| One ordered list, not parallel private lists | Shadow backlogs destroy prioritisation |
| Merge duplicates on sight | |
| Re-check items that have waited a long time | The context may have changed entirely |
| Record "won't do" decisions with a reason | Prevents re-litigation (`prioritization`) |

**Refinement health metrics**: ready inventory in iterations · percentage of items pulled that met the DoR · percentage of items carried over · number of items blocked mid-iteration · average time from "created" to "ready". Rising carry-over and mid-iteration blocking almost always mean insufficient refinement, not insufficient effort.

---

## 7. Intake — ask before designing the practice

Ask only what is missing; batch into one message, five or fewer.

1. **What is going wrong today** — planning too long, stories stalling, "done" disputed, or nothing ready?
2. **What is the delivery rhythm** — iterations or continuous flow, and how long?
3. **Who is involved**, and is a product owner or equivalent available regularly?
4. **What do the current DoR and DoD say**, if they exist, and are they actually applied?
5. **What does the backlog look like** — size, age, ordering, and duplication?

---

## 8. Output template

Keep in the team's working agreements, visible in the tooling.

````markdown
# Refinement working agreement — <team>

- **Cadence**: Tue + Thu, 45 min · **Attendance**: whole team; PO brings ordered candidates
- **Target ready inventory**: 1.5–2 iterations
- **Timebox per item**: 20 min; exceeding it means "too big or too unclear" → split or park

## Definition of Ready

- [ ] Value and beneficiary stated
- [ ] Traces to a goal or obligation
- [ ] Acceptance criteria written and objective, boundaries covered
- [ ] Examples agreed with the three amigos
- [ ] Applicable non-functional constraints identified
- [ ] Dependencies identified and scheduled
- [ ] No blocking open questions
- [ ] Sized and finishable within one iteration
- [ ] UI states specified where the item touches the interface
- [ ] Test data and environment available

## Definition of Done

- [ ] Agreed acceptance tests pass
- [ ] Automated tests at the agreed layers, passing in CI
- [ ] Non-functional criteria verified (performance, accessibility, security, observability)
- [ ] Code reviewed and merged
- [ ] Contracts, documentation, and glossary updated
- [ ] Deployed to <environment>
- [ ] Telemetry in place and verified
- [ ] Traceability links updated
- [ ] No knowingly deferred defects without a ticket

**Exceptions**: recorded on the item with a reason and an owner. There is no "done-done".

## Session record — <date>

| Item | State after | Size | Open questions (owner, due) | Notes |
|------|-------------|------|-----------------------------|-------|
| STORY-201 | ready | M | — | boundary examples agreed |
| STORY-202 | needs work | ? | Q1 fare policy for partial refunds (<name>, <date>) | blocked on policy |
| STORY-215 | split | — | — | split into 215a (API) and 215b (UI) |
| EPIC-14 | coarse-sized | L | — | revisit next quarter |

## Health metrics — <period>

| Metric | Value | Trend | Action |
|--------|-------|-------|--------|
| Ready inventory | 1.2 iterations | ↓ | add one refinement session per week |
| Items pulled that met the DoR | 78 % | ↓ | enforce the DoR at pull time |
| Carry-over | 22 % | ↑ | items too large — tighten right-sizing |
| Blocked mid-iteration | 4 | ↑ | dependency check missing in refinement |
| Backlog size / oldest item | 240 / 14 months | — | prune items untouched for 6 months |
````

---

## 9. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Refinement only during planning | Planning becomes analysis under time pressure | Continuous refinement ahead of the iteration |
| Refining everything to the same depth | Waste on items that will change | Progressive detail by horizon |
| DoR requiring perfect information | Waterfall inside the sprint | Require enough to start with confidence |
| DoR used to reject work rather than to prepare it | Adversarial dynamics between PO and team | Shared gate, applied together |
| DoD that omits non-functional checks | "Done" work that cannot ship | Include performance, accessibility, security, observability |
| "Done" and "done-done" | The DoD is not honest | Fix the DoD |
| Backlog of 900 items | Nobody can find or trust anything | Prune by age; keep the ordered top detailed |
| Estimating to justify a deadline | Numbers become negotiation, not information | Size to expose disagreement, not to commit |
| Converting points to hours; comparing velocity across teams | Metrics gamed, trust destroyed | Use throughput and cycle time for forecasting |
| Refinement without the tester | Edge cases arrive during the build | Three amigos in refinement |
| Items pulled that never met the DoR, repeatedly | Predictable mid-iteration blocking | Track and act on the DoR-compliance metric |

---

## 10. Checklist

- [ ] Refinement runs on a regular cadence, short and frequent
- [ ] Product owner brings an ordered candidate list
- [ ] Detail applied progressively by horizon, not uniformly
- [ ] Ready inventory kept near 1.5–2 iterations and measured
- [ ] Each item leaves the session with a state and, where needed, an owner and a date
- [ ] Timebox per item enforced; exceeding it triggers a split
- [ ] Three amigos present for items being made ready
- [ ] Dependencies checked before an item is called ready
- [ ] DoR short, applied honestly, and requiring enough rather than everything
- [ ] DoD includes non-functional criteria, telemetry, docs, and traceability
- [ ] "Done" means releasable; exceptions recorded per item
- [ ] Backlog pruned by age; duplicates merged; "won't do" recorded with reasons
- [ ] Health metrics tracked and acted on
