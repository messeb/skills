---
description: >
  Manages the full GitHub release pipeline for a project following the
  develop → release branch → RC tags → production tag flow with Docker image
  promotion. Use this skill whenever a developer mentions: creating a release
  branch, tagging a release candidate, promoting RC to production, cutting a
  release, managing rc versions, release/x.y.z branches, or asks about the
  release workflow, release pipeline, or how to release a new version.
  Also trigger for phrases like "start a release", "create RC", "bump RC",
  "promote to prod", "tag release", or "what RC are we on".
---

# GitHub Release Pipeline Skill

Guides developers through the full release lifecycle:
`develop` → `release/x.y.z` → `vx.y.z-rc.N` tags → `vx.y.z` production tag.

---

## Workflow Files

| File | Trigger | Purpose |
|---|---|---|
| `ci-pull-request.yml` | PR opened/updated against any branch | Validate — lint, test, build check |
| `release-branch-create.yml` | Push to `release/**` | Confirm branch exists, notify team |
| `release-candidate.yml` | Tag push matching `v*-rc.*` | Build Docker image, deploy to QA |
| `release-production.yml` | Tag push matching `v[0-9]+.[0-9]+.[0-9]+` | Retag RC image, deploy to PROD, publish GitHub Release |

---

## Pipeline Flow

```text
 feature/foo
      │
      │  PR opened
      ▼
 ┌─────────────────────┐
 │  ci-pull-request    │  ← lint, test, build check
 │  .yml               │    runs on every push to PR
 └─────────────────────┘
      │
      │  PR merged → develop
      ▼
   develop  (auto-deploy to DEV, no workflow file needed beyond develop.yml)
      │
      │  Developer: "start release 1.2.0"
      │  git checkout -b release/1.2.0
      │  git push origin release/1.2.0
      ▼
 ┌─────────────────────┐
 │ release-branch-     │  ← triggered by push to release/**
 │ create.yml          │    notifies team, sets up branch protection
 └─────────────────────┘
      │
      │  Developer: "tag RC"
      │  git tag v1.2.0-rc.1
      │  git push origin v1.2.0-rc.1
      ▼
 ┌─────────────────────┐
 │ release-candidate   │  ← triggered by tag v*-rc.*
 │ .yml                │    builds Docker image myapp:1.2.0-rc.1
 └─────────────────────┘    deploys to QA environment (manual gate: 1 reviewer)
      │
      │  QA finds bugs → fix on release/1.2.0 → tag v1.2.0-rc.2
      │  (release-candidate.yml runs again for rc.2)
      │
      │  QA approves ✅
      │
      │  Developer: "promote to production"
      │  PR: release/1.2.0 → main (merged)
      │  git tag v1.2.0
      │  git push origin v1.2.0
      ▼
 ┌─────────────────────┐
 │ release-production  │  ← triggered by tag v[0-9]+.[0-9]+.[0-9]+
 │ .yml                │    retags myapp:1.2.0-rc.2 → myapp:1.2.0 + latest
 └─────────────────────┘    deploys to PROD (manual gate: 2 reviewers)
                             publishes single GitHub Release with consolidated RC notes
```

**Golden rule:** Never rebuild for production. The RC image that passes QA is retagged as the production image.

---

## Step 1 — Determine Intent

Ask the developer which action they want to perform (or infer from context):

| Action | Trigger phrase examples |
|---|---|
| **A. Start a new release** | "create release branch", "start 1.3.0", "cut a release" |
| **B. Tag a new RC** | "tag RC", "bump RC", "create rc.2", "new release candidate" |
| **C. Promote RC → Production** | "release to prod", "promote", "go live", "final release" |
| **D. Inspect current state** | "what RC are we on?", "list RCs", "release status" |

---

## Action A — Start a New Release Branch

### 1. Confirm the version number

Ask the developer: *"What version are you releasing? (e.g. 1.3.0)"*

### 2. Check develop is up to date

```bash
git checkout develop
git pull origin develop
git log --oneline -5   # confirm state with developer
```

### 3. Create the release branch

```bash
VERSION=<version>   # e.g. 1.3.0
git checkout -b release/$VERSION
git push -u origin release/$VERSION
```

### 4. Confirm GitHub Actions will pick it up

Remind the developer that pushing `release/*` triggers the QA deployment workflow.
Read `references/workflows.md` for the expected CI behaviour.

---

## Action B — Tag a New Release Candidate

### 1. Identify the release branch

```bash
git branch -r | grep release/   # list remote release branches
```

Ask the developer to confirm which branch if multiple exist.

### 2. Find the current RC number

```bash
VERSION=<version>
git tag --list "v${VERSION}-rc.*" | sort -V | tail -1
# e.g. → v1.3.0-rc.1  (so next is rc.2)
# if empty → next is rc.1
```

### 3. Compute next RC number

```bash
LAST=$(git tag --list "v${VERSION}-rc.*" | sort -V | tail -1)
if [ -z "$LAST" ]; then
  NEXT_RC=1
else
  NEXT_RC=$(echo $LAST | grep -o 'rc\.[0-9]*' | cut -d. -f2)
  NEXT_RC=$((NEXT_RC + 1))
fi
echo "Next RC → v${VERSION}-rc.${NEXT_RC}"
```

### 4. Confirm with developer before tagging

Show the developer:

- Branch: `release/<version>`
- Tag to create: `v<version>-rc.<N>`
- Docker image that will be built: `registry.io/myapp:<version>-rc.<N>`

### 5. Create and push the tag

```bash
git checkout release/$VERSION
git pull origin release/$VERSION
git tag v${VERSION}-rc.${NEXT_RC}
git push origin v${VERSION}-rc.${NEXT_RC}
```

### 6. Monitor the RC workflow

```bash
gh run list --branch release/$VERSION --limit 5
gh run watch   # follow live
```

---

## Action C — Promote RC to Production

### 1. Confirm QA sign-off

Ask: *"Has QA approved the latest RC? Which RC is being promoted?"*

### 2. Verify the RC tag exists

```bash
VERSION=<version>
git tag --list "v${VERSION}-rc.*" | sort -V
```

### 3. Merge release branch into main

```bash
gh pr create \
  --base main \
  --head release/$VERSION \
  --title "release: $VERSION" \
  --label release \
  --body "Promoting $(git tag --list "v${VERSION}-rc.*" | sort -V | tail -1) to production."

# After approval:
gh pr merge --merge
```

### 4. Tag the production release

```bash
git checkout main && git pull
git tag v$VERSION
git push origin v$VERSION
```

This triggers the production workflow which **retags** the last RC image — no rebuild.

### 5. Verify the GitHub Release

```bash
gh release view v$VERSION
```

The release notes will consolidate all RC entries under collapsible sections.

### 6. Back-merge into develop

```bash
gh pr create \
  --base develop \
  --head release/$VERSION \
  --title "chore: back-merge release/$VERSION into develop"
```

---

## Action D — Inspect Current Release State

```bash
# Show all release branches
git branch -r | grep release/

# Show all RC tags for a given version
VERSION=<version>
git tag --list "v${VERSION}-rc.*" | sort -V

# Show latest GitHub releases (production only)
gh release list --limit 10 | grep -v rc

# Show PR validation runs
gh run list --workflow=ci-pull-request.yml --limit 5

# Show release branch creation runs
gh run list --workflow=release-branch-create.yml --limit 5

# Show RC workflow run status
gh run list --workflow=release-candidate.yml --limit 5

# Show production run status
gh run list --workflow=release-production.yml --limit 5
```

---

## Hotfix Flow (bypassing normal cycle)

When a critical fix is needed directly on production:

```bash
# Branch off main
VERSION=<hotfix-version>   # e.g. 1.2.1
git checkout main && git pull
git checkout -b hotfix/$VERSION
# ... apply fix ...
git push -u origin hotfix/$VERSION

# Fast-track PR to main
gh pr create --base main --title "hotfix: $VERSION" --label hotfix
gh pr merge --merge

# Tag immediately — triggers production workflow
git checkout main && git pull
git tag v$VERSION
git push origin v$VERSION

# Back-merge into develop
gh pr create --base develop --head hotfix/$VERSION \
  --title "chore: back-merge hotfix/$VERSION"
```

---

## Branch & Tag Reference

| Branch / Tag | Purpose | Docker image built? |
|---|---|---|
| `develop` | Continuous integration | ✅ `myapp:develop`, `myapp:develop-<sha>` |
| `release/x.y.z` | Stabilisation, QA fixes only | ❌ (RC tags trigger builds) |
| `vx.y.z-rc.N` | Release candidate | ✅ `myapp:x.y.z-rc.N` |
| `vx.y.z` | Production | ♻️ Retag of last RC only |

---

## Safety Checks Before Any Tag Push

Always run these before pushing a tag:

```bash
# 1. Confirm you are on the correct branch
git branch --show-current

# 2. Confirm the branch is up to date with remote
git fetch origin
git status

# 3. Confirm CI is green on the branch
gh run list --branch $(git branch --show-current) --limit 3

# 4. No uncommitted changes
git diff --stat
```

---

## Reference Files

- `references/workflows.md` — Full GitHub Actions workflow details and environment gates
- `references/docker.md` — Docker tagging conventions and registry commands
- `references/cleanup.md` — How to clean up old RC tags and GitHub pre-releases
