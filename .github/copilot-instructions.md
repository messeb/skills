# Copilot Instructions

## Project Overview

A Claude Code plugin marketplace providing skills (user-invocable prompts) and agents (orchestrator prompts) that encode software engineering principles. Users install plugins via the `.claude-plugin` system to get slash commands in Claude Code and GitHub Copilot CLI.

## Tech Stack

- Language: Markdown, JSON (purely declarative — no executable code)
- No build tools, package managers, or test runners

## Repository Structure

```
.claude-plugin/marketplace.json     # Marketplace index
plugins/<plugin>/
  .claude-plugin/plugin.json        # Plugin manifest (registers agents)
  skills/<name>/SKILL.md            # Skill definition (auto-discovered)
  agents/<name>.md                  # Agent definition (must be in plugin.json)
```

## Authoring Conventions

- Skills use YAML frontmatter (`description`, optional `disable-model-invocation`)
- The prompt body below `---` is what Claude executes when the skill is invoked
- Agents coordinate across multiple skills; they must be registered in `plugin.json`
- Skills are discovered automatically — no registration needed
- Keep skill prompts self-contained and actionable

## Important Context

- `CLAUDE.md` is the authoritative authoring guide — always check it first
- This is a plugin marketplace, not a software project — there is no source code to compile or test
- Each skill encodes a specific software engineering principle (DRY, KISS, SOLID, etc.)
