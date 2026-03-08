---
description: Garbage In, Garbage Out — validate inputs at every system boundary, fail fast with clear errors, and prevent bad data from propagating through the system.
---

# GIGO — Garbage In, Garbage Out

## The Principle

Output quality is bounded by input quality. A system that accepts garbage will produce garbage — and the further bad data travels before being caught, the more expensive the damage: corrupted database records, wrong business decisions, cascading failures, and errors that are impossible to trace back to their source.

The goal is not just to reject bad input, but to **catch it at the boundary where it enters**, before it propagates.

---

## Where to Validate: System Boundaries

Validation must happen at every point where data crosses a trust boundary. Inner layers can trust data that has already been validated; they should not re-validate, but they also should not assume.

```
External input (API, file, queue, CLI)
        ↓  ← validate here: shape, type, format, presence
Domain model
        ↓  ← validate here: business rules and invariants
Persistence (database)
        ↓  ← enforce here: constraints, uniqueness, integrity
```

### API boundary — reject malformed input immediately

```python
# ❌ No validation — garbage reaches the domain and database
@app.post('/orders')
def create_order(request):
    data = request.json
    order = Order(data['customer_id'], data['items'], data['total'])
    db.save(order)

# ✅ Validate shape and types at the boundary
from pydantic import BaseModel, Field

class CreateOrderRequest(BaseModel):
    customer_id: int = Field(..., gt=0)
    items: list[OrderItem] = Field(..., min_items=1)
    total: float = Field(..., gt=0)

@app.post('/orders')
def create_order(body: CreateOrderRequest):
    order = Order(body.customer_id, body.items, body.total)
    db.save(order)
```

### Domain model — enforce business invariants

```python
# ✅ Domain object owns its own validity
class Order:
    MIN_TOTAL = 10.00
    MAX_ITEMS = 100

    def __init__(self, customer_id: int, items: list, total: float):
        if not customer_id or customer_id <= 0:
            raise ValueError("Order must have a valid customer")
        if not items:
            raise ValueError("Order must contain at least one item")
        if len(items) > self.MAX_ITEMS:
            raise ValueError(f"Order cannot exceed {self.MAX_ITEMS} items")
        if total < self.MIN_TOTAL:
            raise ValueError(f"Order total ${total} is below minimum ${self.MIN_TOTAL}")

        self.customer_id = customer_id
        self.items = items
        self.total = total

    def update_total(self, new_total: float):
        if new_total < self.MIN_TOTAL:
            raise ValueError(f"Total ${new_total} is below minimum")
        self.total = new_total  # validate on mutation too, not just construction
```

### Database — last line of defence

```sql
-- Constraints catch anything that bypassed application validation
CREATE TABLE orders (
    id          SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    total       DECIMAL(10,2) NOT NULL CHECK (total >= 10.00),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE order_items (
    order_id   INTEGER NOT NULL REFERENCES orders(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity   INTEGER NOT NULL CHECK (quantity > 0),
    price      DECIMAL(10,2) NOT NULL CHECK (price > 0)
);
```

---

## Fail Fast

Validate at the earliest opportunity. The longer bad data travels, the harder it is to trace and fix.

```python
# ❌ Fail late — bad data reaches the database before the error surfaces
def process_payment(amount, card_number, currency):
    transaction = Transaction(amount, card_number, currency)
    db.save(transaction)          # saved
    result = gateway.charge(...)  # fails here — now you have a phantom transaction

# ✅ Fail fast — validate before doing any work
def process_payment(amount: float, card_number: str, currency: str):
    if amount <= 0:
        raise ValueError("Amount must be positive")
    if not card_number or len(card_number) != 16 or not card_number.isdigit():
        raise ValueError("Card number must be 16 digits")
    if currency not in SUPPORTED_CURRENCIES:
        raise ValueError(f"Unsupported currency: {currency}")

    # Only reach here with valid inputs
    transaction = Transaction(amount, card_number, currency)
    db.save(transaction)
    return gateway.charge(transaction)
```

---

## Sanitize, Then Validate

Some inputs are structurally valid after normalisation. Sanitize first, then validate — do not reject what can be reasonably cleaned.

```python
def create_user(name: str, email: str):
    # Sanitize first
    name = ' '.join(name.strip().split())   # normalize whitespace
    email = email.strip().lower()

    # Then validate
    if not name:
        raise ValueError("Name cannot be empty")
    if '@' not in email or '.' not in email.split('@')[-1]:
        raise ValueError("Invalid email address")

    return User(name, email)
```

---

## Fail with Clear Errors

Errors should tell the caller what was wrong and what is expected — not expose internals or produce cryptic tracebacks.

```python
# ❌ Error is meaningless to the caller
def calculate_average_age(users):
    return sum(u.age for u in users) / len(users)
# ZeroDivisionError — caller has no idea why

# ✅ Error is actionable
def calculate_average_age(users: list) -> float:
    if not users:
        raise ValueError("Cannot calculate average: user list is empty")
    if not all(hasattr(u, 'age') and isinstance(u.age, int) for u in users):
        raise TypeError("All items must be User instances with an integer age")
    return sum(u.age for u in users) / len(users)
```

---

## Silent Failures Are Worse Than Loud Ones

The most dangerous GIGO violation is not rejecting bad input — it is silently accepting it and producing wrong output.

```python
# ❌ Silent failure — wrong result, no error
def get_discount_rate(user_type: str) -> float:
    rates = {'premium': 0.20, 'standard': 0.10}
    return rates.get(user_type, 0)  # unknown type → 0% discount, silently

# ✅ Loud failure — wrong input surfaces immediately
def get_discount_rate(user_type: str) -> float:
    rates = {'premium': 0.20, 'standard': 0.10}
    if user_type not in rates:
        raise ValueError(f"Unknown user type: '{user_type}'. Expected one of: {list(rates)}")
    return rates[user_type]
```

---

## Audit Checklist

When reviewing a codebase for GIGO violations:

1. **Functions that assume inputs are valid** — no guards, no type checks, immediate use of arguments
2. **Dict/map lookups without key validation** — `data['key']` or `.get(key, None)` where `None` silently propagates
3. **Calculations on unvalidated numeric input** — division, multiplication, aggregation with no bounds checks
4. **Domain objects constructed without validation** — constructor assigns fields without checking them
5. **Mutations without re-validation** — setters that update fields the constructor validated
6. **`.get()` with silent default** — used where an unknown value should be an error, not a default
7. **Missing database constraints** — tables with no `NOT NULL`, `CHECK`, or foreign key constraints
8. **Error messages that expose internals** — stack traces, SQL errors, or internal field names returned to callers

---

## Related Principles

- **Security** — input validation also prevents injection attacks; see the `security` skill for SQL injection, XSS, and path traversal
- **TDA** (Tell Don't Ask) — domain objects that validate their own state keep GIGO enforcement co-located with the data
- **Fail Fast** — a general defensive programming principle; GIGO is its application to input quality
