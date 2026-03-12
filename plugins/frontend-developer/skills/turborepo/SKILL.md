---
description: Turborepo monorepo setup — workspace structure, turbo.json pipeline configuration, caching strategy, task dependencies, and CI integration.
---

# Turborepo Monorepo

## Why Turborepo

Turborepo adds task orchestration and caching on top of a package manager workspace. It does not replace the workspace — it accelerates it.

Key benefits:
- **Incremental builds**: only rebuild packages that changed
- **Remote caching**: share build artifacts across CI runs and machines
- **Parallel execution**: run tasks across packages concurrently where dependencies allow
- **Dependency-aware ordering**: build `ui` before `web` automatically

---

## Workspace Structure

```
monorepo/
├── apps/
│   ├── web/              # Main application (Next.js / Nuxt)
│   ├── admin/            # Admin panel
│   └── docs/             # Documentation site
├── packages/
│   ├── ui/               # Shared component library
│   ├── config-typescript/  # Shared tsconfig files
│   ├── config-eslint/    # Shared ESLint configs
│   ├── utils/            # Shared utilities
│   └── api-client/       # Generated API client
├── turbo.json
├── package.json          # Root workspace definition
└── pnpm-workspace.yaml
```

```yaml
# pnpm-workspace.yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

```json
// package.json (root)
{
  "name": "monorepo",
  "private": true,
  "scripts": {
    "build": "turbo build",
    "dev": "turbo dev",
    "lint": "turbo lint",
    "test": "turbo test",
    "type-check": "turbo type-check",
    "clean": "turbo clean && rm -rf node_modules"
  },
  "devDependencies": {
    "turbo": "^2.0.0"
  }
}
```

---

## `turbo.json` — Task Pipeline

```json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "inputs": ["src/**", "package.json", "tsconfig.json"],
      "outputs": ["dist/**", ".next/**", ".nuxt/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true,
      "dependsOn": ["^build"]
    },
    "test": {
      "dependsOn": ["^build"],
      "inputs": ["src/**", "tests/**", "vitest.config.ts"],
      "outputs": ["coverage/**"]
    },
    "test:e2e": {
      "cache": false,
      "dependsOn": ["build"]
    },
    "lint": {
      "inputs": ["src/**", ".eslintrc.*", "eslint.config.*"]
    },
    "type-check": {
      "dependsOn": ["^build"],
      "inputs": ["src/**", "tsconfig.json"]
    },
    "clean": {
      "cache": false
    }
  }
}
```

### Understanding `dependsOn`

```json
// "^build" — run dependencies' build tasks first (topological)
"dependsOn": ["^build"]

// "build" — run THIS package's build first (same package)
"dependsOn": ["build"]

// Mixed — run all packages' build, and then this package's codegen first
"dependsOn": ["^build", "codegen"]
```

---

## Package Setup

### Shared TypeScript config

```json
// packages/config-typescript/base.json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    "strict": true,
    "exactOptionalPropertyTypes": true,
    "noUncheckedIndexedAccess": true,
    "moduleResolution": "bundler",
    "module": "ESNext",
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "skipLibCheck": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  }
}
```

```json
// apps/web/tsconfig.json
{
  "extends": "@repo/config-typescript/base.json",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["src", "env.d.ts"]
}
```

### Shared ESLint config

```ts
// packages/config-eslint/base.js
import js from '@eslint/js'
import tsPlugin from '@typescript-eslint/eslint-plugin'
import tsParser from '@typescript-eslint/parser'

export default [
  js.configs.recommended,
  {
    plugins: { '@typescript-eslint': tsPlugin },
    parser: tsParser,
    rules: {
      '@typescript-eslint/no-unused-vars': 'error',
      '@typescript-eslint/no-explicit-any': 'warn',
    },
  },
]
```

```js
// apps/web/eslint.config.js
import baseConfig from '@repo/config-eslint/base'
import vuePlugin from 'eslint-plugin-vue'

export default [...baseConfig, ...vuePlugin.configs['flat/recommended']]
```

### Internal package — proper `package.json`

```json
// packages/ui/package.json
{
  "name": "@repo/ui",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.js"
    },
    "./styles": "./src/styles/index.css"
  },
  "scripts": {
    "build": "vite build",
    "dev": "vite build --watch",
    "lint": "eslint src",
    "type-check": "tsc --noEmit"
  },
  "devDependencies": {
    "@repo/config-typescript": "workspace:*",
    "@repo/config-eslint": "workspace:*"
  },
  "peerDependencies": {
    "vue": "^3.0.0"
  }
}
```

### Consuming an internal package

```json
// apps/web/package.json
{
  "dependencies": {
    "@repo/ui": "workspace:*",
    "@repo/utils": "workspace:*"
  }
}
```

---

## Running Tasks

```bash
# Run a task across all packages
turbo build
turbo test
turbo lint

# Run only in specific packages (filter)
turbo build --filter=web
turbo build --filter=@repo/ui
turbo test --filter=./apps/...    # all apps
turbo test --filter=...@repo/ui   # ui and everything that depends on it
turbo build --filter=[HEAD^1]     # only packages changed since last commit

# Force re-run, ignoring cache
turbo build --force

# Run with output mode
turbo build --output-logs=errors-only
turbo build --output-logs=new-only
```

---

## Caching

### What gets cached

Each task is cached by its **inputs hash**. Inputs:
- Files matching `inputs` glob
- Environment variables listed in `env`
- The task's own config
- Turbo version

```json
// turbo.json — declare env vars that affect output
{
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "env": ["NODE_ENV", "VITE_API_URL", "NEXT_PUBLIC_API_URL"],
      "outputs": ["dist/**"]
    }
  }
}
```

### Remote caching with Vercel

```bash
# Authenticate with Vercel Remote Cache
turbo login
turbo link

# Or use custom remote cache
# turbo.json
{
  "remoteCache": {
    "enabled": true,
    "apiUrl": "https://cache.example.com"
  }
}
```

### CI with remote caching

```yaml
# .github/workflows/ci.yml
- name: Cache Turbo
  uses: actions/cache@v4
  with:
    path: .turbo
    key: ${{ runner.os }}-turbo-${{ github.sha }}
    restore-keys: ${{ runner.os }}-turbo-

- name: Build
  run: turbo build test lint
  env:
    TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
    TURBO_TEAM: ${{ vars.TURBO_TEAM }}
```

---

## Dev Workflow

```bash
# Start all apps in dev mode (runs dependsOn builds first)
turbo dev

# Start specific app only
turbo dev --filter=web

# Watch mode for a shared package
cd packages/ui && pnpm dev
```

---

## Audit Checklist

1. **Missing `outputs` in `turbo.json`** — Turbo can't cache tasks without knowing what files they produce; build artifacts are rebuilt every time
2. **`cache: false` on `build`** — disabling cache for build tasks defeats the purpose of Turbo; only set `cache: false` for tasks that genuinely cannot be cached (dev servers, E2E tests)
3. **Env vars not declared in `env`** — environment variables that affect build output (API URLs, feature flags) not listed; cache hits return stale builds
4. **Circular package dependencies** — package A depends on B which depends on A; Turbo cannot resolve task order
5. **Consuming `src/` directly instead of `dist/`** — app imports `@repo/ui/src/...` instead of the built output; works in dev but breaks in production CI where packages aren't watched
6. **All packages using `"*"` as version** — workspace protocol `workspace:*` is correct but peer deps should still declare valid semver ranges for publishing
7. **No `--filter` in CI for affected packages** — running `turbo test` on every push even when only unrelated packages changed; use `--filter=[HEAD^1]` or affected package detection
8. **Shared config packages not built** — TypeScript config packages that export `.ts` files aren't compiled; consuming packages get type errors in CI
