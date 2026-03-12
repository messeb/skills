---
description: Dangerfile best practices — PR automation, rule authoring, CI integration, actionable messaging, and keeping rules maintainable.
---

# Dangerfile Best Practices

## What Danger Does

Danger runs during CI and reads pull request metadata (title, description, changed files, diff, reviews) to enforce team conventions automatically. It posts a comment on the PR with results — flagging violations, leaving warnings, or praising good practice.

Danger shifts code review from "did you remember to…?" checklists to automated, consistent enforcement.

---

## Setup

```bash
# JavaScript / TypeScript projects
npm install --save-dev danger
```

```ts
// danger.config.ts (optional runner config)
import { danger, warn, fail, message } from 'danger'
```

```yaml
# .github/workflows/danger.yml
name: Danger

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  danger:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci
      - run: npx danger ci
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## Output Functions

| Function | Severity | PR effect |
|----------|----------|-----------|
| `fail(msg)` | Error | Marks CI check as failed |
| `warn(msg)` | Warning | CI passes, yellow flag |
| `message(msg)` | Info | Neutral comment |
| `markdown(md)` | Info | Renders full Markdown block |

Always prefer the lowest severity that still gets attention. Reserve `fail` for genuine blockers.

---

## Dangerfile Patterns

### PR Description

```ts
// Dangerfile.ts
import { danger, fail, warn } from 'danger'

const prBody = danger.github.pr.body

// Require a non-empty description
if (!prBody || prBody.trim().length < 20) {
  fail('Please provide a meaningful PR description (at least 20 characters).')
}

// Require a checklist or section marker
if (!prBody.includes('## ') && !prBody.includes('- [ ]')) {
  warn('Consider adding a summary section or checklist to the PR description.')
}
```

### PR Size

```ts
const addedLines = danger.github.pr.additions
const deletedLines = danger.github.pr.deletions
const totalChanges = addedLines + deletedLines

if (totalChanges > 600) {
  warn(
    `This PR is large (${totalChanges} lines changed). ` +
    'Consider splitting it into smaller, focused PRs for easier review.'
  )
}
```

### Changed Files

```ts
const modifiedFiles = danger.git.modified_files
const createdFiles = danger.git.created_files
const allChangedFiles = [...modifiedFiles, ...createdFiles]

// Warn if lockfile changed without package.json
const lockfileChanged = allChangedFiles.some((f) => f.includes('package-lock.json') || f.includes('yarn.lock') || f.includes('pnpm-lock.yaml'))
const packageChanged = allChangedFiles.some((f) => f === 'package.json')

if (lockfileChanged && !packageChanged) {
  warn('Lockfile changed without a corresponding `package.json` change — was this intentional?')
}
```

### Test Coverage

```ts
// Require tests alongside source changes
const sourceChanged = allChangedFiles.some((f) => f.startsWith('src/') && !f.includes('.test.') && !f.includes('.spec.'))
const testsChanged = allChangedFiles.some((f) => f.includes('.test.') || f.includes('.spec.') || f.startsWith('tests/'))

if (sourceChanged && !testsChanged) {
  warn('Source files changed without any test changes. Did you mean to add or update tests?')
}
```

### Changelog

```ts
const changelogUpdated = allChangedFiles.some((f) => f.toLowerCase() === 'changelog.md')

if (!changelogUpdated) {
  message('No `CHANGELOG.md` update detected. If this is a user-facing change, consider documenting it.')
}
```

### Assign a Reviewer

```ts
const reviewers = danger.github.requested_reviewers.users.map((u) => u.login)

if (reviewers.length === 0) {
  warn('No reviewers assigned. Please add at least one reviewer before merging.')
}
```

### Sensitive File Changes

```ts
const sensitiveFiles = [
  '.env',
  '.env.production',
  'config/secrets.yml',
  'infrastructure/',
]

const sensitiveChanged = allChangedFiles.filter((f) =>
  sensitiveFiles.some((s) => f.startsWith(s) || f === s)
)

if (sensitiveChanged.length > 0) {
  fail(
    `Sensitive files changed: \`${sensitiveChanged.join('`, `')}\`. ` +
    'Ensure no secrets are committed and get a security review.'
  )
}
```

### Migration Files

```ts
const migrationsChanged = allChangedFiles.filter((f) => f.includes('/migrations/'))

if (migrationsChanged.length > 0) {
  message(
    `Database migrations included in this PR:\n${migrationsChanged.map((f) => `- \`${f}\``).join('\n')}\n\n` +
    'Ensure migrations are reversible and tested against a backup.'
  )
}
```

---

## Composing Rules into Functions

Keep `Dangerfile.ts` readable by extracting each rule into a named function.

```ts
// Dangerfile.ts
import { danger, fail, warn, message } from 'danger'

checkPrDescription()
checkPrSize()
checkTestCoverage()
checkLockfileConsistency()
checkSensitiveFiles()

// ─── Rules ───────────────────────────────────────────────

function checkPrDescription() {
  const body = danger.github.pr.body ?? ''
  if (body.trim().length < 20) {
    fail('Please provide a meaningful PR description.')
  }
}

function checkPrSize() {
  const total = danger.github.pr.additions + danger.github.pr.deletions
  if (total > 600) {
    warn(`Large PR (${total} lines). Consider splitting it.`)
  }
}

function checkTestCoverage() {
  const changed = [...danger.git.modified_files, ...danger.git.created_files]
  const srcChanged = changed.some((f) => f.startsWith('src/') && !/\.(test|spec)\./.test(f))
  const testChanged = changed.some((f) => /\.(test|spec)\./.test(f) || f.startsWith('tests/'))
  if (srcChanged && !testChanged) {
    warn('Source changed without test changes.')
  }
}

function checkLockfileConsistency() {
  const changed = [...danger.git.modified_files, ...danger.git.created_files]
  const lockfile = changed.some((f) => /lock\.(json|yaml)$/.test(f))
  const packageJson = changed.includes('package.json')
  if (lockfile && !packageJson) {
    warn('Lockfile changed without `package.json` change.')
  }
}

function checkSensitiveFiles() {
  const sensitive = ['.env', 'secrets', 'credentials']
  const changed = [...danger.git.modified_files, ...danger.git.created_files]
  const flagged = changed.filter((f) => sensitive.some((s) => f.includes(s)))
  if (flagged.length > 0) {
    fail(`Sensitive files modified: ${flagged.map((f) => `\`${f}\``).join(', ')}`)
  }
}
```

---

## Writing Good Messages

- **Be specific** — include file names, line counts, or values in the message
- **Explain why** — don't just flag a violation; say what the risk or convention is
- **Suggest action** — end with what the author should do
- **Link docs** — add a link to your contributing guide or ADR for non-obvious rules

```ts
// Bad
warn('Tests missing.')

// Good
warn(
  'Source files in `src/services/` were modified but no test files changed. ' +
  'Add or update tests in `tests/services/` to maintain coverage. ' +
  'See [contributing guide](./CONTRIBUTING.md#testing).'
)
```

---

## Keeping Rules Maintainable

- One rule per function — easy to disable, test, or share
- Group rules by category (PR hygiene, code quality, security)
- Use `warn` by default; only promote to `fail` after the team has adjusted
- Review and prune rules quarterly — remove rules nobody acts on
- Avoid reading file contents in Danger for complex analysis — use dedicated tools (ESLint, tsc) in separate CI steps and have Danger check their output artifacts

---

## Audit Checklist

1. **No Dangerfile in the repo** — PR conventions live in tribal knowledge or a checklist nobody reads; automate them
2. **Overuse of `fail`** — treating every rule as a hard blocker causes alert fatigue; use `warn` for advisory rules and `fail` only for genuine blockers (secrets, broken builds)
3. **Rules with no actionable message** — "tests missing" tells the author nothing; always explain what to do and link to docs
4. **Dangerfile is a long sequential script** — rules tangled in a single file become hard to maintain; extract each rule into a named function
5. **`GITHUB_TOKEN` not scoped correctly** — Danger needs read access to PR metadata and write access to post comments; use the built-in `GITHUB_TOKEN` with `pull-requests: write` permission
6. **Running Danger on push to main** — Danger is a PR tool; running it outside a PR context causes errors; gate the workflow on `pull_request` events
7. **Checking file contents for logic that belongs in linters** — parsing source files in Danger is fragile; delegate code analysis to ESLint/tsc and have Danger verify their exit codes or report files
8. **No `--dangerfile` flag for monorepos** — a single root Dangerfile checking all packages becomes unwieldy; use `--dangerfile packages/foo/Dangerfile.ts` per package or a shared rule library
