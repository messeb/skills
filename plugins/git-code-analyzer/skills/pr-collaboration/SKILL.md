---
description: Pull-request and review collaboration analysis via the gh CLI/GitHub API — who opens PRs, who reviews them, rework signals (review rounds, comment load), time-to-merge, reviewer load distribution, and whether the owners of a repo area actually review changes to it. Use for "review culture", PR throughput, reviewer bottlenecks, and knowledge-sharing checks.
---

# PR & Review Collaboration Analysis

Analyze pull-request authorship, review participation, rework patterns, and reviewer coverage. **All data comes from `gh` (GraphQL API); you only aggregate with jq and interpret.** Requires: `gh auth status` OK and a GitHub remote (`gh repo view` works).

## Step 1 — Fetch PRs (one paginated GraphQL query)

REST/`gh pr view` per PR is too slow; fetch everything in one paginated query:

```bash
gh api graphql --paginate -f owner="$OWNER" -f repo="$REPO" -f query='
query($owner:String!, $repo:String!, $endCursor:String) {
  repository(owner:$owner, name:$repo) {
    pullRequests(first:50, after:$endCursor, orderBy:{field:CREATED_AT, direction:DESC},
                 states:[OPEN, CLOSED, MERGED]) {
      pageInfo { hasNextPage endCursor }
      nodes {
        number title state createdAt mergedAt closedAt isDraft
        additions deletions changedFiles
        author { login __typename }
        mergedBy { login }
        files(first:100) { nodes { path } }
        reviews(first:50) { nodes { author { login __typename } state submittedAt } }
        reviewThreads(first:100) { totalCount nodes { comments { totalCount } } }
        comments { totalCount }
      }
    }
  }
}' --jq '.data.repository.pullRequests.nodes[]' > "$OUT/prs.jsonl"
```

Cap history if the user asks (e.g. last 12 months: filter `createdAt` in jq afterwards). If the repo has >100 files per PR or >50 reviews, note the truncation.

## Step 2 — Aggregate with jq (no LLM math)

From `prs.jsonl` compute and write `$OUT/pr_stats.json`:

**Bot handling — get this right first.** GitHub App reviewers (gemini-code-assist, copilot-pull-request-reviewer, coderabbit, …) have `__typename == "Bot"` but logins that do **not** end in `[bot]` — filtering by login suffix silently counts them as humans and wrecks every review metric. Split reviews into `human_reviews` (`__typename == "User"`) and `bot_reviews`, and compute all metrics below from `human_reviews`; report bot review volume separately (bot reviews are volume, not knowledge transfer).

**Funnel** (repo-level — often the headline finding): total PRs, open / closed-unmerged / merged counts, merge rate, silent-close rate (closed unmerged with zero human interaction).

**Per PR**:

- `hours_open` = mergedAt/closedAt − createdAt (still-open PRs: now − createdAt, flagged `open`).
- `review_comment_count` = sum of reviewThreads comment totals; `rework_rounds` = count of human reviews with state `CHANGES_REQUESTED`.
- `reviewers` = unique human review authors ≠ PR author; `zero_human_review` = merged with empty `reviewers`; `self_merged` = mergedBy == author with no other human reviewer.

**Per author**: PRs opened / merged, median & p90 hours_open, mean review comments received, total CHANGES_REQUESTED received, self-merge count.

**Per reviewer** (humans): reviews given, approvals, changes-requested given, distinct authors reviewed.

**Per merger**: merges performed per person (`mergedBy`) — merge concentration is a second bus factor.

**Author × reviewer matrix**: who reviews whom (counts).

Useful jq starters:

```bash
jq -s 'map(select(.author.login != null))' "$OUT/prs.jsonl" > "$OUT/prs.json"
jq '[.[] | {n:.number, author:.author.login,
     hours:(if .mergedAt then ((.mergedAt|fromdate)-(.createdAt|fromdate))/3600 else null end),
     comments:([.reviewThreads.nodes[].comments.totalCount] | add // 0),
     rework:([.reviews.nodes[] | select(.state=="CHANGES_REQUESTED")] | length),
     reviewers:([.reviews.nodes[] | select(.author.__typename == "User") | .author.login] | unique),
     bot_reviews:([.reviews.nodes[] | select(.author.__typename == "Bot")] | length)}]' \
  "$OUT/prs.json" > "$OUT/pr_stats.json"
```

## Step 3 — Ownership cross-check (optional but valuable)

If `ownership.json` from the **code-ownership** skill exists (or the user asks): map each PR's `files[].path` to areas, then check per area: *were the area's top owners among the reviewers?* Compute `owner_review_rate` per area = PRs touching the area that got a review from a top-2 owner / all reviewed PRs touching the area. Map GitHub logins to git emails via `git log --author` spot-checks or the noreply pattern `<id>+<login>@users.noreply.github.com`; list unmatched identities instead of guessing.

## Step 4 — Output

1. **Files**: `prs.jsonl`, `pr_stats.json` — chart-ready.
2. **Markdown tables**: the funnel (open / closed-unmerged / merged, merge rate); per-author PR stats; per-reviewer load (humans and bots on separate rows); the author×reviewer matrix (top 8×8).
3. **Interpretation** (LLM part — patterns, not verdicts, ≤12 sentences):
   - **Rework pattern**: authors whose PRs consistently draw many review comments or repeated CHANGES_REQUESTED → candidates for pairing/earlier design review. Distinguish "big risky PRs" (high additions) from "sloppy PRs" (small but heavily commented) using the size columns before labeling anything.
   - **Latency**: median vs p90 hours-open; call out long-tail PRs and whether they correlate with size or with a specific reviewer bottleneck.
   - **Review load**: is one person doing most reviews (bus factor of reviewing)? Are there author↔reviewer pairs that never cross (knowledge silos)?
   - **Standards & knowledge**: from Step 3 — areas whose owners never review changes to them (ownership erosion risk), and PRs merged with zero human review or self-merged.
   - **Funnel health**: a large open backlog plus a high silent-close rate signals a community that will stop contributing; a high bot-review-to-human-review ratio means review exists on paper but no knowledge is spreading.
   - Solo-maintainer repos: most metrics are trivially skewed (the owner-reviews-area check is trivially true when owner and merger are the same person — say so, it is not a safeguard there); report the funnel and merge concentration instead of over-interpreting review patterns.
