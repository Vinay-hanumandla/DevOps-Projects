---
last_verified: 2026-08-18
tool_version: n/a
---

# Rebase-based vs merge-based workflows for Git history at scale

## Purpose

At a small scale, the choice between rebase-based and merge-based workflows is mostly aesthetic. At scale — hundreds of contributors, CI pipelines running on every push, and release branches that live for weeks — the integration strategy directly affects merge throughput, bisect reliability, and the signal-to-noise ratio in `git log`. This doc compares the two approaches specifically for large, long-lived repositories.

## Steps

### Rebase-based at scale

1. Require feature branches to be rebased onto the latest main before merging, via a bot or a "Update branch" button.
2. Use squash merges or fast-forward merges so that each feature contributes exactly one commit to the mainline.
3. Tag releases on the main branch immediately after the merge commit. Because the history is linear, `git describe --tags` returns a clean version string.
4. For rollback, redeploy the previous tag. Individual feature commits are not preserved on main, so reverting a single feature requires locating the feature branch or using the PR metadata.

### Merge-based at scale

1. Require pull requests to merge with `--no-ff` so that every integration is recorded as a merge commit.
2. Protect the main branch against direct pushes and require status checks to pass on the merge commit.
3. Tag releases at the merge commit or on a dedicated release branch. `git describe --tags` counts both feature and merge commits, so filter with `--no-merges` when generating changelogs.
4. For rollback, run `git revert -m 1 <merge-sha>`. The original feature commits remain in the graph, making the revert surgical and auditable. Omitting `-m 1` aborts with a fatal error because Git cannot determine which side of the merge to keep.

## Verify

- `git log --oneline --graph --decorate --all` — a rebase-based repo shows a straight line on main; a merge-based repo shows merge bubbles at every integration.
- `git describe --tags --always` — returns a clean `vX.Y.Z-N-gSHA` on a linear history. On a merge-heavy repo, confirm whether the `N` count includes merge commits and whether that breaks your release tooling.
- `git log --oneline --no-merges v1.2.0..v1.3.0` — should list only feature commits in a merge-based workflow. If merge commits still appear, the tagging policy places tags at the wrong objects.
- `git bisect start <bad> <good>` followed by `git bisect log` — should terminate at a feature commit, not a merge commit. If it lands on a merge, the branch topology is too dense for bisect to skip cleanly.
