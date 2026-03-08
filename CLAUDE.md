# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

A collection of Claude Code plugins, each bundling **skills** (user-invocable prompts) and **agents** (orchestrator prompts) via the `.claude-plugin` system.

## Actual Structure

```
skills/
├── .claude-plugin/
│   └── marketplace.json          # Root marketplace metadata
└── plugins/
    └── <plugin-name>/
        ├── .claude-plugin/
        │   └── plugin.json       # Plugin metadata
        ├── skills/
        │   └── <skill-name>/
        │       └── SKILL.md      # Skill definition
        └── agents/
            └── <agent-name>.md   # Agent definition
```

## Plugin System Concepts

### `plugin.json`

Declares the plugin and references its agents:

```json
{
  "name": "plugin-name",
  "description": "...",
  "version": "1.0.0",
  "agents": ["./agents/agent-name.md"]
}
```

Skills are discovered automatically from the `skills/` directory — they do not need to be listed in `plugin.json`. Agents must be explicitly registered in the `agents` array.

### Skills (`skills/<name>/SKILL.md`)

User-invocable prompt definitions. Frontmatter fields:

| Field | Description |
|-------|-------------|
| `description` | Short description shown in the skill picker |
| `disable-model-invocation` | `true` to run without invoking the AI model |

The prompt body (below the `---` frontmatter) contains the full instructions Claude follows when the skill is invoked.

### Agents (`agents/<name>.md`)

Orchestrator prompts that coordinate across multiple skills or perform multi-step analysis. Same frontmatter format as skills. Referenced in `plugin.json` via the `agents` array so Claude Code registers them as agents rather than skills.

## Current Plugin: `general-developer`

Contains one agent and 13 skills:

| Type | Name | Purpose |
|------|------|---------|
| Agent | `general-developer` | Audits a codebase against all skills; produces a structured report and offers fixes |
| Skill | `github-repo` | Sets up / audits / syncs GitHub repository files (3 modes: fresh, update, sync) |
| Skill | `dry` | Don't Repeat Yourself |
| Skill | `kiss` | Keep It Simple |
| Skill | `yagni` | You Aren't Gonna Need It |
| Skill | `solid` | SOLID principles |
| Skill | `soc` | Separation of Concerns |
| Skill | `tda` | Tell Don't Ask |
| Skill | `die` | Duplication Is Evil |
| Skill | `gigo` | Garbage In, Garbage Out |
| Skill | `bduf` | Big Design Up Front |
| Skill | `security` | OWASP Top 10 + security best practices |
| Skill | `testing` | Testing pyramid, patterns, and anti-patterns |

## Adding Content

**New skill**: create `plugins/<plugin>/skills/<name>/SKILL.md` with frontmatter + prompt body. No registration needed.

**New agent**: create `plugins/<plugin>/agents/<name>.md`, then add the path to the `agents` array in `plugin.json`.

**New plugin**: create `plugins/<name>/.claude-plugin/plugin.json` plus `skills/` and/or `agents/` subdirectories.

## No Build or Test Infrastructure

This repository is purely declarative (JSON + Markdown). There are no build commands, package managers, or test runners.
