#!/bin/bash
# PreToolUse hook (matcher: Bash).
# Blocks pushes to the default branch, any force push, and commits made while on the default branch.
# Exit 2 blocks the action and sends the message to the agent.
set -u
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

repo="${CLAUDE_PROJECT_DIR:-.}"
default_branch=$(git -C "$repo" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')
default_branch="${default_branch:-main}"
current_branch=$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null)

if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push.*(--force|-f([[:space:]]|$)|\+[a-zA-Z])'; then
  echo "Blocked: force push is never allowed in the agentic workflow. Append commits instead." >&2
  exit 2
fi

if printf '%s' "$cmd" | grep -Eq "git[[:space:]]+push.*[[:space:]]${default_branch}([[:space:]]|$|:)"; then
  echo "Blocked: direct push to ${default_branch}. Open a pull request; branch protection is the merge path." >&2
  exit 2
fi

if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+(commit|merge|rebase|reset[[:space:]]+--hard)' && [ "$current_branch" = "$default_branch" ]; then
  echo "Blocked: you are on ${default_branch}. Create the ticket branch first (<prefix>/<ticket-id>-<slug>)." >&2
  exit 2
fi

exit 0
