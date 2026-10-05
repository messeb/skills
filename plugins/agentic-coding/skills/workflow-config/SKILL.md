---
description: Resolves the configuration every agentic-coding agent runs on. Reads the repo's WORKFLOW.md, then AGENTS.md / CLAUDE.md / CONTRIBUTING.md, then discovers the best-practice skills in the session that fit the codebase, then falls back to documented defaults. Also generates a WORKFLOW.md for a repo that has none. Run first in every coder, reviewer and janitor run, or interactively to set up a repository for the loop.
---

# Workflow configuration

Every agent in the `agentic-coding` plugin is repo-agnostic. The behavior is fixed; the values come from the repository. This skill defines where the values come from, in which order they win, and what to do when they are missing.

## When to use

- At the start of every coder, reviewer and janitor run (resolve mode).
- Interactively, to prepare a repository for the loop (setup mode: "set up the agentic workflow for this repo").

## Precedence (highest first)

1. **`WORKFLOW.md`** in the repo root, or `docs/WORKFLOW.md`. Owns everything workflow-specific: tracker, statuses, bot user, branch and PR rules, quality gates, limits, hand-off, artifacts, stop conditions.
2. **Repo instruction files**: `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `REVIEW.md`, `.github/PULL_REQUEST_TEMPLATE.md`. Own coding conventions, build/test/lint commands, commit and PR conventions, and the review policy. When `WORKFLOW.md` leaves a value empty, take it from here.
3. **Best-practice skills** available in this session that match the repo's stack (see below). Own how code is written and reviewed where the repo itself is silent.
4. **Plugin defaults** listed at the end of this file.

A more specific source always wins. A repo rule beats a skill; a skill beats a default. The agents never override a repo rule because a skill says otherwise; if the two conflict in a way that blocks the ticket, that is a stop condition.

## Resolve mode

1. Locate the repo: the connected folder or the current working directory containing `.git`. Record `REPO_PATH`.
2. Read `WORKFLOW.md`. Parse every `KEY = value` line inside its code blocks into a config map. Read the status names, the dependency rule and the stop conditions as prose rules.
3. Read the repo instruction files. Extract build, lint and test commands, commit message convention, PR template, branch naming, and any "never do X" rule. Fill only the keys still empty.
4. Derive what is still missing and derivable:
   - `PROJECT` for GitHub from `git remote get-url origin`
   - `DEFAULT_BRANCH` from `git symbolic-ref refs/remotes/origin/HEAD`
   - `BUILD_CMD` / `LINT_CMD` / `TEST_CMD` from `package.json` scripts, `Makefile` targets, `go.mod` (`go build ./... && go vet ./...`, `go test ./...`), `pyproject.toml`, `Package.swift` (`swift build`, `swift test`), `*.xcodeproj` (`xcodebuild test`), `pom.xml` / `build.gradle`
5. Discover best-practice skills (next section) and record the list you will follow.
6. Apply plugin defaults for anything still empty.
7. Validate. `TRACKER`, `PROJECT`, `REPO_PATH`, `DEFAULT_BRANCH` and `TEST_CMD` are mandatory; `RUN_CMD` is required for tickets with behavioral acceptance criteria that the verifier must exercise. If any is missing in an unattended run, comment nothing, end the run with a report of the missing keys and the sentence "Run agentic-coding:workflow-config in setup mode". Never invent a status name or a command.
8. Print the resolved configuration as a table at the start of the run so the run log shows what the agent believed.

## Best-practice skill discovery

The agents are expected to write and review code the way the best available guidance says, not from memory. After resolving the repo files:

1. List the skills available in this session (the skill listing the runtime provides; in Claude Code the `/` menu and installed plugins).
2. Detect the stack from the repo: languages by file extensions and manifests, frameworks by dependencies, infrastructure by `Dockerfile`, CI files, IaC.
3. Select skills in this order and record why each was chosen:
   - Stack plugins whose name or description matches the detected stack (for example `go-developer` for Go, `frontend-developer` for Vue/Nuxt/Astro, `python-ai-developer` for Python services). Load the skills that match the files the ticket will touch, not the whole plugin.
   - Cross-cutting engineering skills, when present: testing, security, and the design-principle skills (`solid`, `kiss`, `yagni`, `dry`, `soc`) from a general-developer style plugin.
   - Process skills the repo's own instruction files reference by name.
4. Read each selected skill before coding or reviewing. The coder uses them as construction rules; the reviewer uses them as review lenses and cites the skill in a finding when it applies.
5. If no matching skill exists, say so in the plan comment and proceed with the repo's conventions plus general engineering judgment. Do not fabricate a skill name.

## Setup mode

When invoked interactively on a repo without `WORKFLOW.md`:

1. Run resolve mode steps 1 to 6 and show the user the derived values and the gaps.
2. Ask for the gaps that cannot be derived: tracker and project, bot user, hand-off mechanism, merge strategy.
3. Copy `templates/WORKFLOW.md` to the repo root and fill in every value. Keep placeholders only for values the user explicitly deferred.
4. Offer to install the guardrails (`agentic-coding:guardrails` bundled files), `REVIEW.md` and the eval workflow, and create `SDLC_DIR`.
5. Tell the user which statuses and labels must exist in the tracker and which identities and branch protection are still needed (see "Outside the repo").

## WORKFLOW.md template

The copy-ready file is `templates/WORKFLOW.md` next to this skill; setup mode copies it and fills in the values. Reproduced here for reading:

```markdown
# Agentic workflow conventions

Shared rules for every agent in this workflow. If an agent prompt and this file conflict, this file wins.

## Tracker

TRACKER  = jira | github-issues | notion
PROJECT  = PROJECT_KEY | owner/repo | Notion database id
BOT_USER = tracker user the agents act as

## Status lifecycle

Inbox → Needs Approval → Todo → In Progress → Ready for Review → In Review → Ready for Release
 (planner)   (human gate)                          ▲                 │
                                                   └─ Changes Requested ◄┘

INTAKE_STATUS   = Inbox
APPROVAL_STATUS = Needs Approval
PLANNER_ENABLED = true

## Dependency rule

A ticket is unblocked when every dependency is in Ready for Release or Done.
jira: inward "is blocked by" links; parent/epic not in Todo
github-issues: "Blocked by #N" / "Depends on #N" lines or task-list references
notion: relation property "Blocked by"

## Artifacts

SDLC_DIR        = docs/sdlc          # <ticket-id>/intent.md, spec.md, plan.md, handoff.md; lessons/
SOURCE_OF_TRUTH = linkage            # repo | tracker | linkage
CONTEXT_RESET   = on-long-tickets    # never | on-long-tickets | always
HANDOFF_AFTER_CRITERIA = 6

## Git

REPO_PATH      = absolute path of the local clone
DEFAULT_BRANCH = main
BRANCH_PREFIX  = feat                # bug tickets use fix
MERGE_STRATEGY = squash

Branch: <prefix>/<ticket-id>-<kebab-slug>. Commit: "<ticket-id>: <imperative summary>".
PR title: "<ticket-id>: <ticket title>". PR body contains "Closes <ticket ref>" and ends with "agent-workflow: v1".
Never commit to DEFAULT_BRANCH, never force-push, never rewrite history on a branch with an open PR.

## Quality gates

BUILD_CMD = <fill in>
LINT_CMD  = <fill in>
TEST_CMD  = <fill in>
RUN_CMD   = <fill in>                # starts the app or service for the verifier and reviewer

All must pass before a PR is opened and before it is merged. New behavior needs tests; bug fixes need a
failing test committed before the fix. Review policy lives in REVIEW.md.

## Hand-off

HANDOFF       = poll | cowork-trigger
PLANNER_TASK  = agentic-planner
CODER_TASK    = agentic-coder
REVIEWER_TASK = agentic-reviewer

## Limits

MAX_REWORK_ROUNDS   = 3
MAX_SHOULD_FINDINGS = 2
CI_WAIT_MINUTES     = 15
STALE_CLAIM_HOURS   = 6
STALE_REVIEW_HOURS  = 4
EVAL_PASS_RATE      = 0.9
METRICS_TICKET      = <optional>          # optional ticket that receives the weekly metrics comment

## Stop conditions

Comment the reason on the ticket, add label needs-human, leave the status, end the run:
missing or contradictory acceptance criteria; needs credentials, infra or a product decision;
unrelated test failures; MAX_REWORK_ROUNDS reached; merge conflict needing a decision;
spec.md risk class higher-risk without tech-lead acceptance of plan.md.
Tickets labeled needs-human or no-bot are never picked up.
```

## Plugin defaults

Used only when neither `WORKFLOW.md` nor the repo files provide a value.

| Key | Default |
| ----- | --------- |
| Statuses | Inbox, Needs Approval, Todo, In Progress, Ready for Review, In Review, Changes Requested, Ready for Release |
| `PLANNER_ENABLED` | `true` |
| `SDLC_DIR` | `docs/sdlc` |
| `SOURCE_OF_TRUTH` | `linkage` |
| `CONTEXT_RESET` | `on-long-tickets` |
| `HANDOFF_AFTER_CRITERIA` | 6 |
| `EVAL_PASS_RATE` | 0.9 |
| Labels | `needs-human`, `no-bot` |
| `BRANCH_PREFIX` | `feat` |
| `MERGE_STRATEGY` | `squash` |
| `HANDOFF` | `poll` (the status is the queue; the next scheduled run picks it up) |
| `MAX_REWORK_ROUNDS` | 3 |
| `MAX_SHOULD_FINDINGS` | 2 |
| `CI_WAIT_MINUTES` | 15 |
| `STALE_CLAIM_HOURS` | 6 |
| `STALE_REVIEW_HOURS` | 4 |
| PR marker | `agent-workflow: v1` |

## Outside the repo

The plugin defines behavior. These are configured once per environment and cannot be derived:

- Scheduled tasks for planner, coder, reviewer and janitor, with the repo folder connected and automatic approval, otherwise the first `git push` waits for a click that never comes.
- A tracker user for `BOT_USER` and a GitHub machine user or App token with `contents`, `pull_requests`, `issues`. Preferably a second token for the reviewer, otherwise "1 approving review" branch protection rejects the bot approving its own PR.
- Branch protection on `DEFAULT_BRANCH`: required review and green CI. That is the real safety net, not the prompts.
- The hooks from `agentic-coding:guardrails` (bundled in that skill's `hooks/` folder) in `.claude/settings.json`, and managed settings for regulated repos.
- `REVIEW.md` in the repo root, from `agentic-coding:sdlc-artifacts` `templates/REVIEW.md`.
- The eval workflow from `agentic-coding:agent-evals`.

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
| -------------- | -------------- | --------- |
| Hard-coding statuses or commands in an agent prompt | Breaks on the next repo | Everything through this skill |
| Guessing `TEST_CMD` from the language alone | Runs the wrong tests, green by accident | Derive from manifests, otherwise stop |
| Loading every installed skill | Contradictory guidance, wasted context | Only stack-matching and cross-cutting skills |
| Letting a skill override a repo rule | Repo owner loses control | Repo rule wins, always |

## Checklist

- [ ] `WORKFLOW.md` read, keys parsed, statuses and stop conditions captured
- [ ] Repo instruction files read, commands and conventions extracted
- [ ] Stack detected, matching skills selected and read, selection recorded
- [ ] Mandatory keys present, or the run ended with a clear report
- [ ] Resolved configuration printed at the top of the run
