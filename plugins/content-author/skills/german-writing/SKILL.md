---
description: German-specific readability problems and their fixes — Schachtelsätze and the verb bracket, Nominalstil and Funktionsverbgefüge, overuse of passive and impersonal constructions, Behördendeutsch and its standard replacements, long compounds and when to split or hyphenate, genitive chains, Sie/du and gendering conventions, anglicisms, and the German-specific measurement notes.
---

# German writing

Goal of this skill: fix the constructions that make German text hard — most of which have no direct English equivalent, and none of which an English-language style guide will catch.

Use this skill when writing or editing German content, when localising English source text, or when German text scores badly and you need to know what to change.

---

## 1. Schachtelsätze and the verb bracket

German's *Satzklammer* places part of the verb at the end of the clause. The further apart the two halves sit, the more the reader must hold in memory.

> **Heavy** — Der Antrag, der von der zuständigen Behörde nach Eingang aller erforderlichen Unterlagen und nach Abschluss der internen Prüfung, die in der Regel vier Wochen dauert, bearbeitet wird, kann online eingereicht werden.
>
> **Fixed** — Sie können den Antrag online einreichen. Die Behörde bearbeitet ihn, sobald alle Unterlagen vorliegen. Die interne Prüfung dauert in der Regel vier Wochen.

Rules that work in practice: **keep the verb bracket short** — ideally fewer than about eight words between the two verb parts; **avoid inserting a relative clause inside the bracket**, which is the specific construction that makes German bureaucratic prose notorious; and **one subordinate clause per sentence at most**, none at all in Einfache Sprache (`plain-language`).

Diagnostic: read the sentence aloud. If you have to look back to find the verb, split it.

---

## 2. Nominalstil and Funktionsverbgefüge

The most characteristic problem of German professional writing: turning actions into nouns and attaching a weak verb.

| Nominalstil | Verbal |
|-------------|--------|
| zur Anwendung kommen | anwenden |
| eine Überprüfung durchführen | überprüfen |
| in Abzug bringen | abziehen |
| die Beantragung ist möglich | Sie können beantragen |
| unter Beweis stellen | beweisen |
| Inbetriebnahme erfolgt am 1. Mai | Wir nehmen die Anlage am 1. Mai in Betrieb |
| die Erstellung des Berichts obliegt | wer den Bericht schreibt |

Spot them by the noun endings `-ung`, `-heit`, `-keit`, `-nis`, `-tion` combined with the weak verbs `erfolgen`, `durchführen`, `vornehmen`, `bringen`, `stellen`, `kommen`, `obliegen`, `Anwendung finden`.

The gain is double: shorter, and the actor reappears. `Die Prüfung erfolgt` tells you nothing about who prüft.

---

## 3. Passive and impersonal constructions

German offers several ways to hide the actor, and administrative writing uses all of them:

| Construction | Example | Fix |
|--------------|---------|-----|
| Vorgangspassiv | Der Antrag wird geprüft. | Wir prüfen Ihren Antrag. |
| `man` | Man muss das Formular unterschreiben. | Unterschreiben Sie das Formular. |
| `es wird` | Es wird empfohlen, … | Wir empfehlen Ihnen, … |
| `sein + zu` | Die Unterlagen sind einzureichen. | Reichen Sie die Unterlagen ein. |
| `lassen sich` | Die Daten lassen sich exportieren. | Sie können die Daten exportieren. |

In instructions, the imperative or `Sie können` is almost always the right form. Passive stays legitimate where the actor is genuinely unknown or irrelevant.

---

## 4. Behördendeutsch — standard replacements

| Instead of | Use |
|-----------|-----|
| aufgrund der Tatsache, dass | weil |
| im Rahmen von / im Zuge von | bei, während |
| zum jetzigen Zeitpunkt | jetzt |
| in Ermangelung | ohne, weil … fehlt |
| unbeschadet | trotz, unabhängig von |
| beinhalten | enthalten |
| seitens der Behörde | von der Behörde, wir |
| diesbezüglich | dazu, dafür |
| gegebenenfalls (ggf.) | wenn nötig, falls |
| erforderlichenfalls | wenn nötig |
| Sachverhalt | was passiert ist |
| Antragsteller/in ist gehalten | Sie müssen |
| nach Maßgabe des § … | wie in § … beschrieben |

Also worth removing: `grundsätzlich` (usually means the opposite of what readers assume — it signals a rule with exceptions), and stacked modal constructions such as `müsste eigentlich möglich sein`.

---

## 5. Compounds

German compounds are a feature, not a defect: `Krankenversicherungsbeitrag` is precise and one concept. But they drive up every readability score, and beyond a certain length they genuinely slow readers.

| Length | Handling |
|--------|----------|
| Two elements (`Antragsformular`) | Leave it |
| Three elements (`Krankenversicherungsbeitrag`) | Usually fine in specialist text; consider unfolding for a general audience |
| Four or more (`Grundstücksverkehrsgenehmigungszuständigkeitsübertragungsverordnung`) | Unfold, or introduce once and then use a short form |

Three techniques: **unfold** into a phrase (`Beitrag zur Krankenversicherung`); **introduce and shorten** (`der Krankenversicherungsbeitrag, im Folgenden: der Beitrag`); or **hyphenate** for reading support (`Kranken-Versicherungs-Beitrag`) — which is standard in Leichte Sprache and unusual elsewhere.

Do not chop compounds arbitrarily to improve a score; `Kranken Versicherung Beitrag` is not German and does not help.

---

## 6. Genitive chains and other density

Stacked genitives are a common source of density:

> **Dense** — die Bewertung der Ergebnisse der Prüfung der eingereichten Unterlagen
>
> **Fixed** — Wir prüfen die eingereichten Unterlagen und bewerten die Ergebnisse.

Related patterns: **extended participial attributes** (`die vom Ausschuss in der letzten Sitzung beschlossenen Maßnahmen`) — usually better as a relative clause or a separate sentence; and **noun stacks** where three nouns queue before the verb.

---

## 7. Address, gendering, and tone

**Sie or du** is a product decision, not a per-page one. Record it in the style guide, apply it everywhere, and note that consistency matters more than the choice itself. Many German consumer products use `du`; B2B, public-sector, and finance usually use `Sie`.

**Gendering** is contested and has readability consequences. The main options:

| Form | Example | Readability note |
|------|---------|------------------|
| Neutral rephrasing | `Studierende`, `die Person`, `das Team` | Best for readability; no special characters |
| Paired forms | `Mitarbeiterinnen und Mitarbeiter` | Longer; clear; screen-reader friendly |
| Gender star / colon | `Nutzer*innen`, `Nutzer:innen` | Screen-reader pronunciation varies; some accessibility guidance advises against inside Leichte Sprache |
| Generic masculine | `die Nutzer` | Shortest; increasingly contested |

Practical guidance: prefer **neutral rephrasing** where it exists — it is shortest, most readable, and sidesteps the dispute. Decide a single house rule, record it, and apply it consistently. In Leichte Sprache, follow the applicable guidance rather than the general house style.

---

## 8. Anglicisms

Decide per audience and record the decision:

| Term | Consumer audience | Engineering audience |
|------|-------------------|---------------------|
| `downloaden` / `herunterladen` | herunterladen | either |
| `Deployment` | Veröffentlichung | Deployment |
| `Feature` | Funktion | Feature |
| `Account` | Konto | Account |
| `Performance` | Geschwindigkeit | Performance |

Two rules: never mix both variants in one document, and avoid hybrid inflection that is ambiguous in writing (`gedownloadet`) where a German verb exists.

---

## 9. Measuring German text

Recap of the points that matter here (full detail in `readability`):

- Use **Amstad Flesch** (`180 − ASL − 58.5 × ASW`) or the **Wiener Sachtextformel**, never the English Flesch coefficients.
- **LIX** is the best choice when comparing a German page against its English counterpart.
- Compounds inflate word-length measures; a German text can be perfectly clear and still score as "difficult". Read the outlier paragraphs rather than trusting the number.
- Anglicisms distort syllable counting; treat small score differences as noise.

---

## 10. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Relative clause inserted inside the verb bracket | The classic unreadable German sentence |
| Nominalstil throughout | Long, actorless, bureaucratic |
| `Es wird …` and `man` as the default voice | Nobody is responsible for anything |
| Behördendeutsch left in consumer-facing text | Readers give up or call support |
| `grundsätzlich` used to mean "always" | Readers miss that exceptions exist |
| Compounds chopped into non-words to improve a score | Not German; helps nobody |
| Four-element compounds in general-audience text | Genuine comprehension barrier |
| Stacked genitives and participial attributes | Density without precision |
| `Sie` and `du` mixed across a product | Inconsistent voice; looks unprofessional |
| Gendering form decided per author | Visible inconsistency; avoidable dispute |
| Anglicisms mixed with their German equivalents in one text | Reader assumes a distinction exists |
| English readability formula applied to German | Wrong diagnosis, wrong rewrite |
| Literal translation from English source | English sentence structure in German words |

---

## 11. Checklist

- [ ] Verb brackets short; no relative clause inside the bracket
- [ ] At most one subordinate clause per sentence; none in Einfache Sprache
- [ ] Nominalstil and Funktionsverbgefüge converted to verbs
- [ ] Actor named; `es wird`, `man`, and `sein + zu` replaced in instructions
- [ ] Behördendeutsch replaced with everyday equivalents
- [ ] `grundsätzlich` and stacked modals removed or made explicit
- [ ] Compounds of four or more elements unfolded or introduced then shortened
- [ ] Compounds never split into non-words for the sake of a score
- [ ] Genitive chains and participial attributes broken up
- [ ] `Sie` or `du` decided once and applied consistently
- [ ] Gendering rule recorded; neutral rephrasing preferred where available
- [ ] Anglicism policy decided per audience and applied consistently
- [ ] German-calibrated readability formula used (Amstad or WSTF), never English coefficients
- [ ] Translated text checked for English sentence structure
