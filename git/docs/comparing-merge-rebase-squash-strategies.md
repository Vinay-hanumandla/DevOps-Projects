---
last_verified: 2026-10-09
tool_version: n/a
---

# Comparing merge, rebase, and squash-merge strategies

## Purpose

This document compares three Git integration strategies — merge, rebase, and squash-merge — across history topology, conflict rates, and CI throughput. It provides a decision framework for teams choosing a default integration method for pull requests.

## When to use

- **Merge**: Default choice for most teams; preserves full history and context
- **Rebase**: Linear history preferred; small, focused commits; team comfortable with force-push
- **Squash-merge**: Clean main branch history; large PRs with many WIP commits; simplified bisect

## Prerequisites

- Git 2.20+ (for `merge --squash` improvements)
- CI system supporting the chosen strategy (GitHub Actions, GitLab CI, Jenkins, etc.)
- Branch protection rules configured for the target branch

## Strategy comparison

### History topology

| Aspect | Merge | Rebase | Squash-merge |
|--------|-------|--------|--------------|
| **Main branch shape** | Diamond/DAG with merge commits | Linear, no merge commits | Linear, single commit per PR |
| **Commit granularity** | Preserves all original commits | Preserves all original commits (rewritten) | Collapses to one commit |
| **Authorship** | Original authors retained | Original authors retained | Squash commit authored by merger |
| **Bisect behavior** | May land on merge commit | Lands on exact commit | Lands on squash commit (coarser) |
| **Revert complexity** | `git revert -m 1 <merge>` | `git revert <commit>` | `git revert <squash>` |

### Conflict rates

| Scenario | Merge | Rebase | Squash-merge |
|----------|-------|--------|--------------|
| **Long-running feature branch** | One conflict resolution at merge | Multiple resolutions (per commit) | One conflict resolution at squash |
| **Frequent main updates** | Accumulates conflicts | Conflicts spread across rebases | Conflicts resolved once |
| **Large PR (>20 commits)** | Single merge conflict | Repeated rebase conflicts | Single squash conflict |
| **Conflict resolution visibility** | Visible in merge commit | Hidden in rewritten history | Visible in squash commit |

### CI throughput

| Metric | Merge | Rebase | Squash-merge |
|--------|-------|--------|--------------|
| **Builds per PR** | 1 (on merge commit) | N (per commit if CI runs on push) | 1 (on squash commit) |
| **Queue depth** | Lower | Higher (each push triggers CI) | Lower |
| **Flaky test impact** | Isolated to merge | Amplified across commits | Isolated to squash |
| **Cache efficiency** | Good (single build) | Poor (repeated builds) | Good (single build) |
| **Time to feedback** | Fast (one result) | Slower (sequential) | Fast (one result) |

## Decision matrix

```
                         ┌─────────────────────────────────────────────┐
                         │  Team / Project Characteristics             │
├────────────────────────┼──────────┬──────────┬──────────┬────────────┤
│                        │ Merge    │ Rebase   │ Squash   │ Notes      │
├────────────────────────┼──────────┼──────────┼──────────┼────────────┤
│ Team size < 5          │ ✓        │ ✓        │ ✓        │ Any works  │
│ Team size > 10         │ ✓        │ ✗        │ ✓        │ Rebase     │
│                        │          │          │          │ scales     │
│                        │          │          │          │ poorly     │
├────────────────────────┼──────────┼──────────┼──────────┼────────────┤
│ Monorepo               │ ✓        │ △        │ ✓        │ Rebase     │
│                        │          │          │          │ conflicts  │
│                        │          │          │          │ spike      │
├────────────────────────┼──────────┼──────────┼──────────┼────────────┤
│ Regulated / audit      │ ✓        │ ✗        │ △        │ Merge      │
│ trail required         │          │          │          │ preserves  │
│                        │          │          │          │ full       │
│                        │          │          │          │ history    │
├────────────────────────┼──────────┼──────────┼──────────┼────────────┤
│ Frequent releases      │ ✓        │ △        │ ✓        │ Squash     │
│ (daily+)               │          │          │          │ cleaner    │
│                        │          │          │          │ tags       │
├────────────────────────┼──────────┼──────────┼──────────┼────────────┤
│ Open source /          │ ✓        │ ✗        │ △        │ Merge      │
│ external contributors  │          │          │          │ safer for  │
│                        │          │          │          │ forks      │
├────────────────────────┼──────────┼──────────┼──────────┼────────────┤
│ Trunk-based dev        │ △        │ ✓        │ ✓        │ Rebase/    │
│ (short-lived branches) │          │          │          │ squash     │
│                        │          │          │          │ preferred  │
└────────────────────────┴──────────┴──────────┴──────────┴────────────┘
```

## Implementation details

### Merge strategy

```yaml
# GitHub branch protection rule
required_pull_request_reviews:
  required_approving_review_count: 1
merge_strategy: merge
allow_merge_commit: true
allow_rebase_merge: false
allow_squash_merge: false
```

```bash
# Local equivalent
git checkout main
git pull origin main
git merge --no-ff feature/branch-name
git push origin main
```

**Trade-offs**: Creates merge commits that some find noisy. Use `--no-ff` to always create a merge commit even when fast-forward is possible.

### Rebase strategy

```yaml
# GitHub branch protection rule
merge_strategy: rebase
allow_merge_commit: false
allow_rebase_merge: true
allow_squash_merge: false
```

```bash
# Local equivalent
git checkout feature/branch-name
git fetch origin
git rebase origin/main
# Resolve conflicts if any
git push --force-with-lease origin feature/branch-name
# Then merge via PR UI or:
git checkout main
git merge feature/branch-name  # fast-forward
```

**Trade-offs**: Requires force-push (`--force-with-lease` for safety). Rewrite history — not suitable for shared branches. CI runs on every push during rebase.

### Squash-merge strategy

```yaml
# GitHub branch protection rule
merge_strategy: squash
allow_merge_commit: false
allow_rebase_merge: false
allow_squash_merge: true
```

```bash
# Local equivalent
git checkout main
git pull origin main
git merge --squash feature/branch-name
git commit -m "feat: add feature X (#123)"
git push origin main
```

**Trade-offs**: Loses individual commit history. Squash commit message should follow conventional commits. Original commits remain in the PR for review context.

## Common errors

### Merge: "Merge conflict in <file>"

```bash
# Resolution
git status                    # See conflicted files
# Edit files to resolve <<<<<<< markers
git add <resolved-files>
git commit                    # Creates merge commit
```

### Rebase: "Could not apply <commit>..."

```bash
# Resolution
git status                    # See conflicted files
# Edit files to resolve
git add <resolved-files>
git rebase --continue         # Continue rebase
# Repeat until complete
git push --force-with-lease   # Update remote
```

### Squash-merge: "Squash commit message too long"

```bash
# Use concise message with PR reference
git commit -m "feat(scope): brief description (#PR_NUMBER)"
```

### Rebase: Force-push rejected

```bash
# Another contributor pushed to the branch
git fetch origin
git rebase origin/feature/branch-name
# Resolve any new conflicts
git push --force-with-lease
```

## Verification

After implementing a strategy, verify:

1. **History shape**: `git log --oneline --graph -20` shows expected topology
2. **Bisect works**: `git bisect start HEAD <known-good>` lands on meaningful commits
3. **Revert works**: `git revert <commit>` cleanly reverts the change
4. **CI passes**: Single build per PR for merge/squash; acceptable queue depth for rebase