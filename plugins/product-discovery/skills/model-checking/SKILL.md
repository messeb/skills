---
description: Model checking and simulation — verifying formal and state-based specifications automatically. Covers what a model checker does, TLC/Apalache and the Alloy Analyzer, state explosion and how to fight it, safety vs liveness and fairness, reading and triaging counterexamples, simulation and discrete-event models for non-exhaustive questions, connecting models to implementations via trace validation and property-based tests, CI integration, and Markdown templates for a verification report.
---

# Model checking and simulation

Goal of this skill: let a machine search the state space for the interleaving that breaks your design — exhaustively where possible, statistically where not — and turn every counterexample into a concrete design fix.

Use this skill after writing a formal specification (`formal-specs`), to verify a non-trivial state machine (`state-machines`), before a risky migration or cutover, and whenever a design's correctness depends on ordering, timing, retries, or concurrency.

Do **not** use it to verify code — a model checker verifies the *model*. Closing the gap to the implementation is a separate, explicit step (§6).

---

## 1. What a model checker does

Given a model (states + transitions) and a property, it explores reachable states and either exhausts the space without violating the property, or returns a **counterexample trace** — the exact sequence of steps that breaks it.

| Tool | Kind | Strength | Limit |
|------|------|----------|-------|
| **TLC** (TLA+) | Explicit-state | Exhaustive within bounds; readable traces; good for protocols and concurrency | State explosion; needs small bounds |
| **Apalache** (TLA+) | Symbolic (SMT) | Handles larger data domains; type-checked | Different modelling constraints; less mature ecosystem |
| **TLAPS** | Proof assistant | Unbounded proofs | High effort; use for the properties that truly need it |
| **Alloy Analyzer** | Bounded relational (SAT) | Instant counterexamples, visualisation; excellent for structure and policy | Bounded scopes only; poor fit for temporal behaviour |
| **SPIN / Promela** | Explicit-state | Mature protocol verification | Niche language |
| **Statechart / state-machine simulators** | Simulation | Animate a lifecycle with a domain expert watching | Not exhaustive |
| **Discrete-event simulation** | Stochastic | Throughput, queueing, staffing, lead time under variability | Statistical, not proof |

Rule: **use exhaustive checking for correctness questions ("can this ever happen?") and simulation for performance and capacity questions ("how often, how long, how many?").** They answer different things and neither substitutes for the other.

---

## 2. Properties

| Kind | Meaning | Examples | Notes |
|------|---------|----------|-------|
| **Type invariant** | Variables stay in their declared domains | `state ∈ States` | Cheap; catches modelling errors first |
| **Safety** | Nothing bad ever happens | no double payout; no lost seat; at most one leader; sum of balances constant | The workhorse |
| **Liveness** | Something good eventually happens | every request is eventually answered; the system eventually settles | Meaningless without fairness assumptions |
| **Refinement** | A detailed spec implements an abstract one | the sharded design behaves like the single-node one | Powerful for staged design |
| **Deadlock freedom** | Some action is always enabled | — | Checked by default in TLC; usually the first thing you find |

**Fairness**: weak fairness means an action continuously enabled is eventually taken; strong fairness means an action repeatedly enabled is eventually taken. Choose deliberately — assuming too much fairness makes liveness properties pass for the wrong reason.

---

## 3. Fighting state explosion

| Technique | Effect |
|-----------|--------|
| Start tiny (2 nodes, 2 messages, 1 retry) | Most real bugs appear at the smallest interesting size |
| Constrain the state space (`CONSTRAINT`, bounded queues and counters) | Keeps the search finite |
| Abstract away irrelevant data (ids as a small symmetric set) | Removes combinatorial noise |
| Symmetry sets for interchangeable processes | Large factor reduction |
| Split large properties into several small ones | Faster feedback, clearer failures |
| Model only the question's slice | The single biggest lever |
| Move to a symbolic checker when data domains are large | Handles what explicit-state cannot |
| Run long checks nightly, keep a fast subset in CI | Feedback without blocking |

If a check runs for hours, the model is almost always too detailed — not the tool too slow.

---

## 4. Reading a counterexample

A counterexample is a story, and it deserves the same rigour as a production incident.

1. **Read it as steps**, in order: what action fired, what changed, why the property broke at the last state.
2. **Reproduce the reasoning in plain language** — one paragraph a colleague could follow without the tool.
3. **Classify it**:

   | Verdict | Meaning | Action |
   |---------|---------|--------|
   | **Real design defect** | The design genuinely permits this | Fix the design; record the fix and re-check |
   | **Missing assumption** | Reality prevents it, but the model does not know | Add the assumption explicitly — and check the assumption is really guaranteed in production |
   | **Modelling error** | The model is wrong, the design is fine | Fix the model; note it, since it usually means the spec was misread |
   | **Property wrong** | The property overstates what is required | Correct the property; the discussion about what is actually required is the valuable part |

4. **Never dismiss a trace as "unrealistic" without writing down why.** That dismissal is exactly the shape of a future incident report.
5. **Turn each real defect into a regression**: a test, a runtime assertion, or an alarm named after the property.

---

## 5. Simulation, when exhaustive checking is the wrong tool

| Question | Approach |
|----------|----------|
| How long is the queue at peak, how many staff are needed? | Discrete-event simulation with measured arrival and service distributions |
| What is the end-to-end lead time distribution of this process? | Simulate the `process-modeling` model with real process and wait times |
| How does the system behave under a plausible-but-rare mix of failures? | Randomised or statistical model checking |
| Will a domain expert recognise this lifecycle as correct? | Animate the state machine step by step with them watching |

Simulation rules: drive it with **measured** distributions, not guesses; state the confidence interval; run enough replications; validate the model against a period of known history before trusting a forecast.

---

## 6. Connecting the model to the implementation

The checker verifies the model. Bridge the gap explicitly:

| Bridge | How |
|--------|-----|
| **Trace validation** | Log the implementation's state transitions and replay them against the spec; a divergence proves the code does something the model forbids |
| **Property-based tests** | Turn each invariant into a property test with generated inputs, using the same property name |
| **Runtime assertions and alarms** | Assert the critical invariants in production; alert when one is violated |
| **Derived acceptance tests** | Each counterexample becomes a named regression test (`acceptance-test-definition`) |
| **Same vocabulary** | Property names, state names, and action names identical in spec, code, and tests |

---

## 7. Intake — ask before checking

Ask only what is missing; batch into one message, five or fewer.

1. **What property must hold**, and what would its violation cost?
2. **Which model exists** — a formal spec, a state machine, a process model, or nothing yet?
3. **What are the bounds** — how many actors, messages, retries are worth exploring?
4. **What may fail** — crash, loss, duplication, reordering, concurrency, clock skew?
5. **Is the question about correctness or about capacity?** That decides checking vs simulation.

---

## 8. Output template

Write to `docs/specs/verification-<name>.md`.

````markdown
# Verification report — <Booking confirmation under retries>

- **Model**: `spec/BookingConfirm.tla` @ `<commit>` · **Tool**: TLC 2.19 · **Date**: <date>
- **Run by**: <name> · **Config**: `spec/BookingConfirm.cfg`

## Properties checked

| # | Property | Kind | Fairness | Result | Runtime | States |
|---|----------|------|----------|--------|---------|--------|
| P1 | `TypeOK` | type invariant | — | ✅ pass | 12 s | 340 k |
| P2 | `SeatConservation` | safety | — | ❌ fail → fixed | 41 s | 1.2 M |
| P3 | `ConfirmIdempotent` | safety | — | ✅ pass | 38 s | 1.2 M |
| P4 | `NoConfirmAfterExpiry` | safety | — | ❌ fail → fixed | 40 s | 1.2 M |
| P5 | `EventuallySettled` | liveness | weak fairness on `Timeout` | ✅ pass | 3 m 20 s | 1.2 M |
| — | deadlock | safety | — | ✅ none | — | — |

## Bounds and assumptions

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Bookings | 2 | smallest size that exposes interleaving |
| Max duplicates | 2 | provider retries at most twice |
| Assumption | webhooks are not corrupted | signed payloads verified at the edge — **verify this still holds** |

## Counterexamples

### CE-1 — `SeatConservation` violated

**Trace**: `Submit(b1)` reserves a seat → `Crash` before the state is persisted → restart → `Timeout(b1)` never fires because `b1` is not in `awaiting` → the seat is never released.

- **Verdict**: real design defect
- **Root cause**: reservation and state write are not in one transaction
- **Fix**: single transaction; reconciliation job as a backstop
- **Regression**: `SeatConservationPropertyTest`, runtime assertion `seats_invariant`, alert on drift > 0
- **Re-checked**: ✅ pass @ `<commit>`

### CE-2 — `NoConfirmAfterExpiry` violated

**Trace**: `Timeout(b1)` expires the booking → a delayed `PaymentOK` webhook arrives → confirm fires without a state guard.

- **Verdict**: real design defect
- **Fix**: guard the transition on `state = awaiting`; late payment triggers an automatic refund
- **Regression**: `state-machine-booking.md` transition matrix cell + test `T7`
- **Re-checked**: ✅ pass

## Implementation bridge

| Property | Enforced in code by | Verified by |
|----------|--------------------|-------------|
| P2 | reconciliation job invariant | `SeatConservationPropertyTest`, production alert |
| P3 | idempotency key on the webhook handler | `WebhookIdempotencyTest` |

## CI integration

| Check | Trigger | Duration | Blocking |
|-------|---------|----------|----------|
| Safety properties at bound 2 | every PR touching `spec/` or the booking module | 90 s | yes |
| Full run incl. liveness at bound 3 | nightly | 22 min | no — reported |

## Re-check triggers

- State machine, retry policy, or timeout changes
- New failure mode observed in production
````

---

## 9. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Checking a model that assumes a reliable network | The interesting bugs are excluded by construction | Model loss, duplication, reordering, crashes |
| Only safety properties | Designs that deadlock or starve pass cleanly | Add liveness with explicit fairness |
| Liveness without stated fairness | Passes or fails for reasons nobody understands | State weak/strong fairness deliberately |
| Dismissing a counterexample as unrealistic | The dismissal is the future incident report | Explain it in writing or change the assumption |
| Huge bounds from the start | Runs for hours, finds nothing | Start tiny, grow after it is clean |
| Model kept in one person's head | Abandoned after they leave | Pair on it; publish the prose rendering |
| Never re-run after design changes | The verification is about an obsolete design | Re-check trigger in the definition of done |
| Believing verified model = correct code | False confidence | Trace validation, property tests, runtime assertions |
| Simulation driven by guessed distributions | Confident, precise, wrong numbers | Measured distributions; validate against history |
| Using simulation to answer a correctness question | "We ran 10,000 iterations and saw no violation" | Exhaustive checking for "can this ever happen" |

---

## 10. Checklist

- [ ] Property stated precisely, with the cost of a violation
- [ ] Correctness vs capacity question identified; checking or simulation chosen accordingly
- [ ] Type invariant checked before domain properties
- [ ] Failure actions modelled: crash, loss, duplication, reordering, timeout, concurrency
- [ ] Safety and liveness both covered; fairness assumptions explicit
- [ ] Deadlock check enabled
- [ ] Bounds started small and grown; bounds, runtime, and state counts recorded
- [ ] Every counterexample explained in prose and classified
- [ ] Assumptions added to the model verified as true in production
- [ ] Every real defect fixed in the design artifact and covered by a named regression
- [ ] Re-check after each fix, recorded with the commit
- [ ] Implementation bridged via trace validation, property tests, or runtime assertions
- [ ] Fast subset in CI, full run nightly
- [ ] Re-check triggers defined and owned
