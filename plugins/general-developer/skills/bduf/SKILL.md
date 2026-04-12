---
description: Big Design Up Front — identify over-designed, under-iterated code and architecture, and distinguish it from appropriate upfront planning.
---

# BDUF — Big Design Up Front

## What BDUF Is

**Big Design Up Front** is the anti-pattern of completing exhaustive design before any implementation — producing more design than the current state of knowledge warrants. The name is intentionally pejorative.

BDUF manifests as: designing for hypothetical requirements, deferring feedback too long, and treating design as finished rather than evolving.

**BDUF is not**: appropriate upfront design for high-risk, high-cost-of-change areas. The goal is not to avoid design — it is to design at the right time with the right level of detail.

---

## When Upfront Design Is Warranted

Design carefully before building when the **cost of changing later is high**:

| Area | Why design first |
|------|-----------------|
| Database schema | Migrations are expensive; data transformations are risky |
| Public API contracts | Breaking changes affect external consumers |
| Security architecture | Retrofitting security is harder and riskier than building it in |
| Distributed service boundaries | Changing boundaries requires data migration and service refactoring |
| Regulatory / compliance requirements | Non-negotiable constraints that won't change |

For everything else — especially in uncertain domains — prefer iterative design.

---

## BDUF Anti-Patterns in Code

These are the patterns to detect when auditing:

### Over-abstracted for hypothetical requirements

```python
# ❌ BDUF: Plugin system, strategy pattern, and 5 extension points
#    for a feature with one known implementation
class NotificationService:
    def __init__(self, provider_registry, formatter_factory,
                 channel_router, retry_strategy, fallback_chain):
        ...

# ✅ Design for what exists now
class NotificationService:
    def send(self, user, message): ...
```

### Excessive configuration surface

```python
# ❌ BDUF: 30 config options for a system with 2 known use cases
class UserPreferencesSystem:
    # 50+ options, complex inheritance, multiple backends
    pass

# ✅ Start with what users actually need
class UserPreferences:
    def __init__(self):
        self.preferences = {}

    def set(self, key, value):
        self.preferences[key] = value

    def get(self, key, default=None):
        return self.preferences.get(key, default)
```

### Generic framework for a specific problem

```python
# ❌ BDUF: Built a workflow engine when you needed two sequential steps
class WorkflowEngine:
    def register_step(self, name, handler, conditions, rollback): ...
    def define_transition(self, from_state, to_state, guard): ...

# ✅ Just the two steps
def process_order(order):
    validate(order)
    save(order)
```

### Dead design weight

```python
# ❌ BDUF residue: Interfaces, base classes, and abstractions
#    with exactly one implementation and no extension planned
class AbstractOrderProcessor(ABC):
    @abstractmethod
    def pre_process(self): ...
    @abstractmethod
    def validate(self): ...
    @abstractmethod
    def execute(self): ...
    @abstractmethod
    def post_process(self): ...

class ConcreteOrderProcessor(AbstractOrderProcessor):
    # Only implementation; never extended
    ...
```

---

## Warning Signs

**Too much BDUF:**

- Design effort exceeds implementation effort
- Large class hierarchies or interfaces with a single implementation
- Configuration systems with options that are never set
- Abstractions that exist "for future extensibility" with no concrete plan
- Code structured around requirements that don't exist yet

**Too little design:**

- No architectural discussion before building critical systems
- Security, data model, or API shape figured out during implementation
- High-risk integrations started without a spike
- No identification of what is hard to change later

---

## The Right Level of Design

### Design architecture, defer details

```text
✅ Decide upfront:          ⏸ Let emerge during development:
- Layer boundaries          - Specific class structures
- Data flow direction       - Method signatures
- Technology choices        - Internal algorithms
- Security approach         - Helper utilities
```

### Risk-driven design

```text
High risk → design first:   Low risk → design later:
- Security mechanisms       - UI layout
- Public API contracts      - Reporting logic
- Data models               - Admin features
- External integrations     - Internal tooling
```

### Spike before committing

When entering uncertain territory — a new integration, an unfamiliar domain — build a throwaway prototype first. Design after learning, not before.

### Time-box design effort

| Scope | Time limit |
|-------|-----------|
| System architecture | 1 day |
| Module / service design | 2 hours |
| Class / component design | 30 minutes |

If the time box runs out and uncertainty remains, build a spike.

---

## Decision Framework

Before investing in detailed design, ask:

1. **What is the cost of changing this later?** — High → design more now. Low → design lightly and iterate.
2. **How certain are the requirements?** — Certain → design upfront. Uncertain → design iteratively.
3. **Can assumptions be validated cheaply?** — Yes → spike first, then design.
4. **Is this domain well-understood?** — Yes → leverage known patterns. No → experiment and learn.

---

## Related Principles

- **YAGNI** — don't implement features not yet needed; BDUF is the design-level equivalent
- **KISS** — over-designed systems are rarely simple
- **Evolutionary Architecture** — define fitness functions, measure continuously, evolve to meet goals rather than specifying them upfront
