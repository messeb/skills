---
description: Go testing — table-driven tests, subtests, testify, mocks with interfaces, integration tests, benchmarks, and test helpers.
---

# Go Testing

## Test File Conventions

```
internal/service/
├── user_service.go
└── user_service_test.go   ← same package (white-box) or _test suffix (black-box)
```

```go
// White-box test — same package, accesses unexported identifiers
package service

// Black-box test — external package, tests only exported API
package service_test
```

---

## Table-Driven Tests

The idiomatic Go testing pattern. One test function, a slice of cases.

```go
func TestParseAmount(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    float64
        wantErr bool
    }{
        {name: "valid integer", input: "100", want: 100.0},
        {name: "valid decimal", input: "9.99", want: 9.99},
        {name: "negative value", input: "-5.00", want: -5.0},
        {name: "empty string", input: "", wantErr: true},
        {name: "non-numeric", input: "abc", wantErr: true},
    }

    for _, tc := range tests {
        t.Run(tc.name, func(t *testing.T) {
            got, err := ParseAmount(tc.input)

            if tc.wantErr {
                if err == nil {
                    t.Fatal("expected error, got nil")
                }
                return
            }

            if err != nil {
                t.Fatalf("unexpected error: %v", err)
            }
            if got != tc.want {
                t.Errorf("got %v, want %v", got, tc.want)
            }
        })
    }
}
```

---

## Subtests and Helpers

```go
func TestUserService(t *testing.T) {
    t.Run("Create", func(t *testing.T) {
        t.Run("valid input returns user", func(t *testing.T) { ... })
        t.Run("duplicate email returns error", func(t *testing.T) { ... })
    })

    t.Run("GetByID", func(t *testing.T) {
        t.Run("existing user", func(t *testing.T) { ... })
        t.Run("unknown ID returns ErrNotFound", func(t *testing.T) { ... })
    })
}
```

### Test helper with `t.Helper()`

```go
func assertNoError(t *testing.T, err error) {
    t.Helper()   // makes failures point to the caller, not this function
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
}

func assertEqual[T comparable](t *testing.T, got, want T) {
    t.Helper()
    if got != want {
        t.Errorf("got %v, want %v", got, want)
    }
}
```

---

## Testify — Assertions and Mocks

```bash
go get github.com/stretchr/testify
```

### `assert` and `require`

```go
import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestCreateUser(t *testing.T) {
    svc := setupService(t)

    user, err := svc.Create(context.Background(), CreateParams{
        Name:  "Alice",
        Email: "alice@example.com",
    })

    require.NoError(t, err)              // stops the test on failure
    assert.Equal(t, "Alice", user.Name)  // continues on failure
    assert.NotEmpty(t, user.ID)
    assert.WithinDuration(t, time.Now(), user.CreatedAt, time.Second)
}
```

`require` = stop immediately on failure. `assert` = continue and collect all failures.

---

## Mocking with Interfaces

Define a minimal interface, implement a fake for tests.

```go
// internal/service/user_service.go
type userRepository interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, u *User) error
}
```

### Hand-written mock

```go
// internal/service/user_service_test.go
type mockUserRepo struct {
    findByIDFn func(ctx context.Context, id string) (*User, error)
    saveFn     func(ctx context.Context, u *User) error
}

func (m *mockUserRepo) FindByID(ctx context.Context, id string) (*User, error) {
    return m.findByIDFn(ctx, id)
}

func (m *mockUserRepo) Save(ctx context.Context, u *User) error {
    return m.saveFn(ctx, u)
}

func TestGetUser_NotFound(t *testing.T) {
    repo := &mockUserRepo{
        findByIDFn: func(ctx context.Context, id string) (*User, error) {
            return nil, ErrNotFound
        },
    }
    svc := NewUserService(repo)

    _, err := svc.GetByID(context.Background(), "unknown")

    require.ErrorIs(t, err, ErrNotFound)
}
```

### Generated mocks with `mockery`

```bash
go install github.com/vektra/mockery/v2@latest
mockery --name=userRepository --output=mocks --outpkg=mocks
```

```go
import "github.com/myorg/myapp/mocks"

func TestGetUser(t *testing.T) {
    repo := mocks.NewUserRepository(t)
    repo.On("FindByID", mock.Anything, "123").Return(&User{ID: "123", Name: "Alice"}, nil)

    svc := NewUserService(repo)
    user, err := svc.GetByID(context.Background(), "123")

    require.NoError(t, err)
    assert.Equal(t, "Alice", user.Name)
    repo.AssertExpectations(t)
}
```

---

## HTTP Handler Tests

Use `net/http/httptest` to test handlers without a running server.

```go
func TestGetUser_Handler(t *testing.T) {
    repo := &mockUserRepo{
        findByIDFn: func(ctx context.Context, id string) (*User, error) {
            return &User{ID: id, Name: "Alice"}, nil
        },
    }
    h := handler.New(service.NewUserService(repo))

    mux := http.NewServeMux()
    h.RegisterRoutes(mux)

    req := httptest.NewRequest(http.MethodGet, "/api/users/123", nil)
    rr := httptest.NewRecorder()
    mux.ServeHTTP(rr, req)

    assert.Equal(t, http.StatusOK, rr.Code)

    var got User
    require.NoError(t, json.NewDecoder(rr.Body).Decode(&got))
    assert.Equal(t, "Alice", got.Name)
}
```

---

## Integration Tests with `TestMain`

```go
// internal/repository/integration_test.go
//go:build integration

package repository_test

import (
    "os"
    "testing"
)

var testDB *sql.DB

func TestMain(m *testing.M) {
    db, cleanup := setupTestDB()
    testDB = db

    code := m.Run()

    cleanup()
    os.Exit(code)
}

func setupTestDB() (*sql.DB, func()) {
    dsn := os.Getenv("TEST_DATABASE_DSN")
    if dsn == "" {
        dsn = "postgres://postgres:postgres@localhost:5432/testdb?sslmode=disable"
    }

    db, err := sql.Open("postgres", dsn)
    if err != nil {
        panic(err)
    }

    return db, func() { db.Close() }
}
```

Run only integration tests:

```bash
go test -tags integration ./internal/repository/...
```

---

## Parallel Tests

```go
func TestProcess(t *testing.T) {
    tests := []struct{ name, input string }{ ... }

    for _, tc := range tests {
        t.Run(tc.name, func(t *testing.T) {
            t.Parallel()   // run subtests concurrently

            // tc is captured per-iteration in Go 1.22+
            // In Go < 1.22: tc := tc  to avoid loop variable capture
            result := Process(tc.input)
            assert.NotEmpty(t, result)
        })
    }
}
```

---

## Benchmarks

```go
func BenchmarkParseAmount(b *testing.B) {
    b.ReportAllocs()
    for range b.N {
        _, _ = ParseAmount("9.99")
    }
}
```

```bash
go test -bench=. -benchmem ./...
```

---

## Race Detection

```bash
go test -race ./...
```

Run with `-race` in CI always. The race detector has near-zero false positives.

---

## Test Coverage

```bash
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out          # HTML report
go tool cover -func=coverage.out          # function-level summary
```

---

## Audit Checklist

1. **`t.Fatal` / `t.Error` outside of `TestXxx` functions without `t.Helper()`** — failure messages point to the wrong line; mark all assertion helpers with `t.Helper()`
2. **No table-driven tests for functions with multiple input variations** — copy-pasted test cases diverge over time; consolidate into a `tests` slice
3. **Mocking at the wrong layer** — mocking HTTP clients instead of the interface the service depends on couples tests to transport details; mock at the interface boundary
4. **Integration tests mixed with unit tests** — slow DB tests slow down every `go test ./...` run; separate with build tags (`//go:build integration`)
5. **No `-race` flag in CI** — data races are invisible without the race detector; add `-race` to every `go test` invocation
6. **Shared global state between tests** — `var db *sql.DB` at package level means tests affect each other; use `TestMain` or per-test setup functions
7. **`assert` where `require` is needed** — continuing after a nil pointer failure causes a confusing panic; use `require.NoError` when subsequent assertions depend on the result
8. **Tests only cover the happy path** — error paths, edge cases (empty input, zero values, boundary values), and cancellation are where bugs live
