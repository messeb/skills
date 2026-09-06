---
description: Facilitated cross-functional workshops and JAD (Joint Application Design) sessions — reach consensus fast with conflicting stakeholders. Covers the JAD role model, workshop design (purpose/outcome/agenda), divergence–convergence structure, decision protocols (dot voting, fist of five, consent, advice process), conflict handling, remote and hybrid setup, and a Markdown template for the agenda and the outcome record.
---

# Workshops and JAD sessions

Goal of this skill: get the right people into one structured session and leave with **decisions, not minutes** — especially when stakeholders disagree and asynchronous email would take six weeks to reach the same place.

Use this skill when a decision needs several parties at once, when requirements are contested, when a project starts and alignment is missing, or when a discussion has looped for weeks without converging.

Do **not** use it as a substitute for individual depth (`stakeholder-interviews` first), for observing real work (`contextual-inquiry`), or when the decision is already made and you only need to inform people — that is a memo, not a workshop.

---

## 1. JAD in one table

Joint Application Design puts business and IT in one room with a neutral facilitator and a documented outcome. The role split is what makes it work.

| Role | Responsibility | Rule |
|------|----------------|------|
| **Facilitator** | Runs the process, owns the agenda, stays neutral on content | Never argues for an outcome; never also the product owner |
| **Sponsor / executive** | Opens the session, states the mandate and the constraints, leaves the room | Presence for the whole session suppresses honesty |
| **Business participants** | Own the requirements and the decisions | Must have authority to decide, not just to report back |
| **Developers / architects** | Feasibility, cost, constraints, options | Do not design in the room; surface trade-offs |
| **Scribe** | Captures decisions, open items, and rationale live and visibly | Separate person from the facilitator |
| **Observers** | Listen only | Explicitly named and time-boxed if they may speak |

Non-negotiable: every participant either has decision authority or represents someone who delegated it in writing.

---

## 2. Intake — ask before designing the workshop

Ask only what is missing; batch into one message, five or fewer.

1. **What decision or outcome must exist when people leave?** Phrase it as a deliverable, not a topic.
2. **Who must be there** — names, roles, and who holds the authority to decide? Who will block it if absent?
3. **What is already decided and out of scope?** What is genuinely open?
4. **Where is the conflict?** Which two positions are currently incompatible, and why does each side hold theirs?
5. **Logistics** — how long, in person / remote / hybrid, how much prep can participants do beforehand?

If the answer to (1) is a topic rather than an outcome, stop and reframe it before scheduling anything.

---

## 3. Design the workshop backwards

1. **Outcome** — write the deliverable sentence: *"By 16:00 we have a ranked list of the five capabilities for release 1, agreed by Sales, Ops and Engineering."*
2. **Decision** — name who decides and by which protocol (see §5). Announce it at the start, not when the argument starts.
3. **Inputs** — what must be true before the session: pre-reads, interview synthesis, data, a draft to react to. A draft to shoot at converges faster than a blank wall.
4. **Steps** — pick the exercises that bridge inputs to outcome. Each step has a purpose, a timebox, and a visible artifact.
5. **Participants** — the smallest group that contains all necessary authority and knowledge. Above ~12, use breakouts.
6. **Risks** — who might derail it, and what is your plan (pre-brief the sceptic 1:1 before the session, never ambush them).

---

## 4. Structure: diverge, then converge

Every effective workshop alternates between opening up and narrowing down. Never mix the two in one step, and always say which mode you are in.

| Phase | Purpose | Techniques |
|-------|---------|------------|
| **Check-in** (5–10 min) | Get every voice in the room once | One sentence per person: expectation for today |
| **Frame** (10 min) | Purpose, outcome, agenda, decision protocol, working agreements | Facilitator; sponsor states the mandate and leaves |
| **Diverge** (20–40 min) | Surface everything | Silent writing (1-2-4-All), brainwriting, "how might we", pre-mortem |
| **Cluster** (15–25 min) | Find the structure | Affinity mapping, naming the clusters together |
| **Converge** (20–40 min) | Narrow the options | Dot voting, impact/effort grid, criteria scoring |
| **Decide** (15–30 min) | Take the decision | The announced protocol; capture the rationale |
| **Commit** (10–15 min) | Make it real | Owner + action + date for every item; nothing leaves unassigned |
| **Check-out** (5 min) | Close and improve | What worked, what to change next time |

**Silent-first is the single highest-leverage rule.** Individual silent writing before any discussion prevents the first speaker from anchoring the room and gives introverts and juniors equal weight.

---

## 5. Decision protocols

Announce which one applies **before** the discussion starts.

| Protocol | How | Best for | Watch out |
|----------|-----|----------|-----------|
| **Dot voting** | n dots per person, place on options, count | Narrowing many options fast | Herding — vote silently and simultaneously |
| **Fist of five** | 0 fingers = block, 5 = enthusiastic; anything ≤2 must be voiced | Testing agreement level quickly | Ask the 1s and 2s first, always |
| **Roman voting** | Thumb up / down / sideways | Binary go/no-go | Too coarse for nuanced options |
| **Consent** (not consensus) | "Any *objection* that would harm us?" — absence of objection decides | Working agreements, policies | Requires discipline about what counts as an objection |
| **Advice process** | The owner decides after seeking advice from those affected and those with expertise | Single-owner decisions with wide impact | Advice must be documented, or it feels fake |
| **Delegation levels** | Explicitly agree: tell / sell / consult / agree / advise / inquire / delegate | Recurring decision types | Do it once for the category, not per decision |
| **Sponsor decides** | Group informs, sponsor rules | Deadlocks, budget calls | Be honest about it up front — do not fake participation |

**Deadlock protocol:** if a decision does not converge in its timebox — write down the two positions, name what evidence would settle it, assign an owner and a date, and move on. Never let one item consume the session.

---

## 6. Handling conflict and dominance

| Situation | Move |
|-----------|------|
| One person dominates | "Let's hear from someone who hasn't spoken yet." Switch to silent writing or 1-2-4-All. |
| Hierarchy silences the room | Sponsor states the mandate then leaves; use anonymous input |
| Two entrenched positions | Have each side state the *other* side's position until it is accepted as fair, then look for the shared criterion |
| Argument about facts | Stop. Name the missing data, assign an owner, park it |
| Argument about values or priorities | Legitimate; make the trade-off explicit and use the decision protocol |
| Recurring off-topic themes | Parking lot on the wall, visible, reviewed before close |
| Hidden agenda / political veto | Pre-brief 1:1 before the workshop; never surprise a stakeholder in public |
| Energy collapse | Break, change modality (stand up, move, small groups) — never push through |

---

## 7. Remote and hybrid

- **Remote**: shared board + video, one frame per exercise, pre-built templates, breakout rooms of 3–4 for anything longer than 10 minutes, cameras on for discussion, silent timers visible. Max 90 minutes per block, then a real break. Split a full-day workshop into 3–4 shorter sessions across days.
- **Hybrid is the hardest mode**: default everyone to their own device and the same board, even the people in the room together. One shared room camera plus a shared board beats a conference-table setup where remote participants cannot read the wall.
- Assign a **remote advocate** whose only job is to pull remote participants into the conversation.
- Never make the artifact only physical if anyone is remote.

---

## 8. Output template

Send the outcome record within 24 hours, and put decisions before narrative.

````markdown
# Workshop — <title> — <YYYY-MM-DD>

- **Outcome statement**: <the deliverable sentence>
- **Facilitator**: <name> · **Scribe**: <name>
- **Participants**: <name (role, org)>, …  · **Absent but affected**: <names>
- **Decision protocol used**: <dot voting / consent / advice process / sponsor>
- **Board / recording**: <link>

## Decisions

| # | Decision | Rationale | Protocol | Decided by | Reversible? |
|---|----------|-----------|----------|------------|-------------|
| D1 | Release 1 covers capabilities A, B, C | Highest impact per effort, Ops capacity | dot vote + consent | group | yes, before <date> |

## Actions

| # | Action | Owner | Due | Depends on |
|---|--------|-------|-----|------------|
| A1 | Draft API contract for capability A | <name> | <date> | D1 |

## Open questions / parking lot

| # | Item | Why parked | Owner | Next step | Due |
|---|------|-----------|-------|-----------|-----|

## Dissent recorded

| Who | Position | Condition under which they would agree |
|-----|----------|----------------------------------------|

## Artifacts produced

- <clustered map, prioritised list, impact map, event storm — with links>

## Retrospective of the session

- Worked: … · Change next time: …
````

---

## 9. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Workshop with a topic instead of an outcome | Long discussion, no decision | Write the deliverable sentence first |
| Participants without decision authority | "I need to check with my boss" — six-week loop | Require delegated authority in writing |
| Sponsor sits through the whole session | People say what they think the boss wants | Sponsor opens, states the mandate, leaves |
| Discussion before individual thinking | The first speaker anchors everyone | Silent writing first, every time |
| Diverging and converging at once | Ideas get killed before they exist | Separate the modes explicitly |
| No announced decision protocol | The loudest or most senior voice wins by default | Announce it in the framing |
| Two hours on one contested item | The rest of the agenda dies | Deadlock protocol: park with owner and evidence needed |
| 20 people, one conversation | Most participants disengage | Breakouts of 3–5, then merge |
| Minutes as prose, decisions buried | Nobody knows what was agreed | Decisions and actions in tables, at the top |
| Ambushing a sceptic in public | Public entrenchment, veto later | Pre-brief 1:1 |
| No follow-up on actions | Trust in workshops collapses | Review actions at the start of the next session |

---

## 10. Checklist

- [ ] Outcome written as a deliverable sentence before scheduling
- [ ] Right people invited, each with decision authority or documented delegation
- [ ] Sceptics and blockers pre-briefed 1:1
- [ ] Sponsor slot planned: mandate stated, then leaves
- [ ] Facilitator neutral on content and not also the product owner
- [ ] Separate scribe assigned
- [ ] Agenda alternates diverge → cluster → converge → decide, with timeboxes
- [ ] Silent individual work precedes every group discussion
- [ ] Decision protocol announced during framing
- [ ] Deadlock protocol agreed in advance
- [ ] Parking lot visible and reviewed before close
- [ ] Every action has an owner and a date before anyone leaves
- [ ] Dissent recorded, not smoothed over
- [ ] Outcome record circulated within 24 hours, decisions first
- [ ] Remote/hybrid: shared board for everyone, remote advocate assigned
