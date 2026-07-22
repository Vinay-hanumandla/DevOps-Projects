# DevOps-Projects
> A working engineer's DevOps reference — Bash, Docker, and Git notes and scripts, plus primers and runnable companions for the core DevOps concepts.

![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)
![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)
![Languages](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)
![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)

> **New here?** Start at [the learning path](00_index/learning-path.md). It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and the foundational concepts behind Bash, Docker, and Git. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs. Right now it covers Bash, Docker, and Git, plus primers and hands-on companions for the concepts they rest on; more tools land as I work through them.

## What's in here

A small, growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, or config built while following a tool's quickstart and kept for later. It holds Bash material (primer, install notes, hello-world script), Docker material (primer, quickstart trip-ups notes, install note, multi-stage Dockerfile, sample apps, and container scripts), Git material (primer, quickstart trip-ups notes, undo/commit/push walkthroughs, install note, and branch-merge-revert script), and a set of foundational concept primers under `docs/concepts/` — each now joined by a runnable script or snippet that puts the ideas into practice.

## Quick links

- [Container manifest parser](docs/concepts/containerization-concepts/snippets/2026-07-21-image-manifest-parser.py) — parse container image manifests and extract layer metadata
- [IaC idempotency check](docs/concepts/infrastructure-as-code-principles/scripts/2026-07-21-iac-idempotency-check.sh) — verify that a provisioning step produces the same result on repeat runs
- [Declarative state diff](docs/concepts/infrastructure-as-code-principles/snippets/2026-07-21-declarative-state-diff.py) — compute the diff between a declared config and live state
- [Artifact promotion](docs/concepts/ci-cd-pipeline-concepts/snippets/2026-07-20-artifact-promotion.py) — promote a build artifact across pipeline stages with an audit trail
- [Container lifecycle inspection](docs/concepts/containerization-concepts/scripts/2026-07-20-container-lifecycle-inspection.sh) — inspect running and stopped containers using the Docker API

## Layout

- `bash/` — Bash material: primer, notes, and scripts.
- `docker/` — Docker material: notes, Dockerfiles, source files, and scripts.
- `git/` — Git material: notes and workflow scripts.
- `docs/concepts/` — foundational primers with runnable scripts and snippets (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

| Tool | notes | primer | scripts | dockerfiles | src | Last verified |
|------|-------|--------|---------|-------------|-----|---------------|
| Bash | 1 | 1 | 1 | — | — | 2026-07-18 |
| Docker | 3 | 1 | 3 | 1 | 2 | 2026-07-19 |
| Git | 5 | 1 | 2 | — | — | 2026-07-20 |

Foundational concept primers (one each) live under `docs/concepts/`: CI/CD, containerization, infrastructure-as-code, Linux & CLI, networking, observability & monitoring, scripting & automation, and version control — all last verified 2026-07-21. Three of the eight now also have runnable scripts and three have code snippets.

## Status

Working through first-contact material for Bash, Docker, and Git, and laying down primers for the DevOps concepts underneath them. All eight foundational concept primers are in place; CI/CD, containerization, and IaC have gained runnable scripts and snippets. More tool-specific depth is on the way.

---
_Last updated: 2026-07-21_
