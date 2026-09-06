---
description: One interface over many LLM providers — a Protocol-based client with normalized message, usage, and error types; adapter structure per provider; a registry and routing policy with fallback; when to build your own layer versus adopting a gateway such as LiteLLM; capability negotiation instead of lowest-common-denominator design; and testing adapters with recorded fixtures.
---

# Provider abstraction

Goal of this skill: make the provider a **runtime decision** — swappable per task, per tenant, or per failure — while keeping vendor differences confined to five small adapter modules.

Use this skill when more than one provider is in play, when you need fallback during an outage, when routing cheap work to cheap models, or when provider SDK calls have started appearing outside the adapter layer.

Do **not** build an abstraction over a single provider you have no intention of leaving; that is speculative indirection. Build it when the second provider arrives, or when fallback is a requirement.

---

## 1. The interface

Define behaviour in your own vocabulary, not the union of five SDKs.

```python
# src/app/llm/base.py
from collections.abc import AsyncIterator, Sequence
from dataclasses import dataclass
from typing import Any, Protocol, TypeVar

from pydantic import BaseModel

T = TypeVar("T", bound=BaseModel)


@dataclass(frozen=True)
class Message:
    role: str                      # "user" | "assistant" | "tool"
    content: str
    name: str | None = None


@dataclass(frozen=True)
class Usage:
    input_tokens: int
    output_tokens: int
    cached_input_tokens: int = 0
    reasoning_tokens: int = 0


@dataclass(frozen=True)
class Completion:
    text: str
    model: str
    provider: str
    usage: Usage
    finish_reason: str             # "stop" | "length" | "tool_use" | "refusal" | "filtered"
    raw: Any = None                # vendor object, for debugging only — never read in business logic


class LLMError(Exception): ...
class ProviderAuthError(LLMError): ...
class ProviderRateLimited(LLMError): ...
class ProviderUnavailable(LLMError): ...
class ProviderTimeout(LLMError): ...
class ProviderBadRequest(LLMError): ...
class ProviderRefused(LLMError): ...
class BudgetExceeded(LLMError): ...


class LLMClient(Protocol):
    name: str
    supports: frozenset[str]       # {"tools", "json_schema", "vision", "caching", "streaming"}

    async def complete(
        self, messages: Sequence[Message], *, system: str | None = None,
        max_output_tokens: int = 1024, temperature: float = 0.2,
    ) -> Completion: ...

    async def stream(
        self, messages: Sequence[Message], *, system: str | None = None,
        max_output_tokens: int = 1024,
    ) -> AsyncIterator[str]: ...

    async def parse(
        self, messages: Sequence[Message], *, schema: type[T], system: str | None = None,
    ) -> tuple[T, Usage]: ...

    async def aclose(self) -> None: ...
```

Use `Protocol`, not an abstract base class: adapters do not need to inherit anything, and test doubles are ordinary classes.

Keep `raw` for debugging and logging only. The moment business logic reads `completion.raw["choices"][0]`, the abstraction is dead.

---

## 2. An adapter

```python
# src/app/llm/anthropic.py
import anthropic
from collections.abc import Sequence

from app.llm.base import Completion, LLMClient, Message, Usage, ProviderRateLimited, \
    ProviderTimeout, ProviderUnavailable, ProviderBadRequest, ProviderAuthError

_FINISH = {"end_turn": "stop", "max_tokens": "length",
           "tool_use": "tool_use", "refusal": "refusal", "stop_sequence": "stop"}


class AnthropicClient:
    name = "anthropic"
    supports = frozenset({"tools", "json_schema", "vision", "caching", "streaming"})

    def __init__(self, api_key: str, model: str, timeout: float = 60.0) -> None:
        self._c = anthropic.AsyncAnthropic(api_key=api_key, timeout=timeout, max_retries=0)
        self._model = model

    async def complete(self, messages: Sequence[Message], *, system: str | None = None,
                       max_output_tokens: int = 1024, temperature: float = 0.2) -> Completion:
        try:
            r = await self._c.messages.create(
                model=self._model,
                max_tokens=max_output_tokens,          # required by this provider
                system=system or anthropic.NOT_GIVEN,
                messages=[{"role": m.role, "content": m.content} for m in messages],
            )
        except anthropic.AuthenticationError as e:
            raise ProviderAuthError(str(e)) from e
        except anthropic.RateLimitError as e:
            raise ProviderRateLimited(str(e)) from e
        except anthropic.APITimeoutError as e:
            raise ProviderTimeout(str(e)) from e
        except anthropic.BadRequestError as e:
            raise ProviderBadRequest(str(e)) from e
        except anthropic.APIStatusError as e:
            raise ProviderUnavailable(str(e)) from e

        text = "".join(b.text for b in r.content if b.type == "text")
        return Completion(
            text=text, model=r.model, provider=self.name,
            usage=Usage(
                input_tokens=r.usage.input_tokens,
                output_tokens=r.usage.output_tokens,
                cached_input_tokens=getattr(r.usage, "cache_read_input_tokens", 0) or 0,
            ),
            finish_reason=_FINISH.get(r.stop_reason or "", "stop"),
            raw=r,
        )

    async def aclose(self) -> None:
        await self._c.close()
```

Every adapter does the same four jobs: **translate the request**, **translate the response**, **translate the errors**, and **declare its capabilities**. Nothing else belongs there — no retry logic, no budget checks, no prompt construction.

---

## 3. Registry, routing, and fallback

Keep policy out of the adapters and out of the handlers.

```python
# src/app/llm/registry.py
class LLMRegistry:
    def __init__(self, clients: dict[str, LLMClient], routes: dict[str, list[str]]) -> None:
        self._clients, self._routes = clients, routes

    def for_task(self, task: str) -> LLMClient:
        return self._clients[self._routes[task][0]]

    async def complete_with_fallback(self, task: str, **kw) -> Completion:
        last: Exception | None = None
        for provider in self._routes[task]:
            try:
                return await self._clients[provider].complete(**kw)
            except (ProviderUnavailable, ProviderTimeout, ProviderRateLimited) as e:
                last = e
                continue                       # transient — try the next provider
            except (ProviderBadRequest, ProviderRefused):
                raise                          # deterministic — the next provider will fail too
        raise ProviderUnavailable("all providers failed") from last
```

```toml
# routes, in config
[llm.routes]
chat        = ["anthropic", "openai"]
extraction  = ["openai", "mistral"]
classify    = ["mistral"]            # cheap model, cheap task
vision      = ["gemini", "anthropic"]
```

Fallback rules that matter:

- **Only fail over on transient errors.** A 400 or a refusal will fail identically on the next provider — retrying costs money and hides the bug.
- **Fallback changes the output distribution.** Record which provider served each response; do not silently mix providers in an evaluation set.
- **Cap the total deadline** across the chain, not per provider.
- **Do not fail over mid-stream** unless the client can handle a restart — you will have already billed for the partial output.

---

## 4. Capability negotiation, not lowest common denominator

The failure mode of a bad abstraction is reducing every provider to the weakest one. Instead, declare capabilities and adapt:

```python
async def extract(client: LLMClient, text: str, schema: type[T]) -> T:
    if "json_schema" in client.supports:
        obj, _ = await client.parse([Message("user", text)], schema=schema)
        return obj
    # Fallback path: prompt for JSON, then validate and repair
    return await _parse_via_prompt(client, text, schema)
```

This keeps provider-specific *strengths* (native schema enforcement, prompt caching, thinking control) available where they exist, with a defined degradation elsewhere — rather than never using any of them.

---

## 5. Build your own, or use a gateway?

| | Own thin layer | Gateway (LiteLLM, an internal proxy, a cloud router) |
|---|---|---|
| Control over types and errors | Full | Constrained to the gateway's model |
| Effort | ~200 lines per adapter | Configuration |
| New provider | You write an adapter | Often already supported |
| Provider-specific features | Available if you expose them | Whatever the gateway surfaces |
| Central budgets, keys, logging across services | You build it | Usually built in |
| Extra failure domain | None | One more hop to operate and debug |

Reasonable default: **own thin adapters** for two to five providers inside one service; **a gateway** when many services need shared key management, budgets, and routing. The two compose — a gateway can sit behind your `LLMClient` protocol as one more adapter.

---

## 6. Testing adapters

- **Unit-test the translation**, not the network: feed a recorded vendor response object into the mapping code and assert the `Completion`.
- **Record fixtures once** against the real API (`pytest -m llm`), commit the sanitised JSON, and replay it in CI. See `llm-testing-and-evals`.
- **Contract-test every adapter with the same suite** so all five satisfy the same protocol.
- **Test the error mapping explicitly** — construct each vendor exception and assert the local type and its retriable classification.
- **Test the fallback policy with fakes**, not with real outages: a fake that raises `ProviderUnavailable` twice then succeeds.

---

## 7. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Abstraction built for one provider "just in case" | Indirection with no payoff |
| Vendor request/response objects crossing the boundary | The abstraction exists on paper only |
| Business logic reading `completion.raw` | Provider swap breaks callers |
| Lowest-common-denominator interface | Caching, schema enforcement, and thinking control never used |
| Retry, budget, and prompt logic inside adapters | Duplicated five times and inconsistent |
| Fallback on 400s and refusals | Paying repeatedly for the same failure |
| Silent fallback with no record of who served the response | Unexplainable quality regressions |
| One model ID shared by all tasks | Frontier prices for trivial work |
| Vendor exceptions escaping to handlers | Error handling breaks on provider change |
| SDK retries left enabled under your own retry loop | Attempts and cost multiply |
| No contract tests across adapters | Providers drift apart in behaviour |

---

## 8. Checklist

- [ ] Interface defined as a `Protocol` in your own vocabulary
- [ ] Normalised `Message`, `Usage`, `Completion`, and error taxonomy with a retriable flag
- [ ] One adapter per provider; vendor SDK imported nowhere else
- [ ] Adapters only translate — no retry, budget, or prompt logic
- [ ] Vendor exceptions mapped exhaustively, including refusals
- [ ] Capabilities declared per adapter and negotiated, not reduced
- [ ] Routing table in configuration, per task tier
- [ ] Fallback only on transient errors, with a total deadline and a recorded serving provider
- [ ] Streaming fallback behaviour decided explicitly
- [ ] Same contract test suite runs against every adapter
- [ ] Error-mapping and fallback-policy tests use fakes, not the network
- [ ] Recorded fixtures sanitised of keys and user data before committing
