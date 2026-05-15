---
description: Git release flow — branch strategy, ticket/branch naming, environment promotion (TEST → QA → UAT → PROD), versioning, tagging, and artifact handling for web, CLI, library, and app projects.
---

# Release Flow

Defines a generalized Git-based release process: how work flows from feature branches, through staged environments, to a tagged production release — for any project that ships an artifact (Docker image, web bundle, library, CLI binary, desktop installer, mobile build).

This skill describes the **flow**. The companion [`cicd`](../cicd/SKILL.md) skill drives the **actions** (creating release branches, tagging RCs, promoting to prod) for an established flow.

---

## When to Use

- Setting up the release process for a new project
- Auditing an existing repository's branching, naming, and promotion conventions
- Adapting an opinionated flow (e.g. one built around Docker + Kubernetes) to a different artifact type (web bundle, npm package, CLI binary, mobile build)
- Aligning a team on what "release" means across environments

---

## Branch Strategy

| Branch              | Purpose                                                       | Long-lived? |
|---------------------|---------------------------------------------------------------|-------------|
| `develop`           | Mainline integration — every feature lands here first         | Yes         |
| `feature/PROJ-NNN-*`| Feature, bugfix, or doc branches; PR target is `develop`      | No          |
| `release/X.Y.Z`     | Release candidate — stabilization, QA fixes only              | Short       |
| `hotfix/PROJ-NNN-*` | Emergency patch off the last production tag                   | No          |
| `main`              | Optional — production-tracking pointer; tags live here        | Yes (opt.)  |
| `config`            | Optional — GitOps manifests written by deploy jobs only       | Yes (opt.)  |

**Rules:**

- Only one open `release/X.Y.Z` at a time. Concurrent release branches make back-merging fragile — serialize them.
- `develop` always points at the next snapshot version (`X.Y.Z-SNAPSHOT` / `X.Y.Z-dev`).
- `release/*` is closed once the version ships and is back-merged to `develop`.
- Humans never push to `config`. The deploy job is the only writer.

---

## Naming Conventions

### Branch names

```text
feature/PROJ-1234-add-oauth-login
bugfix/PROJ-1234-fix-cart-totals
hotfix/PROJ-1234-1.2.1
release/1.2.0
```

- `PROJ` is the project abbreviation (Jira/Linear/GitHub project key).
- `NNN` is the ticket number.
- Slug is short, kebab-case, ≤ 4 words.
- `release/X.Y.Z` and `hotfix/.../X.Y.Z` carry the target version — no ticket needed for the release branch itself.

### Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/) and append the ticket ref:

```text
feat(auth): add OAuth2 login flow (PROJ-1234)
fix(cart): prevent negative quantities (PROJ-1235)
chore(deps): bump axios to 1.7.0 (PROJ-1240)
```

The ticket suffix unlocks automatic linking in Jira/Linear and grouping in auto-generated release notes.

### PR titles

```text
[PROJ-1234] feat(auth): add OAuth2 login flow
```

Title prefix → label routing (`feat:` → `enhancement`, `fix:` → `bug`, etc.) → groups under the right heading in `.github/release.yml` auto-notes.

---

## Pipeline Overview

```text
 feature/PROJ-1234-...
        │  PR opened → lint, test, SAST/SCA  (no deploy)
        │  PR merged
        ▼
     develop
        │  auto build + deploy → TEST
        │  artifact tag: {MAJ}.{MIN}.{run}-{sha}
        │
        │  manual: "Prepare Release" (input: version X.Y.Z)
        │    ├── cut release/X.Y.Z from develop
        │    ├── bump version in manifest
        │    ├── build artifact X.Y.Z + deploy → QA
        │    └── open snapshot bump PR back to develop
        ▼
   release/X.Y.Z
        │  fix branches → PR into release/X.Y.Z
        │  every push rebuilds + redeploys QA
        │  auto back-merge PR to develop on every fix
        │
        │  manual: "Deploy to Staging and Production" (input: version X.Y.Z)
        │    ├── promote artifact NonProd → Production registry
        │    ├── deploy → Staging  (no approval)
        │    ├── deploy → Production (GitHub Environment approval ✋)
        │    ├── tag vX.Y.Z + GitHub Release (marked latest)
        │    └── update config branch manifests
        ▼
       PROD
```

---

## Development → TEST

| Action                                                                                    | Type      |
|-------------------------------------------------------------------------------------------|-----------|
| Create feature branch from `develop` (`feature/PROJ-NNN-slug`)                            | Manual    |
| Open PR to `develop`                                                                      | Manual    |
| PR triggers lint + test + build check + SAST + SCA (no deploy, no artifact publish)       | Automatic |
| Review + merge PR into `develop` (squash merge — keeps history flat)                      | Manual    |
| Push to `develop` triggers build + deploy to **TEST**                                     | Automatic |
| Artifact tagged `{appName}:{MAJ}.{MIN}.{run_number}-{sha}` and pushed to NonProd registry | Automatic |
| Deploy to TEST via Terraform / Helm / Pulumi / framework-specific deploy                  | Automatic |
| Update env manifests on `config` branch (if GitOps)                                       | Automatic |

**TEST is the integration environment.** It runs trunk content; expect frequent breakage. Add smoke tests here, not regression tests.

---

## Release Preparation → QA

The "Prepare Release" workflow is a manually dispatched job that owns version bumping, branch cutting, and the first QA deploy. It removes the temptation to do these by hand.

| Action                                                                                           | Type      |
|--------------------------------------------------------------------------------------------------|-----------|
| Dispatch **"Prepare Release"** workflow → input `version` (e.g. `1.2.0`)                         | Manual    |
| Cut branch `release/1.2.0` from `develop`                                                        | Automatic |
| Bump version in manifest (`pom.xml`, `package.json`, `pyproject.toml`, `Cargo.toml`, `*.csproj`) | Automatic |
| Commit + push version bump to `release/1.2.0`                                                    | Automatic |
| Build artifact tagged `1.2.0`                                                                    | Automatic |
| SAST + SCA scan                                                                                  | Automatic |
| Push artifact to NonProd registry                                                                | Automatic |
| Deploy → **QA** via Terraform / Helm / etc.                                                      | Automatic |
| Update QA manifests on `config` branch                                                           | Automatic |
| Open PR to bump `develop` to next snapshot (e.g. `1.3.0-SNAPSHOT`)                               | Automatic |
| Review + merge the snapshot bump PR into `develop`                                               | Manual    |

### Bugfix during release

When QA finds a bug on a release candidate:

| Action                                                       | Type      |
|--------------------------------------------------------------|-----------|
| Create `bugfix/PROJ-NNN-...` branch off `release/1.2.0`      | Manual    |
| Open PR back into `release/1.2.0`                            | Manual    |
| Review + merge PR into `release/1.2.0`                       | Manual    |
| Push to `release/**` rebuilds artifact `1.2.0`, redeploys QA | Automatic |
| Auto-open PR to back-merge `release/1.2.0` → `develop`       | Automatic |
| Review + merge back-merge PR                                 | Manual    |

Repeat until QA signs off.

---

## Release → Staging → Production

A separate dispatched workflow handles promotion. It never rebuilds — it **promotes** the QA-tested artifact.

| Action                                                                  | Type                                  |
|-------------------------------------------------------------------------|---------------------------------------|
| Dispatch **"Deploy to Staging and Production"** → input `version=1.2.0` | Manual                                |
| Promote artifact NonProd registry → Prod registry                       | Automatic                             |
| Deploy → **Staging** via Terraform / Helm / etc. (no approval)          | Automatic                             |
| Update Staging manifests on `config` branch                             | Automatic                             |
| Business validation on Staging                                          | Manual                                |
| **Production** deploy gated by GitHub Environment review                | **Manual approval** (1–2 reviewers)   |
| Deploy → Production                                                     | Automatic (after approval)            |
| Update Production manifests on `config` branch                          | Automatic                             |
| Create annotated tag `v1.2.0` on `release/1.2.0`, push                  | Automatic                             |
| Create GitHub Release with auto-generated notes, mark as `latest`       | Automatic                             |

**Golden rule:** never rebuild for production. The artifact that QA approved is the artifact that goes to PROD — by digest, not by tag-name.

---

## Artifact Recipes

The same flow ships any artifact. What changes is the *promote* step.

### Docker images

- Build once on `release/X.Y.Z`. Push to NonProd registry.
- Promote by **retagging the digest** in the Prod registry — never `docker build` again.
- Tag scheme: `app:X.Y.Z` (immutable), `app:latest` (only on prod release, never on RC), `app:X.Y` and `app:X` (optional moving tags).

```bash
# Promote by digest, not by tag — guarantees identical bytes
DIGEST=$(crane digest nonprod.azurecr.io/app:1.2.0)
crane copy nonprod.azurecr.io/app@$DIGEST prod.azurecr.io/app:1.2.0
crane tag  prod.azurecr.io/app:1.2.0 latest
```

### Web static bundles

- Build once. Output directory contains hashed asset filenames (`app.4f3a.js`).
- Deploy = copy build directory to env-specific origin (S3 prefix, Cloudflare R2, CloudFront, Cloudflare Pages).
- Promote = copy bytes from staging origin → prod origin. Never rebuild between environments — environment config is loaded at runtime (`/config.json` fetched on boot, or env-injected at edge).

### Library packages (npm / PyPI / Maven / NuGet / Cargo)

- RC publish: `1.2.0-rc.1` under the `next` / `rc` dist-tag.
- Prod publish: `1.2.0` under `latest`.
- Never republish the same version — yank/deprecate and bump patch instead.
- For npm: `npm publish --tag rc` then `npm dist-tag add app@1.2.0 latest` on promotion.
- For PyPI: pre-releases are first-class (`1.2.0rc1`); install with `pip install --pre`.

### CLI binaries

- Matrix build on `release/X.Y.Z`: `{linux,darwin,windows} × {amd64,arm64}` (+ optional `linux/arm`).
- Upload to GitHub Release assets: `app_1.2.0_linux_amd64.tar.gz`, etc.
- Ship `checksums.txt` (SHA-256) + a detached signature (`cosign sign-blob` or minisign).
- Pre-release flag on RC Releases (`gh release create v1.2.0-rc.1 --prerelease`); flip to non-prerelease + `--latest` on promotion.
- For Homebrew/Scoop/winget: tap updates on the prod tag, not the RC tag.

### Desktop apps

- Code-signed installers per OS: `.dmg` (notarized) for macOS, `.msi` / `.exe` (Authenticode) for Windows, `.AppImage` / `.deb` / `.rpm` for Linux.
- Auto-update channels map to environments: `alpha` → develop, `beta` → release/RC, `stable` → prod.
- Update feed (Sparkle / Squirrel / electron-updater) reads from the channel's manifest URL.

### Mobile apps

- iOS: TestFlight Internal (≈ QA) → TestFlight External (≈ UAT) → App Store (≈ PROD).
- Android: Play Internal Testing → Closed/Open Testing → Production track.
- Promotion is "advance the same build", not rebuild — both stores let you re-use the binary across tracks.
- Version codes (`versionCode` / `CFBundleVersion`) must be strictly increasing across all uploaded builds.

### IaC / Helm charts

- Chart version equals app version. Publish chart to OCI registry alongside the image.
- Promote by retagging the OCI artifact, same as Docker.

---

## Versioning

| Scheme               | When                                                                       |
|----------------------|----------------------------------------------------------------------------|
| SemVer `1.2.3`       | Default — libraries, services, public APIs                                 |
| SemVer + pre-release | RCs and pre-releases: `1.2.0-rc.1`, `1.2.0-beta.1`                         |
| Build metadata       | Snapshot artifacts: `1.2.0+sha.a1b2c3d`, `1.2.0+build.42`                  |
| CalVer `2026.05.0`   | Apps with no public API contract (e.g. desktop, IDE)                       |
| Snapshot/dev         | `1.2.0-SNAPSHOT` (Maven), `1.2.0-dev` (npm), `0.0.0-pr.1234` (PR previews) |

**SemVer rules:**

- **MAJOR** — incompatible API change
- **MINOR** — backwards-compatible feature
- **PATCH** — backwards-compatible fix
- Pre-release ordering: `1.2.0-alpha.1` < `1.2.0-beta.1` < `1.2.0-rc.1` < `1.2.0`

---

## Tagging + GitHub Releases

- **Annotated tags only** (`git tag -a vX.Y.Z -m "..."`). Lightweight tags lose signing and authorship metadata.
- Tag prefix: `vX.Y.Z` (the `v` is convention; some ecosystems — Go modules — require it).
- Mark RC tags as **pre-release** on GitHub; flip to `latest` only on production tag.
- Auto-generate release notes via `.github/release.yml` (see [`github-repo`](../github-repo/SKILL.md) for the template). Labels on merged PRs → categorized changelog.
- Pair with `CHANGELOG.md` (Keep a Changelog format) — move `[Unreleased]` to `[X.Y.Z] - YYYY-MM-DD` as part of "Prepare Release".

---

## Emergency Deploy / Rollback

Use a dedicated **"Deploy Existing Artifact"** workflow — never rollback by force-pushing or by deleting/recreating tags.

| Action                                                                                   | Type      |
|------------------------------------------------------------------------------------------|-----------|
| Dispatch **"Deploy Existing Artifact"**                                                  | Manual    |
| Input artifact version (e.g. `1.1.0` or `1.2.0.42-a1b2c3d`)                              | Manual    |
| Select target environment (`test` / `qa` / `uat` / `prod`)                               | Manual    |
| Optional: enable dry-run / plan flag (e.g. `terraform plan` only, `helm diff`)           | Manual    |
| Deploy via Terraform / Helm / framework-specific                                         | Automatic |
| Update env manifests on `config` branch                                                  | Automatic |

**Prerequisites:**

- For `prod`: the artifact must already exist in the **Prod registry**. If rolling back to a version that was never promoted, run the promotion workflow first.
- The **PROD approval gate still applies** — the environment review is enforced by GitHub regardless of which workflow initiates the deploy.

### Hotfix flow

Critical fix on production without going through a normal release:

1. `git checkout -b hotfix/PROJ-NNN-1.2.1` off the `v1.2.0` tag (not `develop`).
2. Apply fix, PR into `release/1.2.1` (cut from the tag) — flow continues like a normal release.
3. On PROD ship, back-merge `release/1.2.1` into `develop` **and** any open `release/*` branches.

See [`cicd`](../cicd/SKILL.md) for the action-level commands.

---

## GitOps Manifest Branch

Optional pattern for ArgoCD / Flux / Internal Developer Platforms (Backstage, Port, Humanitec).

- A single long-lived `config` branch holds env-specific manifests (`envs/test/values.yaml`, `envs/qa/values.yaml`, etc.).
- Every successful deploy job commits the new image tag / artifact version to the corresponding manifest.
- ArgoCD/Flux watches `config` and reconciles the cluster.
- **Humans never push to `config`.** All changes go through the deploy pipeline. Branch protection enforces this.
- Audit trail: every deploy is a commit on `config` with the workflow run URL in the message.

---

## Quality Gates Summary

| Environment   | Trigger                                              | Approval needed?                      |
|---------------|------------------------------------------------------|---------------------------------------|
| **PR check**  | PR opened/updated                                    | No (required status checks must pass) |
| **TEST**      | Auto on merge to `develop`                           | No                                    |
| **QA**        | Auto via "Prepare Release" or push to `release/**`   | No                                    |
| **UAT**       | Manual dispatch of "Deploy to UAT and Prod"          | No                                    |
| **PROD**      | Continues from UAT workflow                          | **Yes** — GitHub Environment review   |
| **Tag + Release** | Auto after PROD succeeds                         | No (inherits PROD approval)           |
| **Rollback**  | Manual dispatch of "Deploy Existing Artifact"        | PROD: yes; other envs: no             |

Required checks on PRs to `develop`: lint, test, build, SAST, SCA. Required checks on PRs to `release/**`: same, plus integration tests.

---

## Anti-Patterns

| Anti-pattern                                            | Why it hurts                                                                                 |
|---------------------------------------------------------|----------------------------------------------------------------------------------------------|
| Long-lived `release/*` branch (weeks)                   | Drift from `develop` grows; back-merges become merge nightmares                              |
| Multiple concurrent `release/*` branches                | Back-merge order ambiguous; hotfixes land in some but not others                             |
| Rebuilding artifact for PROD instead of promoting       | PROD ships untested bytes; defeats the purpose of QA sign-off                                |
| Skipping back-merge after a hotfix                      | The next release silently regresses the fix                                                  |
| Tagging before deploy success                           | Failed deploys leave a tag that doesn't correspond to anything live; tooling lies            |
| Same registry path for snapshot + release artifacts     | Disk fills with churn; SBOM/signing tooling can't distinguish them                           |
| `latest` tag pointing at a pre-release                  | Consumers running `:latest` get untested code                                                |
| Version = git SHA only                                  | No ordering, no human-readable contract; consumers can't pin or upgrade safely               |
| Humans pushing to `config` branch                       | Breaks GitOps reconciliation; deploy state diverges from manifest state                      |
| Branch names without ticket prefix                      | Loses traceability; release notes can't link to tracker; auditors can't follow the trail     |
| Force-push to `develop` / `main` / `release/*`          | Rewrites shared history; CI caches and downstream clones break                               |

---

## Related Skills

- [`cicd`](../cicd/SKILL.md) — action-driven companion: commands for starting a release, tagging an RC, promoting to prod
- [`github-repo`](../github-repo/SKILL.md) — `.github/release.yml`, `CHANGELOG.md`, environment configuration
- [`husky`](../husky/SKILL.md) — `commit-msg` hook to enforce Conventional Commits + ticket-ref format locally
