---
description: Prototypes, wireframes, and mockups as UI requirements — choosing fidelity, paper and clickable prototypes, Wizard of Oz and concierge approaches, fake-door tests, what a prototype must specify beyond the happy path (empty, loading, error, edge-case states), annotation for handover, and Markdown templates for a prototype brief, a state inventory, and a UI specification.
---

# Prototypes, wireframes, and mockups

Goal of this skill: specify user-facing behaviour with something people can **look at and use**, because a picture settles in ten seconds what three paragraphs argue about for a week — and get feedback before the expensive build.

Use this skill for any user-facing requirement, to resolve a layout or flow disagreement, to test a risky assumption cheaply, to give a supplier an unambiguous UI specification, or to measure demand before building (`fake door`).

Do **not** treat a prototype as a complete specification on its own. It shows the happy path beautifully and stays silent about errors, permissions, empty states, and data limits — which is where the work actually is. Pair it with the state inventory below.

---

## 1. Choosing fidelity

Fidelity is a cost decision, not a quality ladder. Match it to the question.

| Artifact | Cost | Answers | Fails at |
|----------|------|---------|----------|
| **Sketch / paper** | minutes | Is the flow right? Which concept do people prefer? | Visual credibility, fine interaction |
| **Wireframe** | hours | What information and controls belong on this screen, in what hierarchy? | Aesthetics, micro-interaction |
| **Clickable low-fi prototype** | hours–days | Can people find and complete the task? | Perceived polish |
| **High-fidelity mockup** | days | Does it look right and match the design system? | Behaviour under real data |
| **Interactive high-fi prototype** | days | Does the interaction feel right? Do transitions read correctly? | Performance, real data volume |
| **Wizard of Oz** | days | Do people want the outcome, when a human fakes the machine? | Scale economics |
| **Concierge** | days–weeks | What does the real process need? | Automation feasibility |
| **Fake door / painted door** | hours | Is there demand at all? | Anything about the experience itself |
| **Coded prototype in the real stack** | weeks | Is it technically feasible? Does it perform? | Being thrown away — it rarely is |

**Rule: the lower the fidelity, the more honest the feedback.** People critique a sketch and politely admire a polished mockup. Use low fidelity while you still want to hear that the idea is wrong.

**Fake doors have an ethics cost.** Measure demand this way only with an honest follow-through ("not available yet — want to be notified?"), never by taking money or data for something that does not exist.

---

## 2. Intake — ask before making anything

Ask only what is missing; batch into one message, five or fewer.

1. **What question must this answer?** One sentence. ("Will agents understand the two-step approval?" not "design the approval screen".)
2. **Who will see it** — real users, stakeholders, or a supplier? That decides fidelity and annotation depth.
3. **What is already fixed** — design system, platform, accessibility level, brand constraints, existing patterns?
4. **What data will it show** — realistic content, real volumes, worst-case lengths and languages?
5. **What happens after** — usability test, stakeholder sign-off, handover to build, or a demand measurement?

If the answer to (1) is "we need designs", push back once: a prototype with no question is decoration and will be argued about on taste.

---

## 3. What a prototype must cover to serve as a requirement

The happy path is the easy 20 %. Specify these explicitly, per screen:

| State | Question |
|-------|----------|
| **Empty** | First use, no data yet — what does the user see and do? |
| **Loading** | Skeleton, spinner, optimistic? What if it takes 10 s? |
| **Partial** | Some data arrived, some failed |
| **Error** | Validation, permission denied, server error, offline — with the exact message text |
| **Success / confirmation** | What confirms the action, and for how long? |
| **Maximum** | Longest name, 500 rows, 20 line items, longest translated string |
| **Minimum** | One item, smallest viewport |
| **Permissions** | What each role sees and cannot see |
| **Disabled / blocked** | Why an action is unavailable, and how the user resolves it |
| **Destructive** | Confirmation, undo window, consequences stated |

Also specify: keyboard order and focus behaviour, screen-reader labels for non-text controls, responsive breakpoints, and the copy — **microcopy is a requirement**, not a placeholder. `Lorem ipsum` in a handover artifact guarantees a content emergency later.

---

## 4. Annotating for handover

A prototype handed to developers needs annotation that the pixels cannot carry:

| Annotate | Example |
|----------|---------|
| Data source and field | "shows `booking.refundAmount`, minor units, formatted in the user's locale" |
| Validation rules | "date must be ≥ today; error text as specified in the error table" |
| Behaviour on action | "POST cancellation; optimistic state change; roll back and show error on 4xx" |
| Conditional visibility | "fee row shown only when departure < 24 h" |
| Timing | "toast for 4 s; auto-dismiss; announced to screen readers politely" |
| Non-obvious interaction | "list is virtualised above 200 rows" |
| What is out of scope | "printing not in this release" |

Link every annotated screen to the story or requirement it satisfies, and vice versa (`traceability`).

---

## 5. Output templates

### 5.1 Prototype brief

````markdown
# Prototype brief — <name>

- **Question it answers**: <one sentence>
- **Fidelity**: paper | wireframe | clickable low-fi | high-fi | Wizard of Oz | fake door
- **Audience**: <real users / stakeholders / supplier> · **Made by**: <name> · **Date**: <date>
- **Scope**: screens/flows included: <…> · explicitly excluded: <…>
- **Data**: realistic content, worst-case lengths, <locale(s)>
- **Fixed constraints**: design system <name> v<x>, WCAG 2.2 AA, mobile-first
- **Next step**: usability test <link> | sign-off | handover to STORY-xxx
- **Artifact**: <link to Figma / file / deployed prototype>
- **Throwaway or evolving?**: throwaway — not to be reused as production code
````

### 5.2 State inventory (per screen)

````markdown
# Screen — <Cancellation confirmation>

| State | Trigger | What the user sees | Copy | Actions available | Notes |
|-------|---------|--------------------|------|-------------------|-------|
| Default | booking cancellable | refund + fee breakdown | "You'll get €80.00 back" | Confirm, Back | fee row hidden if fee = 0 |
| Loading | after Confirm | button spinner, controls disabled | — | none | timeout 10 s → error state |
| Success | 202 accepted | confirmation panel + reference | "Cancelled. Refund on its way." | Done, View booking | toast announced politely |
| Error — outside window | 422 | inline explanation + rebooking link | "This booking can no longer be cancelled online. …" | Contact support, Rebook | never a raw error code |
| Error — provider down | 503 | banner, action preserved | "We couldn't reach our payment partner. Your booking is unchanged." | Retry, Back | retriable |
| Empty | no cancellable bookings | empty state illustration + guidance | "You have no bookings to cancel." | Browse trips | |
| Max data | 12 passengers, long names | list scrolls; names truncate with tooltip | — | — | verify at 320 px width |
| Permissions — agent | agent acting for a customer | reason field required | — | Confirm | audit note captured |

## Accessibility

| Requirement | Detail |
|-------------|--------|
| Keyboard | full flow operable; focus moves to the confirmation panel on success |
| Screen reader | fee breakdown read as a table; status announced via a live region |
| Contrast | all text ≥ 4.5:1; the fee warning is not colour-only |
| Target size | primary actions ≥ 44 × 44 px |

## Annotations for build

| Element | Data / behaviour |
|---------|------------------|
| Refund amount | `cancellation.refundAmount`, minor units, locale-formatted |
| Confirm | `POST /bookings/{id}/cancellation` with `Idempotency-Key` |

## Traces to

STORY-201, UC-12 (main flow + extensions 2a, 7a), QA-9 (WCAG 2.2 AA)
````

---

## 6. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Prototype with no question | Endless taste debates | One question per prototype, written down |
| High fidelity too early | Polite feedback; sunk-cost attachment to a wrong idea | Low fidelity while the concept is still open |
| Lorem ipsum and perfect fake data | Layout breaks on real names, long strings, and empty states | Realistic and worst-case content |
| Only the happy path | The 80 % of real work is unspecified | State inventory per screen |
| Prototype as the only specification | Rules, permissions, and errors go undocumented | Prototype + stories + criteria |
| Coded prototype quietly becoming production | Prototype shortcuts become permanent | Declare throwaway; enforce it |
| Stakeholder demo mistaken for user validation | Approval without evidence | Test with real users (`usability-testing`) |
| Accessibility left "for later" | Rebuild, or a legal problem | Keyboard, contrast, and semantics from the wireframe on |
| Fake door with no honest follow-through | Damaged trust | Always tell people it is not available yet |
| Prototype not versioned or dated | Teams build from an outdated screen | Version, date, and link from the story |

---

## 7. Checklist

- [ ] The question the prototype answers is written down
- [ ] Fidelity matched to the question and the audience
- [ ] Realistic content, worst-case lengths, and target locales used
- [ ] Empty, loading, partial, error, success, min, max, and permission states covered
- [ ] Exact microcopy specified, including every error message
- [ ] Keyboard order, focus behaviour, and screen-reader semantics specified
- [ ] Responsive behaviour at the smallest supported viewport verified
- [ ] Destructive actions have confirmation and stated consequences
- [ ] Annotations cover data sources, validation, timing, and conditional visibility
- [ ] Out-of-scope items stated on the artifact
- [ ] Throwaway status declared for coded prototypes
- [ ] Linked to the stories and requirements it specifies, both ways
- [ ] Validated with real users, not only with stakeholders
- [ ] Versioned and dated
