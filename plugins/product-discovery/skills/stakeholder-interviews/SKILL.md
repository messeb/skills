---
description: Stakeholder interviews — structured and semi-structured 1:1s to surface depth, political context, and tacit knowledge. Covers stakeholder mapping (power/interest, RACI), interview guide design, question types to use and avoid, laddering and probing techniques, note-taking, synthesis across interviews, and Markdown templates for the guide, per-interview notes, and the cross-interview synthesis.
---

# Stakeholder interviews

Goal of this skill: learn what a workshop cannot surface — private opinions, political constraints, historical scar tissue, and the knowledge people carry but never write down.

Use this skill at the start of a project, before a big workshop (to prepare and de-risk it), when stakeholders visibly disagree, when a decision keeps getting reversed, or when you inherit a domain nobody documented.

Do **not** use it to observe how work is actually performed (use `contextual-inquiry` — people describe work differently from how they do it) or to reach a group decision (use `workshop-facilitation`).

---

## 1. Map the stakeholders first

Interview deliberately, not opportunistically.

**Power / interest grid** — place every stakeholder:

| | Low interest | High interest |
|---|---|---|
| **High power** | Keep satisfied — brief, short interview, watch for veto risk | **Manage closely — interview first and longest** |
| **Low power** | Monitor — survey instead (`questionnaires`) | Keep informed — interview if they hold operational knowledge |

Also identify by role:

| Role | Why interview them | Typical blind spot |
|------|--------------------|--------------------|
| Sponsor / budget holder | Success criteria, constraints, what would make them cancel it | Detail of daily work |
| Domain expert | Rules, edge cases, history | Assumes context you lack |
| End user | Real workflow, workarounds | Cannot see the wider system |
| Operations / support | Failure modes, volumes, recurring pain | Only sees what breaks |
| Legal / compliance / security | Hard constraints, non-negotiables | Under-states what is truly required |
| Blocker / sceptic | The strongest argument against the project | Often the most valuable interview |
| Adjacent teams | Integration and dependency reality | Own roadmap bias |

Cover the sceptic. An unheard objection returns as a late veto.

---

## 2. Intake — ask before designing the guide

Ask only what is missing; batch into one message, five or fewer.

1. **What are we trying to learn?** State it as 3–5 learning goals, not "understand the domain".
2. **Who are the stakeholders**, and what are their roles, power, and stance (supporter / neutral / sceptic)?
3. **What is the initiative** — problem, idea, or system, in one paragraph? What is already decided and not up for discussion?
4. **What already exists** — prior research, tickets, docs, a previous failed attempt?
5. **Constraints** — how many interviews, how long, can you record, any confidentiality rules?

---

## 3. Choose the format

| Format | Use when | Trade-off |
|--------|----------|-----------|
| **Structured** (fixed questions, same order) | Comparing many stakeholders on the same points; regulated settings | Comparable, but shallow — misses the unexpected |
| **Semi-structured** (guide + follow the thread) | Default for discovery | Rich, needs a skilled interviewer, harder to compare |
| **Unstructured** (topic only) | Very early exploration, or a highly senior stakeholder | Can drift; only with clear goals |

Default to **semi-structured**: a guide of themes with must-ask questions, and the freedom to follow anything interesting.

---

## 4. Interview guide design

Structure every guide in five blocks, 45–60 minutes total:

| Block | Time | Purpose | Example openers |
|-------|------|---------|-----------------|
| **Frame** | 3 min | Purpose, duration, confidentiality, recording consent, what happens with the notes | "I want to understand how X works from your side. Nothing here is attributed without asking you first." |
| **Context** | 7 min | Their role, their day, their team's place in the flow | "Walk me through a typical Tuesday." |
| **Core** | 25–30 min | The learning goals | see question types below |
| **Risks and politics** | 8 min | Constraints, opposition, history | "What would make this project fail?" "What has been tried before?" |
| **Close** | 5 min | Anything missed, who else to talk to, next steps | "What should I have asked you?" "Who sees this differently?" |

**Question types that work:**

- **Story-eliciting**: "Tell me about the last time you had to…" — concrete beats abstract every time.
- **Contrast**: "How is that different from how it worked before the migration?"
- **Extremes**: "What was the worst case you can remember? The best?"
- **Workaround-hunting**: "What do you do when the system won't let you?"
- **Quantifying**: "How often? How long does it take? How many per day?"
- **Laddering (why)**: three levels of "and why does that matter?" to reach the real goal.
- **Laddering (how)**: "what would that look like concretely?" to reach the real requirement.
- **Silence**: after an answer, wait three seconds. The second half of the answer is usually the honest one.
- **Miracle question**: "You come in tomorrow and this is solved. What is different?"
- **Anti-goal**: "What must this absolutely not do?"

**Question types to avoid:**

| Avoid | Why | Ask instead |
|-------|-----|-------------|
| "Would you use a feature that…?" | People predict their own behaviour badly | "When did you last need something like that? What did you do?" |
| "Do you want X or Y?" | Forces your frame | "How do you handle this today?" |
| "You'd agree that…?" | Leading; you get your own answer back | "How do you see it?" |
| Compound questions | You get one answer, unclear which part | One question at a time |
| Jargon from your side | Polite nodding, no shared meaning | Use their words; ask them to define their terms |
| "Why don't you just…?" | Sounds like judgement, closes them down | "What makes that hard?" |

---

## 5. Conducting

- **Two interviewers** where possible: one asks, one takes notes and watches for threads to pull.
- **Record with consent**, but still take notes — recordings that nobody re-listens to are lost data.
- **Capture verbatim quotes**. A quote survives synthesis; a paraphrase becomes your opinion.
- **Separate observation from interpretation** in the notes: `SAID:` vs `I THINK:`.
- **Follow the emotion.** Frustration, pride, and hesitation each mark something important.
- **Ask for artifacts**: the spreadsheet, the checklist, the email template they mentioned. Shadow copies of real tooling are gold.
- **Do not sell, defend, or design** during the interview. If they ask for a solution, note it and move on.
- **Time-box politically sensitive topics** and offer to take them off the record.
- **Close the loop**: send a short summary within two days and ask for corrections. It builds trust and fixes misunderstandings early.

---

## 6. Synthesis across interviews

1. Extract each note into an atomic statement (one insight per line) with a source tag.
2. Affinity-cluster the statements into themes.
3. For each theme record: what everyone agrees on, where they conflict, and what only one person said (often the expert knowledge).
4. Mark each item as **fact**, **opinion**, or **assumption** — and note what evidence would settle the assumptions.
5. Turn conflicts into a decision list, not an average. Contradiction between stakeholders is a finding, not noise.
6. Feed the output into the next method: contexts → `event-storming`, processes → `domain-storytelling`, goals → `impact-mapping`, unmet needs → `jobs-to-be-done`, breadth check → `questionnaires`.

---

## 7. Output templates

### 7.1 Interview guide

````markdown
# Interview guide — <initiative>

- **Learning goals**: 1) … 2) … 3) …
- **Format**: semi-structured, 45 min, two interviewers
- **Consent**: recording yes/no · attribution rules

## Frame (3 min)
- Purpose, duration, what happens with the notes, consent

## Context (7 min)
1. What is your role and how does it touch <topic>?
2. Walk me through a typical day / a typical case.

## Core (25 min)
3. Tell me about the last time <situation>.
4. What do you do when <system/rule> blocks you?
5. How often does <event> happen, and what does it cost you?
6. <goal-specific question>

## Risks and politics (8 min)
7. What would make this project fail?
8. What has been tried before, and what happened?
9. Who else has a strong view on this?

## Close (5 min)
10. What should I have asked you?
11. Who should I talk to next?
````

### 7.2 Per-interview notes

````markdown
# Interview — <Name, role> — <YYYY-MM-DD>

- **Interviewers**: <names> · **Duration**: <min> · **Recorded**: yes/no
- **Stance**: supporter | neutral | sceptic · **Power/interest**: high/high

## Key quotes

> "…" — on <topic>

## Observations (SAID)

| # | Statement | Topic | Type | Confidence |
|---|-----------|-------|------|------------|
| 1 | Approvals are done by phone because the tool is too slow | approvals | fact | high |

## Interpretations (I THINK)

- …

## Constraints and non-negotiables

| Constraint | Source | Hard/soft |
|------------|--------|-----------|

## Pain points and workarounds

| Pain | Workaround used today | Frequency | Impact |
|------|----------------------|-----------|--------|

## Open questions and follow-ups

| # | Question | Ask whom | By when |
|---|----------|----------|---------|

## Artifacts requested / received

- <spreadsheet, checklist, screenshot>
````

### 7.3 Cross-interview synthesis

````markdown
# Stakeholder synthesis — <initiative>

- **Interviews**: <n> · **Period**: <dates> · **Roles covered**: …
- **Coverage gaps**: <roles not yet interviewed and why it matters>

## Themes

### Theme 1 — <name>
- **Agreement**: … (sources: I1, I3, I5)
- **Conflict**: <A says X, B says Y> (I2 vs I4)
- **Outlier insight**: … (I6)
- **Type**: fact | opinion | assumption — **Evidence needed**: …

## Conflicts requiring a decision

| # | Conflict | Positions | Decider | Method to resolve | Due |
|---|----------|-----------|---------|-------------------|-----|

## Constraints register

| Constraint | Type (legal/technical/political) | Hard/soft | Source |
|------------|----------------------------------|-----------|--------|

## Risks

| Risk | Likelihood | Impact | Mitigation | Owner |
|------|------------|--------|------------|-------|

## Recommended next steps

- <method> for <question>
````

---

## 8. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Interviewing only supporters | The objection arrives at go-live | Interview the sceptic early |
| Asking about the future ("would you use…") | Fiction recorded as data | Ask about the last real occurrence |
| Presenting your solution mid-interview | They evaluate your idea instead of describing their world | Understand first, validate later |
| One interviewer typing while talking | Shallow notes, missed threads | Two interviewers, or record with consent |
| Paraphrasing everything | Insight becomes your opinion | Keep verbatim quotes |
| Treating conflicting answers as noise | The real political problem gets averaged away | Escalate conflicts as decisions |
| No synthesis, just twelve note files | Nothing is learned collectively | Cluster into themes with source tags |
| Never reporting back | Stakeholders disengage; corrections never come | Summary within two days |
| Ignoring what they cannot articulate | Tacit knowledge stays invisible | Follow with `contextual-inquiry` |

---

## 9. Checklist

- [ ] Stakeholders mapped by power/interest and by role, including at least one sceptic
- [ ] 3–5 explicit learning goals written before the guide
- [ ] Guide built in five blocks with must-ask questions marked
- [ ] Consent, confidentiality, and attribution agreed at the start
- [ ] Questions are past-tense and story-eliciting, not hypothetical
- [ ] Verbatim quotes captured; observation separated from interpretation
- [ ] Artifacts (spreadsheets, checklists) requested
- [ ] "What should I have asked you?" and "Who else?" asked in every interview
- [ ] Summary sent back to each interviewee within two days
- [ ] Cross-interview synthesis with themes, conflicts, constraints, and risks
- [ ] Assumptions marked with the evidence that would settle them
- [ ] Follow-up method chosen per open question
