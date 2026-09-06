---
description: Reviews, walkthroughs, and inspections of requirements — the formality ladder from desk check to Fagan inspection, defect taxonomy for requirements (ambiguity, incompleteness, contradiction, untestability), perspective-based and checklist-based reading techniques, roles and the entry/exit criteria of a formal inspection, metrics, and Markdown templates for the defect log and the inspection record.
---

# Requirements reviews, walkthroughs, and inspections

Goal of this skill: find ambiguity, gaps, and contradictions **in the document**, where a defect costs minutes, rather than in the build, where it costs weeks.

Use this skill before baselining a specification, before handing requirements to a supplier, before a regulatory submission, and as a routine gate on any requirement that will be implemented by someone who was not in the conversation.

Do **not** use a heavyweight inspection on a backlog item that three people will discuss tomorrow — use `three-amigos` and `example-mapping` instead. Formality must be earned by risk.

---

## 1. The formality ladder

| Technique | Effort | Who | Finds | Use when |
|-----------|--------|-----|-------|----------|
| **Desk check / buddy review** | 15–30 min | 1 reviewer | Obvious ambiguity and omissions | Routine changes |
| **Peer review (asynchronous)** | 30–60 min | 2–3 reviewers, comments in the document or PR | Wording, testability, missing cases | Default for most specs |
| **Walkthrough** | 60–90 min | Author leads, peers follow | Misunderstandings, missing scenarios, shared understanding | Handover, onboarding, complex flows |
| **Technical review** | 90 min | Experts, prepared in advance | Feasibility, conflicts with architecture and other requirements | Before committing |
| **Inspection (Fagan)** | Several hours across roles | Moderator, author, reader, inspectors, scribe | Systematic defect detection with measurement | Contractual, regulated, safety-relevant |

Key distinction: in a **walkthrough** the author drives and explains; in an **inspection** a separate *reader* paraphrases the document and the author stays quiet, which is precisely what exposes text that only the author understands.

---

## 2. Defect taxonomy for requirements

Classify every finding — the distribution tells you what to fix in the process, not just in the document.

| Class | Definition | Example |
|-------|------------|---------|
| **Ambiguity** | Readable in more than one way | "recent orders", "the system should respond quickly" |
| **Incompleteness** | A case is not covered | No behaviour specified when the provider times out |
| **Inconsistency** | Two statements conflict | §3.1 says 30 days, §5.4 says one month from invoice |
| **Incorrectness** | Contradicts the domain or a regulation | Compensation threshold wrong per EU 261 |
| **Untestability** | No objective pass/fail | "user-friendly", "robust" |
| **Redundancy** | Same rule stated twice | Two requirements, one meaning, destined to diverge |
| **Infeasibility** | Cannot be built or run as stated | 50 ms round trip to a system 200 ms away |
| **Over-specification** | Solution imposed where behaviour was needed | "shall use a Redis sorted set" |
| **Traceability gap** | No source, no goal, or no verification | Requirement nobody can justify or test |
| **Terminology** | Term not in the glossary, or used inconsistently | "order" meaning two things in one document |

Severity: **critical** (would cause a wrong system or a compliance breach) · **major** (rework in build or test) · **minor** (clarity) · **editorial**.

---

## 3. Reading techniques — how reviewers actually find defects

Handing people a document and asking them to "review it" produces cosmetic comments. Assign a *technique*.

**Perspective-based reading** — each reviewer reads as one role and asks that role's questions:

| Perspective | Questions |
|-------------|-----------|
| **Tester** | How would I prove this? What is the pass/fail? Where are the boundaries? |
| **Developer** | Can I implement this without asking a question? What is undefined? |
| **User / domain expert** | Is this what actually happens? What case is missing? |
| **Operations** | How do I run, monitor, and recover this? What happens at 3 a.m.? |
| **Security / privacy** | What data is this, who may see it, what is logged? |
| **Legal / compliance** | Which obligation does this satisfy, and is the citation current? |
| **Architect** | Does this conflict with another requirement or a quality scenario? |

**Checklist-based reading** — the defect taxonomy above as a checklist, plus:

- Does every requirement have a rationale, a source, and a verification method?
- Are all quantities bounded, with a measurement point?
- Is failure behaviour specified for every external dependency?
- Are all terms in the glossary and used consistently?
- Does every requirement trace to a goal and forward to a test?
- Are constraints separated from requirements?
- Is anything specified twice?

**Scenario-based reading** — walk a concrete case end to end through the document and see whether it can be answered without guessing.

---

## 4. Running a formal inspection

**Roles**: moderator (runs it, not the author) · author (answers only when asked) · reader (paraphrases the document aloud) · inspectors (find defects, each with a perspective) · scribe (logs defects).

| Phase | Purpose | Rule |
|-------|---------|------|
| **Entry check** | Does the document meet entry criteria — complete, spell-checked, version-tagged, prior defects closed? | Reject early; inspecting a draft wastes everyone's time |
| **Planning** | Moderator selects inspectors, assigns perspectives, sets the chunk size | 10–20 pages max per session; more than that and detection collapses |
| **Kickoff** (optional) | Context and objectives | Short |
| **Individual preparation** | Each inspector reads alone with their technique | This is where most defects are found — 1.5–2 h per session |
| **Inspection meeting** | Reader paraphrases; inspectors raise defects; scribe logs | **Log defects, never discuss solutions**; 2 h maximum |
| **Rework** | Author fixes | Each defect gets a disposition |
| **Follow-up** | Moderator verifies the fixes | Exit criterion |

**The rules that make it work**: attack the document, never the author; no solution discussion in the meeting; no management present; if preparation was not done, cancel the meeting.

**Metrics worth keeping**: defects found per page, preparation hours per page, defect density by class, and escaped defects found later in build or test. If most defects surface after the review, the reading techniques are wrong, not the reviewers.

---

## 5. Intake — ask before scheduling

Ask only what is missing; batch into one message, five or fewer.

1. **What is being reviewed**, at which version, and how long is it?
2. **What is the risk** — contractual, regulatory, safety, or ordinary product work? That sets the formality.
3. **Who must review it**, and which perspectives must be covered?
4. **What is the decision after the review** — approve, baseline, hand to a supplier, re-work?
5. **What are the entry criteria** — is the document actually finished enough to review?

---

## 6. Output templates

### 6.1 Defect log

````markdown
# Review defect log — <document> v<version>

- **Type**: peer review | walkthrough | inspection · **Date**: <date>
- **Moderator**: <name> · **Author**: <name> · **Reader**: <name>
- **Inspectors and perspectives**: <name> (tester), <name> (ops), <name> (legal)
- **Scope**: §3–§5, 14 pages · **Preparation time**: 1.5 h each

| # | Location | Defect | Class | Severity | Raised by | Disposition | Fixed in | Verified |
|---|----------|--------|-------|----------|-----------|-------------|----------|----------|
| D1 | §3.1 SRS-F-014 | "quickly" is not quantified | untestability | major | tester | rewrite with p95 ≤ 2 s | v1.1 | ✅ |
| D2 | §3.2 | No behaviour when the payment provider times out | incompleteness | critical | ops | add unwanted-behaviour requirement SRS-F-015 | v1.1 | ✅ |
| D3 | §3.1 vs §5.4 | 30 days vs "one month" | inconsistency | major | tester | 30 calendar days from invoice date | v1.1 | ✅ |
| D4 | §4 | "order" used for both purchase and picking job | terminology | major | domain expert | use glossary terms | v1.1 | open |

## Summary

| Class | Critical | Major | Minor | Editorial |
|-------|----------|-------|-------|-----------|
| Ambiguity | 0 | 3 | 4 | — |
| Incompleteness | 2 | 1 | 0 | — |

- **Defects per page**: 1.4 · **Preparation**: 0.11 h/page
- **Verdict**: rework required · **Re-inspection**: partial, §3 only
````

### 6.2 Inspection record

````markdown
# Inspection record — <document> v<version>

| | |
|---|---|
| Entry criteria met | yes — version tagged, prior defects closed, spell-checked |
| Pages inspected | 14 (§3–§5) |
| Participants | 5 |
| Total preparation | 7.5 h |
| Meeting duration | 1 h 50 |
| Defects logged | 20 (2 critical, 8 major, 10 minor) |
| Verdict | rework and partial re-inspection |
| Exit criteria | all critical and major defects closed and verified by the moderator |
| Follow-up owner / date | <name> / <date> |

## Process observations

- Ops perspective found both critical defects — add ops to every review of an integration spec.
- Preparation below 1 h/session correlated with zero findings; enforce preparation or cancel.
````

---

## 7. Anti-patterns

| Anti-pattern | Consequence | Do instead |
|--------------|-------------|------------|
| "Please review" with no technique assigned | Cosmetic comments only | Assign perspectives or a checklist |
| Discussing solutions in the meeting | Two hours, four defects | Log defects; solve in rework |
| Author defending the text | Reviewers go quiet | Author answers only direct questions; the reader paraphrases |
| Reviewing 80 pages in one session | Detection collapses after ~20 pages | Chunk it |
| No preparation, "we'll read it together" | The meeting finds only what is read aloud | Preparation is mandatory; cancel without it |
| Manager in the inspection | It becomes performance assessment | No management present |
| Only developers review | Ops, legal, and user perspectives missed | Cover the perspectives deliberately |
| Defects logged but never verified | Rework is assumed, not confirmed | Moderator verifies at follow-up |
| No defect classification | No signal about what to fix upstream | Class and severity on every defect |
| Formal inspection on every backlog item | Process theatre; team resentment | Formality proportional to risk |
| Review after implementation has started | Findings are unwelcome and expensive | Review before commitment and baselining |

---

## 8. Checklist

- [ ] Formality chosen to match the risk
- [ ] Entry criteria checked before scheduling
- [ ] Document chunked to a size where detection stays effective
- [ ] Perspectives assigned across tester, developer, user, ops, security, legal, architect
- [ ] Reading technique specified, not left to the reviewer
- [ ] Individual preparation done and time recorded
- [ ] Reader paraphrases; author does not present (inspections)
- [ ] Defects logged with location, class, and severity — no solution discussion
- [ ] Every requirement checked for rationale, source, verification method, and traceability
- [ ] Terminology checked against the glossary
- [ ] Failure behaviour checked for every external dependency
- [ ] Disposition assigned to every defect; critical and major ones verified at follow-up
- [ ] Metrics recorded: defects per page, preparation per page, class distribution
- [ ] Process observations fed back into how the next document is written
