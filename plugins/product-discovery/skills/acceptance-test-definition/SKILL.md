---
description: Acceptance test definition (ATDD) — agree the tests that prove a requirement before implementation starts. Covers the ATDD cycle, deriving test cases from rules with equivalence partitioning and boundary analysis, decision tables and state-transition coverage, test data strategy, the automation pyramid and layer selection, acceptance criteria for non-functional requirements, entry into the Definition of Done, and Markdown templates for an acceptance test plan and a coverage matrix.
---

# Acceptance test definition (ATDD)

Goal of this skill: define **how a requirement will be proven, before it is built** — so that "done" is a fact, not a negotiation, and so the act of designing the tests exposes the gaps in the requirement while they are still cheap.

Use this skill as the last step of refinement for every story, in the `three-amigos` conversation, and for any requirement that will be formally accepted by a customer, an auditor, or a supplier contract.

Do **not** confuse this with writing test scripts. ATDD is about agreeing the *set of checks that would convince all three parties*; `gherkin-bdd` is one notation for expressing them, and automation is a later decision.

---

## 1. The ATDD cycle

1. **Discuss** — business, development, and testing agree the rules and examples (`three-amigos`, `example-mapping`).
2. **Distil** — turn the examples into a concrete, agreed set of acceptance tests with expected results and test data.
3. **Develop** — implement, with the failing acceptance tests as the target.
4. **Demo** — show the passing tests as the evidence of completion.

The value sits in step 2: writing the expected result forces every ambiguity to the surface. Most of the "requirements defects" a team finds during ATDD are found while designing the tests, not while running them.

**Test definition precedes implementation.** Tests written after the code test what was built, not what was wanted.

---

## 2. Deriving test cases systematically

Do not improvise the cases. Apply the techniques in order and record which you used.

| Technique | Use for | Produces |
|-----------|---------|----------|
| **Equivalence partitioning** | Any input with ranges or classes | One case per class — valid and invalid |
| **Boundary value analysis** | Every threshold | Below, exactly at, above — the highest defect yield per test written |
| **Decision table** | Several conditions combining into different outcomes | One case per rule column; exposes undefined combinations |
| **State transition testing** | Anything with a lifecycle (`state-machines`) | Legal transitions, illegal transitions, idempotent repeats |
| **Pairwise / combinatorial** | Many independent parameters | Compact coverage of interactions without a full cross-product |
| **Error guessing / exploratory charter** | Experience-driven | The cases the systematic techniques miss |
| **Use case extension coverage** | Flows with alternatives (`use-case-modeling`) | One case per extension |

Rules: every threshold gets three cases; every external dependency gets a failure case; every state model gets at least one illegal-transition case; every rule in the decision table gets one case, including the "cannot happen" columns, which are where undefined behaviour hides.

---

## 3. Acceptance criteria for non-functional requirements

Functional acceptance is the easy half. A story is not done if it is correct and unusably slow.

| Type | Acceptance form | Where it runs |
|------|-----------------|---------------|
| **Performance** | p95/p99 threshold at a stated load and measurement point | load test in CI or a staged run |
| **Accessibility** | Automated scan with zero serious violations, plus a keyboard-only walkthrough of the flow | CI + manual check |
| **Security** | Authorisation matrix per role; negative tests for each denied case; no sensitive data in logs | automated tests + review |
| **Reliability** | Behaviour under a simulated dependency failure | fault injection test |
| **Data protection** | Retention and erasure behaviour demonstrated | integration test |
| **Observability** | Required events, metrics, and correlation ids present | assertion on telemetry |

Attach the relevant ones to each story rather than deferring them to a later "hardening" phase — deferred non-functional acceptance is how systems become unshippable.

---

## 4. Choosing the automation layer

| Layer | Use for | Cost | Rule |
|-------|---------|------|------|
| **Unit** | Calculations, rules, edge-case explosion | lowest | Push case volume down here |
| **Integration / service** | Business rules across components, contracts, persistence | medium | **Default layer for acceptance tests** |
| **Contract** | Interface expectations between teams (`api-contracts`) | low | One per consumer expectation |
| **UI / end-to-end** | Rules that genuinely are about the interface, plus one smoke path per critical journey | highest | Keep the count small and deliberate |
| **Manual / exploratory** | Judgement, aesthetics, novel risk | varies | Charter-driven, time-boxed, recorded |

Cover a rule **once at the cheapest layer that proves it**, then let higher layers prove the wiring rather than re-testing the rule. Twenty UI tests exercising the same calculation is a slow suite, not thorough testing.

---

## 5. Test data

Decide this consciously; it is the most common cause of flaky acceptance suites.

| Question | Good answer |
|----------|-------------|
| Where does the data come from? | Created by the test through the API or a factory — not a shared seeded database |
| Is it isolated? | Each test creates and cleans up its own; tests run in any order and in parallel |
| Is it realistic? | Real formats, real lengths, real character sets, worst-case values |
| Is production data used? | Only anonymised or synthetic; never raw personal data in a test environment |
| How is time handled? | Injected clock; no `now()` in assertions; no tests that fail on 31 December |
| How is randomness handled? | Fixed seed, or property-based with a recorded failing seed |

---

## 6. Intake — ask before defining tests

Ask only what is missing; batch into one message, five or fewer.

1. **Which requirement or story**, and what are its agreed rules and examples?
2. **What proves it to the business** — what would they want to see demonstrated?
3. **Which non-functional constraints apply** to this story specifically?
4. **What test data and environments are available**, and what is off-limits (production data, live payment provider)?
5. **Who accepts it**, and is the acceptance formal (customer sign-off, audit evidence) or internal?

---

## 7. Output template

Attach to the story; keep formal ones in `docs/specs/acceptance-<requirement>.md`.

````markdown
# Acceptance tests — <STORY-201 / SRS-F-014>

- **Agreed by**: <business>, <development>, <testing> · **Date**: <date>
- **Requirement**: <one-line restatement>
- **Acceptance authority**: product owner | customer sign-off | auditor

## Functional cases

| # | Rule | Case | Technique | Preconditions | Action | Expected result | Layer | Automated | Test id |
|---|------|------|-----------|---------------|--------|-----------------|-------|-----------|---------|
| A1 | free cancellation > 24 h | 25 h before departure | boundary | confirmed booking, paid | cancel | full refund, state `Cancelled` | service | yes | `CancelTest#free` |
| A2 | free cancellation > 24 h | exactly 24 h | **boundary** | as above | cancel | full refund | service | yes | `CancelTest#atBoundary` |
| A3 | fee within 24 h | 23 h 59 m | **boundary** | as above | cancel | 20 % fee | service | yes | `CancelTest#fee` |
| A4 | idempotency | cancel twice | state transition | already `Cancelled` | cancel | no second refund, 409 | service | yes | `CancelTest#idempotent` |
| A5 | illegal transition | cancel a completed booking | state transition | state `Completed` | cancel | rejected 409, state unchanged | service | yes | `CancelTest#illegal` |
| A6 | provider failure | payment provider 503 | error guessing | provider stubbed to fail | cancel | booking cancelled, refund `Pending`, retry queued | service | yes | `CancelTest#providerDown` |

## Decision table

| Condition | R1 | R2 | R3 | R4 |
|-----------|----|----|----|----|
| Departure > 24 h | Y | N | Y | N |
| Booking state `Confirmed` | Y | Y | N | N |
| **Outcome: full refund** | ✔ | | | |
| **Outcome: refund minus 20 % fee** | | ✔ | | |
| **Outcome: rejected 409** | | | ✔ | ✔ |

## Non-functional acceptance

| # | Type | Criterion | How verified | Blocking |
|---|------|-----------|--------------|----------|
| N1 | performance | cancellation quote p95 ≤ 500 ms at 40 rps | load test `LT-7` | yes |
| N2 | accessibility | flow keyboard-operable; axe scan: 0 serious | CI scan + manual walkthrough | yes |
| N3 | security | an agent may cancel only with a recorded reason; customer cannot cancel another customer's booking | negative authz tests | yes |
| N4 | observability | `BookingCancelled` emitted with correlation id | telemetry assertion | yes |

## Test data

| Need | Source | Isolation | Notes |
|------|--------|-----------|-------|
| Confirmed booking | created via API in the test fixture | per test, cleaned up | clock injected; departure set relative to the injected now |

## Coverage of the requirement

| Rule / extension | Covered by | Gap |
|------------------|-----------|-----|
| UC-12 main flow | A1 | — |
| UC-12 ext. 2a (fee) | A3 | — |
| UC-12 ext. 7a (provider down) | A6 | — |
| UC-12 ext. 5a (quote expiry) | — | **gap — add A7** |

## Out of scope for this story

- Partial refunds (STORY-202), manual finance correction path (STORY-203)
````

---

## 8. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Tests written after the implementation | They test what was built, not what was wanted | Define before development starts |
| Only happy-path acceptance | Errors and edge cases become production defects | Systematic derivation with boundaries and failures |
| No boundary cases | Off-by-one defects ship reliably | Below / at / above every threshold |
| Everything automated through the UI | Slow, flaky, expensive suite | Cheapest layer that proves the rule |
| Non-functional acceptance deferred to "hardening" | Unshippable systems late in the project | Attach the relevant constraints to each story |
| Shared seeded test database | Order-dependent, flaky, unparallelisable tests | Tests create and clean their own data |
| Real clock and real externals in acceptance tests | Random failures, time-bomb tests | Inject time; stub externals; separate contract tests |
| "Done" decided by demo impression | Disagreement at the end of the sprint | Passing agreed tests is the definition of done |
| Business not involved in defining the tests | Tests prove the developer's understanding | All three amigos agree the set |
| Coverage measured only as a percentage of code | Rules can be uncovered while coverage looks fine | Map cases to rules and extensions |

---

## 9. Checklist

- [ ] Tests defined and agreed before implementation starts
- [ ] All three perspectives agreed the set
- [ ] Derivation techniques applied and recorded (partitions, boundaries, decision table, state transitions)
- [ ] Three cases at every threshold
- [ ] Illegal and repeated (idempotency) cases included for anything with a lifecycle
- [ ] A failure case for every external dependency
- [ ] Decision table complete, including combinations declared impossible
- [ ] Applicable non-functional criteria attached and marked blocking
- [ ] Automation layer chosen per case, with UI kept deliberate and small
- [ ] Test data self-created, isolated, realistic, and parallel-safe
- [ ] Time and randomness injected
- [ ] Cases mapped back to rules and use case extensions; gaps listed explicitly
- [ ] Out-of-scope behaviour stated so acceptance is not ambiguous
- [ ] Passing the agreed tests is what the Definition of Done points at
