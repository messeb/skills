# messeb Skills

A Claude Code plugin marketplace that provides plugins that add skills and agents usable in both [**Claude Code CLI**](https://code.claude.com/docs/en/overview) and [**GitHub Copilot CLI**](https://github.com/features/copilot/cli).

---

## Installation

### Add the marketplace

Register this marketplace as a source in Claude Code:

```
/plugin marketplace add https://github.com/messeb/skills
```

### Install a plugin

```
/plugin install general-developer@messeb
```

### Remove the marketplace

```
/plugin marketplace remove messeb --force
```

---

## Available Plugins

### `general-developer`

Language-agnostic software engineering principles applicable to any codebase and technology stack.

**Installation**
```
/plugin install general-developer@messeb
```

**Agent**

| Agent | Description |
|-------|-------------|
| `general-developer` | Audits a codebase against all skills, produces a structured report with severity-ranked findings, and offers to apply fixes |

**Skills**

| Skill | Description |
|-------|-------------|
| `github-repo` | Sets up, audits, or syncs all GitHub repository files (README, LICENSE, community files, templates, and more) |
| `dry` | Don't Repeat Yourself — identifies knowledge duplication |
| `die` | Duplication Is Evil — detects structural and logical duplication by failure mode |
| `kiss` | Keep It Simple — flags over-engineering and unnecessary complexity |
| `yagni` | You Aren't Gonna Need It — prevents speculative development |
| `solid` | SOLID principles — single responsibility, open/closed, Liskov, interface segregation, dependency inversion |
| `soc` | Separation of Concerns — evaluates layering and boundary clarity |
| `tda` | Tell Don't Ask — identifies procedural logic that should be encapsulated in objects |
| `gigo` | Garbage In, Garbage Out — reviews input validation and data quality boundaries |
| `bduf` | Big Design Up Front — identifies over-planned, under-iterated architecture |
| `security` | OWASP Top 10, secrets management, authentication, and dependency hygiene |
| `testing` | Testing pyramid balance, coverage gaps, and test anti-patterns |

---

## Usage with Coding CLI

### Run a skill

Invoke any skill by its name as a slash command inside a Claude Code session:

```
/general-developer:github-repo
/general-developer:dry
/general-developer:solid
/general-developer:security
```

Claude will execute the skill's instructions against your current working directory.

### Run the audit agent

The `general-developer` agent checks your codebase against **all skills at once** and produces a prioritised report:

```
/general-developer
```

The agent will:
1. Explore your codebase structure
2. Run every skill as an audit lens
3. Output a summary table with `high / medium / low` findings per skill
4. Offer to apply fixes one by one

---

## Repository Structure

```
skills/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace index
└── plugins/
    └── general-developer/
        ├── .claude-plugin/
        │   └── plugin.json       # Plugin manifest (registers agents)
        ├── agents/
        │   └── general-developer.md
        └── skills/
            ├── github-repo/SKILL.md
            ├── dry/SKILL.md
            └── ...
```

Skills are discovered automatically from the `skills/` directory. Agents must be explicitly registered in `plugin.json`.
