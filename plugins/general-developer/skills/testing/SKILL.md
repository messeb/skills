---
description: Testing patterns for backend development — unit tests with AAA structure, integration tests, test organization, mocking, and coverage.
---

# Testing Patterns and Best Practices

## Testing Philosophy

### Testing Pyramid

```text
        /\
       /  \  E2E Tests (Few)
      /____\
     /      \
    / Integ. \ Integration Tests (Some)
   /__________\
  /            \
 /  Unit Tests  \ Unit Tests (Many)
/________________\
```

**Unit Tests (70-80%)**: Fast, isolated, test business logic
**Integration Tests (15-25%)**: Test components working together
**E2E Tests (5-10%)**: Test complete user workflows

### Test Characteristics (F.I.R.S.T.)

- **Fast**: Tests should run quickly
- **Independent**: Tests should not depend on each other
- **Repeatable**: Same result every time
- **Self-validating**: Pass or fail, no manual verification
- **Timely**: Written alongside or before the code

## Unit Testing

### Unit Test Structure (AAA Pattern)

```python
def test_order_calculates_total_correctly():
    # Arrange: Set up test data and dependencies
    order = Order(OrderId("123"), CustomerId("456"))
    item1 = OrderItem(ProductId("p1"), quantity=2, unit_price=Money(10, "USD"))
    item2 = OrderItem(ProductId("p2"), quantity=1, unit_price=Money(15, "USD"))

    # Act: Perform the operation
    order.add_item(item1)
    order.add_item(item2)

    # Assert: Verify the result
    assert order.total == Money(35, "USD")
```

### Testing Domain Logic

**Test entity behavior:**

```python
class TestOrder:
    def test_new_order_starts_in_pending_status(self):
        order = Order(OrderId("123"), CustomerId("456"))
        assert order.status == OrderStatus.PENDING

    def test_add_item_increases_total(self):
        order = Order(OrderId("123"), CustomerId("456"))
        initial_total = order.total

        order.add_item(OrderItem(ProductId("p1"), 2, Money(10, "USD")))

        assert order.total == initial_total.add(Money(20, "USD"))

    def test_cannot_add_item_to_placed_order(self):
        order = Order(OrderId("123"), CustomerId("456"))
        order.add_item(OrderItem(ProductId("p1"), 1, Money(10, "USD")))
        order.place()

        with pytest.raises(OrderNotModifiableError):
            order.add_item(OrderItem(ProductId("p2"), 1, Money(5, "USD")))

    def test_cannot_place_empty_order(self):
        order = Order(OrderId("123"), CustomerId("456"))

        with pytest.raises(InvalidOrderError):
            order.place()
```

**Test value objects:**

```python
class TestMoney:
    def test_money_addition(self):
        m1 = Money(Decimal("10.50"), "USD")
        m2 = Money(Decimal("5.25"), "USD")

        result = m1.add(m2)

        assert result == Money(Decimal("15.75"), "USD")

    def test_cannot_add_different_currencies(self):
        m1 = Money(Decimal("10"), "USD")
        m2 = Money(Decimal("10"), "EUR")

        with pytest.raises(CurrencyMismatchError):
            m1.add(m2)

    def test_money_is_immutable(self):
        m1 = Money(Decimal("10"), "USD")
        m2 = m1.add(Money(Decimal("5"), "USD"))

        assert m1 == Money(Decimal("10"), "USD")  # Original unchanged
        assert m2 == Money(Decimal("15"), "USD")
```

**Test domain services:**

```python
class TestTransferService:
    def test_transfer_moves_money_between_accounts(self):
        # Arrange
        from_account = Account(AccountId("1"), Money(100, "USD"))
        to_account = Account(AccountId("2"), Money(50, "USD"))
        account_repo = InMemoryAccountRepository()
        account_repo.save(from_account)
        account_repo.save(to_account)
        service = TransferService(account_repo)

        # Act
        service.transfer(
            from_account.id,
            to_account.id,
            Money(30, "USD")
        )

        # Assert
        updated_from = account_repo.find_by_id(from_account.id)
        updated_to = account_repo.find_by_id(to_account.id)
        assert updated_from.balance == Money(70, "USD")
        assert updated_to.balance == Money(80, "USD")

    def test_transfer_fails_with_insufficient_funds(self):
        from_account = Account(AccountId("1"), Money(20, "USD"))
        to_account = Account(AccountId("2"), Money(50, "USD"))
        account_repo = InMemoryAccountRepository()
        account_repo.save(from_account)
        account_repo.save(to_account)
        service = TransferService(account_repo)

        with pytest.raises(InsufficientFundsError):
            service.transfer(
                from_account.id,
                to_account.id,
                Money(30, "USD")
            )
```

### Mocking and Test Doubles

**Use test doubles to isolate dependencies:**

```python
from unittest.mock import Mock, MagicMock

class TestOrderService:
    def test_create_order_saves_to_repository(self):
        # Arrange
        order_repo = Mock(spec=OrderRepository)
        email_service = Mock(spec=EmailService)
        service = OrderService(order_repo, email_service)

        request = CreateOrderRequest(
            customer_id="cust-123",
            items=[{"product_id": "prod-1", "quantity": 2, "price": 10.0}]
        )

        # Act
        service.create_order(request)

        # Assert
        order_repo.save.assert_called_once()
        saved_order = order_repo.save.call_args[0][0]
        assert saved_order.customer_id == "cust-123"

    def test_create_order_sends_confirmation_email(self):
        order_repo = Mock(spec=OrderRepository)
        email_service = Mock(spec=EmailService)
        service = OrderService(order_repo, email_service)

        request = CreateOrderRequest(
            customer_id="cust-123",
            items=[{"product_id": "prod-1", "quantity": 1, "price": 10.0}]
        )

        service.create_order(request)

        email_service.send_order_confirmation.assert_called_once()
```

**In-memory implementations for integration tests:**

```python
class InMemoryOrderRepository(OrderRepository):
    """Test double that maintains orders in memory"""

    def __init__(self):
        self._orders: dict[str, Order] = {}

    def find_by_id(self, order_id: OrderId) -> Optional[Order]:
        return self._orders.get(order_id.value)

    def save(self, order: Order) -> None:
        self._orders[order.id.value] = order

    def delete(self, order_id: OrderId) -> None:
        self._orders.pop(order_id.value, None)

    def find_by_customer(self, customer_id: CustomerId) -> list[Order]:
        return [
            order for order in self._orders.values()
            if order.customer_id == customer_id
        ]
```

## Integration Testing

### Testing API Endpoints

**Setup test client and database:**

```python
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

@pytest.fixture
def db_session():
    """Create a clean database for each test"""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    session = Session()

    yield session

    session.close()

@pytest.fixture
def client(db_session):
    """Create test client with test database"""
    app.dependency_overrides[get_db] = lambda: db_session
    return TestClient(app)
```

**Test endpoint behavior:**

```python
class TestOrderEndpoints:
    def test_create_order_returns_201(self, client, db_session):
        # Arrange
        request_data = {
            "customer_id": "cust-123",
            "items": [
                {
                    "product_id": "prod-1",
                    "quantity": 2,
                    "unit_price": 10.00
                }
            ]
        }

        # Act
        response = client.post("/api/orders", json=request_data)

        # Assert
        assert response.status_code == 201
        data = response.json()
        assert data["customer_id"] == "cust-123"
        assert data["total"]["amount"] == 20.00
        assert "id" in data

    def test_create_order_persists_to_database(self, client, db_session):
        request_data = {
            "customer_id": "cust-123",
            "items": [
                {"product_id": "prod-1", "quantity": 2, "unit_price": 10.00}
            ]
        }

        response = client.post("/api/orders", json=request_data)
        order_id = response.json()["id"]

        # Verify in database
        order = db_session.query(OrderTable).filter_by(id=order_id).first()
        assert order is not None
        assert order.customer_id == "cust-123"
        assert len(order.items) == 1

    def test_create_order_validates_input(self, client):
        # Missing customer_id
        response = client.post("/api/orders", json={
            "items": [{"product_id": "prod-1", "quantity": 1, "unit_price": 10}]
        })
        assert response.status_code == 400
        assert "customer_id" in response.json()["error"]["message"].lower()

        # Empty items
        response = client.post("/api/orders", json={
            "customer_id": "cust-123",
            "items": []
        })
        assert response.status_code == 400
        assert "items" in response.json()["error"]["message"].lower()

    def test_get_order_returns_404_when_not_found(self, client):
        response = client.get("/api/orders/nonexistent")
        assert response.status_code == 404

    def test_get_order_returns_order_details(self, client, db_session):
        # Create order first
        create_response = client.post("/api/orders", json={
            "customer_id": "cust-123",
            "items": [{"product_id": "prod-1", "quantity": 2, "unit_price": 10}]
        })
        order_id = create_response.json()["id"]

        # Get order
        response = client.get(f"/api/orders/{order_id}")

        assert response.status_code == 200
        data = response.json()
        assert data["id"] == order_id
        assert data["customer_id"] == "cust-123"
        assert len(data["items"]) == 1
```

### Testing Authentication

```python
class TestAuthentication:
    def test_protected_endpoint_requires_authentication(self, client):
        response = client.get("/api/orders/123")
        assert response.status_code == 401

    def test_protected_endpoint_with_valid_token(self, client, auth_token):
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.get("/api/orders/123", headers=headers)
        assert response.status_code in [200, 404]  # Authenticated, not 401

    def test_cannot_access_other_users_orders(self, client, auth_token):
        # Create order for user 1
        order_response = client.post(
            "/api/orders",
            json={"customer_id": "user-1", "items": [...]},
            headers={"Authorization": f"Bearer {auth_token('user-1')}"}
        )
        order_id = order_response.json()["id"]

        # Try to access as user 2
        response = client.get(
            f"/api/orders/{order_id}",
            headers={"Authorization": f"Bearer {auth_token('user-2')}"}
        )
        assert response.status_code == 403
```

### Testing Repository Implementations

```python
class TestPostgresOrderRepository:
    def test_save_and_find_by_id(self, db_session):
        # Arrange
        repo = PostgresOrderRepository(db_session)
        order = Order(OrderId("123"), CustomerId("456"))
        order.add_item(OrderItem(ProductId("p1"), 2, Money(10, "USD")))

        # Act
        repo.save(order)
        found_order = repo.find_by_id(OrderId("123"))

        # Assert
        assert found_order is not None
        assert found_order.id == OrderId("123")
        assert found_order.customer_id == CustomerId("456")
        assert len(found_order.items) == 1

    def test_find_by_customer(self, db_session):
        repo = PostgresOrderRepository(db_session)

        # Create orders for different customers
        order1 = Order(OrderId("1"), CustomerId("cust-1"))
        order2 = Order(OrderId("2"), CustomerId("cust-1"))
        order3 = Order(OrderId("3"), CustomerId("cust-2"))

        repo.save(order1)
        repo.save(order2)
        repo.save(order3)

        # Find orders for customer 1
        orders = repo.find_by_customer(CustomerId("cust-1"))

        assert len(orders) == 2
        assert all(o.customer_id == CustomerId("cust-1") for o in orders)

    def test_delete_removes_order(self, db_session):
        repo = PostgresOrderRepository(db_session)
        order = Order(OrderId("123"), CustomerId("456"))
        repo.save(order)

        repo.delete(OrderId("123"))

        found_order = repo.find_by_id(OrderId("123"))
        assert found_order is None
```

## Test Organization

### Directory Structure

```text
tests/
├── unit/
│   ├── domain/
│   │   ├── test_order.py
│   │   ├── test_money.py
│   │   └── test_order_service.py
│   └── application/
│       └── test_create_order_use_case.py
├── integration/
│   ├── test_order_api.py
│   ├── test_order_repository.py
│   └── test_authentication.py
├── e2e/
│   └── test_order_workflow.py
└── fixtures/
    ├── __init__.py
    └── database.py
```

### Shared Fixtures

**Create reusable test fixtures:**

```python
# tests/fixtures/database.py
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

@pytest.fixture(scope="function")
def db_session():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    session = Session()
    yield session
    session.close()

# tests/fixtures/__init__.py
from .database import db_session

# Make available to all tests
pytest_plugins = ["tests.fixtures"]
```

**Domain object builders:**

```python
# tests/builders.py
class OrderBuilder:
    def __init__(self):
        self._order_id = OrderId("default-id")
        self._customer_id = CustomerId("default-customer")
        self._items = []

    def with_id(self, order_id: OrderId):
        self._order_id = order_id
        return self

    def with_customer(self, customer_id: CustomerId):
        self._customer_id = customer_id
        return self

    def with_item(self, product_id: ProductId, quantity: int, price: Money):
        self._items.append((product_id, quantity, price))
        return self

    def build(self) -> Order:
        order = Order(self._order_id, self._customer_id)
        for product_id, quantity, price in self._items:
            order.add_item(OrderItem(product_id, quantity, price))
        return order

# Usage in tests
def test_order_total():
    order = (
        OrderBuilder()
        .with_id(OrderId("123"))
        .with_item(ProductId("p1"), 2, Money(10, "USD"))
        .with_item(ProductId("p2"), 1, Money(15, "USD"))
        .build()
    )
    assert order.total == Money(35, "USD")
```

## Test Coverage

```bash
# Run tests with coverage
pytest --cov=src --cov-report=html

# Aim for 80%+ overall coverage
# 100% for domain logic
# 70-90% for application layer
# 60-80% for infrastructure layer
```

## Common Testing Patterns

### Parametrized Tests

```python
@pytest.mark.parametrize("quantity,unit_price,expected_total", [
    (1, 10, 10),
    (2, 10, 20),
    (3, 15, 45),
    (0, 10, 0),  # Edge case
])
def test_order_item_subtotal(quantity, unit_price, expected_total):
    item = OrderItem(
        ProductId("p1"),
        quantity,
        Money(unit_price, "USD")
    )
    assert item.subtotal() == Money(expected_total, "USD")
```

### Test Data Factories

```python
# Use factory_boy or similar
import factory

class OrderFactory(factory.Factory):
    class Meta:
        model = Order

    id = factory.LazyFunction(lambda: OrderId(str(uuid.uuid4())))
    customer_id = factory.LazyFunction(lambda: CustomerId(str(uuid.uuid4())))
    status = OrderStatus.PENDING

# Usage
order = OrderFactory()
placed_order = OrderFactory(status=OrderStatus.PLACED)
```

## Audit Checklist

When reviewing a test suite for quality issues:

1. **Test names describe code, not behaviour** — `test_calculate` or `test_save` instead of `test_order_total_includes_all_items`; the name should read as a specification
2. **Only happy path covered** — error handling, validation failures, and boundary conditions have no corresponding tests
3. **Tests share mutable state** — class-level fields mutated across test methods, or tests that pass only when run in a specific order
4. **Non-deterministic tests** — `datetime.now()` without mocking, random data without seeds, or real network calls; these produce flaky results
5. **Over-mocking** — every collaborator is a Mock; the test verifies interactions with test doubles but never exercises real behaviour
6. **Domain logic only reachable through integration tests** — business rules require standing up the full HTTP stack to test; they should be unit-testable in isolation
7. **No AAA structure** — arrange, act, and assert are interleaved, making it hard to see what is being tested and why it passes or fails
8. **Fixture or setup code duplicated across test methods** — copy-pasted `Order(...)` or database setup that belongs in a shared fixture or builder
