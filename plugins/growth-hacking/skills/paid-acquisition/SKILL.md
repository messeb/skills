---
description: Paid channels run as experiments — account structure and campaign hygiene, the hierarchy of levers (audience, offer, creative, landing page), creative testing at volume, search versus social versus display intent differences, retargeting done proportionately, bidding and budget management, measuring incrementality rather than platform-reported conversions, and the compliance requirements for ad tracking in the EU.
---

# Paid acquisition

Goal of this skill: buy customers profitably and know that you did — which means testing the right levers in the right order and measuring beyond what the ad platform reports about itself.

Use this skill when scaling a paid channel, when CPA is rising, or when platform-reported results and actual revenue disagree.

---

## 1. The hierarchy of levers

Effort is routinely spent in the reverse of the order that matters:

| Rank | Lever | Typical effect |
|------|-------|----------------|
| 1 | **Offer** — what is promised and at what price | Largest; changes who responds at all |
| 2 | **Audience / targeting** | Large; the wrong audience cannot be rescued by creative |
| 3 | **Landing experience** — message match and conversion | Large; determines whether the click is wasted |
| 4 | **Creative** — the ad itself | Moderate to large on social, where creative *is* the targeting |
| 5 | **Ad copy details, headlines** | Moderate |
| 6 | **Bidding and budget mechanics** | Small once sane |
| 7 | **Ad extensions, cosmetics** | Marginal |

Test top-down. A team that has tested forty headlines and one offer has not tested the channel (`growth-process`).

Note the platform-specific weighting: on search, **intent is given** by the query, so the offer and landing page dominate. On social and video, **creative selects the audience** — the algorithm finds people who respond to what you made — so creative volume and diversity matter far more there than on search.

---

## 2. Account structure and hygiene

Modern ad platforms optimise better with **consolidated** structures than with the heavily fragmented accounts that were once best practice. Fragmentation splits conversion data across too many units, and none of them gets enough signal to optimise.

Practical guidance: keep enough campaigns to control budget by objective and geography, and no more; ensure each optimisation unit can reach the platform's minimum weekly conversion threshold, or optimise toward a higher-funnel event instead; separate prospecting from retargeting so their very different economics do not blend; separate brand from non-brand in search, since brand traffic would largely have arrived anyway and hides non-brand performance; and use exclusions properly — existing customers excluded from acquisition campaigns, converters excluded from retargeting.

Hygiene that is unglamorous and pays: negative keywords reviewed regularly on search, placement exclusions on display, frequency caps set, and creative refreshed before fatigue rather than after.

---

## 3. Creative testing

On social platforms, creative is the highest-volume test you will run.

- **Test concepts, not variations.** Five genuinely different angles beat fifty colour variants. Change the message, the format, the proof, or the audience being addressed.
- **Produce for volume.** Creative fatigues; a channel at scale consumes new concepts continuously. Build a repeatable production process rather than treating each asset as a project.
- **Mine what already works**: customer language from research, support and sales objections, high-performing organic posts, and reviews.
- **User-generated and unpolished formats** frequently outperform produced brand assets on social, because they match the feed.
- **Test the hook separately.** The first two seconds of a video or the first line of text decides most of the outcome.
- **Watch competitors' long-running ads** in public ad libraries — longevity indicates performance (`growth-strategy`).
- **Refresh before fatigue**: rising frequency with falling click-through is the signal, and it arrives sooner than most teams plan for.

---

## 4. Channel differences

| Channel | Intent | Best for | Watch |
|---------|--------|----------|-------|
| **Paid search — non-brand** | High, explicit | Capturing existing demand | Expensive in competitive categories; limited by search volume |
| **Paid search — brand** | Highest | Defending the brand term | Largely non-incremental — test with a holdout before assuming value |
| **Shopping / product listings** | High, transactional | E-commerce | Feed quality is the main lever |
| **Paid social** | Low, interruption | Demand creation, broad reach | Creative-dependent; needs a strong offer |
| **Display / programmatic** | Very low | Awareness, retargeting | Viewability and fraud; easily wasted |
| **Video / short-form** | Low | Demand creation, storytelling | Hook decides everything |
| **Professional networks** | Medium, B2B targeting | Precise firmographic reach | High CPMs; needs high customer value |
| **Retargeting** | Warm | Recovering abandonment | Frequently over-credited; cap frequency |
| **Affiliate** | Varies | Performance-based reach | Fraud, brand-term bidding, disclosure obligations |

Retargeting deserves the strongest caution: it targets people who were already going to convert, so last-click attribution flatters it enormously. Cap frequency, exclude converters, and **run a holdout** — teams that do commonly discover a large share of retargeting spend is buying conversions they already had.

---

## 5. Bidding and budget

- Start with **manual or capped bidding** while learning; move to automated bidding once conversion volume supports it.
- Automated bidding needs **conversion volume** — below the platform's threshold it optimises on noise. Optimise to a higher-funnel event until volume exists.
- Respect **learning periods**: significant edits reset them. Batch changes rather than adjusting daily.
- **Scale in steps** of 20–50%; large jumps degrade efficiency.
- Set **target CPA or ROAS from your payback requirement**, not from what the platform suggests.
- Watch **dayparting and geography** — but only where the data supports a real difference.
- Track **spend against the budget cap daily**; the most expensive incidents in paid acquisition are configuration errors, not strategy errors.

---

## 6. Measurement

The core discipline: **do not accept the platform's report of its own performance.**

| Problem | Practice |
|---------|----------|
| Platforms claim overlapping conversions | Reconcile against your own analytics and billing; expect platform figures to be higher |
| View-through conversions inflate credit | Judge on click-through primarily; treat view-through separately |
| Last-click over-credits closing channels | Use assisted views and self-reported attribution (`acquisition`) |
| Consent loss means missing conversions | Server-side conversion tracking with consent; expect a modelled gap |
| Correlation mistaken for causation | **Incrementality testing** — geo holdout, on/off, or PSA — at least once per significantly funded channel |

Also required: cohort retention by campaign, not just CPA. Campaigns that acquire cheaply and retain badly are common, and only visible when cohorted by source.

The measurement that ends most arguments is the simplest: turn the channel off in one region for two weeks and compare. It costs volume and it produces a causal answer.

---

## 7. Compliance

Ad tracking in the EU sits directly on top of the consent requirements:

- **Tracking pixels require consent** before loading; nothing fires before the banner is answered.
- **Consent mode / server-side tagging** should reflect actual consent state, not bypass it.
- **Custom audiences from uploaded customer lists** need a lawful basis and a transparency notice; check the platform's own required terms too.
- **Retargeting requires consent** for the tracking that enables it.
- **Ad content** must meet advertising law: substantiated claims, correct price indication including VAT, and no misleading urgency (`growth-legal-and-ethics`).
- **Special categories** — health, finance, and similar — carry additional restrictions on both platforms and law.

Non-compliant tracking is not only a legal problem; it is a data problem, because a consent banner rejected by a large share of users produces analytics that under-report by exactly that share.

---

## 8. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Testing headlines before testing the offer | Optimising the smallest lever |
| Over-fragmented account structure | No unit gets enough signal to optimise |
| Judging a campaign inside the learning period | Measuring the warm-up |
| Doubling budget overnight | Efficiency collapse; optimisation reset |
| Accepting platform-reported conversions as truth | Overstated performance, misallocated budget |
| Never running an incrementality test | Paying for conversions that would have happened |
| Brand search reported as acquisition performance | Non-incremental spend counted as a win |
| Retargeting credited by last click, uncapped | Large spend on people already converting |
| Optimising CPA rather than cost per retained customer | Cheap traffic that never stays |
| Creative never refreshed until performance collapses | Avoidable fatigue losses |
| Ad clicks landing on a generic homepage | Message match broken; the click is wasted |
| Pixels firing before consent | Legal exposure and unusable data |
| No daily budget monitoring | Configuration errors become expensive incidents |

---

## 9. Checklist

- [ ] Offer and audience tested before creative details
- [ ] Account structure consolidated enough for each unit to reach conversion thresholds
- [ ] Prospecting, retargeting, brand, and non-brand separated
- [ ] Customer and converter exclusions applied
- [ ] Creative tested as distinct concepts, with a repeatable production process
- [ ] Hook tested separately on video and social
- [ ] Creative refreshed on frequency and click-through signals, before collapse
- [ ] Bidding matched to conversion volume; learning periods respected
- [ ] Target CPA or ROAS derived from the payback requirement
- [ ] Scaling in 20–50% steps with efficiency monitored
- [ ] Platform conversions reconciled against own analytics and billing
- [ ] Self-reported attribution collected in the signup flow
- [ ] Incrementality test run for every significantly funded channel, including brand and retargeting
- [ ] Cohort retention tracked by campaign, not just CPA
- [ ] Consent respected before any pixel fires; server-side tagging reflects consent state
- [ ] Ad claims, prices, and urgency compliant
- [ ] Daily budget and anomaly monitoring in place
