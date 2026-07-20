---
last_verified: 2026-07-20
tool_version: n/a
sources: []
---

# Git — quick primer

> First-day notes for someone who's never used Git. Personal voice, plain language.

## What is it?

Git is a version control system. It's like a save-point system for your code and documents. Every time you make a change, you can capture a snapshot of the entire project. If something breaks later, you can rewind to any previous snapshot.

I think of it like the "Track Changes" feature in a word processor, but for every file in a project at once. It doesn't live in the cloud by default — it keeps the full history right there in a hidden `.git` folder inside your project. That means you can work offline and still have access to the complete history.

## What does it do?

It tracks changes to files over time. When I save a change, Git records who made it, when, and what changed. I can compare any two snapshots, branch off to experiment without touching the main line of work, and merge experiments back in when they're ready.

It also lets me push the history to a remote server (like GitHub or GitLab) so other people can pull my changes and I can pull theirs. Git handles merging so two people can work on the same file and combine their work automatically, or flag a conflict when both edited the same lines.

## Why does it exist?

Before version control, people kept copies of files with names like `project_final_v2_REALLY_FINAL.doc`. Collaboration meant emailing zip files back and forth. When two people edited the same file, merging meant manual copy-pasting.

Git solves this by treating history as a first-class citizen. Every contributor gets the full history locally, so merges can be automated and conflicts are explicit. Instead of passing zip files around, everyone pulls and pushes changes through a shared server.

## Key terminology

- **Repository** — The folder Git is tracking, plus the hidden `.git` database that stores all history.
- **Commit** — A single snapshot in time. Think of it as a labeled checkpoint with a message explaining what changed.
- **Branch** — A parallel line of development. I can spin up a branch to try a feature without disturbing the main branch.
- **Working tree** — The actual files I see and edit on disk, as opposed to the committed snapshots in the `.git` folder.
- **Staging area** — A middle ground where I assemble the next commit. Files go here before they're captured as a snapshot.
- **Clone** — A full copy of a remote repository on my machine, including its entire history.
- **Remote** — A named pointer to another copy of the repository, usually hosted on a server like GitHub.
- **HEAD** — A pointer to my current position in the commit history, usually the tip of the current branch.

## A tiny example

```bash
git init my-project
cd my-project
echo "hello world" > readme.txt
git add readme.txt
git commit -m "first commit"
git status
```

This creates a new Git repository, adds a file, records the first commit, and checks that the working tree is clean.

## What I'll cover next

Next I'll write down how I installed Git on my machine and set up my name and email so commits know who made them. Then I'll walk through the first repo lifecycle: init, add, commit, and status.
