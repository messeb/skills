---
description: Running slow AI work without blocking the API — choosing between inline, background task, and queue; async vs threads vs processes; the job pattern with status polling and SSE; idempotency and deduplication of expensive calls; concurrency limits and backpressure; cancellation and timeouts; retries that do not double-charge; and worker deployment.
---

# Async, background work, and job queues

Goal of this skill: keep request latency bounded while the expensive parts — a 90-second model call, a 300-page OCR run, a solver — happen somewhere that can take the time, be retried safely, and be cancelled.

Use this skill when a request can exceed a few seconds, when work must survive a deploy, when retries risk paying twice for the same generation, or when concurrent load is overwhelming a provider's rate limit.

---

## 1. Choose the execution model

| Duration / property | Approach |
|---------------------|----------|
| < ~2 s, cheap, idempotent | Inline in the request |
| 2–30 s, user is waiting, output is incremental | Inline **streaming** (SSE — see `fastapi`) |
| 30 s – minutes | **Job**: accept, return `202` + job id, process out of band, poll or stream status |
| Must survive process restart or deploy | Durable queue with a persisted job record |
| Scheduled or batch | Queue with a scheduler, or a provider batch API at reduced cost |
| CPU-bound (inference, rasterising, solving) | Process pool or dedicated worker — never the event loop |

`BackgroundTasks` in FastAPI runs **in the same process, after the response**. It is fine for fire-and-forget side effects (sending a webhook, writing an audit row). It is not a queue: the work is lost on restart, invisible to monitoring, and unbounded in concurrency. Do not use it for paid model calls.

---

## 2. Concurrency primitives

| Work | Primitive |
|------|-----------|
| Many concurrent network calls | `asyncio` + async SDK clients |
| Blocking C extension or sync SDK | `anyio.to_thread.run_sync` (bounded by the thread limiter) |
| CPU-bound Python | `ProcessPoolExecutor`, or a separate worker process |
| Fan-out across providers or documents | `asyncio.gather` with a semaphore |

```python
import asyncio

sem = asyncio.Semaphore(8)          # cap in-flight provider calls

async def summarize(doc: str) -> str:
    async with sem:
        return await llm.complete(f"Summarize:\n{doc}")

results = await asyncio.gather(*(summarize(d) for d in docs), return_exceptions=True)
```

Always bound the fan-out. `asyncio.gather` over a thousand documents will open a thousand concurrent requests, hit the provider's rate limit, and turn a throughput problem into an error storm. Use `return_exceptions=True` so one failure does not discard the other 999 results.

---

## 3. The job pattern

```python
# POST /v1/documents:extract  ->  202 Accepted
{"job_id": "01J...", "status": "queued", "status_url": "/v1/jobs/01J..."}

# GET /v1/jobs/01J...
{"job_id": "01J...", "status": "running", "progress": {"done": 12, "total": 40},
 "result": null, "error": null}
```

Job states: `queued → running → succeeded | failed | cancelled`, plus `expired` for results you garbage-collect. Persist the record before enqueuing — otherwise a crash between the two loses the job with no trace.

```python
@router.post("/documents:extract", status_code=202, response_model=JobAccepted)
async def submit(body: ExtractRequest, jobs: JobsDep) -> JobAccepted:
    job = await jobs.create(kind="ocr", payload=body.model_dump(),
                            idempotency_key=body.idempotency_key)
    if job.was_existing:                      # same key, already submitted
        return JobAccepted(job_id=job.id, status=job.status, status_url=...)
    await jobs.enqueue(job.id)
    return JobAccepted(job_id=job.id, status="queued", status_url=...)
```

Offer both polling (`GET /jobs/{id}`) and an SSE stream (`GET /jobs/{id}/events`) for progress. Give clients a `Retry-After` hint so they do not poll in a tight loop.

---

## 4. Idempotency — the rule that matters most with paid work

A retried HTTP request must never produce a second paid model call.

1. Require an `Idempotency-Key` header (or accept a client-supplied key in the body) on every expensive endpoint.
2. Store `key → job_id` with a unique constraint. Insert **before** doing the work.
3. On a duplicate key, return the existing job instead of starting a new one.
4. Inside the worker, make each step re-entrant: check whether the step's output already exists before recomputing it.
5. Where the provider supports its own idempotency or request id, pass it through.

The same discipline applies to queue delivery. Almost every queue is **at-least-once**, so the worker must tolerate receiving the same message twice — dedupe on the job id, not on message arrival.

---

## 5. Timeouts, cancellation, and backpressure

```python
async def call_with_deadline(coro, seconds: float):
    with anyio.fail_after(seconds):
        return await coro
```

| Concern | Practice |
|---------|----------|
| Per-attempt timeout | Always set one on the provider client; the SDK default is often minutes |
| Total deadline | Budget across retries — three attempts at 60 s is a 3-minute worst case |
| Client disconnect | Check `request.is_disconnected()` in streams; cancel the task |
| Cancellation | Propagate `asyncio.CancelledError`; never swallow it in a bare `except Exception` |
| Cleanup | Release semaphores and mark the job in `finally`, not after the await |
| Queue depth | Expose it as a metric and reject or shed load when it exceeds a threshold |
| Provider rate limits | One shared limiter per provider per process; queue rather than burst |
| Worker crash | Visibility timeout plus a max-attempts dead-letter queue |

Bare `except Exception` around an `await` is the classic bug: on Python 3.8+ `CancelledError` derives from `BaseException` and is not caught, but a broad `except BaseException` swallows it and leaves the task un-cancellable. Catch specific exceptions.

---

## 6. Retries that do not double-charge

| Failure | Retry? |
|---------|--------|
| Connection error, 5xx, 429 | Yes — exponential backoff with jitter, honour `Retry-After` |
| Timeout on a **streaming** call | Risky — output may have been generated and billed; prefer resuming or failing the job |
| 400 / schema validation failure | No — retrying an invalid request wastes money; fix the request |
| Content refusal | No — retry with a different prompt or model, deliberately, and record it |
| Partial batch failure | Retry only the failed items, keyed by item id |

Record attempts on the job (`attempt`, `provider`, `model`, `cost_usd`) so a bill can be traced to a job. See `llm-reliability-and-cost`.

---

## 7. Choosing a queue

| Option | Fits |
|--------|------|
| **Redis + ARQ / RQ / Dramatiq** | Redis already present; simple async jobs; light operational load |
| **Celery + Redis/RabbitMQ** | Mature ecosystem, scheduling, complex routing; heavier |
| **Postgres-backed queue** (`SELECT … FOR UPDATE SKIP LOCKED`) | You already run Postgres and want jobs transactional with your data — usually the simplest correct choice |
| **SQS / Pub/Sub / Service Bus** | Managed durability, cross-service, autoscaling workers |
| **Provider batch APIs** | Large non-urgent volumes at roughly half price and hours of latency |

Run workers as a **separate container from the API** with the same image and a different command, so a burst of GPU-heavy jobs cannot starve HTTP handlers. See `containerization`.

---

## 8. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| `BackgroundTasks` for paid model calls | Work lost on restart, invisible, unbounded concurrency |
| Unbounded `asyncio.gather` fan-out | Rate-limit storm; the provider becomes the outage |
| No idempotency key on expensive endpoints | Client retries double the bill |
| Enqueuing before persisting the job | Crash loses the job with no record |
| Assuming exactly-once queue delivery | Duplicate paid work |
| No per-attempt timeout | One hung request holds a worker slot for minutes |
| Swallowing `CancelledError` | Tasks that cannot be shut down; deploys hang |
| Retrying 400s and refusals | Money spent to get the same failure |
| Polling with no `Retry-After` | Clients hammer the status endpoint |
| Workers in the API container | GPU or CPU jobs starve HTTP handlers |
| Results kept forever | Storage growth; user data retained beyond policy |

---

## 9. Checklist

- [ ] Execution model chosen per endpoint by duration and durability need
- [ ] `BackgroundTasks` used only for cheap, loss-tolerant side effects
- [ ] Job record persisted before enqueue; states and terminal transitions defined
- [ ] Idempotency key required on every expensive endpoint and enforced by a unique constraint
- [ ] Worker steps re-entrant; at-least-once delivery assumed
- [ ] Per-attempt timeout and a total deadline across retries
- [ ] Fan-out bounded by a semaphore; `return_exceptions=True` where partial success is useful
- [ ] Client disconnect cancels the work; `CancelledError` propagated
- [ ] Retry policy distinguishes retriable from non-retriable failures
- [ ] Per-attempt cost recorded on the job
- [ ] Dead-letter queue with max attempts and alerting
- [ ] Queue depth and job age exported as metrics
- [ ] Workers deployed separately from the API; results expired on a retention policy
