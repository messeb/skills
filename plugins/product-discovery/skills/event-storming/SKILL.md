---
description: Event Storming (Brandolini) — run Big Picture, Process Level, and Design Level workshops. Sticky-note grammar (events, commands, actors, policies, read models, external systems, hotspots), facilitation script, timeboxes, remote adaptation, and a Markdown template that captures the wall as a durable artifact including bounded contexts and aggregates.
---

# Event Storming

Goal of this skill: turn a fuzzy domain into a shared, visible model — a timeline of **domain events** that business and engineering both recognise as true — and harvest bounded contexts, aggregates, and open questions from it.

Use this skill when the domain is complex or contested, when nobody can draw the end-to-end flow, when you need bounded contexts before designing services, or when business and developers use the same words for different things.

Do **not** use it for a well-understood CRUD screen, a single user story (use `example-mapping`), or a pure UI question (use `design-thinking`).

---

## 1. Pick the level first

| Level | Question it answers | Participants | Duration | Output |
|-------|---------------------|--------------|----------|--------|
| **Big Picture** | What happens in this business, end to end? | 10–25, wide mix incl. sceptics | 2–4 h (up to a day) | Timeline, hotspots, candidate bounded contexts |
| **Process Level** | How does this one flow really work? | 6–12, deep knowledge of the flow | 2–4 h per flow | Commands, actors, policies, read models, external systems |
| **Design Level** | How do we implement this? | 3–6, mostly developers + 1 domain expert | 2–4 h per aggregate | Aggregates, invariants, command→event contracts |

Run them in order when the domain is new. Jump straight to Process or Design only when the Big Picture already exists and is agreed.

---

## 2. Intake — ask before facilitating

Ask only for what the conversation has not already answered. Batch the questions into one message; keep it to five or fewer. If the answer is "you decide", proceed and mark each guess as **⚠️ Assumption** in the output.

1. **Domain / scope** — which business area, and where does it start and end? (name the first and last event you care about)
2. **Level** — Big Picture, Process Level, or Design Level? (if unsure: how well does the team already agree on the end-to-end flow?)
3. **Trigger** — why now? New system, re-platforming, service split, onboarding, an ongoing dispute?
4. **Participants** — who is in the room, which roles, and who is the one person whose absence would invalidate the result?
5. **Format** — physical wall, or remote tool (Miro/FigJam/Mural)? How long do you have?

Follow-ups only if relevant: existing systems the flow touches, regulatory constraints, whether a glossary already exists, prior modeling artifacts.

---

## 3. The sticky-note grammar

Colour is convention, not law — but be consistent and put the legend on the wall.

| Element | Colour | Notation | Rule |
|---------|--------|----------|------|
| **Domain event** | orange | past tense verb: `Order Placed`, `Payment Captured` | Something that happened, relevant to a domain expert. The only element in a Big Picture pass. |
| **Command** | blue | imperative: `Place Order`, `Capture Payment` | The intent that causes an event. |
| **Actor / role** | small yellow | `Customer`, `Dispatcher` | The person issuing the command. Stick it on the command. |
| **Aggregate / system** | large pale yellow | noun: `Order`, `Shipment` | The thing that receives the command and decides. Consistency boundary. |
| **Policy / reaction** | lilac | `Whenever … then …` | Business rule that turns an event into the next command. Reads as "whenever X happens, do Y". |
| **Read model** | green | `Order Summary`, `Available Slots` | The information the actor needs to decide. |
| **External system** | pink | `Payment Provider`, `SAP` | Outside your control. |
| **Hotspot** | red, rotated 45° | a question or a conflict | Disagreement, unknown, risk, pain. Never resolve it live — park it. |
| **Opportunity** | green rotated / different shape | `We could …` | Improvement idea, kept out of the model flow. |

Grammar to teach in one sentence: **actor** issues a **command** against an **aggregate**, which emits an **event**, which triggers a **policy**, which issues the next **command** — and the actor decides using a **read model**.

---

## 4. Facilitation script

### Setup (before people arrive)

- Unlimited modeling space: 8+ metres of paper roll, or an intentionally huge remote board.
- Sticky notes and one marker per person. Everyone writes — no scribe.
- Legend visible. Timeline direction marked with a big arrow.
- Rule poster: *no discussion during writing*, *past tense*, *one event per note*, *red note instead of an argument*.

### Phase 1 — Chaotic exploration (30–45 min)

1. State the scope: "everything from `<first event>` to `<last event>`".
2. Everyone writes domain events in past tense, in silence, and sticks them roughly on the timeline. No ordering discipline yet.
3. Facilitator does not curate. Keep pushing volume: "the wall is too empty".
4. Stop when the flow of new notes dries up, not when the time ends.

### Phase 2 — Enforce the timeline (30–60 min)

1. Sort left to right. Duplicates stack; near-duplicates go side by side until the group picks the right word.
2. Alternative and error flows go **below** the happy path, aligned to the same point in time.
3. Every naming argument becomes a **hotspot**, not a debate. Write the disputed terms on it.
4. Walk the timeline aloud from start to end. The walkthrough exposes gaps faster than any review.

### Phase 3 — Pivotal events and boundaries (20–40 min)

1. Mark **pivotal events** — the ones where responsibility, state, or vocabulary visibly changes (`Order Confirmed`, `Shipment Dispatched`). Draw a vertical line through them.
2. The chunks between pivotal lines are **candidate bounded contexts**. Name them with the language used inside the chunk.
3. Sanity-check each candidate: does one team own it? Is the vocabulary internally consistent? Would it survive being a separate deployable?

*Big Picture ends here.* Capture the wall, then decide which flows deserve a Process pass.

### Phase 4 — Process level (per flow)

1. Add the **command** before each event and the **actor** on the command.
2. Add the **read model** the actor consults before issuing the command — "what do you look at to decide?"
3. Add **policies** between an event and the next command. Watch for the phrase "and then someone has to…" — that is a policy or a missing automation.
4. Add **external systems** and mark every crossing as an integration point.
5. Question every automatic-looking arrow: is it truly automatic, or is a human deciding?

### Phase 5 — Design level (per aggregate)

1. Group `command → aggregate → event` triplets around one candidate aggregate.
2. For each aggregate, state its **invariants** — what must always be true inside it.
3. Test the boundary: can the aggregate decide with only its own state? If it needs another aggregate's data to accept a command, either the boundary is wrong or the rule is eventually consistent.
4. Note the concurrency and consistency assumptions per aggregate.

### Close (15 min)

Walk the wall once more, read the hotspots aloud, assign an owner and a next action to each, and agree the follow-up method for each open question.

---

## 5. Timeboxes

| Big Picture (half day) | Process Level (half day) |
|------------------------|--------------------------|
| 15 min — intro, legend, rules | 10 min — recap of the Big Picture slice |
| 40 min — chaotic exploration | 45 min — commands + actors |
| 45 min — enforce timeline | 30 min — read models |
| 15 min — break | 15 min — break |
| 30 min — pivotal events, contexts | 45 min — policies + external systems |
| 20 min — hotspot harvesting | 30 min — walkthrough + hotspots |
| 15 min — next steps | 15 min — next steps |

---

## 6. Remote adaptation

- Use one frame per phase, and lock earlier frames when a phase closes.
- Pre-build the legend and a stack of pre-coloured notes so nobody hunts for colours.
- Silent writing works better remotely, not worse — enforce it.
- Cap at 12 participants per board; split into breakouts with identical scope and merge afterwards.
- Voice on, video optional, one shared pointer: the facilitator narrates the walkthrough while everyone follows the same cursor.
- Export the board as an image **and** transcribe it to the Markdown template below — a Miro board nobody opens is not documentation.

---

## 7. Output template

Write the harvested wall to `docs/discovery/event-storming-<scope>.md`.

````markdown
# Event Storming — <Scope>

- **Date**: <YYYY-MM-DD>
- **Level**: Big Picture | Process | Design
- **Facilitator**: <name>
- **Participants**: <name (role)>, …
- **Scope**: from `<First Event>` to `<Last Event>`
- **Board**: <link to Miro/FigJam frame>

## 1. Timeline (happy path)

| # | Event | Command | Actor | Aggregate / System | Notes |
|---|-------|---------|-------|--------------------|-------|
| 1 | Order Placed | Place Order | Customer | Order | |
| 2 | … | | | | |

## 2. Alternative and error flows

| Branches from | Condition | Events | Handled by |
|---------------|-----------|--------|------------|
| Order Placed | Payment declined | `Payment Declined` → `Order Cancelled` | Order, Payment |

## 3. Policies

| Trigger event | Policy | Resulting command | Automatic? |
|---------------|--------|-------------------|------------|
| Payment Captured | Whenever payment is captured, reserve stock | Reserve Stock | yes |

## 4. Read models

| Read model | Consumed by | Decision it supports | Source events |
|------------|-------------|----------------------|---------------|
| Available Slots | Dispatcher | Choose delivery window | Slot Reserved, Slot Released |

## 5. External systems

| System | Direction | Data exchanged | Failure mode / owner |
|--------|-----------|----------------|----------------------|
| Payment Provider | outbound + webhook | authorise, capture, refund | timeouts → retry queue; owner: Payments team |

## 6. Candidate bounded contexts

| Context | Pivotal event boundary | Core language | Candidate owner team |
|---------|------------------------|---------------|----------------------|
| Ordering | starts at `Order Placed`, ends at `Order Confirmed` | order, line item, basket | Team A |

## 7. Aggregates (design level only)

| Aggregate | Commands | Events | Invariants | Consistency |
|-----------|----------|--------|------------|-------------|
| Order | Place, Confirm, Cancel | Placed, Confirmed, Cancelled | total = Σ lines; cannot confirm without payment | strong, single transaction |

## 8. Hotspots

| # | Hotspot | Type | Impact | Owner | Next action | Due |
|---|---------|------|--------|-------|-------------|-----|
| H1 | Two meanings of "cancelled" | naming conflict | high | <name> | glossary decision | <date> |

## 9. Ubiquitous language (harvested)

| Term | Definition agreed in the room | Terms it replaces |
|------|-------------------------------|-------------------|
| Order | A confirmed customer purchase intent with at least one line | "booking", "job" |

## 10. Decisions and next steps

- **Decided**: …
- **Open**: …
- **Next method**: <Domain Storytelling for flow X / Example Mapping for story Y / ADR for decision Z>
````

---

## 8. Anti-patterns

| Anti-pattern | Why it breaks the session | Do instead |
|--------------|---------------------------|------------|
| Present-tense or noun notes (`Order`, `Send mail`) | Removes the timeline; turns into a data model | Enforce past tense, one event per note |
| One person writing while others talk | The loudest voice becomes the model | Everyone writes, silence during writing |
| Debating a term for ten minutes | Burns the room's energy on 1% of the wall | Red hotspot, move on, resolve after |
| Starting with commands and aggregates | Jumps to solution before the flow is agreed | Events only in the first pass |
| Too few domain experts, too many developers | Produces a technical fantasy, not the business | At least a third from the business |
| Modeling the system you want to build | Discovers your assumptions, not the domain | Model the business as it happens today, then mark opportunities |
| A wall that is too small | Physically caps the model | Unlimited space is a rule, not a nicety |
| Session ends, board never transcribed | Knowledge evaporates in two weeks | Fill the template within 24 h |
| Resolving hotspots live | Derails into design | Park, assign, follow up with the right method |

---

## 9. Facilitator checklist

- [ ] Scope stated as a first and last event, agreed before starting
- [ ] Right people present — domain experts, not only proxies
- [ ] Legend and rules visible on the wall
- [ ] Unlimited modeling space
- [ ] Chaotic exploration ran until note flow dried up, not until the clock ran out
- [ ] Timeline enforced left-to-right, alternates below the happy path
- [ ] Full walkthrough performed aloud at least once
- [ ] Pivotal events marked; candidate contexts named
- [ ] Every hotspot has an owner, an action, and a date
- [ ] Ubiquitous language harvested into a glossary
- [ ] Board exported and transcribed into the template
- [ ] Follow-up method chosen per open question
