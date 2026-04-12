---
description: Go HTTP API with Gin — server setup, routing, middleware, request binding, JSON responses, error handling, and graceful shutdown.
---

# Go HTTP API

## Core Framework — Gin

Gin is the most popular Go HTTP framework. It provides a fast router with radix-tree path matching, middleware support, request binding, and built-in JSON/XML rendering.

```bash
go get github.com/gin-gonic/gin
```

---

## Server Setup

```go
// internal/server/server.go
package server

import (
    "context"
    "fmt"
    "log/slog"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    "github.com/myorg/myapp/internal/config"
    "github.com/myorg/myapp/internal/handler"
)

type Server struct {
    http *http.Server
}

func New(cfg *config.Config, h *handler.Handler) *Server {
    if cfg.Env == "production" {
        gin.SetMode(gin.ReleaseMode)
    }

    router := gin.New()
    router.Use(
        gin.Recovery(),                   // recover from panics
        handler.RequestID(),              // attach/forward X-Request-ID
        handler.Logger(slog.Default()),   // structured access log
    )

    h.RegisterRoutes(router)

    httpSrv := &http.Server{
        Addr:         cfg.HTTPAddr,
        Handler:      router,
        ReadTimeout:  cfg.ReadTimeout,
        WriteTimeout: cfg.WriteTimeout,
        IdleTimeout:  cfg.IdleTimeout,
    }

    return &Server{http: httpSrv}
}

func (s *Server) Start(ctx context.Context) error {
    errCh := make(chan error, 1)

    go func() {
        slog.Info("server listening", "addr", s.http.Addr)
        if err := s.http.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            errCh <- err
        }
    }()

    select {
    case err := <-errCh:
        return fmt.Errorf("server error: %w", err)
    case <-ctx.Done():
        slog.Info("shutting down server")
        shutCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
        defer cancel()
        return s.http.Shutdown(shutCtx)
    }
}
```

> **Never use `gin.Default()`** in production — it registers the default Logger and Recovery middleware which write to `os.Stdout` in a non-structured format. Use `gin.New()` and attach your own middleware.

---

## Routing

```go
// internal/handler/handler.go
func (h *Handler) RegisterRoutes(r *gin.Engine) {
    // Health endpoints — no auth required
    r.GET("/healthz", h.healthz)
    r.GET("/readyz", h.readyz)

    // API v1 group
    v1 := r.Group("/api/v1")
    {
        users := v1.Group("/users")
        {
            users.GET("", h.listUsers)
            users.POST("", h.createUser)
            users.GET("/:id", h.getUser)
            users.PUT("/:id", h.updateUser)
            users.DELETE("/:id", h.deleteUser)
        }

        orders := v1.Group("/orders")
        orders.Use(h.AuthRequired())   // middleware scoped to this group
        {
            orders.GET("", h.listOrders)
            orders.POST("", h.createOrder)
        }
    }
}
```

Path parameter extraction:

```go
func (h *Handler) getUser(c *gin.Context) {
    id := c.Param("id")   // from /:id
    // ...
}
```

Query parameters:

```go
func (h *Handler) listUsers(c *gin.Context) {
    page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
    limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
    // ...
}
```

---

## Handlers — Thin and Delegating

```go
// internal/handler/user_handler.go
package handler

import (
    "net/http"

    "github.com/gin-gonic/gin"
    "github.com/myorg/myapp/internal/service"
)

type Handler struct {
    users service.UserService
}

func New(users service.UserService) *Handler {
    return &Handler{users: users}
}

func (h *Handler) getUser(c *gin.Context) {
    id := c.Param("id")

    user, err := h.users.GetByID(c.Request.Context(), id)
    if err != nil {
        respondError(c, err)
        return
    }

    c.JSON(http.StatusOK, user)
}

func (h *Handler) createUser(c *gin.Context) {
    var req CreateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    user, err := h.users.Create(c.Request.Context(), req.toParams())
    if err != nil {
        respondError(c, err)
        return
    }

    c.JSON(http.StatusCreated, user)
}
```

---

## Request Binding and Validation

Gin integrates with `go-playground/validator` via struct tags.

```go
type CreateUserRequest struct {
    Name  string `json:"name"  binding:"required,min=2,max=100"`
    Email string `json:"email" binding:"required,email"`
    Age   int    `json:"age"   binding:"omitempty,gte=0,lte=130"`
}

// ShouldBindJSON returns an error without aborting — use in handlers
if err := c.ShouldBindJSON(&req); err != nil {
    c.JSON(http.StatusUnprocessableEntity, gin.H{"error": err.Error()})
    return
}

// Bind also sources from query params, form, or path
type ListQuery struct {
    Page  int    `form:"page"   binding:"omitempty,min=1"`
    Limit int    `form:"limit"  binding:"omitempty,min=1,max=100"`
    Sort  string `form:"sort"   binding:"omitempty,oneof=asc desc"`
}

var q ListQuery
if err := c.ShouldBindQuery(&q); err != nil {
    c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
    return
}
```

---

## Error Handling

Centralise error-to-response mapping in one place.

```go
// internal/handler/errors.go
package handler

import (
    "errors"
    "log/slog"
    "net/http"

    "github.com/gin-gonic/gin"
    "github.com/myorg/myapp/internal/domain"
)

func respondError(c *gin.Context, err error) {
    var apiErr *domain.APIError
    switch {
    case errors.As(err, &apiErr):
        c.JSON(apiErr.Code, gin.H{"error": apiErr.Message})
    case errors.Is(err, domain.ErrNotFound):
        c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
    case errors.Is(err, domain.ErrConflict):
        c.JSON(http.StatusConflict, gin.H{"error": "conflict"})
    case errors.Is(err, domain.ErrUnauthorized):
        c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
    default:
        slog.Error("unhandled error", "error", err, "path", c.FullPath())
        c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
    }
}
```

---

## Middleware

Gin middleware is a `gin.HandlerFunc` — a function that receives `*gin.Context`.

### Request ID

```go
func RequestID() gin.HandlerFunc {
    return func(c *gin.Context) {
        id := c.GetHeader("X-Request-ID")
        if id == "" {
            id = uuid.NewString()
        }
        c.Set("request_id", id)
        c.Header("X-Request-ID", id)
        c.Next()
    }
}
```

### Structured logger

```go
func Logger(logger *slog.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        c.Next()

        logger.Info("request",
            "method", c.Request.Method,
            "path", c.FullPath(),
            "status", c.Writer.Status(),
            "duration", time.Since(start),
            "request_id", c.GetString("request_id"),
            "client_ip", c.ClientIP(),
        )
    }
}
```

### Authentication middleware

```go
func (h *Handler) AuthRequired() gin.HandlerFunc {
    return func(c *gin.Context) {
        token := c.GetHeader("Authorization")
        if token == "" {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "missing token"})
            return
        }

        claims, err := h.auth.ValidateToken(token)
        if err != nil {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
            return
        }

        c.Set("user_id", claims.UserID)
        c.Next()
    }
}

// In a handler — retrieve value set by middleware
func (h *Handler) createOrder(c *gin.Context) {
    userID := c.GetString("user_id")
    // ...
}
```

### Rate limiting (example with `golang.org/x/time/rate`)

```go
func RateLimit(rps float64, burst int) gin.HandlerFunc {
    limiter := rate.NewLimiter(rate.Limit(rps), burst)
    return func(c *gin.Context) {
        if !limiter.Allow() {
            c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{"error": "rate limit exceeded"})
            return
        }
        c.Next()
    }
}
```

---

## Context and Timeouts

Always pass `c.Request.Context()` to service and repository calls so cancellation propagates:

```go
user, err := h.users.GetByID(c.Request.Context(), id)
```

Per-route timeout middleware:

```go
func Timeout(d time.Duration) gin.HandlerFunc {
    return func(c *gin.Context) {
        ctx, cancel := context.WithTimeout(c.Request.Context(), d)
        defer cancel()
        c.Request = c.Request.WithContext(ctx)
        c.Next()
    }
}
```

---

## Health Endpoints

```go
func (h *Handler) healthz(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

func (h *Handler) readyz(c *gin.Context) {
    if err := h.db.PingContext(c.Request.Context()); err != nil {
        c.JSON(http.StatusServiceUnavailable, gin.H{
            "status": "not ready",
            "error":  err.Error(),
        })
        return
    }
    c.JSON(http.StatusOK, gin.H{"status": "ready"})
}
```

---

## Testing Gin Handlers

Use `net/http/httptest` — Gin is compatible with the standard testing approach.

```go
func TestGetUser(t *testing.T) {
    gin.SetMode(gin.TestMode)

    repo := &mockUserRepo{
        findByIDFn: func(ctx context.Context, id string) (*User, error) {
            return &User{ID: id, Name: "Alice"}, nil
        },
    }
    h := handler.New(service.NewUserService(repo))

    router := gin.New()
    router.GET("/api/v1/users/:id", h.getUser)

    req := httptest.NewRequest(http.MethodGet, "/api/v1/users/123", nil)
    rr := httptest.NewRecorder()
    router.ServeHTTP(rr, req)

    assert.Equal(t, http.StatusOK, rr.Code)

    var got User
    require.NoError(t, json.NewDecoder(rr.Body).Decode(&got))
    assert.Equal(t, "Alice", got.Name)
}
```

---

## Audit Checklist

1. **Using `gin.Default()`** — registers a non-structured logger and recovery writing to stdout; use `gin.New()` with explicit middleware for structured logging and proper panic recovery
2. **`gin.SetMode` not set to `ReleaseMode` in production** — debug mode logs every registered route and is more verbose; set `gin.SetMode(gin.ReleaseMode)` when `ENV=production`
3. **Missing timeouts on `http.Server`** — Gin sets no timeouts by itself; always configure `ReadTimeout`, `WriteTimeout`, and `IdleTimeout` on the underlying `http.Server`
4. **Using `c.Abort()` without `return`** — `Abort` prevents pending middleware from running but does not stop the current handler; always `return` after `c.AbortWithStatusJSON`
5. **Passing `gin.Context` to services** — services should receive `context.Context`, not Gin's context; pass `c.Request.Context()` to keep service layer framework-agnostic
6. **`c.Set` / `c.Get` without typed wrappers** — stringly-typed context values cause silent bugs; define typed getter helpers or store domain types directly
7. **Logging full error details to the JSON response** — internal error messages expose implementation details; log with `slog`, respond with a generic message
8. **No `/healthz` or `/readyz` endpoint** — orchestrators and load balancers need health endpoints for traffic routing and rolling deployments
