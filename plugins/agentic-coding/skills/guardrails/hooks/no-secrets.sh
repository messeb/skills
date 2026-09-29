#!/bin/bash
# PreToolUse hook (matcher: Edit|Write|MultiEdit).
# Rejects content that looks like a credential. Extend the patterns for your organization.
set -u
input=$(cat)
content=$(printf '%s' "$input" | jq -r '.tool_input.content // .tool_input.new_string // empty')
[ -z "$content" ] && exit 0

patterns='AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}|xox[baprs]-[A-Za-z0-9-]{10,}|sk-[A-Za-z0-9]{20,}|AIza[0-9A-Za-z_-]{35}|(password|passwd|secret|token)[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{8,}'
if printf '%s' "$content" | grep -Eiq "$patterns"; then
  echo "Blocked: the edit contains something that looks like a credential. Use environment variables or the secret store; never commit secrets." >&2
  exit 2
fi
exit 0
