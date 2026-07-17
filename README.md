# DevOps-Projects
> A working DevOps engineer's reference — Docker and Git notes, Dockerfiles, scripts, and source files.

![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)
![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)
![Languages](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)
![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)

> **New here?** Start at [the learning path](00_index/learning-path.md). It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for Docker and Git. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs. Right now it covers Docker and Git; more tools land as I work through them.

## What's in here

A small, growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, or config built while following a tool's quickstart and kept for later. Currently it holds Docker material — quickstart trip-ups notes, multi-stage Dockerfiles, sample apps they build, and port-mapped container scripts — plus Git material: quickstart trip-ups notes and a stage/commit/push/undo walkthrough.

## Quick links

- [Docker quickstart follow-up](docker/notes/2026-07-15-docker-quickstart-trip-ups.md) — more first-contact gotchas after the initial run-through
- [Tagged multi-stage Dockerfile](docker/dockerfiles/2026-07-16-minimal-image-tagged-nonroot.Dockerfile) — Python build pinned to a specific tag, non-root runtime
- [Run container with port map](docker/scripts/2026-07-16-run-container-port-map.sh) — run the tagged image, map a port, verify, and tear down
- [Git quickstart trip-ups](git/notes/2026-07-13-git-quickstart-trip-ups.md) — what worked and where I got stuck on first contact with Git
- [Undo, stage, commit, push](git/notes/2026-07-13-undo-stage-commit-push.md) — the working-directory → staging → commit → push cycle, plus how to undo each step

## Layout

- `docker/` — Docker material: notes, Dockerfiles, source files, and scripts.
- `git/` — Git material: first-contact notes and workflow walkthroughs.
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

| Tool | notes | dockerfiles | scripts | src | Last verified |
|------|-------|-------------|---------|-----|---------------|
| Docker | 2 | 2 | 2 | 2 | 2026-07-16 |
| Git | 4 | — | — | — | 2026-07-16 |

## Status

Working through first-contact material for Docker and Git — both have notes now, and more tools are on the way.

---
_Last updated: 2026-07-16_
