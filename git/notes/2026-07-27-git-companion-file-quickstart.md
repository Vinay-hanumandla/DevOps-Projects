---
last_verified: 2026-07-27
tool_version: n/a
sources: []
---

# Companion file.txt for the Git quickstart trip-ups notes

The Git quickstart trip-ups notes (2026-07-13-git-quickstart-trip-ups.md) describe five things that tripped me up. I created a companion `file.txt` that distils each trip-up into a single concrete command or action — the smallest possible takeaway someone can try immediately. The file.txt format keeps things minimal: one line per point, no paragraphs, no narrative.

## How I structured file.txt

Each trip-up got two lines: the problem statement and the fix. For example, the first trip-up about `git add` not meaning "saved" became:

```
Problem: git add stages a file, it does not commit it.
Fix: Run git commit after git add, or use git commit -am for tracked files.
```

I kept the same five trip-ups from the main notes — staging, `-a` flag, `git log` verbosity, `git branch` vs `git checkout`, and `git status` — and wrote one fix line for each.

## What I found

Writing file.txt forced me to boil each trip-down to its essence. Some fixes I thought were obvious needed more explanation when I tried to write them in one line. The `git branch` vs `git checkout` trip-up, for instance, actually needs two lines just to name the two commands — I had to add a third line pointing to `git switch` as the cleaner alternative.

## What I'd try next

I want to see if a reader can use file.txt on its own without the trip-ups notes. If the one-line-per-trip-up format is enough to unstick someone, it's a useful companion. If not, I'll expand the fix lines with a sentence or two of context.