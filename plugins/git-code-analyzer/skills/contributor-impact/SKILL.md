---
description: Individual contributor impact — how much of each contributor's code survives vs gets rewritten, churn (add/modify/delete cycles), an overwrite matrix showing who rewrites whose code, and flags for contributors whose work needs attention. Use for "code survival", rewrite patterns, churn analysis, and mentoring signals.
---

# Contributor Impact & Overwrite Analysis

Measure the *lasting* impact of each contributor: lines added vs lines still alive, churn, and who overwrites whose code. **git produces every number; you interpret.** This skill builds on data the other skills may already have produced — reuse `$OUT/raw.log` (contributor-activity) and `$OUT/blame_lines.tsv` (code-ownership) if present instead of recomputing.

**Requirements**: `git`, `jq`. Apply identity merges (GitHub-noreply duplicates etc.) to the matrix **before** aggregating. When post-processing two-key TSVs in awk, keep the key as a literal tab-joined string (`m[$1 "\t" $2]`) and print `k` directly — mixing `SUBSEP`/`FS` keys with a different `split()` separator silently produces malformed rows.

## Step 1 — Survival rate per contributor

Two inputs:

- **Lines ever added** per author: from `git log --no-merges --pretty=format:'C%x09%aE' --numstat` (sum column 1 per author, skip binary `-` rows).
- **Lines currently alive** per author: aggregate `git blame -w -M -C --line-porcelain` over tracked text files (identical to code-ownership Step 3).

`survival_rate = alive / added` (cap display at 1.0; >1 means moves/copies credited by `-M -C` — note it, don't hide it). Low survival is *not* automatically bad: prototypes, refactored early scaffolding, and deleted features all lower it. The interpretation must check *what* died (Step 2 tells you who deleted it).

## Step 2 — Overwrite matrix (who deletes whose lines)

For each recent non-merge commit (default: last 300, or `--since` window), attribute every deleted line to its previous author by blaming the **parent** commit at the deleted ranges:

```bash
git -C "$REPO" rev-list --no-merges -n "$LIMIT" HEAD | while read -r sha; do
  deleter=$(git -C "$REPO" show -s --format='%aE' "$sha" | tr 'A-Z' 'a-z')
  git -C "$REPO" diff --unified=0 --diff-filter=MD "$sha^" "$sha" 2>/dev/null |
  awk -v sha="$sha" -v deleter="$deleter" '
    /^--- a\//   { file=substr($2,3); next }
    /^@@ /       { split($2, h, ","); start=substr(h[1],2)
                   len=(h[2]=="" ? 1 : h[2])
                   if (len > 0 && file != "") print file "\t" start "\t" len }
  ' | while IFS=$'\t' read -r file start len; do
    end=$((start + len - 1))
    git -C "$REPO" blame -w --line-porcelain -L "$start,$end" "$sha^" -- "$file" 2>/dev/null |
      awk '/^author-mail /{m=tolower($2); gsub(/[<>]/,"",m); print m}'
  done | sort | uniq -c |
  awk -v d="$deleter" '{print d "\t" $2 "\t" $1}'
done | awk -F'\t' '{m[$1 FS $2]+=$3} END{for (k in m) print k "\t" m[k]}' \
  > "$OUT/overwrite_matrix.tsv"    # deleter <TAB> original_author <TAB> lines
```

This is the expensive step (one blame per changed file per commit). Scale `LIMIT` to repo size; on huge repos restrict with `-- <paths>` to the areas of interest and **state the window used**. The diagonal (deleter == original author) is **self-churn**; off-diagonal cells are cross-rewrites.

## Step 3 — Derived metrics (shell/jq)

Write `$OUT/impact.json`, per contributor:

- `added`, `deleted_by_others`, `deleted_own`, `alive`, `survival_rate`
- `churn_ratio` = own lines deleted within the window / own lines added within the window
- `overwrites_others` = off-diagonal row sum (they rewrite others), `overwritten_by` = off-diagonal column sum (others rewrite them), with per-pair top counterpart
- Mechanical attention flags (report only, never headline as a verdict):
  - `high-rework`: >50% of their added lines in the window were deleted again *by someone else*
  - `high-self-churn`: churn_ratio > 0.6 (fix-up loops, force-of-habit rewrites)
  - `dominant-rewriter`: one person causes >60% of all cross-rewrites (style enforcement? unclear standards? review gap?)

## Step 4 — Output

1. **Files**: `impact.json`, `overwrite_matrix.tsv` — chart-ready (matrix → heatmap).
2. **Markdown**: per-contributor table (added / alive / survival % / self-churn / overwritten-by-others) and the top overwrite pairs as `A → B: N lines`.
3. **Interpretation** (LLM part — this is where the value is, ≤12 sentences):
   - Explain each flagged contributor **with the counterpart data**: "X's code in area Y is repeatedly rewritten by Z" is actionable; "X has low survival" alone is not. Cross-reference code-ownership areas when available.
   - Distinguish benign patterns before flagging people: repo-wide refactors, formatters, file renames without `-M` credit, deleted features, and prototype phases all mimic "rework". Check whether the overwrites cluster in one commit/timeframe.
   - A dominant rewriter + a high-rework junior is a **mentoring/review-process signal**, not a performance ranking. Frame findings as process questions (pairing, review standards, earlier feedback), never as individual blame.
   - State window, limits, and identity merges so the numbers are reproducible.
