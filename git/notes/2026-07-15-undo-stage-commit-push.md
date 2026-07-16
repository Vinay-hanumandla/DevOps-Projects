---
last_verified: 2026-07-15
tool_version: n/a
sources: []
---

# Undo, stage, commit, and push — what I learned

Worked through the Git tutorials on the basic workflow. Here's what I figured out.

## The basic cycle

I set up a test repo and ran through the cycle a few times:

1. `git add <file>` — stage changes
2. `git commit -m "message"` — commit staged changes
3. `git push origin main` — push to remote

The three-step flow (working dir → staging → local repo → remote) felt roundabout at first. I get it now — the staging area lets you batch related changes into one commit instead of bundling everything together.

## Staging tricks I found useful

- **`git add -p`** — stages parts of a file interactively. I had two unrelated fixes in one file and wanted separate commits. `-p` let me pick which hunks to stage. The `s` (split) command took a few tries to get right but saved me.
- **`git add .` is convenient but dangerous.** I accidentally staged a `.env` file. Now I always set up a `.gitignore` first.
- **`git restore --staged <file>`** unstages without losing changes. Used this when I `git add`-ed the wrong file.

## Undoing — the confusing part

Three different undo commands depending on where you are:

- **Unstage** (`git restore --staged <file>`): keeps changes in working directory, removes from staging.
- **Discard working changes** (`git restore <file>`): throws away uncommitted edits permanently. I lost some work this way — now I `git stash` before trying destructive commands.
- **Undo a commit** — three options depending on whether the commit is local or shared:
  - `git revert HEAD` — creates a new commit that reverses the previous one. Safe for shared branches.
  - `git reset --soft HEAD~1` — undoes the commit, keeps changes staged.
  - `git reset --hard HEAD~1` — nukes everything after the commit. I tried this on a test repo and lost a file I wanted. Learned my lesson.

## Pushing and pulling

- `git push origin main` pushes local `main` to the remote.
- If the remote has commits I don't have locally, the push gets rejected. `git pull --rebase` fetches and replays my commits on top.
- `git push -u origin main` sets upstream tracking — after that I can just run `git push`.

## `git commit --amend` — handy but dangerous

I committed with a typo in the message. `git commit --amend -m "correct message"` fixed it. I also used it to add a forgotten file: `git add forgotten.txt && git commit --amend --no-edit`. But this rewrites history — fine for local commits, bad if already pushed to a shared branch.

## What I'd try next

Merge conflict resolution is the one thing I keep avoiding. I also want to understand `git rebase` properly since everyone says it's powerful but easy to misuse.
