---
description: pnpm workspace best practices — catalog, filtering, hoisting rules, lockfile discipline, version management, and monorepo patterns.
---

# pnpm Workspace Best Practices

## Why pnpm

- **Disk efficiency**: packages stored once in a content-addressable store; symlinked into projects
- **Strictness by default**: phantom dependencies are impossible — only declared deps are accessible
- **Native workspace support**: `workspace:*` protocol, filtering, and catalog built in
- **Speed**: parallel installs, hard links, no redundant copies

---

## Basic Setup

```bash
# Install pnpm globally
npm install -g pnpm

# Initialize new workspace
mkdir my-monorepo && cd my-monorepo
pnpm init
```

```yaml
# pnpm-workspace.yaml
packages:
  - 'apps/*'
  - 'packages/*'
  - '!**/node_modules/**'
```

```json
// .npmrc — workspace-level pnpm config
shamefully-hoist=false          // keep strict; don't hoist everything
strict-peer-dependencies=false  // warn on peer dep issues, don't fail
auto-install-peers=true         // auto-install missing peer deps
save-exact=true                 // pin exact versions in package.json
link-workspace-packages=true    // use local packages before npm registry
```

---

## Catalog — Centralized Dependency Versions

The catalog prevents version drift: define a version once, reference it everywhere.

```yaml
# pnpm-workspace.yaml
packages:
  - 'apps/*'
  - 'packages/*'

catalog:
  # Core
  vue: ^3.5.0
  pinia: ^2.2.0
  vue-router: ^4.4.0

  # Build
  vite: ^6.0.0
  '@vitejs/plugin-vue': ^5.0.0
  typescript: ^5.7.0

  # Testing
  vitest: ^2.1.0
  '@vue/test-utils': ^2.4.0
  '@playwright/test': ^1.49.0

  # Linting
  eslint: ^9.0.0
  '@typescript-eslint/parser': ^8.0.0

  # Utilities
  '@vueuse/core': ^11.0.0
  zod: ^3.23.0
  date-fns: ^4.0.0
```

```json
// packages/ui/package.json — reference catalog versions
{
  "dependencies": {
    "vue": "catalog:",
    "@vueuse/core": "catalog:"
  },
  "devDependencies": {
    "vite": "catalog:",
    "@vitejs/plugin-vue": "catalog:",
    "typescript": "catalog:",
    "vitest": "catalog:"
  }
}
```

Multiple catalogs for different categories:

```yaml
catalogs:
  default:
    vue: ^3.5.0

  react:
    react: ^19.0.0
    react-dom: ^19.0.0

  testing:
    vitest: ^2.1.0
    playwright: ^1.49.0
```

```json
{ "devDependencies": { "vitest": "catalog:testing" } }
```

---

## Workspace Protocol

```json
// Reference local package — always uses local version
{
  "dependencies": {
    "@repo/ui": "workspace:*",
    "@repo/utils": "workspace:*"
  }
}

// Specific local version constraint
{
  "dependencies": {
    "@repo/ui": "workspace:^1.0.0"
  }
}
```

When publishing, `workspace:*` is replaced with the actual version by `pnpm publish`.

---

## Filtering Commands

```bash
# Run command in a single package
pnpm --filter web dev
pnpm --filter @repo/ui build

# Run in multiple packages matching a pattern
pnpm --filter './apps/*' build
pnpm --filter './packages/*' test

# Run in a package AND all its local dependencies
pnpm --filter web... build

# Run in a package AND everything that depends on it
pnpm --filter ...@repo/ui build

# Run in packages changed since main branch
pnpm --filter '[main]' test

# Exclude a package
pnpm --filter '!docs' build

# Run from root across all packages (recursive)
pnpm -r build
pnpm -r --parallel dev   # all in parallel
```

---

## Common Operations

### Add a dependency

```bash
# Add to a specific workspace package
pnpm --filter web add axios
pnpm --filter @repo/ui add -D vitest

# Add to root (tooling only)
pnpm add -D -w turbo changesets

# Add a local workspace package as dependency
pnpm --filter web add @repo/ui --workspace
```

### Update dependencies

```bash
# Interactive update for entire workspace
pnpm up --recursive --interactive --latest

# Update catalog entry
# Edit pnpm-workspace.yaml, then:
pnpm install  # updates all packages using catalog:

# Check for outdated
pnpm outdated --recursive
```

### Remove a dependency

```bash
pnpm --filter web remove axios
pnpm -r remove unused-package  # remove from all packages
```

---

## Hoisting and Phantom Dependencies

By default, pnpm does NOT hoist all packages. This prevents phantom dependencies (using packages you didn't declare).

```ini
# .npmrc

# Default: strict, correct
shamefully-hoist=false

# If a tool requires hoisting (e.g. some Storybook versions)
# Hoist only specific packages, not everything:
public-hoist-pattern[]=*eslint*
public-hoist-pattern[]=*prettier*
public-hoist-pattern[]=@types/*
```

---

## Lockfile Discipline

- **Never edit `pnpm-lock.yaml` manually** — always use `pnpm install` / `pnpm add`
- **Commit the lockfile** — ensures deterministic installs in CI and for all contributors
- **Regenerate on conflict** — on merge conflicts in lockfile, run `pnpm install` to re-resolve
- **Verify lockfile in CI** — use `pnpm install --frozen-lockfile` to fail if lockfile is out of sync

```yaml
# CI: enforce lockfile integrity
- name: Install dependencies
  run: pnpm install --frozen-lockfile
```

---

## Version Management with Changesets

```bash
pnpm add -D -w @changesets/cli
pnpm changeset init
```

```bash
# When you make a change that needs a version bump:
pnpm changeset          # describe what changed and bump type (major/minor/patch)

# When releasing:
pnpm changeset version  # bump versions and update changelogs
pnpm changeset publish  # publish changed packages
```

```yaml
# .changeset/config.json
{
  "$schema": "https://unpkg.com/@changesets/config@3.0.0/schema.json",
  "changelog": "@changesets/cli/changelog",
  "commit": false,
  "fixed": [],
  "linked": [],
  "access": "restricted",
  "baseBranch": "main",
  "updateInternalDependencies": "patch",
  "ignore": ["docs"]
}
```

---

## Performance Tips

```ini
# .npmrc

# Use a shared store across all your projects
store-dir=~/.pnpm-store

# Speed up CI — skip optional deps
optional=false
```

```bash
# CI: restore pnpm store from cache
- uses: pnpm/action-setup@v4
  with:
    version: 9
    run_install: false

- name: Get pnpm store directory
  id: pnpm-cache
  run: echo "STORE_PATH=$(pnpm store path)" >> $GITHUB_OUTPUT

- uses: actions/cache@v4
  with:
    path: ${{ steps.pnpm-cache.outputs.STORE_PATH }}
    key: ${{ runner.os }}-pnpm-store-${{ hashFiles('**/pnpm-lock.yaml') }}
    restore-keys: ${{ runner.os }}-pnpm-store-
```

---

## Audit Checklist

1. **`shamefully-hoist=true` in `.npmrc`** — hides phantom dependency bugs; packages may work locally but break in environments with a different install order
2. **Not using catalog for shared deps** — each package declares its own version of `vue`, `typescript`, etc.; version drift leads to peer dep conflicts and duplicate bundles
3. **`workspace:*` for non-local packages** — `workspace:` protocol is for local packages only; using it on npm packages causes install failures
4. **Lockfile not committed** — non-deterministic installs; different team members and CI may get different dependency trees
5. **`pnpm install` without `--frozen-lockfile` in CI** — CI silently updates the lockfile and installs newer (potentially breaking) versions
6. **Root package.json has app dependencies** — app-level dependencies installed at root contaminate all packages; root should only contain workspace tooling
7. **Scripts not using `--filter`** — running `pnpm -r build` when only one package changed; use Turbo or `--filter '[main]'` to limit scope
8. **Mixing `npm` / `yarn` scripts in monorepo** — different team members running `npm install` instead of `pnpm install` generates a second lockfile and breaks workspace links
