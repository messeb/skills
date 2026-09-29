#!/bin/bash
# PreToolUse hook (matcher: Edit|Write|MultiEdit).
# Blocks edits under protected paths unless the file .claude/allow-protected exists (set by a human for tickets that need it).
# Configure the list in .claude/protected-paths.txt, one glob per line, e.g. src/gen/**, migrations/**, infra/**, *.lock
set -u
input=$(cat)
path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty')
[ -z "$path" ] && exit 0
repo="${CLAUDE_PROJECT_DIR:-.}"
list="$repo/.claude/protected-paths.txt"
[ -f "$list" ] || exit 0
[ -f "$repo/.claude/allow-protected" ] && exit 0

rel="${path#"$repo"/}"
while IFS= read -r pattern; do
  [ -z "$pattern" ] && continue
  case "$pattern" in \#*) continue ;; esac
  # shellcheck disable=SC2254
  case "$rel" in $pattern|${pattern%/\*\*}/*)
    echo "Blocked: $rel is a protected path ($pattern). Needs a ticket that covers it and a human creating .claude/allow-protected." >&2
    exit 2 ;;
  esac
done < "$list"
exit 0
