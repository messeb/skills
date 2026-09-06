---
description: Three Amigos sessions — business, development, and testing review a story together before it is built. Covers the three perspectives and the questions each brings, session timing and cadence, the 25-minute format with example mapping, when to add a fourth amigo, remote and distributed adaptations, outputs and their destination, and Markdown templates for the session record.
---

# Three Amigos

Goal of this skill: put the three perspectives that usually disagree **in the same conversation before the code is written** — the one who knows what is wanted, the one who will build it, and the one who will try to break it.

Use this skill in refinement, immediately before pulling a story into an iteration, when a story keeps bouncing back in review, or whenever a defect turns out to be a misunderstanding rather than a mistake.

Do **not** use it as a status meeting, a sign-off ceremony, or a substitute for the discovery that decides *what* to build (`impact-mapping`, `story-mapping`).

---

## 1. The three perspectives

| Amigo | Typically | Brings | Signature question |
|-------|-----------|--------|--------------------|
| **Business** | Product owner, analyst, domain expert | Intent, rules, priority, what the user is really trying to do | *Why do we want this, and what happens if we do not?* |
| **Development** | Developer, architect | Feasibility, cost, hidden complexity, existing behaviour | *What is undefined here? What will this cost?* |
| **Testing** | Tester, QA engineer | Edge cases, failure modes, how it will be proven | *How do we know it works? What about when …?* |

The value is the **collision** of the three. Business says what should happen; development says what that implies; testing asks what happens when it does not. Any two of the three, and one class of defect goes undetected: without testing, the edge cases; without development, the impossible promises; without business, an elegant answer to the wrong question.

Roles are perspectives, not job titles. A single person can hold two — but not all three at once, and not silently.

---

## 2. When and how often

| Timing | Purpose |
|--------|---------|
| **During refinement, ahead of the iteration** | Default — leaves time to answer the open questions |
| **Immediately before development starts** | Refresh, confirm nothing has changed |
| **When a story stalls mid-development** | Resolve the ambiguity that was missed |
| **Before a story is accepted** | Only if the criteria were unclear — this is a symptom, not a practice |

Cadence that works: short and frequent — 25–30 minutes per story, several stories in a session, twice a week. A monthly two-hour meeting produces fatigue and shallow examples.

---

## 3. Session format

Run it as an `example-mapping` session; the four card colours give the conversation its structure.

| Step | Time | Content |
|------|------|---------|
| 1 | 2 min | Read the story aloud. If the room cannot restate it in one sentence, fix the story first |
| 2 | 3 min | Business states the intent and who it is for |
| 3 | 10 min | Rules — what must be true for this to be done (blue cards) |
| 4 | 8 min | Examples — concrete cases with real values (green cards), especially boundaries and failures |
| 5 | ongoing | Questions nobody can answer — parked with an owner (red cards), never debated live |
| 6 | 2 min | Verdict: ready · needs splitting · blocked |

Timebox hard at 25–30 minutes. A story that needs more is too big or too unclear; that is itself the finding.

**Add a fourth amigo** when the story touches their domain: operations (runnability, monitoring), security or privacy (data handling), design (UX behaviour and states), legal or compliance (regulatory rules), or support (what customers will ask). Add them for the specific story, not permanently — five people in every session kills the cadence.

---

## 4. What each amigo should actually ask

### Business

- Who is this for, and what do they do today instead?
- What is the rule when the value is exactly at the threshold?
- Which of these cases can we leave out of the first version?
- What must *not* change?

### Development

- Which existing behaviour does this alter?
- What data do we not have today?
- What is undefined if the external call fails?
- Is there a cheaper way to get the same outcome?

### Testing

- How will we prove it — and with what data?
- What happens with zero, one, many, and far too many?
- What happens if the user does it twice, or presses back?
- Which existing behaviour could this break?
- What is the failure mode nobody has mentioned?

---

## 5. Remote and distributed teams

- Shared board with the four card colours; everyone writes on it, not just the facilitator.
- Silent writing first for rules and examples — it prevents the loudest voice from setting the frame and works better remotely than in a room.
- Cameras on for the conversation; a shared cursor when walking the examples.
- Across time zones: run it asynchronously in two passes — business posts intent and rules, the others add examples and questions within 24 hours, then a 15-minute live call resolves only what is still open.
- Whatever the format, the outcome lands on the ticket, not in a chat thread.

---

## 6. Output template

Attach to the ticket; keep a copy in `docs/discovery/three-amigos-<story>.md` if the story is contractually relevant.

````markdown
# Three Amigos — <STORY-201: Cancel a booking inside the free window>

- **Date**: <YYYY-MM-DD> · **Duration**: 25 min
- **Business**: <name> · **Development**: <name> · **Testing**: <name> · **Fourth amigo**: <name (ops)>
- **Verdict**: ready | needs splitting | blocked

## Intent

<one or two sentences: who it is for and what changes for them>

## Rules agreed

| # | Rule | Source |
|---|------|--------|
| 1 | Cancellations more than 24 h before departure are free | fare policy §2 |
| 2 | The cancellation quote expires after 15 minutes | product decision, this session |

## Examples

| # | Rule | Example | Expected | Boundary? |
|---|------|---------|----------|-----------|
| 1.1 | 1 | departs in 25 h | full refund | no |
| 1.2 | 1 | departs in exactly 24 h | full refund | **yes** |
| 1.3 | 1 | departs in 23 h 59 m | 20 % fee | **yes** |
| 2.1 | 2 | confirm after 16 min | quote recalculated, user informed | yes |

## Open questions

| # | Question | Owner | Due | Blocking? | Answer |
|---|----------|-------|-----|-----------|--------|
| Q1 | Is the 24 h measured in local airport time or UTC? | <name> | <date> | yes | |

## Decisions taken in the session

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | Refund is asynchronous; the UI shows "refund on its way" | provider latency is outside our control |

## Consequences

- **Scope changes**: partial refunds moved to STORY-202
- **Scenarios to automate**: 1.1, 1.2, 1.3, 2.1 (see `gherkin-bdd`)
- **Other artifacts to update**: `state-machine-booking.md` (quote expiry), glossary term *cancellation quote*
````

---

## 7. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Only two amigos | One whole class of defect goes undetected | All three perspectives, every time |
| Business presents, others listen | It becomes a briefing; no collision, no discovery | Everyone asks; testing goes first on edge cases |
| Answering red cards in the session | 25 minutes becomes 90; energy gone | Park with an owner and a date |
| Testing invited "when there is something to test" | Edge cases arrive after the build | Testing is in the conversation before the code |
| Session held after development has started | Findings are expensive and unwelcome | Before pulling the story in |
| Ten stories in one long meeting | Fatigue, shallow examples | 25 minutes per story, short and frequent |
| Outcome left in chat | Rules re-litigated in review | Record on the ticket |
| Same six people in every session regardless of topic | Cadence dies; attendance drops | Three core amigos; a fourth only when relevant |
| Used as a sign-off gate | Becomes a ceremony people work around | It is a conversation; the verdict is a by-product |
| Story arrives with no draft at all | The session becomes story writing | Draft the story first, then examine it together |

---

## 8. Checklist

- [ ] All three perspectives present, and a fourth amigo when the story touches their domain
- [ ] Story drafted before the session, read aloud at the start
- [ ] Timebox of 25–30 minutes held
- [ ] Rules captured explicitly, with their source
- [ ] Concrete examples with real values, including every boundary
- [ ] Failure and error cases examined, not just the happy path
- [ ] Questions parked with an owner and a due date — none debated live
- [ ] Verdict taken: ready, split, or blocked
- [ ] Decisions and their rationale recorded
- [ ] Scenarios selected for automation
- [ ] Downstream artifacts to update identified (state machine, glossary, contracts)
- [ ] Outcome attached to the ticket, not left in a chat thread
- [ ] Blocking questions prevent the story from being pulled into the iteration
