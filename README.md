# messeb Skills

A Claude Code plugin marketplace that provides plugins that add skills and agents usable in both [**Claude Code CLI**](https://code.claude.com/docs/en/overview) and [**GitHub Copilot CLI**](https://github.com/features/copilot/cli).

---

## Installation

### Add the marketplace

Register this marketplace as a source in Claude Code:

```
/plugin marketplace add https://github.com/messeb/skills
```

### Install a plugin

```
/plugin install general-developer@messeb
```

### Remove the marketplace

```
/plugin marketplace remove messeb --force
```

---

## Available Plugins

### `general-developer`

Language-agnostic software engineering principles applicable to any codebase and technology stack.

**Installation**
```
/plugin install general-developer@messeb
```

**Agent**

| Agent | Description |
|-------|-------------|
| `general-developer` | Audits a codebase against all skills, produces a structured report with severity-ranked findings, and offers to apply fixes |

**Skills**

| Skill | Description |
|-------|-------------|
| `github-repo` | Sets up, audits, or syncs all GitHub repository files (README, LICENSE, community files, templates, and more) |
| `dry` | Don't Repeat Yourself — identifies knowledge duplication |
| `die` | Duplication Is Evil — detects structural and logical duplication by failure mode |
| `kiss` | Keep It Simple — flags over-engineering and unnecessary complexity |
| `yagni` | You Aren't Gonna Need It — prevents speculative development |
| `solid` | SOLID principles — single responsibility, open/closed, Liskov, interface segregation, dependency inversion |
| `soc` | Separation of Concerns — evaluates layering and boundary clarity |
| `tda` | Tell Don't Ask — identifies procedural logic that should be encapsulated in objects |
| `gigo` | Garbage In, Garbage Out — reviews input validation and data quality boundaries |
| `bduf` | Big Design Up Front — identifies over-planned, under-iterated architecture |
| `security` | OWASP Top 10, secrets management, authentication, and dependency hygiene |
| `testing` | Testing pyramid balance, coverage gaps, and test anti-patterns |
| `husky` | Husky pre-commit hooks — lint-staged integration, commitlint, hook timing, and CI parity |
| `dangerfile` | Danger PR automation — rule authoring, severity levels, actionable messaging, and CI integration |

### `frontend-developer`

Skills and an audit agent for modern frontend development — Vue, Nuxt, React, Vite, Turborepo, pnpm, testing, accessibility, performance, and more.

**Installation**
```
/plugin install frontend-developer@messeb
```

**Agent**

| Agent | Description |
|-------|-------------|
| `frontend-developer` | Audits a frontend codebase against all skills, detects the project stack, produces a structured report with severity-ranked findings grouped by Testing / Framework / Tooling / Architecture, and offers to apply fixes |

**Skills**

| Category | Skill | Description |
|----------|-------|-------------|
| Testing | `unit-testing` | Component and composable unit tests with Vitest/Jest, Vue Test Utils, React Testing Library, mocking, and test data factories |
| Testing | `storybook` | Story authoring with CSF3, interaction tests, accessibility checks, and visual regression with Chromatic |
| Testing | `e2e-testing` | Playwright end-to-end tests — page objects, auth state reuse, network interception, and CI integration |
| Testing | `a11y-testing` | WCAG 2.1 AA compliance, axe-core, keyboard navigation, ARIA patterns, and screen reader testing |
| Framework | `vue` | Vue 3 Composition API, reactivity model, composables, `<script setup>`, performance, and common pitfalls |
| Framework | `nuxt` | Nuxt 3 rendering modes (SSR/SSG/ISR/hybrid), `useFetch`, routing conventions, middleware, and SEO |
| Tooling | `vite` | Vite config best practices — plugins, environment variables, chunk splitting, and build optimization |
| Tooling | `turborepo` | Turborepo monorepo setup — `turbo.json` pipeline, caching strategy, task dependencies, and CI integration |
| Tooling | `pnpm` | pnpm workspace — catalog for centralized versions, filtering, lockfile discipline, and Changesets |
| Tooling | `build-pipeline` | Full GitHub Actions CI/CD — lint, type-check, test, build, preview deploy, E2E gate, and release stages |
| Architecture | `component-design` | Props API design, slots, atomic design, avoiding prop drilling, headless components, and compound patterns |
| Architecture | `state-management` | Choosing between local state, TanStack Query (server state), Pinia/Zustand (global state), and form libraries |
| Architecture | `performance` | Core Web Vitals, bundle analysis, code splitting, image optimization, list virtualization, and rendering performance |
| Architecture | `css-architecture` | Design tokens, Tailwind CSS, CSS Modules, scoped styles, dark mode, and specificity management |
| Architecture | `api-layer` | Typed HTTP client, OpenAPI codegen, centralized error handling, token refresh, and MSW for testing |
| Framework | `astro` | Astro Islands Architecture — hydration directives, content collections, SSR/SSG/hybrid modes, and cross-island state |
| Architecture | `nuxt-ddd` | Domain-Driven Design in Nuxt/TypeScript — value objects, entities, aggregates, domain events, use cases, Result type, repositories, policies, strategy registry, anti-corruption layer, composable bridge, and full client/server layer wiring |

### `go-developer`

Skills and an audit agent for Go CLI tools and backend services — idiomatic Go, project layout, Cobra CLI, HTTP APIs, concurrency, database access, modules, and testing.

**Installation**
```
/plugin install go-developer@messeb
```

**Agent**

| Agent | Description |
|-------|-------------|
| `go-developer` | Audits a Go codebase against all skills, detects the application type (CLI / HTTP API / mixed), produces a structured report with severity-ranked findings, and offers to apply fixes |

**Skills**

| Category | Skill | Description |
|----------|-------|-------------|
| Language | `idiomatic-go` | Error handling, naming conventions, interface design, zero values, and common Go pitfalls |
| Structure | `project-layout` | Standard `cmd/` / `internal/` / `pkg/` layout, layer boundaries, config loading, and Makefile conventions |
| CLI | `cli` | Cobra commands and subcommands, Viper config, flag design, argument validation, shell completion, and graceful shutdown |
| Backend | `http-api` | Gin framework — server setup, route groups, middleware chain, request binding with validation, JSON responses, and health endpoints |
| Language | `concurrency` | Goroutines, channels, `context` cancellation, `sync` primitives, worker pools, and leak prevention |
| Data | `database` | GORM, sqlc, sqlx, and pgx — choosing the right tool, repository pattern, transactions, migrations, and connection pooling |
| Tooling | `modules` | `go.mod` / `go.sum`, dependency management, versioning, Go workspaces, vendoring, and private modules |
| Tooling | `dependency-injection` | Wire (compile-time DI by Google) and Fx (runtime DI by Uber) — providers, modules, lifecycle hooks, and interface binding |
| Quality | `testing` | Table-driven tests, subtests, `testify`, interface mocks, `httptest`, integration tests, benchmarks, and race detection |

---

## Usage with Coding CLI

### Run a skill

Invoke any skill by its name as a slash command inside a Claude Code session:

```
/general-developer:dry
/general-developer:security
/general-developer:husky
/general-developer:dangerfile
/frontend-developer:vue
/frontend-developer:astro
/frontend-developer:nuxt-ddd
/frontend-developer:performance
/frontend-developer:a11y-testing
/go-developer:cli
/go-developer:http-api
/go-developer:concurrency
/go-developer:testing
```

Claude will execute the skill's instructions against your current working directory.

### Run the audit agent

Each plugin ships an audit agent that checks your codebase against **all its skills at once** and produces a prioritised report:

```
/general-developer
/frontend-developer
/go-developer
```

The agent will:
1. Detect the project's tech stack and structure
2. Run every relevant skill as an audit lens
3. Output a summary table with `high / medium / low` findings per skill
4. Offer to apply fixes one by one

---

## Repository Structure

```
skills/
├── .claude-plugin/
│   └── marketplace.json              # Marketplace index
└── plugins/
    ├── general-developer/
    │   ├── .claude-plugin/
    │   │   └── plugin.json           # Plugin manifest (registers agents)
    │   ├── agents/
    │   │   └── general-developer.md
    │   └── skills/
    │       ├── dry/SKILL.md
    │       ├── security/SKILL.md
    │       └── ...
    └── frontend-developer/
        ├── .claude-plugin/
        │   └── plugin.json
        ├── agents/
        │   └── frontend-developer.md
        └── skills/
            ├── unit-testing/SKILL.md
            ├── vue/SKILL.md
            ├── vite/SKILL.md
            └── ...
```

Skills are discovered automatically from the `skills/` directory. Agents must be explicitly registered in `plugin.json`.
