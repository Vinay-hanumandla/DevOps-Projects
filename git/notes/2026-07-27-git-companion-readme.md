---
last_verified: 2026-07-27
tool_version: n/a
sources: []
---

# Companion readme.txt for the Git primer

Following the Git primer (0000-primer-git.md), I created a `readme.txt` file alongside it to give newcomers a quick landing spot. The primer covers what Git is and the tiny example — `git init`, `git add`, `git commit` — but when I started sharing the primer with teammates, I kept getting the same follow-up questions. A companion readme.txt lets me capture those answers in one place without cluttering the primer itself.

## What I put in the readme.txt

I copied the primer's tiny example at the top so someone can paste it directly and see results. Below that I added a short "Why this file exists" paragraph that points back to the primer and explains that this readme.txt is a companion, not a replacement. I also listed the key terminology from the primer (repository, commit, branch, working tree, staging area) with one-line descriptions so beginners can reference them without scrolling.

## What tripped me up

I kept overthinking the readme.txt format. Should it be Markdown or plain text? Since the primer uses Markdown, I went with `.txt` to signal that this companion is meant to be simple and lightweight — a plain-text anchor. The tricky part was keeping it short. I had to resist the urge to add more detail and instead point readers back to the primer for deeper explanations.

## What I'd try next

I want to test whether having this readme.txt alongside the primer actually reduces the number of follow-up questions I get. I'll also track how long it takes someone to go from reading the readme.txt to running the primer's tiny example on their own machine.