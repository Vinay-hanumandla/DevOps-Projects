---
last_verified: 2026-07-13
tool_version: n/a
---

# Undo, stage, commit, and push — what I learned

Spent some time working through Git's tutorial sections on staging, committing, and undoing changes. Here's what clicked and what didn't.

## Staging area finally makes sense

The staging area (index) is Git's middle ground between your working directory and the repository. I used to think `git add` was just a formality, but now I see it lets you craft commits intentionally — stage only the files that belong together.

```bash
# stage specific files, not everything
git add src/index.js src/utils.js
git add -p  # stage parts of a file interactively
```

`git add -p` (patch mode) was the biggest "aha" moment. I can stage only certain hunks of a changed file, leaving unrelated changes unstaged. That's huge for keeping commits clean.

## Committing

`git commit` without `-m` opens the editor. I started writing proper commit messages:

```
Subject line (50 chars or less)

Body explaining the "why" not the "what".
```

The tutorial emphasized that a good commit message has a subject line under 50 characters and wraps the body at 72. I didn't know there was a convention.

## Undoing

This was the most confusing part. Here's what I landed on:

- **`git restore <file>`** — undo unstaged changes (discard working tree changes)
- **`git restore --staged <file>`** — unstage a file (keep working tree changes)
- **`git reset --soft HEAD~1`** — undo the last commit but keep changes staged
- **`git reset --mixed HEAD~1`** — undo the last commit, unstage changes (default)
- **`git reset --hard HEAD~1`** — undo the last commit AND discard changes (dangerous)
- **`git revert <commit>`** — create a new commit that undoes a previous commit (safe for pushed history)

The old `git checkout -- <file>` syntax still works but `git restore` is the modern replacement. The tutorial recommended using `restore` over `checkout` for file-level operations.

## Pushing

`git push` was fine once I remembered to set the upstream:

```bash
git push -u origin <branch>
```

## Got stuck on

- **`git reset` modes.** I had to draw a diagram to remember which mode does what. The working tree / staging index / commit history three-state model takes practice.
- **`git revert` requires a clean working tree.** If you have uncommitted changes, `git revert` refuses to run. I had to stash first.

## What I'd try next

Merging and rebasing are the obvious next things to learn. I also want to try `git bisect` for finding which commit introduced a bug.
