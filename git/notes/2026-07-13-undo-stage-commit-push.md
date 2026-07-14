---
last_verified: 2026-07-13
tool_version: n/a
sources: []
---

# Undo, stage, commit, and push — what I learned

Went through the Git tutorials on the basic workflow. Here's my notes from the practice session.

## The basic workflow

I set up a test repo with a few files and ran through the cycle:
1. `git add <file>` — stage changes
2. `git commit -m "message"` — commit staged changes
3. `git push origin main` — push commits to remote

The three-step thing (working directory → staging area → local repo → remote) felt roundabout at first, but I see why it exists — the staging area lets you batch related changes into a single commit.

## Staging tricks

- `git add -p` stages parts of a file interactively. I had two unrelated changes in one file and wanted them in separate commits. `-p` let me pick which hunks to stage. Took a few tries to get the `s` (split) command right.
- `git add .` stages everything, but I accidentally staged a `.env` file that way. Learned to use `.gitignore` early.
- `git restore --staged <file>` unstages a file without losing the changes. I used this when I accidentally `git add`-ed the wrong file.

## Undoing things

This was the most confusing part — there are three different "undo" commands depending on where you are:

- **Unstage a file** (`git restore --staged <file>` or older `git reset HEAD <file>`): keeps changes in working directory but removes from staging.
- **Discard working directory changes** (`git restore <file>` or older `git checkout -- <file>`): throws away uncommitted edits. Danger — can't recover.
- **Undo a commit** (`git revert HEAD`): creates a NEW commit that reverses the previous one. Safe for shared branches. `git reset --soft HEAD~1` undoes the commit but keeps changes staged. `git reset --hard HEAD~1` nukes everything after the commit.

I messed up with `git reset --hard` on a test repo — lost a file I wanted to keep. Now I always `git stash` before trying reset commands.

## Pushing

- `git push origin main` pushes the local `main` branch to the `origin` remote.
- If the remote has commits I don't have locally, push gets rejected. `git pull --rebase` fetches and replays my commits on top of the remote's changes.
- `git push -u origin main` sets the upstream tracking — after that I can just run `git push`.

## Git commit --amend

I committed with a typo in the message. `git commit --amend -m "correct message"` fixed it. Also accidentally used it to add a forgotten file (`git add forgotten.txt && git commit --amend --no-edit`). Realized later this rewrites history — fine for local commits, bad if already pushed.

## What I'd try next

Need to practice merge conflict resolution — it's the one thing I keep avoiding. Also want to understand `git rebase` better since the tutorials make it sound powerful but dangerous.
