---
description: Code ownership and bus factor per repository area — identifies logical areas of the repo, measures each contributor's historical contribution and current surviving code (git blame) per area, and computes a bus factor with risk flags. Use for "who owns what", knowledge concentration, bus factor, and onboarding/review planning.
---

# Code Ownership & Bus Factor per Repo Area

Determine, for each logical area of the repository, (a) who historically contributed how much, (b) whose code is *currently* there (blame), and (c) how concentrated that knowledge is (bus factor). **All numbers come from git; you only define areas, run the commands, and interpret.**

**Requirements**: `git`, `jq`. Apply the same identity normalization as contributor-activity (lower-cased email, `.mailmap`, GitHub-noreply merges) to **both** the log pass and the blame output *before* aggregating — a person split across two emails fakes a bus factor of 2.

## Step 1 — Identify logical areas (LLM, structure only)

```bash
git -C "$REPO" ls-files | awk -F/ 'NF>1{print $1"/"$2} NF==1{print "(root)"}' | sort | uniq -c | sort -rn
```

From the directory listing (plus README/module names if ambiguous), define 5–12 **logical areas**: a name plus one or more path prefixes. Rules:

- Group by responsibility, not just top-level dirs (`src/agents`, `src/dataflows`, `tests`, `docs`, `ci`, …).
- Exclude vendored/generated/lock content (`vendor/`, `node_modules/`, `dist/`, `*.lock`, `package-lock.json`, generated protobufs) — they poison both blame and numstat.
- Put leftovers in an `other` area so totals reconcile.
- Record the mapping as `$OUT/areas.json`: `[{"area":"agents","paths":["tradingagents/agents/"]}, …]`.

## Step 2 — Historical contribution per area (git log)

One pass over history; map every file path to its area in awk:

```bash
git -C "$REPO" log --no-merges --pretty=format:'C%x09%aN%x09%aE' --numstat > "$OUT/raw.log"

awk -F'\t' -v areasfile="$OUT/areas.tsv" '
BEGIN { while ((getline line < areasfile) > 0) { split(line, a, "\t"); prefix[++n]=a[2]; aname[n]=a[1] } }
function area(path,  i) { for (i=1; i<=n; i++) if (index(path, prefix[i]) == 1) return aname[i]; return "other" }
$1 == "C" { email=tolower($3); name[email]=$2; next }
NF == 3 && $1 != "-" { k=area($3) SUBSEP email; add[k]+=$1; del[k]+=$2; commits[k]++ }
END { print "area\temail\tauthor\tadded\tdeleted\tcommits"
      for (k in add) { split(k, p, SUBSEP)
        printf "%s\t%s\t%s\t%d\t%d\t%d\n", p[1], p[2], name[p[2]], add[k], del[k], commits[k] } }
' "$OUT/raw.log" | sort > "$OUT/history_by_area.tsv"
```

(`areas.tsv`: one `area<TAB>path-prefix` line per prefix, derived from `areas.json`.)

## Step 3 — Current ownership per area (git blame)

Blame every tracked text file; count surviving lines per author. `-w` ignores whitespace, `-M -C` follow moves/copies so reformat-committers don't steal ownership:

```bash
git -C "$REPO" ls-files | grep -Ev '\.(png|jpg|jpeg|gif|svg|ico|pdf|lock|bin|woff2?)$' |
while IFS= read -r f; do
  git -C "$REPO" blame -w -M -C --line-porcelain HEAD -- "$f" 2>/dev/null |
    awk -v f="$f" '/^author-mail /{mail=tolower($2); gsub(/[<>]/,"",mail)}
                   /^author /{sub(/^author /,""); name=$0}
                   /^\t/{print f "\t" mail "\t" name}'
done > "$OUT/blame_lines.tsv"
```

Aggregate to areas with the same `area()` mapping → `$OUT/ownership_by_area.tsv` (`area, email, author, lines`). On big repos (>3k files) restrict blame to the defined area paths and warn that `other` was skipped, or sample; **say so in the output** — never present sampled data as complete.

An area whose files are all excluded (e.g. an image-only `assets/`) silently disappears from the blame aggregation — reconcile the result against `areas.json` and report such areas as "no text content" instead of dropping them.

## Step 4 — Bus factor (computed in the shell/jq, not by feel)

Per area, from `ownership_by_area.tsv`:

- `total_lines`, per-author `lines` and `pct`.
- **Bus factor** = smallest number of authors whose combined surviving lines ≥ 50% of the area (sort authors desc, accumulate).
- Risk flags: `critical` if bus factor = 1 **and** top author ≥ 75%; `warning` if bus factor ≤ 2 or top author ≥ 60%; else `ok`. Downgrade nothing by intuition — flags are mechanical.

Produce `$OUT/ownership.json`:

```json
[{"area":"agents","paths":["tradingagents/agents/"],"total_lines":4210,
  "owners":[{"author":"…","email":"…","lines":3100,"pct":73.6}],
  "history":[{"author":"…","added":5000,"deleted":900,"commits":42}],
  "bus_factor":1,"risk":"critical"}]
```

## Step 5 — Output

1. **Files**: `areas.json`, `ownership.json` (+ the TSVs) — chart-ready.
2. **Markdown table**: area | total lines | top owner (pct) | 2nd owner (pct) | bus factor | risk.
3. **Interpretation** (LLM part, short):
   - Which areas are one-person silos; what happens if that person leaves (name the concrete area, not generic advice).
   - Divergence between history and blame: someone contributed a lot historically but owns little now → their code was rewritten (cross-reference the contributor-impact skill) or they did early scaffolding.
   - Suggested mitigations only where risk ≠ ok: pair the top owner with the closest second contributor **from the data**, route reviews of that area to them (cross-reference the pr-collaboration skill).
   - Note excluded/generated paths and any identity merges you applied.
