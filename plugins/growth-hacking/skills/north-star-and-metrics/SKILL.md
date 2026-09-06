---
description: The measurement system for growth — choosing a north star metric that resists gaming, building a KPI tree from it, the AARRR pirate metrics with the questions each answers, cohort and retention analysis, unit economics (CAC, LTV, payback, contribution margin), leading versus lagging indicators, benchmarks and why to distrust them, and dashboard discipline.
---

# North star metric, KPIs, and unit economics

Goal of this skill: one metric the company optimises, a tree of measures that explain it, and unit economics that say whether growth is worth having.

Use this skill when teams disagree about what to optimise, when reporting is full of numbers nobody acts on, or before committing budget to a channel.

---

## 1. The north star metric

A north star is the single measure that best represents **value delivered to customers, in a way the business captures**. It aligns teams and settles arguments about priorities.

A good one is:

| Property | Test |
|----------|------|
| Reflects customer value | If it goes up, are customers better off? |
| Predicts revenue | Does it lead revenue rather than restate it? |
| Actionable by teams | Can product, marketing, and support each move it? |
| Hard to game | Could a team raise it without creating value? If yes, it is wrong |
| Understandable | Can everyone state it from memory? |

Examples of the shape (not to be copied — derive your own): *nights booked*, *messages sent between connected users*, *weekly active teams with ≥3 members*, *documents completed*, *minutes of content consumed by returning listeners*.

The most common mistake is choosing revenue itself. Revenue is the outcome, lags by weeks or months, and can be raised by discounting or aggressive pricing that destroys next year. The second most common is choosing registrations, which is trivially gameable and says nothing about value.

**The gaming test is the important one.** Ask each team: "how would you triple this metric without helping a single customer?" If the answer is easy, pick another metric or add a counter-metric — for example pair "activated accounts" with "activated accounts still active at day 30".

---

## 2. The KPI tree

Decompose the north star into inputs teams actually control.

```text
North star: weekly active teams with ≥3 members
├── New teams created
│   ├── Visitors  ×  Signup rate
│   └── Signup → first team created rate
├── Teams reaching ≥3 members
│   ├── Invites sent per new team
│   └── Invite acceptance rate
└── Teams staying active week over week
    ├── Week-1 retention
    ├── Week-4 retention
    └── Resurrection rate
```

Each leaf gets an owner and a current value. The tree does three jobs: it shows where the constraint is, it makes an experiment's expected effect calculable in advance, and it stops teams from optimising a metric that cannot move the top.

Keep it to two or three levels. A tree with sixty leaves is a reporting exercise.

---

## 3. AARRR — the pirate metrics

A diagnostic frame, not a plan. Each stage answers one question:

| Stage | Question | Typical metrics |
|-------|----------|-----------------|
| **Acquisition** | How do people find us? | Visitors by channel, CPC, CPA, signup rate |
| **Activation** | Do they reach value quickly? | Rate reaching the activation event, time to value, onboarding completion |
| **Retention** | Do they come back? | D1/D7/D30 or W1/W4 retention, churn, DAU/MAU, resurrection |
| **Referral** | Do they bring others? | Invite rate, k-factor, NPS-linked referral, share rate |
| **Revenue** | Do we capture value? | Conversion to paid, ARPU, expansion, contribution margin |

Two rules for using it. **Work bottom-up when diagnosing**: retention before acquisition, always — acquisition into a leaking bucket is the single most expensive mistake in the model. And **define the activation event precisely**, because everything upstream is judged by it: not "signed up" but the specific action after which retention visibly improves (`activation`).

---

## 4. Cohort and retention analysis

Aggregate metrics hide everything that matters. A flat total user count can conceal 30% monthly churn masked by 30% monthly acquisition.

A retention curve by signup cohort answers the only question that matters early: **does the curve flatten?**

| Shape | Meaning |
|-------|---------|
| Decays to zero | No product-market fit; do not scale acquisition |
| Flattens above zero | A retained core exists — the height of the plateau is your business |
| Flattens then rises ("smile") | Expansion within accounts; strong signal |

Segment cohorts by acquisition channel, by plan, and by whether they hit the activation event. It is common for one channel to look cheapest on CPA and be worst on retention — a comparison that only exists if you cohort by source.

Choose the retention definition that matches the product's natural frequency: daily for a messaging app, weekly for a work tool, monthly for a bank, quarterly for insurance. Applying a daily definition to a monthly product manufactures a crisis; the reverse hides one.

---

## 5. Unit economics

| Metric | Definition | Trap |
|--------|-----------|------|
| **CAC** | Fully loaded acquisition spend ÷ new customers | Excluding salaries, tooling, and agency fees understates it badly |
| **Blended vs paid CAC** | All customers vs only paid-channel customers | Blended CAC hides a failing paid channel behind organic |
| **LTV** | Contribution margin per customer × expected lifetime | Using revenue instead of margin overstates it by the cost of goods |
| **LTV : CAC** | Rule of thumb ≥ 3 : 1 | Meaningless without a payback period |
| **Payback period** | Months until contribution margin repays CAC | The number that actually constrains cash |
| **Contribution margin** | Revenue − variable costs (COGS, payment fees, support, infrastructure) | Ignoring per-customer infrastructure and support cost |

Two disciplines. First, **use margin, not revenue**, in LTV — especially for products with real per-user costs (inference, storage, shipping, support). Second, **cap the lifetime horizon**: a "5-year LTV" for a two-year-old company is an extrapolation, not a measurement. Use a 12- or 24-month realised value and say which.

Payback matters more than ratio: a 3:1 LTV:CAC with 30-month payback consumes cash faster than a 2:1 with 4-month payback returns it.

---

## 6. Leading and lagging indicators

Lagging metrics (revenue, churn, LTV) confirm outcomes but arrive too late to steer. Leading indicators move first and let you act.

For each lagging metric, find a leading one and **validate the correlation before trusting it**:

| Lagging | Candidate leading |
|---------|-------------------|
| Monthly churn | Week-2 usage frequency; support tickets per account |
| Revenue | Qualified pipeline; activation rate |
| LTV | Feature adoption breadth in month one |
| Referral revenue | Invites sent in week one |

The validation step is what teams skip. An unvalidated leading indicator is a metric people optimise with no evidence it produces the outcome — and it will be optimised, because it is the one on the dashboard.

---

## 7. Benchmarks

Public benchmarks are useful for a sanity check and dangerous as a target, because definitions differ (is "activation" the same event?), populations differ (B2B enterprise versus consumer), and published figures are selected for being good.

Use them to detect **order-of-magnitude** problems: a 0.2% email open rate or a 40% monthly churn indicates something broken regardless of definition. For anything finer, your own trend is the only meaningful comparison. **Your baseline is your benchmark.**

---

## 8. Dashboard discipline

- One north star, visible everywhere, with the KPI tree one click away.
- Every metric has an **owner**, a **definition** written down, and a **target**.
- Definitions live in one place; "active user" means one thing company-wide.
- Show trend and variance, not a single number — a week-over-week figure without a control chart produces reaction to noise.
- Separate **decision dashboards** (few metrics, checked weekly, tied to actions) from **exploration tools** (everything, used when investigating).
- Instrument before launching, not after. Retrofitted tracking loses the baseline you needed for the comparison.
- Reconcile analytics against the billing system regularly; when they disagree, billing is right.

---

## 9. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Revenue as the north star | Lags too far; encourages discounting |
| Registrations as the north star | Trivially gamed; unrelated to value |
| A north star that passes the gaming test badly | Teams hit the target and the business does not improve |
| Aggregate totals without cohorts | Churn hidden behind acquisition |
| Retention window mismatched to product frequency | Invented crisis or hidden one |
| Blended CAC used to justify paid spend | A failing channel subsidised by organic |
| LTV from revenue rather than margin | Overstated payback; unprofitable growth funded |
| Unbounded LTV horizon | Extrapolation presented as measurement |
| LTV:CAC without payback period | Cash-flow failure at a "healthy" ratio |
| Leading indicators never validated | Teams optimise a proxy that does not produce the outcome |
| Public benchmarks used as targets | Chasing another company's definition |
| Metrics with no owner or written definition | Nobody acts; every meeting re-argues the numbers |
| Instrumentation added after launch | No baseline; the first result is uninterpretable |

---

## 10. Checklist

- [ ] One north star metric, reflecting customer value, understood by everyone
- [ ] Gaming test applied; counter-metric added where needed
- [ ] KPI tree built two to three levels deep, each leaf with an owner and a baseline
- [ ] AARRR stages instrumented; the activation event defined precisely
- [ ] Diagnosis works bottom-up: retention checked before scaling acquisition
- [ ] Retention analysed by cohort, segmented by channel, plan, and activation
- [ ] Retention window matched to the product's natural frequency
- [ ] Retention curve checked for flattening before acquisition spend increases
- [ ] CAC fully loaded; paid CAC reported separately from blended
- [ ] LTV based on contribution margin with a stated, bounded horizon
- [ ] Payback period tracked alongside LTV:CAC
- [ ] Leading indicators validated against their lagging outcome
- [ ] Metric definitions centralised; analytics reconciled against billing
- [ ] Decision dashboard separated from exploration tooling
- [ ] Instrumentation in place before launch, with a recorded baseline
