---
description: Go project layout — standard directory structure for CLI tools and backend services, module setup, and internal package boundaries.
---

# Go Project Layout

## Standard Layout

```
myapp/
├── cmd/
│   └── myapp/
│       └── main.go          # Entry point — thin, wires everything together
├── internal/
│   ├── config/              # Configuration loading and validation
│   ├── server/              # HTTP/gRPC server setup
│   ├── handler/             # Request handlers
│   ├── service/             # Business logic
│   ├── repository/          # Data access layer
│   └── domain/              # Core domain types and interfaces
├── pkg/                     # Packages safe to import by external projects
│   └── apierror/
├── api/                     # OpenAPI specs, protobuf definitions
│   └── openapi.yaml
├── migrations/              # Database migration files
├── scripts/                 # Build, lint, seed scripts
├── .github/
│   └── workflows/
├── go.mod
├── go.sum
├── Makefile
└── README.md
```

---

## `cmd/` — Entry Points

One subdirectory per binary. `main.go` should only wire dependencies and call `run()`.

```go
// cmd/myapp/main.go
package main

import (
    "context"
    "log/slog"
    "os"

    "github.com/myorg/myapp/internal/config"
    "github.com/myorg/myapp/internal/server"
)

func main() {
    if err := run(); err != nil {
        slog.Error("startup failed", "error", err)
        os.Exit(1)
    }
}

func run() error {
    cfg, err := config.Load()
    if err != nil {
        return fmt.Errorf("load config: %w", err)
    }

    srv, err := server.New(cfg)
    if err != nil {
        return fmt.Errorf("create server: %w", err)
    }

    return srv.Start(context.Background())
}
```

Multiple binaries in one repo:

```
cmd/
├── api/main.go        # HTTP API server
├── worker/main.go     # Background job processor
└── migrate/main.go    # Database migration runner
```

---

## `internal/` — Private Application Code

Packages under `internal/` cannot be imported by code outside this module. Use it for everything that should not be a public API.

```
internal/
├── config/
│   └── config.go        # Config struct + Load() function
├── domain/
│   ├── user.go          # User type, value objects
│   └── errors.go        # Domain-specific errors
├── service/
│   └── user_service.go  # Business logic, depends on domain + repository interfaces
├── repository/
│   ├── user_repo.go     # Concrete DB implementation
│   └── user_repo_test.go
└── handler/
    ├── user_handler.go  # HTTP handler (thin, delegates to service)
    └── middleware.go
```

### Layer dependencies (enforced by import paths)

```
handler → service → repository → domain
                              ↘ external packages (database/sql, etc.)
```

- `domain` has **no internal imports** — it is the innermost layer
- `service` depends on `domain` and `repository` **interfaces** (not concrete types)
- `handler` depends on `service` **interfaces**

---

## `pkg/` — Shared Public Packages

Only put packages here that you genuinely intend external consumers to import. When in doubt, use `internal/`.

```
pkg/
├── apierror/         # Standardized API error types
├── pagination/       # Cursor/offset pagination helpers
└── validate/         # Input validation utilities
```

---

## Module Setup

```bash
go mod init github.com/myorg/myapp
```

```
# go.mod
module github.com/myorg/myapp

go 1.23

require (
    github.com/spf13/cobra v1.8.0
    github.com/spf13/viper v1.18.0
)
```

### Go workspaces (multi-module repos)

```bash
go work init ./app ./shared
```

```
# go.work
go 1.23

use (
    ./app
    ./shared
)
```

---

## Makefile Conventions

```makefile
.PHONY: build test lint vet tidy

build:
	go build -o bin/myapp ./cmd/myapp

test:
	go test ./... -race -count=1

lint:
	golangci-lint run ./...

vet:
	go vet ./...

tidy:
	go mod tidy

run:
	go run ./cmd/myapp
```

---

## Config Loading Pattern

```go
// internal/config/config.go
package config

import (
    "fmt"
    "os"
    "strconv"
    "time"
)

type Config struct {
    HTTPAddr        string
    DatabaseDSN     string
    ReadTimeout     time.Duration
    ShutdownTimeout time.Duration
}

func Load() (*Config, error) {
    cfg := &Config{
        HTTPAddr:        getEnv("HTTP_ADDR", ":8080"),
        DatabaseDSN:     mustGetEnv("DATABASE_DSN"),
        ReadTimeout:     30 * time.Second,
        ShutdownTimeout: 10 * time.Second,
    }

    if v := os.Getenv("READ_TIMEOUT_SECS"); v != "" {
        secs, err := strconv.Atoi(v)
        if err != nil {
            return nil, fmt.Errorf("invalid READ_TIMEOUT_SECS: %w", err)
        }
        cfg.ReadTimeout = time.Duration(secs) * time.Second
    }

    return cfg, nil
}

func getEnv(key, fallback string) string {
    if v := os.Getenv(key); v != "" {
        return v
    }
    return fallback
}

func mustGetEnv(key string) string {
    v := os.Getenv(key)
    if v == "" {
        panic(fmt.Sprintf("required environment variable %q is not set", key))
    }
    return v
}
```

---

## Audit Checklist

1. **Business logic in `main.go`** — `main` should only wire dependencies; logic buried there cannot be tested or reused
2. **No `internal/` boundary** — packages without `internal/` protection can be imported by any Go code, making refactoring risky
3. **Single flat package** — everything in one package loses the ability to enforce layer boundaries and makes the codebase hard to navigate
4. **`pkg/` used as a dumping ground** — packages in `pkg/` imply they are stable, public APIs; use `internal/` unless external consumers are intended
5. **Config read directly in business logic** — `os.Getenv` scattered across service and handler files; centralise in a typed `Config` struct loaded at startup
6. **Multiple binaries all in `cmd/` root** — `cmd/main.go` prevents adding a second binary cleanly; always nest under `cmd/<name>/main.go`
7. **Missing `go.sum` in version control** — `go.sum` must be committed; it ensures reproducible, tamper-evident builds
