---
description: Growth loops as the replacement for funnel thinking — loop anatomy and the four common types (viral, content, paid, sales), how to model and measure a loop, loop math including k-factor and cycle time, why loops compound where funnels leak, diagnosing a broken loop, the flywheel model, and when a funnel is still the right frame.
---

# Growth loops and the flywheel

Goal of this skill: find the mechanism by which **the output of growth becomes the input to more growth**, and make it measurable — because that, not a list of tactics, is what compounds.

Use this skill when growth is linear and entirely bought, when planning where to invest engineering effort, or when acquisition costs rise every quarter.

---

## 1. Funnel versus loop

A funnel is a one-way pipeline: attention in at the top, customers out at the bottom, and everything must be refilled from outside. A loop is closed: the output feeds the input.

| | Funnel | Loop |
|---|---|---|
| Shape | Linear, terminates | Circular, re-enters |
| Growth | Proportional to spend | Compounds while the loop holds |
| Cost per customer | Flat or rising | Falls as the loop strengthens |
| Where effort goes | Campaigns | Product mechanics |
| Failure mode | Stops when spend stops | Decays quietly as one step degrades |

Both frames are useful. The funnel is the right tool for **diagnosis** — it tells you which stage leaks (`north-star-and-metrics`). The loop is the right tool for **strategy** — it tells you what to build. Teams that only think in funnels end up renting all their growth.

---

## 2. Anatomy

Every loop has four parts. Write them as a sentence before drawing anything:

> **New users** arrive → they **do something** in the product → that action **creates an asset** (content, an invitation, data, revenue) → that asset **brings new users**.

```text
       ┌──────────────────────────────────────────┐
       │                                          │
   new user ──► action ──► output/asset ──► exposure
       ▲                                          │
       └──────────────────────────────────────────┘
```

The loop is only real if you can name each arrow and measure it. "Users love it and tell their friends" is a hope; "12% of users send at least one invite within 7 days, and 22% of invites convert" is a loop.

---

## 3. The four common types

| Type | Mechanism | Works when | Cycle time |
|------|-----------|------------|------------|
| **Viral / referral** | Users invite or share, invitees become users | Product has multiplayer value or a natural sharing moment | Hours to days |
| **Content** | User or product activity creates indexable pages; search brings new users | Content is genuinely useful and unique at scale | Weeks to months |
| **Paid** | Revenue from customers funds acquisition of more customers | Payback period is shorter than the cash cycle | Bounded by payback period |
| **Sales** | Revenue funds more sellers, who close more revenue | Repeatable, teachable sales motion | Quarters |

Two more worth knowing: the **data loop**, where usage improves the product (better recommendations, better models) which improves retention and word of mouth; and the **ecosystem loop**, where third parties build on your platform and bring their own users.

Most durable businesses run **two or three loops at once** — for example a paid loop for predictable volume and a content loop that lowers blended cost over time. A single loop is a single point of failure.

---

## 4. Loop math

For a viral loop:

```text
k = invites sent per user × conversion rate of invites

k > 1   → self-sustaining growth (rare, and usually temporary)
k = 0.5 → every 100 users bring 50 more, who bring 25 … a 2× multiplier on all other acquisition
k < 0.1 → not a loop; a nice-to-have
```

Two numbers matter as much as `k`:

- **Cycle time** — how long one turn of the loop takes. A loop with `k = 0.4` and a 2-day cycle beats `k = 0.7` with a 30-day cycle over any realistic horizon. Shortening cycle time is usually easier than raising `k`.
- **Decay** — `k` falls as the network saturates, because early users have the most invitable contacts. A loop that looks self-sustaining in month one routinely settles below 1 by month six. Model the decline; do not plan on the launch number.

For a paid loop the equivalent constraint is the **payback period** relative to your cash cycle. If a customer repays acquisition cost in 14 months but you must pay the channel in 30 days, the loop is real but you need capital to run it — that is a financing question, not a growth question, and confusing the two has killed a lot of companies.

Never let a `k` below 1 be reported as "viral". Sub-1 loops are valuable — they multiply everything else — but they do not grow a business on their own.

---

## 5. Modelling and measuring

Instrument every arrow, then find the weakest one:

| Step | Metric | Typical failure |
|------|--------|-----------------|
| New users arrive | Cohort size by source | — |
| Reach the action | % of new users who perform the loop action | Onboarding never surfaces it (`activation`) |
| Action produces the asset | Assets created per acting user | Sharing is possible but effortful |
| Asset gets exposure | Impressions or visits per asset | Content not indexed; invites go to spam |
| Exposure converts | Conversion rate of exposed people | Landing experience does not match the promise |
| New cohort repeats | Loop participation of the new cohort | New users behave differently from the seeded first cohort |

Multiply the rates to get the loop's amplification factor, and track it **by cohort over time**. A loop is not a fixed property; it degrades as the audience broadens, as platforms change, and as the novelty fades.

The last row is the one that catches teams out: the first cohort is usually enthusiasts. If the loop only works for them, the reported amplification collapses as you reach a mainstream audience.

---

## 6. Diagnosing a broken loop

Work backwards from exposure, not forwards from users:

1. **Is the asset being seen at all?** Zero exposure is the most common failure — content unindexed, invites in spam, shares with no preview image.
2. **Does the exposure convert?** High exposure and low conversion means the landing experience breaks the promise the asset made.
3. **Do converted users perform the loop action?** If not, the loop runs one turn and stops.
4. **Is the incentive aligned?** People share because it makes them look good, helps them, or is required to get value — not because a button exists.
5. **Is friction the blocker?** Every additional step in the share flow costs a large share of participants.
6. **Has the platform changed the rules?** Loops built on someone else's distribution are revocable.

Fix in that order. Optimising the share button when nothing is being indexed is wasted work.

---

## 7. The flywheel

The flywheel is the same idea at company scale: a small number of reinforcing stages where each pushes the next, and momentum accumulates. A typical shape:

> **Attract** (content, brand) → **Convert** (a product experience that delivers value fast) → **Delight** (retention, support, outcomes) → **Advocate** (reviews, referrals, word of mouth) → back to Attract.

The useful discipline the flywheel adds over the funnel: **friction is the enemy at every stage, and delight is a growth input, not a cost centre.** Support quality, time to value, and product reliability sit inside the growth model rather than outside it. A company that treats churn as a support problem and growth as a marketing problem has cut its own flywheel in half.

---

## 8. When a funnel is still the right frame

- One-off or very infrequent purchases (a mattress, a mortgage) where no natural loop exists.
- Fixed, finite markets — with 300 possible customers, loops have nowhere to compound.
- Early diagnosis, where you need to know which stage leaks before you build anything.
- Regulated contexts where referral and sharing are restricted.

In these cases the compounding comes from brand and from unit economics, not from a product loop. Say so explicitly rather than inventing a loop that does not exist.

---

## 9. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Calling a funnel a loop | No compounding, but the plan assumes it |
| Reporting `k < 1` as "viral" | Forecasts that never materialise |
| Ignoring cycle time | A "strong" loop that turns twice a year |
| Planning on the launch `k` | Saturation and decay unmodelled; the plan breaks in month four |
| Loop metrics not tracked by cohort | Degradation invisible until growth stalls |
| Building a share button and calling it a loop | No incentive, no exposure, no loop |
| Incentives that attract fraud | Referral spend converted into fake accounts (`referral`) |
| Only one loop | A single platform change removes all growth |
| Loop built entirely on a third-party platform | Distribution can be revoked without notice |
| Optimising the last step first | Effort on conversion while nothing is exposed |
| Treating retention and support as outside the growth model | The flywheel is cut in half |

---

## 10. Checklist

- [ ] Loop written as a sentence: new users → action → asset → exposure → new users
- [ ] Every arrow instrumented with a named metric
- [ ] Amplification factor calculated, and `k` reported honestly against 1
- [ ] Cycle time measured, with an explicit plan to shorten it
- [ ] Saturation and decay modelled, not extrapolated from launch
- [ ] Loop metrics tracked per cohort over time
- [ ] Weakest arrow identified and worked on first
- [ ] Share and invite incentives aligned with a real user motive
- [ ] Friction in the loop path counted step by step
- [ ] At least two loops, or an explicit acknowledgement of single-loop risk
- [ ] Platform dependence in the loop identified and mitigated
- [ ] Paid loop payback period compared against the cash cycle
- [ ] Retention and support explicitly inside the growth model
- [ ] Where no loop exists, said so — and compounding sought in brand and unit economics
