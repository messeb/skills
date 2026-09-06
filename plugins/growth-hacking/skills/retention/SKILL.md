---
description: Keeping users — measuring retention properly by cohort and frequency, diagnosing churn by stage and cause, onboarding and habit formation, lifecycle and behaviour-triggered messaging, marketing automation design, resurrection campaigns, offboarding and cancellation flows done honestly, loyalty and community, and why retention is the highest-leverage growth work available.
---

# Retention

Goal of this skill: reduce the rate at which value leaks out of the business — the single highest-leverage growth lever, because it improves acquisition economics, referral, and revenue simultaneously.

Use this skill when churn is high, when growth has stalled despite steady acquisition, or before increasing marketing spend.

---

## 1. Why retention is the highest-leverage work

A small improvement in retention compounds through the whole model: customers pay for longer (LTV rises), payback shortens, higher CAC becomes affordable, referral has more time to happen, and expansion revenue has a base to grow from. No acquisition improvement does all of that at once.

The reverse is equally true: acquisition spend on a product with poor retention is a way of converting cash into churned users at scale.

---

## 2. Measure it properly

| Decision | Guidance |
|----------|----------|
| **Definition of "active"** | The action that represents value, not a login. Write it down once, company-wide |
| **Frequency** | Match the product's natural rhythm — daily, weekly, monthly, quarterly. A mismatch invents or hides a crisis |
| **Cohorts** | Always by signup period; aggregates hide everything |
| **Curve shape** | The flattening matters more than the starting height (`product-market-fit`) |
| **Segments** | By channel, plan, activation status, and use case — differences here are the actionable findings |
| **Counter-metric** | Track alongside revenue retention: users can stay while spend falls |

Distinguish **logo churn** (customers lost) from **revenue churn** (money lost), and track **net revenue retention** where expansion exists — above 100% means the existing base grows without any new customers, which is the strongest position a subscription business can hold.

Also separate **voluntary churn** (they chose to leave) from **involuntary churn** (a card expired, a payment failed). Involuntary churn is often 20–40% of total churn in subscription businesses and is fixed with dunning, card-update prompts, and retry logic — unglamorous work with an immediate return that most teams never look at.

---

## 3. Diagnose before intervening

Churn is not one problem. Locate it in time and cause.

| When they leave | Likely cause | Where to work |
|-----------------|--------------|---------------|
| Days 0–7 | Never reached value | Activation, onboarding, time to value (`activation`) |
| Weeks 2–8 | Value experienced once, no habit formed | Triggers, reminders, workflow integration |
| Months 3–12 | Needs changed, competitor, or unrealised value | Expansion, education, relationship |
| At renewal | Price versus perceived value; no champion | Value reporting, commercial conversation |
| Involuntary, any time | Payment failure | Dunning and card management |

Then find the cause, not just the timing: exit surveys (short, one question, optional free text), interviews with churned users (the most informative and least conducted research available), usage patterns before departure (declining frequency is usually visible weeks ahead), support history, and the difference between retained and churned cohorts in their first week.

Build a **churn-risk signal** from the leading indicators you find — declining usage frequency, a key user going inactive, support escalations, failed payments — and validate that it actually predicts churn before acting on it.

---

## 4. Onboarding and habit formation

Retention is largely decided in the first week. Beyond activation, the goal is a **habit**: a trigger, an easy action, and a reward that makes the next occasion likely.

| Lever | Practice |
|-------|----------|
| **Trigger** | Something outside the product brings people back — a notification, an email tied to their work rhythm, a calendar event, a colleague's action |
| **Frequency fit** | Align prompts to the natural frequency of the underlying problem; do not manufacture daily engagement for a monthly need |
| **Accumulated value** | Data, history, integrations, and configuration that make the product more useful over time and costlier to leave |
| **Social anchor** | Multi-user products retain far better; getting a second user into an account is often the strongest retention intervention available |
| **Early wins** | Deliberately create a visible result in the first session |
| **Re-onboarding** | Returning and lapsed users need a different path from new ones |

The multi-user point deserves emphasis: in most collaborative products, accounts with two or more active users retain dramatically better than single-user accounts. If that holds in your data, "invite a colleague" is not a referral tactic — it is your primary retention intervention.

---

## 5. Lifecycle messaging and automation

Behaviour-triggered messaging beats scheduled campaigns, because it arrives when it is relevant.

Design each flow explicitly:

```markdown
Trigger:    user reached activation but has not returned in 5 days
Segment:    self-serve, single-user accounts, non-paying
Goal:       return visit that completes a second core action
Message:    the specific next step, with the value stated — not "we miss you"
Channel:    email; in-app if they return first
Exit:       user returns, upgrades, or unsubscribes
Frequency:  max 2 messages, 3 days apart, then stop
Measure:    return rate versus a holdout that receives nothing
```

The elements that separate a working programme from spam: **a holdout group** (without it you cannot tell whether the flow does anything, and many lifecycle programmes measurably do nothing); a **global frequency cap** across all flows so a user cannot receive six automated messages in a day; **exit conditions** on every flow; and **content that is specific** to what the user did or did not do.

Standard flows worth building, in order of typical value: onboarding sequence tied to activation steps; stalled-activation nudge; feature-adoption prompt based on usage; renewal and payment-failure sequence (dunning); win-back for lapsed users; and post-value moments for asking for a review or a referral.

Chatbots and in-app messages follow the same rules: triggered by behaviour, capped in frequency, always escapable, and never blocking a task the user is trying to complete.

---

## 6. Offboarding — done honestly

The cancellation flow is a legitimate place to make an offer, and a common place to behave badly.

Legitimate: asking why in one question; offering a pause instead of a cancellation; offering a downgrade to a cheaper plan; addressing the stated reason (a discount if price, a call if a problem, help if a missing feature exists); and making the exit clean, with data export.

Not legitimate: hiding the cancellation option, requiring a phone call to cancel what was bought online, adding steps designed purely to exhaust, guilt-inducing copy, or continuing to bill after cancellation. Beyond the ethics, these practices are increasingly regulated in the EU and elsewhere — cancellation must be as easy as signing up, and in Germany online contracts require a compliant cancellation mechanism (`growth-legal-and-ethics`).

The practical argument against dark patterns here: a customer prevented from leaving becomes a refund request, a chargeback, and a public review. **Save the customer, not the subscription.**

Offboarding well also creates a resurrection opportunity: people who leave on good terms come back. Keep the door open, keep their data recoverable for a stated period, and make returning easy.

---

## 7. Loyalty, community, and expansion

- **Loyalty programmes** work when the reward is meaningful and reachable; they fail as a substitute for a product people want to return to.
- **Status and progress** (tiers, streaks, milestones) retain when they reflect genuine accumulated value, and irritate when they are arbitrary.
- **Community** is a retention mechanism that also produces content, support, and referrals — expensive to start and hard to fake, but durable once it exists.
- **Surprise and recognition** — an unannounced upgrade, a human note at a milestone — produce disproportionate goodwill precisely because they are not transactional.
- **Expansion** (more seats, more usage, higher tier) is the strongest form of retention: an account that grows rarely churns. Instrument the signals that precede expansion and make the upgrade path obvious without being obstructive.

---

## 8. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| "Active" defined as login | Measuring presence, not value |
| Retention window mismatched to product frequency | Invented crisis or hidden churn |
| Aggregate retention without cohorts | Churn masked by acquisition |
| Ignoring involuntary churn | A fifth of churn left unaddressed with an easy fix |
| Intervening before diagnosing when and why | Win-back emails for users who never activated |
| Churn-risk model never validated | Effort spent on accounts that were never at risk |
| Lifecycle programme with no holdout | No evidence any of it works |
| No global frequency cap | Users receive six automated messages a day |
| Manufacturing daily engagement for a monthly need | Notification fatigue and unsubscribes |
| Retention pursued only with messaging | Patching a product problem with email |
| Cancellation made difficult | Chargebacks, complaints, regulatory exposure |
| Discounting to prevent churn by default | Buys the metric, trains the behaviour, destroys margin |
| Loyalty programme instead of a reason to return | Cost with no retention effect |

---

## 9. Checklist

- [ ] "Active" defined by a value action, once, company-wide
- [ ] Retention measured by cohort at the product's natural frequency
- [ ] Logo, revenue, and net revenue retention tracked separately
- [ ] Voluntary and involuntary churn separated; dunning and card-update flows in place
- [ ] Churn located by stage (0–7 days, weeks 2–8, months 3–12, renewal)
- [ ] Churned-user interviews conducted, not only exit surveys
- [ ] Churn-risk signal built from leading indicators and validated
- [ ] Habit design: external trigger, easy action, visible reward
- [ ] Multi-user effect on retention measured; second-user activation prioritised if it holds
- [ ] Accumulated value (data, history, integrations) built deliberately
- [ ] Lifecycle flows documented with trigger, segment, goal, exit, and frequency cap
- [ ] Holdout group on every automated programme
- [ ] Cancellation as easy as signup, with data export and a stated recovery window
- [ ] Save offers address the stated reason instead of defaulting to a discount
- [ ] Expansion signals instrumented; upgrade path obvious and non-obstructive
