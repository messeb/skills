---
description: Questionnaires and surveys — validate at scale what qualitative research surfaced. Covers when a survey is and is not the right tool, sampling and bias, question wording rules, response scales, standard instruments (SUS, UMUX-Lite, NPS, CSAT, importance/satisfaction for opportunity scoring), pilot testing, sample size guidance, analysis, and Markdown templates for the survey plan, instrument, and results report.
---

# Questionnaires and surveys

Goal of this skill: measure **how widespread** something is, once qualitative work has told you **what** to ask about — with wording and sampling that do not manufacture the answer you hoped for.

Use this skill to quantify priorities across a large user base, to size a problem found in interviews, to score importance vs satisfaction for `jobs-to-be-done` opportunity analysis, or to track a metric over time.

Do **not** use it to discover unknown problems (you can only ask about what you already suspect), to ask people to predict their own future behaviour, or when your reachable sample is under ~30 responses — five interviews will teach you more.

---

## 1. Survey or not?

| Question you have | Survey? | Better method |
|-------------------|---------|---------------|
| "What problems do users have?" | No | `stakeholder-interviews`, `contextual-inquiry` |
| "How many users have problem X?" | **Yes** | — |
| "Why does X happen?" | No | interviews |
| "Which of these five known pains is most common?" | **Yes** | — |
| "Would you use feature Y?" | No — stated preference is not behaviour | fake-door test, analytics |
| "How satisfied are users with Z, tracked quarterly?" | **Yes** | — |
| "How do users actually do the task?" | No | observation, analytics |
| "How important vs how satisfied per outcome?" | **Yes** | — (feeds opportunity scoring) |

Rule: **qualitative first, quantitative second.** A survey written before any interviews measures the team's assumptions.

---

## 2. Intake — ask before writing questions

Ask only what is missing; batch into one message, five or fewer.

1. **What decision will the results change?** Name the decision and the threshold ("if more than 40 % report X, we do Y").
2. **What do you already know qualitatively**, and which specific hypotheses should this survey test?
3. **Who is the population**, how many are reachable, and through which channel (in-app, email, panel, community)?
4. **What is the acceptable length** and what incentive, if any, is available?
5. **Constraints** — GDPR/consent requirements, whether responses can be linked to accounts, any prior wave whose wording must be kept identical for comparison.

If no decision threshold can be named, the survey is not yet worth running.

---

## 3. Sampling and bias

| Bias | Cause | Mitigation |
|------|-------|------------|
| **Selection bias** | Only reachable or willing people respond | Define the population explicitly; report the frame you actually reached |
| **Non-response bias** | Unhappy or disengaged users never answer | Compare respondents vs population on known attributes; report response rate |
| **Survivorship bias** | Churned users are not in your mailing list | Recruit churned users separately |
| **Order effects** | Earlier questions prime later ones | Randomise item order within blocks |
| **Acquiescence bias** | People tend to agree | Mix positively and negatively worded items, then reverse-score |
| **Social desirability** | People report what sounds good | Ask about behaviour, guarantee anonymity |
| **Satisficing** | Long survey, straight-lining | Keep it under 5–7 minutes; add attention checks |
| **Recall bias** | Distant events remembered badly | Anchor to a recent, bounded period ("in the last 7 days") |

Report the response rate and the sampling frame in every result document. A percentage without a denominator is not a finding.

**Rough sample sizes** (for a proportion, 95 % confidence):

| Margin of error | Responses needed |
|-----------------|------------------|
| ±10 pp | ~100 |
| ±5 pp | ~380 |
| ±3 pp | ~1,070 |

For segment-level conclusions, each segment needs its own sample — a 400-response survey split into eight segments gives you nothing per segment. For usability instruments like SUS, 20–30 responses give a usable signal; below ~30 report ranges, not point estimates.

---

## 4. Question wording rules

| Rule | Bad | Good |
|------|-----|------|
| One thing per question | "How satisfied are you with the speed and reliability?" | Two separate items |
| No leading | "How much did our new fast checkout improve your experience?" | "How would you rate the checkout experience?" |
| Behaviour, not prediction | "Would you use a mobile app?" | "How did you place your last order?" |
| Bounded recall | "How often do you export data?" | "How many times did you export data in the last 7 days?" |
| Neutral language | "Do you agree the old process was inefficient?" | "How would you rate the previous process?" |
| No jargon | "Rate the ACL latency" | "How long does it take before the data appears?" |
| Mutually exclusive options | 0–10, 10–20, 20–30 | 0–9, 10–19, 20–29 |
| Exhaustive options | forgetting "none of these" | include "other", "none", "not applicable" |
| No forced answers | mandatory sensitive fields | make sensitive questions optional |
| Consistent scale direction | flipping mid-survey | keep low → high throughout |

**Scales:**

| Scale | Use for | Notes |
|-------|---------|-------|
| 5-point Likert | Agreement, satisfaction | Label every point, not just the ends |
| 7-point | More granularity for tracking | Harder on mobile |
| 0–10 | NPS, importance, satisfaction (for opportunity scores) | Familiar; needed for Ulwick-style scoring |
| Binary + follow-up | Fast screening | Follow up conditionally |
| Rank order | Forcing prioritisation | Cap at 5–7 items |
| Constant sum (allocate 100 points) | Trade-off strength | Harder for respondents, richer data |

Avoid: unlabelled midpoints, "N/A" mixed into a scale (put it outside), and matrices longer than five rows on mobile.

---

## 5. Standard instruments — use them instead of inventing

| Instrument | Measures | Items | Notes |
|------------|----------|-------|-------|
| **SUS** | Perceived usability | 10 | Score 0–100; ≥68 is average. Do not change the wording if you want comparability |
| **UMUX-Lite** | Usability, short form | 2 | Good when survey length is tight |
| **NPS** | Word-of-mouth intent | 1 + open follow-up | Weak as a product metric; the open follow-up is where the value is |
| **CSAT** | Satisfaction with a specific interaction | 1 | Ask right after the interaction |
| **CES** | Effort of completing a task | 1 | Strong predictor of loyalty for service journeys |
| **Importance / Satisfaction pair** | Opportunity scoring per outcome | 2 per outcome | Feeds `Opportunity = Imp + max(0, Imp − Sat)` in `jobs-to-be-done` |
| **PMF survey** ("how disappointed if this went away") | Product-market fit signal | 1 | Watch the ">40 % very disappointed" heuristic critically |

Changing a standard instrument's wording destroys its benchmarks. If you need different wording, treat it as a custom item and drop the benchmark claim.

---

## 6. Structure and pilot

**Structure**: screener → warm-up (easy, relevant) → core blocks (most important first, in case of drop-off) → sensitive/demographic items last → open comment → thank-you and next steps.

Keep it to **5–7 minutes**. Every extra minute costs completions. Show a progress indicator. Design for mobile first.

**Always pilot** with 5–10 people from the target group before sending:

- Have three of them think aloud while answering — you will find at least one question that means something else to them.
- Check completion time against your estimate.
- Check that every question can actually change a decision. Delete the rest — "nice to know" questions are the main cause of low completion.
- Verify the export/analysis pipeline on the pilot data before the real send.

---

## 7. Analysis

1. **Clean**: remove straight-liners, failed attention checks, and impossibly fast completions. Report how many you removed and why.
2. **Report the denominator**: population, invited, started, completed, response rate.
3. **Descriptives first**: distributions, not just means. A bimodal distribution averaged into a mean hides two different user groups.
4. **Segment** by the attributes you defined in advance — not by hunting until something is significant.
5. **State uncertainty**: give confidence intervals or margins of error; do not report 2 pp differences from 80 responses as a finding.
6. **Read the open text**: code it into themes with counts. Usually the most useful part of the survey.
7. **Close the loop**: state what decision the data supports, and where the data was insufficient. Route the "why" questions back to interviews.

---

## 8. Output templates

### 8.1 Survey plan

````markdown
# Survey plan — <topic>

- **Decision this informs**: <decision> · **Threshold**: <if X% then Y>
- **Hypotheses**: H1 … H2 …
- **Population**: <definition> · **Reachable frame**: <n> · **Channel**: <in-app / email / panel>
- **Target responses**: <n> (margin ±<x> pp) · **Field period**: <dates>
- **Incentive**: … · **Consent/GDPR**: <what is stated, data retention>
- **Pilot**: <n> testers, <date>
- **Prior wave to stay comparable with**: <link or none>
````

### 8.2 Instrument

````markdown
# Questionnaire — <topic> (v<n>, <date>)

**Intro**: purpose, length, anonymity, data use, contact.

## Screener
S1. <question> → terminate if <answer>

## Block A — behaviour
A1. In the last 7 days, how many times did you …? [0 / 1–2 / 3–5 / 6–10 / more than 10]

## Block B — importance and satisfaction (randomise items)
For each outcome:
B1. How important is it that you can <outcome>? [0–10]
B2. How satisfied are you with how you can do this today? [0–10]

## Block C — standard instrument
C1–C10. SUS (unmodified)

## Block D — open
D1. What is the single biggest problem you have with <topic>? [free text]

## Demographics (optional)
E1. Role · E2. Team size · E3. Tenure

**Attention check placement**: after A3.
````

### 8.3 Results report

````markdown
# Survey results — <topic> — <date>

## Method and sample

| Population | Invited | Started | Completed | Response rate | Removed (quality) | Analysed |
|------------|---------|---------|-----------|---------------|-------------------|----------|

- **Field period**: … · **Margin of error**: ±<x> pp at 95 %
- **Known bias / limitations**: …

## Headline findings

| # | Finding | Evidence | Confidence |
|---|---------|----------|------------|
| F1 | 62 % (±5 pp) export data weekly or more | A1 | high |

## Distributions

| Item | n | Distribution | Mean / median | Note |
|------|---|--------------|---------------|------|

## Opportunity scores

| Outcome | Importance | Satisfaction | Opportunity | Verdict |
|---------|-----------|--------------|-------------|---------|

## Segments

| Segment | n | Key difference | Significant? |
|---------|---|----------------|--------------|

## Open text themes

| Theme | Mentions | Representative quote |
|-------|----------|---------------------|

## Decision

- **Threshold was**: … · **Result**: met / not met
- **Decision taken**: …
- **Insufficient data on**: … → follow up with <method>
````

---

## 9. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Survey before any qualitative research | You measure your own assumptions | Interviews first, survey second |
| Asking about future behaviour | Confident, wrong roadmap | Ask about the last real occurrence |
| No decision threshold defined up front | Results get reinterpreted to fit the plan | Write the threshold before sending |
| Leading or double-barrelled questions | Data that cannot be used | One idea per item, neutral wording |
| 40 questions "while we're at it" | Drop-off and straight-lining | 5–7 minutes, ruthless deletion |
| Percentages without a denominator | Misleading claims | Always report n and response rate |
| Segmenting until something is significant | False findings | Pre-register the segments |
| Modifying SUS/NPS wording | Benchmarks become meaningless | Use them unmodified or drop the benchmark |
| Ignoring non-responders | Systematically biased picture | Report response rate and compare respondents to the population |
| Averaging a bimodal distribution | Two user groups hidden behind one mean | Always look at the distribution |
| Never reporting back to respondents | Response rates drop for every future survey | Share what changed because of it |

---

## 10. Checklist

- [ ] Qualitative research done first; hypotheses are specific
- [ ] Decision and threshold written before the instrument
- [ ] Population, sampling frame, and channel defined; response target derived from a margin of error
- [ ] Churned/inactive users recruited separately where relevant
- [ ] Every question traces to a hypothesis — "nice to know" items deleted
- [ ] No leading, double-barrelled, or prediction questions
- [ ] Scales labelled fully and consistent in direction; "N/A" outside the scale
- [ ] Standard instruments used unmodified where applicable
- [ ] Item order randomised within blocks; attention check included
- [ ] Length verified under 5–7 minutes; mobile-tested
- [ ] Consent, anonymity, retention, and GDPR statements included
- [ ] Piloted with 5–10 target users, at least three thinking aloud
- [ ] Analysis pipeline tested on pilot data
- [ ] Results report distributions, denominators, and uncertainty
- [ ] Open text coded into themes with counts
- [ ] "Why" questions routed back to qualitative methods
- [ ] Findings reported back to respondents
