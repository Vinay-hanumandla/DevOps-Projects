# DevOps-Projects
> A working engineer's DevOps reference for Bash, Docker, Git, Python, Terraform, and the foundational concepts they rest on.

![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)
![License](https://img.shields.io/github/license/Vinay-hanumandla/DevOps-Projects)
![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)
![Languages](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)
![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)

> **New here?** Start at [the learning path](00_index/learning-path.md). It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for Bash, Docker, Git, Python, and Terraform, plus primers for the concepts they rest on. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs.

## What's in here

A growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, config, or script built while following a tool's quickstart and kept for later. It covers Bash (primer, install notes, trip-ups guide, robust scripting patterns, strict-mode and trap docs, hello-world and safe-template scripts, companion scripts, and a directory-based system report tool), Docker (primer, quickstart trip-ups, install note, multi-stage Dockerfile, sample apps, and container scripts), Git (primer, quickstart trip-ups, undo/commit/push walkthroughs, install note, branch-merge and feature-branch rebase scripts, hooks tooling, and an interactive rebase reference), Python (primer, first script, snippets), Terraform (install note and first config), and foundational concept primers under docs/concepts/ — each joined by a runnable script or snippet, plus a CI/CD + Observability notebook and a gate-before-merge reference.

## Quick links

- [Strict mode and trap patterns](bash/docs/strict-mode-trap-patterns.md) — notes on integrating set -euo pipefail and trap-based cleanup into a Bash script workflow
- [System report tool](bash/scripts/system-report-tool.sh) — directory-based system report tool with text and JSON output
- [Gate-before-merge with branch protection](docs/concepts/ci-cd-pipeline-concepts/gate-before-merge-branch-protection.md) — how branch protection rules and pipeline gates combine to block broken merges
- [Pipeline metrics and health dashboards](docs/concepts/ci-cd-pipeline-concepts/notebooks/pipeline-metrics-and-health-dashboards.ipynb) — CI/CD observability notebook with DORA metrics and health scoring
- [Interactive rebase vs merge commit](git/docs/interactive-rebase-vs-merge-commit.md) — reference guide comparing the two core Git collaboration strategies

## Layout

- `bash/` — Bash material: primer, notes, docs, and scripts.
- `docker/` — Docker material: notes, Dockerfiles, source files, and scripts.
- `git/` — Git material: notes, docs, scripts, and hooks tooling.
- `python/` — Python material: primer, scripts, and snippets.
- `tf/` — Terraform material: install note and first config.
- `docs/concepts/` — foundational primers with runnable scripts, snippets, and a notebook (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

| Tool | notes | docs | scripts | hooks | snippets | configs | dockerfiles | src | Last verified |
|------|-------|------|---------|-------|----------|---------|-------------|-----|---------------|
| Bash | 3 | 2 | 5 | — | — | — | — | — | 2026-07-30 |
| Docker | 4 | — | 3 | — | — | — | 1 | 2 | 2026-07-19 |
| Git | 12 | 2 | 3 | 1 | — | — | — | — | 2026-07-30 |
| Python | 1 | — | 1 | — | 1 | — | — | — | 2026-07-22 |
| Terraform | 1 | — | — | — | — | 1 | — | — | 2026-07-26 |

Foundational concept primers (one each) live under docs/concepts/: CI/CD, containerization, infrastructure-as-code, Linux & CLI, networking, observability & monitoring, scripting, and version control. Five of the eight now have runnable scripts and five have code snippets. CI/CD additionally has a companion notes file, a gate-before-merge reference, and an observability notebook covering DORA metrics and pipeline health dashboards. Primers last verified 2026-07-30.

## Status

Expanding Git tool content with workflow scripts and hooks tooling; working through companion notes for the foundational concepts. All eight foundational concept primers are in place and now joined by runnable scripts, code snippets, and a CI/CD + Observability notebook. Bash strict-mode/trap patterns and a directory-based system report tool are the latest additions.

---
_Last updated: 2026-07-31_
