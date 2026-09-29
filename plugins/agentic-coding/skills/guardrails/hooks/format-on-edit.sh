#!/bin/bash
# PostToolUse hook (matcher: Edit|Write|MultiEdit).
# Runs the repo's formatter on the changed file so formatting drift never reaches the diff. Never blocks.
set -u
input=$(cat)
path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty')
[ -f "$path" ] || exit 0
repo="${CLAUDE_PROJECT_DIR:-.}"

case "$path" in
  *.go) command -v gofmt >/dev/null && gofmt -w "$path" ;;
  *.py) command -v ruff >/dev/null && ruff format --quiet "$path" ;;
  *.rs) command -v rustfmt >/dev/null && rustfmt "$path" ;;
  *.swift) command -v swiftformat >/dev/null && swiftformat --quiet "$path" ;;
  *.js|*.jsx|*.ts|*.tsx|*.vue|*.json|*.css|*.scss|*.md|*.yml|*.yaml)
    if [ -x "$repo/node_modules/.bin/prettier" ]; then "$repo/node_modules/.bin/prettier" --log-level silent --write "$path"; fi ;;
  *.java|*.kt) command -v ktlint >/dev/null && [ "${path##*.}" = "kt" ] && ktlint -F "$path" >/dev/null 2>&1 ;;
esac
exit 0
