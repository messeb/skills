---
description: The measurement stack behind growth experiments — choosing between product analytics, web analytics, warehouse-first and experimentation tools, designing an event taxonomy and tracking plan, identity resolution across anonymous and logged-in users, server-side versus client-side collection, consent-compliant tracking in the EU and what it does to your data, validating that tracking is correct, and the reconciliation discipline that keeps numbers trusted.
---

# Analytics and tracking

Goal of this skill: numbers the team actually trusts — because every experiment result, every cohort curve, and every cost-per-retained-customer figure in this plugin depends on measurement being correct.

Use this skill before running the first experiment, when two dashboards disagree, when a result cannot be explained, or when consent changes have made reporting inconsistent.

Instrumentation comes **before** experimentation. A test launched on untrusted tracking produces a number nobody will act on, and the argument about the number will cost more than the test.

---

## 1. The tool categories

They answer different questions; most teams need two or three, not one of each.

| Category | Answers | Examples of the type |
|----------|---------|----------------------|
| **Product analytics** | What do users *do*? Funnels, cohorts, retention, paths | Event-based tools such as Mixpanel, Amplitude, PostHog |
| **Web analytics** | Where does traffic come from, what do sessions look like? | GA4, Plausible, Matomo, Fathom |
| **Experimentation** | Which variant won, with what confidence? | Dedicated A/B platforms, or feature-flag tools with metrics |
| **Qualitative / behavioural** | *Why* did they struggle? | Session recording and heatmap tools such as Hotjar or Clarity |
| **Warehouse + BI** | Anything, joined with billing and CRM | Warehouse plus a BI layer; the only place true unit economics live |
| **CDP / event pipeline** | One collection layer feeding all of the above | Segment, RudderStack, or a self-hosted pipeline |
| **Attribution / MMM** | Which channels contributed? | Platform reports, self-reported surveys, incrementality tests (`acquisition`) |

Practical guidance for choosing:

- **Retention and activation questions need product analytics.** Web analytics cannot answer "do cohorts flatten", which is the central question of `product-market-fit`.
- **Unit economics need the warehouse**, because CAC and LTV require joining product events with billing and ad spend — no single SaaS tool has all three.
- **A warehouse-first setup** (collect once, model in the warehouse, feed the tools) costs more to build and removes most of the "which tool is right?" arguments permanently. Worth it once there are more than two tools or more than one team asking questions.
- **Self-hosted or EU-hosted options** are worth real consideration in the EU, since they materially simplify the transfer and consent picture (`growth-legal-and-ethics`).
- **Every extra tool is a tracking surface to maintain and a consent obligation.** Two well-implemented tools beat five half-implemented ones.

---

## 2. The tracking plan

Instrumentation designed ad hoc becomes unusable within months. Write the plan first, in one shared document, and treat it as the source of truth.

```markdown
| Event | When it fires | Properties | Owner | Used by |
|-------|---------------|------------|-------|---------|
| signup_completed | Account created, email verified | method, plan_intent, referrer_source | Growth | Activation funnel, channel cohorts |
| project_created | User saves their first project | project_type, template_used, seconds_since_signup | Product | ACTIVATION EVENT — KPI tree leaf |
| invite_sent | Invite dispatched | channel, recipients_count | Growth | Referral loop (k-factor) |
| subscription_started | First successful payment | plan, billing_period, discount_code | Billing | Revenue, payback |
```

Naming rules that prevent the usual mess: **`object_action` in past tense**, lower snake case, consistently (`project_created`, never a mix of `Created Project`, `create-project`, and `projectCreate`). Keep the event count small — 20–50 well-chosen events beat 400 — and put variation in **properties**, not in new event names. Define every property's type and allowed values. Never put personally identifying data in event names or properties.

The rule that matters most: **an event exists because a named question needs it.** Track what you will act on. Everything else is cost, consent surface, and noise.

Version the plan, review it when the product changes, and make updating it part of the definition of done for any feature that adds a step to the funnel.

---

## 3. Identity

Getting this wrong quietly corrupts every cohort and every funnel.

| Concept | Meaning |
|---------|---------|
| **Anonymous id** | Device or browser identifier before signup |
| **User id** | Your stable internal id after signup — never an email address |
| **Alias / identify** | The stitch that links pre-signup activity to the account |
| **Group / account id** | The company or workspace, essential for B2B analysis |

Requirements: call `identify` at signup **and** on every login, so returning users on new devices merge correctly; use your internal id, never an email or anything that changes; send the account id on every event in B2B so retention can be measured per company rather than per seat; and accept the limits honestly — cross-device tracking without login is incomplete, and consent rejection means some users are simply not observed.

State those limits wherever the numbers are reported. Analytics that silently under-count are worse than analytics known to under-count by roughly a known amount.

---

## 4. Client-side, server-side, and consent

| Collection | Strengths | Weaknesses |
|------------|-----------|------------|
| **Client-side** | Captures UI interactions, easy to add | Blocked by ad blockers and consent rejection; loses a meaningful share of events |
| **Server-side** | Reliable, complete, tamper-resistant; ideal for revenue and lifecycle events | Cannot see pure UI behaviour; more work to build |

The practical split: track **business-critical events server-side** (signup, activation, payment, subscription changes) and **interaction events client-side**. That way the numbers your business decisions rest on do not fluctuate with browser extensions.

Consent in the EU is not an afterthought here:

- Nothing that sets an identifier may load before consent is given (`growth-legal-and-ethics`).
- Server-side tagging must **reflect** consent state, not route around it. Using a server-side proxy to track users who rejected tracking is a breach, not a clever workaround.
- Expect a material share of users to reject; your analytics will systematically under-report by roughly that share.
- Consequently, **relative comparisons and trends stay valid; absolute totals do not.** Design your reporting around ratios, rates, and cohort comparisons rather than absolute counts.
- Consider a consent-free measurement baseline (aggregate server logs, order counts from billing) to sanity-check the consented data.

---

## 5. Validating the tracking

Assume instrumentation is broken until proven otherwise; it usually is.

| Check | How |
|-------|-----|
| Events fire when expected | Walk the funnel manually in a debug view before release |
| Events fire **only** when expected | Duplicate firing is common and silently doubles conversion rates |
| Properties populated and correctly typed | Look for nulls, empty strings, and `"undefined"` as a value |
| Identity stitches | Sign up, log out, log in on another browser, confirm one user |
| Funnel numbers are plausible | A step with a higher count than the one above it is a bug |
| Against billing | Analytics revenue must reconcile with the billing system; **billing wins** |
| Against server logs | Total sessions and orders should be in the right order of magnitude |
| A/A test | Two identical variants must show no significant difference (`experiment-design`) |

Automate what you can: a smoke test in CI that fires the critical events and asserts they arrive, and an alert on volume anomalies per event. Tracking breaks silently during ordinary releases — a renamed button, a changed route — and is usually discovered weeks later when someone questions a chart.

Reconcile against billing on a schedule, not only when something looks wrong.

---

## 6. Making the data usable

- **One definition per metric**, written down centrally. "Active user" means one thing company-wide (`north-star-and-metrics`).
- **Separate decision dashboards** (few metrics, weekly, tied to actions) from exploration tools.
- **Every metric has an owner** and a documented calculation.
- **Cohorts by default**, aggregates on request — aggregates hide churn.
- **Annotate the timeline** with releases, campaigns, outages, and pricing changes; half the unexplained chart movements are explained by an annotation nobody made.
- **Retain raw events** long enough to recompute history when a definition changes; a metric definition change without recomputable history creates a permanent discontinuity.
- **Document the known gaps** — consent loss, blocked clients, cross-device — next to the numbers, so readers calibrate rather than over-trust.

---

## 7. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Running experiments before instrumentation is verified | Uninterpretable results; arguments instead of decisions |
| Tracking added after launch | No baseline; the first result cannot be compared |
| 400 events, no tracking plan | Nobody knows which is correct; none are trusted |
| Inconsistent event naming | Analysis becomes archaeology |
| New event names instead of properties | Combinatorial explosion, unusable funnels |
| Email address used as the user id | Breaks on change; personal data spread across tools |
| `identify` only at signup, not at login | Returning users counted as new; cohorts corrupted |
| No account id in a B2B product | Retention measured per seat, not per customer |
| Revenue events tracked client-side only | Ad blockers silently reduce reported revenue |
| Server-side tagging used to bypass consent | Data-protection breach dressed as a technical solution |
| Absolute totals reported as if complete post-consent | Confident, wrong numbers |
| Analytics never reconciled with billing | Two versions of revenue, neither trusted |
| Duplicate event firing undetected | Conversion rates silently doubled |
| Metric definitions changed without recomputable history | Permanent discontinuity in the trend |
| Charts without annotations | Every movement re-investigated from scratch |
| Personal data in event properties | GDPR exposure across every connected tool |

---

## 8. Checklist

- [ ] Tool categories chosen deliberately; product analytics present for retention questions
- [ ] Warehouse in place where unit economics must join product, billing, and ad spend
- [ ] Tracking plan written, versioned, and owned before instrumentation
- [ ] Every event justified by a named question it answers
- [ ] Consistent `object_action` past-tense naming; variation in properties, not event names
- [ ] Event count kept small and curated
- [ ] No personal data in event names or properties
- [ ] Internal stable user id used; `identify` called at signup and every login
- [ ] Account id on every event for B2B
- [ ] Business-critical events collected server-side; interactions client-side
- [ ] Nothing loads before consent; server-side tagging reflects consent state
- [ ] Reporting built on rates and cohort comparisons rather than absolute totals
- [ ] Tracking validated manually and by an automated smoke test in CI
- [ ] Duplicate-firing and volume-anomaly alerts in place
- [ ] Analytics reconciled against billing on a schedule
- [ ] A/A test passed before trusting the experimentation setup
- [ ] Metric definitions centralised, owned, and versioned; raw events retained
- [ ] Timeline annotated with releases, campaigns, outages, and pricing changes
- [ ] Known measurement gaps documented alongside the numbers
