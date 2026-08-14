---
last_verified: 2026-08-14
tool_version: n/a
sources:
  - https://bashsnippets.xyz/guides/bash-scripting-for-ci-cd-pipelines
  - https://www.mechanicalrock.io/blog/modern-bash
---

# Integrating Bash with Git — Automation Patterns and Project Layout

> Bash is the glue that connects Git to the rest of a release pipeline. This doc collects the patterns that made the Bash+Git tooling in this kit reliable: failing fast on git failures, staying idempotent, and keeping the scripts organized.

## Purpose

Most release work is "run git commands, then act on the result" — tag a version, collect a changelog, deploy the current commit. Bash is the natural glue layer for that, but the naive script (`git push; git tag; deploy`) hides failures: a failed push still reports success to CI because the last command in the chain exits 0. This doc is the reference for the Bash+Git integration patterns used in this kit's release tooling, and the project layout that keeps a handful of git-touching scripts maintainable.

## When to use

- Tag-and-deploy pipelines where a version tag must be created, pushed, and verified in a single run.
- Changelog generation from `git log` between two tags.
- Any CI step that invokes git and needs to fail the build when git fails.

## Patterns

### Fail fast when git fails

The canonical failure mode is a swallowed exit code: `git push origin main | tee push.log` reports the exit status of `tee` (which always succeeds), so a failed push ships a green checkmark. `set -o pipefail` closes that gap by making the pipeline report the first non-zero exit code. In a GitHub Actions `run:` block, a Docker `ENTRYPOINT`, or a deploy script, `set -euo pipefail` is what turns a swallowed git failure into a red build.

### Stay re-runnable

A release script run twice must not fail or duplicate work. Check before acting:

```bash
if ! git tag -l | grep -q "$VERSION"; then
    git tag "$VERSION"
fi
```

The same pattern covers pushes and directories: verify existence, then act. This is what makes a release script safe to re-run after a CI hiccup.

### Resolve the commit you're shipping

Resolve the current commit once and thread it through the pipeline:

```bash
COMMIT_SHA=$(git rev-parse HEAD)
```

Write it into the release artifact so the deployed state can be traced back to a commit. The semantic release helper (`../../git/scripts/semantic-release-automation.sh`) derives the next version from `git describe` tags; the release workflow template (`../../git/templates/release-workflow/`) shows the full layout.

## Project layout

Keep git-touching Bash in a small, flat tree:

```
bin/        entrypoints you run by hand
lib/        shared functions (common.sh)
scripts/    the actual work
tests/      bats tests
```

The release workflow template in `git/templates/release-workflow/` follows this shape: a `lib/common.sh` for shared helpers, plus `scripts/release.sh`, `scripts/changelog.sh`, and `scripts/verify-release.sh`. Scripts that stay under a few hundred lines fit Bash; past that, move the logic to Python.

## Verify

Run the script twice: the second run must be a no-op, not an error. Break git on purpose (push to a non-existent remote) and confirm the script exits non-zero and CI turns red. If the tag already exists, the guard must skip, not fail. Two gotchas worth noting: `git tag` inside a command substitution with `set -e` still aborts on a non-zero exit, so the existence guard has to run before the tag command; and `cd` to the repo root explicitly or use `git -C`, since `git rev-parse` from the wrong directory fails with "not a git repository".

## References

- https://bashsnippets.xyz/guides/bash-scripting-for-ci-cd-pipelines
- https://www.mechanicalrock.io/blog/modern-bash
