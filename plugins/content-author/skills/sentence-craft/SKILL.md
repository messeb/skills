---
description: The sentence-level moves that actually make text readable — one idea per sentence, active voice and naming the actor, verbs instead of nominalisations, concrete over abstract words, cutting filler and hedges, managing sentence rhythm and length variation, keeping connectives that carry logic, terminology consistency, and the difference between simplifying and deleting meaning.
---

# Sentence craft

Goal of this skill: the concrete edits that raise comprehension — the operations you perform after a readability score tells you a passage is heavy.

Use this skill when rewriting a draft, editing someone else's text, or turning a specification into something people will read.

Readability indices measure sentence length and word length (`readability`). This skill is what you actually change; the score moves as a consequence.

---

## 1. One idea per sentence

The dominant cause of unreadable text is not long words. It is sentences carrying three ideas, two conditions, and an aside.

> **Before** — After the applicant has submitted the form, which must be complete and signed, the office will check the details and, provided that no further documents are required, issue the decision within four weeks, whereby the period begins on receipt.
>
> **After** — Submit the completed and signed form. The office then checks your details. If no further documents are needed, you receive the decision within four weeks. The four weeks start when the office receives your form.

What changed: four ideas separated into four sentences; the actor named in each; the condition given its own sentence; the definition of the deadline made explicit.

The test: read the sentence and count the assertions. More than one, and it is a candidate to split — not automatically wrong, but a candidate.

---

## 2. Active voice, and naming the actor

Passive voice hides who does what. In instructions and legal text, that ambiguity is the actual problem.

| Passive | Active |
|---------|--------|
| The application will be reviewed. | We review your application. |
| It has been decided that … | The committee decided that … |
| Der Antrag wird geprüft. | Wir prüfen Ihren Antrag. |
| Es wird empfohlen, … | Wir empfehlen Ihnen, … |

Passive is legitimate when the actor is genuinely unknown (`the file was corrupted`), irrelevant (`the results were published in 1998`), or when the object is the topic of the paragraph. Use it deliberately, not by default.

The diagnostic question for any passive sentence: **can the reader tell who is responsible?** If not, and it matters, rewrite it.

---

## 3. Verbs, not nominalisations

Turning a verb into a noun (`prüfen` → `die Prüfung`, `decide` → `make a determination`) adds length and removes the actor. This is the single highest-yield edit in bureaucratic and corporate text.

| Nominal | Verbal |
|---------|--------|
| perform an evaluation of | evaluate |
| provide assistance to | help |
| make a decision about | decide |
| bring about an improvement in | improve |
| zur Anwendung kommen | anwenden |
| eine Überprüfung durchführen | überprüfen |
| die Inbetriebnahme erfolgt | wir nehmen … in Betrieb |

Spot them by their endings — `-ung`, `-heit`, `-keit`, `-tion`, `-ment`, `-ance` — and by the weak verbs they attach to: `erfolgen`, `durchführen`, `vornehmen`, `perform`, `conduct`, `provide`, `undertake`.

---

## 4. Concrete over abstract

Abstract words are processed more slowly and remembered less well.

| Abstract | Concrete |
|----------|----------|
| resources | people, money, time — say which |
| the solution | the export function |
| Maßnahmen ergreifen | die Frist verlängern |
| optimise the customer journey | reduce checkout from five steps to two |

The same applies to quantities: `significantly faster` is unverifiable; `1.2 seconds instead of 4` is a fact. Replace every evaluative adjective you can with the number that justified it.

---

## 5. Cut what carries nothing

| Category | Examples |
|----------|----------|
| Empty openers | `It should be noted that`, `Es sei darauf hingewiesen, dass`, `Basically`, `Grundsätzlich gilt` |
| Redundant pairs | `each and every`, `null und nichtig`, `first and foremost` |
| Filler intensifiers | `very`, `really`, `quite`, `sehr`, `durchaus`, `letztendlich` |
| Hedges stacked | `it may perhaps be possible that` |
| Throat-clearing | A first paragraph explaining what the document will explain |
| Restating the heading | The first sentence repeating the heading in prose |

Two cautions. **Hedges are not always filler**: in scientific or legal writing, `may` and `typically` carry real meaning, and deleting them makes the text wrong. Cut *stacked* hedges, keep the one that is true. And **cutting is not the same as simplifying** — remove words that carry nothing, never conditions, exceptions, or qualifications that carry meaning.

---

## 6. Rhythm and length variation

Uniformly short sentences read as staccato and, oddly, become harder to follow, because the reader must reconstruct the relationships the sentences no longer express.

Aim for a **shorter average with real variation**: mostly short and medium sentences, an occasional longer one that genuinely holds a complex relation, and a short one after it to land the point.

A practical measure: if your longest sentence is over about 30 words, check it carries one idea. If most sentences are under 8 words, check that connectives have not been stripped out.

---

## 7. Keep the connectives

The most damaging way to raise a readability score is deleting the words that carry logic: `because`, `therefore`, `however`, `although`, `weil`, `deshalb`, `jedoch`, `obwohl`.

> **Score-optimised** — The server was overloaded. We rejected requests. Users saw errors.
>
> **Coherent** — The server was overloaded, so we rejected new requests. As a result, users saw errors.

The second is longer, scores worse, and is easier to understand — because it states the causal chain instead of leaving the reader to infer it. Where a connective states a real relation, keep it.

---

## 8. Terminology consistency

Vary sentence structure for rhythm. **Never vary terminology for elegance.**

Using `user`, `customer`, `account holder`, and `client` for the same entity forces the reader to work out whether the distinctions are meaningful. In German this is compounded by the temptation to use synonyms to avoid repetition — a stylistic habit from essay writing that is actively harmful in technical and legal text.

Maintain a short term list per product: the term, its definition, and what not to use instead. One term, one meaning; one meaning, one term.

---

## 9. Words: familiar over impressive

| Instead of | Use |
|-----------|-----|
| utilise, commence, terminate, endeavour | use, start, end, try |
| in the event that, prior to, subsequent to | if, before, after |
| beinhalten, gewährleisten, seitens | enthalten, sichern, von |
| aufgrund der Tatsache, dass | weil |
| erforderlich machen | brauchen, müssen |

Keep the technical term where it is the correct one — but introduce it once in plain words. `Idempotenz` in an API document is right; using it without a one-line explanation on a page aimed at newcomers is not.

Loanwords and anglicisms in German deserve a deliberate decision: `downloaden` is widely understood, `Deployment-Pipeline` may not be outside engineering. Decide per audience and record it in the style guide.

---

## 10. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Splitting sentences mechanically at commas | Fragments; relations lost |
| Deleting connectives to shorten sentences | Score rises, comprehension falls |
| Passive by default | Nobody knows who acts; responsibility hidden |
| Nominal style throughout | Long, actorless, heavy |
| Abstractions where a concrete noun exists | Reader cannot picture anything |
| Evaluative adjectives instead of numbers | Unverifiable claims |
| Cutting conditions and exceptions as "filler" | Meaning changed; in regulated text, a defect |
| Removing every hedge | Statements become false |
| Synonym variation for the same concept | Reader infers distinctions that do not exist |
| Uniformly short sentences | Staccato, patronising, harder to follow |
| Technical term used without one plain introduction | Newcomers stall on the first paragraph |
| Rewriting for the score rather than the reader | Text that measures well and communicates badly |

---

## 11. Checklist

- [ ] Each sentence carries one main idea; multi-assertion sentences reviewed
- [ ] Conditions and exceptions given their own sentences
- [ ] Actor named wherever responsibility matters; passive used deliberately
- [ ] Nominalisations converted to verbs, especially with `erfolgen`, `durchführen`, `provide`, `conduct`
- [ ] Abstract nouns replaced with concrete ones where possible
- [ ] Evaluative adjectives replaced with the numbers behind them
- [ ] Empty openers, redundant pairs, and stacked hedges cut
- [ ] Meaning-bearing hedges, conditions, and qualifications kept
- [ ] Connectives that state real relations preserved
- [ ] Sentence length varied around a shorter average
- [ ] One term per concept, consistently; term list maintained
- [ ] Familiar words preferred; technical terms introduced once in plain words
- [ ] Anglicism policy decided per audience
- [ ] Text re-measured after rewriting, not written to the measure
