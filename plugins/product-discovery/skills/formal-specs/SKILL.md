---
description: Formal specification with TLA+/PlusCal, Alloy, and Z — when mathematical specification pays for itself, what each language is good at, how to pick the abstraction level, writing safety and liveness properties and invariants, refinement, common modelling patterns for concurrency and distributed protocols, and Markdown templates for a specification record and a property catalogue.
---

# Formal specifications — TLA+, Alloy, Z

Goal of this skill: state the intended behaviour of a **concurrent, distributed, or safety-critical design precisely enough that a machine can look for counterexamples** — finding the interleaving nobody imagined, before it reaches production.

Use this skill for distributed protocols and consensus, concurrent state with shared resources, cache and replication coherence, financial and safety invariants that must never be violated, complex permission or state models, and migration or cutover plans where an intermediate state could corrupt data.

Do **not** use it for ordinary CRUD, for UI behaviour, or as documentation for a team that will not maintain it. A formal spec nobody can read is worse than none — it looks authoritative and rots silently.

---

## 1. Choosing the language

| Language | Paradigm | Best at | Tooling | Learning cost |
|----------|----------|---------|---------|---------------|
| **TLA+** (with PlusCal) | State machines over time; temporal logic | Concurrency, distributed protocols, liveness, refinement between abstraction levels | TLC model checker, TLAPS prover, Apalache | High; PlusCal lowers the entry cost |
| **Alloy** | Relational first-order logic; bounded analysis | Structural and relational models — permissions, ownership, schemas, configuration, security policies | Alloy Analyzer, instant counterexamples and visualisation | Medium; fastest feedback loop |
| **Z** | Set theory and predicate logic; schema calculus | Precise data and operation specification, especially in regulated documentation | Type checkers, provers; less automated exploration | High; heavy notation |

Rules of thumb: **behaviour over time → TLA+.** **Structure and relations at a point in time → Alloy.** **A regulator wants a mathematical document → Z (or Alloy/TLA+ with a prose rendering).**

Both TLA+ and Alloy are *bounded* by default: they check exhaustively within a finite state space, so they find bugs but do not prove correctness for all sizes unless you use the proof tooling. That is still enormously valuable — nearly all real defects appear at small bounds.

---

## 2. What formal specification actually buys

| Benefit | Why it matters |
|---------|----------------|
| Counterexample traces | An exact interleaving that violates the property — reproducible, and readable as a sequence of steps |
| Forced precision | Half the value arrives before the checker runs, while writing down what you *thought* the design was |
| Cheap design exploration | Change an assumption, re-check in minutes instead of rebuilding a system |
| Documented invariants | Properties survive as executable design intent |
| Confidence about the impossible | "Two nodes can never both hold the lock" checked, not hoped |

What it does **not** buy: correctness of the implementation. The spec constrains the design; the code can still diverge. Bridge that gap with `model-checking` trace validation, property-based tests derived from the invariants, and runtime assertions.

---

## 3. Method

1. **Pick one question.** "Can a booking be confirmed twice under a retry?" — not "specify the booking system".
2. **Choose the abstraction level.** Model only what the question needs. Timeouts, message loss, and crashes are usually essential; field formats and serialisation are usually noise.
3. **Define the state** — the variables and their type invariant.
4. **Define the actions** — every step the system or environment may take, including failures: crash, restart, duplicate, reorder, lose, delay.
5. **Write the properties**:
   - **Safety** — "nothing bad happens": invariants, mutual exclusion, no double spend, no lost update.
   - **Liveness** — "something good eventually happens": every request is eventually answered — and state the fairness assumptions required, since liveness is meaningless without them.
6. **Check with small bounds first** (2 nodes, 3 messages). Grow only after the small model is clean.
7. **Read every counterexample as a story.** Decide: is it a real design bug, a missing assumption, or a modelling error? All three are findings.
8. **Refine if useful** — an abstract spec plus a more detailed one, with a refinement mapping showing the detailed design implements the abstract one.
9. **Bridge to the implementation** — derive property-based tests and runtime assertions from the invariants; keep the names identical so the link is obvious.

---

## 4. Modelling patterns that repeatedly pay off

| Pattern | Model it as |
|---------|-------------|
| Unreliable network | Actions that duplicate, drop, and reorder messages; never assume delivery |
| Crash and restart | An action that resets volatile state while persistent state survives |
| Retries and idempotency | Let the environment resend any request; assert the outcome is unchanged |
| Timeouts | A non-deterministic action, not a real clock |
| Partial failure | Allow every external call to fail at every point |
| Concurrent updates | Interleave the read-modify-write steps explicitly; this is where lost updates surface |
| Migration / cutover | Model the intermediate state where both old and new paths are live |
| Eventual consistency | Separate the write and the propagation as distinct actions |

---

## 5. Intake — ask before specifying

Ask only what is missing; batch into one message, five or fewer.

1. **What exact question or property** must be checked? What would a violation cost?
2. **What is the design** — components, messages, and persistent state — at the level the question needs?
3. **What can fail** — crash, network loss, duplication, reordering, concurrent actors, clock skew?
4. **Who will maintain the specification**, and does anyone on the team already read TLA+ or Alloy?
5. **What evidence is required** — an internal design check, or an artifact for a certification body?

If nobody will maintain it, say so and propose the cheaper alternatives: a rigorous `state-machines` model with a complete transition matrix, plus property-based and fault-injection tests.

---

## 6. Output template

Store specs in `spec/` beside the code; the record below as `docs/specs/formal-spec-<name>.md`.

````markdown
# Formal specification — <Booking confirmation under retries>

- **Language**: TLA+ (PlusCal) · **Files**: `spec/BookingConfirm.tla`, `spec/BookingConfirm.cfg`
- **Author**: <name> · **Date**: <date> · **Maintainer**: <name>
- **Question**: Can a booking be confirmed twice, or a seat be lost, when payment webhooks are duplicated or reordered and the service can crash mid-transaction?

## Scope and abstraction

| Modelled | Not modelled | Why |
|----------|--------------|-----|
| Booking state, payment webhook delivery, service crash/restart, retry | Field formats, auth, UI, database internals | Irrelevant to the question |

**Assumptions**: webhooks may be duplicated, delayed, and reordered but not corrupted; persistent state survives a crash; at most one payment per booking.

## State

| Variable | Type | Meaning |
|----------|------|---------|
| `state` | `[Bookings -> {"draft","awaiting","confirmed","expired"}]` | Persistent booking state |
| `inbox` | bag of messages | Webhooks in flight |
| `seats` | `Nat` | Remaining capacity |

## Actions

| Action | Precondition | Effect |
|--------|--------------|--------|
| `Submit(b)` | `state[b] = "draft"` | reserve a seat; `state[b] := "awaiting"` |
| `DeliverPaymentOK(b)` | message in `inbox` | `state[b] := "confirmed"` (must be idempotent) |
| `Duplicate(m)` | `m ∈ inbox` | add a copy of `m` |
| `Crash` | always | drop volatile state; keep persistent state |
| `Timeout(b)` | `state[b] = "awaiting"` | release the seat; `state[b] := "expired"` |

## Properties

| # | Property | Type | Statement | Result |
|---|----------|------|-----------|--------|
| P1 | Type invariant | safety | all variables stay within their declared types | ✅ |
| P2 | No seat leak | safety | `seats + Cardinality(Held) = Capacity` always | ❌ → fixed, see F1 |
| P3 | Confirm is idempotent | safety | a duplicated webhook never changes state twice | ✅ |
| P4 | No confirm after expiry | safety | `state[b] = "expired"` never becomes `"confirmed"` | ❌ → fixed, see F2 |
| P5 | Eventual settlement | liveness | every awaiting booking eventually becomes confirmed or expired (weak fairness on `Timeout`) | ✅ |

## Findings

| # | Counterexample (summary) | Root cause | Fix in the design | Now covered by |
|---|--------------------------|-----------|-------------------|----------------|
| F1 | Submit → Crash after reserving, before persisting → seat held forever | Reservation written outside the persistent transaction | Reserve and persist in one transaction; reconciliation job as backstop | `BookingReconciliationTest`, runtime assertion `seatsInvariant` |
| F2 | Timeout fires; delayed webhook arrives → expired booking becomes confirmed | No guard on the transition | Guard: only accept confirmation while in `awaiting`; late payment triggers auto-refund | transition matrix in `state-machine-booking.md`, test `T7` |

## Checking configuration

| Bound | Value | Runtime | States explored |
|-------|-------|---------|-----------------|
| Bookings | 2 | 40 s | 1.2 M |
| Capacity | 2 | | |
| Max duplicates | 2 | | |

## Bridge to the implementation

| Spec property | Implementation guard | Test |
|---------------|----------------------|------|
| P3 idempotent confirm | idempotency key on the webhook handler | `WebhookIdempotencyTest` |
| P2 seat conservation | invariant assertion in the reconciliation job | `SeatConservationPropertyTest` |

## Maintenance

- **Re-check when**: the state machine, the retry policy, or the timeout changes.
- **Owner**: <name> · **Reviewed with**: <names>
````

---

## 7. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Specifying the whole system | Unmaintainable, unreadable, never re-run | One question, one narrow spec |
| Modelling at implementation detail level | State explosion; the checker never finishes | Abstract to the level the question needs |
| Assuming a reliable network | The interesting bugs are excluded by construction | Model loss, duplication, reordering, crashes |
| Only safety properties | Systems that deadlock while violating nothing | Add liveness with explicit fairness |
| Ignoring a counterexample as "unrealistic" | The exact production incident, dismissed early | Explain it or change the model's assumptions |
| Spec never re-run after design changes | Silent divergence | Re-check trigger in the definition of done |
| No bridge to code | Correct design, incorrect implementation | Derive property tests and assertions |
| One person who can read it | Bus factor of one; spec abandoned | Pair on it; publish a prose rendering |
| Using formal methods for CRUD | Cost with no benefit; credibility loss | Reserve it for concurrency and safety-critical logic |

---

## 8. Checklist

- [ ] One precise question stated, with the cost of a violation
- [ ] Language chosen deliberately (behaviour over time vs structure vs regulated document)
- [ ] Abstraction level justified: what is modelled and what is not, and why
- [ ] Assumptions written down explicitly
- [ ] Failure actions modelled — crash, loss, duplication, reordering, timeout, concurrency
- [ ] Type invariant plus domain safety invariants stated
- [ ] Liveness properties stated with their fairness assumptions
- [ ] Checked at small bounds first, then grown; bounds and runtime recorded
- [ ] Every counterexample explained and classified: design bug, missing assumption, or modelling error
- [ ] Fixes traced into the design artifacts (state machine, contracts) and into tests
- [ ] Property-based tests or runtime assertions derived from the invariants
- [ ] Re-check trigger defined and owned
- [ ] More than one person able to read and maintain the specification
