---
description: uv as the single Python package and project manager — project init and layout, dependency groups and optional extras, the lockfile and `uv sync --frozen`, Python version pinning, workspaces for monorepos, `uv run` and `uvx`, PyTorch and CUDA index configuration, Docker and CI usage, and migration from pip/Poetry/Conda.
---

# uv

Goal of this skill: run the whole Python lifecycle through one fast, reproducible tool — interpreter, virtualenv, dependencies, lockfile, scripts, and tools — so that "works on my machine" and "works in the container" are the same environment.

Use this skill when starting a Python AI project, when adding or upgrading dependencies, when builds are non-reproducible, or when migrating from pip, Poetry, Pipenv, or Conda.

---

## 1. Why uv for AI projects specifically

| Problem | What uv does |
|---------|--------------|
| Resolving `torch`, `transformers`, CUDA wheels takes minutes | Resolution and install are typically 10–100× faster than pip |
| The dev box has Python 3.12, the image has 3.11 | `uv python install` manages interpreters; `.python-version` pins one |
| `pip freeze` output differs per platform | `uv.lock` is cross-platform and resolves for all declared targets |
| CPU wheels locally, CUDA wheels in prod | Per-index and per-platform source pinning in `pyproject.toml` |
| Notebook, API, and training share dependencies badly | Dependency groups and workspaces |
| Container builds re-resolve every time | `--frozen` plus a cache mount gives deterministic, cached installs |

One tool replaces pip, pip-tools, pipx, virtualenv, pyenv, and (for most projects) Poetry.

---

## 2. Project setup

```bash
uv init --package my-ai-service     # src layout with a build backend
cd my-ai-service
uv python pin 3.12                  # writes .python-version
uv add fastapi uvicorn[standard] pydantic-settings httpx
uv add --group dev pytest pytest-asyncio pytest-cov ruff mypy
uv add --group notebook jupyterlab ipykernel
uv sync                             # create .venv and install everything
```

`uv add` edits `pyproject.toml`, re-locks, and installs in one step — do not hand-edit dependency lists and then forget to re-lock.

### pyproject.toml

```toml
[project]
name = "my-ai-service"
version = "0.1.0"
requires-python = ">=3.12,<3.13"
dependencies = [
    "fastapi>=0.115",
    "uvicorn[standard]>=0.32",
    "pydantic>=2.9",
    "pydantic-settings>=2.6",
    "httpx>=0.27",
]

[project.optional-dependencies]
# Extras are for *consumers* of your package: `pip install my-ai-service[ocr]`
ocr = ["pytesseract>=0.3.13", "pdf2image>=1.17"]
ml = ["scikit-learn>=1.5", "pandas>=2.2"]

[dependency-groups]
# Groups are for *developers*; they never ship in the wheel.
dev = ["pytest>=8.3", "pytest-asyncio>=0.24", "pytest-cov>=6.0", "ruff>=0.8", "mypy>=1.13"]
notebook = ["jupyterlab>=4.3", "ipykernel>=6.29", "nbstripout>=0.8"]

[tool.uv]
default-groups = ["dev"]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

**Extras vs groups** is the distinction people get wrong: an *extra* is an installable feature of your published package; a *dependency group* is tooling that only ever exists in a developer's or CI's environment. Test runners, linters, and Jupyter belong in groups.

Pin `requires-python` to a narrow range. `>=3.10` forces the resolver to find dependency versions compatible with every version in the range, which silently holds packages back.

---

## 3. Everyday commands

| Task | Command |
|------|---------|
| Install exactly what the lockfile says | `uv sync --frozen` |
| Install including a group | `uv sync --group notebook` |
| Install only production deps | `uv sync --no-dev --frozen` |
| Add a dependency | `uv add "transformers>=4.46"` |
| Add a dev dependency | `uv add --group dev ruff` |
| Remove | `uv remove transformers` |
| Upgrade one package | `uv lock --upgrade-package transformers` |
| Upgrade everything | `uv lock --upgrade` |
| Run a command in the env | `uv run pytest` |
| Run the API | `uv run uvicorn app.main:app --reload` |
| Run a tool without installing it | `uvx ruff check .` |
| Install a global tool | `uv tool install ruff` |
| Show the dependency tree | `uv tree` |
| Export a requirements file (for tools that need one) | `uv export --frozen --no-dev -o requirements.txt` |

**`uv run` is the entry point.** It ensures the environment matches the lockfile before executing, which removes the entire class of "forgot to activate the venv" and "forgot to reinstall after pulling" bugs. Never `pip install` into a uv-managed `.venv`.

---

## 4. The lockfile

`uv.lock` is committed. It is cross-platform: one lockfile resolves for every platform in `environments`, so Linux CI and a macOS laptop install the same versions.

| Rule | Why |
|------|-----|
| Commit `uv.lock`; never commit `.venv/` | Reproducibility without binaries in git |
| CI and Docker use `--frozen` | Fails loudly if the lock is stale instead of silently re-resolving |
| Re-lock deliberately, in its own commit | A dependency bump is a reviewable change, not a side effect |
| Restrict resolution targets if you only ship Linux | Smaller, faster locks |

```toml
[tool.uv]
environments = [
    "sys_platform == 'linux' and platform_machine == 'x86_64'",
    "sys_platform == 'darwin' and platform_machine == 'arm64'",
]
```

`uv lock --check` in CI fails the build when `pyproject.toml` and `uv.lock` have drifted apart — add it as a gate.

---

## 5. PyTorch, CUDA, and other special indexes

The default PyPI `torch` wheel is not the wheel you want in a GPU image, and the CUDA wheel is not what you want on a laptop. Declare indexes explicitly rather than relying on install-time flags.

```toml
[[tool.uv.index]]
name = "pytorch-cpu"
url = "https://download.pytorch.org/whl/cpu"
explicit = true                 # only used by packages that name it

[[tool.uv.index]]
name = "pytorch-cu124"
url = "https://download.pytorch.org/whl/cu124"
explicit = true

[tool.uv.sources]
torch = [
    { index = "pytorch-cpu",   marker = "sys_platform == 'darwin'" },
    { index = "pytorch-cu124", marker = "sys_platform == 'linux'" },
]
```

`explicit = true` matters: without it, uv may pull *any* package from that index. For a private company index, use `[[tool.uv.index]]` with credentials from the environment (`UV_INDEX_<NAME>_USERNAME` / `_PASSWORD`), never inline in `pyproject.toml`.

---

## 6. Workspaces (monorepo)

```toml
# root pyproject.toml
[tool.uv.workspace]
members = ["packages/*", "services/*"]
```

```toml
# services/api/pyproject.toml
[project]
dependencies = ["shared-domain"]

[tool.uv.sources]
shared-domain = { workspace = true }
```

One lockfile at the root, one shared `.venv`, and local packages resolved from the workspace instead of the index. Use `uv run --package api ...` to run a command for one member. Workspaces are right when members share a release cycle; separate repos are better when they do not.

---

## 7. Docker and CI

```dockerfile
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
WORKDIR /app

# Dependency layer — cached until the lockfile changes
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

# Project layer
COPY . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev
```

The two-stage sync (`--no-install-project`, then the project) is what keeps the expensive dependency layer cached when only your source changes. See `containerization` for the full multi-stage image.

```yaml
# GitHub Actions
- uses: astral-sh/setup-uv@v5
  with:
    enable-cache: true
- run: uv sync --frozen
- run: uv lock --check          # fail if pyproject and lock drifted
- run: uv run ruff check .
- run: uv run mypy src
- run: uv run pytest --cov
```

---

## 8. Migration

| From | Path |
|------|------|
| `requirements.txt` | `uv init`, then `uv add -r requirements.txt`, then delete it (or keep it generated via `uv export`) |
| Poetry | `uvx migrate-to-uv` converts `[tool.poetry]` to PEP 621 `[project]`; verify `requires-python`, groups, and sources afterwards |
| Pipenv | `uv add -r <(pipenv requirements)` |
| Conda | Keep Conda only if you need non-Python system libraries it uniquely provides (some CUDA/GDAL setups). Otherwise move to uv and install system libraries in the Dockerfile |
| pip-tools | `.in` files become `[project.dependencies]`; `.txt` becomes `uv.lock` |

After any migration: delete the old lockfile, run `uv sync --frozen` in a clean container, and run the test suite. A migration that has not been verified in a clean environment is not finished.

---

## 9. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| `pip install` into a uv-managed `.venv` | The lockfile no longer describes the environment |
| `.venv/` committed | Huge repo, broken on other platforms |
| `uv.lock` not committed | No reproducibility; the point of the tool is lost |
| `uv sync` without `--frozen` in CI or Docker | Silent re-resolution; the image differs from the lock |
| Wide `requires-python` (`>=3.9`) | Resolver holds every dependency back to the oldest compatible version |
| Dev tooling in `[project.dependencies]` | pytest and ruff ship to production |
| Extras used for developer tooling | Consumers get your linter |
| Index without `explicit = true` | Unrelated packages silently resolve from a CUDA index |
| Credentials inline in `pyproject.toml` | Secrets in git |
| Re-locking as a side effect of an unrelated commit | Unreviewed dependency changes |
| Mixing Conda and uv in one environment | Two resolvers, one site-packages, unexplainable breakage |

---

## 10. Checklist

- [ ] `pyproject.toml` uses PEP 621 `[project]`, with a narrow `requires-python`
- [ ] `.python-version` committed and matched by the Docker base image
- [ ] `uv.lock` committed; `.venv/` git-ignored
- [ ] Runtime dependencies, consumer extras, and dev groups separated correctly
- [ ] Special indexes declared with `explicit = true`; credentials from the environment
- [ ] Every command run through `uv run`; no manual venv activation in docs or CI
- [ ] CI runs `uv sync --frozen` and `uv lock --check`
- [ ] Dockerfile installs dependencies and project in separate cached layers
- [ ] Dependency upgrades land in their own reviewed commits
- [ ] A clean-container `uv sync --frozen` plus test run verified after migration
