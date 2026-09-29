#!/bin/bash
# PreToolUse hook (matcher: Edit|Write|MultiEdit).
# While .claude/fix-mode exists, edits to test files are blocked so a fix cannot bend the test that proves it.
set -u
input=$(cat)
path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty')
[ -z "$path" ] && exit 0
repo="${CLAUDE_PROJECT_DIR:-.}"
[ -f "$repo/.claude/fix-mode" ] || exit 0

case "$path" in
  *test*|*Test*|*spec*|*Spec*|*__tests__*|*/tests/*|*/Tests/*|*_test.go|*.test.*|*.spec.*)
    echo "Blocked: fix mode is active, test files are frozen. Fix the code, not the test. Remove .claude/fix-mode after the gates are green." >&2
    exit 2 ;;
esac
exit 0
