---
last_verified: 2026-09-02
tool_version: n/a
sources:
  - https://dev.to/dr_rvinobchander_ac6a/build-your-first-cicd-pipeline-with-github-actions-complete-beginners-guide-6fj
  - https://dev.to/htekdev/the-definitive-github-actions-debugging-guide-65-real-errors-and-how-to-fix-them-54p7
  - https://www.devopsness.com/blog/first-cicd-pipeline-github-actions-tutorial
  - https://www.devtools.tools/blog/github-actions-yaml-guide
---

# Tag-triggered release automation with GitHub Actions

> One approach to wiring GitHub Actions so that a push of a version tag kicks off a build, test, and release workflow.

## Purpose

This doc covers the steps to set up a GitHub Actions workflow that triggers only when a version tag is pushed, runs the build and test suite, and then publishes a release. It is useful for teams that want CI to gate every published version without running the same pipeline on every commit to main.

## When to use

Use a tag-triggered workflow when releases should be explicit events rather than automatic side effects of a branch push. Tagging gives you a single, immutable point in history to build from, and the tag message can carry release notes.

## Prerequisites

- A repo on GitHub with at least one commit on the default branch
- A project that can be built and tested from the command line
- `gh` CLI authenticated if you want to create the workflow file from the command line

## Steps

1. **Create the workflow file.** Add a YAML file at `.github/workflows/release.yml` in the repo root. GitHub only reads workflows from this exact path.

2. **Define the tag trigger.** Use `on: push: tags: ['v*']` to fire the workflow only when a tag matching the pattern is pushed. A tag like `v1.2.3` triggers the run; a plain commit push does not.

3. **Check out the code.** Add a step using `actions/checkout@v4` to pull the repo at the tagged commit. The checkout action fetches the exact ref the tag points to, so the build sees the same source the tag was made from.

4. **Set up the language runtime.** Add a step using `actions/setup-node@v4` (or the equivalent for your language) with the version pinned and caching enabled. Pinning the version keeps the runner environment reproducible across runs.

5. **Install dependencies and run tests.** Chain `npm ci` then the test command. Tests must pass before the release step runs; otherwise the workflow stops at the failed job.

6. **Add a permissions block if the workflow writes to the repo.** Since February 2023 the default `GITHUB_TOKEN` has read-only `contents` scope. If a step needs to create a release, commit a version file, or push a tag, add an explicit `permissions:` block granting the required scopes. Without it the step fails with a vague 403.

7. **Publish the release.** Add a step that creates a GitHub Release using a community action or the GitHub CLI. Pass the tag and target commit as inputs. Drafts and pre-releases can be toggled with input flags.

## Verify

Push a test tag and watch the run:

```bash
git tag v0.1.0-test
git push origin v0.1.0-test
```

Open the Actions tab to confirm the workflow started, then check the Jobs page for a green check. If the run is missing, verify the file path is exactly `.github/workflows/release.yml` and the tag matches the `tags:` pattern.

Delete the test tag after verifying so it does not pollute the release history:

```bash
git tag -d v0.1.0-test
git push origin :refs/tags/v0.1.0-test
```
