---
last_verified: 2026-09-10
tool_version: n/a
sources: []
---

# Git integration patterns with CI/CD pipelines

## Purpose

Git is the source of truth for code, but it is also the primary signal source for CI/CD pipelines. Every push, pull request, tag, and branch deletion is an event that a pipeline can react to. This document surveys the integration patterns available when wiring Git events to CI/CD workflows, and provides guidance on choosing between them. It complements the more focused guides on tag-driven releases, conventional-commit gates, and image tagging from `git describe` elsewhere in this kit.

## When to use

| Pattern | Use when… | Avoid when… |
|---|---|---|
| Push-triggered CI | You want fast feedback on every commit pushed to any branch. | Your monorepo has dozens of independent services and every push triggers a full build that wastes compute. |
| Pull-request gates | You need to validate changes before they merge into the mainline. | Your workflow uses direct pushes to `main` with no review step. |
| Tag-triggered releases | You want an immutable link between a version label and the exact commit that shipped. | Your release process is manual or you do not tag releases. |
| Path-filtered pipelines | You have a monorepo or multi-service repo and only want to run CI for changed directories. | Your repo is small enough that a full pipeline run is cheap. |
| Scheduled pipelines | You need nightly security scans, dependency updates, or integration tests against external services. | You have no long-running or time-sensitive checks that cannot run on push. |
| Branch-protection gates | You need to enforce review requirements, status checks, or linear history on critical branches. | You are the sole maintainer and process overhead is unwarranted. |
| Deployment-on-merge | You want merged PRs to deploy automatically to staging or production. | You need manual approval gates or multi-environment promotion before production. |

## Prerequisites

- A CI system that supports event-based triggers (GitHub Actions, GitLab CI, Jenkins, CircleCI, etc.)
- A branching strategy agreed upon by the team (trunk-based, GitFlow, or a hybrid)
- Branch protection configured on the target branch if merge gates are needed

## Pattern 1 — Push-triggered CI

The simplest integration: every push to any branch triggers the full pipeline. The CI system receives a webhook from the Git host, checks out the commit, and runs the configured jobs.

**Strengths:** Maximum feedback frequency. Every commit is tested immediately.
**Weaknesses:** In large repos or monorepos, this can be expensive. A commit to `docs/` triggers the same pipeline as a commit to `src/`.

Most CI systems support filtering push events by branch name:

```
on:
  push:
    branches: [main, develop]
```

This restricts the trigger to specific branches, reducing noise while still catching integration issues early.

## Pattern 2 — Pull-request gates

Pull requests add a review layer between the developer's branch and the mainline. The CI pipeline runs against the PR's head commit and reports status back to the PR page. Merging is blocked until all checks pass.

Key configuration points:

- **Trigger events.** Run CI on `opened`, `synchronize` (new commits pushed), and `reopened` — not on `closed`, which fires even for unmerged PRs.
- **Status checks.** The CI system posts a status check (e.g. `ci/build`) that branch protection can require before allowing merge.
- **Concurrency.** Use concurrency groups to cancel in-progress runs when new commits are pushed to the same PR, avoiding wasted compute on stale commits.

```
concurrency:
  group: ${{ github.workflow }}-${{ github.head_ref || github.run_id }}
  cancel-in-progress: true
```

## Pattern 3 — Tag-triggered releases

Tags provide the most stable trigger for release pipelines. Unlike branch tips, which move with every push, an annotated tag points at a single commit. The release pipeline can extract version metadata from the tag name using `git describe --tags` or by parsing the tag string directly.

This pattern is covered in detail in `git-cicd-tag-driven-releases-conventional-commits.md`, but the core integration points are:

- The CI trigger filters on tag patterns (`v[0-9]+.[0-9]+.[0-9]+`).
- The pipeline checks out the tagged commit (not `HEAD`) to ensure the release artifact matches the tag exactly.
- The pipeline can create a release branch from the tag for hotfix cherry-picks.

## Pattern 4 — Path-filtered pipelines

In monorepos or multi-service repositories, running the full CI suite on every change is wasteful. Path filters let the pipeline skip jobs that are irrelevant to the changed files.

GitHub Actions supports `paths` and `paths-ignore` filters on push and pull_request triggers:

```
on:
  push:
    paths:
      - 'services/api/**'
      - 'libs/shared/**'
```

GitLab CI uses `rules:changes:paths` in `.gitlab-ci.yml`. The same concept applies across CI systems.

**Design considerations:**

- **Cross-service dependencies.** A change to `libs/shared/` may affect every service that depends on it. Path filters alone cannot detect this — you need a dependency graph or a "change detection" tool that understands import relationships.
- **Test scope.** Even when the pipeline runs, path filters can also scope which test suites execute. Run unit tests for the changed service only; run integration tests across affected services.
- **Fallback.** A change to `.github/workflows/` or `.gitlab-ci.yml` itself should trigger the full pipeline, because the pipeline definition has changed.

## Pattern 5 — Scheduled pipelines

Scheduled triggers complement push and PR triggers by running checks that are too slow or too external-dependent for per-commit runs:

- **Nightly security scans.** Dependency vulnerability scans, container image scans, and SAST tools that take minutes to hours.
- **Integration tests against external services.** Tests that hit real APIs, databases, or cloud resources that should not run on every developer push.
- **Compliance audits.** License checks, SBOM generation, and audit log collection.

Scheduled pipelines typically run against a fixed branch (`main` or `develop`) and use cron syntax:

```
on:
  schedule:
    - cron: '0 2 * * *'   # 2 AM UTC daily
```

**Trade-off:** Scheduled pipelines create commits or check runs detached from any developer action. Some teams treat scheduled failures as noise; others page on-call for nightly scan regressions. Decide upfront which scheduled failures are actionable.

## Pattern 6 — Branch-protection gates

Branch protection turns Git host configuration into a CI enforcement mechanism. Rather than relying on pipeline triggers alone, protection rules prevent merges or force-pushes unless specific conditions are met:

- **Required status checks.** The CI system must report a passing status (e.g. `ci/build`, `ci/test`) before the branch can be updated.
- **Required reviews.** At least N approvals from specified CODEOWNERS before merge.
- **Linear history.** Enforce squash merge or rebase only — no merge commits on `main`.
- **Force-push protection.** Prevent rewriting history on protected branches.

Branch protection is the glue that makes PR gates mandatory rather than optional. Without it, developers can merge directly to `main` and bypass CI entirely.

## Pattern 7 — Deployment-on-merge

When a PR is merged to the mainline, the merge commit (or the resulting branch tip) can trigger a deployment pipeline. This is the most common pattern for continuous deployment to staging environments.

Configuration typically combines push triggers on the main branch with environment-specific deployment jobs:

```
on:
  push:
    branches: [main]

jobs:
  deploy-staging:
    environment: staging
    steps: [...]
  deploy-production:
    environment: production
    needs: deploy-staging
    steps: [...]
```

**Key consideration:** Deployment-on-merge assumes every merge to `main` is deployable. This requires robust CI gates, feature flags for incomplete work, and the ability to revert quickly. If the team is not confident in rollback speed, a manual approval step between staging and production is safer.

## Combining patterns

Most production pipelines combine multiple patterns. A common layered approach:

1. **On every push to a feature branch** — lint and unit tests (fast feedback).
2. **On pull request to `main`** — full test suite, security scan, and build (merge gate).
3. **On merge to `main`** — deploy to staging automatically.
4. **On tag push** — build release artifact, create GitHub Release, deploy to production.
5. **Nightly** — integration tests, dependency audit, SBOM generation.

Each layer adds a filter: fast checks run most frequently, expensive checks run less often, and deployment only happens on the most stable commits.

## Verify

After implementing any of these patterns:

- **Push trigger:** Push a commit to a filtered branch and confirm the pipeline fires (or does not fire, if using path filters).
- **PR gate:** Open a PR with a deliberately failing test and confirm the status check blocks merge.
- **Tag trigger:** Create and push an annotated tag; confirm the release pipeline triggers on the correct commit.
- **Path filter:** Change a file outside the filtered path and confirm the pipeline is skipped; change a file inside the filtered path and confirm it runs.
- **Branch protection:** Attempt a direct push to a protected branch and confirm it is rejected.
- **Concurrency:** Push two commits rapidly to a PR branch and confirm the first in-progress run is cancelled.

## Common errors

| Symptom | Cause | Fix |
|---|---|---|
| Pipeline does not trigger on push | Branch filter excludes the pushed branch | Check `on.push.branches` or `rules:if` filters |
| PR pipeline runs on closed PRs | Trigger includes `closed` event | Filter to `opened`, `synchronize`, `reopened` only |
| Tag-triggered pipeline checks out `HEAD` instead of the tag | Checkout uses default ref instead of `github.ref` | Set `ref: ${{ github.ref }}` in the checkout step |
| Path filter skips all jobs on monorepo change | `paths` filter is too narrow | Audit the filter against actual directory structure; add missing paths |
| Concurrency cancels the wrong run | Concurrency group key is too broad | Use a more specific key (e.g. include PR number or branch name) |
| Deployment runs on every merge, including breaking ones | No test gate before merge | Require passing status checks before merge via branch protection |
| Scheduled pipeline runs but no one notices failures | Scheduled failures are not routed to on-call | Configure alerting for scheduled pipeline failures (Slack, PagerDuty, etc.) |
