---
description: Example Mapping (Matt Wynne) — a 25-minute four-colour card session per user story: yellow story, blue rules, green examples, red questions. Covers the session script, splitting signals, the Given/When/Then bridge to BDD, readiness verdicts, and a Markdown template for rules, examples, and open questions.
---

# Example Mapping

Goal of this skill: take one user story into a 25-minute conversation and come out with its **rules**, concrete **examples** for each rule, and the **questions** that block it — so the team either starts the story with confidence or splits it deliberately.

Use this skill in backlog refinement, before sprint planning, or whenever a story feels vague, oversized, or "we'll figure it out while building".

Do **not** use it to explore a whole domain (use `event-storming` or `domain-storytelling`) or to prioritise a backlog.

---

## 1. The four cards

| Card | Colour | Content | Rule of thumb |
|------|--------|---------|---------------|
| **Story** | yellow | The user story under discussion | Exactly one per session, at the top |
| **Rule** | blue | An acceptance criterion or business rule | 3–6 is healthy; more means split |
| **Example** | green | A concrete case illustrating a rule | At least one per rule; ambiguous rules need 2–3 |
| **Question** | red | Anything the room cannot answer now | Do not answer it live — park it with an owner |

Layout: story on top; rules in a row below it; examples in a column under their rule; questions on the side.

---

## 2. Intake — ask before the session

Ask only for what is missing; batch into one message, five or fewer.

1. **Which story?** Paste the story text as it stands (`As a … I want … so that …` or the title plus a sentence).
2. **Who is in the room?** Ideally the Three Amigos — product/business, developer, tester. Which of the three is missing?
3. **What triggered this?** Refinement, planning, a story that stalled, a bug that revealed a missing rule?
4. **What already exists?** Designs, an API contract, a legacy behaviour to preserve, a regulation?
5. **What is the deadline or constraint** that would change how far we split?

If no story text exists, write one from the conversation first and get it confirmed before mapping.

---

## 3. Session script — 25 minutes, timeboxed hard

1. **Write the story card** (2 min). Read it aloud. If the room cannot restate it in one sentence, fix the story before continuing.
2. **First rule** (2 min). Ask: *"What must be true for this story to be done?"* Write it as a blue card.
3. **Example the rule** (5–10 min). Ask: *"Give me a concrete case."* Real values, real names — `order total €499.99, customer is Gold` beats `order below threshold`. Write green cards under the rule.
4. **Let examples create rules** (ongoing). When an example does not fit any rule, it has just revealed one. Add the blue card.
5. **Park every question** (ongoing). Any "hmm, I don't know" or "we'd have to ask X" is a red card with an owner — never a live debate.
6. **Watch the shape** (last 5 min). Read the map and take the verdict below.
7. **Decide** (3 min). Ready / split / blocked, plus owners for every red card.

Stop at 25 minutes regardless. A map that needs more time is telling you the story is too big.

---

## 4. Reading the map — the verdict

| Shape | Meaning | Action |
|-------|---------|--------|
| 3–6 rules, 1–3 examples each, 0–1 questions | Well understood, right size | **Ready** — pull into the sprint |
| Many rules (7+) | Story is too big | **Split** along rule groups — each cluster is a story |
| Many examples under one rule (5+) | Rule is ambiguous or hides sub-rules | Split the rule; the examples usually cluster |
| Many red cards | Not understood yet | **Blocked** — assign questions, re-map after answers |
| Almost no cards | Trivial, or the room is not engaged | Trivial → just do it. Disengaged → wrong people in the room |
| Rules that no example can illustrate | Not a real rule, or nobody knows the behaviour | Turn it into a question |

Splitting patterns that fall out naturally: by rule, by happy path vs error path, by data variation, by interface (API before UI), by user role.

---

## 5. Bridge to executable specs

Examples become Gherkin scenarios almost verbatim. Keep the example concrete and the scenario declarative:

```gherkin
Feature: Free shipping threshold

  Rule: Orders of €50 or more ship free

    Example: Order just above the threshold
      Given a customer with a basket total of €50.00
      When they proceed to checkout
      Then shipping costs €0.00

    Example: Order just below the threshold
      Given a customer with a basket total of €49.99
      When they proceed to checkout
      Then shipping costs €4.95
```

Rules of the bridge:

- One blue card → one `Rule:` block. One green card → one `Example:`/`Scenario:`.
- Boundary examples are mandatory: below, exactly at, and above every threshold.
- Do not automate every example — automate the ones that document behaviour worth protecting; the rest served their purpose in the conversation.
- Keep the vocabulary from the domain glossary, not from the UI.

---

## 6. Output template

Write to `docs/discovery/example-map-<story-id>.md`, or straight into the ticket.

````markdown
# Example Map — <STORY-123: story title>

- **Date**: <YYYY-MM-DD>
- **Participants**: <product>, <dev>, <test>
- **Duration**: <minutes>
- **Verdict**: Ready | Split | Blocked

## Story

> As a <role> I want <capability> so that <benefit>.

## Rules and examples

### Rule 1 — <rule statement>

| # | Example | Given | When | Then |
|---|---------|-------|------|------|
| 1.1 | Just above threshold | basket €50.00 | checkout | shipping €0.00 |
| 1.2 | Just below threshold | basket €49.99 | checkout | shipping €4.95 |

### Rule 2 — <rule statement>

| # | Example | Given | When | Then |
|---|---------|-------|------|------|
| 2.1 | … | | | |

## Open questions

| # | Question | Blocks | Owner | Due | Answer |
|---|----------|--------|-------|-----|--------|
| Q1 | Does the threshold apply before or after discounts? | Rule 1 | <name> | <date> | |

## Verdict and follow-up

- **Verdict**: <Ready / Split / Blocked> — <one-line reason>
- **Proposed split** (if any): <STORY-123a …>, <STORY-123b …>
- **Scenarios to automate**: 1.1, 1.2
- **Glossary terms touched**: <term> — <definition>
````

---

## 7. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Answering red cards during the session | 25 min becomes 90 min, energy gone | Park with an owner and a date |
| Abstract examples ("a large order") | The ambiguity survives into code | Use real values |
| Only the developer talks | Business rules stay implicit | Three Amigos, all three speak |
| Writing Gherkin during the mapping | Slows the conversation to typing speed | Cards first, Gherkin after |
| Mapping five stories in one meeting | Fatigue, sloppy examples | One story, 25 minutes, then break |
| Ignoring a map with 9 rules | Oversized story enters the sprint and stalls | Split before committing |
| No boundary examples | Off-by-one bugs ship | Below / at / above every threshold |
| Map thrown away after the session | Rules get re-litigated in review | Attach it to the ticket |

---

## 8. Checklist

- [ ] Exactly one story per session, read aloud and understood
- [ ] Three Amigos present (business, dev, test)
- [ ] Timebox of 25 minutes respected
- [ ] Every rule has at least one concrete example with real values
- [ ] Boundary cases examined for every threshold
- [ ] Every question parked with an owner and a date — none answered live
- [ ] Map shape read and a verdict taken: ready / split / blocked
- [ ] Split proposal written when the map is oversized
- [ ] Scenarios to automate selected (not all of them)
- [ ] Map attached to the ticket, not left on a wall
