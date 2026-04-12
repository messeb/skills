---
description: Go modules — go.mod setup, dependency management, versioning, Go workspaces, vendoring, and private modules.
---

# Go Modules

## Module Initialization

```bash
go mod init github.com/myorg/myapp
```

```
# go.mod
module github.com/myorg/myapp

go 1.23.0

require (
    github.com/spf13/cobra v1.8.1
    github.com/stretchr/testify v1.9.0
)

require (
    // Indirect dependencies — managed automatically
    github.com/inconshreveable/mousetrap v1.1.0 // indirect
    github.com/spf13/pflag v1.0.5 // indirect
)
```

---

## Core Commands

```bash
# Add a dependency
go get github.com/some/package@v1.2.3

# Upgrade to latest patch
go get github.com/some/package@latest

# Upgrade all dependencies (patch + minor)
go get -u ./...

# Remove unused dependencies and add missing ones
go mod tidy

# Verify downloaded modules against go.sum
go mod verify

# Show why a package is needed
go mod why github.com/some/package

# Show full dependency graph
go mod graph
```

---

## `go.sum` — Tamper-Evident Checksums

`go.sum` records cryptographic hashes for every module version. **Always commit it.**

```bash
# Regenerate go.sum if it gets out of sync
go mod tidy
```

Never edit `go.sum` by hand. CI should fail if `go.sum` is not consistent with `go.mod`:

```bash
go mod tidy && git diff --exit-code go.sum
```

---

## Versioning

Go modules follow semantic versioning. Major version bumps require a module path change.

```
v0.x.y → no stability guarantee
v1.x.y → stable API
v2.x.y → breaking changes → module path becomes .../v2
```

```go
// go.mod for a v2 module
module github.com/myorg/myapp/v2

// Import in code
import "github.com/myorg/myapp/v2/internal/service"
```

### Pinning a specific version

```bash
go get github.com/some/package@v1.4.2
```

### Using a commit or branch (avoid in production)

```bash
go get github.com/some/package@main
go get github.com/some/package@abc1234
```

---

## Replace Directives — Local Development

Use `replace` to point a dependency at a local checkout during development.

```
# go.mod
replace github.com/myorg/shared => ../shared
```

**Remove all `replace` directives before releasing.** They are valid only in the root module, not in libraries.

---

## Go Workspaces — Multi-Module Development

Workspaces let you work across multiple local modules without `replace` directives.

```bash
# Create a workspace
go work init ./app ./shared ./tools

# Add a module to an existing workspace
go work use ./another-module
```

```
# go.work
go 1.23.0

use (
    ./app
    ./shared
    ./tools
)
```

Workspace changes are local — `go.work` should typically be in `.gitignore` unless the repo is explicitly a workspace repo.

```bash
# Sync workspace with dependencies
go work sync
```

---

## Vendoring

Vendoring copies all dependencies into a `vendor/` directory for offline builds and auditing.

```bash
go mod vendor          # create/update vendor/
go build -mod=vendor   # build from vendor/
go test -mod=vendor ./...
```

Use vendoring when:
- Building in air-gapped environments
- You need to audit or patch dependencies
- You want reproducible builds without a module proxy

Skip vendoring when:
- You trust the module proxy and GOPROXY is reliable
- Repo size is a concern (vendor/ can be large)

---

## Module Proxy and Private Modules

```bash
# GOPROXY — ordered list of module proxies (default)
GOPROXY=https://proxy.golang.org,direct

# GONOSUMCHECK / GONOSUMDB — skip checksum for private modules
GONOSUMDB=github.com/myorg/*
GOPRIVATE=github.com/myorg/*   # sets both GONOSUMDB and GONOPROXY
```

For private GitHub modules:

```bash
# .gitconfig or GOPATH/env
GOPRIVATE=github.com/myorg
git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
```

---

## Dependency Hygiene

### Check for known vulnerabilities

```bash
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...
```

### Check for outdated dependencies

```bash
go list -u -m all          # list available upgrades
go get -u ./...            # upgrade all (use carefully — review go.sum diff)
```

### Minimal version selection (MVS)

Go's MVS algorithm selects the **minimum** version of each dependency that satisfies all requirements. This means:
- Adding a dependency never silently upgrades others
- Builds are reproducible without a lock file beyond `go.sum`
- Upgrading is explicit, not implicit

---

## CI Checks

```yaml
# .github/workflows/ci.yml
- name: Verify go.mod and go.sum are tidy
  run: |
    go mod tidy
    git diff --exit-code go.mod go.sum

- name: Check for vulnerabilities
  run: |
    go install golang.org/x/vuln/cmd/govulncheck@latest
    govulncheck ./...
```

---

## Audit Checklist

1. **`go.sum` not committed** — reproducible builds and tamper detection require `go.sum` in version control
2. **`go mod tidy` not run after adding/removing imports** — `go.mod` and `go.sum` drift from actual imports, causing inconsistent builds
3. **`replace` directives committed in a library module** — `replace` only applies to the root module; shipping it in a library silently has no effect and confuses consumers
4. **Using `@latest` for all dependencies in CI** — `@latest` fetches whatever is current at build time; pin versions in `go.mod` for reproducible CI builds
5. **No `govulncheck` in CI** — known vulnerabilities in transitive dependencies go undetected; add `govulncheck ./...` to the pipeline
6. **Direct import of a package not in `go.mod`** — relying on a transitive dependency directly is fragile; if you import it, require it explicitly
7. **`go.work` committed in a library repo** — workspace files are for local development across modules; committing them in a shared library confuses other consumers
8. **Major version upgrade without updating import paths** — importing `v2` of a module at the old `v1` import path silently uses the old version; update both `go.mod` and all import statements
