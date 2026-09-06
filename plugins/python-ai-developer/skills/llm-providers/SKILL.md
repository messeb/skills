---
description: The five providers in practice — OpenAI, Anthropic, Google Gemini, xAI Grok, and Mistral. SDK and client setup for each, how model IDs should be resolved and pinned rather than hardcoded from memory, the capability matrix (streaming, tools, structured output, vision, caching, batch), which providers expose OpenAI-compatible endpoints and where that compatibility ends, token and cost accounting, and per-provider error surfaces.
---

# LLM providers: OpenAI, Anthropic, Gemini, Grok, Mistral

Goal of this skill: know what each provider's Python SDK actually gives you, where the APIs genuinely differ, and how to keep those differences at one boundary instead of in your business logic.

Use this skill when adding a provider, choosing one per task, debugging provider-specific behaviour, or estimating cost. Pair it with `provider-abstraction`, which defines the interface these adapters implement.

---

## 1. Model IDs are configuration, not code

Provider model identifiers change often — new models ship, old ones are deprecated on a schedule, and IDs recalled from training data are frequently wrong or stale. Two rules:

1. **Never hardcode a model ID in application code.** Put it in settings (`project-structure`), so a deprecation is a config change and not a release.
2. **Resolve the current list from the provider at setup time**, and record what you pinned:

```bash
# Each provider exposes a models listing; use it rather than memory.
python -c "from openai import OpenAI; print([m.id for m in OpenAI().models.list()])"
python -c "import anthropic; print([m.id for m in anthropic.Anthropic().models.list()])"
python -c "from mistralai import Mistral; import os; print([m.id for m in Mistral(api_key=os.environ['MISTRAL_API_KEY']).models.list().data])"
```

For **Anthropic**, the current model IDs at the time of writing are `claude-opus-5`, `claude-sonnet-5`, and `claude-haiku-4-5` (plus `claude-fable-5`); use the exact string with no date suffix, and default to `claude-opus-5` unless you have a reason to downgrade. For the other four providers, resolve IDs from their models endpoint or current docs — do not copy identifiers out of a blog post or a model's own recollection.

Record in your config which model each *task* uses, not one global model: extraction, chat, and cheap classification usually want different tiers.

---

## 2. Client setup per provider

All five ship first-party Python SDKs with sync and async clients. Construct once at startup (`fastapi` lifespan), reuse the connection pool, and set an explicit timeout — every SDK's default is far longer than you want.

### OpenAI

```python
from openai import AsyncOpenAI

client = AsyncOpenAI(api_key=settings.openai_api_key.get_secret_value(),
                     timeout=60.0, max_retries=0)   # retries owned by our policy

resp = await client.responses.create(
    model=settings.model_default,
    input="Summarize this contract clause: ...",
    max_output_tokens=1024,
)
text = resp.output_text
```

OpenAI has two generations of API: the older **Chat Completions** (`client.chat.completions.create`, `messages=[...]`) and the newer **Responses** API (`client.responses.create`, `input=...`). Chat Completions remains the de-facto compatibility standard that other vendors emulate; Responses is the richer surface. Pick one per adapter and be explicit about which — mixing them in one codebase is a common source of confusion.

### Anthropic

```python
import anthropic

client = anthropic.AsyncAnthropic(api_key=settings.anthropic_api_key.get_secret_value(),
                                  timeout=60.0, max_retries=0)

resp = await client.messages.create(
    model="claude-opus-5",
    max_tokens=4096,                       # required, unlike other providers
    system="You extract structured data from contracts.",
    messages=[{"role": "user", "content": "..."}],
)
text = next(b.text for b in resp.content if b.type == "text")
```

Anthropic specifics worth knowing: `max_tokens` is **required**; the system prompt is a **top-level parameter**, not a message; `resp.content` is a list of typed blocks (`text`, `thinking`, `tool_use`) that you must narrow by `.type`; and current models support adaptive thinking via `thinking={"type": "adaptive"}` with depth controlled by `output_config={"effort": "low"|"medium"|"high"|"xhigh"|"max"}`. For values of `max_tokens` above roughly 16k, stream — non-streaming requests can hit HTTP timeouts.

### Google Gemini

```python
from google import genai
from google.genai import types

client = genai.Client(api_key=settings.gemini_api_key.get_secret_value())

resp = await client.aio.models.generate_content(
    model=settings.model_default,
    contents="Summarize this contract clause: ...",
    config=types.GenerateContentConfig(
        system_instruction="You extract structured data from contracts.",
        max_output_tokens=1024,
        temperature=0.2,
    ),
)
text = resp.text
```

Gemini specifics: the async surface lives under `client.aio`; generation parameters go in a `GenerateContentConfig` object rather than as keyword arguments; safety settings can block a response, so check `resp.candidates[0].finish_reason` before trusting `resp.text`; and the same SDK targets both the Gemini Developer API and Vertex AI (`genai.Client(vertexai=True, project=..., location=...)`), which is the usual production path on GCP.

### xAI Grok

```python
from openai import AsyncOpenAI

client = AsyncOpenAI(
    api_key=settings.xai_api_key.get_secret_value(),
    base_url="https://api.x.ai/v1",
    timeout=60.0, max_retries=0,
)
resp = await client.chat.completions.create(
    model=settings.model_default,
    messages=[{"role": "user", "content": "..."}],
)
```

xAI exposes an OpenAI-compatible Chat Completions endpoint, so the OpenAI SDK with a `base_url` override is the standard integration path; xAI also publishes its own SDK. Compatibility covers the core request shape — it does not guarantee identical behaviour for tool calling, structured output, or usage fields. Verify each capability you rely on rather than assuming parity.

### Mistral

```python
from mistralai import Mistral

client = Mistral(api_key=settings.mistral_api_key.get_secret_value())

resp = await client.chat.complete_async(
    model=settings.model_default,
    messages=[{"role": "user", "content": "..."}],
    max_tokens=1024,
)
text = resp.choices[0].message.content
```

Mistral's SDK uses `complete_async` for the async path and returns an OpenAI-shaped `choices[0].message` structure. Mistral also offers document/OCR-oriented endpoints, which are worth comparing against dedicated OCR engines (`ocr`) rather than assuming either is better.

---

## 3. Capability matrix

Verify these against current provider docs before relying on them; capabilities move faster than any document.

| Capability | OpenAI | Anthropic | Gemini | Grok | Mistral |
|---|---|---|---|---|---|
| Streaming | ✅ | ✅ | ✅ | ✅ | ✅ |
| Tool / function calling | ✅ | ✅ | ✅ | ✅ | ✅ |
| Parallel tool calls | ✅ | ✅ (default) | ✅ | ✅ | ✅ |
| Schema-constrained output | ✅ | ✅ | ✅ | partial | ✅ |
| Vision input | ✅ | ✅ | ✅ | ✅ | model-dependent |
| Native PDF input | via Files | ✅ (document block) | ✅ | — | ✅ |
| Prompt / context caching | ✅ | ✅ (explicit `cache_control`) | ✅ (explicit) | — | — |
| Batch API (discounted) | ✅ | ✅ | ✅ | — | ✅ |
| Reasoning / thinking control | ✅ (effort) | ✅ (adaptive + effort) | ✅ (thinking budget) | model-dependent | model-dependent |
| Embeddings | ✅ | — | ✅ | — | ✅ |
| Hosted web search tool | ✅ | ✅ | ✅ | ✅ | — |
| Self-hostable open weights | — | — | — | — | ✅ |

Two capability gaps drive most architecture decisions: **Anthropic has no embeddings endpoint** (pair it with another provider or a local model for retrieval), and **only Mistral offers open weights** you can self-host when data residency forbids a hosted API.

---

## 4. Where the differences actually bite

| Concern | Reality |
|---------|---------|
| **System prompt** | Anthropic: top-level `system`. OpenAI/Grok/Mistral: a message with `role: "system"` (or `instructions` on Responses). Gemini: `system_instruction` in the config |
| **`max_tokens`** | Required on Anthropic; optional elsewhere; named `max_output_tokens` on OpenAI Responses and Gemini |
| **Response shape** | Anthropic returns a *list of typed blocks*; the others return a message with a string (plus tool calls) |
| **Multi-modal input** | Every provider has a different content-part shape for images and documents |
| **Finish/stop reason** | Different vocabularies (`stop`/`end_turn`/`STOP`), and different signals for refusal, length, and tool use |
| **Usage fields** | Different names, and cached tokens are reported differently — normalise before summing |
| **Rate limits** | Different units (requests, tokens, or both) and different headers; read the headers rather than guessing |
| **Caching** | Anthropic and Gemini require explicit cache markers; OpenAI caches long prefixes automatically |
| **Refusals** | A distinct stop reason on some providers, an ordinary message on others — detect both |

This table is the argument for `provider-abstraction`: the differences are real, numerous, and unstable, so they belong in five small adapters rather than in your handlers.

---

## 5. Tokens and cost

```python
class Usage(BaseModel):
    input_tokens: int
    output_tokens: int
    cached_input_tokens: int = 0
    reasoning_tokens: int = 0

    def cost_usd(self, price: "ModelPrice") -> float:
        billed_input = self.input_tokens - self.cached_input_tokens
        return (
            billed_input * price.input_per_mtok
            + self.cached_input_tokens * price.cached_input_per_mtok
            + (self.output_tokens + self.reasoning_tokens) * price.output_per_mtok
        ) / 1_000_000
```

Rules: normalise every provider's usage into one shape at the adapter; keep prices in a config table keyed by `(provider, model)` with a `valid_from` date, not scattered constants; count **reasoning tokens as output** — they are billed and invisible in the text; and prefer the provider's own token counter (for example Anthropic's `client.messages.count_tokens`) over `tiktoken`, which only models OpenAI's tokenizer and will be wrong for the other four.

---

## 6. Errors

Each SDK raises its own exception types. Translate them into your own taxonomy in the adapter (`provider-abstraction`) so callers never catch a vendor class:

| Vendor surface | Map to |
|---|---|
| 401 / invalid key | `ProviderAuthError` — not retriable, alert |
| 429 / quota | `ProviderRateLimited` — retriable, honour `Retry-After` |
| 5xx / overloaded | `ProviderUnavailable` — retriable with backoff |
| Timeout / connection | `ProviderTimeout` — retriable, but see the streaming caveat in `async-and-background-work` |
| 400 / schema or context-length | `ProviderBadRequest` — **not** retriable |
| Safety block or refusal stop reason | `ProviderRefused` — not retriable; try a different prompt or model deliberately |

---

## 7. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Model IDs hardcoded from memory | Wrong or deprecated IDs; an emergency release to fix a string |
| One global model for every task | Paying frontier prices for classification |
| Assuming OpenAI-compatible means behaviour-identical | Tool calling or structured output silently differs |
| Vendor exception types caught in handlers | Provider swap breaks error handling |
| `tiktoken` used to count non-OpenAI tokens | Wrong budgets and wrong truncation |
| Reasoning tokens excluded from cost | Systematic under-reporting of spend |
| SDK-level retries plus your own retry loop | Multiplied attempts and multiplied bills |
| Default SDK timeouts | A hung call holds a worker for minutes |
| Client constructed per request | No pooling; latency and FD churn |
| Ignoring `finish_reason` | Truncated output treated as a complete answer |
| Provider keys in code or images | Credential leak |

---

## 8. Checklist

- [ ] Model IDs resolved from the provider and pinned in configuration
- [ ] A model chosen per task tier, not one global default
- [ ] Clients built once at startup with explicit timeouts; SDK retries disabled in favour of one policy
- [ ] Provider SDK imported only in its adapter module
- [ ] Capability assumptions verified per provider, not inferred from compatibility claims
- [ ] Usage normalised into one shape; reasoning and cached tokens accounted for
- [ ] Prices in a dated config table keyed by provider and model
- [ ] Token counting done with the provider's own counter
- [ ] Vendor exceptions translated into a local taxonomy with a retriable flag
- [ ] `finish_reason` / `stop_reason` checked before using the output
- [ ] Keys from the secret store, never in code or images
