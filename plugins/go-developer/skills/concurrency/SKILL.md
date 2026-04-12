---
description: Go concurrency — goroutines, channels, context cancellation, sync primitives, worker pools, and common pitfalls.
---

# Go Concurrency

## Goroutines — Launch with a Clear Owner

Every goroutine needs an owner responsible for its lifecycle — who starts it, who stops it, and what happens if it panics.

```go
// Bad — fire and forget, no way to know if it finished or failed
go processOrder(order)

// Good — track completion and handle errors
errCh := make(chan error, 1)
go func() {
    errCh <- processOrder(ctx, order)
}()

select {
case err := <-errCh:
    if err != nil {
        return fmt.Errorf("process order: %w", err)
    }
case <-ctx.Done():
    return ctx.Err()
}
```

---

## Context — Cancellation and Deadlines

`context.Context` is the standard mechanism for propagating cancellation, timeouts, and request-scoped values across goroutine boundaries.

```go
// Timeout — cancel after a fixed duration
ctx, cancel := context.WithTimeout(parentCtx, 5*time.Second)
defer cancel()   // always call cancel to release resources

result, err := callExternalAPI(ctx, params)
```

```go
// Cancellation — cancel when a condition is met
ctx, cancel := context.WithCancel(parentCtx)
defer cancel()

go func() {
    <-shutdownSignal
    cancel()
}()
```

### Respect context in long-running operations

```go
func processItems(ctx context.Context, items []Item) error {
    for _, item := range items {
        // Check cancellation at the top of each iteration
        if err := ctx.Err(); err != nil {
            return err
        }

        if err := processItem(ctx, item); err != nil {
            return err
        }
    }
    return nil
}
```

---

## Channels — Communication Between Goroutines

```go
// Unbuffered — sender blocks until receiver is ready (synchronous)
ch := make(chan int)

// Buffered — sender blocks only when buffer is full
ch := make(chan int, 10)
```

### Signal completion with a done channel

```go
done := make(chan struct{})

go func() {
    defer close(done)
    // ... do work
}()

<-done   // wait for completion
```

### Fan-out: distribute work to multiple workers

```go
func fanOut(ctx context.Context, jobs <-chan Job, numWorkers int) <-chan Result {
    results := make(chan Result, numWorkers)

    var wg sync.WaitGroup
    for range numWorkers {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for job := range jobs {
                select {
                case results <- process(ctx, job):
                case <-ctx.Done():
                    return
                }
            }
        }()
    }

    go func() {
        wg.Wait()
        close(results)
    }()

    return results
}
```

### Fan-in: merge multiple channels into one

```go
func fanIn(ctx context.Context, channels ...<-chan Result) <-chan Result {
    merged := make(chan Result)
    var wg sync.WaitGroup

    output := func(ch <-chan Result) {
        defer wg.Done()
        for r := range ch {
            select {
            case merged <- r:
            case <-ctx.Done():
                return
            }
        }
    }

    wg.Add(len(channels))
    for _, ch := range channels {
        go output(ch)
    }

    go func() {
        wg.Wait()
        close(merged)
    }()

    return merged
}
```

---

## Worker Pool

```go
type WorkerPool struct {
    jobs    chan Job
    results chan Result
    wg      sync.WaitGroup
}

func NewWorkerPool(size int) *WorkerPool {
    p := &WorkerPool{
        jobs:    make(chan Job, size*2),
        results: make(chan Result, size*2),
    }

    p.wg.Add(size)
    for range size {
        go p.worker()
    }

    return p
}

func (p *WorkerPool) worker() {
    defer p.wg.Done()
    for job := range p.jobs {
        p.results <- process(job)
    }
}

func (p *WorkerPool) Submit(job Job) {
    p.jobs <- job
}

func (p *WorkerPool) Close() {
    close(p.jobs)    // signal workers to stop
    p.wg.Wait()      // wait for all workers to finish
    close(p.results)
}
```

---

## `sync` Primitives

### `sync.WaitGroup` — wait for a group of goroutines

```go
var wg sync.WaitGroup

for _, item := range items {
    wg.Add(1)
    go func(item Item) {
        defer wg.Done()
        process(item)
    }(item)  // pass item as argument — avoid loop variable capture
}

wg.Wait()
```

### `sync.Mutex` — protect shared state

```go
type SafeCounter struct {
    mu    sync.Mutex
    count int
}

func (c *SafeCounter) Inc() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.count++
}

func (c *SafeCounter) Value() int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.count
}
```

### `sync.RWMutex` — multiple readers, one writer

```go
type Cache struct {
    mu    sync.RWMutex
    items map[string]Item
}

func (c *Cache) Get(key string) (Item, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    item, ok := c.items[key]
    return item, ok
}

func (c *Cache) Set(key string, item Item) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.items[key] = item
}
```

### `sync.Once` — run initialization exactly once

```go
type Singleton struct {
    once     sync.Once
    instance *DB
}

func (s *Singleton) DB() *DB {
    s.once.Do(func() {
        s.instance = connectDB()
    })
    return s.instance
}
```

### `errgroup` — goroutines with error propagation

```go
import "golang.org/x/sync/errgroup"

g, ctx := errgroup.WithContext(ctx)

g.Go(func() error {
    return fetchUsers(ctx)
})
g.Go(func() error {
    return fetchOrders(ctx)
})

if err := g.Wait(); err != nil {
    return fmt.Errorf("parallel fetch: %w", err)
}
```

---

## Common Pitfalls

### Loop variable capture (pre-Go 1.22)

```go
// Bad (Go < 1.22) — all goroutines capture the same variable
for _, v := range items {
    go func() {
        process(v)   // v is shared — race condition
    }()
}

// Good — pass as argument
for _, v := range items {
    go func(v Item) {
        process(v)
    }(v)
}

// Go 1.22+ — loop variable is per-iteration, no issue
```

### Goroutine leak — channel send with no receiver

```go
// Bad — goroutine blocks forever if nobody reads from ch
func fetch(url string) <-chan Result {
    ch := make(chan Result)   // unbuffered
    go func() {
        ch <- doFetch(url)   // blocks if caller ignores the channel
    }()
    return ch
}

// Good — buffered channel or context cancellation
func fetch(ctx context.Context, url string) <-chan Result {
    ch := make(chan Result, 1)
    go func() {
        select {
        case ch <- doFetch(url):
        case <-ctx.Done():
        }
    }()
    return ch
}
```

### Data race on map

```go
// Bad — concurrent map read/write panics at runtime
var m = map[string]int{}

go func() { m["a"]++ }()
go func() { _ = m["a"] }()

// Good — use sync.RWMutex or sync.Map
var sm sync.Map
sm.Store("a", 1)
v, _ := sm.Load("a")
```

---

## Audit Checklist

1. **Goroutines started with no cancellation path** — a goroutine that cannot be stopped leaks for the process lifetime; always accept and respect a `context.Context`
2. **`defer cancel()` missing after `WithTimeout` / `WithCancel`** — without `cancel()`, the context is never released and resources leak
3. **Unbuffered channel with no guarantee of a receiver** — goroutine blocks forever if the receiver is gone; use a buffered channel or a `select` with `ctx.Done()`
4. **`sync.WaitGroup.Add` inside the goroutine** — `Add` must be called before `go` to avoid a race between `Wait` and `Add`
5. **Loop variable captured by goroutine (Go < 1.22)** — all goroutines share the same loop variable; pass it as an argument
6. **Concurrent map access without a mutex** — the Go runtime detects concurrent map reads/writes and panics; use `sync.RWMutex` or `sync.Map`
7. **Mixing channels and mutexes unnecessarily** — channels are for communication, mutexes are for shared state; using both for the same value creates confusion and races
8. **No panic recovery in goroutines** — a panic in a goroutine that is not the main goroutine crashes the entire process; add `defer` with recover for long-running goroutines
