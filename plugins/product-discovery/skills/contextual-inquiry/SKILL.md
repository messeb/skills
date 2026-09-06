---
description: Contextual inquiry and field observation (Beyer/Holtzblatt) — watch people do the actual work in their own environment to uncover the gap between what they say and what they do. Covers the master/apprentice model, the four principles, session script, artifact and workaround capture, interpretation sessions, work models, and Markdown templates for field notes and synthesis.
---

# Contextual inquiry and observation

Goal of this skill: see the work as it actually happens — including the workarounds, the second screen, the paper note, the colleague they shout across the room to — none of which appears in an interview or a process document.

Use this skill for operational roles (dispatch, support, warehouse, clinical, finance ops), when the documented process and reality have clearly diverged, when users cannot articulate what they do because it is habitual, or before replacing a tool that people have bent to their needs for a decade.

Do **not** use it when the work is not observable (strategy, rare annual events), when access is impossible, or when you only need opinions (use `stakeholder-interviews`).

---

## 1. The core model: master and apprentice

You are the apprentice; the worker is the master. Apprentices watch, ask about what they see, and never instruct.

Four principles (Beyer & Holtzblatt):

| Principle | Meaning | In practice |
|-----------|---------|-------------|
| **Context** | Go where the work happens, watch the real thing | Their desk, their shift, their live system — not a meeting room, not a demo |
| **Partnership** | Shared inquiry, not interrogation and not a test | "Show me. What just happened there?" |
| **Interpretation** | Turn observations into shared meaning **with** the user | "So you copy it to the spreadsheet because the export drops the notes — right?" |
| **Focus** | A stated focus keeps the session useful, but stay open to surprises | Declare the focus, then follow the interesting deviation |

---

## 2. Intake — ask before going into the field

Ask only what is missing; batch into one message, five or fewer.

1. **Which work, which role, and where** does it physically happen?
2. **What is the focus** — one or two questions the observation must answer?
3. **Access** — who approves it, is a shift needed, what is off-limits (customer data, patient data, trading floor rules)?
4. **Timing** — when is this work representative? Peak vs quiet, end of month, night shift?
5. **Constraints** — can you record, photograph, or take screenshots? Any NDA, GDPR, or safety induction requirements?

Confirm explicitly: is the person being observed **volunteering**, and do they understand this is not a performance review? If their manager arranged it without asking them, fix that before starting.

---

## 3. Session script (90–180 min per person)

1. **Conventional interview** (15 min) — role, responsibilities, what a normal day looks like, what a bad day looks like. Sets context and calms nerves.
2. **Transition** (2 min) — state the shift explicitly: *"From here on, please just work as you normally would. I'll watch and interrupt with questions. Ignore me when you're busy — I'll ask afterwards."*
3. **Observation** (60–120 min) — they work, you watch and take notes. Ask about what you see, when it does not disturb them.
4. **Interpretation and wrap-up** (15–20 min) — read your understanding back and let them correct it. This is where most of the value is confirmed or destroyed.
5. **Immediate debrief** (15 min, alone or with your pair) — write the top five findings before the memory fades. Do not skip this; field notes decay within hours.

Observe **3–6 people** per role, across shifts and experience levels. Include one novice and one veteran — the difference between them is where the tacit knowledge lives.

---

## 4. What to record

| Look for | Why it matters | Note it as |
|----------|----------------|------------|
| **Workarounds** | The system's real gaps, priced in effort | tool, reason, frequency, cost |
| **Artifacts** | Spreadsheets, sticky notes, printed checklists, WhatsApp groups | photograph or copy (with permission) |
| **Interruptions** | Real workflow is not linear; design must survive them | trigger, what got lost, recovery cost |
| **Tool switching** | Integration gaps, copy-paste bridges | sequence of applications and what moved between them |
| **Waiting** | Latency the process document hides | what they waited for, how long, what they did meanwhile |
| **Errors and recoveries** | The real failure modes | trigger, detection, recovery, blast radius |
| **Communication** | Who they ask, and about what | channel, question, urgency |
| **Expertise cues** | Shortcuts and heuristics veterans use | phrase it as a rule and check it back with them |
| **Physical environment** | Noise, gloves, standing, two monitors, sunlight | affects any interface you design |
| **Emotion** | Sighs, muttering, visible relief | mark it — it flags severity |

Notation discipline: prefix every line with `OBS:` (what happened), `SAID:` (verbatim), or `INT:` (your interpretation). Timestamp the lines. Never merge the three.

---

## 5. Interpretation session

Within 48 hours, the observers meet (1–2 h per field session):

1. One observer reads their notes aloud in sequence; nobody skips ahead.
2. The group captures **affinity notes** — one insight per note, in the user's own language.
3. Build the relevant **work models**:
   - **Sequence model** — the actual step order, including interruptions and loops.
   - **Flow model** — who talks to whom, and about what.
   - **Artifact model** — what documents and tools carry the information.
   - **Cultural model** — pressures, norms, and unwritten rules ("we never say no to sales").
   - **Physical model** — the layout of the space and the screens.
4. Affinity-cluster across all sessions into themes.
5. Turn each theme into a design implication and an evidence tag.

---

## 6. Output templates

### 6.1 Field notes

````markdown
# Field notes — <role> — <site> — <YYYY-MM-DD>

- **Observer(s)**: <names> · **Duration**: <hh:mm–hh:mm> · **Shift**: <early/late/peak>
- **Participant**: <pseudonym>, <experience: 2 years> · **Consent**: verbal/written, photos yes/no
- **Focus question(s)**: …

## Context interview (summary)

- Role, responsibilities, a normal day, a bad day

## Timeline

| Time | OBS / SAID / INT | Content | Tool / artifact | Tag |
|------|------------------|---------|-----------------|-----|
| 09:12 | OBS | Copies 14 order numbers into Excel by hand | ERP → Excel | workaround |
| 09:14 | SAID | "The export forgets the notes, so I do it twice." | | quote |
| 09:15 | INT | Export lacks a field, cost ≈ 20 min/day | | implication |

## Workarounds observed

| Workaround | Reason | Frequency | Time cost | Risk it creates |
|------------|--------|-----------|-----------|-----------------|

## Artifacts collected

| Artifact | Type | Purpose | Owner | Copy/photo |
|----------|------|---------|-------|------------|

## Interruptions

| Time | Trigger | What was lost | Recovery time |
|------|---------|---------------|---------------|

## Errors and recoveries

| Error | Detected how | Recovery | Consequence if missed |
|-------|--------------|----------|-----------------------|

## Top 5 findings (written within 15 min of leaving)

1. …
````

### 6.2 Synthesis

````markdown
# Contextual inquiry synthesis — <work area>

- **Sessions**: <n> participants, <sites>, <shifts> · **Period**: <dates>
- **Focus questions**: …

## Say / do gaps

| Topic | What people say | What people do | Evidence |
|-------|-----------------|----------------|----------|
| Approvals | "we follow the four-eyes rule" | veterans pre-approve verbally, sign later | S2, S4, S5 |

## Sequence model — <task name>

| Step | Actor | Action | Trigger | Breakdown observed |
|------|-------|--------|---------|--------------------|

## Flow model

| From | To | About | Channel | Frequency |
|------|----|-------|---------|-----------|

## Artifact model

| Artifact | Created by | Used by | Information carried | Gap it fills |
|----------|------------|---------|--------------------|--------------|

## Cultural model — unwritten rules

| Rule | Evidence | Effect on the work |
|------|----------|--------------------|

## Themes and design implications

| # | Theme | Evidence (sessions) | Design implication | Severity |
|---|-------|--------------------|--------------------|----------|

## Requirements and opportunities

| # | Requirement / opportunity | Derived from | Priority |
|---|---------------------------|--------------|----------|

## Open questions and next method

| Question | Next method | Owner |
|----------|-------------|-------|
````

---

## 7. Ethics and access

- **Informed consent** from the person observed, not only from their manager. State that findings are not attributed to individuals and never go into a performance review.
- **Right to pause**: they can stop the observation at any moment, no reason needed.
- **Data protection**: blur or omit customer/patient data in photos and screenshots; follow the site's rules over your convenience.
- **Safety**: complete site induction, wear required PPE, respect exclusion zones.
- **Do not create work**: never ask someone to redo a task for your benefit — that is a demo, not an observation.
- **Report back to the observed**, not only upwards. They gave you the insight; show them what you learned.

---

## 8. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Watching a demo instead of live work | You see the process document acted out | Observe real work, unannounced order |
| Interviewing while they try to work | You destroy the very thing you came to see | Save questions for gaps and the wrap-up |
| Teaching or fixing their tool usage | They perform for you from then on | Apprentice, never instructor |
| Only observing the best performer | You miss the failure modes the system causes | Novice + veteran + average |
| Only during quiet hours | Peak behaviour is where the design fails | Observe at peak and at handover |
| Notes without the OBS/SAID/INT split | Interpretation gets treated as fact later | Tag every line |
| No interpretation session | Individual observers keep private, conflicting models | Meet within 48 h |
| Manager present in the room | Behaviour changes, workarounds get hidden | Observe without the line manager |
| Skipping the immediate debrief | Half the detail is gone by evening | Five findings before you leave the site |

---

## 9. Checklist

- [ ] Focus questions stated before entering the field
- [ ] Access approved and informed consent obtained from the person observed
- [ ] Observations scheduled when the work is representative (peak, handover, shift mix)
- [ ] 3–6 participants per role, novice and veteran included
- [ ] Master/apprentice stance held throughout — no instructing, no demoing
- [ ] Notes tagged OBS / SAID / INT with timestamps
- [ ] Workarounds, artifacts, interruptions, waiting, and errors explicitly captured
- [ ] Artifacts photographed or copied with permission and data protection respected
- [ ] Interpretation read back to the participant before leaving
- [ ] Top-five findings written within 15 minutes of the session
- [ ] Interpretation session held within 48 hours; work models built
- [ ] Say/do gaps documented with evidence tags
- [ ] Findings reported back to the observed people, not just to management
