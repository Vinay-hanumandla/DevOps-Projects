---
last_verified: 2026-07-19
tool_version: n/a
sources: []
---

# Version Control & Git Workflow — quick primer

> First-day notes on Version Control & Git Workflow. What it is, why it matters, and the key ideas to know.

## What is it?

Version control is a system that records every change to your files over time so you can revisit, compare, and undo them later. Git is the most widely used version-control tool; a *Git workflow* is the agreed set of habits a team uses on top of Git — how branches are named, when code is merged, how reviews happen.

It's like a track-changes history for your whole project, but instead of one big document it tracks an entire codebase, and instead of one author everyone can collaborate without overwriting each other.

## Why does it matter for devops?

DevOps lives and dies on change: shipping features, rolling back bad ones, and keeping infrastructure in sync. Without version control, every change is a gamble — there is no record, no undo, and no way to review what someone did.

Git gives you a single source of truth and a safety net. When you store configuration, scripts, and application code in Git, you can see who changed what and when, roll back a broken deploy, and let many people work on the same project at once without chaos.

## Key terminology

- **Repository (repo)** — the folder Git tracks, with its full history. Example: the `DevOps-Projects` folder is a Git repo.
- **Commit** — a saved snapshot of changes with a message. Example: `git commit -m "fix: correct port mapping"`.
- **Branch** — a parallel line of development. Example: `feature/login` keeps new work away from the stable `main` branch.
- **Merge** — combining changes from one branch into another. Example: merging `feature/login` into `main` once it's reviewed.
- **Clone** — a local copy of a remote repo. Example: `git clone <url>` to get the code on your laptop.
- **Remote** — a hosted copy of the repo (often `origin`). Example: pushing to `origin` shares your commits with the team.
- **Pull request (PR)** — a request to merge your branch, with a review step. Example: open a PR so a teammate signs off before merge.
- **Diff** — the line-by-line view of what changed. Example: `git diff` shows uncommitted edits.

## A concrete example

```bash
git init
echo "hello" > README.md
git add README.md
git commit -m "first commit"
```

These four commands take a fresh folder, add a file, and save the first snapshot — the smallest possible Git workflow.

## How this connects to what's next

Version control underpins everything else in DevOps: CI/CD pipelines read from Git, Infrastructure as Code lives in Git, and collaboration depends on branches and reviews. Learning the workflow here makes every later tool make sense.
