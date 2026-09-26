---
last_verified: 2026-09-26
tool_version: n/a
---

# Git worktree workflows for hotfix isolation

## Purpose

When a hotfix cannot wait for in-flight feature work to land, a linked worktree gives the fix its own checkout directory while feature branches keep theirs. The hotfix branch is cut from the release line, edited and verified in isolation, merged back, and torn down — all without stashing, switching, or rebuilding the feature trees. This doc covers the hotfix half of worktree usage; the parallel-feature half is covered in [worktree-parallel-feature-development.md](worktree-parallel-feature-development.md).

## When to use

- A fix must go out while one or more feature branches hold uncommitted changes, running test suites, or local servers that a checkout switch would disrupt.
- The fix needs verification against the release line (not against a feature branch's half-merged state).
- A reviewer must inspect the hotfix locally without disturbing their own checkout.
- A plain branch switch is still simpler when nothing else is in flight — reach for a worktree once the main checkout is busy.

## Prerequisites

- One existing repository checkout; linked worktrees are created from it and share its object database.
- One branch per worktree: a branch already checked out in one tree cannot be checked out in another.
- Enough disk space for an extra full working copy; ignored files and build outputs are per-worktree, not shared.
- Pushes from any worktree trigger the same CI pipeline as pushes from a single checkout — the pipeline sees a branch update, not a directory.

## Steps

### 1. Cut the hotfix branch from the release line in a fresh worktree

```bash
git fetch origin
git worktree add ../hotfix-login-retry -b hotfix-login-retry origin/main
git worktree list
```

Branching straight off the fetched release line (not off a feature branch) keeps the fix free of unrelated changes and keeps the resulting merge small. `git worktree list` confirms the new tree, its path, and its branch.

### 2. Fix, verify, and push from inside the hotfix tree

```bash
cd ../hotfix-login-retry
# edit, then run the checks the release line requires
git status --short
git push -u origin hotfix-login-retry
```

Keep the diff minimal — only the fix plus its regression test. Run the project's standard verification inside this tree (a fresh tree has no installed dependencies or build caches, so run the setup step first). Push early so the hotfix gets its own pipeline run, independent of any feature-branch pipelines.

### 3. Leave the feature trees alone

Do not touch sibling worktrees while the hotfix is open. If a feature branch also needs the fix, wait until the hotfix lands (step 4) and then merge or rebase the feature onto the updated release line inside its own tree — never edit feature code from the hotfix tree.

### 4. Merge the hotfix and forward-merge to active features

Merge the hotfix into the release line through the normal review flow, then bring each active feature tree up to date:

```bash
cd ../feature-a
git fetch origin
git merge origin/main
```

Each feature re-runs its checks after absorbing the fix. Features that already contain a conflicting hand-rolled workaround resolve the conflict here, in their own tree, where their tests can confirm the resolution.

### 5. Tear down the hotfix worktree promptly

```bash
git worktree remove ../hotfix-login-retry
git worktree prune
```

Delete the hotfix branch once merged. Hotfix trees are short-lived by design — leaving them around invites "just one more commit" drift that should have gone through a feature branch instead. Verify with `git worktree list` that only live trees remain.

## Verify

- `git worktree list` — the hotfix tree appears exactly once while open, and is gone after teardown.
- `git branch --show-current` inside the hotfix tree — confirms commands run against the hotfix branch, checked before every commit and push.
- `git status --short` in each tree — uncommitted changes are isolated to their intended branch; the hotfix tree shows only fix-related files.
- CI status on the hotfix review — green on the release-line pipeline, independent of sibling feature pipelines.
- Post-merge, each feature tree builds and tests clean after absorbing the release line.

## Rollback

- **Hotfix not yet pushed:** discard by removing the tree (`git worktree remove ../hotfix-login-retry`, or `git worktree remove --force` if it holds uncommitted changes you have decided to drop) and deleting the branch.
- **Hotfix pushed but not merged:** close or abandon the review, then remove the tree and delete the branch locally and remotely.
- **Hotfix merged but wrong:** do not rewrite the release line — cut a follow-up hotfix worktree with the correction and run the same flow.
- **Tree deleted outside Git** (file manager instead of `git worktree remove`): run `git worktree prune` to clear the stale administrative entry.

## Common errors

- **Same branch checked out twice.** Checking out a branch already active in another tree aborts. Cut a new branch for the second tree, or use `--detach` for read-only inspection.
- **Branching the hotfix off a feature branch.** The fix silently carries unrelated feature changes into the release line. Always cut from the fetched release line.
- **Missing setup in the fresh tree.** Ignored files (dependency installs, local config, caches) are not shared between worktrees — re-run project setup inside the hotfix tree before verifying.
- **Running commands in the wrong tree.** Sibling prompts look alike; confirm with `git branch --show-current` before committing or pushing, especially across terminal tabs.
- **Stale entries after manual deletion.** `git worktree prune` clears entries for trees removed without `git worktree remove`.

## References

- [worktree-parallel-feature-development.md](worktree-parallel-feature-development.md) — the companion doc: one worktree per feature, review checkouts, per-tree CI discipline.
- `git worktree --help` — full subcommand reference (`add`, `list`, `remove`, `prune`, `move`, `repair`).
