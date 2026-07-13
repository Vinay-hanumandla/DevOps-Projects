---
last_verified: 2026-07-13
tool_version: n/a
sources: []
---

# Git quickstart — what tripped me up today

Followed the official Git quickstart. Here's what worked and where I got stuck.

## What went fine

Installing Git and running `git --version` was instant. `git config --global user.name` and `user.email` made sense — the commit needs an author stamp. `git init` created a `.git` folder in my test directory. `git add README.md` staged the file, and `git commit -m "first commit"` created my first commit. Checking `git log` showed it with the message and my name.

## Where I got tripped up

**1. `git add` doesn't add a file to the repo — it stages it.** I ran `git add file.txt` and thought "great, it's committed." Then I edited the file and ran `git status` — it showed the file as modified. I had to re-`git add` and then `git commit`. The staging area concept took a few tries to stick.

**2. `git commit -m` without the staging step.** I edited a tracked file and ran `git commit -m "update"` expecting it to auto-stage. Git said "nothing to commit." The `-a` flag (`git commit -am "update"`) stages tracked changes and commits in one step, but only for files Git already knows about.

**3. `git log` shows a lot.** On a fresh repo with one file it's fine, but `git log --oneline` is much more readable — one line per commit. I also learned `git log --oneline --graph` shows the branch topology, which was useful later.

**4. Messing up `git branch` vs `git checkout`.** `git branch new-feature` creates a branch but stays on `master`. I thought I'd switched. `git checkout new-feature` actually switches. Later I found `git switch new-feature` does the same thing and `git checkout` does too much.

**5. `git status` is my friend.** Any time I was confused about what state things were in, `git status` laid it out clearly — which branch, staged vs unstaged, untracked files. I started running it before and after every command.

## What I'd try next

I want to work through branching and merging properly — the quickstart only touches the surface. Also need to practice undoing things (`git reset`, `git restore`, `git revert`) because I'm going to mess up sooner or later.
