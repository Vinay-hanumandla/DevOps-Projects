---
last_verified: 2026-09-08
tool_version: n/a
sources: []
---

# How the repo documentation tooling works

> First-day notes on the docs system in this repo. What I see when I look at the file tree.

## What I see

The repo has a coverage table in `README.md` that tracks how many files each tool folder contains, broken down by category (notes, scripts, docs, configs, etc.). There's also a per-tool index like `git/docs/2026-08-10-git-index.md` that lists every doc in that tool's folder with a one-line description.

## How the index works

Each tool folder follows the same subdirectory pattern: `notes/`, `scripts/`, `snippets/`, `docs/`, `configs/`, `manifests/`, `dockerfiles/`, `notebooks/`, `templates/`, `hooks/`. The index doc just walks that tree and writes down what's there. When I add a new file, the count in README drifts out of sync until someone updates the table.

## What I'd automate

I want a small Bash script that walks the repo, counts files per tool/subdir, and rewrites the README coverage table automatically. Right now it's manual, and every time I add a file I have to update two places.
