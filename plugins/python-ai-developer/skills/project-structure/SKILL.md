---
description: Project layout and configuration for Python AI services — src layout, module boundaries that keep provider SDKs at the edge, typed settings with pydantic-settings, secrets handling, structured logging and tracing, ruff and mypy configuration, pytest layout, and the pyproject.toml that ties it together.
---

# Project structure and configuration

Goal of this skill: a layout where the AI-specific parts — prompts, provider clients, model choices — are **replaceable details at the edge**, not assumptions threaded through every module.

Use this skill when starting a Python AI service, when provider SDK imports have spread through the codebase, when configuration is read from `os.environ` in twenty places, or when tests need network access to run.

---

## 1. Layout

```text
my-ai-service/
├── pyproject.toml
├── uv.lock
├── .python-version
├── .env.example              # committed; .env is not
├── src/
│   └── app/
│       ├── __init__.py
│       ├── main.py           # FastAPI app factory + lifespan
│       ├── config.py         # Settings (pydantic-settings)
│       ├── logging.py        # structured logging setup
│       ├── api/              # HTTP layer only
│       │   ├── deps.py       # dependency providers
│       │   ├── errors.py     # exception handlers
│       │   └── routers/
│       ├── domain/           # pure logic — no SDK, no I/O, no framework
│       │   ├── models.py
│       │   └── services.py
│       ├── llm/              # provider adapters behind one protocol
│       │   ├── base.py       # Protocol + shared types
│       │   ├── openai.py
│       │   ├── anthropic.py
│       │   ├── gemini.py
│       │   ├── grok.py
│       │   ├── mistral.py
│       │   └── registry.py
│       ├── prompts/          # versioned prompt templates
│       ├── ocr/              # OCR engine adapters
│       ├── ml/               # model loading + inference
│       ├── solvers/          # OR models
│       └── infra/            # db, cache, queue, object storage
├── tests/
│   ├── unit/
│   ├── integration/
│   └── fixtures/             # recorded provider responses
├── notebooks/
├── docker/
└── .vscode/ · .idea/         # see `ide-setup`
```

### The rules that matter

- **`src/` layout, not a flat package.** It forces the installed package to be importable, so tests exercise what ships rather than the working directory.
- **`domain/` imports nothing from `llm/`, `api/`, or `infra/`.** It defines the interfaces; the edges implement them. This is what makes providers swappable and the core testable without network access.
- **Provider SDKs are imported in exactly one module each.** If `import anthropic` appears in a router, the abstraction has already leaked.
- **Prompts are files, not string literals scattered in functions.** They need versioning and diffing (`llm-testing-and-evals`).
- **One place constructs clients**, wired at startup (`fastapi` lifespan) and injected — never constructed per request.

Enforce the import direction mechanically rather than by memory:

```toml
[tool.ruff.lint.flake8-tidy-imports.banned-api]
"openai".msg = "Import provider SDKs only in app.llm.<provider>"
"anthropic".msg = "Import provider SDKs only in app.llm.<provider>"
```

---

## 2. Settings

One typed settings object, loaded once, injected everywhere. Never call `os.environ` outside `config.py`.

```python
# src/app/config.py
from functools import lru_cache
from typing import Literal

from pydantic import Field, SecretStr, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_nested_delimiter="__",
        extra="forbid",          # unknown env vars are a startup error, not a mystery
    )

    env: Literal["local", "test", "staging", "prod"] = "local"
    log_level: str = "INFO"

    # Secrets: SecretStr keeps them out of logs and repr()
    openai_api_key: SecretStr | None = None
    anthropic_api_key: SecretStr | None = None
    gemini_api_key: SecretStr | None = None
    xai_api_key: SecretStr | None = None
    mistral_api_key: SecretStr | None = None

    # Model ids are configuration, never literals in code — they change often
    default_provider: Literal["openai", "anthropic", "gemini", "grok", "mistral"] = "anthropic"
    model_default: str = "claude-opus-5"
    model_cheap: str = "claude-haiku-4-5"

    request_timeout_s: float = 60.0
    max_retries: int = 3
    llm_budget_usd_per_day: float = Field(default=50.0, ge=0)

    @model_validator(mode="after")
    def _require_key_for_default_provider(self) -> "Settings":
        key_field = {
            "openai": "openai_api_key",
            "anthropic": "anthropic_api_key",
            "gemini": "gemini_api_key",
            "grok": "xai_api_key",
            "mistral": "mistral_api_key",
        }[self.default_provider]
        if getattr(self, key_field) is None:
            raise ValueError(f"default_provider={self.default_provider} but {key_field} is unset")
        return self


@lru_cache
def get_settings() -> Settings:
    return Settings()
```

| Rule | Reason |
|------|--------|
| `SecretStr` for every credential | Keeps keys out of tracebacks, logs, and `/debug` endpoints |
| `extra="forbid"` | A typo'd env var fails at startup instead of being silently ignored |
| Validate cross-field consistency at startup | Fail fast, before the first request |
| Model IDs in settings, not in code | Provider model IDs change frequently; a redeploy should not be a code change |
| `.env.example` committed, `.env` git-ignored | Onboarding without leaking secrets |
| In production, read from the platform's secret store | `.env` files are a local-development convenience |

---

## 3. Logging and tracing

AI services fail in ways plain logs cannot explain — a slow provider, a retried call, a token spike. Log structurally from day one.

```python
# src/app/logging.py
import logging, sys, json, time
from contextvars import ContextVar

request_id: ContextVar[str] = ContextVar("request_id", default="-")


class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        payload = {
            "ts": time.time(),
            "level": record.levelname,
            "logger": record.name,
            "msg": record.getMessage(),
            "request_id": request_id.get(),
        }
        if record.exc_info:
            payload["exc"] = self.formatException(record.exc_info)
        payload.update(getattr(record, "extra_fields", {}))
        return json.dumps(payload)
```

Log per LLM call: provider, model, latency, input tokens, output tokens, cached tokens, cost estimate, attempt number, and a stable `request_id` — never the full prompt or completion by default (they contain user data). See `llm-reliability-and-cost`.

---

## 4. Tooling configuration

```toml
[tool.ruff]
line-length = 100
src = ["src"]

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP", "B", "A", "C4", "SIM", "TID", "PTH", "RUF", "ASYNC", "S"]
ignore = ["E501"]

[tool.ruff.lint.per-file-ignores]
"tests/*" = ["S101"]            # assert is fine in tests

[tool.mypy]
python_version = "3.12"
strict = true
files = ["src", "tests"]

[[tool.mypy.overrides]]
module = ["pytesseract.*", "pdf2image.*", "ortools.*"]
ignore_missing_imports = true

[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
addopts = "-q --strict-markers --strict-config"
markers = [
    "integration: hits real external services; excluded by default",
    "llm: calls a real model provider; costs money",
]

[tool.coverage.run]
source = ["src"]
branch = true
```

Default the test run to unit tests only — `pytest -m "not integration and not llm"` — so the suite stays fast, offline, and free. The `ASYNC` and `S` ruff rules earn their place here specifically: `ASYNC` catches blocking calls inside `async def` (the most common FastAPI performance bug), and `S` catches hardcoded secrets and unsafe subprocess use.

---

## 5. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Flat layout without `src/` | Tests import the working directory, not the installed package |
| `os.environ[...]` scattered through modules | Configuration is undiscoverable and untestable |
| Provider SDK imported in routers or domain code | Swapping providers becomes a refactor |
| Model IDs hardcoded in code | A provider deprecation becomes an emergency release |
| Secrets as plain `str` | Keys leak into tracebacks and logs |
| Clients constructed per request | Connection pools destroyed; latency and file-descriptor churn |
| Prompts as inline string literals | No versioning, no diffing, no evaluation |
| Unit tests that need network | Slow, flaky, expensive, unusable in CI |
| `extra="allow"` on settings | Typo'd env vars silently ignored |
| Logging full prompts and completions by default | User data in log storage |

---

## 6. Checklist

- [ ] `src/` layout with the package installed into the environment
- [ ] `domain/` free of framework and SDK imports; direction enforced by lint rules
- [ ] Each provider SDK imported in exactly one adapter module
- [ ] One `Settings` object; no `os.environ` outside `config.py`
- [ ] Secrets typed `SecretStr`; `extra="forbid"`; startup validation of required keys
- [ ] Model IDs configurable, not literals
- [ ] `.env.example` committed; `.env` ignored; production secrets from the platform store
- [ ] Structured JSON logging with a request-scoped correlation id
- [ ] Per-call LLM metrics logged; prompt content excluded by default
- [ ] ruff (with `ASYNC` and `S`) and strict mypy configured and passing
- [ ] Tests split into unit / integration / llm markers; default run is offline and free
