---
description: Testing a product or business idea before building it — the validation ladder from paper prototypes to crowdfunding, landing-page smoke tests, painted-door and fake-door tests with their ethical handling, concierge and Wizard-of-Oz delivery, no-code builds, explainer videos, pre-sales, buy-a-feature exercises, and reading the results honestly including what a smoke test cannot tell you.
---

# Validating ideas before building

Goal of this skill: buy the maximum amount of evidence for the minimum amount of build — and know exactly which question each method answers.

Use this skill before committing engineering time to a new product, feature, or business model.

---

## 1. The validation ladder

Climb only as far as the risk requires. Each rung costs more and answers a sharper question.

| Method | Cost | Answers | Does not answer |
|--------|------|---------|-----------------|
| **Paper prototype / sketch** | Hours | Is the concept understood? | Will anyone want it |
| **Explainer video** | 1–3 days | Is the value proposition compelling? | Whether the product can be built |
| **Landing page / smoke test** | 1–3 days | Does the promise generate interest at a given cost? | Whether people would pay or stay |
| **Painted door in-product** | Hours | Do existing users want this feature? | Whether they would use it repeatedly |
| **Interactive prototype** | Days | Is the flow usable? | Real-world demand |
| **No-code build** | Days–weeks | Will people use a working version? | Scalability and unit economics |
| **Concierge / Wizard of Oz** | Days–weeks | What does delivering the value actually require? | Whether it can be automated profitably |
| **Pre-sale / pre-order** | Days | Will people **pay**? | Whether they will keep paying |
| **Crowdfunding** | Weeks | Is there demand at scale, with money attached? | Retention; and it is public |
| **MVP** | Weeks–months | Do they use and return? | Full-market viability |

The ordering principle: **money is stronger evidence than email addresses, and email addresses are stronger than clicks.** Move up the ladder only until the risk is retired, then build.

---

## 2. Landing-page smoke test

The workhorse. A page describing the offer as if it exists, with a single call to action, and traffic bought or borrowed to measure response.

Design rules:

- **One clear promise, one call to action.** Multiple CTAs make the signal uninterpretable.
- Describe the **benefit and the differentiator** exactly as you would in the real product — you are testing the proposition, not the design.
- Send **qualified traffic**: paid search on intent keywords, a relevant community, or a targeted ad set. Traffic from friends and social feeds measures politeness.
- Decide the **success threshold before launching** (for example: ≥8% of visitors leave an email at a cost below €4 each).
- Include a **price** whenever price is part of the risk. A free signup rate tells you nothing about willingness to pay.
- Run for a full week minimum, across at least two traffic sources, so the result is not a property of one channel.

What it genuinely tests: whether the promise is compelling enough to generate an action at a cost you can afford. What it cannot test: whether the product can deliver the promise, whether people will return, and whether the economics work. Teams routinely over-read a good smoke test as validated demand — it is validated **interest**.

The honest close: tell people what they signed up for. "Not available yet — we will let you know" is fine. Taking payment for something that does not exist and has no delivery plan is not.

---

## 3. Painted door and fake door

An entry point for a feature that does not exist yet — a button, a menu item, a plan tier — that records the click and then explains the situation.

Use it to prioritise between candidate features with real behavioural data, rather than asking users what they want.

The ethical requirements are non-negotiable, and this is where teams get it wrong:

- The follow-up must be **immediate and honest**: "This isn't available yet — want to be notified?"
- **Never take money or sensitive data** for something that does not exist.
- **Never break a task the user was in the middle of.** A painted door in a checkout is a betrayal, not a test.
- **Cap the exposure**: a small share of traffic, a short window.
- Record it as an experiment with an end date, so the door is removed rather than left up for a year.

Read the results carefully: a click means "this looked interesting", not "I would use this weekly". Pair click rate with a follow-up question or a waitlist conversion to distinguish curiosity from intent.

---

## 4. Concierge and Wizard of Oz

Two different things, often confused:

- **Concierge**: the customer knows the service is delivered manually. You are testing whether the outcome is valuable and learning what delivering it actually requires.
- **Wizard of Oz**: the customer believes it is automated; humans do the work behind the interface. You are testing the experience of the automated product before building automation.

Both are the fastest route to learning the **real process** — the edge cases, the data you actually need, the time each step takes. That knowledge is what makes the eventual automation correct rather than a guess.

Constraints: do not misrepresent how data is handled — if a human reads the customer's content, that must be disclosed, and in the EU it has data-protection consequences (`growth-legal-and-ethics`). Keep the deception limited to the mechanism, never to the outcome, the price, or the privacy of the data.

Both are deliberately unscalable, and that is the point: they answer the question before you pay for scale.

---

## 5. No-code and pre-sales

**No-code** builds a genuinely working product from assembled tools — forms, automation platforms, spreadsheets, site builders, payment links. It answers "will people use it" without engineering, and often serves real customers for months. Its limits are real: cost per user rises with volume, customisation hits walls, and the data model becomes a migration problem. Treat it as a validated throwaway, and decide the rebuild trigger in advance.

**Pre-sales** are the strongest pre-build evidence available, because money is the least polite signal there is. Sell a defined deliverable with a defined date, offer an unconditional refund, and be explicit that it does not exist yet. In B2B, a signed letter of intent or a paid pilot is the equivalent. If nobody will pay in advance with a refund guarantee, the demand signal from your landing page was softer than it looked.

**Crowdfunding** is a pre-sale at scale with public commitment and a deadline. It validates demand with money attached, and it comes with obligations: a failed delivery is a public failure with legal and reputational consequences. Use it when the demand question is genuinely the biggest risk and you can deliver.

---

## 6. Prioritising features with users

**Buy a feature**: give participants a limited budget and price each candidate feature by its real build cost, with the expensive ones deliberately unaffordable alone so people must pool their money and negotiate. The negotiation is the data — what they argue for reveals priority far better than a satisfaction survey.

Run it with 6–8 customers, price credibly (engineering must stand behind the numbers), and give 45 minutes to trade. Use it when you have several plausible features and no evidence to rank them.

Its limit is the same as any stated-preference method: people are spending play money. Treat the result as a strong prioritisation input, not as demand validation.

---

## 7. Reading the results honestly

| Signal | Strength |
|--------|----------|
| Paid, with a refund available and not taken | Strongest |
| Paid | Very strong |
| Committed time (a scheduled call, a completed onboarding) | Strong |
| Gave an email address for a specific promise | Moderate |
| Clicked a painted door | Weak |
| Said they liked it in an interview | Very weak |
| Liked or shared a post | Not evidence |

Three rules that prevent self-deception: **set the threshold before the test**, because a result without a pre-declared bar will be rationalised; **check where the traffic came from**, since a 20% signup rate from your own newsletter is not a market signal; and **negative results are results** — an idea that fails validation has saved you the build, which is the entire point.

Finally, keep a validation log: idea, method, threshold, actual, decision. Without it, killed ideas return every six months with no new evidence.

---

## 8. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Building an MVP to test a demand assumption | Months spent on a question a week could answer |
| Smoke test driven by friends and personal social feeds | Politeness measured, not demand |
| No pre-declared success threshold | Any result reinterpreted as encouraging |
| Free signup used to test willingness to pay | The one thing you needed to know is untested |
| Painted door with no honest follow-up | Trust destroyed for a data point |
| Painted door inside a critical flow | Users blocked mid-task |
| Wizard of Oz that hides human access to private data | Data-protection breach |
| Treating clicks as validated demand | Building on curiosity |
| No-code prototype scaled with no rebuild trigger | Cost and fragility discovered at volume |
| Crowdfunding without delivery capability | Public failure with legal exposure |
| Buy-a-feature treated as demand validation | Play money mistaken for real intent |
| Killed ideas returning with no new evidence | The same debate every six months |

---

## 9. Checklist

- [ ] Riskiest assumption identified before choosing a method
- [ ] Cheapest method that could falsify it selected
- [ ] Success threshold and sample declared before the test runs
- [ ] Traffic source qualified and documented; at least two sources for a smoke test
- [ ] Price included whenever willingness to pay is part of the risk
- [ ] Painted doors honest, immediate, capped in exposure, and removed afterwards
- [ ] No money or sensitive data collected for something that does not exist
- [ ] Human involvement disclosed where it touches customer data
- [ ] Concierge or Wizard-of-Oz learnings written up as process requirements
- [ ] No-code builds given an explicit rebuild trigger
- [ ] Evidence strength stated honestly (paid > committed > email > click > opinion)
- [ ] Negative results recorded and acted on
- [ ] Validation log maintained so killed ideas stay killed without new evidence
