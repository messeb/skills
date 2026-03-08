---
description: Tell, Don't Ask — tell objects what to do rather than querying their state and making decisions for them. Behavior belongs with the data it operates on.
---

# TDA — Tell, Don't Ask

## Examples

### ❌ Ask (Violates TDA)

```python
# Asking for state and making decisions
class Order:
    def __init__(self):
        self.status = 'pending'
        self.items = []
        self.total = 0

# Client code asks and decides
order = Order()
if order.status == 'pending' and len(order.items) > 0:
    order.status = 'confirmed'
    send_confirmation_email(order)
```

### ✅ Tell (Follows TDA)

```python
# Tell the object what to do
class Order:
    def __init__(self):
        self._status = 'pending'
        self._items = []

    def confirm(self):
        if self._status != 'pending':
            raise InvalidStateError("Can only confirm pending orders")
        if not self._items:
            raise InvalidStateError("Cannot confirm empty order")

        self._status = 'confirmed'
        self._send_confirmation()

    def _send_confirmation(self):
        send_confirmation_email(self)

# Client code tells what to do
order = Order()
order.add_item(item)
order.confirm()  # Object handles its own logic
```

### ❌ Feature Envy

```python
# Method is more interested in another object's data
class OrderService:
    def calculate_total(self, order):
        total = 0
        for item in order.items:  # Asking for items
            if item.discount > 0:  # Asking for discount
                price = item.price * (1 - item.discount)  # Asking for price
            else:
                price = item.price
            total += price * item.quantity  # Asking for quantity
        return total
```

### ✅ Encapsulated Behavior

```python
# Each object handles its own calculations
class OrderItem:
    def __init__(self, price, quantity, discount=0):
        self.price = price
        self.quantity = quantity
        self.discount = discount

    def subtotal(self):
        """Item knows how to calculate its own subtotal"""
        discounted_price = self.price * (1 - self.discount)
        return discounted_price * self.quantity

class Order:
    def __init__(self):
        self._items = []

    def add_item(self, item):
        self._items.append(item)

    def total(self):
        """Order knows how to calculate its own total"""
        return sum(item.subtotal() for item in self._items)

# Client just tells and asks for results
order = Order()
order.add_item(item)
total = order.total()  # Ask for result, not intermediate state
```

## Real-World Scenarios

### 1. User Authentication

```python
# ❌ Ask pattern
class User:
    def __init__(self, password_hash, is_locked, failed_attempts):
        self.password_hash = password_hash
        self.is_locked = is_locked
        self.failed_attempts = failed_attempts

def authenticate(user, password):
    if user.is_locked:
        raise AccountLockedError()

    if check_password(password, user.password_hash):
        user.failed_attempts = 0
        return True
    else:
        user.failed_attempts += 1
        if user.failed_attempts >= 3:
            user.is_locked = True
        return False

# ✅ Tell pattern
class User:
    MAX_FAILED_ATTEMPTS = 3

    def __init__(self, password_hash):
        self._password_hash = password_hash
        self._is_locked = False
        self._failed_attempts = 0

    def authenticate(self, password):
        """Tell user to authenticate itself"""
        if self._is_locked:
            raise AccountLockedError()

        if self._check_password(password):
            self._reset_failed_attempts()
            return True
        else:
            self._record_failed_attempt()
            return False

    def _check_password(self, password):
        return check_password(password, self._password_hash)

    def _reset_failed_attempts(self):
        self._failed_attempts = 0

    def _record_failed_attempt(self):
        self._failed_attempts += 1
        if self._failed_attempts >= self.MAX_FAILED_ATTEMPTS:
            self._lock_account()

    def _lock_account(self):
        self._is_locked = True

# Usage
user = User(password_hash)
user.authenticate(provided_password)  # Just tell it what to do
```

### 2. Shopping Cart

```python
# ❌ Ask pattern - external code manipulating cart
def apply_discount_code(cart, code):
    if cart.items_count == 0:
        raise EmptyCartError()

    discount = get_discount(code)
    if discount.min_purchase > cart.total:
        raise MinimumNotMetError()

    if discount.type == 'percentage':
        cart.discount_amount = cart.total * discount.value
    elif discount.type == 'fixed':
        cart.discount_amount = discount.value

# ✅ Tell pattern - cart handles its own discounts
class Cart:
    def __init__(self):
        self._items = []
        self._discount = None

    def apply_discount(self, discount_code):
        """Tell cart to apply discount"""
        if not self._items:
            raise EmptyCartError()

        discount = DiscountCode.lookup(discount_code)

        if not self._meets_minimum(discount):
            raise MinimumNotMetError()

        self._discount = discount

    def _meets_minimum(self, discount):
        return self.total() >= discount.minimum_purchase

    def total(self):
        subtotal = sum(item.price() for item in self._items)
        if self._discount:
            return self._discount.apply(subtotal)
        return subtotal

# Usage
cart = Cart()
cart.add_item(item)
cart.apply_discount("SAVE10")  # Tell, don't ask
```

### 3. State Transitions

```python
# ❌ Ask pattern - client manages state
class Document:
    def __init__(self):
        self.status = 'draft'
        self.author = None
        self.reviewers = []

def publish_document(doc):
    if doc.status != 'reviewed':
        raise InvalidStateError()
    if not doc.reviewers:
        raise NoReviewersError()
    doc.status = 'published'
    notify_subscribers(doc)

# ✅ Tell pattern - object manages its own state
class Document:
    def __init__(self, author):
        self._status = 'draft'
        self._author = author
        self._reviewers = []

    def submit_for_review(self):
        """Tell document to transition"""
        if self._status != 'draft':
            raise InvalidStateError("Can only submit drafts")
        self._status = 'in_review'

    def approve(self, reviewer):
        """Tell document it's approved"""
        if self._status != 'in_review':
            raise InvalidStateError("Can only approve documents in review")

        self._reviewers.append(reviewer)
        if self._has_enough_approvals():
            self._status = 'reviewed'

    def publish(self):
        """Tell document to publish"""
        if self._status != 'reviewed':
            raise InvalidStateError("Can only publish reviewed documents")

        self._status = 'published'
        self._notify_subscribers()

    def _has_enough_approvals(self):
        return len(self._reviewers) >= 2

    def _notify_subscribers(self):
        notify_subscribers(self)

# Usage
doc = Document(author)
doc.submit_for_review()
doc.approve(reviewer1)
doc.approve(reviewer2)
doc.publish()  # Clean, clear commands
```

## Practical Guidelines

### 1. Protect Internal State

```python
# ❌ Exposed internals
class BankAccount:
    def __init__(self, balance):
        self.balance = balance  # Public!

account.balance -= 100  # Direct manipulation!

# ✅ Encapsulated state
class BankAccount:
    def __init__(self, balance):
        self._balance = balance  # Private

    def withdraw(self, amount):
        """Tell account what to do"""
        if amount > self._balance:
            raise InsufficientFundsError()
        self._balance -= amount

    def deposit(self, amount):
        if amount <= 0:
            raise InvalidAmountError()
        self._balance += amount

    def balance(self):
        """Read-only access to state"""
        return self._balance

account.withdraw(100)  # Tell, don't manipulate
```

### 2. Commands, Not Queries (CQS)

Separate methods that:
- **Command**: Change state (tell)
- **Query**: Return information (ask)

```python
class Order:
    def confirm(self):  # Command - tells
        self._status = 'confirmed'

    def is_confirmed(self):  # Query - asks
        return self._status == 'confirmed'

# Good usage
order.confirm()  # Tell
if order.is_confirmed():  # Ask for info, not to manipulate
    process_order(order)
```

### 3. Law of Demeter (One Dot Rule)

Don't chain through multiple objects:

```python
# ❌ Train wreck
customer.get_wallet().get_money().get_amount()

# ✅ Tell customer what you need
customer.can_afford(amount)
customer.charge(amount)
```

## Common Violations

### 1. Anemic Domain Model

```python
# ❌ All getters/setters, no behavior
class User:
    def get_name(self): return self.name
    def set_name(self, name): self.name = name
    def get_email(self): return self.email
    def set_email(self, email): self.email = email

# All logic in services
class UserService:
    def validate_user(self, user):
        if not user.get_email():
            raise Error()
        # All behavior here instead of in User

# ✅ Rich domain model
class User:
    def __init__(self, name, email):
        self._name = name
        self._email = email
        self._validate()

    def _validate(self):
        if not self._email or '@' not in self._email:
            raise InvalidEmailError()

    def update_email(self, new_email):
        old_email = self._email
        self._email = new_email
        try:
            self._validate()
        except InvalidEmailError:
            self._email = old_email
            raise
```

### 2. Temporal Coupling

```python
# ❌ Caller must know the sequence
user = User()
user.status = 'active'  # Must set status first
user.save()  # Then save

# ✅ Object handles its own initialization
class User:
    def __init__(self, name, email):
        self._name = name
        self._email = email
        self._status = 'active'  # Initialized correctly

    def activate(self):
        self._status = 'active'
        self._save()  # Handles persistence
```

## When to Ask

Sometimes asking is appropriate:

### Queries for Display

```python
# ✅ OK to ask for display
def render_user(user):
    return f"Name: {user.name()}, Email: {user.email()}"
```

### Reporting and Analytics

```python
# ✅ OK to ask for reporting
def generate_report(orders):
    total_revenue = sum(order.total() for order in orders)
    average_order = total_revenue / len(orders)
```

### When Building New Objects

```python
# ✅ OK to ask when constructing
def create_order_from_cart(cart):
    order = Order()
    for item in cart.items():  # Ask for items to build order
        order.add_item(item)
    return order
```

## Audit Checklist

When reviewing a codebase for TDA violations:

1. **External state checks before mutation** — `if obj.status == 'x': obj.status = 'y'` — the condition and transition should live inside the object
2. **Public fields mutated directly by callers** — `order.status = 'confirmed'` or `account.balance -= 100` instead of a command method
3. **Feature envy** — a method reads more fields from another object than from `self`; behaviour belongs in the object being interrogated
4. **Train wrecks** — chained calls like `customer.wallet().money().amount()` instead of `customer.can_afford(amount)`
5. **Anemic domain model** — classes with only getters/setters and no behaviour; all logic pushed into service classes
6. **Temporal coupling** — caller must set fields in a specific sequence before calling a method; the object should initialise itself correctly
7. **Getters used only to make decisions** — if the only consumer of a getter is an `if` statement in the caller, that decision should be inside the object

---

## Related Principles

- **Encapsulation**: TDA enforces strong encapsulation
- **SRP**: Objects responsible for their own behavior
- **Law of Demeter**: Don't chain through objects
- **KISS**: Simpler when behavior is encapsulated
- **DRY**: Behavior in one place, not scattered

## Decision Framework

| Question | If yes… |
|----------|---------|
| Am I reading another object's state to make a decision? | Move the decision inside that object |
| Is this method more interested in another object's data? | Move the behaviour to that object |
| Am I exposing internal state through a getter? | Provide a command method instead |
| Does the caller need to call methods in a specific order? | The object should initialise or transition itself |
