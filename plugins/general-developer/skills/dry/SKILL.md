---
description: Don't Repeat Yourself — every piece of knowledge must have a single, unambiguous representation. Know when to extract, when to leave duplication alone, and how to avoid the wrong abstraction.
---

# DRY — Don't Repeat Yourself

## The Principle

**Every piece of knowledge must have a single, unambiguous, authoritative representation within a system.**

DRY is about *knowledge*, not code syntax. Two functions that look identical may not violate DRY if they represent different knowledge. Two functions that look different may violate DRY if they encode the same business rule in different forms.

When DRY is applied correctly, a change to any piece of knowledge requires a change in exactly one place.

---

## Knowledge Duplication vs Coincidental Similarity

The most important judgment call in applying DRY:

```python
# Knowledge duplication — DOES violate DRY
# Same business rule expressed twice
def is_eligible_for_discount(user):
    return user.orders_count > 5

def qualifies_for_loyalty_tier(user):
    return user.orders_count > 5   # Same rule, must change together

# Coincidental similarity — does NOT violate DRY
# Same code, different knowledge
def password_min_length():
    return 8   # Password security policy

def api_key_min_length():
    return 8   # Key format requirement — different rule, different reason to change
```

**Test**: if the two pieces would need to change for different reasons, they are coincidences — not duplicates. Do not unify them.

---

## What DRY Applies To

### Business logic

```python
# ❌ Tax rate scattered — change $0.08 in three places
def calculate_order_total(order):
    subtotal = sum(item.price * item.quantity for item in order.items)
    return subtotal + subtotal * 0.08

def estimate_cart_price(cart):
    subtotal = sum(item.price * item.quantity for item in cart.items)
    return subtotal + subtotal * 0.08

# ✅ Single source
class PriceCalculator:
    TAX_RATE = 0.08
    FREE_SHIPPING_THRESHOLD = 50
    SHIPPING_COST = 10

    @classmethod
    def calculate_total(cls, items):
        subtotal = sum(item.price * item.quantity for item in items)
        tax = subtotal * cls.TAX_RATE
        shipping = 0 if subtotal >= cls.FREE_SHIPPING_THRESHOLD else cls.SHIPPING_COST
        return subtotal + tax + shipping
```

### Constants and configuration

```python
# ❌ Magic number scattered across files
if user.age >= 18: allow_access()
if customer.age >= 18: process_order()

# ✅ Named once
LEGAL_ADULT_AGE = 18
if user.age >= LEGAL_ADULT_AGE: allow_access()
```

### Repeated structural patterns

```python
# ❌ Fetch-or-raise pattern repeated for every model
user = db.query(User).filter_by(id=user_id).first()
if not user:
    raise NotFoundError(f"User {user_id} not found")

order = db.query(Order).filter_by(id=order_id).first()
if not order:
    raise NotFoundError(f"Order {order_id} not found")

# ✅ Pattern extracted once
def get_or_404(model, entity_id):
    entity = db.query(model).filter_by(id=entity_id).first()
    if not entity:
        raise NotFoundError(f"{model.__name__} {entity_id} not found")
    return entity
```

### Documentation

```python
# ❌ Comment duplicates the code — one will drift
def calculate_discount(price: float, pct: float) -> float:
    # Multiply price by percentage divided by 100, then subtract from price
    discount = price * (pct / 100)
    return price - discount

# ✅ Code is self-explanatory; doc adds what code cannot express
def calculate_discount(price: float, pct: float) -> float:
    """Returns final price after applying a percentage discount."""
    discount_amount = price * (pct / 100)
    return price - discount_amount
```

---

## When Not to Apply DRY

### The wrong abstraction is worse than duplication

The most dangerous DRY failure: unifying code that looks similar but is not the same knowledge, producing an abstraction that cannot serve both callers cleanly.

```python
# ❌ Forced unification — worse than the duplication it replaced
def process_entity(entity, entity_type):
    if entity_type == 'user':
        validate_user(entity)
        save_user(entity)
    elif entity_type == 'order':
        validate_order(entity)
        save_order(entity)
    # Adding a new type requires changing this function
    # Every caller now couples to every other type

# ✅ Separate functions — clear, independent, extendable
def process_user(user):
    validate_user(user)
    save_user(user)

def process_order(order):
    validate_order(order)
    save_order(order)
```

### Premature extraction creates coupling

```python
# ❌ Shared formatter couples two unrelated services
class SharedFormatter:
    def format(self, data):
        # A change for UserService will affect OrderService and vice versa
        pass

# ✅ Each service owns its formatting — they can evolve independently
class UserFormatter:
    def format(self, user): ...

class OrderFormatter:
    def format(self, order): ...
```

---

## Rule of Three

Do not extract on the first or second occurrence. Wait for the third — it confirms that the pattern is real and not coincidental.

```python
# First — write it
def process_payment(amount):
    return amount + amount * 0.08

# Second — note it, leave it
def calculate_invoice(amount):
    return amount + amount * 0.08   # noted

# Third — now extract
TAX_RATE = 0.08

def apply_tax(amount):
    return amount * TAX_RATE

def process_payment(amount):   return amount + apply_tax(amount)
def calculate_invoice(amount): return amount + apply_tax(amount)
def estimate_quote(amount):    return amount + apply_tax(amount)
```

---

## Decision Framework

Before extracting, ask:

| Question | Extract if… | Leave if… |
|----------|------------|-----------|
| Is this the same knowledge? | Yes — same rule, same reason to change | No — similar code, different concepts |
| Third occurrence? | Yes | No — wait |
| Can I name the abstraction clearly? | Yes | No — not ready |
| Does extraction make it clearer? | Yes | No — adds indirection without clarity |
| Will extraction couple unrelated things? | No | Yes — prefer duplication |

**Default**: duplication is cheaper than the wrong abstraction.

---

## Related Principles

- **DIE** — Duplication Is Evil: maps duplication types to their specific failure modes; complements DRY by explaining *why* duplication is harmful
- **KISS** — over-abstracting to eliminate duplication often violates simplicity
- **YAGNI** — do not extract to accommodate hypothetical future callers
- **SRP** — DRY within a responsibility; keep concerns separate between responsibilities
