# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres to [Semantic Versioning](https://semver.org/).

## 2026-09-05

### Added

- `product-discovery` plugin with a guiding agent and 11 method skills: `event-storming`, `domain-storytelling`, `example-mapping`, `stakeholder-interviews`, `contextual-inquiry`, `workshop-facilitation`, `impact-mapping`, `design-thinking`, `jobs-to-be-done`, `document-system-analysis`, `questionnaires` — each with an intake question set, a facilitation or session script, a fillable Markdown output template, an anti-pattern table, and a checklist
- `product-discovery` agent that diagnoses the type of unknown, recommends and sequences methods, runs their intake, and audits existing discovery artifacts for traceability, evidence quality, coverage, currency, and decision hygiene
- `product-discovery` modeling and specification skills: `context-mapping` (DDD bounded contexts and the nine relationship patterns), `use-case-modeling` (Cockburn goal levels, extensions), `user-stories` (INVEST, SPIDR splitting, acceptance criteria), `process-modeling` (BPMN subset, pools and lanes, irregular flows), `state-machines` (entity lifecycles, transition matrix, guards, timeouts), `data-modeling` (conceptual/logical/physical ER, historisation, GDPR erasure), `c4-diagrams` (C4 levels plus dynamic and deployment views), `goal-modeling` (KAOS refinement and obstacle analysis, i\* dependencies and softgoals), `quality-attributes` (QAW, six-part scenarios, ISO/IEC 25010:2023, ATAM-lite trade-offs), `risk-conflict-analysis` (conflict resolution strategies, five-dimension feasibility, pre-mortem, assumption mapping, risk register)
- Mermaid diagrams in the output templates of the modeling skills — context maps, BPMN-style swimlane flowcharts, `stateDiagram-v2` lifecycles, `erDiagram` data models, C4 context/container diagrams, sequence and dynamic views, goal refinement and obstacle trees, utility trees, and an assumption `quadrantChart`
- `product-discovery` specification and documentation skills: `gherkin-bdd` (Feature/Rule/Scenario structure, declarative style, step design, living documentation), `requirement-templates` (EARS patterns, MASTeR/Rupp sentence template, ambiguity traps, ISO 29148 quality criteria), `story-mapping` (backbone, walking skeleton, horizontal release slices), `srs-templates` (Volere, IEEE 830, ISO/IEC/IEEE 29148, the Volere shell and fit criterion, tailoring), `glossary` (ubiquitous language per context, homonyms, translation tables, enforcement), `prototyping` (fidelity selection, state inventory, annotation for handover), `formal-specs` (TLA+, Alloy, Z — safety and liveness, modelling failures), `api-contracts` (contract-first OpenAPI/AsyncAPI, RFC 9457 errors, versioning and compatibility, contract testing)
- `product-discovery` validation and verification skills: `requirements-reviews` (formality ladder to Fagan inspection, defect taxonomy, perspective-based reading, metrics), `three-amigos` (the three perspectives, 25-minute format, fourth amigo, remote variants), `acceptance-test-definition` (ATDD cycle, systematic case derivation, test data, automation layers), `usability-testing` (study types, task design, think-aloud moderation, severity rating), `model-checking` (TLC/Apalache/Alloy, state explosion tactics, fairness, counterexample triage, CI integration), `traceability` (trace model, identifier discipline, orphan and coverage checks, impact analysis)
- `product-discovery` management skills: `prioritization` (MoSCoW, WSJF and cost of delay, Kano, RICE, Buy a Feature, Prune the Product Tree), `backlog-refinement` (refinement funnel and horizons, sizing, honest DoR/DoD, health metrics), `change-management` (CR lifecycle, impact analysis, change control board, versioning, communication obligations), `baselining` (baseline contents, entry criteria, immutability, partial and rolling baselines)
- Every Mermaid diagram in the `product-discovery` templates validated against the Mermaid 11 parser
- `seo-geo-optimization` skill for `frontend-developer` — SEO/GEO implementation in a component framework: rendering strategy for crawlability (what must be in the initial HTML for AI crawlers that do not execute JavaScript), per-component hydration and islands policy, LCP/CLS/INP rules at component level, server-rendered head tags and JSON-LD from a single typed source, asset and third-party discipline, and Lighthouse CI as a pull-request gate

### Fixed

- `seo-geo-optimization`: rewrote the skill, which had been committed as an unedited chat transcript — empty `description` frontmatter, assistant meta-commentary as the opening body text, collapsed markdown (headings, tables, and lists flattened onto single lines), unclosed code fences, patch instructions referring to sections of a different document, and content hard-coded to one unrelated project. Scoped it to frontend implementation and cross-referenced the `seo` plugin instead of duplicating its twelve skills. Corrected the claim that `preconnect` is HTTP/2 Server Push; Chrome disabled Server Push by default in Chrome 106

## 2026-05-15

### Added

- `seo` plugin with audit agent and 12 skills: `geo-content`, `meta-tags`, `seo-page-structure`, `crawl-control`, `html5-microdata`, `core-web-vitals`, `image-optimization`, `resource-hints`, `third-party-scripts`, `internal-linking`, `url-structure`, `structured-data-jsonld`
- `release-flow` skill for `general-developer` — Git release flow: branch strategy, `PROJ-NNN` ticket conventions, environment promotion (TEST → QA → UAT → PROD), versioning, tagging, and artifact recipes for Docker, web bundles, libraries, CLI binaries, desktop, and mobile apps
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
