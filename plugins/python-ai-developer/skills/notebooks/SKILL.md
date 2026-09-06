---
description: Jupyter notebooks that support a production codebase — kernel setup with uv, the import-from-src rule that prevents divergence, output stripping and reviewable diffs, jupytext pairing, parameterised execution with papermill, notebooks as documentation and as evaluation reports, testing notebooks in CI, secrets and data hygiene, and the notebook-to-module promotion path.
---

# Jupyter notebooks

Goal of this skill: notebooks that are genuinely useful for exploration, evaluation, and explanation — without becoming a second, untested implementation of your product.

Use this skill for data exploration, prompt and model comparison, OCR accuracy analysis, evaluation reports, and onboarding documentation.

---

## 1. What notebooks are and are not for

| Good use | Bad use |
|----------|---------|
| Exploring a dataset or a new document class | Production data pipelines |
| Comparing prompts, models, or OCR engines side by side | Scheduled jobs |
| Rendering an evaluation report with charts | Business logic that the service imports |
| Reproducing and diagnosing a production case | Anything requiring tests and review |
| Onboarding documentation that runs | Long-lived shared state across a team |

The line: **notebooks call your library; they never contain it.** The moment a notebook holds logic the service needs, that logic belongs in `src/` with tests.

---

## 2. Setup with uv

```bash
uv add --group notebook jupyterlab ipykernel nbstripout jupytext papermill
uv run python -m ipykernel install --user --name my-ai-service --display-name "my-ai-service (.venv)"
uv run jupyter lab
```

Registering a named kernel matters: an unnamed kernel silently runs against a different interpreter, which produces the classic "works in the notebook, fails in the service" report. Confirm inside the notebook:

```python
import sys; print(sys.executable)     # must be <project>/.venv/bin/python
```

---

## 3. The import rule

```python
# First cell of every notebook
%load_ext autoreload
%autoreload 2

from app.config import get_settings
from app.ocr.pipeline import extract_text          # the SAME code the service runs
from app.llm.registry import build_llm_registry

settings = get_settings()
```

With the project installed in the environment (`src` layout, `uv sync`), `import app...` just works — no `sys.path` manipulation. `autoreload` picks up edits to `src/` without restarting the kernel, which is what makes this workflow pleasant enough that people actually follow it.

If a notebook needs a helper that does not exist in `src/`, write it in `src/` and import it. This is the single habit that keeps notebooks and production from diverging.

---

## 4. Making notebooks reviewable

Notebook JSON diffs are unreadable and outputs bloat the repository — and outputs can contain customer data, API keys printed by accident, and full model responses.

```bash
uv run nbstripout --install          # git filter: strips outputs on commit
```

```toml
# pyproject.toml — pair notebooks with plain-text scripts
[tool.jupytext]
formats = "ipynb,py:percent"
```

Jupytext pairing gives every notebook a `.py` twin that diffs and reviews like normal code. Options, in order of preference for a shared repository:

1. **Commit the `.py` percent-format file only**, generating the `.ipynb` locally — cleanest history.
2. **Commit both**, with outputs stripped — good discoverability, small diff noise.
3. **Commit the `.ipynb` with outputs** — only for a deliberately rendered report, where the output *is* the artifact.

Also: keep `.ipynb_checkpoints/` git-ignored, clear cell execution counts, and never commit a notebook whose outputs include credentials or personal data.

---

## 5. Parameterised runs and reports

Papermill executes a notebook with injected parameters, which turns a notebook into a repeatable report generator.

```python
# cell tagged "parameters"
model = "claude-opus-5"
dataset = "evals/invoices.jsonl"
sample_size = 100
```

```bash
uv run papermill notebooks/eval_report.ipynb \
    out/eval_2026-09-06.ipynb \
    -p model claude-opus-5 -p sample_size 200
```

This is a good fit for evaluation reports (`llm-testing-and-evals`) and OCR accuracy sweeps: the notebook renders charts and tables, the executed copy is archived as the record of that run, and the parameters are explicit rather than edited into cells.

Keep the heavy lifting in `src/` even here — the notebook orchestrates and visualises; the metric functions are imported and unit-tested.

---

## 6. Notebooks in CI

| Level | Approach |
|-------|----------|
| Do they still run? | `pytest --nbmake notebooks/` or `jupyter nbconvert --execute` in CI |
| Do they still produce the right numbers? | Extract assertions into a test that imports the same functions |
| Are outputs stripped? | `nbstripout --verify` as a pre-commit hook |
| Is the paired script in sync? | `jupytext --sync --check` |

Executing notebooks in CI catches the most common rot — an import that moved, a function whose signature changed — but keep them fast and offline (use fixtures, not live provider calls) or they will be disabled within a month. Notebooks that need credentials or GPUs belong in a manual or nightly job.

---

## 7. Data and secrets hygiene

- Read credentials through `get_settings()`; never paste a key into a cell. A key typed into a cell reaches the `.ipynb`, the outputs, and the git history.
- Point notebooks at sampled or anonymised data by default. A notebook is the easiest place for production personal data to end up on a laptop.
- Keep data out of the repository — read from object storage or a local `data/` directory that is git-ignored.
- Set a cost guard when a notebook loops over model calls: a `for` loop over 10,000 rows is an expensive way to discover a bug (`llm-reliability-and-cost`).
- Restart and run all before sharing results. Out-of-order execution is the classic source of numbers that cannot be reproduced.

---

## 8. Promotion path

When a notebook produces something worth keeping:

1. Move the functions into `src/`, with type hints.
2. Write unit tests for them.
3. Reduce the notebook to imports, parameters, and presentation.
4. If it runs on a schedule, it is a job — move it to a module and a worker (`async-and-background-work`), not a scheduled notebook execution.
5. If it is documentation, keep it paired, executed in CI, and dated.

---

## 9. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Business logic living in notebook cells | Untested code the service cannot use |
| `sys.path.append("../src")` | Fragile; hides a broken environment setup |
| Copy-pasting service code into a cell | Two implementations that drift apart |
| Notebooks committed with outputs | Repo bloat; leaked data and keys; unreadable diffs |
| API keys typed into cells | Credentials in git history and in outputs |
| Kernel from a different environment | "Works in the notebook, fails in production" |
| Out-of-order execution shared as a result | Numbers nobody can reproduce |
| Production data pulled onto a laptop | Data protection incident |
| Scheduled notebook execution as a production job | No tests, no monitoring, no error handling |
| Unbounded model calls in a loop | Large, unexpected bill |
| Notebooks never executed in CI | Silent rot; broken on the next person who opens them |

---

## 10. Checklist

- [ ] Notebook dependencies in a `notebook` dependency group, not runtime dependencies
- [ ] Named kernel registered against the project `.venv`; `sys.executable` verified
- [ ] Notebooks import from `src/`; no `sys.path` manipulation, no copied logic
- [ ] `autoreload` enabled for a workable edit loop
- [ ] `nbstripout` installed as a git filter; outputs stripped on commit
- [ ] Jupytext pairing configured; the `.py` twin is what gets reviewed
- [ ] `.ipynb_checkpoints/` and `data/` git-ignored
- [ ] Parameters in a tagged cell; papermill used for repeatable runs
- [ ] Executed report copies archived with their parameters
- [ ] Notebooks executed in CI, offline and fast
- [ ] Credentials read from settings; anonymised or sampled data by default
- [ ] Cost guard on loops that call model providers
- [ ] Restart-and-run-all before sharing any result
- [ ] Promotion path followed: useful logic moves to `src/` with tests
