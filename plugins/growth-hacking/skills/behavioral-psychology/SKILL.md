---
description: Persuasion principles applied to product and marketing — social proof, scarcity, reciprocity, authority, commitment, loss aversion, anchoring, defaults and nudging, framing, the peak-end rule and cognitive ease — with the explicit line between legitimate persuasion and manipulation, the dark patterns that are now illegal in the EU, and how to test persuasion ethically.
---

# Behavioural psychology and persuasion

Goal of this skill: use how people actually decide to make good products easier to choose — and know precisely where that turns into manipulation, which is both wrong and, increasingly, unlawful.

Use this skill when optimising conversion, writing copy, designing defaults, or reviewing someone else's "growth hack" that feels off.

---

## 1. The line

The distinction that governs everything in this skill:

| | **Persuasion** | **Manipulation** |
|---|---|---|
| Information | True | False, hidden, or distorted |
| The user's interest | Served or neutral | Harmed |
| If the user understood the technique | They would not object | They would feel deceived |
| Reversibility | Easy to undo | Hard to undo by design |
| Effect on trust | Neutral or positive | Erodes it |
| Effect over time | Compounds | Refunds, chargebacks, complaints, churn |

**The disclosure test** is the practical version: *if we explained exactly what we are doing and why, on the page, would the user still be fine with it?* Showing genuine stock levels passes. Showing a fake countdown that resets on reload does not.

The commercial argument matters as much as the ethical one: manipulative tactics reliably lift a short-term metric and reliably raise refunds, chargebacks, support load, and churn. They are usually **net negative** even when nobody complains — and they are measurable as such if you keep the right guardrails (`experiment-design`).

---

## 2. Principles that work honestly

### Social proof

People look at what others do when uncertain. Use real numbers, real reviews, and real customers — and prefer **specific and similar** proof: "used by 340 physiotherapy practices" persuades a physiotherapist far more than "loved by 50,000 users".

Honest: genuine review counts, verified ratings, real customer logos with permission, actual usage numbers.
Not: fabricated reviews, invented user counts, borrowed logos of non-customers, suppressing negative reviews. Fake reviews are explicitly prohibited under EU consumer law, and platforms and competitors both pursue them.

### Scarcity and urgency

Genuine limits change decisions legitimately — real stock, a real deadline, a real capacity limit.

Honest: actual remaining stock, a real offer end date, genuinely limited cohort places.
Not: countdowns that reset, permanent "only 3 left", "12 people are viewing this" when the number is random. Falsely claiming limited availability is a listed unfair commercial practice in the EU.

### Reciprocity

Give something genuinely useful first — a tool, a template, an analysis, real help — and goodwill follows. The failure mode is a "free" resource that is a sales pitch, which produces the opposite effect.

### Authority

Expertise reduces perceived risk. Real credentials, real research, real expert contributions. Not: invented credentials, borrowed authority, or implying endorsement that does not exist.

### Commitment and consistency

Small steps make larger ones more likely — which is why progressive forms work. Legitimate when each step is genuinely wanted; manipulative when early steps are designed to trap ("you have come this far") or when the real cost only appears at the end.

### Loss aversion

Losses weigh more than equivalent gains, so framing around what is lost is powerful. Legitimate: "your export expires in 7 days" when it does. Manipulative: manufactured loss, or guilt-based confirmshaming ("No thanks, I like wasting money").

### Anchoring

The first number seen shapes judgement — which is why a higher tier makes the middle one look reasonable, and why the original price affects the perception of a discount. Legitimate when the anchor is real: the higher tier must be genuinely purchasable, and a "was" price must have been genuinely charged for a meaningful period. EU price-indication rules require reference prices to be the lowest price applied in the preceding 30 days; inventing an anchor is unlawful.

### Defaults and nudging

Defaults are extremely powerful and unavoidable — some option must be preselected. That makes the choice an ethical one.

Legitimate: defaulting to the option most users want, pre-filling data you already hold, choosing a sensible plan.
Not: pre-ticked consent boxes (invalid under the GDPR), pre-selected paid add-ons, opt-out subscriptions after a trial without a clear prior notice.

The test for a default: **does it serve the user, or only you?**

### Framing, cognitive ease, and peak-end

Presentation changes perception without changing facts: per-month rather than per-year, what is gained rather than what is spent. Legitimate as long as the total is clear and findable.

People judge experiences by their **peak** and their **end** — so the strongest investments are a memorable high point (the first success) and a clean ending (a smooth checkout, a graceful cancellation). And processing ease is mistaken for truth: simple language, legible type, and clear structure make claims more believable, which is a reason to write clearly and not a licence to make dubious claims easier to swallow.

---

## 3. Dark patterns to refuse

These are named in EU regulation and consumer-protection enforcement, not merely disapproved of:

| Pattern | What it is |
|---------|-----------|
| **Confirmshaming** | Guilt-loaded decline options |
| **Roach motel** | Easy to subscribe, hard to cancel |
| **Sneak into basket** | Items or add-ons added without action |
| **Hidden costs** | Fees revealed only at the final step |
| **Bait and switch** | Advertised offer unavailable on arrival |
| **Disguised ads** | Advertising presented as content or navigation |
| **Forced continuity** | Silent conversion from trial to paid billing |
| **Misdirection** | Visual hierarchy steering away from the user's interest |
| **Trick questions** | Deliberately confusing consent wording, double negatives |
| **Fake scarcity or urgency** | Invented counters and timers |
| **Fake reviews and testimonials** | Fabricated or incentivised without disclosure |
| **Preselected consent** | Pre-ticked boxes for marketing or tracking |
| **Nagging** | Repeated interruption until the user gives in |
| **Privacy Zuckering** | Confusing settings that push toward more data sharing |

The Digital Services Act prohibits interfaces that deceive or manipulate users on online platforms; the Unfair Commercial Practices Directive covers misleading actions and omissions; the GDPR invalidates consent that is not freely given, specific, informed, and unambiguous. In Germany these are additionally enforceable by competitors and consumer associations via the UWG — meaning the practical risk is a *Abmahnung* from a competitor, not only a regulator (`growth-legal-and-ethics`).

---

## 4. Testing persuasion responsibly

- **Declare guardrails**: refunds, chargebacks, cancellations, support contacts, and complaint rate. A conversion win that raises refunds is a loss.
- **Measure at a longer horizon** than the conversion itself. Manipulation shows up 30–90 days later, so a test judged at day 7 will look like a win.
- **Apply the disclosure test** during experiment design, not after launch.
- **Have a named reviewer** for anything touching consent, pricing display, cancellation, or claims.
- **Keep a banned-tactics list** the team agrees to in advance, so the decision is not made under quarterly pressure.
- **Segment by vulnerability** where relevant: tactics that pressure people in financial difficulty or health-related distress deserve a much higher bar, and regulators treat them accordingly.

---

## 5. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Fake countdowns, fake stock, fake viewer counts | Unlawful in the EU; erodes trust when noticed |
| Fabricated or incentivised undisclosed reviews | Explicitly prohibited; platform and legal consequences |
| Pre-ticked consent boxes | Consent invalid under the GDPR |
| Hidden costs revealed at the last step | Largest cause of abandonment; misleading practice |
| Confirmshaming decline options | Damages brand for a marginal lift |
| Cancellation harder than signup | Regulated in the EU and Germany; produces chargebacks |
| Trial converting to paid without clear prior notice | Refunds, disputes, regulatory exposure |
| "Was" prices never actually charged | Breaches price-indication rules |
| Judging persuasion tests at day 7 | Manipulation looks like a win at short horizons |
| No guardrail metrics on persuasion experiments | Net-negative changes shipped as wins |
| Copying a competitor's dark pattern | Their legal exposure becomes yours |
| Treating "it converts" as sufficient justification | The whole category of harm is unmeasured |

---

## 6. Checklist

- [ ] Disclosure test applied: would the user object if we explained this?
- [ ] Every scarcity, urgency, and social-proof claim verifiably true
- [ ] Review and rating displays genuine; no suppression of negatives
- [ ] Reference and "was" prices comply with price-indication rules
- [ ] Anchor tiers genuinely purchasable
- [ ] Defaults serve the user; no pre-ticked consent, no pre-selected paid add-ons
- [ ] Total price, including tax and fees, visible before the final step
- [ ] Cancellation at least as easy as signup
- [ ] Trial-to-paid conversion preceded by a clear notice
- [ ] Banned-tactics list agreed in advance by the team
- [ ] Guardrails on persuasion tests: refunds, chargebacks, cancellations, complaints
- [ ] Persuasion experiments measured at 30–90 days, not only at conversion
- [ ] Named reviewer for consent, pricing display, cancellation, and claims
- [ ] Higher bar applied where the audience may be vulnerable
