---
last_verified: 2026-09-20
tool_version: n/a
---

# Worktree workflows for parallel feature development

## Purpose

A linked working tree lets one clone host several checked-out branches at once, each in its own directory, sharing a single object store. That removes the stash-switch-rebuild loop of single-checkout development: each feature keeps its own working state, build output, and test run while `git push` from any worktree feeds the same CI pipeline and review flow as a normal branch push.

## When to use

- Two or more feature branches are active at the same time and context-switching costs (rebuilds, test restarts, uncommitted changes) dominate.
- A long-running verification (test suite, local server, reproduction script) must keep running on one branch while edits continue on another.
- A reviewer wants to check out someone else's branch locally without disturbing their own in-progress work — a detached worktree on the review ref leaves the main checkout untouched.
- Single-checkout discipline (stash, switch, rebuild) is still simpler when only one branch is active; worktrees pay off from the second concurrent branch onward.

## Prerequisites

- One existing repository checkout; linked worktrees are created from it and share its object database.
- One branch per worktree: the same branch cannot be checked out in two worktrees at once.
- Enough disk space for a full working copy per concurrent branch (build artifacts and ignored files are per-worktree, not shared).

## Steps

### 1. Create one worktree per active feature

```bash
git worktree add ../feature-a feature-a
git worktree add ../feature-b feature-b
git worktree list
```

Each command creates a directory with that branch checked out. `git worktree list` confirms the main checkout plus each linked path and its branch.

### 2. Work and verify independently in each tree

```bash
cd ../feature-a
# edit, then run the branch's checks
git status --short
git push -u origin feature-a
```

Pushing from a worktree is identical to pushing from a single checkout: the branch update triggers the same CI pipeline and opens or updates the same review. There is no special CI configuration — the pipeline sees a branch push, regardless of which local directory produced it.

### 3. Keep CI green per worktree

Treat each worktree as its own CI client: push early from each tree so failures are attributed to the right branch while the other tree keeps running. When CI reports a failure on `feature-a`, fix it inside `../feature-a` without pausing work in `../feature-b`.

### 4. Check out reviews in disposable worktrees

```bash
git fetch origin pull-request-branch
git worktree add --detach ../review-pr pull-request-branch
# inspect, run checks, then remove the tree when the review is done
git worktree remove ../review-pr
```

A detached worktree pins the review ref without creating a local branch, so reviewing never disturbs in-progress feature work. Remove the tree after approving or requesting changes.

### 5. Clean up merged branches

```bash
git worktree remove ../feature-a
git worktree prune
```

Remove the worktree once its branch is merged, then delete the branch itself. `git worktree prune` clears administrative entries for trees deleted outside of Git (e.g. removed with a plain directory delete). Verify with `git worktree list` that only live trees remain.

## Verify

- `git worktree list` — shows every live worktree, its path, commit, and branch. Each feature branch appears exactly once.
- `git status --short` inside each tree — confirms uncommitted changes are isolated to the intended branch.
- `git branch --show-current` (or the prompt) inside each tree — confirms commands run against the right branch before pushing.
- CI status on each open review — each branch shows its own pipeline result, independent of sibling worktrees.

## Common errors

- **Same branch checked out twice.** Checking out a branch that is already active in another worktree aborts with a fatal error. Create a new branch for the second tree, or use `--detach` for read-only inspection.
- **Stale entries after manual deletion.** Deleting a worktree directory with a file manager instead of `git worktree remove` leaves a stale administrative entry. Run `git worktree prune` to clear it.
- **Missing build setup in a new tree.** Ignored files (dependency installs, local config, build caches) are not shared between worktrees. Re-run the project's setup step inside each new tree before running tests.
- **Running the wrong command in the wrong tree.** Prompts in sibling directories look alike. Check `git branch --show-current` before committing or pushing, especially right after switching terminal tabs.

## References

- `git worktree --help` — full subcommand reference (`add`, `list`, `remove`, `prune`, `move`, `repair`).
- `git help worktree` — conceptual background on linked working trees and the one-branch-per-worktree rule.
