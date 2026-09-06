---
description: Ranking growth ideas — the ICE, PIE and BRASS scoring models with worked examples, when each fits, calibrating scores so they mean the same thing across people, expected-value ranking from the KPI tree, effort estimation, portfolio balance, and the failure modes that make scoring theatre rather than decision support.
---

# Prioritizing experiments

Goal of this skill: decide which of forty ideas to run next, transparently enough that the decision survives challenge and consistently enough that scores mean something across people and weeks.

Use this skill in the weekly growth cycle, when the backlog is larger than capacity, or when prioritisation is being decided by whoever argues hardest.

---

## 1. The three common models

### ICE

`Score = (Impact + Confidence + Ease) ÷ 3`, each rated 1–10.

| Component | Question |
|-----------|----------|
| **Impact** | If it works, how much does the target metric move? |
| **Confidence** | How sure are we it will work, given evidence? |
| **Ease** | How cheap is it to run — build, design, and analysis? |

Fast and good enough for most teams. Its weakness is that all three rest on judgement, so scores drift between people unless calibrated (§3).

### PIE

`Score = (Potential + Importance + Ease) ÷ 3` — designed for conversion optimisation.

| Component | Question |
|-----------|----------|
| **Potential** | How bad is this page or step today? Worse means more room |
| **Importance** | How much valuable traffic passes through it? |
| **Ease** | How hard is it to change, technically and politically |

PIE's advantage over ICE for funnel work: *Potential* and *Importance* can be read from analytics rather than guessed. A poor page with heavy traffic outranks a mediocre page with little traffic, automatically.

### BRASS

A five-factor model aimed at channel selection rather than page tests:

| Component | Question |
|-----------|----------|
| **Blink** | Gut reaction — does this fit our product and audience at all? |
| **Relevance** | How well does the channel reach our actual target group? |
| **Availability** | How easily can we access it — cost, skills, tools, approvals? |
| **Scale** | How big is the reachable audience? |
| **Score** | Cost and effort to test |

BRASS is the right instrument when choosing **which of the many channels to try** (`idea-generation`), because it weighs reach and access rather than page-level potential. It is a poor fit for ranking A/B tests.

### Choosing

| Situation | Model |
|-----------|-------|
| Mixed backlog, fast weekly ranking | **ICE** |
| Funnel and conversion work with analytics available | **PIE** |
| Selecting new acquisition channels to test | **BRASS** |
| High-stakes decisions with real money attached | **Expected value** (§4) |

Pick one per backlog and stay with it. Two scoring systems in one backlog produce incomparable numbers and endless argument.

---

## 2. A worked example

| # | Idea | Impact | Confidence | Ease | ICE |
|---|------|-------:|-----------:|-----:|----:|
| 1 | Inline plan comparison in signup | 8 | 7 | 7 | **7.3** |
| 2 | Referral programme with double-sided incentive | 9 | 4 | 3 | **5.3** |
| 3 | Change CTA colour on the homepage | 2 | 6 | 10 | **6.0** |
| 4 | Onboarding checklist with progress | 7 | 6 | 5 | **6.0** |
| 5 | New pricing page structure | 8 | 5 | 4 | **5.7** |

The example shows the model's known weakness immediately: idea 3 scores as highly as idea 4 because it is trivially easy, despite being worth almost nothing. Guard against this by setting a **minimum impact threshold** — ideas scoring below, say, 4 on impact do not enter the ranking at all, however cheap they are. Ease should break ties, not create winners.

---

## 3. Calibration

Scores only work if a 7 means the same thing to everyone. Write the scale down.

**Impact** — anchor to the KPI tree, not to feeling:

| Score | Meaning |
|-------|---------|
| 9–10 | Moves the north star by >10% if it works |
| 7–8 | Moves a primary funnel metric by >5% |
| 4–6 | Moves a secondary metric measurably |
| 1–3 | Local improvement, no measurable effect on the tree |

**Confidence** — anchor to evidence, which is the component people inflate most:

| Score | Evidence |
|-------|----------|
| 9–10 | We have run this before and it worked here |
| 7–8 | Strong evidence from our own data or user research |
| 5–6 | It worked for a comparable company in a comparable context |
| 3–4 | Plausible reasoning, no direct evidence |
| 1–2 | Someone's hunch |

**Ease** — anchor to real cost including analysis and review, not just build time. A "quick" change that needs legal sign-off is not easy.

Practices that keep calibration honest: score independently and silently, then compare — discussing first anchors everyone to the first number spoken; discuss only where scores differ by three or more, since that is where the real disagreement lives; and periodically **check scores against outcomes** — if high-confidence ideas fail as often as low-confidence ones, the confidence scale is decorative.

---

## 4. Expected value, when the stakes justify it

For decisions with real budget attached, score models are too coarse. Estimate directly from the KPI tree:

```text
Expected value = reach × baseline conversion × expected relative lift × value per conversion × probability of success

Example — inline plan comparison:
  4,000 signups/month × 39% activation × +12% relative lift × €180 LTV × 0.5
  = 4,000 × 0.39 × 0.12 × 180 × 0.5 ≈ €16,850 per month if it ships

Cost to test: 4 dev-days + 2 design-days ≈ €5,000
```

This forces the two numbers score models hide: **how many people are actually affected**, and **what a conversion is worth**. It regularly reverses a ranking — a large lift on a page nobody visits loses to a small lift on the checkout.

Note the honest limitation: the probability and the lift are still estimates. The value of the calculation is that it makes those estimates explicit and challengeable rather than buried inside a "7".

---

## 5. Portfolio balance

Pure score ordering produces a backlog of safe, cheap, small tests, because certainty and ease are rewarded and boldness is not. Reserve capacity instead of relying on the ranking (`growth-process`):

| Share | Type |
|-------|------|
| ~70% | Highest-scoring optimisation work on the current constraint |
| ~20% | New tactics in proven channels |
| ~10% | Structural bets — low confidence, high potential |

Also enforce: **all experiments must address the current constraint** unless explicitly exempted as a structural bet. A well-scored idea for a stage that is not the bottleneck is still the wrong thing to run.

---

## 6. Effort estimation

Underestimating effort is the most common scoring error, because people estimate the build and forget everything around it. Count: design, engineering, tracking and instrumentation, QA across devices, content and translation, legal or compliance review, the run duration itself, and analysis.

Two rules: if instrumentation does not exist yet, that is part of the effort and often the majority of it; and if an idea cannot be tested in a single cycle, split it — the first slice should be the cheapest version that could falsify the hypothesis.

---

## 7. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Uncalibrated scores | Numbers are opinions with decimal points |
| Scoring aloud as a group | Anchoring; the first voice sets everyone's number |
| Ease dominating the ranking | A backlog of trivial tests, no step change |
| No minimum impact threshold | Button-colour tests outrank structural work |
| Confidence inflated for pet ideas | Advocacy dressed as evaluation |
| Two scoring models in one backlog | Incomparable rankings, permanent argument |
| Scores never checked against outcomes | The scale never improves |
| Ignoring reach in the estimate | Big lifts on pages nobody sees |
| Effort counted as build time only | Consistently over-committed cycles |
| Prioritising ideas outside the current constraint | Work that cannot move the outcome |
| Score used to overrule strategy | Tactics with no cumulative direction |
| Backlog re-scored from scratch every week | Time spent ranking rather than running |

---

## 8. Checklist

- [ ] One scoring model chosen per backlog, and used consistently
- [ ] Score anchors written down for each component
- [ ] Confidence anchored to evidence strength, not enthusiasm
- [ ] Scoring done independently, then compared; only large gaps discussed
- [ ] Minimum impact threshold applied before ranking
- [ ] Ease breaks ties rather than creating winners
- [ ] Effort includes instrumentation, QA, review, run time, and analysis
- [ ] Ideas larger than one cycle split to their cheapest falsifying slice
- [ ] Expected value calculated for anything with significant budget attached
- [ ] Reach and value-per-conversion made explicit for high-stakes decisions
- [ ] Capacity reserved for structural bets rather than left to the ranking
- [ ] All experiments tied to the current constraint, or explicitly exempted
- [ ] Predicted versus actual outcomes reviewed periodically to recalibrate
