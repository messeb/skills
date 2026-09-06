---
description: Design Thinking, empathize and define phases — personas and proto-personas, empathy maps, customer journey maps, and problem-statement/POV framing with How Might We questions. Covers when each artifact is worth building, research inputs required, workshop scripts, validation of proto-personas, and Markdown templates for every artifact.
---

# Design Thinking — empathize and define

Goal of this skill: build a shared, evidence-based model of the user and their experience, then converge on a **sharp problem statement** worth solving — before anyone designs a solution.

Scope of this skill is the first two diamond-opening phases: **empathize** (persona, empathy map, journey map) and **define** (POV statement, How Might We). Ideation, prototyping and testing are out of scope.

Use this skill for user-facing products, when the team argues about "the user" without agreeing who that is, when the experience spans many touchpoints, or when you have research data that nobody has synthesised.

Do **not** use it as a substitute for research. Every artifact here is a *synthesis* format; built from opinion alone, it manufactures confidence without knowledge.

---

## 1. Which artifact, when

| Artifact | Answers | Needs as input | Costs | Skip it when |
|----------|---------|----------------|-------|--------------|
| **Proto-persona** | Who do we *think* we serve? | Team knowledge, 1–2 h | Low | You already have research — build a real persona |
| **Persona** | Who do we serve, evidenced? | 5–12 interviews or solid analytics | Medium | You serve one obvious internal role |
| **Empathy map** | What is in this user's head right now? | Interview quotes / observation notes | Low | You have no user data at all |
| **Journey map** | Where does the experience break? | Research across the whole journey | Medium–high | The scope is a single screen |
| **Service blueprint** | What backstage causes the frontstage pain? | Journey map + operational knowledge | High | No backstage complexity exists |
| **POV / problem statement** | What exactly are we solving, for whom, why? | Any of the above | Low | Always do this one |
| **How Might We** | What should we ideate on? | POV statement | Low | Always do this one |

Rule: **artifacts are outputs of synthesis, not substitutes for it.** Never present a proto-persona as a persona.

---

## 2. Intake — ask before building anything

Ask only what is missing; batch into one message, five or fewer.

1. **Who is the user group** and what do they use the product for? Are there several distinct groups?
2. **What research exists?** Interviews, support tickets, analytics, observation notes, sales calls, prior studies — anything with real user voice?
3. **What is the scope of the experience** — where does the journey start and end (first awareness? first login? renewal?)
4. **What is the suspected problem**, and what evidence supports it today?
5. **What is the artifact for** — alignment, prioritisation, a redesign, a pitch? Who will read it?

If there is no research at all, say so plainly and produce **proto-personas marked as assumptions**, plus a research plan to validate them.

---

## 3. Personas and proto-personas

### Build a proto-persona (1–2 h workshop)

1. Each participant silently sketches the user they have in mind on a four-quadrant sheet: sketch + name/role · demographics and behaviours · needs and goals · pains.
2. Share and cluster. Where sketches diverge, you have found a hidden disagreement — that is the value of the exercise.
3. Agree on 1–3 proto-personas. Mark **every** field as `assumed` or `evidenced`.
4. List the assumptions with the highest risk and turn them into research questions.

### Turn a proto-persona into a persona

Validate the risky assumptions with 5–8 interviews (`stakeholder-interviews`, `jobs-to-be-done`) or observation (`contextual-inquiry`), then rewrite the persona with evidence tags per statement.

Keep personas **behavioural**, not demographic: what they are trying to achieve, their context, constraints, tool literacy, and decision criteria matter; their age and marital status usually do not.

Cap at 3–5 personas, and name the **primary** persona — the one whose failure means the product fails.

---

## 4. Empathy map

Six areas around a user in one **specific situation** (not a whole life):

| Area | Prompt | Source |
|------|--------|--------|
| **Says** | Verbatim quotes | interviews |
| **Thinks** | What they believe but do not say | inference, marked as such |
| **Does** | Observable actions and workarounds | observation |
| **Feels** | Emotions and their intensity | tone, body language, quotes |
| **Pains** | Frustrations, obstacles, risks | both |
| **Gains** | Wants, measures of success | both |

Rules: one map per persona per situation; fill `Says` and `Does` from evidence first, then infer `Thinks` and `Feels`; mark every inferred item so nobody later cites it as fact.

---

## 5. Customer journey map

Build it from research, across the whole experience — including the parts you do not own.

Columns are **stages**; rows are the lenses:

| Row | Content |
|-----|---------|
| **Stage** | Awareness → Consideration → Onboarding → Use → Support → Renewal/Exit (adapt to your domain) |
| **Goal** | What the user wants at this stage |
| **Actions** | What they actually do, including outside your product |
| **Touchpoints** | Channels and systems involved |
| **Thoughts / quotes** | Verbatim where possible |
| **Emotion** | Curve from -2 to +2, with the reason for each dip |
| **Pain points** | With frequency and severity |
| **Opportunities** | Where intervention would pay off |
| **Owner** | Which team owns this stage today |
| **Evidence** | Source per column: interview id, ticket id, analytics event |

Backstage (optional, makes it a **service blueprint**): frontstage staff actions, backstage actions, supporting systems, and the failure points between them.

The most valuable output is usually the **dip with no owner** — the stage everyone assumed was someone else's.

---

## 6. Define — the POV statement and How Might We

**Point of view template:**

> `<persona>` needs a way to `<need, phrased as a verb>` because `<insight — the surprising why>`.

Rules:

- The **need is a verb**, never a feature ("…needs a way to know whether the delivery will be late", not "…needs a tracking page").
- The **insight** must be something you learned, not something obvious. If it reads as a truism, keep digging.
- One POV per problem. If it contains "and", split it.

**Reframe into How Might We questions.** Test the altitude:

| Too narrow | Right altitude | Too broad |
|------------|----------------|-----------|
| HMW add an ETA badge to the order page? | HMW keep customers confident about arrival time without them having to check? | HMW delight our customers? |

Generate 5–10 HMWs per POV, then dot-vote to pick the 2–3 to ideate on. Vary the angle deliberately: amplify the good, remove the bad, explore the opposite, question the assumption, change the actor, borrow from another domain.

---

## 7. Output templates

### 7.1 Persona

````markdown
# Persona — <name>, <role> · <primary | secondary> · <persona | PROTO-persona (assumptions)>

- **Based on**: <n interviews, n observations, analytics segment> · **Last validated**: <date>

| Field | Content | Evidence |
|-------|---------|----------|
| Context | Where and how they work | I2, I5, obs S1 |
| Goals | What success means for them | I1–I6 |
| Tasks | What they do regularly | obs S1–S3 |
| Pains | Obstacles and frustrations | I3, tickets #442 |
| Workarounds | What they built themselves | obs S2 |
| Tools | What they use today | I1, I4 |
| Decision criteria | How they choose | I5 |
| Constraints | Time, skill, device, environment, policy | obs S3 |
| Quote | "…" | I3 |

## Open assumptions to validate

| # | Assumption | Risk if wrong | How to validate |
|---|------------|---------------|-----------------|
````

### 7.2 Empathy map

````markdown
# Empathy map — <persona> · situation: <specific moment>

| Says (verbatim) | Thinks (inferred) |
|-----------------|-------------------|
| "…" (I2) | … (inferred from I2, I4) |

| Does (observed) | Feels (inferred) |
|-----------------|------------------|
| … (obs S1) | frustration, high (I3 tone) |

**Pains**: … · **Gains**: …

**Evidence sources**: I1–I6, obs S1–S3, tickets #…
````

### 7.3 Journey map

````markdown
# Journey map — <persona> — <journey name>

| | Awareness | Consideration | Onboarding | Use | Support | Renewal |
|---|---|---|---|---|---|---|
| **Goal** | | | | | | |
| **Actions** | | | | | | |
| **Touchpoints** | | | | | | |
| **Quote** | | | | | | |
| **Emotion (-2…+2)** | | | | | | |
| **Pain points** | | | | | | |
| **Opportunities** | | | | | | |
| **Owner** | | | | | | |
| **Evidence** | | | | | | |

## Prioritised pain points

| # | Stage | Pain | Frequency | Severity | Users affected | Opportunity |
|---|-------|------|-----------|----------|----------------|-------------|

## Moments of truth

- <stage>: <why this moment decides the relationship>

## Ownership gaps

| Stage | Currently owned by | Problem |
|-------|--------------------|---------|
````

### 7.4 Problem definition

````markdown
# Problem definition — <topic>

## Point of view

> <persona> needs a way to <need verb> because <insight>.

**Evidence for the insight**: …

## How Might We

| # | HMW | Altitude check | Votes |
|---|-----|----------------|-------|
| 1 | HMW … | ok | ●●●● |

**Selected for ideation**: HMW <n>, HMW <n>

## Success criteria

| Signal | Baseline | Target | Measured by |
|--------|----------|--------|-------------|

## Non-goals

- …
````

---

## 8. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Personas invented in a meeting and used as fact | Confident decisions on fiction | Label proto-personas; validate before relying on them |
| Demographic personas ("Sarah, 34, likes yoga") | No design decision follows from it | Behaviour, goals, context, constraints |
| Ten personas | Nobody remembers any of them | 3–5 max, one primary |
| Journey map covering only your own product | The worst pain is usually outside your walls | Map the whole experience including third parties |
| Emotion curve with no reason attached | Pretty, not actionable | Every dip gets a cause and evidence |
| POV that contains the solution | Ideation is over before it starts | Need as a verb, no feature words |
| HMW too broad or too narrow | Useless or already answered | Test altitude explicitly |
| Artifacts made once and never updated | They quietly become wrong | Date them; set a re-validation trigger |
| Empathy map presented without marking inference | Guesses cited later as user research | Tag inferred items |
| Skipping define and jumping to ideas | Solving the wrong problem beautifully | Write the POV before any sketching |

---

## 9. Checklist

- [ ] Research inputs listed; artifacts without research are labelled as assumptions
- [ ] Persona count ≤ 5, primary persona named
- [ ] Persona statements carry evidence tags; open assumptions listed with a validation plan
- [ ] Empathy map scoped to one persona in one specific situation
- [ ] Inferred items in the empathy map explicitly marked
- [ ] Journey map covers stages outside your own product
- [ ] Every emotional dip has a cause and evidence
- [ ] Pain points ranked by frequency × severity × reach
- [ ] Ownership gaps identified
- [ ] POV statement uses a need-verb and a non-obvious insight
- [ ] 5–10 HMW questions generated and altitude-checked; 2–3 selected
- [ ] Success criteria and non-goals written
- [ ] Artifacts dated with a re-validation trigger
