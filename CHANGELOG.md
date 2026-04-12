# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Markdown linting with `markdownlint-cli2`: `pnpm lint:md` and `pnpm lint:fix:md` scripts, `.markdownlint.json` config
- Husky pre-commit hook running `pnpm lint:md` on every commit
- Switched package manager from npm to pnpm 10.33.0 (`packageManager` field in `package.json`)
- `.markdownlint.json` config with project-appropriate rule configuration
- `.vscode/extensions.json` recommending `vscode-markdownlint` and `code-spell-checker`
- `.vscode/settings.json` with fix-on-save and markdown editor settings
- `node_modules/` to `.gitignore`; `.vscode/` removed from `.gitignore` (config now tracked)

### Changed

- `nuxt-ddd`: improved `value-objects.md` — reworked Factory Method and Constructor Creation sections with generic examples, `type` discriminant (replacing `kind`), camelCase union variants (replacing kebab-case)
- `nuxt-ddd`: improved `domain-errors.md` — richer discriminated union section with caller example and decision table; extended hierarchy with `instanceof` vs `error.code` guidance
- `nuxt-ddd`: improved `result-type.md` — added `AsyncResult<T, E>` alias, utility functions (`mapResult`, `flatMapResult`, `combineResults`, `unwrapOr`, `assertNever`), exhaustive switch pattern, async chaining example
- `nuxt-ddd`: improved `domain-events.md` — two dispatch approaches (repository vs EventBus port), full Nuxt/Nitro integration section, `NitroEventBus` infrastructure example, explicit browser boundary explanation
- `nuxt-ddd`: improved `nuxt-layer-wiring.md` — full layer architecture diagram with import rules table, client-side wiring section (composable as DI root), pages/components rules with Vue examples, server-side wiring section
- `nuxt-ddd`: improved `anti-corruption-layer.md` — external DTO types moved to `infrastructure/external/`; domain defines port only; mapper parameters are plain primitives, not external DTOs
- `nuxt-ddd`: improved `policies-strategy-registry.md` — fully generalized examples (no pricing/visitor domain); added stateless vs stateful strategy distinction; `FlatStrategy` added alongside `TieredStrategy`
- `nuxt-ddd`: updated `SKILL.md` layer map to reflect `infrastructure/client/`, `infrastructure/server/`, `infrastructure/external/` split; updated Core Principles and Common Mistakes

## [1.2.0] - 2026-04-12

### Added

- `go-developer` plugin with audit agent and 9 skills: `idiomatic-go`, `project-layout`, `cli`, `http-api`, `concurrency`, `database`, `modules`, `dependency-injection`, `testing`
- `nuxt-ddd` skill for `frontend-developer` — Domain-Driven Design patterns in Nuxt/TypeScript split across 11 pattern files: `value-objects`, `entities-aggregates`, `domain-events`, `use-cases`, `result-type`, `repository`, `anti-corruption-layer`, `policies-strategy-registry`, `domain-errors`, `composable-bridge`, `nuxt-layer-wiring`

## [1.1.0] - 2026-03-12

### Added

- `frontend-developer` plugin with audit agent and 14 skills: `unit-testing`, `storybook`, `e2e-testing`, `a11y-testing`, `vue`, `nuxt`, `vite`, `turborepo`, `pnpm`, `build-pipeline`, `component-design`, `state-management`, `performance`, `css-architecture`, `api-layer`
- `astro` skill for `frontend-developer` — Astro Islands Architecture, hydration directives, content collections, SSR/SSG/hybrid modes
- `husky` skill for `general-developer` — pre-commit hooks, lint-staged integration, commitlint, CI parity
- `dangerfile` skill for `general-developer` — Danger PR automation, rule authoring, severity levels, CI integration

## [1.0.0] - 2026-03-08

### Added

- `general-developer` plugin with agent and 13 skills
- Skills: `github-repo`, `dry`, `die`, `kiss`, `yagni`, `solid`, `soc`, `tda`, `gigo`, `bduf`, `security`, `testing`
- Marketplace metadata in `.claude-plugin/marketplace.json`
