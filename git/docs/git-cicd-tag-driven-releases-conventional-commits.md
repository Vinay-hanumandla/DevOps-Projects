---
last_verified: 2026-09-07
tool_version: n/a
sources: []
---

# Integrating Git with CI/CD: tag-driven release branches and conventional-commit gates

## Purpose

This document describes two complementary patterns for wiring Git into a CI/CD pipeline: **tag-driven release branches** (where a semantic version tag triggers an automated release workflow) and **conventional-commit gates** (where commit message format is validated in CI to keep history clean and enable automated changelogs). Both patterns reduce manual toil and make releases reproducible.

## When to use

| Pattern | Use when… | Avoid when… |
|---|---|---|
| Tag-driven release branches | You need a single source of truth for what ships to production. Tags map 1:1 to releases and can trigger CD pipelines automatically. | Your team prefers trunk-based development with feature flags and no formal release cadence. |
| Conventional-commit gates | You want automated changelogs, semantic-version bumping, or commit linting in CI. | Your project is small enough that manual changelog maintenance is not a burden. |

These patterns are not mutually exclusive. A mature pipeline often uses both: conventional commits feed into changelog generation, and the resulting version tag triggers the release branch workflow.

## Prerequisites

- Git 2.x or later (for annotated tags and `git describe`)
- A CI system that supports webhook or push-event triggers (GitHub Actions, GitLab CI, Jenkins, etc.)
- Branch protection rules configured on the target branch (e.g. `main` or `release`)

## Pattern 1 — Tag-driven release branches

### How it works

1. A developer (or automation) creates an annotated tag on the commit that should become a release:
   ```
   git tag -a v1.4.2 -m "Release 1.4.2"
   git push origin v1.4.2
   ```
2. The CI system detects the tag push and triggers a release workflow.
3. The workflow checks out the tagged commit, builds artifacts, runs tests, and publishes the release.
4. Optionally, the workflow creates a release branch (`release/1.4.x`) for hotfix cherry-picks.

### Workflow skeleton (GitHub Actions)

```yaml
name: Release
on:
  push:
    tags:
      - 'v[0-9]+.[0-9]+.[0-9]+'   # match semver tags

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0          # full history for changelog

      - name: Build and test
        run: |
          make build
          make test

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          generate_release_notes: true
```

### Key design decisions

- **Annotated tags over lightweight tags.** Annotated tags carry a message and timestamp; CI can extract metadata with `git tag -l --format='%(contents)'`.
- **Tag naming convention.** `vMAJOR.MINOR.PATCH` is the de facto standard. Tools like `git describe --tags --abbrev=7` rely on this convention.
- **Release branch creation.** For projects that maintain long-lived support branches, the release workflow can auto-create `release/X.Y` from the tag:
  ```
  git checkout -b release/1.4 v1.4.2
  git push origin release/1.4
  ```

## Pattern 2 — Conventional-commit gates

### How it works

1. The CI pipeline runs a commit-lint check on every push or pull request.
2. The check validates that commit messages follow the Conventional Commits format:
   ```
   <type>(<scope>): <description>

   [optional body]

   [optional footer(s)]
   ```
3. Allowed types include `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, and `revert`.
4. A failing gate blocks the merge, enforcing history hygiene.

### Workflow skeleton (GitHub Actions)

```yaml
name: Conventional Commits
on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  lint-commits:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: wagoid/commitlint-github-action@v6
```

### Configuration file (commitlint.config.js)

```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'docs', 'style', 'refactor',
      'perf', 'test', 'build', 'ci', 'chore', 'revert'
    ]],
    'subject-max-length': [2, 'always', 72],
    'body-max-line-length': [1, 'always', 100],
  },
};
```

### Key design decisions

- **Scope is optional but encouraged.** Scoped commits (`feat(api): add endpoint`) make changelogs more readable.
- **Breaking changes.** A `!` after the type (`feat!: remove deprecated endpoint`) or a `BREAKING CHANGE:` footer signals a major version bump.
- **Integration with semantic-release.** Conventional commits enable tools like `semantic-release` to automatically determine the next version number and generate changelogs.

## Combining both patterns

A typical pipeline chains these gates:

1. **PR opened** → conventional-commit lint runs on all commits in the PR.
2. **PR merged to `main`** → CI runs tests and lint.
3. **Release triggered** → a maintainer (or automation) creates a semver tag.
4. **Tag pushed** → release workflow builds, tests, and publishes the artifact.

This creates a traceable path from commit → merge → tag → release, with automated quality gates at each stage.

## Verify

- Push a commit with a malformed message (e.g. `fixed stuff`) to a PR branch; the conventional-commit gate should fail.
- Create an annotated tag `v0.0.1-test` on a branch; the release workflow should trigger.
- Run `git tag -l` to confirm tags exist with the expected naming convention.

## Common errors

| Symptom | Cause | Fix |
|---|---|---|
| Commitlint action fails with "Unable to resolve ref" | Shallow clone missing tag history | Set `fetch-depth: 0` in the checkout step |
| Tag push does not trigger the release workflow | Tag name does not match the glob pattern | Check the `on.push.tags` filter in the workflow YAML |
| Breaking change not detected by semantic-release | Missing `BREAKING CHANGE` footer or `!` suffix | Add `BREAKING CHANGE: <description>` to the commit body or append `!` after the type |
| Release branch diverges from `main` | Hotfixes cherry-picked without back-merging | Merge the release branch back into `main` after hotfixes |

## References

- Conventional Commits specification
- GitHub Actions `push` event documentation
- Semantic Versioning 2.0.0
