---
last_verified: 2026-07-15
tool_version: n/a
sources: []
---

# Git quickstart — what tripped me up today

Followed the official Git quickstart. Here's what worked and where I got stuck.

## What went fine

Installing Git and running `git --version` was instant — no surprises there. `git config --global user.name` and `user.email` made sense, the commit needs an author stamp. `git init` created a `.git` folder. `git add README.md` staged the file, `git commit -m "first commit"` created my first commit, and `git log` showed it. So far so good.

## Where I got tripped up

**1. The staging area is an extra step I kept forgetting.** I'd edit a file and run `git commit -m "message"` expecting it to pick up the change. Nope — "nothing to commit." You have to `git add` first, or use `git commit -am` if the file is already tracked. The three-tier model (working dir → index → repo) took several reps to stick.

**2. `git add` doesn't mean "saved."** I staged a file, edited it again, ran `git status`, and saw it listed as both staged (old version) and modified (new version). Had to re-`git add` before committing if I wanted the new changes included. Felt redundant until I realized you can stage each change deliberately.

**3. `git log` is verbose by default.** On a fresh repo with one commit it's fine, but `git log --oneline` is way more practical. `git log --oneline --graph` shows branch topology too — I started using that as my default.

**4. `git branch` creates but doesn't switch.** I ran `git branch feature-x`, thought I was on the new branch, and committed to `master` instead. `git checkout feature-x` or `git switch feature-x` actually switches. The `checkout` command does too many things — I'm trying to use `switch` and `restore` instead.

**5. `git status` became my panic button.** Every time I got confused — wrong branch, staged when I meant to commit, forgot what I was doing — `git status` laid it all out. I started running it before and after every command.

## What I'd try next

Branching and merging is the thing I'm avoiding. The quickstart only touches the surface. I also want to practice undoing things properly — `git reset`, `git restore`, `git revert` — because I know I'll mess up.
