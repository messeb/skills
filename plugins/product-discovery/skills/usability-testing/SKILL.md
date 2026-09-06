---
description: Usability testing and prototype validation with real users — moderated and unmoderated studies, task design, the think-aloud protocol, participant recruitment and sample size, severity rating of findings, benchmark metrics (task success, time on task, SUS/SEQ), remote and accessibility testing, and Markdown templates for a test plan, a session note sheet, and a findings report.
---

# Usability testing and prototype validation

Goal of this skill: watch real users attempt real tasks on the actual artifact, and convert what breaks into prioritised, evidenced findings — before the behaviour is built or shipped.

Use this skill to validate a prototype (`prototyping`) before build, to check a redesign before release, to diagnose why a funnel drops, and to benchmark usability over time.

Do **not** use it to decide *what* to build (`jobs-to-be-done`, `contextual-inquiry`), to gather opinions (people are poor predictors of their own behaviour), or as a stakeholder demo — approval is not validation.

---

## 1. Choosing the study type

| Type | Answers | Participants | Cost | Caveat |
|------|---------|--------------|------|--------|
| **Moderated, in person or remote** | *Why* does it break? | 5–8 per role | medium | Moderator skill decides the data quality |
| **Unmoderated remote** | *How many* people struggle, on which step | 20–50 | low per participant | No follow-up questions; task wording must be perfect |
| **Guerrilla** | Quick read on obvious confusion | 5–8 | very low | Wrong population; use only for coarse checks |
| **Benchmark study** | Has it improved since last time? | 20+ per round | medium | Requires identical tasks and conditions across rounds |
| **Accessibility testing** | Is it usable with assistive technology? | 3–5 users of AT, plus an expert audit | medium | Never substitute an automated scan for a real screen-reader user |
| **A/B test** | Which variant performs better at scale? | thousands | low per user | Tells you *which*, never *why* |

**Sample size**: about five participants per distinct user group surfaces the majority of severe issues in a qualitative study — but that holds *per group*, and only for finding problems, not for measuring them. Anything you intend to quote as a percentage needs 20+ participants.

---

## 2. Intake — ask before running

Ask only what is missing; batch into one message, five or fewer.

1. **What decision does this inform**, and what would make you change the design?
2. **What is being tested** — paper, clickable prototype, staging build, live product? Which flows?
3. **Who are the users**, and how do we reach real ones? Which groups differ enough to need separate sessions?
4. **What are the tasks** people should be able to complete, phrased as real goals?
5. **Constraints** — recording consent, data protection, incentive budget, timeline, accessibility requirements?

If the artifact is a stakeholder demo rather than something a user can attempt, stop: there is nothing to test yet.

---

## 3. Task design — where most studies are won or lost

| Rule | Bad | Good |
|------|-----|------|
| Give a goal and a context, not instructions | "Click Cancel, then confirm" | "You can't travel on Friday any more. Sort it out." |
| Never use interface words from the design | "Use the Manage Booking section" | "Find your trip and change it" |
| Make it realistic and consequential | "Imagine you might book something" | "You need to be in Munich by 09:00 Tuesday; book it" |
| One goal per task | "Book a trip and add a passenger and pay by invoice" | Three separate tasks |
| Define success before the session | "See if they like it" | "Cancellation confirmed within 3 minutes without help" |
| Order tasks realistically and vary where possible | Always the same order | Rotate independent tasks to spread learning effects |
| Include a task that must fail gracefully | Only happy paths | "Try to cancel a trip departing in one hour" |

Give participants their own data where possible (their real trip, their real claim). Synthetic data hides the problems that real names, lengths, and volumes cause.

---

## 4. Running a moderated session (45–60 min)

1. **Welcome and consent** (5 min). Explain: we are testing the design, never you; there are no wrong answers; you can stop at any time. Get recording consent explicitly.
2. **Warm-up** (5 min). Their context and current habits — this also tells you whether they match the target group.
3. **Think-aloud instruction** (2 min). "Please say what you are thinking, what you expect, and what surprises you."
4. **Tasks** (30–40 min). Watch. Stay quiet.
5. **Post-task question** after each task: "How easy or difficult was that, on a scale of 1 to 7?" (SEQ) plus "what would you have expected?"
6. **Wrap-up** (5–10 min). Overall impressions, the standard instrument if you use one (SUS/UMUX-Lite, see `questionnaires`), anything they wanted to say.
7. **Debrief immediately** (10 min). Top findings while they are fresh.

**Moderator discipline** — the difference between data and noise:

| Do | Do not |
|----|--------|
| Wait. Silence is the most productive tool you have | Rescue at the first hesitation |
| Bounce questions back: "what would you expect to happen?" | Answer "where is X?" |
| Ask about what you saw: "you paused there — what were you thinking?" | Ask "would you use this?" |
| Note the exact words they use for things | Explain the design or defend it |
| Record where they looked and where they went first | Lead: "was that confusing?" |
| Let them fail completely before offering help, then note the assist | Count an assisted task as a success |

---

## 5. Analysing and rating findings

1. **Log observations per participant per task**: what happened, what they said, where they went, whether they succeeded unaided.
2. **Aggregate across participants** — a problem seen by one person is a signal; by four out of six it is a fact.
3. **Rate severity** on frequency × impact × persistence:

   | Severity | Definition | Response |
   |----------|------------|----------|
   | **Critical** | Task cannot be completed, data is lost, or the user is misled about a consequence | Fix before release |
   | **Serious** | Significant delay or frustration; a workaround exists | Fix in this release |
   | **Minor** | Noticeable friction, task still completed | Backlog |
   | **Cosmetic** | Polish | Opportunistic |

4. **Separate observation from interpretation from recommendation** — reviewers must be able to disagree with your recommendation while still accepting your data.
5. **Quantify only what your sample supports.** With six participants, say "4 of 6", never "67 % of users".
6. **Report metrics** where you collected them: task success rate (unaided), time on task, error count, assists, SEQ per task, SUS overall.
7. **Route each finding**: design change, content change, requirement change, or a new open question.

---

## 6. Output templates

### 6.1 Test plan

````markdown
# Usability test plan — <artifact>

- **Decision it informs**: <what changes based on the result>
- **Artifact**: <prototype link / build> @ <version> · **Type**: moderated remote
- **Participants**: 6 <primary role> + 3 <secondary role>; recruited via <channel>; incentive <x>
- **Sessions**: 50 min · **Dates**: <range> · **Moderator**: <name> · **Notetaker**: <name>
- **Consent**: recording, retention <n> months, anonymised reporting
- **Success criteria**: ≥ 5/6 complete T1 unaided within 3 min; no critical findings on T1–T2

## Tasks

| # | Task (as read to the participant) | Success definition | Data used | Max time |
|---|-----------------------------------|--------------------|-----------|----------|
| T1 | "You can't travel on Friday. Sort it out." | Booking cancelled or changed, unaided | participant's own booking (or a realistic seeded one) | 5 min |
| T2 | "Check what you'll get back before you confirm." | Locates and correctly reads the refund breakdown | as T1 | 3 min |
| T3 | "Try to cancel the trip that leaves in one hour." | Understands why it is not possible and finds the alternative | seeded booking | 3 min |

## Metrics collected

Task success (unaided / assisted / failed) · time on task · errors · SEQ per task · SUS at the end
````

### 6.2 Session notes

````markdown
# Session — P4 — <date>

- **Role**: support agent, 3 years · **Device**: laptop, Chrome · **Consent**: recorded ✅

| Task | Outcome | Time | Observations (OBS) / quotes (SAID) | SEQ |
|------|---------|------|-------------------------------------|-----|
| T1 | assisted | 4:10 | OBS: went to "My trips" three times, never opened the trip detail. SAID: "I thought cancelling would be on the list, not inside." | 3 |
| T2 | success | 0:50 | OBS: read the fee row aloud, then hesitated. SAID: "Is that taken off, or on top?" | 5 |
| T3 | success | 1:20 | OBS: understood immediately; looked for a phone number. | 6 |

**Top three from this session**: entry point to cancellation is hidden in the list view · fee wording is directional-ambiguous · users expect a support contact when blocked.
````

### 6.3 Findings report

````markdown
# Usability findings — <artifact> — <date>

- **Method**: moderated remote, 6 + 3 participants, 50 min · **Artifact** @ <version>
- **Limitations**: prototype without real payment; participants recruited from existing customers only

## Summary

| Metric | Result | Target |
|--------|--------|--------|
| T1 success unaided | 3 / 6 | ≥ 5 / 6 |
| Median time T1 | 3:50 | ≤ 3:00 |
| SUS | 68 | ≥ 75 |

**Verdict**: the cancellation entry point fails; recommend a fix and a re-test before build.

## Findings

| # | Finding | Evidence | Severity | Affects | Recommendation | Owner | Status |
|---|---------|----------|----------|---------|----------------|-------|--------|
| F1 | Cancellation is not discoverable from the trip list | 4/6 searched the list repeatedly; P4, P2, P5, P6 | **critical** | T1 | Surface a "Change or cancel" action on the list item | design | open |
| F2 | Fee wording is directionally ambiguous ("fee €20") | 3/6 asked whether it was added or deducted; P4 quote | serious | T2 | "€20 fee deducted — you receive €80" | content | open |
| F3 | Blocked state offers no route forward | 2/6 looked for a phone number | serious | T3 | Add support contact and rebooking link to the blocked state | design | open |

## What worked

- Refund breakdown was read correctly once found (6/6)
- Confirmation state was unambiguous (6/6)

## Next steps

| Action | Owner | Due |
|--------|-------|-----|
| Revise entry point, re-test with 5 participants | <name> | <date> |
| Update `prototyping` state inventory and STORY-201 criteria | <name> | <date> |
````

---

## 7. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Testing with colleagues | They know the domain and the design; nothing breaks | Recruit real users from the target group |
| Instructional tasks naming the UI | You test reading comprehension, not the design | Goal-based tasks in the user's words |
| Moderator rescuing on the first hesitation | The finding disappears | Wait; let them fail; note the assist |
| Asking "would you use this?" | Polite predictions, not behaviour | Watch what they do; ask about past behaviour |
| Counting assisted tasks as successes | Metrics look fine while the design fails | Unaided success only |
| "67 % of users" from six participants | False precision that spreads unchallenged | "4 of 6" |
| Only happy-path tasks | Error and blocked states, where users actually suffer, untested | Include tasks that must fail gracefully |
| Findings without severity or evidence | Everything is argued on opinion | Frequency × impact × persistence, with participant references |
| Recommendations without separated observations | Reviewers cannot disagree with the fix without rejecting the data | Observation, interpretation, recommendation as distinct layers |
| Stakeholder demo counted as validation | Approval without evidence | Real users attempting real tasks |
| Accessibility checked only by an automated scan | Most barriers are invisible to scanners | Test with assistive technology users |
| Testing once, never re-testing after the fix | You never learn whether the fix worked | Re-test the critical findings |

---

## 8. Checklist

- [ ] Decision the study informs is written down, with what would change the design
- [ ] Real users from the target group recruited; separate sessions per distinct role
- [ ] Sample size fits the claim: qualitative findings ~5 per group; percentages need 20+
- [ ] Tasks phrased as goals, free of interface vocabulary
- [ ] Success defined per task before the session
- [ ] At least one task that must fail gracefully
- [ ] Realistic or participant-owned data used
- [ ] Consent, recording, retention, and anonymisation agreed
- [ ] Think-aloud instruction given; moderator stays silent and does not lead
- [ ] Unaided vs assisted recorded per task
- [ ] Observations, quotes, interpretations, and recommendations kept separate
- [ ] Findings aggregated across participants and severity-rated
- [ ] Metrics reported with the denominator
- [ ] Limitations of the study stated
- [ ] Accessibility validated with assistive technology users, not only a scan
- [ ] Critical findings re-tested after the fix
