---
description: Contributor activity over time — commits and added/deleted/net code lines per contributor, bucketed into custom time periods (n-week sprints with a start date, calendar months, quarters, or years). Produces structured TSV/JSON ready for charting plus a compact interpretation. Use for "who committed how much when", velocity trends, sprint retrospectives, and activity charts.
---

# Contributor Activity Over Time

Measure commits and line changes (added / deleted / net) per contributor, bucketed into a user-chosen time period. **All numbers come from git commands. You never count, estimate, or extrapolate numbers yourself — you only bucket-check, format, and interpret the command output.**

**Requirements**: `git` (any recent version), `jq`. Sprint bucketing needs `mktime` (GNU awk) — on macOS/BSD awk either install `gawk` or compute the sprint index with `date -j` / `python3` instead.

## Step 0 — Resolve parameters

Ask nothing if the user already gave these; otherwise use the defaults:

| Parameter | Default | Notes |
|---|---|---|
| `PERIOD` | `month` | One of: `sprint` (requires `SPRINT_WEEKS` and `SPRINT_START`), `month`, `quarter`, `year` |
| `SPRINT_WEEKS` | `2` | Only for `sprint` |
| `SPRINT_START` | first commit date | ISO date `YYYY-MM-DD`, only for `sprint` |
| `SINCE` / `UNTIL` | full history | Passed to `git log --since/--until` |
| `BRANCH` | default branch | `git remote show origin` or current `HEAD` |
| `MERGES` | excluded | Always use `--no-merges`; merge commits inflate stats |

Create a working directory for intermediate files (use the session scratchpad; call it `$OUT` below).

## Step 1 — Collect raw data (git only)

One log pass. `%x09` = tab. The `C<TAB>` prefix marks commit header lines; numstat lines follow each header.

```bash
git -C "$REPO" log "$BRANCH" --no-merges --date=format:'%Y-%m-%d' \
  --pretty=format:'C%x09%h%x09%ad%x09%aN%x09%aE' --numstat > "$OUT/raw.log"
```

Add `--since="$SINCE" --until="$UNTIL"` when set. Binary files appear as `-<TAB>-<TAB>path` in numstat — they must be skipped for line counts but still count as files touched.

## Step 2 — Bucket and aggregate (awk only)

Identity: normalize contributors by **lower-cased email**; keep the most frequent display name per email. Always use `%aN`/`%aE` in the pretty format so an existing `.mailmap` is applied. GitHub noreply addresses (`<id>+<login>@users.noreply.github.com`) almost always duplicate a real address of the same person — check `git shortlog -sne HEAD` for pairs sharing a display name or login, then merge them by rewriting the noreply address in `raw.log` (portable `sed` without the GNU-only `I` flag: match the already-lower-cased form) or via a generated `.mailmap`. List every merge you applied in the output.

Run this awk program (adjust the `bucket()` function per `PERIOD`):

```bash
awk -F'\t' -v period="$PERIOD" -v sprint_weeks="$SPRINT_WEEKS" -v sprint_start="$SPRINT_START" '
function d2e(d,  a) { split(d, a, "-"); return mktime(a[1]" "a[2]" "a[3]" 0 0 0") }
function bucket(d,  e, s, n) {
  if (period == "month")   return substr(d, 1, 7)
  if (period == "year")    return substr(d, 1, 4)
  if (period == "quarter") { return substr(d,1,4) "-Q" int((substr(d,6,2)-1)/3)+1 }
  # sprint: index from sprint_start in n-week steps
  e = d2e(d); s = d2e(sprint_start); n = int((e - s) / (sprint_weeks * 7 * 86400))
  return sprintf("sprint-%03d", n + 1)
}
$1 == "C" { date=$3; author=$4; email=tolower($5); key=bucket(date) SUBSEP email
            commits[key]++; name[email]=author; seen[key]=1; next }
NF == 3   { if ($1 == "-") { bin[key]++ } else { add[key]+=$1; del[key]+=$2 }; files[key]++ }
END {
  for (k in seen) { split(k, p, SUBSEP)
    printf "%s\t%s\t%s\t%d\t%d\t%d\t%d\t%d\n", p[1], name[p[2]], p[2],
      commits[k], add[k], del[k], add[k]-del[k], files[k] }
}' "$OUT/raw.log" | sort -t$'\t' -k1,1 -k4,4nr > "$OUT/activity.body.tsv"
{ printf 'bucket\tauthor\temail\tcommits\tadded\tdeleted\tnet\tfiles_touched\n'
  cat "$OUT/activity.body.tsv"; } > "$OUT/activity.tsv"
```

Use **TSV, not CSV** (author names contain commas), and add the header *after* sorting — a header piped through `sort` lands in the middle of the data.

Then convert to JSON with `jq` (or `python3 -c` if jq is missing):

```bash
jq -R -s '
split("\n") | .[1:] | map(select(length > 0) | split("\t")) |
map({bucket:.[0], author:.[1], email:.[2], commits:(.[3]|tonumber),
     added:(.[4]|tonumber), deleted:(.[5]|tonumber), net:(.[6]|tonumber),
     files_touched:(.[7]|tonumber)}) |
group_by(.bucket) | map({bucket: .[0].bucket, contributors: .})' \
  "$OUT/activity.tsv" > "$OUT/activity.json"
```

## Step 3 — Sanity checks (you, cheap)

- Sum of per-bucket commits must equal `git rev-list --no-merges --count "$BRANCH"` (within the SINCE/UNTIL window). When summing the TSV with awk, mind the header row.
- Spot-check one contributor against `git log --author=<email> --oneline | wc -l`.
- Verify identity merges took effect: `git shortlog -sne HEAD` (pass a rev explicitly — bare `git shortlog` reads stdin in non-interactive shells) should show no obviously duplicated person left in the output.

## Step 4 — Output

Deliver three things:

1. **The files** `activity.tsv` and `activity.json` — tell the user where they are; these are the chart-ready structured output.
2. **A markdown table**: buckets as rows, top contributors as columns, `commits / +added / −deleted` per cell. Cap at top 8 contributors by total commits; fold the rest into "others". **Include empty buckets** (months/sprints with zero commits) in tables and charts — gaps in activity are a finding, and omitting them distorts the time axis.
3. **Interpretation** (this is the only LLM part — keep it to ≤10 bullet-style sentences):
   - Velocity trend per contributor (rising, falling, stopped, bursty).
   - Bucket anomalies (empty sprints, single-bucket spikes — often refactors or vendored code; check the files_touched column before calling it "productivity").
   - Ratio patterns: high deleted-vs-added (cleanup work), high net with few commits (large drops), many commits with tiny nets (churn or fixups).
   - Never rank people as "best/worst". Report patterns, not verdicts; line counts measure activity, not value.

If the user wants charts, generate them from `activity.tsv`/`activity.json` (e.g. an HTML artifact or mermaid `xychart-beta` for small series — one line per contributor over buckets). Load the dataviz guidance skill first if available.
