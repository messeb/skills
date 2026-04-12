# Contributing to messeb Skills

Thank you for your interest in contributing!

## How to Contribute

### Reporting Bugs

- Search existing issues before opening a new one
- Include a clear description of the problem and steps to reproduce

### Suggesting New Skills or Plugins

- Open a GitHub Discussion or issue with the `enhancement` label
- Describe the software engineering principle or workflow the skill addresses

### Submitting Pull Requests

1. Fork and clone the repository
2. Create a feature branch: `git checkout -b feat/my-skill`
3. Add or update skills following the structure in `CLAUDE.md`
4. Update `CHANGELOG.md` under `[Unreleased]`
5. Open a PR against `main` with a descriptive title
6. Address review feedback

## Repository Structure

This is a purely declarative repository — no build tools, no package managers. Content lives in Markdown and JSON files only.

```text
plugins/<plugin-name>/
├── .claude-plugin/plugin.json   # Plugin manifest
├── skills/<name>/SKILL.md       # Skill definition
└── agents/<name>.md             # Agent definition
```

See `CLAUDE.md` for full authoring guidelines.

## Commit Message Convention

Use [Conventional Commits](https://www.conventionalcommits.org):

- `feat:` new skill or plugin
- `fix:` correction to existing skill content
- `docs:` documentation only
- `chore:` maintenance (metadata, formatting)

## Code Review Standards

- All PRs require at least one approving review
- Breaking changes to skill interfaces require discussion in an issue first
