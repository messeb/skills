# messeb Skills

A Claude Code plugin marketplace that provides plugins that add skills and agents usable in both [**Claude Code CLI**](https://code.claude.com/docs/en/overview) and [**GitHub Copilot CLI**](https://github.com/features/copilot/cli).

---

## Installation

### Add the marketplace

Register this marketplace as a source in Claude Code:

```bash
/plugin marketplace add https://github.com/messeb/skills
```

### Install a plugin

```bash
/plugin install general-developer@messeb
```

### Remove the marketplace

```bash
/plugin marketplace remove messeb --force
```

---

## Available Plugins

### `general-developer`

Language-agnostic software engineering principles applicable to any codebase and technology stack.

#### Installation

```bash
/plugin install general-developer@messeb
```

#### Agent

| Agent | Description |
|-------|-------------|
| `general-developer` | Audits a codebase against all skills, produces a structured report with severity-ranked findings, and offers to apply fixes |

#### Skills

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

#### Installation

```bash
/plugin install frontend-developer@messeb
```

#### Agent

| Agent | Description |
|-------|-------------|
| `frontend-developer` | Audits a frontend codebase against all skills, detects the project stack, produces a structured report with severity-ranked findings grouped by Testing / Framework / Tooling / Architecture, and offers to apply fixes |

#### Skills

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
| Architecture | `seo-geo-optimization` | SEO/GEO in a component framework — rendering strategy for crawlability, hydration and islands policy, LCP/CLS/INP at component level, server-rendered head tags and JSON-LD, Lighthouse CI as a PR gate |

### `go-developer`

Skills and an audit agent for Go CLI tools and backend services — idiomatic Go, project layout, Cobra CLI, HTTP APIs, concurrency, database access, modules, and testing.

#### Installation

```bash
/plugin install go-developer@messeb
```

#### Agent

| Agent | Description |
|-------|-------------|
| `go-developer` | Audits a Go codebase against all skills, detects the application type (CLI / HTTP API / mixed), produces a structured report with severity-ranked findings, and offers to apply fixes |

#### Skills

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

### `product-discovery`

Skills and a guiding agent for product discovery and requirements elicitation — collaborative domain modeling, user research, stakeholder alignment, and validation at scale. Every skill asks for the idea, problem, and scope it needs, then produces a filled Markdown template.

#### Installation

```bash
/plugin install product-discovery@messeb
```

#### Agent

| Agent | Description |
|-------|-------------|
| `product-discovery` | Diagnoses what is actually unknown, recommends and sequences the right methods, runs their intake, produces the artifacts, and audits existing discovery work for traceability, evidence, coverage, and currency gaps |

#### Skills

| Category | Skill | Description |
|----------|-------|-------------|
| Research | `stakeholder-interviews` | Stakeholder mapping, guide design, question types, laddering, note-taking, cross-interview synthesis |
| Research | `contextual-inquiry` | Field observation with the master/apprentice model — workarounds, artifacts, interruptions, work models, say/do gaps |
| Research | `jobs-to-be-done` | Job statements, four forces of switching, switch interviews, job maps, outcome statements and opportunity scores |
| Research | `questionnaires` | When to survey, sampling and bias, wording rules, scales, standard instruments (SUS, UMUX-Lite, NPS, CES), pilots, analysis |
| Framing | `design-thinking` | Personas and proto-personas, empathy maps, customer journey maps, POV statements and How Might We questions |
| Framing | `impact-mapping` | Why → who → how → what maps, measurable goals, behaviour-change impacts, deliverables as experiments, visible scope cuts |
| Framing | `goal-modeling` | KAOS AND/OR goal trees, requirements vs expectations vs domain properties, obstacle analysis, i\* dependency and softgoal models |
| Alignment | `workshop-facilitation` | JAD roles, workshop design backwards from the outcome, diverge/converge structure, decision protocols, conflict handling, hybrid setup |
| Analysis | `document-system-analysis` | Source inventory and trust ranking, regulatory traceability, legacy code archaeology, data and log analysis, contradiction handling |
| Analysis | `risk-conflict-analysis` | Conflict types and resolution strategies, five-dimension feasibility checks, pre-mortem, risk storming, assumption mapping, risk register |
| Domain modeling | `event-storming` | Big Picture / Process / Design level workshops — sticky-note grammar, facilitation script, timeboxes, bounded contexts and aggregates |
| Domain modeling | `domain-storytelling` | Pictographic actor / work-object / activity stories, scope axes, recording session script, glossary harvesting, derived requirements |
| Domain modeling | `context-mapping` | Bounded contexts, boundary heuristics, the nine DDD relationship patterns, Bounded Context Canvas, core/supporting/generic classification |
| System modeling | `process-modeling` | BPMN subset, pools and lanes, gateways, timers, exception and irregular flows, handoff and cycle-time measurement, Mermaid swimlanes |
| System modeling | `state-machines` | Entity lifecycles — states, events, guards, actions, invariants, complete transition matrix, timeouts, idempotency, derived test cases |
| System modeling | `data-modeling` | Conceptual / logical / physical ER models, identifiers and cardinality, 3NF and deliberate denormalisation, historisation, GDPR erasure |
| System modeling | `c4-diagrams` | C4 levels 1–4 plus landscape, dynamic and deployment views, abstraction discipline, legends, diagrams-as-code workflow |
| Specification | `use-case-modeling` | Cockburn goal levels, actors, preconditions and guarantees, main success scenario, extensions for every exception path |
| Specification | `user-stories` | Story formats, INVEST, the 3 C's, SPIDR and vertical splitting patterns, acceptance criteria styles, Definition of Ready/Done |
| Specification | `story-mapping` | Backbone of user activities, narrative flow vs detail axes, walking skeleton, horizontal release slices, scope negotiation |
| Specification | `example-mapping` | 25-minute four-colour card session — rules, examples, questions, split signals, Gherkin bridge |
| Specification | `gherkin-bdd` | Feature/Rule/Scenario structure, declarative vs imperative style, step definition design, tags, living documentation |
| Specification | `requirement-templates` | EARS patterns, the MASTeR/Rupp sentence template, ambiguity traps, ISO 29148 quality criteria, template selection |
| Specification | `srs-templates` | Volere, IEEE 830, ISO/IEC/IEEE 29148 — when a formal SRS is justified, the Volere shell and fit criterion, tailoring, approval |
| Specification | `glossary` | Ubiquitous language per bounded context, definition rules, homonyms and translation tables, harvesting and enforcement |
| Specification | `prototyping` | Fidelity selection, paper to Wizard of Oz to fake door, the state inventory (empty/loading/error/max), annotation for handover |
| Specification | `api-contracts` | Contract-first OpenAPI and AsyncAPI, resource and event modelling, RFC 9457 errors, versioning and compatibility, contract testing |
| Specification | `formal-specs` | TLA+/PlusCal, Alloy, and Z — when formal specification pays, safety and liveness properties, modelling failures, refinement |
| Specification | `quality-attributes` | Quality Attribute Workshop, six-part scenarios, ISO/IEC 25010:2023 checklist, utility trees, ATAM-lite trade-off and sensitivity points |
| Validation | `requirements-reviews` | The formality ladder from desk check to Fagan inspection, requirement defect taxonomy, perspective-based reading, review metrics |
| Validation | `three-amigos` | The three perspectives and their questions, the 25-minute format, when to add a fourth amigo, remote and asynchronous variants |
| Validation | `acceptance-test-definition` | ATDD cycle, systematic case derivation (partitions, boundaries, decision tables, state transitions), test data, automation layers |
| Validation | `usability-testing` | Study types and sample size, task design, think-aloud moderation, severity rating, benchmark metrics, accessibility testing |
| Validation | `model-checking` | TLC / Apalache / Alloy Analyzer, state explosion tactics, fairness, reading counterexamples, simulation, CI integration |
| Validation | `traceability` | Trace model and link types, identifier discipline, orphan and coverage checks, impact analysis, regulatory traceability |
| Management | `prioritization` | MoSCoW, WSJF and cost of delay, Kano, RICE, opportunity scoring, Buy a Feature, Prune the Product Tree, revisit triggers |
| Management | `backlog-refinement` | Refinement funnel and horizons, cadence, sizing approaches, honest DoR/DoD, refinement health metrics, backlog hygiene |
| Management | `change-management` | When change control is justified, the CR lifecycle, impact analysis, change control board, versioning, communication obligations |
| Management | `baselining` | What a baseline contains, entry criteria and approval, immutability and naming, partial and rolling baselines in agile delivery |

Every skill follows the same shape: an intake question set (idea, problem, scope, participants, constraints), the method or session script, a fillable Markdown output template with Mermaid diagrams where a diagram helps, an anti-pattern table, and a checklist.

---

### `python-ai-developer`

Skills and an audit agent for Python AI application development — project tooling with uv, FastAPI services, a provider-agnostic LLM layer across OpenAI, Anthropic, Gemini, Grok and Mistral, orchestration frameworks, OCR / ML / operations-research workloads, containers, IDE run-and-debug configuration, and notebooks.

#### Installation

```bash
/plugin install python-ai-developer@messeb
```

#### Agent

| Agent | Description |
|-------|-------------|
| `python-ai-developer` | Detects the project profile (package manager, framework, providers, AI workloads), audits the codebase against every skill, and produces a severity-ranked report with `file:line` findings ordered by the cost of being wrong |

#### Skills

| Category | Skill | Description |
|----------|-------|-------------|
| Tooling | `uv` | Project init, dependency groups vs extras, the lockfile and `--frozen`, Python pinning, workspaces, PyTorch/CUDA index configuration, Docker and CI usage, migration from pip/Poetry/Conda |
| Tooling | `project-structure` | src layout, module boundaries that keep provider SDKs at the edge, typed settings with `SecretStr`, structured logging, ruff/mypy/pytest configuration |
| Tooling | `ide-setup` | VS Code `launch.json` and PyCharm run configurations for API, worker, tests and container attach; debugpy path mappings; async and multi-worker debugging pitfalls |
| Tooling | `notebooks` | Kernel setup with uv, the import-from-`src` rule, nbstripout and jupytext, papermill parameterised reports, notebooks in CI, secrets and data hygiene |
| Tooling | `containerization` | Multi-stage Dockerfiles with uv layer caching, non-root hardening, OCR/ML system dependencies, GPU images, model-weight strategies, Compose with remote debugging |
| API | `fastapi` | App factory and lifespan-managed clients, dependency injection, Pydantic v2 models, the blocking-call trap, problem+json errors, streamed uploads, SSE with disconnect handling |
| API | `async-and-background-work` | Inline vs job vs queue, idempotency keys that prevent double-charging, bounded fan-out, cancellation and deadlines, queue selection, worker deployment |
| LLM | `llm-providers` | OpenAI, Anthropic, Gemini, Grok and Mistral — client setup, resolving model IDs instead of hardcoding them, capability matrix, token and cost accounting, error surfaces |
| LLM | `provider-abstraction` | A `Protocol`-based client with normalized messages, usage and errors; adapters, registry, routing and fallback; build-vs-gateway; contract testing |
| LLM | `structured-output` | Native schema-constrained output per provider, schema design models can satisfy, the repair loop, provenance verification, schema versioning |
| LLM | `tool-calling` | Tool surface design, the agent loop and its four termination conditions, recoverable tool errors, provider differences, prompt-injection and confused-deputy defences |
| LLM | `llm-reliability-and-cost` | One retry policy with jitter, rate limiting, prompt caching that actually hits, model tiering, batch APIs, enforced budgets, cost attribution and alerts |
| LLM | `orchestration-frameworks` | When raw SDKs beat a framework; LangChain and LCEL; LangGraph for durable stateful agents with checkpointing and human-in-the-loop; PydanticAI, Instructor, LlamaIndex, Haystack |
| LLM | `dspy` | Signatures, modules and optimizers, writing metrics that mean something, train/dev/test discipline, compiled-artifact versioning, teacher-student cost reduction |
| Quality | `llm-testing-and-evals` | The pyramid for non-deterministic code, fakes and recorded fixtures, labelled evaluation sets, metrics and LLM-as-judge biases, CI gating, canary rollout |
| Solutions | `ocr` | Engine selection per document class, preprocessing that decides accuracy, text-layer detection, OCR-then-LLM with provenance, CER/WER measurement, performance and operations |
| Solutions | `machine-learning` | ML-vs-LLM decision, reproducible training, leakage-free pipelines, registry and serialization, serving and train/serve skew, drift monitoring and retraining gates |
| Solutions | `operations-research` | Recognising an OR problem, CP-SAT vs MILP vs routing, modelling patterns, soft constraints, infeasibility diagnosis, determinism, scaling, safe LLM combination |

Every skill follows the same shape: when to use it and when not to, the method with runnable Python, an anti-pattern table, and a checklist.

---

### `growth-hacking`

Skills and an audit agent for growth practice — strategy and product-market fit, the experiment operating rhythm, the AARRR funnel from acquisition through revenue, and the legal and ethical limits that apply in the EU and Germany.

#### Installation

```bash
/plugin install growth-hacking@messeb
```

#### Agent

| Agent | Description |
|-------|-------------|
| `growth-hacking` | Finds the stage that actually constrains growth, audits the practice and funnel against every skill, and produces a severity-ranked report plus a prioritised experiment backlog — refusing to recommend acquisition spend before retention is established |

#### Skills

| Category | Skill | Description |
|----------|-------|-------------|
| Foundations | `growth-fundamentals` | A definition that survives scrutiny, the five pillars, applicability to B2B and established companies, hack versus lever, comparison with adjacent models, and the failure modes |
| Foundations | `growth-strategy` | The first-mover myth, a one-page strategy, positioning as a growth constraint, defensibility, and competitor analysis from public sources |
| Foundations | `growth-loops` | Loop anatomy and the four common types, k-factor and cycle time, saturation and decay, diagnosing a broken loop, the flywheel, and when a funnel is still right |
| Foundations | `customer-research` | Interview technique that avoids false positives, switching forces, behavioural segmentation, evidenced versus proto-personas, and converting research into hypotheses |
| Foundations | `product-market-fit` | Retention curves, the disappointment survey read honestly, riskiest-assumption tests versus MVPs, time to value, and what to do when the evidence says no fit |
| Foundations | `growth-legal-and-ethics` | GDPR/DSGVO bases and consent, email under UWG, B2B cold outreach, influencer disclosure, sweepstakes, price indication and cancellation rules, DSA dark-pattern prohibitions, and a tiered review process |
| Process | `growth-process` | The experiment cycle, weekly cadence and meeting structure, learning over optimising, optimise-before-pivot, guardrails, and the emotional cycle of change |
| Process | `north-star-and-metrics` | Choosing a north star that resists gaming, the KPI tree, AARRR, cohort and retention analysis, CAC/LTV/payback, leading indicators, and benchmark scepticism |
| Process | `growth-team` | Independent versus embedded models, roles, engineering access as the deciding factor, decision rights, artefacts, ramping, and organisational blockers |
| Process | `experiment-design` | The experiment card and hypothesis format, one primary metric plus guardrails, MDE and sample size, stopping rules, validity threats, and low-traffic alternatives |
| Process | `experiment-prioritization` | ICE, PIE and BRASS with worked examples, score calibration, expected-value ranking, effort estimation, and portfolio balance |
| Process | `idea-generation` | The nineteen channels as a coverage checklist, mining your own data, brainwriting 6-3-5, the Disney method, SCAMPER, waterholes, and converting ideas to testable form |
| Process | `idea-validation` | The validation ladder, landing-page smoke tests, painted doors handled ethically, concierge and Wizard of Oz, no-code, pre-sales, and reading evidence strength honestly |
| Funnel | `acquisition` | Channel portfolio strategy, the probe-to-scale test protocol, cost per retained customer, attribution limits and incrementality, saturation and diversification risk |
| Funnel | `content-and-seo-growth` | Content as a compounding loop, topic selection by business value, formats that earn citations, programmatic and user-generated content, distribution, cohort measurement |
| Funnel | `paid-acquisition` | The lever hierarchy, account structure and learning periods, creative testing at volume, retargeting scepticism, incrementality testing, and consent-compliant tracking |
| Funnel | `social-and-community` | Platform choice by audience, engagement triggers, employee advocacy, owned versus rented community, social listening, and measuring capture rather than followers |
| Funnel | `activation` | Finding the aha moment from cohort data and validating it causally, time to value, landing pages, forms, usability methods, and CTA copy |
| Funnel | `behavioral-psychology` | Persuasion principles applied honestly, the disclosure test, the dark patterns now prohibited in the EU, and testing persuasion with the right guardrails and horizon |
| Funnel | `retention` | Cohort measurement, voluntary versus involuntary churn, habit formation, lifecycle automation with holdouts, honest offboarding, loyalty and expansion |
| Funnel | `referral` | Word of mouth versus sharing versus programmes, incentive design that resists fraud, placement and timing, k-factor, in-product virality, creators and disclosure |
| Funnel | `revenue` | Business model selection, pricing research and value metrics, the freemium conversion problem, expansion and cross-sell, discount discipline, checkout, honest copywriting |

Every skill follows the same shape: when to use it and when not to, the method, an anti-pattern table, and a checklist.

---

## Usage with Coding CLI

### Run a skill

Invoke any skill by its name as a slash command inside a Claude Code session:

```text
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

```text
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

## Contributing

### Setup

```bash
pnpm install
```

Installs dev dependencies and registers the Husky pre-commit hook automatically via the `prepare` script.

### Markdown Linting

All Markdown files are linted with [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) using the rules defined in `.markdownlint.json`.

```bash
pnpm lint:md        # check for violations
pnpm lint:fix:md    # auto-fix where possible
```

The pre-commit hook runs `pnpm lint:md` automatically on every commit. Fix any remaining issues manually or with `pnpm lint:fix:md` before committing.

VS Code users: install the recommended extensions (`.vscode/extensions.json`) to see lint violations inline and apply fixes on save.

---

## Repository Structure

```text
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
