---
description: Testing non-deterministic AI code — the test pyramid for LLM applications, fake clients and recorded fixtures, what to assert when output varies, building a labelled evaluation set, offline metrics and LLM-as-judge with its failure modes, regression gates in CI, canary and A/B in production, and testing OCR and ML components.
---

# Testing and evaluating AI code

Goal of this skill: a suite that is fast, offline, and free for the deterministic 95% of the codebase, plus a small, deliberate evaluation harness for the part that genuinely varies.

Use this skill from the first LLM call. Retrofitting evaluation after a quality complaint means having no baseline to compare against.

---

## 1. The pyramid

| Layer | What it covers | Speed | Cost | When it runs |
|-------|----------------|-------|------|--------------|
| **Unit** | Prompt construction, response parsing, schema validation, error mapping, budget logic, routing | ms | free | Every commit |
| **Contract** | Each adapter satisfies the `LLMClient` protocol identically, against recorded fixtures | ms | free | Every commit |
| **Integration** | API routes with a fake LLM; queue, DB, storage wiring | s | free | Every commit |
| **Live smoke** | A handful of real provider calls proving credentials and shapes still work | s | cents | Nightly / pre-release |
| **Evaluation** | Output quality on a labelled set | minutes | dollars | On prompt, model, or schema change |

The great majority of an AI service is ordinary deterministic code. Test it as such. Only genuine output quality needs the evaluation layer.

---

## 2. Fakes and fixtures

```python
class FakeLLM:
    """Scripted client implementing the LLMClient protocol."""
    name = "fake"
    supports = frozenset({"tools", "json_schema", "streaming"})

    def __init__(self, replies: list[str | Exception]) -> None:
        self._replies, self.calls = list(replies), []

    async def complete(self, messages, **kw) -> Completion:
        self.calls.append((messages, kw))
        reply = self._replies.pop(0)
        if isinstance(reply, Exception):
            raise reply
        return Completion(text=reply, model="fake", provider="fake",
                          usage=Usage(10, 5), finish_reason="stop")

    async def aclose(self) -> None: ...
```

```python
def test_falls_back_to_second_provider():
    primary = FakeLLM([ProviderUnavailable("503")])
    secondary = FakeLLM(["ok"])
    registry = LLMRegistry({"a": primary, "b": secondary}, {"chat": ["a", "b"]})
    assert (await registry.complete_with_fallback("chat", ...)).text == "ok"
```

A fake also lets you assert **what was sent**: that the system prompt was included, that the document was truncated to the budget, that the cache breakpoint sits before the volatile part.

**Recorded fixtures** cover response parsing. Capture a real response once, sanitise it (strip keys, ids, and any user data), commit the JSON, and replay it in adapter tests. Re-record on a schedule — a fixture that never changes will not tell you the provider's response shape has drifted; the nightly live smoke test is what catches that.

---

## 3. What to assert when output varies

Do not assert exact strings from a model. Assert the properties you actually depend on:

| Property | Assertion |
|----------|-----------|
| Shape | Parses into the Pydantic model |
| Constraints | Enum membership, bounds, required fields present |
| Grounding | Extracted values appear in the source text (`structured-output` provenance) |
| Business rules | Line items sum to the total; dates are ordered |
| Safety | No PII in output when the prompt forbids it |
| Format | Language, length bounds, no markdown fences where forbidden |
| Behaviour | The right tool was called with the right arguments |
| Cost | Tokens and dollars within the expected envelope |

For classification and extraction, use a labelled set and measure accuracy — a per-example assertion is not the right instrument.

---

## 4. The evaluation set

1. **Start with 30–50 real, labelled examples per task.** Real inputs beat synthetic ones; include the awkward cases that caused past bugs.
2. **Stratify** across document types, languages, lengths, and edge cases (empty, huge, malformed, adversarial).
3. **Label with the expected output** — exact values for extraction, a class for classification, a rubric for open-ended generation.
4. **Grow it from production failures.** Every quality complaint becomes an eval case; that is what makes the set match reality over time.
5. **Version it**, and never let a model see the evaluation set as few-shot examples — that is training on the test set.
6. **Hold out a slice** you only run before a release, so continuous tuning does not overfit the visible set.

```python
@pytest.mark.eval
@pytest.mark.parametrize("case", load_cases("evals/invoice_extract.jsonl"), ids=lambda c: c.id)
def test_invoice_extraction(case, extractor, results):
    got = extractor.run(case.input)
    results.record(case.id, expected=case.expected, got=got)   # aggregate, do not assert per case

def test_aggregate_thresholds(results):
    assert results.field_accuracy("total_cents") >= 0.98
    assert results.field_accuracy("invoice_number") >= 0.95
    assert results.hallucination_rate() <= 0.01
```

Assert on **aggregates with thresholds**, not on individual cases. One case failing is noise; accuracy dropping two points is signal.

---

## 5. Metrics

| Task | Metric |
|------|--------|
| Extraction | Per-field precision/recall; exact-match rate; hallucination rate (value not supported by the source) |
| Classification | Accuracy, macro-F1, confusion matrix — not accuracy alone on imbalanced classes |
| Retrieval | Recall@k, MRR |
| Summarisation / open generation | Rubric scoring by judge, plus faithfulness (claims supported by the source) |
| Tool use | Correct-tool rate, valid-argument rate, turns to completion |
| OCR | Character and word error rate against ground truth (`ocr`) |
| End-to-end | Task success rate, cost per successful task, p95 latency |

### LLM-as-judge — useful, with real limits

For open-ended output where no exact answer exists, a strong model scoring against a rubric correlates reasonably with human judgement. Known biases you must control for:

- **Position bias** in pairwise comparison — randomise order, or score each independently.
- **Length bias** — longer answers score higher; cap or normalise length.
- **Self-preference** — a model favours its own outputs; judge with a different model family than the one under test.
- **Rubric drift** — a vague rubric produces unstable scores; use a small, concrete scale with explicit anchors.

Calibrate against human labels on a subset before trusting the judge, and re-calibrate when you change the judge model. A judge is a measuring instrument; an uncalibrated instrument is not evidence.

---

## 6. CI and production

**CI**: unit, contract, and integration tests on every commit (offline, free). Evaluation runs when `prompts/**`, `schemas/**`, or model configuration changes — as a **gate** with thresholds, publishing a comparison against the previous run. Live smoke tests nightly, alerting on shape drift or credential expiry.

**Production** is where the real evaluation happens:

- Log inputs, outputs, and quality signals (with consent and a retention policy).
- Capture implicit feedback: retries, edits, abandonment, thumbs-down, downstream corrections.
- Sample and label continuously; feed failures into the eval set.
- Canary a prompt or model change on a small traffic share before rolling out; compare task success and cost, not just latency.
- **Never change model and prompt in the same deploy** — you will not know which moved the metric.

---

## 7. Testing OCR and ML components

- **OCR**: a small ground-truth corpus with character/word error rate thresholds per document class; test the *pipeline* (rasterisation, deskew, engine, post-processing), since preprocessing is usually where accuracy is won or lost.
- **ML**: pin the data version and the random seed; test the feature transform and the serving path separately from model quality; assert reproducibility (the same input yields the same prediction); and check for train/serve skew by running the training features through the serving code path. See `machine-learning`.
- **Solvers**: test on instances with known optima; assert feasibility of every returned solution and that the objective is within a tolerance; use a fixed time limit so results are comparable (`operations-research`).

---

## 8. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Asserting exact model output strings | Perpetually flaky tests, then disabled tests |
| Every test hitting a real provider | Slow, expensive, flaky, unusable in CI |
| No evaluation set | Prompt changes ship on vibes; regressions are found by users |
| Eval cases used as few-shot examples | Training on the test set; scores mean nothing |
| Per-case assertions in evaluation | Noise fails the build; the real signal is the aggregate |
| Uncalibrated LLM judge | Confident, wrong quality measurements |
| Same model family as judge and subject | Self-preference inflates the score |
| Temperature left non-zero in tests | Avoidable non-determinism |
| Fixtures never re-recorded | Provider shape drift goes undetected |
| Prompt and model changed together | The cause of a regression is unknowable |
| Production quality never measured | The eval set drifts away from reality |
| Fixtures committed with real user data or keys | Data and credential leak in the repo |

---

## 9. Checklist

- [ ] Deterministic logic covered by fast offline unit tests
- [ ] Fake client implementing the protocol; used in route and policy tests
- [ ] Adapter tests replay sanitised recorded fixtures; all adapters share one contract suite
- [ ] Error mapping and fallback policy tested with fakes
- [ ] Default test run needs no network and no credentials
- [ ] Live smoke tests run nightly and alert on shape drift
- [ ] Labelled evaluation set of 30+ real, stratified cases per task, versioned
- [ ] Eval cases never used as prompt examples; a held-out slice reserved
- [ ] Aggregate thresholds asserted, not individual cases
- [ ] Metrics appropriate to the task, including hallucination and cost per successful task
- [ ] Judge calibrated against human labels; different model family from the subject
- [ ] Evaluation gates CI on prompt, schema, or model changes with a run-to-run comparison
- [ ] Production feedback sampled and fed back into the eval set
- [ ] Model and prompt changes rolled out separately, behind a canary
