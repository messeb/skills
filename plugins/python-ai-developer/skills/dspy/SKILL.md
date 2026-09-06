---
description: DSPy for programmatic prompting — signatures, modules and composition, optimizers that compile prompts and few-shot demonstrations against a metric, writing metrics that mean something, the train/dev/test discipline that keeps results honest, saving and versioning compiled programs, cost control during optimization, and when DSPy is the wrong tool.
---

# DSPy — programmatic prompting and optimization

Goal of this skill: stop hand-tuning prompt strings and instead **declare what the step does, define a metric, and let an optimizer compile the prompt and examples** — with the evaluation discipline that makes the resulting numbers trustworthy.

Use this skill when prompt quality is the bottleneck, when a labelled set or a programmatic metric exists (or can be built), when a pipeline has several model steps whose prompts interact, or when you want to move a task to a cheaper model without losing accuracy.

Do **not** use it for one-off generation with no measurable success criterion, for creative writing, or when you cannot produce ~50 labelled examples — without a metric there is nothing to optimize and DSPy becomes an unusual way to call an API.

---

## 1. The model

Three layers:

| Layer | What it is |
|-------|------------|
| **Signature** | A typed declaration of the transformation — inputs, outputs, and a docstring stating the task. Not a prompt |
| **Module** | A strategy for executing a signature (`Predict`, `ChainOfThought`, `ReAct`, …), composable into a `dspy.Module` |
| **Optimizer** | A compiler that searches instructions and few-shot demonstrations to maximise your metric on a training set |

```python
import dspy

dspy.configure(lm=dspy.LM("anthropic/claude-opus-5", max_tokens=4096))


class ExtractInvoice(dspy.Signature):
    """Extract invoice fields from OCR'd document text. Use null when a field is absent."""

    document: str = dspy.InputField(desc="Raw OCR text of one invoice")
    invoice_number: str | None = dspy.OutputField(desc="Printed invoice number, null if absent")
    total_cents: int = dspy.OutputField(desc="Total in minor units")
    currency: str = dspy.OutputField(desc="ISO 4217 code")


class InvoicePipeline(dspy.Module):
    def __init__(self) -> None:
        super().__init__()
        self.classify = dspy.Predict("document -> doc_type")
        self.extract = dspy.ChainOfThought(ExtractInvoice)

    def forward(self, document: str):
        kind = self.classify(document=document).doc_type
        if kind != "invoice":
            return dspy.Prediction(invoice_number=None, total_cents=0, currency="XXX")
        return self.extract(document=document)
```

The point: you never write the prompt. The signature states intent; the optimizer produces the instruction text and the demonstrations, against your metric.

---

## 2. The metric is the whole design

An optimizer maximises exactly what you measure. A weak metric produces a program that is excellent at the wrong thing.

```python
def invoice_metric(example, pred, trace=None) -> float:
    score = 0.0
    score += 0.5 * (pred.total_cents == example.total_cents)          # the field that matters most
    score += 0.3 * (pred.invoice_number == example.invoice_number)
    score += 0.2 * (pred.currency == example.currency)
    if pred.total_cents and pred.total_cents not in example.document: # unsupported value
        score -= 0.3                                                   # penalise hallucination
    return max(0.0, score)
```

| Rule | Reason |
|------|--------|
| Weight fields by business impact | A wrong total costs more than a wrong date |
| Penalise hallucination explicitly | Otherwise confident invention scores like a correct guess |
| Prefer programmatic checks over a judge | Cheaper, deterministic, and not gameable |
| If you must use an LLM judge, calibrate it | See the judge biases in `llm-testing-and-evals` |
| Return a graded score, not just 0/1 | Gives the optimizer a gradient to follow |
| Keep it fast | It runs hundreds to thousands of times during compilation |

---

## 3. Optimizing

```python
from dspy.teleprompt import BootstrapFewShotWithRandomSearch

train, dev, test = load_splits("evals/invoices.jsonl")     # ~50 / ~50 / held out

optimizer = BootstrapFewShotWithRandomSearch(
    metric=invoice_metric,
    max_bootstrapped_demos=4,
    max_labeled_demos=8,
    num_candidate_programs=8,
)
compiled = optimizer.compile(InvoicePipeline(), trainset=train, valset=dev)

compiled.save("artifacts/invoice_pipeline.v4.json")        # versioned artifact
```

Optimizer families, roughly in order of cost:

| Optimizer | What it does | Data needed |
|-----------|--------------|-------------|
| `LabeledFewShot` | Uses your labelled examples directly as demonstrations | Small |
| `BootstrapFewShot` | Generates demonstrations by running the program and keeping the ones that pass the metric | ~20–50 |
| `BootstrapFewShotWithRandomSearch` | Searches over candidate demonstration sets | ~50+ |
| `MIPROv2` | Jointly optimizes instructions and demonstrations with a Bayesian search | ~100+, more compute |
| `BootstrapFinetune` | Distils a compiled program into a fine-tuned smaller model | Larger set |

A high-value pattern: **compile with a strong model, run with a cheap one.** Use a frontier model as the teacher to bootstrap demonstrations, then set a small model as the student for serving. This is often a larger cost reduction than any prompt hand-tuning, and the metric tells you whether accuracy survived.

Cost control during compilation: cap `num_candidate_programs`, cache LM calls (DSPy caches by default — keep it on), start on a 20-example subset to validate the metric before a full run, and set a spend ceiling. An unattended `MIPROv2` run on a large set with a frontier model is an expensive way to discover your metric was wrong.

---

## 4. Evaluation discipline

The failure mode of DSPy projects is optimizing against the number you report.

- **Three splits, kept separate**: train (the optimizer sees it), dev (used for selection during compilation), test (touched only to report final quality).
- **Never report the train or dev score** as the program's accuracy.
- **Baseline first.** Measure the uncompiled program on the test set; the compiled score is only meaningful as a delta against it.
- **Re-evaluate on model change.** A compiled program is tuned to a specific model; swapping the model invalidates the demonstrations. Recompile and re-measure.
- **Watch for overfitting** — a large train/dev gap versus test means the search memorised your set. Enlarge and diversify the set rather than tuning the optimizer.
- Reuse the same labelled set as your evaluation harness (`llm-testing-and-evals`), with the same stratification rules.

---

## 5. Production integration

Compilation is a **build-time** activity, never a request-time one.

```python
# app/extraction/invoice.py — the only module importing dspy
class InvoiceExtractor:
    def __init__(self, artifact: Path, lm: dspy.LM) -> None:
        self._program = InvoicePipeline()
        self._program.load(artifact)             # compiled prompts + demos
        self._lm = lm

    async def run(self, document: str) -> Invoice:
        with dspy.context(lm=self._lm):
            pred = await self._program.acall(document=document)
        return Invoice(invoice_number=pred.invoice_number,
                       total_cents=pred.total_cents,
                       currency=pred.currency)    # your type crosses the boundary
```

| Rule | Reason |
|------|--------|
| Compiled artifact is versioned and committed (or stored as a build artifact) | Reproducible deploys; the prompt is not regenerated per environment |
| Record the artifact version on every extraction result | Quality regressions become traceable |
| Recompile in CI on a schedule or on data change, gated by the test-set score | Prevents silent drift |
| DSPy confined to one module; your types at the boundary | Same rule as any framework (`orchestration-frameworks`) |
| Same budgets, retries, and timeouts as any other call | DSPy does not replace `llm-reliability-and-cost` |
| Inspect the compiled prompt before shipping | It is generated text; read what will actually be sent |

---

## 6. When DSPy is the wrong tool

| Situation | Better |
|-----------|--------|
| No labelled data and no programmatic metric | Build the eval set first (`llm-testing-and-evals`) |
| One prompt, already good enough | Plain SDK call |
| Open-ended creative generation | No meaningful metric to optimize |
| The bottleneck is retrieval, not prompting | Fix retrieval; a compiled prompt cannot rescue bad context |
| Control flow needs durability, pausing, approvals | LangGraph (`orchestration-frameworks`) — the two compose |
| Native schema enforcement already solves the problem | `structured-output` is simpler |

---

## 7. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Optimizing without a metric that reflects business value | A program excellent at the wrong objective |
| Metric that ignores hallucination | Invention scores the same as knowledge |
| Reporting the dev or train score | Overstated accuracy; regressions in production |
| No baseline measurement | The compilation's value is unknown |
| Compiling at request time | Latency and cost per request; non-deterministic behaviour |
| Compiled artifact not versioned | Non-reproducible deploys; unattributable regressions |
| Reusing a compiled program after a model change | Demonstrations tuned to a different model |
| Unbounded optimizer runs on frontier models | Large bill for a run you will discard |
| DSPy objects leaking into domain code | Framework welded into the core |
| Shipping a compiled prompt nobody has read | Unreviewed text sent to a provider |
| Treating DSPy as a replacement for retries and budgets | Same reliability problems, now hidden |

---

## 8. Checklist

- [ ] A metric exists that reflects business value and penalises hallucination
- [ ] Metric is fast, deterministic where possible, and unit-tested on known cases
- [ ] Train / dev / test splits separated; test used only for reporting
- [ ] Baseline (uncompiled) score measured before optimization
- [ ] Optimizer chosen to match the data volume and budget; spend ceiling set
- [ ] Compilation validated on a small subset before the full run
- [ ] Compiled prompt read and reviewed before shipping
- [ ] Artifact versioned; version recorded on every result
- [ ] Recompilation gated in CI by the test-set score
- [ ] Recompiled and re-measured after any model change
- [ ] Teacher/student split considered for cost reduction
- [ ] DSPy imports confined to one module; domain types at the boundary
- [ ] Standard retries, timeouts, and budgets still applied
