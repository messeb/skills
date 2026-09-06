---
description: Establishing product-market fit before scaling growth — why acquisition before fit destroys money, measuring fit with retention curves, cohort behaviour, the disappointment survey and qualitative signals, MVPs versus riskiest-assumption tests, time to value and the user experience as the largest growth lever, and what to do when the evidence says you do not have fit.
---

# Product-market fit

Goal of this skill: decide honestly whether the product retains people — and refuse to scale acquisition until it does.

Use this skill before increasing marketing spend, when growth stalls despite traffic, or when leadership asks why the funnel does not convert.

---

## 1. Why this comes first

Acquisition into a product that does not retain is the most expensive mistake in growth. Every euro brings a customer who leaves, and scale makes the loss larger and the diagnosis harder: churn is masked by growth, the paid channel looks viable on first-purchase economics, and the problem only becomes visible when acquisition slows.

The sequencing rule: **retention → activation → acquisition**. Fix the leak, then the on-ramp, then the volume.

---

## 2. Measuring fit with data

### The retention curve

Plot the share of each signup cohort still active in each subsequent period, using the frequency natural to the product.

| Shape | Reading | Action |
|-------|---------|--------|
| Decays toward zero | No fit. The product does not solve a recurring problem, or does not solve it well | Do not scale. Return to the problem |
| Flattens at a low level | Fit exists for a **subset** | Identify that subset; consider narrowing the product and the targeting |
| Flattens at a healthy level | Fit | Scale acquisition |
| Flattens, then rises | Fit plus expansion | Scale, and invest in the expansion mechanism |

The flattening is the signal, not the starting height. A curve that settles at 25% and stays there describes a real business; a curve that starts at 60% and keeps falling does not.

Segment the curve before concluding anything. It is common to have no fit in aggregate and clear fit within one segment — which is a positioning and targeting decision, not a product failure.

### Supporting signals

| Signal | What it indicates |
|--------|-------------------|
| Organic and word-of-mouth share of new signups | People recommend things that work |
| Usage frequency approaching the natural frequency of the problem | The product is in the workflow |
| Repeat purchase or renewal without prompting | Value is felt, not sold |
| Users returning after an outage | Real dependence |
| Support requests asking for *more*, not for basics | Users are invested |
| Willingness to pay before the feature exists | The strongest signal available |

---

## 3. Measuring fit qualitatively

### The disappointment survey

Ask users who have experienced the core value: *"How would you feel if you could no longer use this product?"* — very disappointed / somewhat disappointed / not disappointed.

The widely used rule of thumb is that **above roughly 40% "very disappointed"** indicates fit. Treat it as a directional instrument rather than a threshold to be gamed:

- Ask only people who have actually used the product enough to judge it (past the activation event, at least twice).
- The **free-text follow-ups** are worth more than the percentage: *what is the main benefit you get?* and *what type of person would benefit most?* Those answers are your positioning and targeting, written by customers.
- Segment the result. 25% overall with 60% in one segment is a clear instruction to narrow.
- A single number from a small, self-selected sample is not evidence; report n and the sampling method.

### Other qualitative signals

Users building workarounds to keep using it, resisting a migration away, asking for an invoice so they can expense it, or spontaneously introducing colleagues — these are behavioural, unprompted, and harder to fake than any survey.

---

## 4. Getting to fit: MVP and riskiest-assumption tests

An MVP is often built too large because "minimum" is negotiated upward. The sharper tool is to ask what would have to be true for this to work, and test **only the assumption most likely to kill it**.

| | MVP | Riskiest-assumption test |
|---|-----|--------------------------|
| Question | "Will people use a small version of this?" | "Is the one thing that would kill this actually true?" |
| Cost | Weeks to months | Hours to days |
| Output | A working product slice | Evidence about one assumption |
| Use when | The risky assumption is usage itself | Any earlier stage |

Order your assumptions by *how fatal if wrong* × *how uncertain*, and test the top one first. Typical fatal assumptions: people have this problem often enough to care; they will pay; you can reach them affordably; the manual version of the service is economically viable; the technology works at required quality.

Cheap tests for each exist (`idea-validation`) — a landing page, a concierge service delivered by hand, a pre-sale, a fake door. **You do not need to build software to test a business idea**, and building it first is how teams spend a year answering a question a week would have settled.

---

## 5. Time to value is the biggest lever

Between signup and the moment a user first experiences the value, everything is cost and risk. Shortening that gap improves activation, retention, referral, and conversion simultaneously — no single campaign does that.

Practical measures: define the value moment precisely (`activation`); measure the median and 90th-percentile time to reach it; remove every step that is not required to reach it (settings, tours, profile completion, verification that could happen later); pre-populate with sample or imported data so the product is not empty on first use; and defer everything you can ask for after the value is delivered rather than before.

The empty-state problem is worth naming separately: many products are useless until the user has done work to fill them. Solve that with templates, imports, or demo data — not with a tour explaining the empty screen.

---

## 6. When the evidence says you do not have fit

Options, in the order they should be considered:

1. **Narrow.** Serve one segment completely rather than several partially. This is the most common correct answer and the least popular.
2. **Change the value proposition** for the same audience — often the product is right and the framing is wrong.
3. **Change the audience** for the same product — the retained subset points at who it is.
4. **Change the problem** — a genuine pivot.
5. **Stop.**

What not to do: increase marketing spend, add features to close the gap with competitors, or discount to buy retention. All three raise the cost of learning what the retention curve already told you.

The organisational difficulty is that this decision is unpopular and usually correct. Make it easier by agreeing the fit criteria **in advance**, before the data arrives, so the conversation is about evidence rather than about someone's judgement.

---

## 7. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Scaling acquisition before retention flattens | Money spent filling a leaking bucket |
| Judging fit on aggregate totals | Churn hidden behind new signups |
| Retention window mismatched to product frequency | Invented crisis or hidden one |
| Disappointment survey run on all signups | Diluted by people who never used it |
| Treating the 40% threshold as a target to hit | Survey gamed; the underlying question unanswered |
| MVP scoped as a small full product | Months spent to answer one question |
| Building software to test a business assumption | A year to learn what a week could |
| Adding features to fix retention | Complexity added to a product people do not return to |
| Discounting to buy retention | Buys the metric, not the behaviour |
| Fit criteria decided after seeing the data | The conclusion follows the preference |
| Ignoring a strongly retained niche | Abandoning the fit you already have |

---

## 8. Checklist

- [ ] Retention curve plotted by cohort at the product's natural frequency
- [ ] Curve checked for flattening before any acquisition scale-up
- [ ] Curves segmented by channel, segment, and activation status
- [ ] Retained subset identified and characterised
- [ ] Supporting signals reviewed: organic share, frequency, unprompted renewal
- [ ] Disappointment survey run on users past the activation event, with n reported
- [ ] Free-text survey answers mined for positioning and targeting
- [ ] Assumptions ranked by fatal × uncertain; the riskiest tested first
- [ ] Cheapest possible test used before building software
- [ ] Value moment defined; median and p90 time to value measured
- [ ] Every step not required to reach value removed or deferred
- [ ] Empty state solved with templates, import, or sample data
- [ ] Fit criteria agreed in writing before the data was collected
- [ ] Narrowing considered before pivoting, and pivoting before scaling
