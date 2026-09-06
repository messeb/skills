---
description: FastAPI for AI services — app factory and lifespan-managed clients, routers and dependency injection, Pydantic v2 request/response models, async discipline and the blocking-call trap, error handling with RFC 9457 problem details, file uploads for OCR, SSE streaming of model output, middleware, health and readiness probes, and OpenAPI hygiene.
---

# FastAPI for AI services

Goal of this skill: an API whose slow, failure-prone AI work is isolated behind clean boundaries — typed at the edge, async where it matters, and observable when a provider degrades.

Use this skill when building or auditing a FastAPI service that calls model providers, runs OCR, or serves ML inference.

---

## 1. App factory and lifespan

Construct expensive clients **once**, at startup, and put them on `app.state`. Creating an HTTP client per request destroys connection pooling and is the most common cause of latency and file-descriptor exhaustion in AI services.

```python
# src/app/main.py
from contextlib import asynccontextmanager
from collections.abc import AsyncIterator

from fastapi import FastAPI

from app.config import get_settings
from app.llm.registry import build_llm_registry
from app.api.errors import install_exception_handlers
from app.api.routers import chat, documents, health


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    settings = get_settings()
    app.state.settings = settings
    app.state.llm = build_llm_registry(settings)      # provider clients, pooled
    app.state.ml = load_models(settings)              # warm the model cache
    try:
        yield
    finally:
        await app.state.llm.aclose()


def create_app() -> FastAPI:
    app = FastAPI(
        title="AI Service",
        version="1.0.0",
        lifespan=lifespan,
        docs_url="/docs" if get_settings().env != "prod" else None,
    )
    install_exception_handlers(app)
    app.include_router(health.router)
    app.include_router(chat.router, prefix="/v1")
    app.include_router(documents.router, prefix="/v1")
    return app


app = create_app()
```

An app **factory** (rather than a module-level `app` built with side effects) is what lets tests build an app with stub clients.

---

## 2. Dependencies

```python
# src/app/api/deps.py
from typing import Annotated

from fastapi import Depends, Request

from app.config import Settings
from app.llm.base import LLMClient


def get_settings_dep(request: Request) -> Settings:
    return request.app.state.settings


def get_llm(request: Request) -> LLMClient:
    return request.app.state.llm.default()


SettingsDep = Annotated[Settings, Depends(get_settings_dep)]
LLMDep = Annotated[LLMClient, Depends(get_llm)]
```

Routes then depend on the `LLMClient` **protocol**, never on a concrete SDK. Overriding one dependency in tests swaps the entire provider layer:

```python
app.dependency_overrides[get_llm] = lambda: FakeLLM(scripted_replies)
```

Use `yield` dependencies for per-request resources (a DB session), and plain returns for shared singletons.

---

## 3. Request and response models

```python
from typing import Annotated, Literal
from pydantic import BaseModel, Field, StringConstraints

Prompt = Annotated[str, StringConstraints(min_length=1, max_length=8000, strip_whitespace=True)]


class ChatRequest(BaseModel):
    model_config = {"extra": "forbid"}          # reject unknown fields loudly

    prompt: Prompt
    provider: Literal["openai", "anthropic", "gemini", "grok", "mistral"] | None = None
    temperature: float = Field(default=0.2, ge=0.0, le=2.0)
    max_output_tokens: int = Field(default=1024, ge=1, le=32_000)


class Usage(BaseModel):
    input_tokens: int
    output_tokens: int
    cached_input_tokens: int = 0
    cost_usd: float


class ChatResponse(BaseModel):
    text: str
    model: str
    usage: Usage
    request_id: str
```

Rules: `extra="forbid"` on inbound models; explicit bounds on anything that maps to cost (`max_output_tokens`, page counts, batch sizes) — an unbounded integer from a client is a billing incident; `response_model=` on every route so responses are validated and documented; and a `Usage` block on AI responses so callers can see what they spent.

---

## 4. Async discipline

FastAPI runs `async def` handlers on the event loop and `def` handlers in a thread pool. Getting this wrong is the dominant performance bug in Python AI services.

| Situation | Write |
|-----------|-------|
| Awaiting an async SDK or `httpx.AsyncClient` | `async def` |
| Calling a **sync** SDK, `pytesseract`, scikit-learn, a solver | `def` (FastAPI threads it) **or** `await anyio.to_thread.run_sync(fn)` inside `async def` |
| CPU-heavy work (inference, PDF rasterisation, solving) | Offload to a process pool or a task queue — see `async-and-background-work` |
| Fan-out to several providers | `async def` + `asyncio.gather` |

```python
import anyio

@router.post("/ocr")
async def run_ocr(file: UploadFile) -> OcrResponse:
    data = await file.read()
    # Blocking C extension — never call this directly on the event loop
    text = await anyio.to_thread.run_sync(extract_text, data)
    return OcrResponse(text=text)
```

**The trap**: one blocking call inside `async def` stalls *every* concurrent request on that worker, not just the current one. Enable ruff's `ASYNC` rules to catch the common cases mechanically, and keep `time.sleep`, `requests`, and sync SDK clients out of `async def` entirely.

---

## 5. Errors

Map failures to stable, typed responses. Use RFC 9457 problem details so clients can branch on `type` rather than parsing prose.

```python
# src/app/api/errors.py
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from app.llm.base import ProviderTimeout, ProviderRateLimited, ProviderRefused, BudgetExceeded

PROBLEM = "application/problem+json"

_MAP = {
    ProviderTimeout:     (504, "provider-timeout",   True),
    ProviderRateLimited: (429, "provider-rate-limit", True),
    ProviderRefused:     (422, "content-refused",     False),
    BudgetExceeded:      (429, "budget-exceeded",     False),
}


def install_exception_handlers(app: FastAPI) -> None:
    for exc_type, (status, slug, retriable) in _MAP.items():
        app.add_exception_handler(exc_type, _handler(status, slug, retriable))


def _handler(status: int, slug: str, retriable: bool):
    async def handle(request: Request, exc: Exception) -> JSONResponse:
        return JSONResponse(
            status_code=status,
            media_type=PROBLEM,
            content={
                "type": f"https://errors.example.com/{slug}",
                "title": slug.replace("-", " "),
                "status": status,
                "detail": str(exc),
                "instance": request.headers.get("x-request-id", "-"),
                "retriable": retriable,
            },
        )
    return handle
```

Never leak a provider's raw error text to clients — it can contain prompt fragments, internal URLs, and account identifiers. Translate at the adapter boundary (`provider-abstraction`).

---

## 6. File uploads for OCR and documents

```python
from fastapi import UploadFile, File, HTTPException

MAX_BYTES = 25 * 1024 * 1024
ALLOWED = {"application/pdf", "image/png", "image/jpeg", "image/tiff"}


@router.post("/documents:extract", response_model=ExtractResponse)
async def extract(file: Annotated[UploadFile, File()]) -> ExtractResponse:
    if file.content_type not in ALLOWED:
        raise HTTPException(415, "unsupported media type")

    size, chunks = 0, []
    while chunk := await file.read(1 << 20):        # stream; never file.read() a whole PDF
        size += len(chunk)
        if size > MAX_BYTES:
            raise HTTPException(413, "file too large")
        chunks.append(chunk)
    ...
```

Validate the **content**, not just the declared `content_type` — check magic bytes, and cap page count before rasterising. A 2-page-looking PDF that expands to 4,000 pages is a denial-of-service vector for any OCR endpoint.

---

## 7. Streaming model output (SSE)

```python
import json
from fastapi.responses import StreamingResponse


@router.post("/chat:stream")
async def chat_stream(body: ChatRequest, llm: LLMDep, request: Request) -> StreamingResponse:
    async def events():
        try:
            async for delta in llm.stream(body.prompt, max_output_tokens=body.max_output_tokens):
                if await request.is_disconnected():   # stop paying for an abandoned request
                    break
                yield f"event: delta\ndata: {json.dumps({'text': delta})}\n\n"
            yield "event: done\ndata: {}\n\n"
        except Exception as exc:                       # never let the stream die silently
            yield f"event: error\ndata: {json.dumps({'message': type(exc).__name__})}\n\n"

    return StreamingResponse(
        events(),
        media_type="text/event-stream",
        headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"},
    )
```

| Rule | Why |
|------|-----|
| Check `request.is_disconnected()` | The user closed the tab; stop generating and stop billing |
| Emit a terminal `done` **and** an `error` event | HTTP status is already sent; failure must be in-band |
| `X-Accel-Buffering: no` | Otherwise nginx buffers the whole stream and the UX benefit disappears |
| Send usage in the final event | Clients cannot read trailers reliably |
| Keep a heartbeat if generation can pause >30 s | Proxies close idle connections |

---

## 8. Middleware, health, and OpenAPI

- **Request id**: accept `X-Request-Id` or generate one; put it in a `ContextVar` so every log line and provider call carries it.
- **Timing**: record duration per route; AI routes need per-provider histograms, not just a global average.
- **CORS**: explicit origins; never `allow_origins=["*"]` together with credentials.
- **Body size limit**: enforce at the proxy as well as in the handler.
- **Health**: `/healthz` is liveness — process is up, no dependencies checked. `/readyz` is readiness — models loaded, provider keys present, DB reachable. Never call a paid provider in a health check; probe at your process boundary instead.
- **OpenAPI**: give every route an `operation_id`, tags, and response models so generated clients are usable. Disable `/docs` in production unless it is deliberately public.

---

## 9. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Client constructed inside the handler | No connection reuse; latency and FD churn |
| Blocking call inside `async def` | Every concurrent request on that worker stalls |
| Long LLM/OCR work inline in a request | Gateway timeouts, retries that duplicate paid work |
| Unbounded `max_tokens` / page count from the client | Cost and DoS exposure |
| Raw provider errors returned to clients | Leaks prompts, URLs, account details |
| `dict` responses instead of `response_model` | Undocumented, unvalidated API |
| Provider SDK imported in a router | Provider swap becomes a refactor |
| Health check that calls the LLM | Paid, flaky, and cascades outages |
| Streaming without disconnect detection | You pay for output nobody receives |
| `extra="allow"` on request models | Typos silently ignored; forward-compat bugs |
| `/docs` public in production | Free reconnaissance of your API surface |

---

## 10. Checklist

- [ ] App factory plus `lifespan`; clients built once and closed on shutdown
- [ ] Routes depend on protocols via `Depends`, never on concrete SDKs
- [ ] `extra="forbid"` on request models; bounds on every cost-bearing field
- [ ] `response_model` on every route; `Usage` returned on AI routes
- [ ] Sync/blocking work threaded or offloaded; ruff `ASYNC` rules enabled
- [ ] Long jobs moved to the background with a status endpoint
- [ ] Errors mapped to problem+json with a stable `type` and a `retriable` flag
- [ ] Uploads streamed, size-capped, content-validated, page-count-capped
- [ ] SSE emits terminal `done`/`error`, checks disconnects, disables proxy buffering
- [ ] Request id propagated into logs and provider calls
- [ ] Liveness and readiness separated; no paid calls in probes
- [ ] `/docs` disabled in production; `operation_id` set on every route
