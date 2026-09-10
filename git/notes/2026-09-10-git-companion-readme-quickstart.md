---
last_verified: 2026-09-10
tool_version: n/a
sources: []
---

# Companion README.md for the Git quickstart trip-ups notes

After writing the Git quickstart trip-ups notes, I needed a companion README.md that could sit alongside it and serve as a reference card. The trip-ups notes are personal journal; this README is a quick-scan reference.

## What the quickstart covers

Installing Git, configuring identity (`git config --global user.name/email`), initializing a repo (`git init`), staging (`git add`), committing (`git commit -m`), and checking history (`git log`).

## The five trip-ups I hit

1. **Staging vs committing** — `git add` stages, doesn't commit. You must `git commit` after.
2. **`git commit -m` without staging** — For new files, nothing happens. Use `-a` flag for tracked files.
3. **`git log` verbosity** — Use `--oneline` for concise view, `--graph` for branch topology.
4. **`git branch` vs `git checkout`** — Branch creates but doesn't switch. Use `checkout` or `switch`.
5. **`git status` confusion** — Shows staged/unstaged/untracked. Run it often.

## How to use this companion

Each trip-up has a one-line description and a pointer to where the trip-ups notes explain the fix. If you just need the highlight, read this. If you need the story, read the full notes.

## What I'd try next

Compare side-by-side with the trip-ups notes to see if this companion works standalone.