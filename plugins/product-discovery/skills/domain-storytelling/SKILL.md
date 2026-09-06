---
description: Domain Storytelling (Hofer/Schwentner) — record concrete work scenarios as pictographic sentences of actors, work objects, and numbered activities. Covers scope selection (AS-IS/TO-BE, coarse/fine, pure/digitalised), the recording session script, notation rules, glossary harvesting, and a Markdown template for stories, sentence lists, and derived requirements.
---

# Domain Storytelling

Goal of this skill: get a domain expert to tell one **concrete** story of how work really happens, recorded live as a picture that they can correct in real time — and harvest ubiquitous language, process understanding, and requirements from it.

Use this skill when you need to understand a process, build shared vocabulary, onboard into an unfamiliar domain, compare AS-IS with TO-BE, or when Event Storming produced a flow that nobody can narrate concretely.

Do **not** use it to model an entire business at once (use `event-storming` Big Picture) or to specify acceptance criteria for one story (use `example-mapping`).

---

## 1. Why it works

A story is one **concrete** run through the process — with real names, real documents, one specific case — not an abstract "the system shall". Concreteness makes disagreement visible immediately: a domain expert cannot object to a UML box, but will instantly object to "no, Anna sends the *signed* form, not the draft".

---

## 2. Scope the story on four axes

Decide all four before recording. Say them out loud at the start of the session.

| Axis | Options | How to choose |
|------|---------|---------------|
| **Time** | AS-IS (how it works today) / TO-BE (how it should work) | Model AS-IS first unless the process does not exist yet |
| **Domain purity** | Pure (business only) / Digitalised (systems named as actors) | Pure for understanding; digitalised for integration and system design |
| **Granularity** | Coarse-grained (overview) / Fine-grained (every step) | Coarse to map the landscape, fine for the flow you will build |
| **Scope** | Happy path / variant / exception | Record the happy path first, then the variants that matter |

Give each story a name that states the case: *"Anna books a same-day delivery"*, not *"Delivery process"*.

---

## 3. Intake — ask before recording

Ask only what the conversation has not answered; batch into one message, five or fewer.

1. **Which process**, and which concrete case should we walk through? (a real, recent example — ideally one that happened last week)
2. **Who tells it?** Which domain expert actually does this work? Who else must be in the room?
3. **AS-IS or TO-BE**, and pure or digitalised?
4. **Where does the story start and stop?** (first trigger, final outcome)
5. **What is this for** — onboarding, a service redesign, a system replacement, an integration?

If the user offers an abstract process description instead of a case, push once: *"Give me the last time this actually happened — names, dates, documents."*

---

## 4. Notation

Three shapes and numbered arrows. That is the whole language.

| Element | Drawn as | Example |
|---------|----------|---------|
| **Actor** | pictogram of a person, group, or system | `Dispatcher`, `Customer`, `ERP` |
| **Work object** | pictogram of a document, message, or thing | `delivery note`, `invoice`, `email` |
| **Activity** | numbered, labelled arrow between them | `1. sends` |

Every step reads as one sentence: **`<actor>` `<activity>` `<work object>` [to `<actor>`]**.

Rules:

- Number every activity — the numbers *are* the sequence.
- Use the domain's own verbs (`approves`, `books`, `rejects`), never `does`, `handles`, `processes`, or `manages`.
- One sentence per arrow; if you need "and", it is two steps.
- No branching in a story. Alternatives become their own story.
- No loops. If work repeats, either say it once or record a separate story.
- Annotations (free text notes) hold constraints, timings, pain, and rules that are not steps.

---

## 5. Session script (60–90 min per story)

**Roles**: one **narrator** (domain expert), one **modeller** (draws live, visible to all), one **moderator** (asks, keeps scope), listeners (ask at the end of a pass).

1. **Frame** (5 min) — state the four scope axes and the concrete case aloud.
2. **First pass** (20–30 min) — narrator tells the story; modeller draws each sentence as it is told. Do not stop for polish.
3. **Replay** (10 min) — modeller reads the picture back, sentence by sentence: *"1. Anna sends the order form to Dispatch. 2. Dispatch checks…"*. The narrator corrects. This step catches most errors.
4. **Annotate** (10–15 min) — add rules, timings, volumes, pain points, and system names as annotations. Mark pain points visibly.
5. **Harvest language** (10 min) — list every noun and verb used, agree the definition, and note synonyms that were rejected.
6. **Variants** (10 min) — list the variants and exceptions that matter; decide which get their own session.
7. **Close** (5 min) — what is unclear, who answers it, what is the next story.

Record 3–5 stories per process: one happy path, the two most frequent variants, and the most painful exception.

---

## 6. From story to requirements

| In the picture | Yields |
|----------------|--------|
| Actor | role, permission, persona candidate |
| Work object | entity, document, aggregate candidate |
| Activity | use case, command, user story |
| Annotation with a rule | business rule, acceptance criterion |
| Annotation with pain | improvement opportunity for the TO-BE story |
| System as actor | integration point, API requirement |
| Handover between actors | queue, notification, SLA, failure mode |
| Story boundary | bounded context candidate |

To design the TO-BE: copy the AS-IS story, remove or merge steps, and mark exactly what changed. Keeping both side by side is the argument for the change.

---

## 7. Output template

Write to `docs/discovery/domain-story-<slug>.md`.

````markdown
# Domain Story — <Story name, e.g. "Anna books a same-day delivery">

- **Date**: <YYYY-MM-DD>
- **Narrator**: <name (role)>
- **Modeller / moderator**: <names>
- **Scope**: AS-IS | TO-BE · pure | digitalised · coarse | fine · happy path | variant | exception
- **Starts with**: <trigger> — **Ends with**: <outcome>
- **Picture**: <link to diagram / Egon.io / Miro>

## 1. Sentences

| # | Actor | Activity | Work object | To | Note |
|---|-------|----------|-------------|----|------|
| 1 | Customer | places | order | Shop | via web form |
| 2 | Shop | sends | order confirmation | Customer | within 2 min (SLA) |

## 2. Actors

| Actor | Human / system / group | Responsibility in this story |
|-------|------------------------|------------------------------|
| Dispatcher | human | assigns orders to drivers |

## 3. Work objects

| Work object | Physical / digital | Created in step | Consumed in step |
|-------------|--------------------|-----------------|------------------|
| Delivery note | digital PDF | 4 | 7 |

## 4. Annotations — rules, timings, volumes

| Refers to step | Type | Detail |
|----------------|------|--------|
| 2 | SLA | confirmation within 2 minutes |
| 5 | rule | orders over €500 need a supervisor approval |
| 6 | volume | ~300/day, peaks Monday morning |

## 5. Pain points

| Step | Pain | Frequency | Impact | Idea |
|------|------|-----------|--------|------|
| 5 | approval by phone, often unreachable | daily | 2 h delay | in-app approval |

## 6. Variants and exceptions (not modelled here)

| Variant | Frequency | Modelled in |
|---------|-----------|-------------|
| Customer cancels after dispatch | ~3 %/week | `domain-story-cancel-after-dispatch.md` |

## 7. Glossary harvested

| Term | Definition | Rejected synonyms |
|------|------------|-------------------|
| Delivery note | Document accompanying goods, generated at dispatch | "shipping slip", "docket" |

## 8. Derived requirements and open questions

| # | Derived from step | Requirement / question | Type | Owner |
|---|-------------------|------------------------|------|-------|
| R1 | 5 | Supervisor can approve an order in the app | user story | <name> |
| Q1 | 7 | What happens if the driver rejects the assignment? | open question | <name> |

## 9. Next steps

- Next story to record: …
- Method to follow with: <Example Mapping for R1 / Event Storming Process level / TO-BE story>
````

---

## 8. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| Abstract narration ("normally the system processes…") | Nobody can spot errors | Insist on one concrete, recent case with names |
| Branches and loops in one picture | Turns into a flowchart nobody reads | One story per path |
| Modeller "improving" the words | Language stops being the domain's | Write exactly what the narrator said |
| Skipping the replay | Errors survive into the documentation | Always read the picture back aloud |
| Only IT in the room | You model your assumptions | The narrator must be someone who does the work |
| Recording ten stories before reflecting | Diminishing returns, exhausted expert | 3–5 stories, then harvest |
| Verbs like "handles" or "manages" | Hides the actual work | Use the specific domain verb |
| Modelling TO-BE before AS-IS | No baseline, no argument for change | AS-IS first, then diff |

---

## 9. Checklist

- [ ] Story named after a concrete case, not a process
- [ ] Four scope axes stated aloud before recording
- [ ] Drawing visible to everyone while it is made
- [ ] Every activity numbered and phrased with a domain verb
- [ ] No branches or loops in a single story
- [ ] Picture replayed aloud and corrected by the narrator
- [ ] Rules, timings, volumes captured as annotations
- [ ] Pain points marked
- [ ] Glossary harvested with rejected synonyms
- [ ] Variants listed, next story chosen
- [ ] Requirements and open questions extracted with owners
