---
description: Keep It Simple — write code that solves the actual problem directly, without unnecessary abstraction, indirection, or cleverness. Complexity must earn its place.
---

# KISS — Keep It Simple

## The Principle

Simple code is not a sign of laziness — it is the hardest outcome to achieve. Complexity accumulates naturally; simplicity requires deliberate effort and discipline.

**Complexity must earn its place.** Every abstraction layer, every design pattern, every generalization adds cognitive overhead for every future reader. If a piece of complexity does not pay for that cost with clear, measurable value, it should not exist.

KISS violations are rarely malicious. They usually come from:
- Solving a hypothetical future problem instead of the current one (see also: YAGNI)
- Applying a pattern because it is familiar, not because it fits
- Confusing "clever" with "good"
- Adding structure before its need is proven

---

## Simple vs. Simplistic

The most important distinction: **simple** solves the problem cleanly and directly. **Simplistic** ignores real requirements.

```python
# Simplistic — ignores real edge cases
def divide(a, b):
    return a / b   # crashes on b=0

# Simple — handles the real problem without over-engineering
def divide(a: float, b: float) -> float:
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

# Complex — engineers for hypothetical extensibility nobody asked for
class DivisionOperation(ArithmeticOperation):
    def execute(self, operands: OperandCollection) -> Result:
        self._validator.validate(operands)
        return self._executor.run(operands, self._strategy)
```

---

## Complexity Patterns to Detect

### Unnecessary design patterns

A pattern applied where a function would do creates indirection with no benefit.

```python
# ❌ Strategy + Factory for three fixed operations
class CalculationStrategyFactory:
    def create(self, op: str) -> CalculationStrategy:
        return {'add': AddStrategy, 'sub': SubStrategy}[op]()

class AddStrategy(CalculationStrategy):
    def execute(self, a, b): return a + b

# ✅ A function
def calculate(op: str, a: int, b: int) -> int:
    if op == 'add': return a + b
    if op == 'sub': return a - b
    raise ValueError(f"Unknown operation: {op}")
```

### Premature abstraction

Abstract base classes, interfaces, and repositories with a single concrete implementation add layers without benefit.

```python
# ❌ Abstraction for one implementation that will never be swapped
class BaseRepository(ABC):
    @abstractmethod
    def find_by_id(self, entity_id: str): ...

class UserRepository(BaseRepository):
    def find_by_id(self, entity_id: str):
        return db.query(User).filter_by(id=entity_id).first()

# ✅ Concrete and direct
class UserRepository:
    def find_by_id(self, entity_id: str):
        return db.query(User).filter_by(id=entity_id).first()
```

### Builder pattern for simple construction

Builders earn their complexity when construction is genuinely conditional or when the object has many optional parts. A dict is not a candidate.

```python
# ❌ Builder wrapping a dict
class ConfigBuilder:
    def with_database(self, url: str) -> 'ConfigBuilder':
        self._config['database'] = url
        return self

    def with_cache(self, ttl: int) -> 'ConfigBuilder':
        self._config['cache_ttl'] = ttl
        return self

    def build(self) -> dict:
        return self._config

# ✅ Just a dict
config = {
    'database': 'postgresql://localhost/db',
    'cache_ttl': 3600
}
```

### Clever one-liners

Code that requires study to parse, even briefly, is not simple — regardless of line count.

```python
# ❌ Requires mental unpacking to understand
valid = [u for u in users if (lambda x: x.age >= 18 and x.status == 'active' and not x.deleted)(u)]

# ✅ Named predicate — reads as a sentence
def is_active_adult(user: User) -> bool:
    return user.age >= 18 and user.status == 'active' and not user.deleted

valid = [u for u in users if is_active_adult(u)]
```

### Over-structured data

```python
# ❌ Stateful class for transient data that never changes after creation
class OrderState:
    def __init__(self):
        self._history = deque()
        self._index = 0

    def transition(self, state: str):
        self._history.append(state)
        self._index = len(self._history) - 1

# ✅ A string field on the order
class Order:
    def __init__(self):
        self.status = 'pending'

    def confirm(self):
        self.status = 'confirmed'
```

---

## Complexity Must Earn Its Place

Before adding an abstraction, pattern, or layer, it must answer yes to at least one:

| Justification | Acceptable if… |
|--------------|----------------|
| Removes duplication | Three or more real occurrences exist (Rule of Three) |
| Enables testing | The simpler form is genuinely untestable |
| Enforces a constraint | The constraint cannot be expressed more directly |
| Manages real variability | Multiple concrete implementations exist or are immediately planned |
| Improves readability | A named concept is clearer than inlined logic |

If none of these apply, the complexity should not be added.

---

## Audit Checklist

When reviewing a codebase for KISS violations:

1. **Abstract base classes or interfaces with a single implementation** — complexity without benefit
2. **Factory classes that instantiate one type** — indirection without variability
3. **Builder pattern wrapping a simple struct or dict** — construction complexity for a simple object
4. **Classes whose only purpose is to hold a method** — a function would do
5. **Methods that pass through to another method unchanged** — unnecessary delegation layer
6. **Inline lambdas in comprehensions or map calls** — name it instead
7. **Config or feature flags for behaviour that never changes** — premature generality
8. **Comments explaining what the code does** — the code should be self-explanatory; if it needs explanation, simplify it

---

## Balancing KISS with Other Principles

**KISS vs. DRY**: when eliminating duplication would require a complex abstraction, the duplication is often the simpler choice. Prefer readable duplication over an abstraction that obscures meaning.

**KISS vs. YAGNI**: YAGNI says don't build features you don't need. KISS says build the features you do need as simply as possible. They are complementary, not alternatives.

**KISS vs. extensibility**: start with the simplest thing that works. Add extension points when a second concrete need actually exists — not in anticipation of one.

---

## Decision Framework

Before adding complexity, ask:

1. **Does this solve a current, proven problem?** If no — defer.
2. **Could a new team member understand this in five minutes?** If no — simplify.
3. **Would removing this abstraction make the code clearer?** If yes — remove it.
4. **Am I solving a real problem or a hypothetical one?** Hypothetical — defer.
5. **Does this earn its indirection?** If the answer requires justification — probably not.

---

## Related Principles

- **YAGNI** — don't build features not yet needed; KISS is about building what you do need as simply as possible
- **DRY** — balance: eliminating duplication should not produce complexity worse than the duplication itself
- **BDUF** — over-designed upfront architecture is a KISS violation at the system level
