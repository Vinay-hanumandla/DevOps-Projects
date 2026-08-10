---
last_verified: 2026-08-10
tool_version: n/a
sources: []
---

# Repo — reconcile coverage tables with on-disk counts

> How I compared the README coverage table and the Git file index against what's actually on disk, then fixed the mismatches.

## What I did

I started by listing every file in the repo (excluding `.git/` and `00_index/`), grouped them by tool and category, and compared those counts against the two coverage tables I could find: the main one in `README.md` and the Git-specific one in `git/docs/2026-08-10-git-index.md`.

## What I found

Three mismatches:

1. **Git docs** — `README.md` says 3, but `git/docs/` actually has 4 files (`2026-08-10-git-index.md`, `how-i-wired-git-hooks-into-my-local-dev-workflow.md`, `interactive-rebase-vs-merge-commit.md`, `rebase-based-vs-merge-based-release-workflows.md`). The index doc I wrote earlier hadn't counted itself yet.
2. **Helm docs** — `README.md` says `—`, but `helm/docs/2026-08-10-helm-coverage.md` is on disk now.
3. **Git hooks** — `README.md` has no `hooks` column, but `git/hooks/install.sh` exists. The Git index doc already tracks hooks separately, so the README table was the one missing it.

## What I fixed

- Updated `README.md`:
  - Git docs: 3 → 4
  - Helm docs: — → 1
  - Added a `hooks` column (Git = 1, all others = —)
- Updated `git/docs/2026-08-10-git-index.md`:
  - docs count: 3 → 4
  - Added `2026-08-10-git-index.md` to the docs file list

## How I verified

I ran `find . -type f -not -path './.git/*' -not -path './00_index/*'` from the repo root, grouped the output by tool folder, and spot-checked each count against the table. Every tool row now matches the on-disk listing.

## What I'd do next

I want to turn this into a small Bash script that auto-generates the coverage table from the filesystem so the counts stay in sync when I add new files. Right now I'm doing this manually every time I add a doc or script, and it's easy to miss a folder.
