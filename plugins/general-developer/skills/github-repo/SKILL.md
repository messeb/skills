---
description: Sets up, audits, or syncs a GitHub repository — creates all community and project files for a fresh repo, fills gaps in an existing one, or updates files when source code changes.
---

You manage GitHub repository files across three modes. Detect the mode first, then execute accordingly.

## Step 1 — Detect mode and gather info

**Detect the mode** from context or ask the user:

| Mode | Trigger |
|------|---------|
| **A — Fresh setup** | Empty or brand-new repository with no files yet |
| **B — Update existing repo** | Repo exists; community/config files may be missing or outdated |
| **C — Sync with source changes** | Source code changed; keep repo files consistent with the new state |

**Gather project info** (for Mode A; infer from existing files for B and C):

- Project name and one-sentence description
- Primary language / tech stack
- License (default: MIT)
- Author name / GitHub handle

**File placement**: GitHub recognises community files (`README`, `CONTRIBUTING`, `CODE_OF_CONDUCT`, `SECURITY`, `SUPPORT`, `CODEOWNERS`) in three locations — root, `.github/`, or `docs/`. Default to root unless the project already uses one of the other locations consistently.

---

## Step 2 — Execute by mode

### Mode A — Fresh setup

Create every file from the **File Templates** section below. Follow each template exactly, filling in project-specific values gathered in Step 1.

Order of creation:

1. `.gitignore`, `.gitattributes`
2. `README.md`, `LICENSE` (+ `NOTICE` if Apache 2.0)
3. `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`
4. `GOVERNANCE.md` (if multi-maintainer), `CHANGELOG.md`, `CONTRIBUTORS.md`
5. All `.github/` files: `CODEOWNERS`, `FUNDING.yml`, `dependabot.yml`, `copilot-instructions.md`, `CITATION.cff`, issue templates, PR template, `release.yml`, discussion templates

Then proceed to **Step 3 — Verify and summarize**.

---

### Mode B — Update existing repo

**Audit** the repository against the full file list in Step 3. For each file:

| State | Action |
|-------|--------|
| **Missing** | Create from template |
| **Present, outdated** | Show a diff of what would change, ask before overwriting |
| **Present, customized** | Skip — do not overwrite custom content without explicit user approval |
| **Present, current** | Skip |

**Staleness checks to perform:**

- `CODE_OF_CONDUCT.md` — is it using Contributor Covenant v2.1 or newer?
- `.gitignore` — does it cover the current tech stack? Are OS/editor artifacts included?
- `.gitattributes` — is `* text=auto eol=lf` present? Are export-ignore entries set?
- `SECURITY.md` — does it reference GitHub Private Vulnerability Reporting?
- `CHANGELOG.md` — does it follow Keep a Changelog format?
- `.github/release.yml` — do the labels match what's actually used in the repo?
- `.github/copilot-instructions.md` — does the tech stack section reflect the current stack?
- `.github/ISSUE_TEMPLATE/*.md` — are templates using the legacy `.md` format? Offer to upgrade to `.yml`.
- `.github/dependabot.yml` — does the `package-ecosystem` list cover all ecosystems in the repo?

After auditing, present a summary of what will be created or updated, confirm with the user, then apply changes. Proceed to **Step 3 — Verify and summarize**.

---

### Mode C — Sync with source changes

Inspect what changed in the source code, then update only the affected repo files. Do not touch files unrelated to the change.

**Change → affected files mapping:**

| Source change | Files to update |
|---------------|----------------|
| New language or framework added | `.gitignore` (add patterns), `.gitattributes` (add file types + export-ignore), `.github/copilot-instructions.md` (update Tech Stack), `.github/dependabot.yml` (add ecosystem) |
| New significant dependency added | `.github/copilot-instructions.md` (update Key dependencies), `.github/dependabot.yml` (verify ecosystem covered) |
| New binary file types introduced | `.gitattributes` (add binary markers) |
| User-visible feature added or changed | `CHANGELOG.md` (add `Added` or `Changed` entry under `[Unreleased]`) |
| Bug fixed | `CHANGELOG.md` (add `Fixed` entry under `[Unreleased]`) |
| Breaking change introduced | `CHANGELOG.md` (add `Breaking Changes` entry), verify `SECURITY.md` SLAs still accurate if security-related |
| New contributor merged a PR | `CONTRIBUTORS.md` (add entry under Contributors) |
| Supported versions changed | `SECURITY.md` (update Supported Versions table) |
| Project renamed or re-described | `README.md`, `CITATION.cff`, `SUPPORT.md`, `copilot-instructions.md` |
| License changed | `LICENSE`, `NOTICE` (if switching to/from Apache 2.0), `README.md` badge/footer |
| GitHub Pages enabled | Add `.nojekyll` to root or publish directory |

For each affected file, show the proposed change and confirm before writing. Proceed to **Step 3 — Verify and summarize**.

---

## Step 3 — Verify and summarize

Output a checklist of all files, marking each as ✅ created, 🔄 updated, or ⏭ skipped:

### Root-level files

- [ ] `.gitignore`
- [ ] `.gitattributes`
- [ ] `.nojekyll` (GitHub Pages only)
- [ ] `README.md`
- [ ] `LICENSE`
- [ ] `NOTICE` (Apache 2.0 only)
- [ ] `CODE_OF_CONDUCT.md`
- [ ] `CONTRIBUTING.md`
- [ ] `SECURITY.md`
- [ ] `SUPPORT.md`
- [ ] `GOVERNANCE.md` (multi-maintainer projects)
- [ ] `CHANGELOG.md`
- [ ] `CONTRIBUTORS.md`
- [ ] `CITATION.cff` (academic/citable projects)

**`.github/`**

- [ ] `.github/CODEOWNERS`
- [ ] `.github/FUNDING.yml`
- [ ] `.github/dependabot.yml`
- [ ] `.github/copilot-instructions.md`
- [ ] `.github/release.yml`
- [ ] `.github/PULL_REQUEST_TEMPLATE.md`
- [ ] `.github/ISSUE_TEMPLATE/config.yml`
- [ ] `.github/ISSUE_TEMPLATE/bug_report.yml`
- [ ] `.github/ISSUE_TEMPLATE/feature_request.yml`
- [ ] `.github/DISCUSSION_TEMPLATE/announcements.yml`
- [ ] `.github/DISCUSSION_TEMPLATE/ideas.yml`
- [ ] `.github/DISCUSSION_TEMPLATE/q-and-a.yml`

**Suggest next steps based on mode:**

- **Mode A**: Configure branch protection on `main` (require PR reviews, status checks, signed commits), enable Dependabot alerts + security updates + secret scanning, add CI workflows, enable GitHub Discussions, add topics/tags, set social preview image
- **Mode B**: Highlight any files skipped due to customization that may need manual review
- **Mode C**: Remind user to promote `[Unreleased]` entries to a versioned section before the next release

**Complete repository structure:**

```text
<project>/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.yml
│   │   ├── feature_request.yml
│   │   └── config.yml
│   ├── DISCUSSION_TEMPLATE/
│   │   ├── announcements.yml
│   │   ├── ideas.yml
│   │   └── q-and-a.yml
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── CODEOWNERS
│   ├── FUNDING.yml
│   ├── dependabot.yml
│   ├── copilot-instructions.md
│   └── release.yml
├── docs/
├── src/
├── tests/
├── .gitignore
├── .gitattributes
├── CHANGELOG.md
├── CITATION.cff
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── CONTRIBUTORS.md
├── GOVERNANCE.md
├── LICENSE
├── NOTICE
├── README.md
├── SECURITY.md
└── SUPPORT.md
```

---

## File Templates

Reference templates for all files. Used by all three modes.

---

### `README.md`

````markdown
# <Project Name>

<One-paragraph description of what the project does and why it exists.>

[![CI](https://github.com/<owner>/<repo>/workflows/CI/badge.svg)](https://github.com/<owner>/<repo>/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Features

- Key feature 1
- Key feature 2

## Getting Started

### Prerequisites
...

### Installation

```bash
# installation command
```

### Usage

```bash
# usage example
```

## Documentation

Full documentation is available at [docs link].

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the <LICENSE NAME> — see [LICENSE](LICENSE) for details.

## Support

For help, see [SUPPORT.md](SUPPORT.md) or open an issue.

````

Best practices:

- Lead with value: what problem does this solve?
- Badge row immediately after the title — CI status, license, version
- Keep code examples minimal but runnable
- Link to all community files (CONTRIBUTING, CODE_OF_CONDUCT, LICENSE, SUPPORT)

---

### `LICENSE` and `NOTICE` (if Apache 2.0)

Common options — ask the user:

- **MIT**: Permissive, simple, widely used
- **Apache 2.0**: Permissive with patent grant; requires `NOTICE` file
- **GPL-3.0**: Copyleft; derivatives must be open source
- **BSD-3-Clause**: Permissive with attribution requirement

MIT template:

```text
MIT License

Copyright (c) <YEAR> <AUTHOR>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```

**If Apache 2.0**, also create `NOTICE` (legally required in all distributions):

```text
<Project Name>
Copyright <YEAR> <AUTHOR>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

Add additional attributions for third-party Apache 2.0 code:

```text
This product includes software developed by <Third Party> (<URL>).
```

---

### `CODE_OF_CONDUCT.md`

Use Contributor Covenant v2.1. Keep it concise — link to the full text rather than reproducing it:

```markdown
# Code of Conduct

## Our Pledge

We pledge to make participation in our community a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity, level of experience, nationality, race, religion, or sexual identity.

## Our Standards

Positive behavior includes: welcoming language, respecting differing viewpoints, gracefully accepting criticism, focusing on what is best for the community.

Unacceptable behavior includes: harassment, trolling, personal attacks, publishing others' private information without permission.

## Enforcement

Violations may be reported to <contact email or GitHub Security Advisory link>. All complaints will be reviewed and investigated promptly.

## Attribution

This Code of Conduct is adapted from the [Contributor Covenant](https://www.contributor-covenant.org), version 2.1.
```

---

### `CONTRIBUTING.md`

```markdown
# Contributing to <Project Name>

Thank you for your interest in contributing!

## Development Setup

1. Fork and clone the repository
2. Install dependencies: `<install command>`
3. Run tests: `<test command>`
4. Create a feature branch: `git checkout -b feat/my-feature`

## How to Contribute

### Reporting Bugs
- Search existing issues before opening a new one
- Include reproduction steps, expected vs actual behavior, and environment details

### Suggesting Features
- Open a GitHub Discussion or issue with the `enhancement` label
- Explain the use case, not just the feature

### Submitting Pull Requests
1. Ensure all tests pass and linting is clean
2. Update `CHANGELOG.md` under `[Unreleased]`
3. Open a PR against `main` with a descriptive title
4. Address review feedback

## Code Review Standards

- All PRs require at least one approving review
- CI checks must pass before merge
- Breaking changes require discussion in an issue first

## Commit Message Convention

Use [Conventional Commits](https://www.conventionalcommits.org):
- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation only
- `chore:` maintenance

## Code Style

<Describe linting tools, formatting rules, or link to a style guide>
```

---

### `SECURITY.md`

GitHub surfaces this in the Security tab and guides users to report vulnerabilities privately.

```markdown
# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| x.x.x   | ✅        |
| < x.x.x | ❌        |

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Report via [GitHub Private Vulnerability Reporting](https://github.com/<owner>/<repo>/security/advisories/new) or email <security@example.com>.

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

We aim to respond within 48 hours and release a patch within 14 days for confirmed critical issues.

## Security Best Practices

- Keep dependencies updated (Dependabot is enabled on this repo)
- Use environment variables for secrets — never commit credentials
- Enable 2FA for repository access
```

---

### `SUPPORT.md`

GitHub shows a banner linking to this when users open a new issue.

```markdown
# Support

## Documentation

- [README](README.md)
- [Docs](./docs/) or [docs.example.com](https://docs.example.com)

## Getting Help

1. Check the documentation
2. Search [existing issues](https://github.com/<owner>/<repo>/issues)
3. Ask in [GitHub Discussions](https://github.com/<owner>/<repo>/discussions)
4. For confirmed bugs: open a new issue using the bug report template

## Community

<Links to Discord, Slack, Stack Overflow tag, forum, mailing list — as applicable>

## Commercial Support

<Optional: paid support or consulting contact>
```

---

### `GOVERNANCE.md`

Skip for solo projects. Use for multi-maintainer or community projects.

```markdown
# Governance

## Project Roles

### Maintainers
Maintainers have write access and are responsible for reviewing PRs, triaging issues, and cutting releases.
Current maintainers: @<handle>

### Contributors
Anyone who has had a PR merged. Listed in [CONTRIBUTORS.md](CONTRIBUTORS.md).

## Decision Making
- Day-to-day decisions are made by maintainers via PR review
- Significant changes (breaking API, new dependencies, governance changes) require consensus among all active maintainers
- If consensus cannot be reached, the lead maintainer (@<handle>) has final say

## Becoming a Maintainer
Criteria: multiple merged PRs, demonstrated understanding of project goals, active participation in issues and reviews.

## Releases
Releases follow [semver](https://semver.org). A CHANGELOG entry is required for every release.
```

---

### `CHANGELOG.md`

Follow [Keep a Changelog](https://keepachangelog.com) format. Pairs with `.github/release.yml` for automated GitHub release notes.

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.0.0] - <YYYY-MM-DD>
### Added
- Initial release
```

Categories: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`. Move `[Unreleased]` to a versioned section when cutting a release.

---

### `CONTRIBUTORS.md`

```markdown
# Contributors

Thank you to everyone who has contributed to <Project Name>!

## Maintainers
- [<Name>](https://github.com/<handle>) — creator and lead maintainer

## Contributors
<!-- Added here as PRs are merged -->
<!-- Format: - [Name](https://github.com/handle) — description of contribution -->
```

Consider automating with the `all-contributors` GitHub Action for larger projects.

---

### `CITATION.cff`

Ask the user if the project is academic/citable; skip if not relevant.

```yaml
cff-version: 1.2.0
message: "If you use this software, please cite it as below."
type: software
title: "<Project Name>"
version: "<version>"
date-released: "<YYYY-MM-DD>"
authors:
  - family-names: "<Last>"
    given-names: "<First>"
    orcid: "https://orcid.org/0000-0000-0000-0000"  # optional
repository-code: "https://github.com/<owner>/<repo>"
license: <SPDX-identifier>
abstract: "<One-sentence description>"
```

Also add a `## Citation` section to `README.md`:

```markdown
## Citation

\`\`\`bibtex
@software{<key>,
  author = {<Last>, <First>},
  title  = {<Project Name>},
  year   = {<YEAR>},
  url    = {https://github.com/<owner>/<repo>}
}
\`\`\`
```

---

### `.gitignore`

Generate based on the detected tech stack using [gitignore.io](https://www.toptal.com/developers/gitignore) patterns. Always include:

```gitignore
# Dependencies
node_modules/
vendor/

# Build output
dist/
build/
*.o
*.so

# Environment
.env
.env.local
*.local

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Testing
coverage/
.pytest_cache/

# Temporary
tmp/
temp/
```

Adapt sections to the actual stack (e.g. `__pycache__/` for Python, `target/` for Rust/Java). Keep `.vscode/extensions.json` if present.

---

### `.gitattributes`

```gitattributes
# Auto-detect text files and normalize line endings
* text=auto eol=lf

# Force LF for shell scripts
*.sh text eol=lf

# Force CRLF for Windows batch files
*.bat text eol=crlf
*.cmd text eol=crlf

# Binary files — prevent diff/merge corruption
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.ico binary
*.svg binary
*.woff binary
*.woff2 binary
*.ttf binary
*.otf binary
*.eot binary
*.zip binary
*.gz binary
*.pdf binary

# Linguist — tell GitHub which language to highlight and what to exclude
# docs/** linguist-documentation
# vendor/** linguist-vendored
# *.generated.ts linguist-generated

# Export ignore — exclude from `git archive` downloads
.github/ export-ignore
tests/ export-ignore
.gitignore export-ignore
```

---

### `.nojekyll`

Create an empty `.nojekyll` file in the root (or the GitHub Pages publish directory) to disable Jekyll processing. Required when using GitHub Pages with frameworks that produce files or directories starting with `_`.

---

### `.github/CODEOWNERS`

```text
# Global owner — reviews all PRs by default
* @<github-handle>

# Path-specific owners (adapt to project structure)
/docs/                  @<docs-team-or-handle>
/src/api/               @<backend-team-or-handle>
*.md                    @<docs-team-or-handle>
/.github/workflows/     @<devops-team-or-handle>
```

Best practices: at minimum set `*` so every PR has a required reviewer. More specific rules take precedence. Use `@org/team-name` for teams.

---

### `.github/FUNDING.yml`

```yaml
github: [<username>]           # GitHub Sponsors
patreon: <username>
open_collective: <slug>
ko_fi: <username>
liberapay: <username>
custom: ['https://...']        # any custom URL
```

Include only platforms the user actually uses. Omit the file if funding is not wanted.

---

### `.github/dependabot.yml`

```yaml
version: 2
updates:
  - package-ecosystem: "npm"        # adjust to project: pip, cargo, maven, gradle, etc.
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    reviewers:
      - "<github-handle>"
    labels:
      - "dependencies"
      - "automated"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "monthly"
    labels:
      - "dependencies"
      - "automated"
```

Add one `updates` entry per package ecosystem present in the repo. Always include `github-actions`.

---

### `.github/copilot-instructions.md`

```markdown
# Copilot Instructions

## Project Overview
<What this project does and its primary purpose.>

## Tech Stack
- Language: <e.g. TypeScript, Python>
- Framework: <e.g. Next.js, FastAPI>
- Key dependencies: <list>

## Code Conventions
- <Naming conventions, file structure rules>
- <Preferred patterns, e.g. functional over class-based>
- <What to avoid>

## Testing
- Framework: <e.g. Jest, pytest>
- Run tests with: `<command>`

## Important Context
- <Domain-specific terms or constraints>
- <Anything non-obvious from the code alone>
```

Keep under ~500 words. Focus on non-obvious project-specific context.

---

### `.github/release.yml`

```yaml
changelog:
  exclude:
    labels:
      - ignore-for-release
      - chore
  categories:
    - title: "🚨 Breaking Changes"
      labels:
        - breaking-change
    - title: "✨ New Features"
      labels:
        - enhancement
        - feature
    - title: "🐛 Bug Fixes"
      labels:
        - bug
        - fix
    - title: "📖 Documentation"
      labels:
        - documentation
    - title: "🔧 Maintenance"
      labels:
        - dependencies
        - refactor
    - title: "Other Changes"
      labels:
        - "*"
```

Every label here must exist as a real GitHub label. PRs without a matching label fall into the `"*"` catch-all. Pairs with `CHANGELOG.md` — use one for humans, the other for GitHub release pages.

---

### `.github/ISSUE_TEMPLATE/config.yml`

```yaml
blank_issues_enabled: false
contact_links:
  - name: Question or Discussion
    url: https://github.com/<owner>/<repo>/discussions
    about: Use Discussions for questions and ideas
  - name: Security Vulnerability
    url: https://github.com/<owner>/<repo>/security/advisories/new
    about: Report security issues privately
```

---

### `.github/ISSUE_TEMPLATE/bug_report.yml`

```yaml
name: Bug Report
description: File a bug report
title: "[Bug]: "
labels: ["bug", "triage"]
body:
  - type: markdown
    attributes:
      value: Thanks for taking the time to report this bug!

  - type: textarea
    id: description
    attributes:
      label: Description
      description: A clear description of the bug
    validations:
      required: true

  - type: textarea
    id: reproduction
    attributes:
      label: Steps to Reproduce
      placeholder: |
        1. Go to '...'
        2. Click on '...'
        3. See error
    validations:
      required: true

  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
    validations:
      required: true

  - type: textarea
    id: environment
    attributes:
      label: Environment
      value: |
        - OS:
        - Version:
```

---

### `.github/ISSUE_TEMPLATE/feature_request.yml`

```yaml
name: Feature Request
description: Suggest a new feature or improvement
title: "[Feature]: "
labels: ["enhancement"]
body:
  - type: textarea
    id: problem
    attributes:
      label: Problem Statement
      description: What problem does this solve?
    validations:
      required: true

  - type: textarea
    id: solution
    attributes:
      label: Proposed Solution
    validations:
      required: true

  - type: textarea
    id: alternatives
    attributes:
      label: Alternatives Considered
```

---

### `.github/PULL_REQUEST_TEMPLATE.md`

```markdown
## Description

<!-- What does this PR do? -->

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing

- [ ] Unit tests added / updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] `CHANGELOG.md` updated
- [ ] No new warnings generated
- [ ] Conventional commit messages used
```

For repos with distinct contribution types, consider multiple templates in `.github/PULL_REQUEST_TEMPLATE/` (e.g. `feature.md`, `bugfix.md`, `release.md`) linked via `?template=` URL params.

---

### `.github/DISCUSSION_TEMPLATE/announcements.yml`

```yaml
title: "[Announcement] "
labels: []
body:
  - type: markdown
    attributes:
      value: Use this template for releases, breaking changes, or community news.
  - type: textarea
    id: announcement
    attributes:
      label: Announcement
    validations:
      required: true
```

---

### `.github/DISCUSSION_TEMPLATE/ideas.yml`

```yaml
title: "[Idea] "
labels: []
body:
  - type: textarea
    id: problem
    attributes:
      label: What problem does this solve?
    validations:
      required: true
  - type: textarea
    id: solution
    attributes:
      label: Proposed solution or idea
    validations:
      required: true
  - type: textarea
    id: alternatives
    attributes:
      label: Alternatives considered
```

---

### `.github/DISCUSSION_TEMPLATE/q-and-a.yml`

```yaml
title: "[Q&A] "
labels: []
body:
  - type: textarea
    id: question
    attributes:
      label: Your question
    validations:
      required: true
  - type: textarea
    id: context
    attributes:
      label: What have you tried or found so far?
```
