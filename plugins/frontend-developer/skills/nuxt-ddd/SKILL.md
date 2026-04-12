---
name: nuxt-ddd
description: Use when designing or implementing Domain-Driven Design patterns in a Nuxt/TypeScript monorepo. Covers value objects, entities, aggregates, domain events, repositories, use cases, policies, Result types, domain errors, anti-corruption layers, strategy registries, and the Nuxt-specific composable bridge. Trigger on questions about where logic belongs, how to model domain concepts, how to structure layers, or how to wire DDD to Vue components.
---

# Nuxt Domain-Driven Design

DDD in Nuxt separates concerns into four strict layers — domain, application, infrastructure, presentation — where dependencies only flow inward. The domain layer has zero framework knowledge; Nuxt, Vue, and `$fetch` are infrastructure details.

## Layer Map

```
pages/ & components/   ← Presentation: props in, events out — no use cases, no repos
composables/           ← Presentation bridge: wire HttpRepo + UseCase, map Result → reactive state
application/           ← Use cases, Result / AsyncResult type, DTOs, Context (composition root)
domain/                ← Value objects, entities, aggregates, events, policies,
                          repository interfaces, external service ports (ports only, no DTO shapes)
infrastructure/
  client/              ← HTTP repositories ($fetch) — browser runtime only
  server/              ← DB/email/external-API repositories — Nitro runtime only
  external/            ← External DTO shapes, external service interfaces, ACL adapters
internal/              ← Private implementation details (test fakes, glue code)
                          never imported by production layer code
server/api/            ← Nitro routes: parse body → wire DI → execute → map Result → HTTP
```

**Dependency rule**: each layer may only import from layers below it. `domain/` imports nothing from this project. External DTO types live in `infrastructure/external/` — never in `domain/`. `internal/` is not a layer — it is a visibility boundary: touching it from outside is treated as a bug.

## Section Guide

| Section | File | Consult When |
|---------|------|-------------|
| **Value Objects** | [patterns/value-objects.md](patterns/value-objects.md) | Creating/modifying types that wrap a primitive with validation (email, username, amount, slug, etc.) |
| **Entities & Aggregates** | [patterns/entities-aggregates.md](patterns/entities-aggregates.md) | Designing objects with identity, grouping related value objects, managing aggregate invariants, or loading/mutating/saving over time |
| **Domain Events** | [patterns/domain-events.md](patterns/domain-events.md) | Raising events after state changes, wiring event handlers, or implementing audit trails |
| **Repository Pattern** | [patterns/repository.md](patterns/repository.md) | Defining or implementing persistence interfaces, external service ports, swapping backends, or handling dual client/server contexts |
| **Anti-Corruption Layer** | [patterns/anti-corruption-layer.md](patterns/anti-corruption-layer.md) | Integrating with external APIs, legacy systems, or third-party models without polluting the domain |
| **Use Cases** | [patterns/use-cases.md](patterns/use-cases.md) | Orchestrating domain logic, validating input, applying policies, and returning structured results |
| **Result Type** | [patterns/result-type.md](patterns/result-type.md) | Propagating errors without exceptions, chaining operations, or mapping errors at layer boundaries |
| **Policies & Strategy Registry** | [patterns/policies-strategy-registry.md](patterns/policies-strategy-registry.md) | Encoding business rules that span aggregates, require external data, or select a strategy at runtime |
| **Domain Errors** | [patterns/domain-errors.md](patterns/domain-errors.md) | Designing error hierarchies, adding error codes, or surfacing field-level validation failures |
| **Composable Bridge** | [patterns/composable-bridge.md](patterns/composable-bridge.md) | Connecting use cases to Vue components, managing form state, live validation, or async submission |
| **Nuxt Layer Wiring** | [patterns/nuxt-layer-wiring.md](patterns/nuxt-layer-wiring.md) | Understanding the full layer architecture, import rules per layer, composable DI wiring, page/component rules, Nitro route DI wiring, Context composition root, or client/server symmetry |

## Core Principles

1. **Domain is framework-free.** No `ref()`, no `$fetch`, no Nitro imports inside `domain/` or `application/`.
2. **Value objects self-validate.** If a value object exists, it is valid. Validation lives in `create()`, not at call sites.
3. **Results, not exceptions.** Use `Result<T, E>` (sync) and `AsyncResult<T, E>` (async) across domain and application layers. Only `throw` at Nitro boundaries via `createError`. Repositories return `AsyncResult<void, DomainError>` — never `Promise<void>`.
4. **Aggregates own consistency.** An aggregate root is the only entry point for mutations. No external code reaches into aggregate internals.
5. **Composables are the presentation boundary.** A composable creates repository + use case, calls `execute()`, and maps results to Vue reactive state. Pages stay dumb. **Components never call domain VOs directly** — that call always lives in a composable.
6. **Repository interface in domain, implementations in infrastructure.** The domain defines the contract for every external dependency — persistence, email, payment, external APIs. Infrastructure fulfills it.
7. **One use case per user action.** Use cases are thin orchestrators: validate → create aggregate → apply policy → raise event → persist → return result.
8. **External models never enter the domain.** External DTO types and third-party service interfaces belong in `infrastructure/external/`. The domain defines only the port (what it needs, in domain terms). Translate at the boundary via an ACL adapter in infrastructure.

## Common Mistakes

1. **Domain VO called directly in a component** — `Email.create()`, `Username.create()`, etc. must only be called from composables, never from `<script setup>`. Create a dedicated live-validation composable and import that instead.
2. **Throwing in use cases** — wrap errors in `fail()` and return `Result`; callers must not be surprised by uncaught exceptions.
3. **`$fetch` inside a domain class** — `$fetch` is infrastructure; inject a repository interface instead.
4. **Fat use cases with business rules** — rules that protect invariants belong in a `Policy`; rules intrinsic to a concept belong in the value object or entity.
5. **Aggregate accessed outside its root** — never mutate a child value object by reaching past the aggregate root.
6. **One repository for client + server** — client sends HTTP; server talks to DB/email. Always create two implementations.
7. **External DTO types in `domain/`** — `ExternalFoo` shapes and third-party service interfaces belong in `infrastructure/external/`, not in `domain/externalTypes.ts`. The domain defines ports (interfaces in domain terms); infrastructure defines the external shapes and adapters.
8. **`internal/` imported by production code** — files in `internal/` are private implementation details; importing them from `composables/`, `server/`, or `application/` is a bug.
9. **Repository `save()` returns `void`** — `void` silently swallows errors. Always return `AsyncResult<void, DomainError>` so callers can detect and propagate persistence failures.
10. **Domain events dispatched before save** — an unsaved aggregate is not yet a fact. Always `save()` first, then `pullDomainEvents()` and dispatch. Never dispatch before the aggregate is persisted.
11. **Domain events raised in composables** — events are a server-side concern in Nuxt. Composables react to the HTTP response (the result), not to domain events.
12. **Request parsing inside application services** — converting `request: any` with snake_case fields belongs in the Nitro route handler, not inside use cases. Use cases receive a typed input DTO.
13. **Naming application-layer orchestrators "Service"** — `CalculatorService` reads like a domain service. Use the `UseCase` suffix (`PlaceOrderUseCase`) to signal application-layer orchestration.
14. **Context typed as concrete class instead of interface** — `readonly repo: InMemoryRepository` leaks the implementation. Always type Context properties as the interface: `readonly repo: Repository`.
