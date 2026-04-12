---
description: Separation of Concerns — divide a system into distinct sections where each handles exactly one concern, so that changes to one section do not ripple into others.
---

# SoC — Separation of Concerns

## Common Separations

### 1. Presentation vs. Business Logic vs. Data

The classic three-tier architecture:

```python
# ❌ Mixed concerns
@app.route('/users/<id>')
def get_user(id):
    # Presentation (HTTP)
    # Business logic
    # Data access
    # All mixed together!

    conn = db.connect()  # Data access
    row = conn.execute(f"SELECT * FROM users WHERE id = {id}")  # SQL injection!

    if row:
        user = {
            'id': row[0],
            'name': row[1].upper(),  # Business logic
            'email': row[2].lower()   # Business logic
        }
        return f"<h1>{user['name']}</h1>"  # Presentation (HTML)
    else:
        return "Not found", 404

# ✅ Separated concerns
# Presentation Layer
@app.route('/users/<id>')
def get_user_endpoint(id):
    user = user_service.get_user(id)
    if not user:
        return {"error": "Not found"}, 404
    return jsonify(user.to_dict())

# Business Logic Layer
class UserService:
    def __init__(self, user_repo: UserRepository):
        self.user_repo = user_repo

    def get_user(self, user_id: str) -> User:
        user = self.user_repo.find_by_id(user_id)
        if user:
            user.normalize()  # Business logic
        return user

# Data Access Layer
class UserRepository:
    def find_by_id(self, user_id: str) -> Optional[User]:
        return db.session.query(User).filter_by(id=user_id).first()

# Domain Layer
class User:
    def __init__(self, name, email):
        self.name = name
        self.email = email

    def normalize(self):
        self.name = self.name.upper()
        self.email = self.email.lower()

    def to_dict(self):
        return {'name': self.name, 'email': self.email}
```

### 2. Read vs. Write (CQRS)

Separate query and command responsibilities:

```python
# ❌ Mixed read/write concerns
class UserService:
    def handle_user_request(self, data, operation):
        if operation == 'read':
            # Complex query logic
            pass
        elif operation == 'write':
            # Complex update logic
            pass

# ✅ Separated CQRS
class UserQueryService:
    """Handles all read operations"""
    def get_user(self, user_id): pass
    def search_users(self, criteria): pass
    def get_user_stats(self, user_id): pass

class UserCommandService:
    """Handles all write operations"""
    def create_user(self, data): pass
    def update_user(self, user_id, data): pass
    def delete_user(self, user_id): pass
```

### 3. Domain Logic vs. Infrastructure

```python
# ❌ Domain logic mixed with infrastructure
class Order:
    def confirm(self):
        self.status = 'confirmed'
        # Infrastructure concern in domain!
        redis.cache_set(f"order:{self.id}", self)
        rabbitmq.publish('order.confirmed', self)
        db.session.commit()

# ✅ Separated concerns
# Domain Layer
class Order:
    def confirm(self):
        self.status = 'confirmed'
        self.record_event(OrderConfirmed(self.id))

# Infrastructure Layer
class OrderRepository:
    def save(self, order):
        db.session.add(order)
        db.session.commit()
        self.cache.set(order)
        self.publish_events(order.events)
```

### 4. Configuration vs. Code

```python
# ❌ Configuration hardcoded
class EmailService:
    def send(self, to, subject, body):
        smtp = smtplib.SMTP('smtp.gmail.com', 587)
        smtp.login('user@example.com', 'password')  # Hardcoded!
        # ...

# ✅ Configuration separated
class EmailConfig:
    def __init__(self):
        self.smtp_host = os.getenv('SMTP_HOST')
        self.smtp_port = int(os.getenv('SMTP_PORT'))
        self.username = os.getenv('SMTP_USERNAME')
        self.password = os.getenv('SMTP_PASSWORD')

class EmailService:
    def __init__(self, config: EmailConfig):
        self.config = config

    def send(self, to, subject, body):
        smtp = smtplib.SMTP(self.config.smtp_host, self.config.smtp_port)
        smtp.login(self.config.username, self.config.password)
        # ...
```

## Layered Architecture

### Classic Layers (Dependency Direction: Top → Bottom)

```text
┌─────────────────────────────────┐
│   Presentation Layer            │  ← API, UI, Controllers
├─────────────────────────────────┤
│   Application Layer             │  ← Use Cases, Orchestration
├─────────────────────────────────┤
│   Domain Layer                  │  ← Business Logic, Entities
├─────────────────────────────────┤
│   Infrastructure Layer          │  ← DB, External Services
└─────────────────────────────────┘
```

### Clean Architecture Example

```python
# Domain Layer (Core - no dependencies)
class Order:
    def __init__(self, customer_id):
        self.id = generate_id()
        self.customer_id = customer_id
        self.items = []
        self.status = 'pending'

    def add_item(self, item):
        self.items.append(item)

    def confirm(self):
        if not self.items:
            raise InvalidOrderError()
        self.status = 'confirmed'

# Application Layer (Use Cases)
class CreateOrderUseCase:
    def __init__(self, order_repo, event_bus):
        self.order_repo = order_repo
        self.event_bus = event_bus

    def execute(self, customer_id, items):
        order = Order(customer_id)
        for item in items:
            order.add_item(item)
        order.confirm()

        self.order_repo.save(order)
        self.event_bus.publish(OrderCreated(order.id))

        return order

# Infrastructure Layer (Implementations)
class PostgresOrderRepository:
    def save(self, order):
        # Database-specific implementation
        pass

class RabbitMQEventBus:
    def publish(self, event):
        # Message queue-specific implementation
        pass

# Presentation Layer (API)
@app.post('/orders')
def create_order_endpoint(data):
    use_case = CreateOrderUseCase(order_repo, event_bus)
    order = use_case.execute(data['customer_id'], data['items'])
    return jsonify({'order_id': order.id})
```

## Common Violations

### 1. God Class

```python
# ❌ One class doing everything
class UserManager:
    def create_user(self): pass  # Business logic
    def save_user(self): pass  # Data access
    def render_user_html(self): pass  # Presentation
    def send_welcome_email(self): pass  # External service
    def validate_user(self): pass  # Validation
    def log_user_action(self): pass  # Logging
```

### 2. Leaky Abstractions

```python
# ❌ Domain layer knows about database
class Order:
    def save(self):
        db.session.add(self)  # Domain shouldn't know about DB!
        db.session.commit()

# ✅ Domain stays pure
class Order:
    def confirm(self):
        self.status = 'confirmed'

class OrderRepository:
    def save(self, order):
        db.session.add(order)
        db.session.commit()
```

### 3. Business Logic in Controllers

```python
# ❌ Business logic in presentation layer
@app.route('/orders/<id>/confirm')
def confirm_order(id):
    order = Order.query.get(id)
    if order.total < 10:  # Business rule in controller!
        return "Minimum order is $10", 400
    if order.status != 'pending':  # Business rule!
        return "Can only confirm pending orders", 400
    order.status = 'confirmed'
    db.session.commit()
    return jsonify(order)

# ✅ Business logic in domain
class Order:
    MIN_TOTAL = 10

    def confirm(self):
        if self.total < self.MIN_TOTAL:
            raise MinimumOrderError(f"Minimum order is ${self.MIN_TOTAL}")
        if self.status != 'pending':
            raise InvalidOrderStateError("Can only confirm pending orders")
        self.status = 'confirmed'

@app.route('/orders/<id>/confirm')
def confirm_order(id):
    order_service.confirm_order(id)  # Delegate to service
    return jsonify({'status': 'success'})
```

## Practical Guidelines

### Organize by Feature (Vertical Slices)

```python
# ✅ Feature-based organization
project/
├── orders/
│   ├── domain/          # Order business logic
│   ├── application/     # Order use cases
│   ├── infrastructure/  # Order persistence
│   └── api/            # Order endpoints
├── payments/
│   ├── domain/
│   ├── application/
│   ├── infrastructure/
│   └── api/
└── users/
    ├── domain/
    ├── application/
    ├── infrastructure/
    └── api/
```

### Dependency Rule

```python
# ✅ Dependencies point inward
# Outer layers depend on inner layers
# Inner layers know nothing about outer layers

# Presentation → Application → Domain ← Infrastructure
#                                ↑
#                            Core (no dependencies)
```

### Interface Adapters

```python
# ✅ Use interfaces to invert dependencies
# Domain Layer defines interfaces
class OrderRepository(ABC):
    @abstractmethod
    def save(self, order): pass

# Infrastructure Layer implements
class PostgresOrderRepository(OrderRepository):
    def save(self, order):
        # Implementation
        pass
```

## Audit Checklist

When reviewing a codebase for SoC violations:

1. **God classes** — one class does data access, business logic, and presentation together
2. **Business logic in controllers/routes** — validation rules, domain decisions, or state transitions inside HTTP handlers
3. **Domain objects that call the database** — `self.save()`, `db.session.commit()` inside a domain model
4. **Infrastructure leaking into domain** — domain code imports Redis, RabbitMQ, SMTP, or similar
5. **Configuration hardcoded in logic** — hostnames, credentials, or feature flags inlined in service classes
6. **Mixed read/write concerns** — a single method or class handles both queries and commands with branching on operation type
7. **Presentation mixed with logic** — HTML or JSON serialization inside service or domain classes
8. **Validation scattered across layers** — same business rule enforced in controller, service, and model separately (see also: DRY)

---

## Related Principles

- **SRP**: Each class has one concern
- **DIP**: Depend on abstractions between concerns
- **DRY**: Don't duplicate across concerns
- **Layered Architecture**: Specific way to separate concerns
- **Clean Architecture**: Dependency rule for SoC

## Decision Framework

When designing a module, ask:

1. **What is this module's primary concern?**
2. **Does it mix multiple concerns?**
3. **Can I change this concern without affecting others?**
4. **Are dependencies pointing in the right direction?**
5. **Is business logic mixed with infrastructure?**
