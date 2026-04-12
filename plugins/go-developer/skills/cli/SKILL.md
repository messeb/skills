---
description: Go CLI development — Cobra commands, Viper config, flags, subcommands, shell completion, and distribution patterns.
---

# Go CLI Development

## Cobra — Command Structure

Cobra is the standard library for Go CLI tools (kubectl, gh, hugo all use it).

```bash
go get github.com/spf13/cobra@latest
```

### Root command

```go
// cmd/myapp/main.go
package main

import (
    "os"
    "github.com/myorg/myapp/internal/cli"
)

func main() {
    if err := cli.Execute(); err != nil {
        os.Exit(1)
    }
}
```

```go
// internal/cli/root.go
package cli

import (
    "fmt"
    "github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
    Use:   "myapp",
    Short: "A brief description of your application",
    Long:  `A longer description shown in help text.`,
}

func Execute() error {
    return rootCmd.Execute()
}

func init() {
    rootCmd.AddCommand(serveCmd)
    rootCmd.AddCommand(versionCmd)
}
```

### Subcommand

```go
// internal/cli/serve.go
package cli

import (
    "fmt"
    "github.com/spf13/cobra"
    "github.com/myorg/myapp/internal/config"
    "github.com/myorg/myapp/internal/server"
)

var serveCmd = &cobra.Command{
    Use:   "serve",
    Short: "Start the HTTP server",
    RunE:  runServe,     // Use RunE to return errors — cobra prints them
}

var serveFlags struct {
    addr    string
    timeout int
}

func init() {
    serveCmd.Flags().StringVarP(&serveFlags.addr, "addr", "a", ":8080", "Listen address")
    serveCmd.Flags().IntVar(&serveFlags.timeout, "timeout", 30, "Request timeout in seconds")
}

func runServe(cmd *cobra.Command, args []string) error {
    cfg, err := config.Load()
    if err != nil {
        return fmt.Errorf("load config: %w", err)
    }

    if serveFlags.addr != ":8080" {    // flag overrides config
        cfg.HTTPAddr = serveFlags.addr
    }

    srv, err := server.New(cfg)
    if err != nil {
        return err
    }

    return srv.Start(cmd.Context())
}
```

---

## Flags — Persistent vs Local

```go
// Persistent flag — available to the command AND all its subcommands
rootCmd.PersistentFlags().StringP("config", "c", "", "Config file path")
rootCmd.PersistentFlags().BoolP("verbose", "v", false, "Enable verbose output")

// Local flag — available only to this specific command
serveCmd.Flags().String("addr", ":8080", "Listen address")
```

### Mark a flag as required

```go
serveCmd.MarkFlagRequired("addr")
```

### Mutually exclusive flags

```go
serveCmd.MarkFlagsMutuallyExclusive("json", "text")
```

---

## Viper — Config File + Environment Variables

Viper binds flags, environment variables, config files, and defaults into a unified config source.

```bash
go get github.com/spf13/viper@latest
```

```go
// internal/config/config.go
package config

import (
    "fmt"
    "strings"
    "github.com/spf13/viper"
)

type Config struct {
    HTTPAddr    string `mapstructure:"http_addr"`
    DatabaseDSN string `mapstructure:"database_dsn"`
    LogLevel    string `mapstructure:"log_level"`
}

func Load() (*Config, error) {
    v := viper.New()

    // Defaults
    v.SetDefault("http_addr", ":8080")
    v.SetDefault("log_level", "info")

    // Config file
    v.SetConfigName("config")           // config.yaml, config.json, etc.
    v.SetConfigType("yaml")
    v.AddConfigPath(".")
    v.AddConfigPath("$HOME/.myapp")

    if err := v.ReadInConfig(); err != nil {
        if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
            return nil, fmt.Errorf("read config: %w", err)
        }
        // Config file not found — continue with defaults + env vars
    }

    // Environment variables
    v.SetEnvPrefix("MYAPP")            // MYAPP_HTTP_ADDR, MYAPP_DATABASE_DSN
    v.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))
    v.AutomaticEnv()

    var cfg Config
    if err := v.Unmarshal(&cfg); err != nil {
        return nil, fmt.Errorf("unmarshal config: %w", err)
    }

    return &cfg, nil
}
```

### Bind Cobra flag to Viper key

```go
func init() {
    serveCmd.Flags().String("addr", "", "Listen address")
    viper.BindPFlag("http_addr", serveCmd.Flags().Lookup("addr"))
}
```

---

## Input and Output

### Read arguments safely

```go
var getCmd = &cobra.Command{
    Use:   "get <id>",
    Short: "Get a resource by ID",
    Args:  cobra.ExactArgs(1),   // enforces exactly one argument
    RunE: func(cmd *cobra.Command, args []string) error {
        id := args[0]
        // ...
        return nil
    },
}
```

Argument validators: `cobra.NoArgs`, `cobra.ExactArgs(n)`, `cobra.MinimumNArgs(n)`, `cobra.RangeArgs(min, max)`.

### Output formats

```go
type Formatter interface {
    Format(w io.Writer, data any) error
}

type JSONFormatter struct{}
type TableFormatter struct{}

func (f *JSONFormatter) Format(w io.Writer, data any) error {
    return json.NewEncoder(w).Encode(data)
}
```

```go
var outputFormat string
rootCmd.PersistentFlags().StringVarP(&outputFormat, "output", "o", "table", "Output format: table, json, yaml")
```

### Always write to `cmd.OutOrStdout()` / `cmd.ErrOrStderr()`

```go
func runGet(cmd *cobra.Command, args []string) error {
    result, err := fetchResource(args[0])
    if err != nil {
        return err
    }
    fmt.Fprintln(cmd.OutOrStdout(), result)  // testable — not hardcoded to os.Stdout
    return nil
}
```

---

## Shell Completion

Cobra generates shell completion scripts automatically:

```go
rootCmd.AddCommand(completionCmd)

var completionCmd = &cobra.Command{
    Use:   "completion [bash|zsh|fish|powershell]",
    Short: "Generate shell completion script",
    Args:  cobra.ExactArgs(1),
    RunE: func(cmd *cobra.Command, args []string) error {
        switch args[0] {
        case "bash":
            return cmd.Root().GenBashCompletion(os.Stdout)
        case "zsh":
            return cmd.Root().GenZshCompletion(os.Stdout)
        case "fish":
            return cmd.Root().GenFishCompletion(os.Stdout, true)
        default:
            return fmt.Errorf("unsupported shell: %s", args[0])
        }
    },
}
```

---

## Graceful Shutdown

```go
func runServe(cmd *cobra.Command, args []string) error {
    ctx, cancel := signal.NotifyContext(cmd.Context(), os.Interrupt, syscall.SIGTERM)
    defer cancel()

    srv := &http.Server{Addr: cfg.HTTPAddr, Handler: handler}

    go func() {
        if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
            slog.Error("server error", "error", err)
            cancel()
        }
    }()

    slog.Info("server started", "addr", cfg.HTTPAddr)
    <-ctx.Done()
    slog.Info("shutting down")

    shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer shutdownCancel()

    return srv.Shutdown(shutdownCtx)
}
```

---

## Distribution

```makefile
# Makefile
VERSION ?= $(shell git describe --tags --always --dirty)
LDFLAGS := -ldflags "-X main.version=$(VERSION) -s -w"

build:
 go build $(LDFLAGS) -o bin/myapp ./cmd/myapp

build-all:
 GOOS=linux   GOARCH=amd64 go build $(LDFLAGS) -o bin/myapp-linux-amd64   ./cmd/myapp
 GOOS=darwin  GOARCH=arm64 go build $(LDFLAGS) -o bin/myapp-darwin-arm64  ./cmd/myapp
 GOOS=windows GOARCH=amd64 go build $(LDFLAGS) -o bin/myapp-windows-amd64.exe ./cmd/myapp
```

```go
// cmd/myapp/main.go
var version = "dev"  // overridden at build time with -ldflags

var versionCmd = &cobra.Command{
    Use:   "version",
    Short: "Print the version",
    Run: func(cmd *cobra.Command, args []string) {
        fmt.Fprintln(cmd.OutOrStdout(), version)
    },
}
```

---

## Audit Checklist

1. **`Run` instead of `RunE`** — errors returned from `Run` are silently ignored; always use `RunE` and return errors
2. **Writing to `os.Stdout` / `os.Stderr` directly** — makes commands untestable; use `cmd.OutOrStdout()` and `cmd.ErrOrStderr()`
3. **Business logic in command functions** — `RunE` should wire and call, not implement; extract logic into `internal/` packages
4. **No argument validation** — unchecked `args[0]` panics on empty input; use `cobra.ExactArgs`, `cobra.MinimumNArgs`, or custom `Args` validators
5. **Flat flag namespace with no grouping** — dozens of top-level persistent flags make `--help` unreadable; group with subcommands and local flags
6. **Hardcoded config values** — addresses, timeouts, or API keys in flag defaults instead of environment variables or config files
7. **No graceful shutdown** — `ListenAndServe` killed by SIGINT without draining connections; use `signal.NotifyContext` and `srv.Shutdown`
8. **No `version` command or `-ldflags` version injection** — users have no way to identify which binary they are running
