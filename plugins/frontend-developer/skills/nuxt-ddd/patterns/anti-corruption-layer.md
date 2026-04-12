# Anti-Corruption Layer

An Anti-Corruption Layer (ACL) translates between external models and your domain model at the system boundary. Without it, external API shapes, naming conventions, and status codes leak into the domain and pollute it.

## When You Need an ACL

- Calling a third-party REST API (payment provider, shipping service, legacy system)
- Consuming an external event stream with its own schema
- Integrating with a microservice that uses different terminology
- Reading from a database table owned by another team

## Responsibility Split

The domain must never see external shapes. External types are an infrastructure detail:

| Layer | Owns |
| --- | --- |
| `domain/` | Domain model types, port interface — expressed in domain terms only |
| `infrastructure/` | External API shapes, external service interface, adapter, translation function |

The domain defines *what it needs* (the port). Infrastructure defines *how to get it* from the outside world.

## Structure

```text
domain/
  <Concept>.ts              ← domain interface + private concrete classes
  <Concepts>.ts             ← port interface — domain terms only, no external types

infrastructure/
  external/
    External<Concept>Api.ts       ← external DTO shape + external service interface
    External<Concept>Adapter.ts   ← implements port, calls API, translates via ACL mapper
```

## Domain Layer — Port Only

The domain defines the port in its own language. No external types, no API shapes:

```typescript
// domain/<Concepts>.ts — port: what the domain needs, in domain terms
export interface <Concepts> {
  getById(id: string): Promise<<Concept> | undefined>
}

// domain/<Concept>.ts — domain model + private implementations
export interface <Concept> {
  id:   string
  type: 'typeA' | 'typeB'
  // ... domain fields, named in domain terms
}

// Private concrete types — not exported, hidden behind the interface
class TypeA<Concept> implements <Concept> {
  readonly #id: string

  constructor(id: string) {
    this.#id = id
  }

  get id()   { return this.#id }
  get type() { return 'typeA' as const }
  // type-specific derivation lives here, not scattered in use cases
}

class TypeB<Concept> implements <Concept> {
  readonly #id:      string
  readonly #groupId: string

  constructor(id: string, groupId: string) {
    this.#id      = id
    this.#groupId = groupId
  }

  get id()      { return this.#id }
  get type()    { return 'typeB' as const }
  get groupId() { return this.#groupId }
}

// ACL mapper — exported so infrastructure can call it
// Parameters are plain primitives, not external DTO types
export function <concept>FromExternal(
  id:    string,
  type:  'typeA' | 'typeB',
  extra: string,
): <Concept> {
  if (type === 'typeA') return new TypeA<Concept>(id)
  if (type === 'typeB') return new TypeB<Concept>(id, extra)
  throw new Error(`Unknown type: ${type}`)
}
```

Key points:

- Concrete classes are **not exported** — consumers only see the interface
- The mapper's parameters are plain primitives — it never imports external DTO types
- The domain does not import anything from `infrastructure/`

## Infrastructure Layer — External Types and Adapter

External API shapes and the translation live entirely in infrastructure:

```typescript
// infrastructure/external/External<Concept>Api.ts — external types stay here
export type ExternalType = 'type_a' | 'type_b'    // external naming, may differ from domain

export interface External<Concept> {
  uid:        string      // external field names, may be snake_case or abbreviated
  kind:       ExternalType
  group_ref:  string
  // ... other external fields the API returns
}

export interface External<Concept>Service {
  fetchById(id: string): Promise<External<Concept> | undefined>
}
```

```typescript
// infrastructure/external/External<Concept>Adapter.ts — implements the port, owns the translation
import type { <Concepts> } from '../../domain/<Concepts>'
import { <concept>FromExternal } from '../../domain/<Concept>'
import type { External<Concept>Service } from './External<Concept>Api'

export class External<Concept>Adapter implements <Concepts> {
  readonly #service: External<Concept>Service

  constructor(service: External<Concept>Service) {
    this.#service = service
  }

  async getById(id: string) {
    const ext = await this.#service.fetchById(id)
    if (!ext) return undefined

    // ACL translation: map external naming → domain primitives → domain object
    const domainType = ext.kind === 'type_a' ? 'typeA' : 'typeB'
    return <concept>FromExternal(ext.uid, domainType, ext.group_ref)
  }
}
```

After `getById()` returns, the rest of the system only sees the domain interface — the external shape is gone.

## Rules

- External DTO types live in `infrastructure/` — never in `domain/`
- The domain defines only the port interface, expressed in domain terms
- The mapper function may live in `domain/` if its parameters are plain primitives; move it to `infrastructure/` if it must destructure external DTOs directly
- The domain layer must never import external service types, `snake_case` field names, or status codes from external systems
- Concrete implementation classes behind a domain interface need not be exported — hide them behind the interface
