---
description: Turning signups into users who experience value — defining the aha moment from data, onboarding design and time to value, landing page and form optimization, call-to-action and copy testing, usability testing methods, session analysis and behavioural analytics, and the conversion work that compounds because it improves every channel at once.
---

# Activation

Goal of this skill: get the largest possible share of new users to the moment where the product's value becomes obvious — quickly, and without asking for anything that can wait.

Use this skill when signups are healthy and retention is poor, when onboarding completion is low, or when paid channels do not reach payback despite good click-through.

Activation work compounds: improving it makes **every** acquisition channel more efficient at once, which is why it is usually a better investment than another channel test.

---

## 1. Find the aha moment from data, not intuition

The activation event is the action after which retention visibly improves. Find it rather than assuming it.

1. Split users into retained and churned cohorts at a horizon that matters (day 30, week 4).
2. For each candidate action in week one, compare the share of each cohort that performed it.
3. Look for a **step change**, not a smooth gradient — the point where the retention curve separates.
4. Test thresholds, not just occurrence: often it is "created 3 documents" rather than "created a document".
5. **Validate causally.** Correlation is guaranteed here — engaged users do more of everything. Run an experiment that drives users toward the candidate action and check whether retention actually moves.

Step 5 is the one that gets skipped, and it matters: a famous activation metric that is merely correlated will send a team optimising a number that does not cause anything.

Once identified, the activation event becomes the primary metric for onboarding, the success criterion for acquisition channels, and a leaf in the KPI tree (`north-star-and-metrics`).

---

## 2. Time to value

Between signup and value, everything is friction and risk. Measure median and 90th-percentile time to the activation event, then attack it:

| Lever | Practice |
|-------|----------|
| Remove steps | Every step before value costs a share of users. Delete, defer, or default them |
| Defer data collection | Ask after value is delivered, not before. Company size and phone number can wait |
| Delay account creation | Let people experience the product before signing up where the model allows |
| Solve the empty state | Templates, sample data, or import — never a tour explaining an empty screen |
| Do the work for them | Pre-fill from what you already know; import from the tool they are leaving |
| Progressive disclosure | Introduce features when they become relevant, not all at once |
| Show progress | A short checklist with visible completion, if it reflects genuine value steps |

The two highest-yield interventions in most products are **removing a step** and **fixing the empty state**. Both are usually cheaper than the tour, the tooltips, and the welcome video that teams build instead.

Email and lifecycle messaging support activation but cannot replace it: a well-written onboarding email sequence around a product that takes twenty minutes to reach value is a patch on a design problem.

---

## 3. Landing pages

The landing page is where the channel's promise is either kept or broken.

| Element | Rule |
|---------|------|
| **Message match** | The headline must continue the ad, email, or search result. A mismatch is the largest single cause of bounce |
| **Above the fold** | What it is, who it is for, what it replaces, and one action |
| **One primary action** | Competing CTAs reduce total conversion |
| **Proof near the action** | Logos, numbers, reviews, security marks — placed where hesitation happens, not in a footer |
| **Objection handling** | Answer the top three objections from sales and support, on the page |
| **Speed** | Load time is a conversion metric; treat it as a guardrail in every test |
| **Mobile first** | Usually the majority of traffic, and usually the worse experience |
| **Clarity over cleverness** | A clever headline that requires interpretation loses to a plain one |

Test the big things first: **offer, headline and promise, page structure, form length, and price presentation** move conversion far more than button colour. Button tests are popular because they are easy, and that is the only reason.

---

## 4. Forms

Forms are where measurable, unglamorous conversion lives.

- **Every field costs conversion.** Justify each one; remove anything sales could obtain later or enrichment could infer.
- **One column**, labels above fields, logical grouping.
- **Inline validation** on blur, with helpful messages — never a single error summary after submission that discards what was typed.
- **Never clear the form on error.** This is still common and is pure loss.
- **Right input types and autocomplete attributes** so mobile keyboards and password managers work.
- **Show progress** in multi-step flows, and let people go back without losing data.
- **Ask the easy questions first**; commitment builds and abandonment falls once someone has begun.
- **Explain why** for anything sensitive — phone number, company size, VAT id.
- **Trust signals near the submit button**, particularly for payment: accepted methods, security marks, and the refund or cancellation policy.

Instrument **field-level abandonment**. It tells you exactly which question loses people, which no aggregate conversion rate will.

---

## 5. Testing and observation methods

| Method | Answers | Cost |
|--------|---------|------|
| **A/B test** | Which variant performs better | Needs traffic (`experiment-design`) |
| **Session recordings** | Where people struggle, rage-click, or abandon | Low; sample rather than watch everything |
| **Heatmaps and scroll maps** | What is seen and what is never reached | Low |
| **Funnel analytics** | Which step leaks | Low |
| **Moderated usability test (5 users)** | *Why* it fails | Low; the highest insight per euro |
| **Unmoderated remote test** | How many struggle at a step | Medium |
| **Field-level form analytics** | Which question causes abandonment | Low |
| **Support and sales logs** | Real objections in customers' words | Free |

The productive pairing: **quantitative to find where, qualitative to find why.** Analytics tell you 61% abandon at step two; five moderated sessions tell you it is because the plan differences are unclear. Neither alone produces the fix.

For usability sessions, give people a realistic goal in their own words — never instructions naming the interface. Watch; do not rescue at the first hesitation.

---

## 6. Calls to action and copy

- **Specific beats generic**: a CTA describing the outcome ("Create my first report") outperforms "Submit" or "Continue".
- **First person often wins**, but test it rather than assuming.
- **Reduce perceived commitment** where it is honest to do so — "no card required" if true. Never if it is not.
- **One primary CTA per screen**, with secondary actions visually subordinate.
- **Contextual CTAs** matched to intent: a comparison-page visitor wants a demo or a trial, not a newsletter.
- **Write for the objection**, not the feature. The microcopy next to the button — cancellation terms, data handling, what happens next — often moves conversion more than the button itself.

---

## 7. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Assuming the aha moment instead of finding it | Onboarding optimised toward a number that causes nothing |
| Correlated activation metric never validated causally | A metric that rises while retention does not |
| Long onboarding before any value | Users leave before understanding the product |
| Asking for everything at signup | Each field costs conversion, most could wait |
| Empty state with a product tour | A tour of nothing; users leave |
| Ad promise not matched by the landing page | High click-through, high bounce, wasted spend |
| Multiple competing CTAs | Lower total conversion |
| Testing button colours before offer and structure | Trivial wins while the real levers go untouched |
| Form cleared on validation error | Guaranteed abandonment |
| No field-level form analytics | The losing question stays invisible |
| Only quantitative or only qualitative | You know where but not why, or why but not how much |
| "No card required" when a card is required | Trust destroyed at the worst moment |
| Ignoring page speed in conversion tests | A "winning" variant that is slower and loses money |

---

## 8. Checklist

- [ ] Activation event derived from retained-versus-churned cohort analysis
- [ ] Threshold behaviour tested, not just occurrence
- [ ] Causal validation run before adopting the activation metric
- [ ] Median and p90 time to value measured and tracked
- [ ] Every pre-value step justified; the rest removed or deferred
- [ ] Empty state solved with templates, import, or sample data
- [ ] Message match verified between each channel and its landing page
- [ ] One primary CTA per screen, with proof and objection handling near the action
- [ ] Page speed included as a guardrail in conversion tests
- [ ] Mobile experience tested first, not last
- [ ] Form fields justified individually; sensitive questions explained
- [ ] Inline validation that never clears entered data
- [ ] Field-level abandonment instrumented
- [ ] Quantitative analysis paired with five moderated sessions for the "why"
- [ ] Big levers (offer, promise, structure, form length, price presentation) tested before cosmetics
