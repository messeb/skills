---
description: Classical and deep ML in a Python service — choosing ML over an LLM, reproducible training pipelines, scikit-learn Pipelines that prevent leakage, experiment tracking and model registry, serialization and versioning, serving inside FastAPI versus a dedicated server, feature parity between training and serving, monitoring for drift, and retraining triggers.
---

# Machine learning components

Goal of this skill: build ML that is reproducible, servable, and monitorable — and know when a small trained model beats calling a language model on every request.

Use this skill for classification, regression, ranking, forecasting, anomaly detection, embeddings, and any model you train and serve yourself.

---

## 1. ML or LLM?

| Signal | Choose |
|--------|--------|
| Thousands of labelled examples exist | **ML** — cheaper, faster, more accurate on a narrow task |
| Millions of predictions per day | **ML** — per-call LLM cost dominates |
| Latency budget under ~50 ms | **ML** |
| Task is stable and well specified (fraud score, churn, routing) | **ML** |
| Little or no labelled data; open-ended or linguistic task | **LLM** |
| Requirements change weekly | **LLM** — no retraining cycle |
| Explainability required for regulators | **ML** — feature attribution is tractable |
| Need both | Use an LLM to bootstrap labels, then train a small model on them |

The last row is often the best answer: a language model labels ten thousand examples once, and a gradient-boosted tree or a fine-tuned small encoder serves them at a fraction of a cent per million predictions.

---

## 2. Reproducibility

Every training run must be re-creatable from what is committed.

| Element | Practice |
|---------|----------|
| Code | Git commit recorded in the run metadata |
| Dependencies | `uv.lock` — the exact resolved environment |
| Data | Versioned snapshot or a query pinned by timestamp and a content hash; never "the current table" |
| Split | Deterministic and recorded — by time for anything temporal, by group where rows are correlated |
| Randomness | One seed set for Python, NumPy, and the framework, recorded in metadata |
| Parameters | Config file, not notebook cell edits |
| Output | Model artifact plus metrics, both versioned |

```python
def set_seeds(seed: int) -> None:
    import random, numpy as np
    random.seed(seed); np.random.seed(seed)
    try:
        import torch
        torch.manual_seed(seed)
        torch.use_deterministic_algorithms(True, warn_only=True)
    except ImportError:
        pass
```

**Split by time whenever the data has a time dimension.** A random split on temporal data leaks the future into training and produces an accuracy number you will never reproduce in production — the most common and most damaging mistake in applied ML.

---

## 3. Pipelines that prevent leakage

Fit every transformation inside the cross-validation fold, never on the full dataset.

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer

pre = ColumnTransformer([
    ("num", Pipeline([("impute", SimpleImputer(strategy="median")),
                      ("scale", StandardScaler())]), NUMERIC),
    ("cat", Pipeline([("impute", SimpleImputer(strategy="most_frequent")),
                      ("onehot", OneHotEncoder(handle_unknown="ignore"))]), CATEGORICAL),
])
model = Pipeline([("pre", pre), ("clf", HistGradientBoostingClassifier(random_state=SEED))])
scores = cross_val_score(model, X_train, y_train, cv=TimeSeriesSplit(5), scoring="average_precision")
```

Leakage sources to check explicitly: scaling or imputing before the split; target encoding computed on all rows; features that are unavailable at prediction time (a field filled in *after* the outcome); duplicate rows spanning train and test; and group leakage where several rows belong to one customer.

`handle_unknown="ignore"` matters at serving time — an unseen category must not raise.

Choose the metric for the problem, not the default: `average_precision` or recall at a fixed precision for rare positives, not accuracy. Report a baseline (majority class, or the current rules engine) alongside the model, or the number is meaningless.

---

## 4. Tracking and the registry

Track every run: parameters, metrics, data version, code commit, environment, and the artifact. MLflow is the common choice; the discipline matters more than the tool.

```python
import mlflow

with mlflow.start_run(run_name=f"churn-{data_version}"):
    mlflow.log_params({"model": "hgb", "seed": SEED, "data_version": data_version})
    model.fit(X_train, y_train)
    mlflow.log_metrics({"ap_test": ap, "recall_at_p90": r})
    mlflow.sklearn.log_model(model, "model", registered_model_name="churn")
```

Promote through explicit stages (`staging → production`), keep the artifact immutable, and record which model version produced every prediction. Without that last field, you cannot explain a decision after a rollback.

---

## 5. Serialization

| Format | Use | Caution |
|--------|-----|---------|
| `joblib` / pickle | scikit-learn | **Executes arbitrary code on load** — never load an untrusted artifact; version-lock scikit-learn, since unpickling across versions is unsupported |
| ONNX | Cross-runtime, fast CPU inference | Not every estimator converts; validate numerically after conversion |
| `torch.save(state_dict)` | PyTorch | Save the state dict plus the class definition, not the whole module object |
| Safetensors | Model weights | Safe by construction; the better default for weights |
| Native boosters (`XGBoost`/`LightGBM`) | Tree models | Stable and portable across versions |

Always store the artifact with a metadata sidecar: training data version, feature list and order, library versions, metrics, and the code commit.

---

## 6. Serving

| Approach | Fits |
|----------|------|
| In-process in FastAPI | Small models (trees, linear, small encoders), low latency, simple ops |
| Dedicated worker | CPU-heavy inference that would block the API |
| Model server (TorchServe, Triton, BentoML) | GPU models, batching, multi-model, independent scaling |
| ONNX Runtime in-process | Fast CPU inference without a separate service |

```python
# Load once at startup — never per request
@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.model = joblib.load(settings.model_path)
    app.state.model_version = read_metadata(settings.model_path)["version"]
    yield

@router.post("/predict", response_model=PredictResponse)
async def predict(body: PredictRequest, request: Request) -> PredictResponse:
    model = request.app.state.model
    features = build_features(body)                       # the SAME function used in training
    proba = await anyio.to_thread.run_sync(lambda: model.predict_proba(features)[0, 1])
    return PredictResponse(score=float(proba), model_version=request.app.state.model_version)
```

**Train/serve skew is the main production failure mode.** The defence is one feature-building function, imported by both the training job and the serving path — never two implementations that "do the same thing". Test that skew is absent by running training rows through the serving code and comparing outputs exactly.

Return the model version in the response and log it with every prediction.

---

## 7. Monitoring and retraining

| Monitor | Signal |
|---------|--------|
| Input drift (PSI, KS test per feature) | The world changed; features moved |
| Prediction drift | Output distribution shifted |
| Performance on delayed labels | The real metric, once outcomes arrive |
| Segment performance | Aggregate accuracy can hide a failing segment |
| Latency and error rate | Operational health |
| Feature availability | A null-rate spike usually means an upstream pipeline broke |

Retrain on a trigger, not only on a calendar: performance below a threshold, drift beyond a bound, enough new labelled data, or a known upstream change. Every retrain must beat the incumbent on the held-out set before promotion, and ship behind a shadow or canary deployment — score both models, serve one, compare.

---

## 8. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Random split on temporal data | Future leaks into training; production accuracy collapses |
| Scaling or encoding before the split | Optimistic, unreproducible scores |
| Separate feature code for training and serving | Train/serve skew; silent accuracy loss |
| Model loaded per request | Seconds of latency per call |
| Model artifact untracked or unversioned | Predictions cannot be explained or reproduced |
| Accuracy reported on imbalanced data | A useless model looks excellent |
| No baseline comparison | No evidence the model helps |
| Pickle loaded from an untrusted source | Arbitrary code execution |
| scikit-learn version not pinned with the artifact | Unpickling breaks or silently misbehaves |
| Blocking inference on the event loop | Every concurrent request stalls |
| No drift monitoring | Degradation discovered by users |
| Retraining on a calendar without a promotion gate | A worse model reaches production automatically |
| Notebook as the training pipeline | Unreproducible, unreviewable, untestable |

---

## 9. Checklist

- [ ] ML-vs-LLM decision recorded, with volume, latency, and label availability
- [ ] Data version, code commit, seed, and split strategy recorded per run
- [ ] Temporal or grouped split where the data requires it
- [ ] All transformations inside the pipeline; fitted within folds only
- [ ] Leakage checks performed and documented
- [ ] Metric appropriate to class balance; baseline reported alongside
- [ ] Runs tracked with params, metrics, artifact, and environment
- [ ] Registry with explicit promotion stages and immutable artifacts
- [ ] Artifact stored with a metadata sidecar including feature order and library versions
- [ ] One feature-building function shared by training and serving; skew tested
- [ ] Model loaded once at startup; inference off the event loop
- [ ] Model version returned in responses and logged with every prediction
- [ ] Drift, delayed-label performance, and per-segment metrics monitored
- [ ] Retraining triggered by conditions, gated by a held-out comparison, released via canary or shadow
