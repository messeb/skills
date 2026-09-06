---
description: Run and debug configuration for VS Code and PyCharm — interpreter selection for uv environments, launch configurations for FastAPI, workers, pytest, and scripts, remote debugging into Docker with debugpy, environment and secret handling in IDE configs, breakpoints in async and threaded code, notebook debugging, and the committed-versus-personal split of IDE files.
---

# VS Code and PyCharm setup

Goal of this skill: a checked-out repository where **F5 (VS Code) or Run (PyCharm) works immediately** — API, worker, tests, and container debugging — without every developer reconstructing it.

Use this skill when onboarding, when debugging inside Docker is needed, or when breakpoints do not hit.

---

## 1. The interpreter

Both IDEs must point at the uv-managed virtualenv, not a system Python.

```bash
uv sync                 # creates ./.venv
```

- **VS Code**: `"python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python"` in `.vscode/settings.json`, or *Python: Select Interpreter* → `./.venv/bin/python`.
- **PyCharm**: *Settings → Project → Python Interpreter → Add → Existing* → `<project>/.venv/bin/python`. Recent PyCharm versions detect `uv` projects and offer the uv environment type directly.

If the IDE creates its own venv, dependencies silently diverge from `uv.lock`. Point it at `.venv` and never let it manage packages.

---

## 2. VS Code

### `.vscode/settings.json` (committed)

```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "python.testing.pytestEnabled": true,
  "python.testing.pytestArgs": ["tests", "-m", "not integration and not llm"],
  "python.analysis.typeCheckingMode": "standard",
  "python.analysis.extraPaths": ["${workspaceFolder}/src"],
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": { "source.organizeImports.ruff": "explicit" },
  "[python]": { "editor.defaultFormatter": "charliermarsh.ruff" },
  "files.exclude": { "**/__pycache__": true, "**/.pytest_cache": true }
}
```

### `.vscode/launch.json` (committed)

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "API (uvicorn, reload)",
      "type": "debugpy",
      "request": "launch",
      "module": "uvicorn",
      "args": ["app.main:app", "--host", "127.0.0.1", "--port", "8000", "--reload"],
      "jinja": true,
      "envFile": "${workspaceFolder}/.env",
      "env": { "PYTHONPATH": "${workspaceFolder}/src" },
      "console": "integratedTerminal"
    },
    {
      "name": "Worker",
      "type": "debugpy",
      "request": "launch",
      "module": "app.worker",
      "envFile": "${workspaceFolder}/.env",
      "env": { "PYTHONPATH": "${workspaceFolder}/src" }
    },
    {
      "name": "Pytest: current file",
      "type": "debugpy",
      "request": "launch",
      "module": "pytest",
      "args": ["${file}", "-vv", "-s"],
      "envFile": "${workspaceFolder}/.env"
    },
    {
      "name": "Attach to Docker (debugpy 5678)",
      "type": "debugpy",
      "request": "attach",
      "connect": { "host": "localhost", "port": 5678 },
      "pathMappings": [
        { "localRoot": "${workspaceFolder}/src", "remoteRoot": "/app/src" }
      ],
      "justMyCode": false
    }
  ]
}
```

Notes that save time: `--reload` plus a debugger works, but the reloader runs your code in a child process — if breakpoints stop hitting after an edit, drop `--reload` for that session. `justMyCode: false` is required to step into library code (SDKs, FastAPI internals). `envFile` loads `.env` — never put secrets into `launch.json`, which is committed.

### `.vscode/extensions.json`

```json
{ "recommendations": ["ms-python.python", "ms-python.debugpy", "charliermarsh.ruff", "ms-python.mypy-type-checker", "ms-toolsai.jupyter", "ms-azuretools.vscode-docker"] }
```

---

## 3. PyCharm

Run configurations live in `.idea/runConfigurations/*.xml` and **can be committed** — that directory is shareable even though most of `.idea/` is not.

| Configuration | Type | Settings |
|---------------|------|----------|
| **API** | Python | Module name `uvicorn`; parameters `app.main:app --reload --port 8000`; working dir = project root; env file `.env` |
| **Worker** | Python | Module name `app.worker` |
| **Tests** | pytest | Target `tests`; additional arguments `-m "not integration and not llm"` |
| **Attach to Docker** | Python Debug Server | Host `localhost`, port `5678`; path mapping `<project>/src` → `/app/src` |
| **Compose** | Docker Compose | For running the full stack from the IDE |

PyCharm Professional also offers a FastAPI run configuration and a Docker Compose interpreter; both are convenient but the plain configurations above work in every edition and are portable.

`.gitignore` for a shared project:

```gitignore
.idea/*
!.idea/runConfigurations/
!.idea/inspectionProfiles/
```

Commit run configurations and inspection profiles; ignore workspace, module, and user-specific files.

---

## 4. Debugging inside Docker

Both IDEs attach to the same `debugpy` server, so one Compose setup serves the whole team.

```yaml
# docker-compose.override.yml — local only, not used in CI
services:
  api:
    command: >
      python -Xfrozen_modules=off -m debugpy --listen 0.0.0.0:5678
      -m uvicorn app.main:app --host 0.0.0.0 --port 8000
    ports: ["8000:8000", "5678:5678"]
    volumes: ["./src:/app/src"]
```

Add `--wait-for-client` to `debugpy` when you need to break on code that runs during startup (model loading, lifespan). Without it the app starts immediately and startup breakpoints are missed.

| Symptom | Cause |
|---------|-------|
| Breakpoints show as hollow/unverified | Path mapping wrong — `localRoot`/`remoteRoot` must match the mounted source exactly |
| Debugger connects, never stops | Source in the image differs from local source; mount the volume |
| Cannot step into library code | `justMyCode: true` |
| Nothing happens on startup | Missing `--wait-for-client` |
| Port refused | `5678` not published, or the process is not listening on `0.0.0.0` |

---

## 5. Async, threads, and subprocesses

- **Async**: breakpoints work normally in `async def`. Stepping over an `await` yields to the loop, so other tasks run in between — the call stack you return to may look different. This is correct behaviour, not a broken debugger.
- **Thread offloads** (`anyio.to_thread.run_sync`): breakpoints inside the threaded function work in both IDEs.
- **Process pools and multiprocessing workers**: child processes are not debugged by default. Debug the function directly in a test, or attach a separate `debugpy` listener inside the child.
- **Uvicorn `--workers N`**: only the parent is attached — use a single worker while debugging.
- **Long provider calls**: raise the debugger's timeout tolerance, or the connection is dropped while you sit on a breakpoint.

---

## 6. Environment and secrets in the IDE

- Keep secrets in `.env` (git-ignored) and reference it via `envFile` / *EnvFile*. Never in `launch.json` or a committed run configuration.
- Commit `.env.example` with every key present and empty, so a new checkout starts with a complete template.
- Use a distinct `.env.test` for the test configuration so a debug run cannot touch production data.
- If the IDE must not see production credentials at all, keep the debug configuration pointed at a local stack (Compose) and require an explicit profile switch for anything else.

---

## 7. Notebooks

- VS Code: the Jupyter extension runs notebooks against the selected interpreter — select `.venv` so notebook and application code share dependencies. Breakpoints work in notebook cells.
- PyCharm Professional: notebooks run against the project interpreter with a full debugger; the Community edition has limited support.
- Register the kernel explicitly so it appears with a meaningful name: `uv run python -m ipykernel install --user --name my-ai-service`.
- See `notebooks` for hygiene — output stripping, imports from `src/`, and the notebook-to-module path.

---

## 8. Anti-patterns

| Anti-pattern | Consequence |
|--------------|-------------|
| IDE-created venv instead of `.venv` | Dependencies drift from the lockfile |
| No committed run configurations | Every developer rebuilds them; onboarding costs hours |
| Secrets in `launch.json` or run configuration XML | Credentials committed to git |
| Whole `.idea/` committed | Constant churn from per-user files |
| `justMyCode: true` when debugging SDK behaviour | Cannot step into the code you are investigating |
| Debugging with `--workers 4` | Breakpoints in unattached child processes never hit |
| `--reload` while debugging startup code | Reloader child process bypasses breakpoints |
| No path mapping for container debugging | Breakpoints never bind |
| Tests configured to run integration and LLM markers by default | Slow, expensive, credential-dependent runs from the IDE |
| Notebook using a different interpreter than the app | "Works in the notebook, fails in the service" |

---

## 9. Checklist

- [ ] `.venv` created by `uv sync` and selected in both IDEs
- [ ] `.vscode/settings.json`, `launch.json`, and `extensions.json` committed
- [ ] `.idea/runConfigurations/` committed; the rest of `.idea/` ignored
- [ ] Launch configurations exist for API, worker, tests, and container attach
- [ ] `PYTHONPATH` or `extraPaths` includes `src/` so the src layout resolves
- [ ] Secrets only in `.env`; `.env.example` committed complete
- [ ] Test configuration excludes integration and LLM markers by default
- [ ] `debugpy` port published in the Compose override with source mounted
- [ ] Path mappings verified — breakpoints bind, not hollow
- [ ] `justMyCode: false` available for stepping into libraries
- [ ] `--wait-for-client` used when debugging startup and model loading
- [ ] Single worker while debugging
- [ ] Notebook kernel registered and pointing at the project environment
