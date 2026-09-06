---
description: Controlled natural language requirement templates — EARS (ubiquitous, event-driven, state-driven, unwanted behaviour, optional, complex) and the MASTeR/Rupp sentence template with its process-word and obligation-level rules. Covers ambiguity elimination, nominalisation and passive-voice traps, quantifier discipline, template selection, quality criteria per ISO/IEC/IEEE 29148, and Markdown templates for a requirement register and a review pass.
---

# Requirement templates — EARS and MASTeR/Rupp

Goal of this skill: remove ambiguity from written requirements by constraining the **sentence structure**, so that a requirement cannot be read two ways, and so that missing information is visible rather than assumed.

Use this skill for regulated or contractual requirements, for interfaces between organisations, when requirements are handed to a supplier, when a review keeps surfacing "we read that differently", and whenever a requirement will outlive the conversation that produced it.

Do **not** use it as a substitute for examples — a perfectly templated requirement plus zero examples still leaves edge cases open. Pair it with `gherkin-bdd` or `example-mapping`.

---

## 1. EARS — Easy Approach to Requirements Syntax

Five patterns plus one combination. Choose the pattern by asking **when does this behaviour apply?**

| Pattern | Template | Use for |
|---------|----------|---------|
| **Ubiquitous** | The `<system>` shall `<response>`. | Behaviour that always holds |
| **Event-driven** | When `<trigger>`, the `<system>` shall `<response>`. | Response to a discrete event |
| **State-driven** | While `<state>`, the `<system>` shall `<response>`. | Behaviour that holds during a state |
| **Optional feature** | Where `<feature is included>`, the `<system>` shall `<response>`. | Configurable or variant behaviour |
| **Unwanted behaviour** | If `<unwanted condition>`, then the `<system>` shall `<response>`. | Errors, failures, misuse |
| **Complex** | While `<state>`, when `<trigger>`, the `<system>` shall `<response>`. | Combinations, used sparingly |

Examples:

| Pattern | Requirement |
|---------|-------------|
| Ubiquitous | The booking service shall record every state change in the audit log. |
| Event-driven | When a payment confirmation is received, the booking service shall confirm the booking within 2 seconds. |
| State-driven | While a booking is in state `AwaitingPayment`, the booking service shall keep the seat reserved. |
| Optional | Where the loyalty module is included, the booking service shall apply the member discount before tax. |
| Unwanted | If the payment provider does not respond within 10 seconds, then the booking service shall cancel the reservation and notify the customer. |
| Complex | While a booking is in state `Confirmed`, when a cancellation is requested less than 24 hours before departure, the booking service shall apply the cancellation fee. |

EARS's practical value: **the keyword tells you which pattern is missing.** A requirement set with no `If … then` clauses has no specified failure behaviour, and that is visible at a glance.

---

## 2. MASTeR / Rupp sentence template

Build every requirement from fixed slots, left to right:

`<condition>` + `THE SYSTEM` + `<obligation>` + `<capability type>` + `<object + complement>`

| Slot | Options | Notes |
|------|---------|-------|
| **Condition** | temporal (`After …`, `As soon as …`), logical (`If …`) | Optional; omit for always-true requirements |
| **System name** | the actual system name | Never "the system" in a multi-system landscape |
| **Obligation** | `shall` (mandatory) · `should` (desirable) · `may` (optional) | Exactly one, and defined in the glossary |
| **Capability type** | *autonomous*: `<process word>` · *user interaction*: `provide <actor> with the ability to <process word>` · *interface*: `be able to <process word>` when triggered by a third party | Choosing the type forces you to name who acts |
| **Object + complement** | The object of the process word and its qualifiers | Where the detail and the measurable values go |

Worked example:

> **As soon as** a cancellation request is received, **the Booking Service** **shall** **provide the customer with the ability to** **view the refund amount and the cancellation fee before confirming**.

The three capability types are the heart of the method: they make you decide whether the system acts by itself, offers the user a capability, or reacts to another system. Requirements that hide this distinction are the ones that get implemented as the wrong thing.

---

## 3. Ambiguity traps and how the templates catch them

| Trap | Example | Why it hurts | Fix |
|------|---------|--------------|-----|
| **Passive voice** | "The order is validated." | The actor is missing — who validates? | Name the system as the subject |
| **Nominalisation** | "After registration, …" | A whole process compressed into a noun | Expand: "After the customer has submitted the registration form, …" |
| **Incomplete comparison** | "…shall be faster." | Faster than what? | State the reference and the value |
| **Universal quantifier** | "All errors shall be logged." | Which errors? All of them, really? | Enumerate, or define the class precisely |
| **Vague adjective** | "user-friendly", "robust", "fast", "as needed" | Untestable | Move to a measurable quality scenario (`quality-attributes`) |
| **Unclear obligation** | "the system will…" | Mandatory or not? | Only `shall` / `should` / `may`, defined once |
| **Compound requirement** | "…shall validate the order and send a confirmation." | Half-implementable, half-testable | One requirement per sentence |
| **Undefined pronoun** | "It shall be stored." | Which "it"? | Repeat the noun |
| **Unbounded condition** | "…within a reasonable time." | Every reader picks a different number | State the number and the measurement point |
| **Solution in the requirement** | "…shall store the flag in a Redis set." | Removes design freedom, hides intent | State the required behaviour; move the constraint to the constraints section if it is genuinely fixed |

---

## 4. Quality criteria per requirement (ISO/IEC/IEEE 29148)

Each requirement must be: **necessary · appropriate · unambiguous · complete · singular · feasible · verifiable · correct · conforming**.

Each requirement **set** must be: **complete · consistent · feasible · comprehensible · able to be validated**.

Practical test: hand the requirement to two people, ask each to write the acceptance test, and compare. Any difference is ambiguity.

---

## 5. Choosing between the templates

| Situation | Use |
|-----------|-----|
| Embedded, control, or safety systems; many event- and state-driven behaviours | **EARS** |
| Business software, supplier contracts, German-speaking RE practice | **MASTeR / Rupp** |
| Mixed | EARS for behaviour, Rupp's capability types for user- and interface-facing requirements |
| Agile product work | Neither by default — `user-stories` plus `gherkin-bdd`; apply a template only to the requirements that must survive as contract |

Templates are a cost. Apply them where ambiguity is expensive, not to every backlog item.

---

## 6. Output template

Write to `docs/specs/requirements-<scope>.md`.

````markdown
# Requirements — <scope>

- **Date**: <YYYY-MM-DD> · **Author**: <name> · **Baseline**: <id or draft>
- **Template**: EARS | MASTeR/Rupp · **Obligation levels**: `shall` = mandatory, `should` = desirable, `may` = optional

## Requirements

| ID | Requirement | Pattern | Obligation | Rationale | Source | Verified by | Traces to goal | Status |
|----|-------------|---------|------------|-----------|--------|-------------|----------------|--------|
| REQ-014 | When a payment confirmation is received, the Booking Service shall set the booking to `Confirmed` within 2 seconds. | event-driven | shall | Customers abandon if confirmation is not immediate | interview I3, QA-2 | `CancellationTest#confirm`, load test LT-4 | G1.2 | approved |
| REQ-015 | If the payment provider does not respond within 10 seconds, then the Booking Service shall release the reservation and notify the customer. | unwanted | shall | Prevents seat leakage | obstacle O3 | `TimeoutTest#release` | G1.2 | approved |
| REQ-016 | While a booking is in state `AwaitingPayment`, the Booking Service shall keep the seat reserved. | state-driven | shall | Consistency with `state-machine-booking.md` | state model | `ReservationTest` | G1.2 | approved |

## Constraints (given, not derived)

| ID | Constraint | Type | Source |
|----|-----------|------|--------|
| CON-3 | Personal data is stored only in EU regions | legal | GDPR / policy |

## Terms used

See `glossary.md`. Terms introduced here: <term> — <definition>.

## Open and rejected

| ID | Item | Status | Reason | Owner |
|----|------|--------|--------|-------|
| REQ-021 | "The system shall be fast." | rejected | not verifiable — replaced by QA-1 scenario | <name> |
````

### Review pass template

````markdown
# Template review — <document> @ <version>

| ID | Trap found | Evidence | Rewritten as | Reviewer |
|----|-----------|----------|--------------|----------|
| REQ-009 | passive voice, actor missing | "The order is validated." | "The Booking Service shall validate the order against the fare rules." | <name> |
| REQ-011 | compound | "…validate and notify…" | split into REQ-011a, REQ-011b | <name> |
| REQ-018 | unbounded condition | "within a reasonable time" | "within 5 seconds, measured at the API boundary" | <name> |

**Coverage check**: patterns present — ubiquitous ✅ · event-driven ✅ · state-driven ✅ · unwanted ⚠️ only 2 · optional ❌ none
**Implication**: failure behaviour is under-specified; run an obstacle analysis (`goal-modeling`).
````

---

## 7. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Templating every backlog item | Bureaucracy, resentment, no added clarity | Template what must survive as a contract |
| "The system" in a multi-system landscape | Nobody knows which component owns it | Name the actual system |
| Mixing `shall`, `will`, `must`, `has to` | Obligation level becomes guesswork | Three defined keywords only |
| Compound requirements | Partially implementable and partially testable | One requirement per sentence |
| Templates without examples | Boundaries still undefined | Pair with example mapping or scenarios |
| No `If … then` requirements anywhere | Failure behaviour undefined | Run obstacle analysis and add unwanted-behaviour requirements |
| Requirement containing the solution | Design space closed, intent lost | Behaviour in the requirement, fixed choices in constraints |
| Rationale omitted | Nobody dares delete anything later | One-line rationale per requirement |
| Requirements with no verification method | Unprovable by construction | Name the test or the measurement |
| Ambiguity resolved verbally, document unchanged | The next reader repeats the mistake | Update the text, not just the ticket |

---

## 8. Checklist

- [ ] One template chosen and stated in the document header
- [ ] Obligation keywords defined once and used consistently
- [ ] Every requirement is a single, self-contained sentence
- [ ] Actor named — no passive voice, no undefined "it"
- [ ] Nominalisations expanded into explicit conditions
- [ ] All comparisons and time bounds quantified with a measurement point
- [ ] No vague adjectives — moved to measurable quality scenarios
- [ ] Solutions moved out of requirements into constraints where genuinely fixed
- [ ] EARS pattern coverage checked — especially unwanted-behaviour requirements
- [ ] Rationale, source, and verification method recorded per requirement
- [ ] Every requirement traces to a goal and forward to a test
- [ ] Terms match the glossary
- [ ] Two-reader ambiguity test performed on the contentious requirements
