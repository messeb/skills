---
description: Frontend CI/CD build pipeline — lint, type-check, test, build, preview deployment, and release stages with GitHub Actions.
---

# Frontend Build Pipeline

## Pipeline Philosophy

A good frontend pipeline is:
- **Fast**: developers get feedback in under 5 minutes
- **Deterministic**: same input always produces same output
- **Sequential where order matters, parallel everywhere else**
- **Fail-fast**: cheap checks run before expensive ones

```
Push → Lint+Type-check (parallel, fast)
              ↓
         Unit Tests
              ↓
         Build
              ↓
    E2E Tests + Preview Deploy (parallel)
              ↓
         Release (on main only)
```

---

## Complete GitHub Actions Workflow

### PR validation

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true  # cancel previous runs on new push

env:
  NODE_VERSION: '22'
  PNPM_VERSION: '9'

jobs:
  # ─────────────────────────────────────────────
  # Fast checks — run in parallel
  # ─────────────────────────────────────────────
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with: { version: '${{ env.PNPM_VERSION }}' }
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm turbo lint

  type-check:
    name: Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with: { version: '${{ env.PNPM_VERSION }}' }
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm turbo type-check

  # ─────────────────────────────────────────────
  # Unit tests
  # ─────────────────────────────────────────────
  test:
    name: Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with: { version: '${{ env.PNPM_VERSION }}' }
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm turbo test
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./apps/web/coverage/lcov.info

  # ─────────────────────────────────────────────
  # Build (depends on checks passing)
  # ─────────────────────────────────────────────
  build:
    name: Build
    runs-on: ubuntu-latest
    needs: [lint, type-check, test]
    outputs:
      artifact-id: ${{ steps.upload.outputs.artifact-id }}
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with: { version: '${{ env.PNPM_VERSION }}' }
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: pnpm

      # Restore Turbo cache
      - uses: actions/cache@v4
        with:
          path: .turbo
          key: ${{ runner.os }}-turbo-${{ github.sha }}
          restore-keys: ${{ runner.os }}-turbo-

      - run: pnpm install --frozen-lockfile
      - run: pnpm turbo build
        env:
          VITE_API_URL: ${{ vars.VITE_API_URL }}
          TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
          TURBO_TEAM: ${{ vars.TURBO_TEAM }}

      - name: Upload build artifact
        id: upload
        uses: actions/upload-artifact@v4
        with:
          name: build-${{ github.sha }}
          path: apps/web/dist
          retention-days: 3

  # ─────────────────────────────────────────────
  # E2E tests + Preview deploy (parallel, after build)
  # ─────────────────────────────────────────────
  e2e:
    name: E2E Tests
    runs-on: ubuntu-latest
    needs: [build]
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with: { version: '${{ env.PNPM_VERSION }}' }
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - name: Install Playwright browsers
        run: pnpm exec playwright install --with-deps chromium
      - name: Download build
        uses: actions/download-artifact@v4
        with:
          name: build-${{ github.sha }}
          path: apps/web/dist
      - run: pnpm turbo test:e2e
        env:
          BASE_URL: ${{ vars.E2E_BASE_URL }}
          TEST_USER_EMAIL: ${{ secrets.TEST_USER_EMAIL }}
          TEST_USER_PASSWORD: ${{ secrets.TEST_USER_PASSWORD }}
      - name: Upload Playwright report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report-${{ github.sha }}
          path: apps/web/playwright-report
          retention-days: 7

  preview:
    name: Preview Deploy
    runs-on: ubuntu-latest
    needs: [build]
    if: github.event_name == 'pull_request'
    environment:
      name: preview
      url: ${{ steps.deploy.outputs.url }}
    steps:
      - uses: actions/checkout@v4
      - name: Download build
        uses: actions/download-artifact@v4
        with:
          name: build-${{ github.sha }}
          path: dist
      - name: Deploy to Vercel
        id: deploy
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          working-directory: .

  # ─────────────────────────────────────────────
  # Release (main branch only)
  # ─────────────────────────────────────────────
  release:
    name: Release
    runs-on: ubuntu-latest
    needs: [build, e2e]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: pnpm/action-setup@v4
        with: { version: '${{ env.PNPM_VERSION }}' }
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - name: Create Release
        run: pnpm changeset publish
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

---

## Caching Strategy

### Node modules caching

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: 22
    cache: pnpm         # caches pnpm store, not node_modules
```

### pnpm store caching

```yaml
- name: Get pnpm store path
  id: pnpm-cache
  run: echo "STORE_PATH=$(pnpm store path)" >> $GITHUB_OUTPUT

- uses: actions/cache@v4
  with:
    path: ${{ steps.pnpm-cache.outputs.STORE_PATH }}
    key: ${{ runner.os }}-pnpm-${{ hashFiles('**/pnpm-lock.yaml') }}
    restore-keys: ${{ runner.os }}-pnpm-
```

### Playwright browser cache

```yaml
- name: Cache Playwright browsers
  uses: actions/cache@v4
  with:
    path: ~/.cache/ms-playwright
    key: ${{ runner.os }}-playwright-${{ hashFiles('**/package.json') }}

- run: pnpm exec playwright install --with-deps chromium
```

---

## Environment Variables and Secrets

```yaml
# Repository variables (not secret, shown in UI) — github.com/.../settings/variables
VITE_API_URL: https://api.example.com
TURBO_TEAM: my-team

# Repository secrets (encrypted) — github.com/.../settings/secrets
VERCEL_TOKEN: ...
TURBO_TOKEN: ...
TEST_USER_PASSWORD: ...
NPM_TOKEN: ...
```

**Rule**: build-time public config → variables. Credentials and tokens → secrets.

---

## Branch Protection Rules

```yaml
# Recommended required status checks on main:
Required checks:
  - Lint
  - Type Check
  - Unit Tests
  - Build
  - E2E Tests

Settings:
  - Require branches to be up to date before merging
  - Require linear history (no merge commits)
  - Dismiss stale reviews on new push
  - Require review from code owners
```

---

## Lighthouse CI

```yaml
# .github/workflows/lighthouse.yml
- name: Lighthouse CI
  uses: treosh/lighthouse-ci-action@v12
  with:
    urls: |
      ${{ steps.deploy.outputs.url }}
      ${{ steps.deploy.outputs.url }}/about
    uploadArtifacts: true
    temporaryPublicStorage: true
    budgetPath: .lighthouse-budget.json
```

```json
// .lighthouse-budget.json
[
  {
    "path": "/*",
    "timings": [
      { "metric": "interactive", "budget": 3000 },
      { "metric": "first-contentful-paint", "budget": 1500 }
    ],
    "resourceSizes": [
      { "resourceType": "script", "budget": 300 },
      { "resourceType": "total", "budget": 600 }
    ]
  }
]
```

---

## Security Scanning

```yaml
# Dependency vulnerability scanning
- name: Audit dependencies
  run: pnpm audit --audit-level=high

# Secrets scanning
- name: Scan for secrets
  uses: trufflesecurity/trufflehog@main
  with:
    path: ./
    base: ${{ github.event.repository.default_branch }}
    head: HEAD
```

---

## Audit Checklist

1. **No `concurrency` group on PRs** — multiple pushes to the same PR queue up jobs; outdated jobs run even after newer push; add `concurrency` with `cancel-in-progress`
2. **Secrets used as `env` variables in non-secret jobs** — `GITHUB_TOKEN` and other secrets leaked into logs via `echo` or error output; use `${{ secrets.X }}` directly in steps, never echo them
3. **No artifact retention limits** — build artifacts kept indefinitely consuming storage; set `retention-days` on all artifact uploads
4. **E2E runs against every push** — expensive Playwright tests running on every trivial commit; gate behind `build` job completion and only run when needed
5. **`pnpm install` without `--frozen-lockfile`** — CI silently resolves to different versions than what's in the lockfile; install can succeed while production breaks
6. **No cache invalidation strategy** — using `${{ github.sha }}` as cache key means cache is never hit; use `hashFiles('**/pnpm-lock.yaml')` for stable cache keys
7. **Build environment variables missing** — `VITE_API_URL` not passed to build step; app silently uses undefined/fallback values in CI build
8. **Release job not gated on E2E** — production deploy triggered before E2E tests complete; deployment of broken builds possible if E2E is slow
