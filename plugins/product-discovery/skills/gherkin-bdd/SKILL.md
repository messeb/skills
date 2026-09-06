---
description: Gherkin and Behaviour-Driven Development — Feature/Rule/Scenario/Background/Scenario Outline structure, declarative vs imperative style, the three levels of abstraction, step definition design, data tables and examples, tags and organisation, living documentation, and Markdown templates for a feature file, a scenario catalogue, and the automation decision.
---

# Gherkin and BDD

Goal of this skill: express acceptance criteria as scenarios that are **unambiguous to a business reader and executable by a test runner** — one artifact that serves as specification, test, and living documentation.

Use this skill when turning example map cards or use case flows into acceptance criteria, when specifying regulated behaviour that must be provably tested, or when business and engineering keep disagreeing about what "done" meant.

Do **not** use it as a UI test scripting language, as a replacement for unit tests, or for behaviour with no business-visible rule — Gherkin costs more than a plain test and only pays back when a non-developer actually reads it.

---

## 1. BDD is a conversation, not a syntax

The order that makes BDD work:

1. **Discovery** — a structured conversation about examples (`example-mapping`, `three-amigos`).
2. **Formulation** — write the agreed examples as scenarios, in the domain's language.
3. **Automation** — make the scenarios executable.

Teams that start at step 3 get slow, brittle UI tests and call BDD a failure. The value is created in step 1; the syntax only preserves it.

---

## 2. Structure

| Keyword | Purpose | Rule |
|---------|---------|------|
| `Feature` | The capability under specification | One per file; add a short narrative of the value |
| `Rule` | A business rule that groups examples | Optional but valuable — mirrors the blue cards from `example-mapping` |
| `Background` | Steps common to every scenario in the file | Max 3–4 steps; if it is longer, the scenarios are over-contextualised |
| `Scenario` / `Example` | One concrete case | One behaviour per scenario |
| `Given` | The context that already holds | State, not actions the user performs |
| `When` | The single action under test | Exactly one `When` per scenario |
| `Then` | The observable outcome | Assert what a business reader could verify |
| `And` / `But` | Continuation of the previous keyword | Never start a scenario with them |
| `Scenario Outline` + `Examples` | The same scenario across a data set | Use for boundary tables, not to hide different behaviours |
| `@tag` | Organisation and selection | `@smoke`, `@regulatory`, `@wip` |

```gherkin
Feature: Booking cancellation
  Customers can cancel their own bookings so that support is not needed
  for routine changes.

  Background:
    Given a customer with a confirmed booking

  Rule: Cancellations more than 24 hours before departure are free

    Example: Well before departure
      Given the booking departs in 25 hours
      When the customer cancels the booking
      Then the full amount is refunded
      And the booking is cancelled

    Example: Exactly at the boundary
      Given the booking departs in exactly 24 hours
      When the customer cancels the booking
      Then the full amount is refunded

  Rule: Cancellations within 24 hours incur a 20% fee

    Scenario Outline: Fee applied close to departure
      Given the booking departs in <hours> hours
      And the booking total is <total>
      When the customer cancels the booking
      Then <refund> is refunded
      And a cancellation fee of <fee> is charged

      Examples:
        | hours | total   | refund  | fee    |
        | 23    | 100.00  | 80.00   | 20.00  |
        | 1     | 250.00  | 200.00  | 50.00  |
```

---

## 3. Declarative, not imperative

The single biggest quality lever.

| Imperative (avoid) | Declarative (write this) |
|--------------------|--------------------------|
| `Given I open "/login"` | `Given the customer is signed in` |
| `When I type "ada@example.com" into "#email"` | `When the customer cancels the booking` |
| `And I click the button with id "submit"` | |
| `Then the element ".alert" contains "Success"` | `Then the booking is cancelled` |

Imperative scenarios break on every redesign, read as scripts rather than rules, and hide the business intent. Write **what**, and let the step definitions own the **how**.

### Three levels of abstraction

| Level | Belongs in | Example |
|-------|-----------|---------|
| **Business rule** | The `Feature` / `Rule` line | Free cancellation more than 24 h before departure |
| **Domain interaction** | The `Given/When/Then` steps | "the customer cancels the booking" |
| **Technical detail** | The step definitions / page objects | HTTP call, selectors, fixtures |

A step that leaks a level down is a defect in the specification, not a style preference.

---

## 4. Writing rules

- **One behaviour per scenario.** Two `When`s means two scenarios.
- **Third person, present tense**, consistently: *"the customer cancels"*, not *"I cancel"* and not *"the customer cancelled"*. Pick one voice per project and enforce it.
- **Concrete values** in the examples; abstract wording in the rule.
- **Boundaries always**: below, exactly at, above every threshold.
- **No conjunctions inside a step** — "and" in a step means it should be two steps.
- **No UI vocabulary** unless the UI *is* the rule (accessibility, layout).
- **Domain glossary terms only** (`glossary`) — a scenario is a language artifact.
- **Independent scenarios.** Never let scenario 2 depend on the state scenario 1 left behind.
- **Deterministic**: no real clock, no real network, no random data. Inject time and fix the seed.

---

## 5. Step definitions

| Rule | Why |
|------|-----|
| Steps are thin; they call domain-level helpers or a driver layer | Keeps automation cost bounded when the UI changes |
| One step phrase, one definition — no near-duplicate phrasings | Prevents an unmaintainable step library |
| Parameterise with type-safe expressions, not fragile regexes | Readable and refactorable |
| No assertions in `Given`, no state setup in `Then` | Keeps failure diagnosis meaningful |
| Test at the cheapest layer that proves the rule — service or domain level by default, UI only for genuinely UI rules | Fast, stable suites |
| Shared fixtures reset between scenarios | Independence |

**Automate selectively.** Every scenario served its purpose in the conversation; only the ones that document behaviour worth protecting need to be executable. Record the decision explicitly (template below) rather than automating by default.

---

## 6. Output template

Store feature files next to the code (`features/` or `src/test/resources/features/`) and the catalogue in `docs/specs/`.

````markdown
# Feature catalogue — <capability>

- **Source**: example map `EM-201`, use case `UC-12` · **Owner**: <team>
- **Glossary**: `docs/discovery/glossary.md` · **Last reviewed**: <date>

## Scenarios

| # | Rule | Scenario | Source example | Automated? | Layer | Tags | Test id |
|---|------|----------|----------------|------------|-------|------|---------|
| 1 | Free cancellation > 24 h | Well before departure | EM-201 / 1.1 | yes | service | `@regulatory` | `CancellationTest#free` |
| 2 | Free cancellation > 24 h | Exactly at the boundary | EM-201 / 1.2 | yes | service | `@regulatory` | `CancellationTest#boundary` |
| 3 | Fee within 24 h | Fee applied close to departure (outline, 2 rows) | EM-201 / 2.1 | yes | service | | `CancellationTest#fee` |
| 4 | — | Screen reader announces the refund amount | UX review | yes | UI | `@a11y` | `CancellationA11yTest` |

## Not automated (and why)

| Scenario | Reason | Covered instead by |
|----------|--------|--------------------|
| Cancellation during a provider outage | Non-deterministic to reproduce | chaos test `GD-4`, monitored alert |

## Ambiguities resolved during formulation

| # | Question | Decision | Decided by | Date |
|---|----------|----------|-----------|------|
| 1 | Is the 24 h window based on departure or on check-in? | departure, in local airport time | product | <date> |

## Living documentation

- Published from the test run to: <link>
- Failure of a `@regulatory` scenario blocks the release.
````

---

## 7. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Writing Gherkin without the conversation | Syntax overhead with no shared understanding | Discovery, then formulation |
| Imperative UI scripting in steps | Brittle suite, unreadable specification | Declarative steps; details in step definitions |
| Several `When`s in one scenario | Unclear what failed | One action per scenario |
| `Given` steps that perform actions | Context and behaviour blur; misleading failures | `Given` states facts, `When` acts |
| Scenario Outline hiding different rules | One failure row, many meanings | Outline only for the same behaviour across data |
| Huge `Background` | Every scenario carries irrelevant context | Max 3–4 steps |
| Scenarios that depend on execution order | Random failures, unusable in parallel | Independent, self-contained scenarios |
| Automating every scenario through the UI | Slow, flaky, expensive | Cheapest layer that proves the rule |
| Real clock and real network in scenarios | Flaky and time-bomb tests | Inject time; stub externals |
| Feature files nobody outside the team reads | The cost of Gherkin without the benefit | If no business reader reads them, use plain tests |
| Step library with 12 phrasings of "log in" | Unmaintainable | One phrase per behaviour, reviewed |

---

## 8. Checklist

- [ ] Scenarios came out of a discovery conversation, not written in isolation
- [ ] One `Feature` per file, with a value narrative
- [ ] Business rules expressed as `Rule` blocks matching the example map
- [ ] One behaviour and exactly one `When` per scenario
- [ ] Declarative steps — no selectors, URLs, or button labels
- [ ] Concrete values in examples; boundaries below / at / above covered
- [ ] Consistent voice and tense across the suite
- [ ] Only glossary terms used
- [ ] Scenarios independent and deterministic (time and randomness injected)
- [ ] `Background` under four steps
- [ ] Step definitions thin, deduplicated, and asserting only in `Then`
- [ ] Automation layer chosen per scenario, UI only where the rule is a UI rule
- [ ] Non-automated scenarios recorded with the reason and their alternative coverage
- [ ] Ambiguities resolved during formulation written down with a decider
- [ ] Living documentation published and linked from the requirement
