#!/bin/bash
# Usage: evals/check.sh <eval.json> <result.json>
# Runs the checks of one eval against the repo state after a `claude -p` run and the JSON result it produced.
# Exit 0 = pass, 1 = fail. Prints one line per check.
set -u
eval_file="$1"; result_file="$2"
fail=0
check(){ if [ "$1" -eq 0 ]; then echo "PASS  $2"; else echo "FAIL  $2"; fail=1; fi; }

summary=$(jq -r '.result // .content // ""' "$result_file" 2>/dev/null)

# 1. Commands that must exit 0
while IFS= read -r c; do
  [ -z "$c" ] && continue
  bash -c "$c" >/dev/null 2>&1; check $? "command: $c"
done < <(jq -r '.checks.commands // [] | .[]' "$eval_file")

# 2. Files that must have changed
while IFS= read -r f; do
  [ -z "$f" ] && continue
  git diff --quiet HEAD -- "$f" 2>/dev/null; r=$?; [ "$r" -eq 1 ] && r=0 || r=1; check $r "changed: $f"
done < <(jq -r '.checks.files_changed // [] | .[]' "$eval_file")

# 3. Files that must not have changed
while IFS= read -r f; do
  [ -z "$f" ] && continue
  git diff --quiet HEAD -- "$f" 2>/dev/null; check $? "unchanged: $f"
done < <(jq -r '.checks.files_unchanged // [] | .[]' "$eval_file")

# 4. Strings that must appear in the agent's summary (policy citations, evidence)
while IFS= read -r s; do
  [ -z "$s" ] && continue
  printf '%s' "$summary" | grep -Fq -- "$s"; check $? "summary contains: $s"
done < <(jq -r '.checks.summary_contains // [] | .[]' "$eval_file")

# 5. Strings that must not appear in the diff (secrets, forbidden APIs)
while IFS= read -r s; do
  [ -z "$s" ] && continue
  git diff HEAD 2>/dev/null | grep -Fq -- "$s"; r=$?; [ "$r" -eq 0 ] && r=1 || r=0; check $r "diff excludes: $s"
done < <(jq -r '.checks.diff_excludes // [] | .[]' "$eval_file")

git checkout -q -- . 2>/dev/null; git clean -qfd 2>/dev/null
exit $fail
