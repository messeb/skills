---
description: Getting new users — running a channel portfolio, the channel test protocol from cheap probe to scale decision, acquisition metrics and unit economics per channel, attribution and its limits, why cheapest CPA is the wrong optimisation target, channel saturation and diversification risk, and the sequence for finding the one or two channels that will carry growth.
---

# Acquisition

Goal of this skill: find the small number of channels that reach your audience at a cost you can afford, prove payback before scaling, and avoid building the business on a single revocable source of traffic.

Use this skill when acquisition is the constraint, when CPA is rising, or when choosing where to spend a new budget.

Prerequisite: retention flattens (`product-market-fit`). Acquisition into a leaking bucket is the most expensive activity in this whole plugin.

---

## 1. Channel strategy

The pattern that repeats across companies: **most growth comes from one or two channels**, but which two is not predictable in advance. Therefore: test broadly and cheaply, then concentrate hard.

```text
1. Score all 19 channels with BRASS               (idea-generation, experiment-prioritization)
2. Pick 3–4 unused, plausible channels
3. Run a cheap probe on each  — days, small budget
4. Kill the clear failures; iterate the promising ones
5. Prove payback on 1–2 winners
6. Scale until saturation, while probing the next candidates
```

Step 6 matters as much as the rest: the time to test the next channel is **while the current one is working**, not when it stops. A team that only looks for a new channel after CPA doubles is already in trouble.

---

## 2. The channel test protocol

| Stage | Budget / effort | Question | Decision |
|-------|-----------------|----------|----------|
| **Probe** | Smallest amount that produces signal — often €200–1,000 or 2 days of effort | Is there any signal at all? | Kill or continue |
| **Iterate** | 3–5× the probe | Can the big levers (offer, audience, landing page) make it work? | Kill or validate |
| **Validate** | Enough volume for reliable CPA and early retention | Does it pay back within our window? | Kill or scale |
| **Scale** | Increase stepwise, 30–50% at a time | Does efficiency hold as volume rises? | Continue or plateau |

Rules that make this honest:

- **Do not kill a channel on one creative and one audience.** Test at least three meaningfully different approaches — offer, audience, and landing experience move results far more than ad copy details (`growth-process`).
- **Respect platform learning periods.** Ad platforms need conversion volume before optimisation is meaningful; judging in 48 hours measures the learning phase.
- **Scale in steps.** Doubling spend overnight usually degrades efficiency and destroys the platform's optimisation.
- **Track cohort retention by channel from the first test.** A channel that looks cheapest on CPA and worst on 30-day retention is a trap you can only see if you cohort by source.

---

## 3. Metrics

| Metric | Definition | Watch for |
|--------|-----------|-----------|
| **CPC / CPM** | Cost per click / per thousand impressions | Useful for diagnosis, never a goal |
| **CTR** | Click-through rate | Creative and relevance signal |
| **CPA / CAC** | Cost per acquisition — fully loaded | Must include people, tools, agency, and creative production |
| **Conversion rate by step** | Visitor → signup → activated → paid | Locates the actual leak |
| **Payback period** | Months to recover CAC from contribution margin | The number that constrains cash |
| **LTV : CAC by channel** | Value against cost, per source | Requires margin-based LTV (`north-star-and-metrics`) |
| **Retention by channel cohort** | 30/90-day retention per source | Exposes cheap-but-worthless traffic |
| **Share of new customers by channel** | Concentration | Dependence risk |

**Do not optimise for the lowest CPA.** The cheapest traffic is usually the least qualified; optimising CPA systematically selects for users who do not stay. Optimise for **cost per retained (or per profitable) customer**, and accept a higher CPA where the cohort is better. This single change in target metric reallocates budget more effectively than most creative work.

Channel benchmarks are worth exactly one thing: detecting order-of-magnitude problems. Definitions and audiences differ too much for finer comparison — your own baseline is your benchmark.

---

## 4. Attribution and its limits

Attribution is a model, not a measurement, and every model is wrong in a known way:

| Model | Bias |
|-------|------|
| Last click | Over-credits closing channels (branded search, retargeting), invisible to demand creation |
| First click | Over-credits discovery, ignores what closed |
| Linear / time decay | Spreads credit arbitrarily |
| Data-driven / algorithmic | Better, opaque, and only as good as its input data |
| Media mix modelling | Robust to tracking loss, needs scale and history |
| **Incrementality tests (geo holdout, PSA test, on/off)** | The closest to causal truth; costs volume to run |

Three practical positions worth holding. Privacy changes and consent requirements have made click-level tracking incomplete — a meaningful share of conversions are unobserved, and platform-reported conversions are systematically higher than your own analytics. Self-reported attribution ("how did you hear about us?") in the signup flow is crude but catches word of mouth and offline exposure that no pixel sees. And for any channel receiving serious budget, **run an incrementality test at least once**: turning a channel off in one region for two weeks answers "would these customers have arrived anyway" better than any attribution model, and it regularly shows that a channel's reported conversions are largely people who would have converted regardless.

---

## 5. Saturation and diversification

Every channel has a ceiling. Signs you are approaching it: CPA rises steadily as spend increases; frequency climbs while conversion falls; audience expansion pulls in unqualified traffic; and incremental spend produces flat absolute conversions.

At that point you have four options: improve conversion so you can afford a higher CPA; improve retention or margin so payback still works; find a new audience within the channel; or open a new channel.

Diversification is a risk decision, not an efficiency one. A business taking more than roughly half its new customers from a single channel is exposed to an algorithm change, a policy change, or an account suspension. The mitigation is not "spend equally everywhere" — it is having a **second channel already proven at small scale**, ready to scale if the first one closes.

Owned channels (email list, community, direct traffic, brand search) are the only ones nobody can revoke. They compound slowly and are worth funding for exactly that reason.

---

## 6. Sequencing by stage

| Stage | Focus |
|-------|-------|
| Pre-fit | Do not scale anything. Use manual, unscalable acquisition to reach users to learn from |
| Early fit | Probe 3–4 channels cheaply; find one that works |
| Scaling | Concentrate on the winner; build owned channels in parallel; probe the next candidate |
| Mature | Portfolio management, incrementality testing, efficiency, and saturation monitoring |

The pre-fit row is regularly ignored. Manual outreach and hand-recruited users do not scale — that is their purpose. They deliver conversations and evidence, which is what that stage needs.

---

## 7. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Scaling acquisition before retention flattens | Money spent filling a leaking bucket |
| Optimising for the lowest CPA | Systematically buying users who never stay |
| Killing a channel after one creative and one audience | Discarding a channel that needed a better offer |
| Judging a paid channel inside its learning period | Measuring the algorithm's warm-up |
| Doubling spend overnight | Efficiency collapse; optimisation reset |
| Trusting platform-reported conversions | Double counting; overstated performance |
| Never running an incrementality test | Paying for conversions that would have happened anyway |
| No cohort retention by channel | Cheapest channel quietly the worst |
| CAC excluding salaries, tools, and creative | Unit economics that look profitable and are not |
| One channel above half of new customers | One policy change from zero |
| Only testing a new channel after the current one degrades | No runway when it does |
| Ignoring owned channels because they compound slowly | Permanently renting all distribution |

---

## 8. Checklist

- [ ] Retention flattening confirmed before scaling acquisition
- [ ] All channels scored; 3–4 unused candidates selected for probes
- [ ] Probe → iterate → validate → scale protocol followed with defined budgets
- [ ] At least three meaningfully different approaches tested before killing a channel
- [ ] Platform learning periods respected
- [ ] Scaling done in steps of 30–50%, with efficiency monitored
- [ ] CAC fully loaded, including people, tools, agency, and creative
- [ ] Optimisation target is cost per retained or profitable customer, not CPA
- [ ] Cohort retention tracked by acquisition channel from the first test
- [ ] Payback period tracked per channel against the cash cycle
- [ ] Attribution model's bias understood and stated
- [ ] Self-reported attribution question in the signup flow
- [ ] Incrementality test run at least once for every significantly funded channel
- [ ] Channel concentration monitored; a second channel proven at small scale
- [ ] Owned channels funded deliberately despite slow compounding
