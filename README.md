# DevOps-Projects
> A working engineer's DevOps reference for Bash, Docker, Git, Helm, Kubernetes, Python, and Terraform, plus the foundational concepts they rest on.

![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)
![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)
![Languages](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)
![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for Bash, Docker, Git, Helm, Kubernetes, Python, and Terraform, plus primers for the concepts they rest on. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs.

## What's in here

A growing collection of hands-on DevOps artifacts — notes, scripts, snippets, configs, and Dockerfiles — built while following each tool's quickstart and kept for later. The kit covers seven tools and eight foundational concept areas, each joined by runnable companions. It is a reference shelf, not a curriculum.

## Quick links

- [Branch strategy and pipeline triggers](docs/concepts/version-control-git-workflow/branch-strategy-and-pipeline-triggers.md) — notes on branch strategies and how pipeline triggers connect to Git workflows
- [Analyzing Git commit history for deployment correlation](docs/concepts/version-control-git-workflow/snippets/analyzing-git-commit-history-for-deployment-correlation.py) — Python snippet correlating Git commit history with deployment events
- [Combining networking with containerization](docs/concepts/networking-fundamentals/combining-networking-with-containerization.md) — notes on how networking and containerization intersect
- [Network interface and routing inspection](docs/concepts/networking-fundamentals/scripts/2026-08-05-network-interface-and-routing-inspection.sh) — script to inspect network interfaces and routing tables
- [Python modules, packages, and imports](python/docs/2026-08-04-python-modules-packages-imports.md) — notes on Python module mechanics and import behavior

## Layout

- `bash/` — Bash material: primer, notes, docs, and scripts.
- `docker/` — Docker material: notes, Dockerfiles, source files, and scripts.
- `docs/concepts/` — foundational primers with runnable scripts, snippets, and a notebook (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `git/` — Git material: notes, docs, scripts, and hooks tooling.
- `helm/` — Helm material: primer, install note, and chart snippet.
- `k8s/` — Kubernetes material: primer, install note, and kubectl exploration scripts.
- `python/` — Python material: primer, scripts, snippets, and docs.
- `tf/` — Terraform material: install note, primer, and first config.
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

<details><summary>Coverage table</summary>

| Tool | notes | docs | scripts | snippets | configs | dockerfiles | src | hooks | manifests | notebooks | Last verified |
|------|-------|------|---------|----------|---------|-------------|-----|-------|-----------|-----------|---------------|
| Bash | 3 | 2 | 5 | 1 | — | — | — | — | — | — | 2026-07-30 |
| Docker | 4 | — | 3 | — | — | 1 | 2 | — | — | — | 2026-07-19 |
| Git | 12 | 2 | 3 | — | — | — | — | 1 | — | — | 2026-07-30 |
| Helm | 2 | — | — | 1 | — | — | — | — | — | — | 2026-07-31 |
| Kubernetes | 4 | 1 | 2 | — | — | — | — | — | 1 | — | 2026-08-04 |
| Python | 2 | 1 | 2 | 1 | — | — | — | — | — | — | 2026-08-04 |
| Terraform | 2 | — | — | — | 1 | — | — | — | — | — | 2026-08-01 |
| Concepts | 8 | 8 | 5 | 5 | — | — | — | — | — | 2 | 2026-08-05 |

</details>

## Status

Currently working through foundational concept docs (branch strategy, container networking, Python modules/packages) and the companion scripts and snippets that reinforce them. All eight foundational concept primers are complete and joined by runnable scripts, code snippets, and a CI/CD + Observability notebook.

---
_Last updated: 2026-08-05_