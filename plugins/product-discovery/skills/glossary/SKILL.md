---
description: Glossary and ubiquitous language — build and maintain the shared vocabulary of a bounded context. Covers what qualifies as a term, definition rules, homonyms and synonyms across contexts, harvesting from workshops and code, enforcing the language in code and tests, ownership and review cadence, tooling, and Markdown templates for a per-context glossary and a cross-context translation table.
---

# Glossary and ubiquitous language

Goal of this skill: make one word mean exactly one thing inside a bounded context — in conversation, in the requirements, in the code, and in the tests — and make the differences **between** contexts explicit instead of accidental.

Use this skill from the first workshop onwards. It is the cheapest artifact in discovery and the one most often skipped; the cost of skipping it is paid every time two people implement different meanings of "order", "customer", or "cancelled".

Do **not** build one enterprise-wide glossary that tries to give every term a single meaning. That project never finishes. Build one glossary per bounded context and a translation table between them (`context-mapping`).

---

## 1. Ubiquitous language is not documentation

The language is only ubiquitous if it appears everywhere:

| Place | Test |
|-------|------|
| Conversation | The domain expert and the developer use the same word for the same thing |
| Requirements and stories | No term appears that is not in the glossary |
| Class, function, and table names | The code reads like the domain, not like a translation of it |
| API contracts and events | `BookingCancelled`, not `updateStatus(3)` |
| Test names and scenarios | `gherkin-bdd` scenarios use only glossary terms |
| Error messages and UI copy | Users see the same words the team uses |

A glossary that documents a vocabulary nobody uses in code is a dictionary of a dead language. The point is enforcement, not archival.

---

## 2. What belongs in the glossary

| Include | Exclude |
|---------|---------|
| Domain nouns that carry rules (`Booking`, `Fare`, `Claim`) | General English (`user`, `list`, `report`) unless it has a special meaning here |
| Domain verbs and events (`confirm`, `settle`, `Booking Cancelled`) | Technology terms (`cache`, `queue`) unless they are domain concepts |
| Statuses and lifecycle states | Internal implementation names |
| Roles and actors (`Dispatcher`, `Assessor`) | Team names |
| Abbreviations and codes used by the business (`IRREG`, `EU261`, `PNR`) | Terms nobody has used in a real conversation |
| Terms that mean something different elsewhere (homonyms) | |
| Terms that were **rejected**, with the reason | |

The rejected-synonyms column is what stops the same argument from recurring every quarter.

---

## 3. Rules for a definition

- **One sentence, in the domain's words**, saying what the thing *is* — not what the system does with it.
- **No circular definitions.** "A booking is a booked trip" defines nothing.
- **State the identity**: what identifies an instance, and when it comes into existence.
- **State the boundaries**: what is *not* included. Most disputes live here.
- **Give one concrete example** — a real booking reference, a real claim.
- **Name the owner**: the person who decides what it means.
- **Record homonyms** — where the same word means something else, and what the translation is.
- **Record rejected synonyms** and why they were rejected.
- **Do not define terms nobody uses.** A glossary with 400 entries is not consulted.

---

## 4. Harvesting and enforcing

**Harvest from:**

| Source | Method |
|--------|--------|
| Workshops | `event-storming` naming disputes, `domain-storytelling` verbs and work objects |
| Interviews | Terms the expert uses that the team does not, and vice versa |
| Documents and regulation | `document-system-analysis` — legal terms are non-negotiable definitions |
| Code and schema | Existing class, table, and enum names — and the mismatches with what people say |
| Support tickets and UI copy | The words customers actually use |

**Enforce by:**

| Practice | Effect |
|----------|--------|
| Renaming in code when the language changes | The glossary and the code stay one artifact |
| Reviewing new terms in refinement | Prevents synonym drift at the source |
| Linting or spell-check dictionaries built from the glossary | Cheap automated nudge in docs and PRs |
| Rejecting stories that introduce undefined terms | Definition of Ready gate |
| Reading scenarios aloud in `three-amigos` | Wrong words sound wrong when spoken |
| A visible, single location — not five wiki pages | Findability decides adoption |

**A change in the language is a change in the model.** When a term is redefined, check what it breaks: code, events, contracts, reports, and the requirements that used the old meaning.

---

## 5. Output templates

Write to `docs/discovery/glossary-<context>.md`.

````markdown
# Glossary — <Ordering context>

- **Bounded context**: Ordering · **Owner**: <name (role)> · **Last reviewed**: <YYYY-MM-DD>
- **Review cadence**: at each refinement; full pass every quarter
- **Rule**: no requirement, story, scenario, or class name may use a term that is not defined here.

## Terms

### Order

- **Definition**: A customer's confirmed intent to purchase one or more items, containing at least one order line.
- **Identity**: `orderNumber`, assigned when the order is placed.
- **Comes into existence**: when the customer confirms the basket and payment is authorised.
- **Not included**: an unconfirmed basket (see *Basket*); a warehouse picking job (see *Fulfilment context*).
- **Example**: `ORD-2026-004821`, 3 lines, €248.50.
- **Owner**: <name>
- **Homonym**: in the Fulfilment context, "order" means the picking job — translated as `OrderConfirmed → PickingJob`.
- **Rejected synonyms**: "booking" (used in a different product line), "job" (means the warehouse task).
- **Used in**: `state-machine-order.md`, `data-model-ordering.md`, `Order` aggregate, `OrderPlaced` event.

### Basket

- **Definition**: A mutable collection of items a customer has selected but not yet confirmed.
- **Identity**: session-scoped `basketId`; not persisted after 30 days of inactivity.
- **Not included**: any reservation of stock.
- **Rejected synonyms**: "cart" (used only in UI copy for the US market — see UI style guide).

## Abbreviations

| Abbreviation | Expansion | Meaning here |
|--------------|-----------|--------------|
| PNR | Passenger Name Record | The carrier's booking reference; not our `orderNumber` |

## Terms deliberately not defined

| Term | Why | Use instead |
|------|-----|-------------|
| "Ticket" | Means a support ticket, a travel document, or a Jira issue depending on who speaks | Say `travel document`, `support case`, or `issue` |

## Change log

| Date | Term | Change | Reason | Impact checked |
|------|------|--------|--------|----------------|
| <date> | Order | narrowed to exclude unpaid baskets | ambiguity found in `event-storming` | renamed `Order` → `Basket` in checkout module; event schema v3 |
````

### Cross-context translation table

````markdown
# Language translation across contexts

| Term | Ordering | Fulfilment | Billing | Translation rule |
|------|----------|------------|---------|------------------|
| Order | confirmed purchase intent | picking job in the warehouse | invoice line group | `OrderConfirmed` creates a `PickingJob` only for paid orders |
| Customer | the person who placed the order | the delivery recipient | the legal invoice party | may be three different people; mapped in the ACL |
| Cancelled | customer withdrew before dispatch | picking stopped | credit note issued | not the same event; see `context-map.md` rel. 1 and 4 |
````

---

## 6. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| One enterprise glossary for everything | Endless negotiation; nobody's meaning fits | One per bounded context + translation table |
| Glossary written by one analyst alone | It reflects one person's model | Harvest from workshops with domain experts |
| Terms defined but not used in code | Two vocabularies to maintain, drift guaranteed | Rename in code when the language changes |
| Circular or system-centric definitions | Explains nothing | Say what the thing is in the business |
| No "not included" clause | The real disagreement stays hidden | Always state the boundary |
| 400 entries, most never used | Nobody consults it | Only terms that carry rules or cause confusion |
| No owner per term | Disputes have no resolution path | Name the decider |
| Homonyms silently tolerated | Integration bugs with confident-looking code | Record the homonym and the translation |
| Glossary in a wiki nobody links to | Invisible, therefore unused | One location, linked from every spec and the repo README |
| Term redefined without impact analysis | Old meaning survives in code and contracts | Change log with an impact check |

---

## 7. Checklist

- [ ] One glossary per bounded context; a translation table between contexts
- [ ] Only terms that carry rules or cause confusion are included
- [ ] Each definition is one sentence in the domain's language, non-circular
- [ ] Identity and creation moment stated per entity term
- [ ] "Not included" boundary stated for every contested term
- [ ] One concrete example per term
- [ ] Owner named per term
- [ ] Homonyms recorded with the translation rule
- [ ] Rejected synonyms recorded with the reason
- [ ] Terms cross-referenced to the models, code, and events that use them
- [ ] Abbreviations and business codes expanded
- [ ] Language enforced in stories, scenarios, code, contracts, and UI copy
- [ ] Change log kept, with an impact check per redefinition
- [ ] Review cadence agreed and a single findable location chosen
