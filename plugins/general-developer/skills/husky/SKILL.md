---
description: Husky pre-commit hooks — setup, hook scripts, lint-staged integration, commit-msg validation, and team best practices.
---

# Husky Pre-Commit Hooks

## What Husky Does

Husky wires Git hooks to scripts in your repo so that checks (linting, formatting, type-checking, tests) run automatically before a commit or push is accepted — catching issues before they reach CI.

---

## Setup

```bash
npm install --save-dev husky
npx husky init
```

`husky init` creates a `.husky/` directory and adds a `prepare` script to `package.json` so hooks are installed after every `npm install`.

```json
// package.json
{
  "scripts": {
    "prepare": "husky"
  }
}
```

```
.husky/
├── pre-commit      ← runs before every commit
├── commit-msg      ← validates the commit message
└── pre-push        ← runs before every push
```

Hook files are plain shell scripts — make them executable.

---

## `pre-commit` Hook — Lint and Format Staged Files

Pair Husky with **lint-staged** so only changed files are processed. Linting the entire codebase on every commit is too slow.

```bash
npm install --save-dev lint-staged
```

```sh
# .husky/pre-commit
npx lint-staged
```

```json
// package.json — lint-staged config
{
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{js,jsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{css,scss}": [
      "prettier --write"
    ],
    "*.{json,md,yaml,yml}": [
      "prettier --write"
    ]
  }
}
```

Or in a standalone `lint-staged.config.js`:

```js
// lint-staged.config.js
export default {
  '*.{ts,tsx,js,jsx}': ['eslint --fix', 'prettier --write'],
  '*.{css,scss,json,md}': ['prettier --write'],
}
```

---

## `commit-msg` Hook — Enforce Conventional Commits

Use **commitlint** to enforce a consistent commit message format.

```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional
```

```sh
# .husky/commit-msg
npx --no -- commitlint --edit "$1"
```

```js
// commitlint.config.js
export default {
  extends: ['@commitlint/config-conventional'],
}
```

Valid commit message format:
```
<type>(<scope>): <subject>

feat(auth): add OAuth2 login flow
fix(cart): prevent negative quantities
chore(deps): bump eslint to 9.x
docs(readme): update setup instructions
```

Allowed types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `test`, `perf`, `ci`, `build`, `revert`.

---

## `pre-push` Hook — Run Tests Before Pushing

Gate pushes behind a fast test run to prevent broken code from reaching the remote.

```sh
# .husky/pre-push
npm run test:unit -- --run
```

Keep the test command fast — long-running E2E tests belong in CI, not in a push hook.

---

## Hook Scripts — Best Practices

### Exit codes control pass/fail

A non-zero exit code aborts the Git operation. Any standard CLI tool (eslint, tsc, jest) already does this correctly.

```sh
# .husky/pre-commit
npx lint-staged        # exits non-zero if linting fails → commit aborted
```

### Type-check without emitting

```sh
# .husky/pre-commit
npx lint-staged
npx tsc --noEmit       # type-check the whole project; no output files written
```

Only add `tsc --noEmit` if it completes in under ~10 seconds on your machine. Move it to CI otherwise.

### Keep hooks fast

| Hook | Target time | What belongs here |
|------|------------|-------------------|
| `pre-commit` | < 10 s | Linting, formatting staged files |
| `commit-msg` | < 1 s | Message format validation |
| `pre-push` | < 60 s | Unit tests, type-check |
| CI only | unlimited | E2E, coverage, build |

---

## Skipping Hooks

Developers can bypass hooks with `--no-verify`. This is sometimes necessary (e.g., WIP commits, emergency fixes) — don't make bypassing the only escape valve for slow hooks.

```bash
git commit --no-verify -m "wip: spike"
```

Never add `--no-verify` to scripts or CI pipelines. If hooks are routinely skipped, they're too slow or too strict — fix the hook, not the workflow.

---

## CI Parity

Hooks are a fast local feedback loop — CI is the authoritative gate. Run the same checks in both places.

```yaml
# .github/workflows/ci.yml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci
      - run: npx eslint .
      - run: npx tsc --noEmit

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci
      - run: npm test
```

---

## Monorepo Setup

In a monorepo, install Husky once at the root and configure lint-staged per-package.

```json
// root package.json
{
  "scripts": { "prepare": "husky" },
  "lint-staged": {
    "packages/ui/src/**/*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "packages/api/src/**/*.ts": ["eslint --fix", "prettier --write"]
  }
}
```

Or use `--concurrent false` to run package-specific lint-staged configs:

```sh
# .husky/pre-commit
npx lint-staged --concurrent false
```

---

## Audit Checklist

1. **`prepare` script missing** — hooks won't install for new contributors after `npm install`; `"prepare": "husky"` must be in `package.json`
2. **Linting the entire project in `pre-commit`** — running ESLint on all files instead of staged files makes commits slow; use lint-staged
3. **Heavy checks in `pre-commit`** — full test suites or E2E tests in the pre-commit hook cause unacceptable delays; move them to `pre-push` or CI
4. **No `commit-msg` hook** — inconsistent commit messages make changelogs, bisect, and release automation unreliable; enforce with commitlint
5. **Hook files not executable** — `.husky/pre-commit` without execute permissions silently does nothing; ensure `chmod +x` or use `husky init`
6. **`--no-verify` in scripts or documentation** — normalizing hook bypass defeats the purpose; fix slow hooks instead of teaching bypass
7. **Hooks not matching CI checks** — a pre-commit hook that passes while CI fails means the hook is incomplete; keep both in sync
8. **Husky installed in `dependencies` instead of `devDependencies`** — hook tooling ships to production unnecessarily
