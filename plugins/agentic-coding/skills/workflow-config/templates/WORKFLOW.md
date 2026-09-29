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
