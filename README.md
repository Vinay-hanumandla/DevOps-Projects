# DevOps-Projects

> A working DevOps engineer's reference for Docker and Git — first-contact notes, runnable snippets, and configs.

> **New here?** Start at [the learning path](00_index/learning-path.md). It walks you from first contact to confidence in a sensible order, then sends you back to this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for the tools I'm picking up. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs. Right now it covers Docker and Git; more tools land as I work through them.

## What's in here

A small, growing kit of hands-on DevOps artifacts. Each entry is a dated note, snippet, or config built while following a tool's quickstart and kept for later. Currently it holds Docker material — a quickstart trip-ups note, a minimal non-root multi-stage Dockerfile, the sample app it builds, and a port-mapped container script — plus Git material: a quickstart trip-ups note and a stage/commit/push/undo walkthrough.

## Quick links

- [Git quickstart trip-ups](git/notes/2026-07-13-git-quickstart-trip-ups.md) — what worked and where I got stuck on first contact with Git
- [Undo, stage, commit, push](git/notes/2026-07-13-undo-stage-commit-push.md) — the working-directory → staging → commit → push cycle, plus how to undo each step
- [Docker quickstart trip-ups](docker/notes/2026-07-13-docker-quickstart-trip-ups.md) — what I hit following the official Docker quickstart
- [Minimal non-root Dockerfile](docker/dockerfiles/2026-07-13-minimal-nonroot-image.Dockerfile) — multi-stage Go build to a distroless, non-root runtime
- [First port-mapped container](docker/scripts/2026-07-13-first-port-mapped-container.sh) — run nginx, map a port, verify, tear down

## Layout

- `docker/` — Docker material: notes, Dockerfiles, and runnable scripts.
- `git/` — Git material: first-contact notes and workflow walkthroughs.
- `00_index/` — the map: topics, quick links, glossary, and the learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

| Tool | notes | dockerfiles | scripts | Last verified |
|------|-------|-------------|---------|---------------|
| Docker | 1 | 1 | 1 | 2026-07-13 |
| Git | 2 | — | — | 2026-07-13 |

## Status

Working through first-contact material for Docker and Git — both have notes now, and more tools are on the way.

---
_Last updated: 2026-07-14_
