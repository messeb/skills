---
description: You Aren't Gonna Need It — implement only what is required now. Every speculative feature has a cost in complexity, maintenance, and misdirection.
---

# YAGNI — You Aren't Gonna Need It

## Examples

### Speculative fields and format support

```python
# ❌ Built for hypothetical future needs
class User:
    def __init__(self, name, email):
        self.name = name
        self.email = email
        self.phone = None          # "We might need this"
        self.address = None        # "Could be useful later"
        self.preferences = {}      # "For future customization"
        self.metadata = {}         # "Who knows what we'll store"
        self.tags = []             # "Might want to tag users"
        self.custom_fields = {}    # "For anything else"

    def serialize(self, format='json'):
        if format == 'json':
            return json.dumps(self.__dict__)
        elif format == 'xml':   # Never actually used
            return self._to_xml()
        elif format == 'yaml':  # Never actually used
            return self._to_yaml()

# ✅ Only what is currently required
class User:
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email

    def to_json(self) -> str:
        return json.dumps({'name': self.name, 'email': self.email})
```

### Premature abstraction

```python
# ❌ Generic framework for one concrete case
class BaseHandler(ABC):
    @abstractmethod
    def validate(self): pass

    @abstractmethod
    def process(self): pass

    @abstractmethod
    def notify(self): pass  # OrderHandler doesn't even need notifications

class UserHandler(BaseHandler):
    def validate(self): pass
    def process(self): pass
    def notify(self): pass

class OrderHandler(BaseHandler):
    def validate(self): pass
    def process(self): pass
    def notify(self): pass  # Forced to implement — YAGNI

# ✅ Solve the specific problem; extract when the third case arrives
def create_user(user_data):
    validate_user_data(user_data)
    user = User(**user_data)
    db.save(user)
    return user

def create_order(order_data):
    validate_order_data(order_data)
    order = Order(**order_data)
    db.save(order)
    send_order_notification(order)  # Actually needed here
    return order
```

---

## Common Scenarios

### Configuration overload

```python
# ❌ Parameterised for every imaginable option
class EmailService:
    def __init__(
        self,
        smtp_host: str,
        smtp_port: int,
        use_tls: bool = True,
        use_ssl: bool = False,      # "Might need both"
        timeout: int = 30,
        retry_count: int = 3,
        retry_delay: int = 1,
        max_connections: int = 10,  # "For scalability"
        pool_size: int = 5,         # "For performance"
        auth_method: str = 'plain', # "Support multiple auth"
    ):
        pass

# ✅ Start with what the single caller actually needs
class EmailService:
    def __init__(self, smtp_host: str, smtp_port: int):
        self.smtp_host = smtp_host
        self.smtp_port = smtp_port
        self.use_tls = True  # Sensible default; add parameter when a caller needs False
```

### Premature plugin/hook system

```python
# ❌ Extensibility before there is a second concrete extension
class ReportGenerator:
    def __init__(self):
        self.plugins = []
        self.hooks = {
            'before_generate': [],
            'after_generate': [],
            'on_error': [],
            'on_success': []
        }

    def generate(self, data):
        self._run_hooks('before_generate', data)
        result = self._create_pdf(data)
        self._run_hooks('after_generate', result)
        return result

# ✅ Simple, direct implementation; add hooks when the second extension need arrives
class ReportGenerator:
    def generate(self, data):
        return self._create_pdf(data)
```

### API versioning before v2 exists

```python
# ❌ Version parameter with only one value ever used
class UserAPI:
    def create_user(self, data, version='v1'):
        if version == 'v1':
            return self._create_user_v1(data)
        # v2, v3 never materialise

# ✅ Simple current implementation; add versioning when v2 requirements arrive
class UserAPI:
    def create_user(self, data):
        user = User(**data)
        db.save(user)
        return user
```

### Over-designed schema

```sql
-- ❌ Nullable columns "for the future"
CREATE TABLE users (
    id          SERIAL PRIMARY KEY,
    email       VARCHAR(255),
    name        VARCHAR(255),
    phone       VARCHAR(20),   -- "Might need"
    address     TEXT,          -- "Could be useful"
    preferences JSONB,         -- "For future"
    metadata    JSONB,         -- "Who knows"
    settings    JSONB          -- "Flexibility"
);

-- ✅ Add columns when a feature actually requires them
CREATE TABLE users (
    id    SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    name  VARCHAR(255) NOT NULL
);
```

---

## Start Minimal, Grow When Needed

```python
# Phase 1: minimal — what is needed now
def send_notification(user_email, message):
    smtp.send(user_email, message)

# Phase 2: add retry only after observing real delivery failures
def send_notification(user_email, message, retry=3):
    for attempt in range(retry):
        try:
            smtp.send(user_email, message)
            return
        except SMTPException:
            if attempt == retry - 1:
                raise

# Phase 3: add channels only when a second channel is actually adopted
def send_notification(user_email, message, channel='email'):
    if channel == 'email':
        send_email(user_email, message)
    elif channel == 'sms':
        send_sms(user_phone, message)
```

Each phase was added when there was a concrete reason — not in anticipation of one.

---

## Audit Checklist

When reviewing a codebase for YAGNI violations:

1. **Nullable fields with no current writer** — `phone = None`, `metadata = {}`, `custom_fields = {}` that nothing in the codebase ever sets
2. **Configuration parameters whose only caller uses the default** — the parameter exists but every call site omits it
3. **Format/version/channel parameters with only one branch ever reached** — `format='json'` or `version='v1'` where the other branches are dead code
4. **Abstract base class with a single concrete implementation** — the abstraction was added for hypothetical future implementations, not a present need
5. **Plugin or hook system with no registered plugins** — the extension mechanism fires for zero or one handler
6. **API endpoints or HTTP methods with no caller** — routes that were added "just in case" and receive no traffic
7. **Generic utilities or helpers used in exactly one place** — the generality is speculative; a specific function would be simpler
8. **Tests for scenarios that cannot happen with current data** — testing permutations of optional fields that are never populated

---

## Balancing YAGNI with Other Principles

**YAGNI vs. DRY**: don't extract duplication into an abstraction until the third occurrence confirms the pattern is real (Rule of Three). Premature extraction produces the wrong abstraction.

**YAGNI vs. refactoring**: refactor to make the current code clearer and easier to change — not to accommodate hypothetical future requirements.

**YAGNI vs. architecture**: architect for known constraints (load, latency, team size); do not architect for speculative scale or imagined future features.

---

## Decision Framework

| Question | YAGNI says… |
|----------|-------------|
| Is there a current requirement for this? | If no — don't build it |
| Is this driven by user feedback or by speculation? | If speculation — defer |
| What is the cost of adding it later? | Usually lower than the cost of carrying it now |
| Will removing this break any current behaviour? | If no — it probably shouldn't be there |

---

## Related Principles

- **KISS** — YAGNI prevents features from being added; KISS keeps the features that are added as simple as possible
- **DRY** — don't extract until the pattern is proven real; the wrong abstraction is worse than duplication
- **BDUF** — over-designed upfront architecture is YAGNI at the system level
