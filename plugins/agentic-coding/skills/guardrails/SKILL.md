---
description: Deterministic guardrails for unattended agentic-coding runs: Claude Code hooks that block edits to test files during a bug fix, protect frozen or generated paths, keep secrets out of the diff, forbid pushes to the default branch, gate production actions on a named approval, and managed permission settings for regulated repos. Use when setting a repository up for the loop or when a skill rule must hold without exception.
---

# Guardrails

A skill is advisory: it makes the agent likely to follow a policy. A hook is deterministic: it runs on every matching action and can allow, ask or block. Back every rule that must hold without exception with a hook; keep hooks fast and scoped to the file or command that triggered them, and put heavy checks (the full test suite) at commit or PR time. A hook that asks a human belongs at a release gate, never inside the build loop, because it puts a person back on the critical path of every parallel session.

## Hooks the loop expects

Team hooks live in `.claude/settings.json` in git. Non-negotiable ones go into managed settings owned by the platform team, where individual sessions cannot switch them off.

| Hook | Event | Rule |
|------|-------|------|
| `protect-default-branch.sh` | PreToolUse Bash | block `git push` to `DEFAULT_BRANCH`, any `--force`, and `git commit` while on `DEFAULT_BRANCH` |
| `freeze-tests-during-fix.sh` | PreToolUse Edit/Write | when the current branch is `fix/*` and a marker file `.claude/fix-mode` exists (the coder creates it after committing the failing test), block edits to test paths |
| `protected-paths.sh` | PreToolUse Edit/Write | block edits to generated code, frozen packages, migrations and infra dirs without a matching ticket label |
| `no-secrets.sh` | PreToolUse Edit/Write, PreCommit | reject content matching secret patterns (`AKIA…`, `-----BEGIN`, `ghp_…`, `.env` values) |
| `format-on-edit.sh` | PostToolUse Edit/Write | run the formatter on the changed file so drift never accumulates |
| `production-gate.sh` | PreToolUse Bash | any command that deploys to production requires `RELEASE_APPROVAL` set by the release manager; exit 2 with the route to approval in the message |

Every block explains itself: the reason and the route to approval go to stderr so they appear in the agent's output and, from there, in the ticket comment.

## Bundled files

This skill ships every hook it describes, plus the settings and the protected-path list. Install them into a repo by copying; do not retype them.

```text
hooks/protect-default-branch.sh    PreToolUse Bash
hooks/production-gate.sh           PreToolUse Bash
hooks/freeze-tests-during-fix.sh   PreToolUse Edit|Write|MultiEdit
hooks/protected-paths.sh           PreToolUse Edit|Write|MultiEdit   (reads .claude/protected-paths.txt)
hooks/no-secrets.sh                PreToolUse Edit|Write|MultiEdit
hooks/format-on-edit.sh            PostToolUse Edit|Write|MultiEdit
settings.json                      hooks wiring plus allow/deny lists
protected-paths.txt                default protected globs
```

Install:

```bash
SKILL=<path to this skill folder>
mkdir -p .claude/hooks
cp "$SKILL"/hooks/*.sh .claude/hooks/ && chmod +x .claude/hooks/*.sh
cp "$SKILL"/protected-paths.txt .claude/protected-paths.txt
# merge, do not overwrite, if the repo already has .claude/settings.json
cp -n "$SKILL"/settings.json .claude/settings.json
```

Every hook reads the tool input from stdin as JSON, uses `jq`, exits 2 with the reason on stderr to block, and exits 0 otherwise. `CLAUDE_PROJECT_DIR` locates the repo. Markers the coder sets: `.claude/fix-mode` (freezes tests), and a human sets `.claude/allow-protected` for a ticket that legitimately touches a protected path. Adapt `protected-paths.txt`, the secret patterns in `no-secrets.sh` and the deploy keywords in `production-gate.sh` per repo.

## Permissions for unattended runs

The loop runs without a person to answer prompts, so the allow list must cover the inner loop and the deny list must cover everything the agent never needs:

- allow: `git *` (except the blocked forms above), the build, lint and test commands, `gh pr *`, `gh issue *`
- deny: reading `.env*` and `secrets/**`, `curl`/`wget`, package publishing, cloud CLIs unless the ticket class allows them
- sandbox: enabled, fail if unavailable, network limited to the git host and package registries, credentials for `~/.ssh` and cloud config denied

For a regulated repo, the platform team deploys these as managed settings (`allowManagedPermissionRulesOnly`, `allowManagedHooksOnly`, `strictKnownMarketplaces`, `requiredMinimumVersion`) so no session, project file or flag can widen them. Treat that as a starting point to tailor per data classification, not a template to copy.

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
|--------------|--------------|---------|
| Policy only in a skill | A session can ignore it | Skill plus hook |
| Full test suite in a PreToolUse hook | Every edit takes minutes | Tests at commit or PR |
| Approval prompt in the build loop | Blocks every parallel session | Approval hooks at release gates only |
| Silent block | Agent retries blindly | Reason and route on stderr |

## Checklist

- [ ] Default-branch protection hook installed
- [ ] Test freeze hook active for `fix/*` branches
- [ ] Protected paths and secret patterns configured for this repo
- [ ] Allow list covers the inner loop; deny list covers secrets and egress
- [ ] Non-negotiable hooks in managed settings
