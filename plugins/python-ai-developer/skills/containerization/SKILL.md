---
description: Containerizing Python AI services — multi-stage Dockerfiles with uv, layer caching that survives dependency changes, non-root and security hardening, system dependencies for OCR and ML, GPU images and CUDA, model weights at build versus runtime, image size, Compose for local development with hot reload and remote debugging, health checks, and running API and workers from one image.
---

# Containerization

Goal of this skill: one image that builds fast, starts fast, runs as a non-root user, and produces the same behaviour on a laptop, in CI, and in production — including the heavy dependencies AI services drag along.

Use this skill when packaging a FastAPI AI service, when image builds are slow, when images are gigabytes, or when GPU and model weights enter the picture.

---

## 1. The base image

```dockerfile
# syntax=docker/dockerfile:1.9
ARG PYTHON_VERSION=3.12

FROM ghcr.io/astral-sh/uv:python${PYTHON_VERSION}-bookworm-slim AS builder
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=never
WORKDIR /app

# 1) Dependency layer — cached until uv.lock or pyproject.toml changes
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

# 2) Project layer — rebuilt on every source change, which is cheap
COPY src/ ./src/
COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev


FROM python:${PYTHON_VERSION}-slim-bookworm AS runtime
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/app/.venv/bin:$PATH"

# System libraries the Python packages link against (see §3)
RUN apt-get update && apt-get install -y --no-install-recommends \
        tesseract-ocr tesseract-ocr-deu poppler-utils libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r app && useradd -r -g app -u 10001 app
WORKDIR /app

COPY --from=builder --chown=app:app /app/.venv /app/.venv
COPY --from=builder --chown=app:app /app/src /app/src

USER app
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD python -c "import urllib.request;urllib.request.urlopen('http://localhost:8000/healthz')"

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

The two-step `uv sync` is the whole trick: dependencies (slow, rarely changing) and project code (fast, always changing) land in separate layers, so a code edit does not reinstall PyTorch. See `uv`.

---

## 2. What actually matters

| Rule | Reason |
|------|--------|
| Multi-stage: build tooling never reaches the runtime image | Smaller image, smaller attack surface |
| `--frozen` everywhere | The image matches the lockfile or the build fails |
| Non-root user with a fixed UID | Required by hardened clusters; predictable file ownership |
| `.dockerignore` excluding `.venv`, `.git`, `notebooks/`, data, models | Build context of hundreds of MB otherwise |
| Pin the base image by digest for production | `:slim` moves under you |
| `PYTHONUNBUFFERED=1` | Otherwise logs vanish when the container is killed |
| No secrets in `ENV` or layers | `docker history` exposes them; mount at runtime |
| One process per container | Let the orchestrator restart and scale |
| Read-only root filesystem with a writable `/tmp` | Cheap hardening |
| Handle `SIGTERM` for graceful shutdown | In-flight requests and jobs finish cleanly |

```text
# .dockerignore
.git
.venv
__pycache__
*.pyc
notebooks/
data/
models/
.pytest_cache
.mypy_cache
.ruff_cache
```

---

## 3. System dependencies

Python wheels for AI libraries link against system libraries that are absent from slim images. Missing them fails at import — or worse, silently, as with a missing OCR language pack.

| Package | Needs |
|---------|-------|
| `pytesseract` | `tesseract-ocr` plus a language pack per language (`tesseract-ocr-deu`, …) |
| `pdf2image` | `poppler-utils` |
| `opencv-python` | `libgl1`, `libglib2.0-0` (or use `opencv-python-headless` and skip them) |
| `PyMuPDF` | Usually self-contained wheels |
| `psycopg[binary]` | Self-contained; the non-binary variant needs `libpq-dev` |
| `weasyprint` / rendering | `libpango`, `libcairo2` |

Prefer headless variants (`opencv-python-headless`) in containers — they exist precisely to avoid pulling in an X stack.

Verify at build time rather than discovering it in production:

```dockerfile
RUN python -c "import cv2, pytesseract; print(pytesseract.get_languages())"
```

---

## 4. GPU images

```dockerfile
FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04 AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends python3.12 python3.12-venv \
    && rm -rf /var/lib/apt/lists/*
```

- Use the **runtime** CUDA image, not `devel`, unless you compile kernels — it is several gigabytes smaller.
- The CUDA version in the image must match what the framework wheel expects; pin the torch index accordingly (`uv`).
- Run with `--gpus all` (Docker) or the device plugin (Kubernetes); the container does not need a driver, only the toolkit.
- Verify at startup and fail loudly: a service that silently falls back to CPU inference looks like a mysterious latency regression.

```python
import torch
if settings.require_gpu and not torch.cuda.is_available():
    raise RuntimeError("GPU required but unavailable")
```

---

## 5. Model weights

| Strategy | Trade-off |
|----------|-----------|
| Bake into the image | Fast, deterministic start; huge images; a new image per model version |
| Download at startup from object storage | Small image; slower cold start; needs a cache and a checksum |
| Mount a shared volume / PVC | Small image, fast start; requires orchestrator support |
| Init container that pre-fetches | Clean separation; the app starts with weights present |

For anything above a few hundred megabytes, prefer downloading or mounting, with a local cache directory, a **checksum verification**, and a pinned revision — never "latest" from a model hub. Set `HF_HOME` (or the equivalent) to a writable cached path, and never let the first user request trigger the download.

---

## 6. Compose for local development

```yaml
services:
  api:
    build:
      context: .
      target: builder                     # dev deps available
    command: >
      python -Xfrozen_modules=off -m debugpy --listen 0.0.0.0:5678
      -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    ports: ["8000:8000", "5678:5678"]     # app + debugger
    volumes:
      - ./src:/app/src                    # hot reload
    environment:
      ENV: local
    env_file: [.env]
    depends_on:
      db: {condition: service_healthy}

  worker:
    build: {context: ., target: builder}  # same image, different command
    command: python -m app.worker
    volumes: ["./src:/app/src"]
    env_file: [.env]

  db:
    image: postgres:16-alpine
    environment: {POSTGRES_PASSWORD: dev}
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
    volumes: ["pgdata:/var/lib/postgresql/data"]

volumes: { pgdata: }
```

`-Xfrozen_modules=off` avoids debugger warnings on modern Python. See `ide-setup` for attaching VS Code and PyCharm to port 5678.

**API and workers share one image and differ only by command.** This keeps them on identical dependencies and halves the build matrix (`async-and-background-work`).

---

## 7. Production runtime

- Workers: `uvicorn` with `--workers N` behind a proxy, or Gunicorn with uvicorn workers. Size `N` from CPU count, but remember each worker loads the model — memory, not CPU, is usually the binding constraint for ML images.
- Set memory limits deliberately; an OOM-killed container with a 4 GB model looks like a random crash.
- Liveness hits `/healthz`, readiness hits `/readyz`; give ML services a generous `start-period` so slow model loading does not cause a restart loop (`fastapi`).
- Scan images (Trivy or equivalent) in CI and fail on high-severity CVEs.
- Generate an SBOM for anything shipped to customers.
- Tag by commit SHA, not `latest`, so a rollback is unambiguous.
- Log to stdout as JSON; let the platform collect it.

---

## 8. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| Single-stage build with compilers in the runtime image | Gigabytes of unnecessary attack surface |
| `COPY . .` before installing dependencies | Every source edit reinstalls PyTorch |
| `pip install` inside a uv project | The image no longer matches the lockfile |
| Running as root | Fails hardened clusters; container escape is worse |
| Secrets in `ENV`, build args, or layers | Visible in `docker history` and registries |
| No `.dockerignore` | Multi-hundred-MB build contexts; `.venv` copied in |
| `latest` base image tags | Non-reproducible builds |
| Model weights downloaded on first request | Cold-start timeouts, thundering herd |
| Model revision unpinned | The model changes without a deploy |
| CUDA `devel` image in production | Several GB wasted |
| Silent CPU fallback when a GPU is expected | Unexplained latency regressions |
| API and workers in one container | Heavy jobs starve HTTP handlers |
| No `SIGTERM` handling | In-flight work lost on every deploy |
| `--reload` in production | Extra file watchers, restarts under load |

---

## 9. Checklist

- [ ] Multi-stage build; runtime image free of build tooling
- [ ] Dependency and project layers separated; `uv sync --frozen` in both
- [ ] `.dockerignore` excludes `.venv`, `.git`, data, models, notebooks
- [ ] Base images pinned by digest for production
- [ ] Non-root user with a fixed UID; read-only root filesystem where possible
- [ ] System dependencies for OCR/ML installed and verified at build time
- [ ] Headless library variants preferred
- [ ] GPU images use the CUDA runtime variant; availability asserted at startup
- [ ] Model weights mounted or downloaded with a pinned revision and checksum
- [ ] Secrets injected at runtime only
- [ ] Health check plus a `start-period` that accommodates model loading
- [ ] `SIGTERM` handled for graceful shutdown
- [ ] API and workers run from the same image with different commands
- [ ] Compose exposes a debugger port and mounts source for hot reload
- [ ] Images scanned in CI; tagged by commit SHA
