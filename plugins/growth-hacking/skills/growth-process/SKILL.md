---
description: The operating rhythm of a growth team — the experiment cycle from idea to decision, weekly cadence and meeting structure, why learning beats optimizing, deciding between iterate, pivot and kill, never shipping a release untested, handling the emotional cycle of change, and the artefacts that make the process cumulative rather than repetitive.
---

# The growth process

Goal of this skill: a repeatable weekly cycle that converts ideas into evidence and evidence into decisions — fast enough to matter, disciplined enough to be trusted.

Use this skill when setting up a growth practice, when experiments are running without producing decisions, or when the team is busy but the numbers are flat.

---

## 1. The cycle

```text
   ┌──────────────────────────────────────────────────────────┐
   │                                                          │
Analyse ──► Ideate ──► Prioritise ──► Design ──► Run ──► Learn ┘
   ▲                                                     │
   └───────────── document, share, feed the backlog ──────┘
```

| Stage | Output | Owner |
|-------|--------|-------|
| **Analyse** | Where is the constraint? What does the data say? | Analyst / growth lead |
| **Ideate** | Ideas addressing that constraint (`idea-generation`) | Whole team |
| **Prioritise** | A ranked shortlist with a scoring rationale (`experiment-prioritization`) | Growth lead |
| **Design** | Hypothesis, metric, sample size, duration, stop rules (`experiment-design`) | Experiment owner |
| **Run** | Live test, monitored but not peeked at for decisions | Owner + engineering |
| **Learn** | Result, interpretation, decision, documented insight | Owner, reviewed by team |

The stage teams skip is **Analyse**, which is why they generate ideas for problems they do not have. Start every cycle from the constraint, not from the idea backlog.

---

## 2. Cadence

A weekly rhythm works for most teams. It is fast enough to build momentum and slow enough that experiments reach meaningful sample sizes.

| When | Meeting | Duration | Output |
|------|---------|----------|--------|
| Monday | **Growth meeting** | 45–60 min | Results reviewed, decisions taken, next experiments launched |
| Daily | **Stand-up** | 10 min | Blockers only — not status theatre |
| Monthly | **Retrospective on the process** | 45 min | How the practice itself improves |
| Quarterly | **Strategy review** | half day | Constraint re-assessed, bets re-set (`growth-strategy`) |

### The weekly growth meeting

A fixed agenda is what keeps it from becoming a status update:

1. **North star and KPI tree** — where are we against target? (5 min)
2. **Results from last week's experiments** — each owner presents the number, the decision, and the insight. (20 min)
3. **Decisions** — ship, kill, or iterate, taken in the room. (10 min)
4. **Next experiments** — the top of the prioritised backlog, launched with owners and dates. (15 min)
5. **Learnings into the knowledge base** — one line each. (5 min)

Rules that make it work: results are pre-written, not narrated from memory; a losing experiment gets the same airtime as a winner; nobody defends their idea, because ideas are not owned once they are tested; and **every experiment leaves the room with a decision** — "let's run it a bit longer" is only acceptable if the pre-registered duration has not elapsed.

---

## 3. Think big, iterate fast

Two failure modes sit at opposite ends. Teams that only run small tests (button colours, subject lines) produce a long list of 2% wins that never compound into anything. Teams that only run big bets ship rarely, learn slowly, and cannot attribute results.

Balance the portfolio deliberately — a rough split that works:

| Share | Type | Example |
|-------|------|---------|
| ~70% | Optimisation of the known constraint | Onboarding step order, pricing page layout, ad creative |
| ~20% | New tactics inside proven channels | A new content format, a different audience segment |
| ~10% | Structural bets | A new channel, a referral loop, a pricing model change |

The 10% is where step changes come from, and it is the first thing cut under pressure. Protect it explicitly, and give those bets a longer measurement window and a lower bar for "interesting".

---

## 4. Learning beats optimizing

An experiment produces two things: a **result** (this variant won by 8%) and an **insight** (users need reassurance about data security at the payment step). The result is worth one improvement. The insight is worth a dozen future experiments — and is the only thing that makes the practice cumulative.

Force the insight out of every test by asking three questions at the Learn stage: *why do we think this happened?*, *what does this tell us about our users that we did not know?*, and *what should we test next because of it?*

A losing test that produces a validated insight is more valuable than a winning test nobody can explain. And a winning test nobody can explain is a risk — it will be over-generalised and applied where the mechanism does not hold.

Keep a **searchable knowledge base**: hypothesis, variant, result, decision, insight, date, owner. A team without one re-runs the same experiment every eighteen months as people change.

---

## 5. Optimize before you pivot

When a channel or feature underperforms, the reflex is to abandon it. Usually the first version was simply bad.

Work through this sequence before declaring something dead:

1. **Was it implemented properly?** Tracking correct, targeting sane, page actually working on mobile.
2. **Was it given enough time and volume?** Most channels need several iterations; ad platforms need a learning period.
3. **Have you tested the big levers?** Offer, audience, and landing experience move results far more than creative details.
4. **Is the failure upstream?** A channel that "fails" often converts fine and then churns — that is a product problem wearing a channel costume.
5. **Have you tested at least three meaningfully different approaches?** One creative and one audience is not a test of a channel.

Only then decide to pivot away. Record the decision and the evidence, so the channel is not re-proposed in six months without new information.

---

## 6. No release without a test

Every meaningful change ships behind a measurement:

| Change | Minimum |
|--------|---------|
| Copy, layout, pricing page | A/B test |
| New feature | Feature flag, staged rollout, activation and retention monitored |
| Onboarding change | Cohort comparison against the previous flow |
| Pricing change | New customers only, with a holdout, and grandfathering considered |
| Infrastructure or performance | Guardrail metrics, since speed changes affect conversion |

Where a controlled test is impossible — a brand campaign, a rebrand, a legal change — say so explicitly, define the before/after comparison and its confounders in advance, and label the result as directional.

**Guardrail metrics** matter as much as the target metric: an experiment that lifts conversion 10% while raising refunds 15% is a loss. Declare guardrails before launch, not after a suspicious result.

---

## 7. The emotional cycle of change

Introducing this practice into a team that has never worked this way follows a predictable arc: initial enthusiasm, then a trough when the first experiments fail and the effort is visible but the results are not, then gradual confidence as wins accumulate, then routine.

The trough is where growth programmes are cancelled. What gets a team through it:

- **Publish the failure rate early.** If everyone expects 70–80% of experiments to fail, failures stop reading as incompetence.
- **Report learning, not just wins**, from the first week.
- **Bank a quick win deliberately.** Choose one high-confidence, low-effort experiment early — not because it is the biggest lever, but because it demonstrates the process works.
- **Protect the team from being judged on individual test outcomes.** Judge them on cycle time, decision quality, and cumulative effect.
- **Name the trough in advance** so that when it arrives it looks like the plan rather than a failure of the plan.

---

## 8. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Starting from the idea backlog instead of the constraint | Solving problems you do not have |
| Growth meeting as a status update | No decisions; the process becomes theatre |
| Experiments with no pre-declared success criterion | Results reinterpreted until positive |
| Stopping a test early because it looks good | False positives; the win does not replicate |
| Only small optimisation tests | Many 2% wins, no step change |
| Only big bets | Slow cycle, unattributable results |
| Results recorded but no insight extracted | The practice never becomes cumulative |
| No knowledge base | The same experiment re-run every year |
| Abandoning a channel after one weak attempt | Discarding a channel that needed a better offer |
| Shipping without guardrail metrics | Conversion up, refunds up, net negative |
| Judging individuals on individual test outcomes | People stop proposing risky, high-value tests |
| Cancelling the programme in the trough | The compounding never starts |

---

## 9. Checklist

- [ ] Cycle defined: analyse → ideate → prioritise → design → run → learn
- [ ] Each cycle starts from the current constraint, not the backlog
- [ ] Weekly growth meeting with a fixed agenda and pre-written results
- [ ] Every experiment leaves the meeting with ship / kill / iterate
- [ ] Portfolio balanced across optimisation, new tactics, and structural bets
- [ ] Structural-bet share protected under delivery pressure
- [ ] Insight extracted and written down for every experiment, including losses
- [ ] Searchable knowledge base of hypotheses, results, decisions, and insights
- [ ] Optimisation sequence worked through before abandoning a channel
- [ ] No meaningful release without a test or a declared measurement plan
- [ ] Guardrail metrics declared before launch
- [ ] Expected failure rate published so failures are not read as incompetence
- [ ] An early quick win planned to build credibility
- [ ] Team judged on cycle time and cumulative effect, not individual outcomes
