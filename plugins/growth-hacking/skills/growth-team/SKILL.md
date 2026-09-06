---
description: Building and running a growth team — the independent versus embedded model, the roles that make experiments possible, engineering access as the deciding factor, working agreements and decision rights, backlog and knowledge management, ramping a new team, and the organisational conditions that quietly prevent growth work from happening at all.
---

# Growth teams

Goal of this skill: a team that can actually change the product, not a marketing function renamed — plus the working agreements that keep experiments flowing.

Use this skill when standing up a growth practice, when experiments are constantly blocked by other teams' roadmaps, or when a growth hire is failing and nobody can say why.

---

## 1. Two models

| | **Independent growth team** | **Embedded growth roles** |
|---|---|---|
| Shape | A standalone cross-functional team with its own backlog | Growth responsibility inside product teams |
| Strength | Speed, focus, clear ownership of growth metrics | Deep product knowledge, no hand-offs, no boundary disputes |
| Weakness | Boundary friction with product teams; can be seen as outsiders | Growth work loses to feature work under pressure |
| Fits | Companies with a clear growth constraint and the scale to staff it | Smaller companies; product-led organisations |

Both work. What does not work is a **growth team without engineering capacity**, which can only run campaigns and rename itself marketing within two quarters.

The single best predictor of whether a growth practice succeeds is whether it can ship a change to the product this week without negotiating for someone else's roadmap.

---

## 2. Roles

| Role | Contributes | Can be shared |
|------|-------------|---------------|
| **Growth lead** | Strategy, constraint identification, prioritisation, decisions | No — needs a clear owner |
| **Engineer(s)** | Ships experiments, builds instrumentation, feature flags | No — this is the bottleneck if missing |
| **Analyst / data** | Instrumentation, analysis, validity checks | Sometimes |
| **Designer** | Flows, copy, prototypes | Often |
| **Marketer / channel specialist** | Channel execution and creative | Depends on the constraint |
| **Product manager** | Coordination with the roadmap | Often the growth lead |

A workable minimum for a small company: one growth lead, one engineer, part-time design and analytics. Below that, growth is a part-time activity — which is fine, as long as it is described honestly rather than staffed as a team on paper.

Skills worth hiring for over credentials: comfort with data and its limits, ability to ship small changes end to end, curiosity about mechanisms, and tolerance for being wrong in public.

---

## 3. Working agreements

Agree these once, in writing, and revisit them quarterly:

| Agreement | Typical answer |
|-----------|----------------|
| Which metrics does the team own? | The constraint stage plus the north star contribution |
| What can the team change without approval? | Copy, layout, onboarding flow, ad spend below a threshold, non-breaking product changes behind flags |
| What always needs approval? | Pricing, brand identity, legal/regulatory surfaces, anything touching payment or personal data |
| Who decides ship or kill? | The growth lead, on pre-registered criteria — not by consensus |
| What is the review path for legal or brand risk? | Named reviewer, expected turnaround, a fast lane for low-risk tests |
| What is the guardrail set no experiment may breach? | Revenue per visitor, refunds, support load, performance, accessibility |
| How much capacity goes to structural bets? | ~10%, protected |

The "can change without approval" line is the one that determines throughput. Every approval step adds days; the goal is a **pre-approved sandbox** wide enough for most experiments, with a genuinely fast lane for the rest — not permission-free chaos.

---

## 4. Cadence and artefacts

The rhythm is covered in `growth-process`; what the team owns is the artefact set that makes it cumulative:

| Artefact | Purpose | Kept where |
|----------|---------|-----------|
| Strategy page | Where growth is supposed to come from | One page, linked everywhere |
| KPI tree with owners | Where the constraint is | Dashboard |
| Idea backlog with scores | What could be run | Shared tracker |
| Experiment cards | What is running and why | One per experiment |
| Knowledge base of results and insights | What has been learned | Searchable, permanent |
| Channel and tactic register | What has been tried, when, and with what result | Prevents re-running dead channels |

The knowledge base is the asset. A three-year-old growth team with no searchable history has the institutional memory of a new one, and will re-run the same experiments as people rotate.

---

## 5. Ramping a new team

A sequence that avoids the common failure of launching experiments before anything can be measured:

1. **Weeks 1–2: instrumentation and baseline.** Verify tracking, reconcile analytics against billing, build the KPI tree, and record baselines. Experiments before this produce uninterpretable results.
2. **Weeks 3–4: find the constraint.** Retention and cohort analysis first. Pick one stage.
3. **Week 4: one deliberate quick win.** High confidence, low effort — to demonstrate the process works and buy credibility for the harder work.
4. **Weeks 5–12: build the rhythm.** Two to four experiments per cycle, weekly decisions, knowledge base populated from the first week.
5. **Quarter 2: structural bets.** Once the cadence is reliable and trusted, spend the protected capacity on loops and channels.

Report from week one on **cycle time, experiments completed, decisions taken, and insights recorded** — not only on wins. A team judged solely on wins in its first quarter will run only safe tests and never find a large lever.

---

## 6. Organisational blockers

The most common reasons growth practice fails have nothing to do with tactics:

| Blocker | Symptom | Remedy |
|---------|---------|--------|
| No engineering access | Only campaigns run | Dedicated engineering capacity, or accept a marketing-only scope honestly |
| Untrusted or absent analytics | Every result is disputed | Fix instrumentation first; nothing else matters until numbers are trusted |
| Approval chains | Two-week lead time on a copy change | Pre-approved sandbox and a fast lane |
| Growth metrics owned by nobody | Nobody accountable, nothing prioritised | Assign metric ownership explicitly |
| HiPPO overrides | Experiments overruled by seniority | Pre-registered criteria; decisions in the open |
| Failure treated as incompetence | Only safe tests proposed | Publish the expected failure rate; judge the portfolio |
| Growth seen as marketing's job | Product levers untouched | Cross-functional membership |
| Roadmap has no slack | Growth work always deprioritised | Protected capacity, agreed at leadership level |
| No knowledge base | Learning resets with every departure | Make write-up part of the definition of done |

Most of these are leadership decisions, not team decisions. If several are present, say so plainly before starting: a growth team launched into these conditions will fail, and the failure will be attributed to the team.

---

## 7. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Growth team with no engineer | Campaigns only; the product levers stay untouched |
| Hiring a "growth hacker" to fix growth alone | One person cannot change product, data, and channels |
| Team owns metrics it cannot influence | Accountability without agency |
| Ship/kill by consensus | Slow, conflict-averse decisions; losers survive |
| Every experiment needs legal and brand approval | Throughput collapses |
| Experiments launched before instrumentation | Uninterpretable results, wasted cycles |
| Judged on wins only, in the first quarter | Safe tests, no big levers |
| No knowledge base | Institutional memory resets |
| Growth team as a separate silo with no product relationship | Boundary disputes consume the calendar |
| Structural-bet capacity cut whenever delivery is late | Only incremental gains, forever |

---

## 8. Checklist

- [ ] Model chosen deliberately: independent team or embedded roles
- [ ] Dedicated engineering capacity secured — the deciding factor
- [ ] Growth lead named with decision rights over ship/kill
- [ ] Analytics and design access available, at least part-time
- [ ] Owned metrics agreed, and the team can actually influence them
- [ ] Pre-approved change sandbox defined in writing
- [ ] Fast lane agreed for legal and brand review, with a turnaround expectation
- [ ] Guardrail set defined that no experiment may breach
- [ ] Structural-bet capacity protected at leadership level
- [ ] Instrumentation verified and baselines recorded before the first experiment
- [ ] Constraint identified before ideas are generated
- [ ] One deliberate quick win planned early for credibility
- [ ] Knowledge base and channel register in place from week one
- [ ] Team reported on cycle time, decisions, and insights — not only wins
- [ ] Organisational blockers named openly before the programme starts
