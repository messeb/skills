---
description: The legal limits of growth tactics in the EU and Germany — GDPR/DSGVO lawful bases, consent and tracking, email marketing under UWG and ePrivacy, cold outreach in B2B, influencer disclosure, sweepstakes and prize draws, price indication and cancellation rules, dark-pattern prohibitions under the DSA, scraping and terms of service, the Abmahnung risk, and an experiment review process that does not block the team.
---

# Legal limits and ethics of growth tactics

Goal of this skill: know which growth tactics are unlawful in the EU and Germany before running them, and build a review step light enough that the team still moves quickly.

Use this skill when designing acquisition, referral, or persuasion experiments; when setting up tracking or email programmes; and when someone proposes a tactic that "everyone does".

**This is orientation for practitioners, not legal advice.** Rules change and enforcement varies by member state — get qualified counsel for anything material.

---

## 1. Why this matters more in Germany than in many markets

Beyond regulators, Germany has a **private enforcement culture**: competitors and consumer associations can issue an *Abmahnung* (formal warning with costs) and seek an injunction under the UWG. The practical consequence is that the realistic risk of an unlawful tactic is not a distant regulatory investigation but a competitor's lawyer within weeks, with legal costs and a cease-and-desist declaration carrying contractual penalties for repeats.

This changes the calculus: tactics that are merely risky elsewhere are actively expensive here.

---

## 2. Data protection (GDPR / DSGVO)

Every growth activity that touches personal data needs a **lawful basis** — and personal data includes IP addresses, cookie ids, device identifiers, and email addresses.

| Basis | Growth use | Caution |
|-------|-----------|---------|
| **Consent** | Marketing email, non-essential cookies, tracking, profiling | Must be freely given, specific, informed, unambiguous, opt-in, and as easy to withdraw as to give |
| **Contract** | Transactional email, service delivery | Does not cover marketing |
| **Legitimate interest** | Some analytics, B2B contact in narrow cases, fraud prevention | Requires a documented balancing test; does not override the ePrivacy consent requirement for device access |

Operational requirements that recur in growth work: a **cookie banner that genuinely allows rejection** as easily as acceptance, with no pre-ticked boxes and no tracking before consent; a **record of processing activities**; a **data processing agreement** with every tool that handles personal data; a **transfer mechanism** for tools processing outside the EU; **data minimisation** (do not collect a phone number you will not use); **deletion on request**, including from your email platform and analytics; and a **DPIA** for large-scale profiling or tracking.

Three growth-specific traps: **A/B testing and analytics tools set identifiers** and therefore usually require consent before loading; **enrichment services** that append data to a lead require a lawful basis and a transparency notice to that person; and **contact-list access** ("find your friends") is a data-protection problem for the contacts, who never agreed to anything.

---

## 3. Email and messaging

The strictest area in practice, and where growth teams most often assume US rules apply.

| Situation | Germany / EU |
|-----------|--------------|
| Marketing email to a consumer | **Opt-in consent required**, with double opt-in as the practical evidentiary standard |
| Marketing email to a business contact | Also requires consent in Germany — B2B is **not** a general exemption |
| Existing-customer exception (§7 UWG) | Narrow: own similar products, address obtained during a sale, objection possible at collection and in every message, clear notice given |
| Newsletter with a pre-ticked box | Invalid consent |
| Buying an email list | Consent is not transferable; sending to it is unlawful |
| Scraping addresses from websites or LinkedIn | Unlawful sending, plus terms-of-service violations |
| Transactional email | Permitted on contractual basis, but must not carry marketing content |
| Cold LinkedIn or WhatsApp messages | Treated as electronic direct marketing; the same consent logic applies |

Every marketing message needs a working unsubscribe honoured promptly, an *Impressum* (provider identification), and no misleading subject line or sender. Double opt-in matters because **the burden of proof of consent is on you** — keep timestamped records.

Cold outreach in B2B is the tactic teams most often import from US playbooks and is the one most likely to produce an Abmahnung. If you do outbound in the DACH region, take proper advice on the specific approach rather than assuming.

---

## 4. Advertising and claims

- **Undisclosed advertising is prohibited.** Sponsored content, influencer posts, affiliate links, and incentivised reviews must be clearly labelled — "Werbung" or "Anzeige" — recognisably and at the start, not buried in hashtags. Free products count as consideration. **Both** the creator and the commissioning brand can be liable (`referral`).
- **Comparative advertising** is permitted but tightly conditioned: comparisons must be objective, verifiable, on relevant features, and must not denigrate a competitor.
- **Claims must be substantiated**, including health, environmental, and performance claims. Vague green claims are an active enforcement area under EU rules.
- **Price indication**: prices must include VAT and show any additional costs; strike-through reference prices must reflect the lowest price applied in the previous 30 days.
- **Testimonials and reviews** must be genuine; fabricating them or incentivising without disclosure is a listed unfair practice.

---

## 5. Sweepstakes, contests, and incentives

Common in growth campaigns and frequently non-compliant:

- Publish **complete terms**: eligibility, period, prizes, selection method, and how winners are notified.
- **Do not couple participation to a purchase** where that is restricted; and do not couple it to marketing consent in a way that makes the consent non-free — bundled consent is a recurring finding.
- Follow **platform rules** (Instagram, Facebook, and others restrict mechanics such as tagging strangers or sharing to a personal profile as an entry condition); breaking them risks the account, which is often the bigger loss.
- **Data collected for a prize draw may only be used for that draw** unless separate, specific consent was given.
- Consider tax and gambling implications for high-value prizes and any element of chance combined with payment.
- Referral incentives are generally fine, but must not induce misrepresentation, and the referred person's data still needs a lawful basis (`referral`).

---

## 6. Contracts, subscriptions, and cancellation

- **Order button** must be labelled unambiguously ("zahlungspflichtig bestellen" / "Buy now") — the German *Button-Lösung*; an incorrectly labelled button can mean no contract was formed.
- **Withdrawal rights** for consumers: correct information and a working procedure; incorrect information extends the withdrawal period substantially.
- **Cancellation must be at least as easy as signup**; German law requires an accessible cancellation button for online contracts.
- **Automatic renewals** require clear disclosure before purchase; trial-to-paid conversion requires prior notice.
- Full **provider identification (Impressum)** and terms accessible before purchase.

---

## 7. Dark patterns and platform rules

The Digital Services Act prohibits interfaces on online platforms that deceive or manipulate users or materially distort their ability to make free decisions; the Unfair Commercial Practices Directive covers misleading actions and omissions and lists several practices as always unfair — including false scarcity, fake reviews, and bait advertising (`behavioral-psychology`).

Separately, **platform terms of service** are contracts. Scraping in breach of them, automating actions on social platforms, creating fake accounts, or buying engagement risks account termination — and losing an established account is frequently a larger business loss than a fine. Any growth tactic whose mechanism is "the platform has not noticed yet" is a liability, not a strategy.

Scraping specifically: publicly accessible does not mean freely usable. Personal data in scraped content is subject to the GDPR regardless of where it was found, database rights may apply, and terms of service usually prohibit it.

---

## 8. A review process that does not block the team

Legal review kills growth velocity when it is applied uniformly. Tier it:

| Tier | Examples | Review |
|------|----------|--------|
| **Green — no review** | Copy and layout changes, internal onboarding flow, subject-line tests, CTA wording | None; ship inside the pre-approved sandbox |
| **Amber — checklist, self-served** | New landing page, new ad creative, referral incentive tweak, lifecycle email in an existing programme | Team applies the checklist below; documented |
| **Red — named reviewer** | New tracking or tool, consent flow, price or discount display, cancellation flow, sweepstakes, cold outreach, influencer contract, claims about results, anything involving special-category or children's data | Named reviewer, agreed turnaround, fast lane |

Make the green tier as wide as defensible — that is what preserves experiment throughput (`growth-team`). Keep the amber checklist to a page. Agree a turnaround expectation for red, so review is a step and not a wall.

**Amber checklist**: Is personal data involved, and what is the lawful basis? Is consent needed, and is it opt-in and withdrawable? Is every claim true and substantiated? Is any advertising disclosed? Are prices and additional costs shown correctly? Can the user reverse the action easily? Would we be comfortable if this were described publicly?

---

## 9. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| "Everyone does it" as justification | Widespread practice is not a defence, particularly under the UWG |
| Applying US email rules (opt-out) in the EU | Unlawful sending; Abmahnung risk |
| Assuming B2B is exempt from consent in Germany | It is not |
| Buying or scraping email lists | Consent is not transferable; unlawful sending |
| Tracking loading before consent | GDPR and ePrivacy breach; invalid analytics data |
| Pre-ticked consent boxes | Consent invalid; the collected data is unusable |
| Influencer posts without clear labelling | Liability for creator and brand |
| Sweepstakes consent bundled with entry | Consent not freely given |
| Fake urgency, fake reviews, invented reference prices | Listed unfair practices |
| Cancellation harder than signup | Regulated; plus chargebacks and complaints |
| Growth tactics that rely on breaching platform terms | Account loss after you depend on the channel |
| Legal review applied uniformly to every experiment | Velocity collapses; teams route around the process |
| No record of consent | Burden of proof is yours and you cannot meet it |

---

## 10. Checklist

- [ ] Lawful basis documented for every processing activity in the growth stack
- [ ] Consent banner allows rejection as easily as acceptance; nothing loads before consent
- [ ] Double opt-in with timestamped records for all marketing email
- [ ] B2B outreach in DACH reviewed specifically, not assumed permitted
- [ ] Data processing agreements and transfer mechanisms in place for every tool
- [ ] Unsubscribe honoured promptly across all systems, including analytics and CRM
- [ ] Impressum and provider identification present where required
- [ ] All advertising, sponsorship, and incentivised content clearly labelled
- [ ] Claims substantiated; comparative advertising conditions met
- [ ] Prices include VAT and additional costs; reference prices comply with the 30-day rule
- [ ] Sweepstakes terms published; consent not bundled; platform rules checked
- [ ] Order button correctly labelled; withdrawal information correct
- [ ] Cancellation at least as easy as signup, with the required online mechanism
- [ ] No tactic depends on breaching platform terms of service
- [ ] Tiered review defined: wide green sandbox, one-page amber checklist, named red reviewer
- [ ] Banned-tactics list agreed in advance, before quarterly pressure arrives
