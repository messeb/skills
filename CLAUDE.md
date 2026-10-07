# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

A Claude Code plugin marketplace (`messeb`). Each plugin bundles **skills** (user-invocable prompts) and **agents** (orchestrator prompts) via the `.claude-plugin` system. Users register the marketplace with `/plugin marketplace add https://github.com/messeb/skills` and install plugins with `/plugin install <plugin>@messeb`.

## Structure

```text
skills/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace index: one entry per plugin (name, description, source, version)
├── plugins/
│   └── <plugin-name>/
│       ├── .claude-plugin/
│       │   └── plugin.json       # Plugin manifest; registers agents
│       ├── agents/
│       │   └── <agent-name>.md   # Agent definition
│       └── skills/
│           └── <skill-name>/
│               ├── SKILL.md      # Skill definition
│               └── ...           # Optional supporting files (templates, scripts, patterns)
├── .markdownlint.json            # Lint rules for every Markdown file
└── package.json                  # markdownlint-cli2 + husky pre-commit hook
```

## Plugin System Concepts

### `plugin.json`

```json
{
  "name": "plugin-name",
  "description": "...",
  "version": "1.0.0",
  "agents": ["./agents/agent-name.md"]
}
```

Skills are discovered automatically from `skills/`; they are not listed in `plugin.json`. Agents must be registered in the `agents` array. Every plugin is also listed in the root `marketplace.json` with the same name, description and version.

### Skills (`skills/<name>/SKILL.md`)

Frontmatter fields:

| Field | Description |
| ------- | ------------- |
| `description` | When to use the skill and what it covers; this is what triggers it, so it names the tasks and keywords |
| `disable-model-invocation` | `true` to run without invoking the AI model |

The body is the full instruction set. House style, followed by every plugin: when to use it and when not to, the method as numbered steps or tables, an anti-pattern table (anti-pattern, why it fails, instead), and a checklist.

A skill may ship supporting files next to `SKILL.md` (for example `frontend-developer/skills/nuxt-ddd/patterns/*.md`, `agentic-coding/skills/sdlc-artifacts/templates/*.md`). The skill references them by relative path; anything a skill tells the user to copy or run must exist in the repo, not only as an inline snippet.

### Agents (`agents/<name>.md`)

Orchestrator prompts with the same frontmatter format. Agents are thin: they resolve context, then name the skill for each step and follow it, rather than repeating the skill's content. Agent names must be unique across the whole marketplace; prefix them when the role name is generic (`agentic-coder`, not `coder`).

### Naming

Plugin, skill and agent names are kebab-case. Cross-references between skills use `<plugin>:<skill>` (for example `agentic-coding:ticket-tracker`); a referenced skill must exist in that plugin.

## Plugins

| Plugin | Agents | Skills | Purpose |
| -------- | -------- | -------- | --------- |
| `general-developer` | `general-developer` | 16 | Language-agnostic engineering principles (DRY, KISS, YAGNI, SOLID, security, testing, GitHub repo setup, Husky, Dangerfile) |
| `frontend-developer` | `frontend-developer` | 18 | Frontend development: Vue, Nuxt (incl. DDD patterns), Astro, Vite, performance, a11y, testing |
| `go-developer` | `go-developer` | 9 | Go CLI and backend service development |
| `python-ai-developer` | `python-ai-developer` | 18 | Python AI applications: uv, FastAPI, LLM clients, OCR, ML, OR, containers, notebooks |
| `seo` | `seo` | 12 | SEO, GEO and Lighthouse-driven page quality |
| `product-discovery` | `product-discovery` | 39 | Product discovery, requirements elicitation, collaborative domain modeling |
| `growth-hacking` | `growth-hacking` | 24 | Growth strategy, experiment process, AARRR funnel, legal and ethical limits |
| `content-author` | `content-author` | 6 | Readable text in English and German: readability indices, plain language, revision |
| `git-code-analyzer` | `git-code-analyzer` | 4 | Repository analysis from git and gh data: activity, ownership, PR collaboration, impact |
| `notion-summarizer` | `notion-summarizer` | 5 | Long sources into structured Notion summaries with flashcards |
| `agentic-coding` | `agentic-planner`, `agentic-coder`, `agentic-reviewer`, `agentic-janitor` | 14 | Unattended AI-native ticket-to-merge loop on Jira, GitHub Issues or Notion; repo-agnostic via `WORKFLOW.md`, `CLAUDE.md`, `AGENTS.md`, `REVIEW.md`; ships artifact templates |

The `general-developer` skills (`testing`, `security`, `solid`, ...) and the stack plugins are also consumed by `agentic-coding` at runtime: its agents detect the repo's stack and load the matching skills as construction rules and review lenses.

## Adding Content

**New skill**: create `plugins/<plugin>/skills/<name>/SKILL.md` in the house style; no registration needed. Add supporting files beside it when the skill describes files to copy or run. Add it to the plugin's table in `README.md` and to `CHANGELOG.md` under today's date.

**New agent**: create `plugins/<plugin>/agents/<name>.md`, add the path to `agents` in `plugin.json`, document it in `README.md`.

**New plugin**: create `plugins/<name>/.claude-plugin/plugin.json` plus `skills/` and/or `agents/`, add an entry to `.claude-plugin/marketplace.json`, a section to `README.md` (installation, agents table, skills table by category), and a `CHANGELOG.md` entry. Bump `version` in both `plugin.json` and `marketplace.json` on later changes.

## Verification

The repository is declarative (JSON, Markdown, a few shell scripts and templates); there is no build. Before committing:

```bash
pnpm install          # once; registers the Husky pre-commit hook
pnpm lint:md          # markdownlint-cli2 with .markdownlint.json; also runs on pre-commit
pnpm lint:fix:md      # auto-fix
```

Additional checks worth running after structural changes:

- every path in a `plugin.json` `agents` array exists
- every `<plugin>:<skill>` reference resolves to a skill folder
- every file a skill names (`hooks/*.sh`, `templates/*`, `evals/*`) exists beside it, shell scripts pass `bash -n` and are executable
- `marketplace.json` and every `plugin.json` parse as JSON

## Commit Convention

Conventional Commits: `feat:` new skill or plugin, `fix:` correction to skill content, `docs:` documentation, `chore:` metadata and formatting.
