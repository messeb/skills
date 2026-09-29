#!/bin/bash
# PreToolUse hook (matcher: Bash).
# Any command that deploys to production needs a named release authorization in RELEASE_APPROVAL.
# The agent may act up to the production gate and cannot pass it.
set -u
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

if printf '%s' "$cmd" | grep -Eiq '(deploy|release|rollout|promote|helm[[:space:]]+upgrade|kubectl[[:space:]]+apply|terraform[[:space:]]+apply)' \
   && printf '%s' "$cmd" | grep -Eiq '(prod|production|live)'; then
  if [ -z "${RELEASE_APPROVAL:-}" ]; then
    echo "Blocked: production deploys need a release authorization. Ask the release manager to run this with RELEASE_APPROVAL=<change-ticket-id> set, or trigger the approved runbook." >&2
    exit 2
  fi
  echo "Production action authorized by RELEASE_APPROVAL=${RELEASE_APPROVAL}" >&2
fi
exit 0
