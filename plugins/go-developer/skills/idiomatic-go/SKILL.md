---
description: Idiomatic Go — error handling, naming conventions, interfaces, zero values, and patterns that make Go code readable and maintainable.
---

# Idiomatic Go

## Error Handling

Errors are values in Go. Return them, check them, wrap them — never ignore them.

```go
// Bad — ignoring the error
result, _ := strconv.Atoi(input)

// Good — check every error
result, err := strconv.Atoi(input)
if err != nil {
    return fmt.Errorf("invalid port %q: %w", input, err)
}
```

### Wrap errors with context using `%w`

```go
func loadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("loadConfig: %w", err)
    }
    // ...
}
```

Callers can unwrap with `errors.Is` and `errors.As`:

```go
var pathErr *fs.PathError
if errors.As(err, &pathErr) {
    // handle missing file specifically
}
```

### Sentinel errors and custom types

```go
// Sentinel — for identity checks
var ErrNotFound = errors.New("not found")

// Custom type — when callers need structured data from the error
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed on %s: %s", e.Field, e.Message)
}
```

---

## Naming

| What | Convention | Example |
|------|-----------|---------|
| Packages | lowercase, single word | `http`, `user`, `auth` |
| Exported types / funcs | PascalCase | `UserService`, `NewClient` |
| Unexported | camelCase | `parseHeader`, `retryCount` |
| Interfaces | noun or `-er` suffix | `Reader`, `UserStore` |
| Acronyms | all-caps or all-lower | `HTTPClient`, `userID`, `parseURL` |
| Error variables | `Err` prefix | `ErrTimeout`, `ErrNotFound` |

Keep names short in narrow scopes, descriptive in wide ones:

```go
// Fine — i is conventional in a loop
for i, item := range items { ... }

// Good — descriptive for package-level function
func ParseUserFromRequest(r *http.Request) (*User, error) { ... }
```

---

## Interfaces

Define interfaces where they are **used**, not where they are **implemented**.

```go
// Bad — defined in the implementation package, forces consumers to import it
package store
type UserStore interface { ... }

// Good — defined in the consumer package
package service

type userStore interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, u *User) error
}

type UserService struct {
    store userStore
}
```

Keep interfaces small:

```go
// Bad — fat interface couples callers to everything
type Repository interface {
    FindByID(id string) (*User, error)
    FindAll() ([]*User, error)
    Save(u *User) error
    Delete(id string) error
    Count() (int, error)
}

// Good — split by actual usage
type UserReader interface {
    FindByID(ctx context.Context, id string) (*User, error)
}

type UserWriter interface {
    Save(ctx context.Context, u *User) error
}
```

---

## Zero Values and Constructors

Design types so their zero value is useful when possible:

```go
// Zero value is usable — no constructor needed
var buf bytes.Buffer
buf.WriteString("hello")

// Constructor needed — zero value would be invalid
func NewServer(addr string, db *sql.DB) *Server {
    return &Server{
        addr:    addr,
        db:      db,
        timeout: 30 * time.Second,
    }
}
```

---

## Avoid `init()`

`init()` runs implicitly, in an uncontrolled order, and makes testing difficult. Prefer explicit initialization:

```go
// Bad
var db *sql.DB
func init() {
    db, _ = sql.Open("postgres", os.Getenv("DATABASE_URL"))
}

// Good — explicit, testable, error-returning
func NewDB(dsn string) (*sql.DB, error) {
    db, err := sql.Open("postgres", dsn)
    if err != nil {
        return nil, fmt.Errorf("NewDB: %w", err)
    }
    return db, nil
}
```

---

## Avoid `panic` in Libraries

`panic` is for unrecoverable programmer errors (nil dereference, index out of range). In application code and library code, return errors instead.

```go
// Bad — crashes the whole process on bad input
func MustParseURL(raw string) *url.URL {
    u, err := url.Parse(raw)
    if err != nil {
        panic(err)
    }
    return u
}

// Good — let the caller decide what to do
func ParseURL(raw string) (*url.URL, error) {
    return url.Parse(raw)
}

// Acceptable — `Must*` variants at package init for known-good constants
var baseURL = MustParseURL("https://api.example.com")
```

---

## Struct Embedding vs Composition

Embed for **is-a** relationships that promote methods. Prefer composition otherwise.

```go
// Embedding — promotes all methods of http.Server
type Server struct {
    http.Server
    db *sql.DB
}

// Composition — explicit, avoids accidental method promotion
type UserService struct {
    repo   UserRepository
    mailer Mailer
    logger *slog.Logger
}
```

---

## Constants Over Magic Values

```go
// Bad
if status == 2 { ... }

// Good
const (
    StatusPending  = 1
    StatusApproved = 2
    StatusRejected = 3
)

// Better — typed constants prevent misuse
type Status int

const (
    StatusPending  Status = iota + 1
    StatusApproved
    StatusRejected
)
```

---

## Audit Checklist

1. **Blank identifier on error** — `_, _ = fn()` silently swallows failures; every error must be checked or explicitly documented as intentionally ignored
2. **Error strings start with a capital letter or end with punctuation** — `errors.New("User not found.")` violates Go conventions; error strings should be lowercase and unpunctuated so they compose cleanly with `fmt.Errorf`
3. **Fat interfaces defined in implementation packages** — forces callers to import the wrong package; define interfaces at the point of use
4. **`init()` for side-effectful setup** — database connections, file reads, or global state in `init()` makes testing and startup order unpredictable
5. **Magic numbers and strings** — literal `200`, `"admin"`, `86400` scattered across handlers; define named constants
6. **Exported types with unexported fields that have no constructor** — zero value is unusable and callers have no way to construct a valid instance
7. **`panic` in non-main packages** — panics in libraries crash calling programs; return errors instead
8. **Stutter in names** — `user.UserService`, `http.HTTPHandler`; the package name is part of the identifier, so `user.Service` and `http.Handler` are correct
