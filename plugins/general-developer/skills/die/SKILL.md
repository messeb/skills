---
description: Duplication Is Evil — identify harmful duplication by its failure mode, distinguish it from acceptable similarity, and eliminate it at the right level.
---

# DIE — Duplication Is Evil

## What DIE Adds Over DRY

**DRY** (Don't Repeat Yourself) states the principle. **DIE** names the consequence: duplication is not merely wasteful — it is actively harmful. Every duplicated piece of knowledge is a future bug and a change that must be made in multiple places, with no guarantee all copies will be found.

The key insight: **different types of duplication have different failure modes.** Knowing the failure mode tells you how urgently to fix it and at what level to eliminate it.

---

## Duplication Types and Their Failure Modes

### Literal duplication — fails silently when one copy is updated

Exact or near-exact code copied across multiple locations. When a bug is fixed or logic changes in one copy, the others are left behind.

```python
# Bug exists in all three — fix in one, miss the others
def calculate_user_discount(user):
    return user.total * (0.10 if user.is_premium else 0.05)  # wrong rate

def calculate_order_discount(order):
    return order.total * (0.10 if order.user.is_premium else 0.05)  # same bug

def estimate_savings(cart):
    return cart.total * (0.10 if cart.user.is_premium else 0.05)  # same bug

# Fix: single source of truth
class DiscountCalculator:
    PREMIUM_RATE = 0.15
    STANDARD_RATE = 0.05

    @classmethod
    def calculate(cls, total, is_premium):
        return total * (cls.PREMIUM_RATE if is_premium else cls.STANDARD_RATE)
```

### Semantic duplication — fails when the business rule changes

Different implementations expressing the same business rule. No static analysis tool catches this — it requires reading the code to spot it.

```python
# Same condition expressed two ways — will diverge when the rule changes
def is_eligible_for_discount(user):
    return user.orders_count > 5

def should_offer_loyalty_bonus(user):
    return len(user.orders) > 5  # same rule, different expression

# Fix: name and own the rule
class User:
    LOYALTY_THRESHOLD = 5

    def is_loyal_customer(self):
        return self.orders_count > self.LOYALTY_THRESHOLD
```

### Knowledge fragmentation — fails when any one copy is out of sync

A business rule or constant scattered across layers. The most dangerous variant because the copies are far apart and may be in different languages or systems.

```python
# Minimum order rule in four places
# Controller:   if order.total < 10: return error
# Service:      if order.total < 10: raise MinimumOrderError()
# Frontend:     if (total < 10) showError(...)
# Email:        if order.total < 10: return "Below minimum"

# Changing $10 → $15 requires finding all four — and the frontend

# Fix: own it in the domain model; pass it to other layers
class Order:
    MINIMUM_TOTAL = 10.00

    def validate(self):
        if self.total < self.MINIMUM_TOTAL:
            raise MinimumOrderError(self.MINIMUM_TOTAL)
```

### Structural duplication — fails when the pattern needs to change

Same algorithm or structure repeated with different data. Adding a step, changing error handling, or altering the flow requires updating every copy.

```python
# Same CSV-processing pattern three times
def process_user_csv(file):
    for line in file.readlines()[1:]:
        fields = line.strip().split(',')
        db.save(User(*fields))

def process_product_csv(file):
    for line in file.readlines()[1:]:
        fields = line.strip().split(',')
        db.save(Product(*fields))

# Fix: extract the pattern, inject the variation
def process_csv(file, make_entity):
    for line in file.readlines()[1:]:
        db.save(make_entity(line.strip().split(',')))

process_csv(file, lambda f: User(*f))
process_csv(file, lambda f: Product(*f))
```

---

## When Similarity Is Not Duplication

Not all similar code should be unified. Merging coincidentally similar code that represents different knowledge creates coupling that causes pain when the two concepts diverge.

**Different domains — do not unify:**
```python
class UserPassword:
    MIN_LENGTH = 8  # Password policy — will change independently

class ApiKey:
    MIN_LENGTH = 8  # Key format requirement — different rule, same number today
```

**Accidental similarity — do not unify:**
```python
def user_account_age_years(user):
    return (date.today() - user.created_at).days // 365

def product_shelf_age_years(product):
    return (date.today() - product.listed_at).days // 365

# Same calculation, different concepts — unifying creates false coupling
```

**Rule of thumb**: if the two pieces would need to change for different reasons, they are not duplicates. They are coincidences.

---

## When to Eliminate

**Rule of Three**: do not extract on the first or second occurrence. Wait for the third. The first two might be coincidences; the third confirms a pattern.

```python
# First occurrence — write it
smtp.send(user.email, welcome_message)

# Second occurrence — note it, leave it
smtp.send(order.customer.email, confirmation_message)

# Third occurrence — now extract
class Mailer:
    def send(self, address, message): ...
```

**Prioritise by failure mode severity:**

| Type | When it bites | Priority |
|------|--------------|----------|
| Knowledge fragmentation | Any time a rule changes | High |
| Semantic duplication | When a business rule evolves | High |
| Literal duplication | When one copy is patched | Medium |
| Structural duplication | When the pattern needs updating | Medium |

---

## Audit Checklist

When reviewing a codebase for harmful duplication:

1. **Search for the same magic number or string literal in multiple files** — flag as knowledge fragmentation
2. **Find methods with identical or near-identical bodies** — flag as literal duplication
3. **Look for the same conditional expressed differently** (`count > 5` vs `len(list) > 5`) — flag as semantic duplication
4. **Identify repeated algorithmic structures** (same loop shape, same error-handling pattern) — flag as structural duplication
5. **Check if similar-looking code in different domains truly shares knowledge** — if not, leave it alone

---

## Related Principles

- **DRY** — the principle this applies: every piece of knowledge must have a single, unambiguous representation
- **SRP** — duplication often signals that a responsibility belongs elsewhere
- **KISS** — the fix for duplication should be simpler than the duplication itself; a wrong abstraction is worse than the copies
