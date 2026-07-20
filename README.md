# DevOps-Projects
> A working DevOps engineer's reference — Bash, Docker, and Git notes and scripts, plus first-day primers on the core DevOps concepts.

![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)
![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)
![Languages](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)
![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and the foundational concepts behind Bash, Docker, and Git. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs. Right now it covers Bash, Docker, and Git, plus primers on the concepts they rest on; more tools land as I work through them.

## What's in here

A small, growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, or config built while following a tool's quickstart and kept for later. Currently it holds Bash material (primer, install notes, hello-world script), Docker material (primer, quickstart trip-ups notes, a multi-stage Dockerfile, sample apps, and container scripts), Git material (primer, quickstart trip-ups notes, install notes, and a first-repo lifecycle script), and a set of foundational concept primers under `docs/concepts/` covering the ideas the tools build on.

## Quick links

- [Git primer](git/notes/0000-primer-git.md) — what Git is, key terminology, and a tiny example
- [Install Git and first repo](git/notes/2026-07-20-install-git.md) — install check, first repo, and commit/push walkthrough
- [First-repo lifecycle script](git/scripts/2026-07-20-first-repo.sh) — init, add, commit, and push in one go
- [Docker primer](docker/notes/0000-primer-docker.md) — what Docker is, key terminology, and a tiny example
- [Install Docker and verify daemon](docker/notes/2026-07-19-install-docker.md) — install check, daemon verify, and hello-world container

## Layout

- `bash/` — Bash material: primer, notes, and scripts.
- `docker/` — Docker material: primer, notes, Dockerfiles, source files, and scripts.
- `git/` — Git material: primer, first-contact notes, install notes, and workflow walkthroughs.
- `docs/concepts/` — foundational primers on the concepts the tools build on (Linux, networking, containerization, CI/CD, IaC, observability, scripting, and version control).
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

| Tool | notes | primer | scripts | dockerfiles | src | Last verified |
|------|-------|--------|---------|-------------|-----|---------------|
| Bash | 2 | 1 | 1 | — | — | 2026-07-18 |
| Docker | 4 | — | 3 | 1 | 2 | 2026-07-19 |
| Git | 6 | 1 | 1 | — | — | 2026-07-20 |

Foundational concept primers (one each) live under `docs/concepts/`: CI/CD, containerization, infrastructure-as-code, Linux & CLI, networking, observability & monitoring, scripting & automation, and version control — all last verified 2026-07-19.

## Status

Working through first-contact material for Bash, Docker, and Git, and laying down primers for the DevOps concepts underneath them — all eight foundational concept primers are now in place, and a CI/CD stage-simulation script gives the pipeline concepts a runnable companion. Git now has a primer, install notes, and a first-repo lifecycle script. More tool-specific depth is on the way.

---
_Last updated: 2026-07-21_
