---
description: Impact Mapping (Gojko Adzic) — build a Why → Who → How → What mindmap that ties every deliverable to a measurable business goal. Covers writing a testable goal, finding actors, distinguishing impacts from features, deriving minimal deliverables, prioritising and pruning branches, running it as a workshop, tracking outcomes, and a Markdown template for the map and the experiment plan.
---

# Impact Mapping

Goal of this skill: stop the feature list from being the plan. Make every deliverable traceable to a **measurable goal** through the **actor** whose **behaviour** must change — and make it obvious which branches can be cut.

Use this skill for roadmap and scope negotiation, when a stakeholder arrives with a solution instead of a problem, when a backlog has grown without a rationale, or when nobody can say what the release is supposed to achieve.

Do **not** use it to model a domain (`event-storming`), specify a story (`example-mapping`), or discover unmet needs (`jobs-to-be-done`) — an impact map assumes you already know roughly what you want to achieve.

---

## 1. The four levels

| Level | Question | Content | Test |
|-------|----------|---------|------|
| **Why** — Goal | Why are we doing this? | One measurable business goal with a metric, a baseline, a target and a deadline | Could a stakeholder tell in six months whether it was reached, without asking us? |
| **Who** — Actors | Who can produce or obstruct the effect? | Users, buyers, internal roles, partners, adversaries, regulators | Is it a *specific* group whose behaviour we could observe? |
| **How** — Impacts | How should their behaviour change? | Behaviour change, in their terms — not features | Is it something the actor *does differently*, that we could measure? |
| **What** — Deliverables | What could we do to support that? | Features, campaigns, process changes, removals | Is it the *cheapest* thing that could create that impact? |

The map is a mindmap: goal in the centre, actors around it, impacts branching from actors, deliverables branching from impacts.

Deliverables are **options, not commitments.** That single reframe is what makes the map a scope-negotiation tool.

---

## 2. Intake — ask before mapping

Ask only what is missing; batch into one message, five or fewer.

1. **What is the business goal**, and how would you measure it? What is the current baseline and the target by when?
2. **If a solution has been proposed already** — what would that solution achieve, in business terms?
3. **Who is involved** — which user groups, internal roles, partners, and who could obstruct the goal?
4. **Constraints** — budget, deadline, team capacity, regulatory limits?
5. **What is already running** — existing initiatives that also target this goal?

If the "goal" arrives as a feature ("we need a mobile app"), ladder up: *"What would the app change, and how would we notice?"* Repeat until you hit a number.

---

## 3. Writing a goal that works

A usable goal has: **metric · baseline · target · deadline · scope**.

| Weak goal | Why it fails | Rewritten |
|-----------|--------------|-----------|
| "Improve customer satisfaction" | No metric, no target | "Raise CSAT for delivery from 3.4 to 4.0 by Q4" |
| "Launch the mobile app" | It is a deliverable, not a goal | "Increase repeat orders from mobile from 12 % to 25 % within 6 months of launch" |
| "Reduce costs" | Which cost, by how much? | "Cut cost per processed claim from €14 to €9 by end of year" |
| "Be more agile" | Not observable | "Reduce lead time from merge to production from 9 days to under 1 day by Q3" |

One goal per map. If there are two goals, draw two maps — otherwise every branch will be justified by whichever goal is convenient.

---

## 4. Common mistake: impacts that are secretly features

The **How** level is where impact maps are usually wrong. An impact is a change in an actor's behaviour, described from the actor's side.

| Not an impact (feature in disguise) | Real impact |
|-------------------------------------|-------------|
| "Add a saved-basket function" | "Customers return to finish an abandoned order" |
| "Send push notifications" | "Drivers accept jobs within 2 minutes instead of 15" |
| "Build an admin dashboard" | "Support resolves a case without asking engineering" |
| "Introduce SSO" | "Employees log in once per day instead of five times" |

Test: put the actor as the subject and an active verb next. If the sentence needs *"we build …"*, it is a deliverable, not an impact.

Include **negative impacts** too — behaviours you must prevent (fraudsters exploiting a promotion, users churning after a price change). They generate real requirements.

---

## 5. Workshop script (2–3 h)

1. **Goal** (20–30 min). Write it, argue about the number, agree the metric and baseline. Most of the value of the session is here.
2. **Actors** (20 min). Silent brainstorm, then cluster. Prompt: who benefits, who pays, who operates it, who could block it, who could abuse it?
3. **Prune actors** (10 min). Keep those whose behaviour materially moves the metric.
4. **Impacts** (30–40 min). Per actor: what must they do differently? Also: what must they stop doing?
5. **Deliverables** (30 min). Per impact, brainstorm the cheapest options — including non-software ones (a phone call, a process change, a manual step, deleting a feature).
6. **Prioritise** (20–30 min). Pick the **shortest path from goal to impact**: choose the one or two impacts with the biggest expected effect, then the cheapest deliverable that could produce them.
7. **Turn into experiments** (15 min). Each chosen deliverable becomes a hypothesis with a measurement and a review date.
8. **Prune visibly** (5 min). Cross out the branches you are not doing — the visible crossing-out is the scope negotiation.

---

## 6. From map to plan

- Treat each deliverable as an **experiment**: *"We believe `<deliverable>` will cause `<impact>` for `<actor>`, contributing to `<goal>`. We will know we are right when `<metric>` moves by `<amount>` by `<date>`."*
- Deliver the cheapest deliverable per impact **first**, then measure before building the rest of the branch.
- Re-check the map at every milestone: an impact that did not move means the branch was wrong — cut it rather than adding more features under it.
- Use the map in stakeholder conversations: "This request sits under an impact we deprioritised — do you want to trade it against branch X?"

---

## 7. Output template

Write to `docs/discovery/impact-map-<goal-slug>.md`.

````markdown
# Impact Map — <goal name>

- **Date**: <YYYY-MM-DD> · **Owner**: <name> · **Participants**: …
- **Review date**: <YYYY-MM-DD>

## Why — Goal

| Metric | Baseline (as of) | Target | Deadline | Source of measurement |
|--------|------------------|--------|----------|----------------------|
| Repeat orders from mobile | 12 % (2026-08) | 25 % | 2027-02-28 | analytics event `order_placed`, channel=mobile |

**Goal statement**: <one sentence>

**Assumptions behind the goal**: …

## Map

```text
GOAL: Repeat mobile orders 12% → 25% by 2027-02-28
├── ACTOR: Returning customer
│   ├── IMPACT: Finishes an abandoned basket the next day
│   │   ├── DELIVERABLE: Basket persists across sessions        [chosen, first]
│   │   └── DELIVERABLE: Reminder email after 24 h              [option]
│   └── IMPACT: Reorders a previous order in under 60 s
│       └── DELIVERABLE: "Order again" on the order list        [chosen]
├── ACTOR: First-time customer
│   └── IMPACT: Completes checkout without creating an account  [deferred]
└── ACTOR: Support agent (obstructor)
    └── IMPACT: Stops advising customers to use the desktop site
        └── DELIVERABLE: Update support playbook               [chosen, non-software]
```

## Impacts

| # | Actor | Impact (behaviour change) | Expected contribution to goal | Measurement | Confidence |
|---|-------|---------------------------|-------------------------------|-------------|------------|
| I1 | Returning customer | Finishes abandoned basket next day | +6 pp | basket recovery rate | medium |

## Deliverables as experiments

| # | Deliverable | Supports | Hypothesis | Cost | Measure by | Result |
|---|-------------|----------|------------|------|------------|--------|
| D1 | Persistent basket | I1 | Recovery rate 4 % → 12 % | S | <date> | |

## Deprioritised branches (visible scope cut)

| Branch | Why cut | Revisit when |
|--------|---------|--------------|

## Risks and negative impacts to prevent

| Actor | Behaviour to prevent | Countermeasure |
|-------|----------------------|----------------|
````

---

## 8. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Goal without a metric | Every deliverable is justifiable | Metric, baseline, target, deadline |
| Impacts that are features | The map becomes a decorated backlog | Actor + active verb, no "we build" |
| Building every branch | The map's whole purpose is lost | Shortest path: one branch at a time |
| Only positive impacts | Abuse and obstruction go unplanned | Add obstructing actors and negative impacts |
| Only software deliverables | Cheaper non-software options missed | Include manual, process, and removal options |
| Actors as "users" | Too coarse to reason about behaviour | Name specific groups |
| Map drawn once and archived | Reality diverges silently | Review at every milestone; cut dead branches |
| Two goals in one map | Any branch can be justified by one of them | One map per goal |
| Treating deliverables as commitments | You lose the negotiation lever | State them as options |

---

## 9. Checklist

- [ ] Exactly one goal, with metric, baseline, target and deadline
- [ ] The goal is observable by a stakeholder without asking the team
- [ ] Actors are specific groups, including obstructors and abusers
- [ ] Every impact is a behaviour change phrased from the actor's side
- [ ] Negative impacts (behaviours to prevent) included
- [ ] Deliverables include non-software and removal options
- [ ] Shortest path chosen: one or two impacts, cheapest deliverable first
- [ ] Each chosen deliverable phrased as a testable hypothesis with a review date
- [ ] Cut branches visibly documented with a revisit condition
- [ ] Map linked from the backlog so tickets trace to an impact
- [ ] Review date scheduled
