---
description: Jobs to be Done — frame requirements around the progress a customer is trying to make, not around features. Covers job statements, the four forces of switching, Switch interviews (timeline reconstruction), job maps, outcome statements with the opportunity score, segmentation by job, and Markdown templates for the interview guide, job statement, job map, and outcome/opportunity table.
---

# Jobs to be Done

Goal of this skill: describe what the customer is trying to **get done** — the progress they want in a given situation — so that requirements survive changes of technology, and so the roadmap stops being a list of competitors' features.

Use this skill for product discovery, when a backlog has become a feature list with no rationale, when positioning is unclear, when churn or non-adoption is unexplained, or when you need to know who you actually compete with.

Do **not** use it to specify acceptance criteria (`example-mapping`), to model an internal process (`domain-storytelling`), or as a rename for personas — JTBD deliberately de-emphasises who the user is in favour of the situation they are in.

---

## 1. The core idea

> People do not buy products; they **hire** them to make progress in a particular circumstance.

Consequences worth internalising:

- **Competition is defined by the job**, not the category. A meal-kit competes with the pizza place, the freezer, and the parents-in-law.
- **The situation drives the behaviour** more than the demographics. Two identical customers in different circumstances hire different products.
- **Jobs are stable; solutions change.** "Get from A to B quickly" outlived the horse.
- **Something must be fired** for a purchase to happen. Understanding what people are firing is as useful as knowing what they hire.

---

## 2. Job statement formats

| Format | Template | Use for |
|--------|----------|---------|
| **Situational (Klement)** | When `<situation>`, I want to `<motivation>`, so I can `<expected outcome>` | Discovery, positioning, interview synthesis |
| **Functional job (Ulwick)** | `<verb>` + `<object of the verb>` + `<contextual clarifier>` — e.g. "minimise the time it takes to diagnose a failing test" | Outcome-driven innovation, measurable requirements |
| **Job story (Intercom)** | When `<situation>`, I want to `<motivation>`, so I can `<expected outcome>` — written per feature | Replacing user stories where the persona adds nothing |

Rules:

- **Solution-free.** No product, brand, or interface word may appear in a job statement.
- **Stable.** If the statement would have been false ten years ago, it is describing a solution.
- Distinguish three layers: the **functional** job (the task), the **emotional** job (how they want to feel), and the **social** job (how they want to be perceived). All three drive purchases; only the functional one usually gets written down.

| Layer | Example |
|-------|---------|
| Functional | Reconcile the month's transactions without manual re-entry |
| Emotional | Feel confident the numbers are right before the board meeting |
| Social | Be seen by the CFO as someone who never delivers a late report |

---

## 3. The four forces of switching

Every switch is a tug of war. Ask about all four in every interview.

| Force | Direction | Question that surfaces it |
|-------|-----------|---------------------------|
| **Push** of the situation | towards change | "What was going wrong before you started looking?" |
| **Pull** of the new solution | towards change | "What made you think this could work?" |
| **Anxiety** about the new | against change | "What worried you? What almost stopped you?" |
| **Habit** of the present | against change | "What were you comfortable with about the old way?" |

Design work follows directly: amplify push and pull in marketing; reduce anxiety with guarantees, migration help and proof; break habit with import tools and defaults.

---

## 4. Switch interviews

Interview people who **recently switched** (bought, cancelled, or changed how they do the job) — ideally within the last 60–90 days, so the memory is real.

Recruit four types: new customers, customers who considered you and chose another, churned customers, and people who solve the job without buying anything (the "non-consumption" case — often the biggest competitor).

### The timeline reconstruction

Do not ask "why did you buy". Rebuild the story backwards from the purchase, moment by moment.

| Milestone | Ask about |
|-----------|-----------|
| **First thought** | "When did you first realise the old way wasn't working?" What happened that day? |
| **Passive looking** | What did you notice? Who did you talk to? What did you not do? |
| **Event that triggered active search** | "What happened that made you actually start looking?" — there is always a specific event |
| **Active looking** | What did you compare? What did you type into the search box, in your words? |
| **Deciding** | Who else was involved? What almost stopped you? What was the deal-breaker criterion? |
| **First use** | What did you expect? What surprised you? |
| **Consumption today** | What do you actually use it for? What did you keep doing the old way? |

Techniques: get **dates and physical details** ("was it a weekday? where were you sitting?") — concrete anchors unlock real memory; ask "and then what?" relentlessly; note the exact words they used to search, they are your positioning copy.

Run 8–15 interviews per job. Patterns usually stabilise around 10.

---

## 5. Job map and outcome statements

**Job map** — the universal steps of getting a job done, solution-free (Ulwick):

`Define → Locate → Prepare → Confirm → Execute → Monitor → Modify → Conclude`

For each step, ask what makes it slow, error-prone, or unpleasant today. The biggest opportunities usually sit in the steps *around* execute — preparation and monitoring — which existing products ignore.

**Outcome statements** — measurable success criteria in the customer's terms:

`<direction: minimise|increase> + <metric: time|likelihood|number|effort> + <object> + <clarifier>`

Example: *"Minimise the time it takes to confirm that every transaction has been categorised, before closing the month."*

**Opportunity score** (Ulwick): survey customers on each outcome for importance and satisfaction, both 1–10.

`Opportunity = Importance + max(0, Importance − Satisfaction)`

| Score | Meaning |
|-------|---------|
| > 15 | Underserved — high opportunity |
| 10–15 | Appropriately served |
| < 10 | Overserved — candidate for simplification or a cheaper offer |

Use `questionnaires` to collect importance/satisfaction at scale after the qualitative work has produced the outcome statements.

---

## 6. Intake — ask before starting

Ask only what is missing; batch into one message, five or fewer.

1. **What product or situation** are we studying, and what job do you *believe* customers hire it for?
2. **Who can we talk to** — recent switchers, churned users, non-buyers? How recent is "recent"?
3. **What triggered this work** — churn, flat growth, a new segment, a pivot, positioning?
4. **What do you currently believe the alternatives are** (including "does nothing" and "spreadsheet")?
5. **What decisions will this inform**, and by when?

---

## 7. Output templates

### 7.1 Switch interview guide

````markdown
# Switch interview guide — <product / job>

**Recruit**: switched within <n> days · types: new / competitor-chosen / churned / non-consumer

1. Tell me about the day you decided to look for something. Where were you? What had just happened?
2. Before that — when did you first think the old way wasn't working? What did you do then?
3. What did you try first? Why did that not settle it?
4. What made you start actively looking? What happened that week?
5. What options did you consider? What did you type into search?
6. Who else was involved in the decision? What did they care about?
7. What almost stopped you? What worried you?
8. What did you have to give up or switch off?
9. What did you expect on day one? What actually happened?
10. What do you use it for today? What do you still do the old way?
````

### 7.2 Job statement and forces

````markdown
# Job — <short name>

**Situational statement**
> When <situation>, I want to <motivation>, so I can <expected outcome>.

**Functional job**: <verb + object + clarifier>
**Emotional job**: <feel …>
**Social job**: <be seen as …>

## Forces

| Force | Content | Evidence |
|-------|---------|----------|
| Push | | I2, I5 |
| Pull | | I1, I3 |
| Anxiety | | I4 |
| Habit | | I2, I6 |

## Competing alternatives (what they hire instead)

| Alternative | Why it wins | Why it loses | Evidence |
|-------------|-------------|--------------|----------|
| Spreadsheet | free, familiar | breaks over 500 rows | I1, I3, I7 |

## Segments by circumstance (not demographics)

| Circumstance | Job emphasis | Size estimate |
|--------------|--------------|---------------|
````

### 7.3 Job map and outcomes

````markdown
# Job map — <job>

| Step | What the customer is trying to do | Current friction | Evidence | Opportunity |
|------|-----------------------------------|------------------|----------|-------------|
| Define | | | | |
| Locate | | | | |
| Prepare | | | | |
| Confirm | | | | |
| Execute | | | | |
| Monitor | | | | |
| Modify | | | | |
| Conclude | | | | |

## Outcome statements

| # | Outcome statement | Job step | Importance (1–10) | Satisfaction (1–10) | Opportunity | Verdict |
|---|-------------------|----------|-------------------|---------------------|-------------|---------|
| O1 | Minimise the time to confirm all transactions are categorised | Confirm | 9.1 | 4.2 | 13.9 | underserved |

**Survey source**: <n respondents, date, method> — see `questionnaires`

## Implications

| # | Implication | Supported outcomes | Next step |
|---|-------------|--------------------|-----------|
````

---

## 8. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Job statement containing the solution | You have written a feature request | Strip all product words; check it would hold ten years ago |
| Asking "why did you buy?" directly | Rationalised, tidy, false answers | Rebuild the timeline with dates and physical detail |
| Interviewing only happy current customers | Survivorship bias; churn stays unexplained | Include churned users, competitor-choosers, and non-consumers |
| Ignoring non-consumption | You miss the largest alternative | Ask what people do who buy nothing |
| Treating JTBD as renamed personas | Loses the situational insight | Segment by circumstance, not by demographic |
| Only the functional job | Emotional and social drivers explain the purchase | Capture all three layers |
| Outcome statements without a metric direction | Not measurable, not prioritisable | `minimise/increase + metric + object + clarifier` |
| Opportunity scores from a handful of interviews | Statistically meaningless | Qualitative for statements, survey for scoring |
| One job for the whole product | Hides that different segments hire it differently | Multiple jobs, mapped to circumstances |

---

## 9. Checklist

- [ ] Job statements are solution-free and situation-anchored
- [ ] Functional, emotional and social layers captured
- [ ] 8–15 switch interviews with recent switchers
- [ ] All four recruit types covered, including non-consumers
- [ ] Timeline reconstructed with concrete dates and details, not rationalisations
- [ ] All four forces documented with evidence per interview
- [ ] Competing alternatives listed, including "do nothing" and "spreadsheet"
- [ ] Customer's own search words captured for positioning
- [ ] Job map built solution-free across all steps
- [ ] Outcome statements written in `direction + metric + object + clarifier` form
- [ ] Importance/satisfaction collected at scale before opportunity scores are trusted
- [ ] Segments defined by circumstance, not demographics
- [ ] Implications tied to concrete next steps
