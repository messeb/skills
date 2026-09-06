---
description: Designing an experiment that produces a trustworthy answer — the growth story card and hypothesis format, choosing one primary metric plus guardrails, minimum detectable effect and sample size, test duration and stopping rules, A/B versus multivariate versus sequential, randomisation and common validity threats (peeking, novelty, sample ratio mismatch, interference), and testing when traffic is too low.
---

# Experiment design

Goal of this skill: an experiment whose result you can act on — because the question, the metric, the size, and the stopping rule were fixed before the data arrived.

Use this skill before launching any test. The design decisions made here determine whether the result means anything.

---

## 1. The experiment card (growth story card)

Also called a **growth story card**, and the board holding them a **growth story canvas** — the names differ by team, the artefact does not.

One page, written before the experiment runs. This is the artefact that makes a growth backlog reviewable.

```markdown
# EXP-142 — Show plan comparison before signup

**Stage**: Activation   **Owner**: <name>   **Status**: running
**Constraint it addresses**: signup → activation drop-off of 61%

## Observation
Session recordings show 38% of visitors open the pricing page from within the
signup flow and 71% of those do not return. Support logs 12 questions/week
about plan differences.

## Hypothesis
**Because** users cannot compare plans without leaving the signup flow,
**we believe that** showing an inline plan comparison at step 2
**will cause** the signup → activation rate to rise from 39% to at least 44%
**for** new self-serve visitors.
**We will know we are right when** activation rate rises ≥5pp with p < 0.05
and refund rate does not rise.

## Design
- Variants: A control, B inline comparison
- Split: 50/50, randomised by visitor id, sticky for 30 days
- Population: new self-serve visitors, desktop and mobile, excluding invited users
- Primary metric: signup → activation rate (activation = first project created)
- Guardrails: refund rate, support tickets/1000 signups, page load time
- Secondary: plan mix, time to activate
- MDE 5pp, baseline 39%, power 80%, alpha 5% → 1,510 per variant
- Duration: 12 days (2 full weekly cycles at ~260 signups/day)
- Stop rules: no decisions before day 12 unless a guardrail breaches its threshold

## Result
<filled after the run: numbers, decision, insight>
```

Two fields do the heavy lifting. **The observation** forces the idea to come from evidence rather than opinion. **"We will know we are right when"** pre-registers the decision rule, which is what prevents the result being reinterpreted afterwards.

---

## 2. Writing the hypothesis

> **Because** `<observed evidence>`, **we believe that** `<change>` **will cause** `<metric>` **to move from** `<baseline>` **to** `<target>` **for** `<segment>`.

| Requirement | Why |
|-------------|-----|
| Grounded in an observation | Distinguishes a hypothesis from a guess |
| Names one primary metric | Multiple primaries mean multiple chances to declare victory |
| States a **quantified** expected effect | Determines sample size; makes the result falsifiable |
| Names the segment | Effects differ by population; an unnamed segment produces an unusable result |
| Is falsifiable | If no outcome would change your mind, it is not an experiment |

"Improving the onboarding will increase engagement" fails every one of these.

---

## 3. Metrics: one primary, several guardrails

| Type | Rule |
|------|------|
| **Primary** | Exactly one. The metric the decision rests on |
| **Guardrails** | Declared in advance; any breach fails the test regardless of the primary |
| **Secondary** | Explanatory, for understanding mechanism — never for declaring a win |

Standard guardrails worth including by default: revenue per visitor, refund or cancellation rate, support contact rate, page performance, and error rate. The classic trap is a variant that lifts conversion by removing information and raises refunds by more than the conversion gain — visible only if refunds were declared as a guardrail.

Choosing a primary metric further down the funnel is more meaningful but slower and noisier. Choosing one further up is faster but may not translate. Pick the furthest-down metric your sample size can actually detect, and check the upstream one as a secondary.

---

## 4. Sample size and duration

You need four numbers before you can size a test: **baseline rate**, **minimum detectable effect (MDE)**, **significance level** (typically 5%), and **power** (typically 80%).

The MDE is a business decision, not a statistical one: *what is the smallest improvement that would change what we do?* Setting it too small produces tests that run for months; too large produces tests that miss real effects.

Sensitivity to be aware of: halving the MDE roughly **quadruples** the required sample. A test to detect a 1pp lift on a 5% baseline needs a very large population; if you do not have it, either test something with a bigger expected effect or accept that you cannot answer this question with an A/B test.

Duration rules that matter as much as sample size:

- Run **whole weeks**. Weekday and weekend traffic behave differently; a Tuesday-to-Friday test measures Tuesday-to-Friday users.
- Run **at least one full purchase or usage cycle** for anything touching conversion.
- **Do not stop when significance appears.** Continuous peeking with a stop-on-significance rule inflates the false-positive rate dramatically — this is the single most common way growth teams generate wins that do not replicate.
- If you need to look early, use a method designed for it (sequential testing or always-valid inference), and fix that choice in the design.
- Cap the maximum duration too. A test running for months is answering a question about a product that no longer exists.

---

## 5. Test types

| Type | Use | Caution |
|------|-----|---------|
| **A/B** | One change, clean attribution | The default; prefer it |
| **A/B/n** | Several distinct alternatives | Correct for multiple comparisons |
| **Multivariate** | Interaction between elements | Sample requirement multiplies; rarely justified |
| **Split URL** | Substantially different pages | Watch for SEO and speed differences between the pages |
| **Holdout** | Measuring a whole programme's effect | Keep a permanent small holdout for brand and lifecycle programmes |
| **Switchback / time-based** | Marketplaces and shared-resource systems where users interfere | Prevents the interference that breaks user-level randomisation |
| **Painted door** | Demand for something not yet built | Ethical handling required (`idea-validation`) |
| **Pre/post** | When randomisation is impossible | Weak; confounded by season, campaigns, releases — label as directional |

Prefer one change per test. A variant that changes headline, layout, and price teaches you that *something* worked, which is not a reusable insight.

---

## 6. Validity threats

| Threat | Symptom | Guard |
|--------|---------|-------|
| **Peeking** | Called early on a "significant" result | Fix duration in advance, or use sequential methods |
| **Sample ratio mismatch** | Split is 52/48 when it should be 50/50 | Check SRM before reading results; a mismatch invalidates the test |
| **Novelty effect** | Big early lift that fades | Run longer; compare new versus returning users |
| **Change aversion** | Early dip that recovers | Same guard; judge established users separately |
| **Interference / spillover** | Variants affect each other (marketplaces, social features) | Cluster or switchback randomisation |
| **Cross-device / logged-out identity** | One person in both variants | Randomise on the most stable identifier available; state the limitation |
| **Segment cherry-picking** | "It won for mobile users in Germany" | Declare segments in advance; treat post-hoc segments as hypotheses |
| **Multiple metrics** | Testing twenty metrics, one is significant | One primary; correct for the rest |
| **Instrumentation bugs** | Impossible numbers | Run an A/A test before trusting a new setup |
| **Seasonality and external events** | A campaign or holiday inside the window | Whole weeks; keep an event log alongside results |

An **A/A test** on a new experimentation setup is cheap insurance: if two identical variants show a significant difference, the tooling is wrong and every subsequent result is suspect.

---

## 7. When traffic is too low

Most teams do not have the volume for classical significance on every question. Honest alternatives:

| Approach | Trade-off |
|----------|-----------|
| Test higher up the funnel | More volume, weaker link to revenue |
| Choose bigger, bolder changes | Large effects need smaller samples |
| Bayesian methods with a stated prior | Gives usable probability statements at small n |
| Sequential testing | Valid early stopping, designed for it |
| Qualitative validation (5–8 user sessions) | Finds usability failures; cannot size an effect |
| Painted door and demand tests | Answers "do they want it" without full traffic |
| Longer windows, fewer tests | Fewer, better-powered experiments |
| Pre/post with a control market | Directional; confounded |

The important discipline is honesty: run the test, report the observed direction, and **label it as directional evidence rather than a proven result**. A team that pretends to significance it does not have will eventually scale a loser.

---

## 8. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Hypothesis without an observation behind it | Testing opinions at random |
| No quantified expected effect | Cannot size the test; result is unfalsifiable |
| Several primary metrics | Multiple chances to declare a win |
| No guardrails | Conversion gains that cost more elsewhere |
| Stopping when significance first appears | False positives that do not replicate |
| Partial-week runs | Weekday/weekend composition drives the result |
| Multiple changes in one variant | No reusable insight |
| Ignoring sample ratio mismatch | Reading an invalidated test |
| Post-hoc segment mining | A "win" that is noise |
| No A/A test on new tooling | Systematic error in every result |
| Ignoring interference in marketplaces | Both variants contaminated |
| Claiming significance the sample cannot support | Scaling a loser with confidence |
| Result never written back to the card | The decision and its reasoning are lost |

---

## 9. Checklist

- [ ] Experiment card written before launch, including the triggering observation
- [ ] Hypothesis states change, primary metric, quantified effect, and segment
- [ ] Exactly one primary metric; guardrails declared in advance with thresholds
- [ ] MDE set as a business decision; sample size calculated from baseline, MDE, alpha, power
- [ ] Duration covers whole weeks and at least one usage or purchase cycle
- [ ] Stopping rule fixed in advance; sequential method chosen if early looks are needed
- [ ] Maximum duration capped
- [ ] Randomisation unit appropriate; interference considered for shared-resource products
- [ ] Segments to analyse declared before the run
- [ ] A/A test passed on new experimentation tooling
- [ ] Sample ratio mismatch checked before reading results
- [ ] Novelty and change-aversion considered for established users
- [ ] Low-traffic alternatives used where classical testing is not viable, and labelled directional
- [ ] Result, decision, and insight written back onto the card
