---
last_verified: 2026-07-27
tool_version: n/a
---

# Cross-link concept primers

> Making the foundational concept primers findable from the main map.

I noticed the three concept primers for CI/CD, containerization, and IaC are listed in `00_index/topics.md` but their links can be hard to trace from the tool sections and learning path. I cross-linked them so the map actually leads you to the foundational knowledge.

## What I did

- Added concept primer links to the Bash and Docker sections in `topics.md` so the tool-first reader can jump to the theory behind the practice.
- Updated `learning-path.md` Stage 1 to point from each primer to its companion scripts and snippets where they exist, and Stage 3 to cross-link CI/CD with its concept primer explicitly.
- The goal is simple: if you're in a tool section or on a learning-path stage, you should be able to find the matching concept primer in one click.

## What I'd refine

The remaining concept primers (observability, scripting philosophy, version control, networking, linux-cli) already have runnable companions but could also use cross-links from their relevant tool sections. I'll tackle that next.