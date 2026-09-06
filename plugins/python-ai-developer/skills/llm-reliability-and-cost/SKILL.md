---
description: Making LLM calls dependable and affordable — one retry policy with jitter and Retry-After, rate limiting and concurrency control, timeouts and hedging, prompt caching, model tiering and routing, batch APIs, semantic and exact response caching, per-request and per-tenant budgets with enforcement, cost attribution, and the metrics and alerts that catch a spend regression before the invoice does.
---

# LLM reliability and cost control

Goal of this skill: keep a provider-dependent service inside its latency and money budgets, and make both observable per request, per tenant, and per feature.

Use this skill once real traffic hits a model provider — the failure modes here (rate limits, retry storms, silent cost regressions) do not appear in development.

---

## 1. One retry policy, in one place

Disable the SDK's retries and own the policy, or the two multiply: `max_retries=2` in the SDK under your own three attempts is nine calls and nine charges.

```python
import random, asyncio

RETRIABLE = (ProviderRateLimited, ProviderUnavailable, ProviderTimeout)

async def with_retry(fn, *, attempts: int = 3, base: float = 0.5, cap: float = 8.0):
    for attempt in range(attempts):
        try:
            return await fn()
        except RETRIABLE as e:
            if attempt == attempts - 1:
                raise
            delay = min(cap, base * 2 ** attempt) * (0.5 + random.random())   # full jitter
            if (ra := getattr(e, "retry_after", None)) is not None:
                delay = max(delay, ra)
            await asyncio.sleep(delay)
        except (ProviderBadRequest, ProviderRefused, ProviderAuthError):
            raise                                    # deterministic — never retry
```

| Rule | Reason |
|------|--------|
| Jitter always | Synchronised retries from many workers create a thundering herd |
| Honour `Retry-After` | The provider is telling you when it will work |
| Never retry 400s, refusals, auth errors | The same request fails identically and still costs |
| Cap total attempts **and** total deadline | Three attempts at 60 s is a three-minute request |
| Treat streaming timeouts as non-retriable by default | Output may already have been generated and billed |
| Add a circuit breaker per provider | Stop hammering a provider that is down; fail over instead |

---

## 2. Rate limiting and concurrency

Providers limit both requests and tokens per minute, usually with headers reporting remaining quota. React to those rather than discovering limits by hitting them.

- One **shared limiter per provider per process**, sized below the account limit, not per call site.
- Cap in-flight requests with a semaphore (`async-and-background-work`); queue rather than burst.
- Read the rate-limit headers and export remaining quota as a metric — alerting on "approaching limit" is far better than alerting on 429s.
- Give interactive traffic priority over batch work; batch jobs should yield.
- On sustained 429s, shed load or fall back to another provider rather than queueing without bound.

---

## 3. Timeouts and latency

| Control | Guidance |
|---------|----------|
| Connect timeout | A few seconds |
| Per-attempt timeout | Set explicitly; SDK defaults are minutes |
| Total deadline | Budgeted across retries, enforced with `anyio.fail_after` |
| Streaming | Use it for anything long — it avoids HTTP timeouts and improves perceived latency |
| Time to first token | Track separately from total duration; it is what users feel |
| Hedged requests | Send a duplicate to a second provider after a p95 delay — halves tail latency but doubles cost for hedged calls; use only on short, interactive, idempotent paths, and cancel the loser |

---

## 4. Spending less

Ordered by typical impact.

### Prompt caching

Long stable prefixes — system prompt, few-shot examples, a document being asked many questions — can be cached by the provider at a large discount.

```python
resp = await client.messages.create(
    model="claude-opus-5", max_tokens=1024,
    system=[{"type": "text", "text": BIG_STABLE_SYSTEM_PROMPT,
             "cache_control": {"type": "ephemeral"}}],
    messages=[{"role": "user", "content": question}],
)
assert resp.usage.cache_read_input_tokens > 0     # verify it is actually hitting
```

Caching is a **prefix match**: any byte change anywhere before the cache point invalidates everything after it. Put stable content first and volatile content (timestamps, request ids, the user's question) last. If `cache_read_input_tokens` stays zero across repeated calls, a silent invalidator is at work — a `datetime.now()` in the system prompt, non-deterministic JSON ordering, or a tool list that varies between requests. Anthropic and Gemini require explicit cache markers; OpenAI caches long prefixes automatically.

### Model tiering

Route by task difficulty, not habit: classification and routing to a cheap small model, hard reasoning to a frontier model. Where a provider exposes a reasoning-effort control, lower effort is usually a bigger and safer saving than switching to a weaker model.

### Batch APIs

Non-urgent bulk work (backfills, nightly enrichment, evaluation runs) through a provider's batch endpoint typically costs about half, with hours of latency. This is the largest single saving available for offline workloads.

### Response caching

| Layer | Use |
|-------|-----|
| Exact-match cache on a hash of `(model, prompt, params)` | Repeated identical requests — cheap, safe, surprisingly effective |
| Semantic cache on embedding similarity | Higher hit rate, but a wrong hit returns a wrong answer — set a conservative threshold and log hits for review |
| Cache the *derived artifact*, not the generation | An OCR result or an extracted record is reusable long after the model call |

Never cache across tenants, and always include the model ID and prompt version in the key.

### Prompt size

Trim retrieved context to what is needed, cap conversation history with a summarisation step, and remove few-shot examples once a schema does the same job. Input tokens are usually the majority of spend in RAG-style workloads.

---

## 5. Budgets that are actually enforced

```python
@dataclass
class Budget:
    per_request_usd: float = 0.25
    per_tenant_daily_usd: float = 20.0

async def guard(tenant: str, estimated: float, budgets: Budget, store) -> None:
    if estimated > budgets.per_request_usd:
        raise BudgetExceeded("request exceeds per-request budget")
    spent = await store.today(tenant)
    if spent + estimated > budgets.per_tenant_daily_usd:
        raise BudgetExceeded("tenant daily budget exhausted")
```

Estimate before the call from the token count, record actual usage after it, and enforce at three levels: per request (caps a single runaway agent loop), per tenant per day (caps an abusive or buggy client), and global per day (caps everything, with an alert well below the ceiling). A budget that only produces a dashboard is not a control.

---

## 6. Cost attribution and metrics

Emit one structured record per model call:

```json
{"request_id": "...", "tenant": "...", "feature": "invoice_extract",
 "provider": "anthropic", "model": "claude-opus-5", "prompt_version": "v3",
 "attempt": 1, "latency_ms": 1840, "ttft_ms": 320,
 "input_tokens": 5120, "cached_input_tokens": 4096, "output_tokens": 260,
 "reasoning_tokens": 0, "cost_usd": 0.0143, "finish_reason": "stop", "cache_hit": false}
```

Metrics worth having: cost per feature per day, cost per successful task (the number that matters — not cost per call), p50/p95/p99 latency and time to first token by model, error rate by class, retry rate, cache hit rate, and remaining rate-limit quota.

Alerts: daily spend above a threshold, a day-over-day spend jump, cache hit rate collapsing, retry rate rising, and any single request over a hard cost ceiling. A prompt change that quietly triples token usage is invisible without the first two.

Reconcile your computed spend against the provider's invoice monthly. A persistent gap means your price table is stale or you are missing a token category — usually reasoning tokens.

---

## 7. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| SDK retries plus application retries | Attempts and cost multiply silently |
| Retrying without jitter | Synchronised herd; the provider stays overloaded |
| Retrying 400s and refusals | Money spent for the identical failure |
| No total deadline across retries | Multi-minute requests behind a 30-second gateway |
| Rate limiter per call site | The account limit is exceeded anyway |
| Caching without verifying `cache_read` tokens | Believing in a discount you are not receiving |
| Volatile content early in the prompt | Cache invalidated on every request |
| One frontier model for every task | Several times the necessary spend |
| Interactive API used for bulk backfills | Double the cost of the batch API |
| Semantic cache with a loose threshold | Confidently wrong answers served from cache |
| Cache keys without model ID or prompt version | Stale answers survive a model upgrade |
| Budgets that log but do not block | Runaway loops discovered on the invoice |
| Cost per call tracked, cost per task ignored | Retries and failures hide the real unit economics |
| Reasoning tokens excluded from cost | Systematic under-reporting |

---

## 8. Checklist

- [ ] SDK retries disabled; one retry policy with full jitter and `Retry-After`
- [ ] Non-retriable errors classified and never retried
- [ ] Total deadline enforced across attempts; per-attempt timeouts set
- [ ] Circuit breaker per provider, with fallback routing
- [ ] Shared rate limiter and concurrency cap per provider
- [ ] Rate-limit headers exported as metrics with a pre-emptive alert
- [ ] Prompt caching used, with stable content first and cache hits verified
- [ ] Models tiered per task; effort controls used before downgrading quality
- [ ] Batch API used for non-urgent bulk work
- [ ] Response or artifact caching with model and prompt version in the key; never cross-tenant
- [ ] Budgets enforced per request, per tenant per day, and globally — blocking, not advisory
- [ ] One structured record per call with tokens, cost, attempt, and feature attribution
- [ ] Cost per successful task tracked, not just cost per call
- [ ] Alerts on spend jumps, cache-hit collapse, and retry-rate rise
- [ ] Computed spend reconciled against the provider invoice monthly
