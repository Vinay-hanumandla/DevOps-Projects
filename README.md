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

A growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, config, or script built while following a tool's quickstart and kept for later. It covers Bash, Docker, Git, Helm, Kubernetes, Python, and Terraform, plus eight foundational concept primers under docs/concepts/ — each joined by runnable scripts, snippets, and a CI/CD + Observability notebook.

## Quick links

- [Python — modules, packages, and imports](python/docs/2026-08-04-python-modules-packages-imports.md) — Python module and package mechanics, import resolution, and common pitfalls
- [Python — functions and modules](python/notes/2026-08-04-python-functions-modules.md) — function definitions, module organisation, and import patterns
- [Minimal file processing script](python/scripts/2026-08-04-minimal-file-processing.py) — read, process, and write files with Python
- [Inspecting pods, services, and events](k8s/docs/2026-08-04-inspecting-pods-services-events.md) — kubectl commands for inspecting cluster resources and their events
- [Minimal deployment and service manifest](k8s/manifests/2026-08-04-minimal-deployment-and-service.yaml) — a minimal Kubernetes Deployment and Service YAML

## Layout

- `bash/` — Bash material: primer, notes, docs, and scripts.
- `docker/` — Docker material: notes, Dockerfiles, source files, and scripts.
- `docs/concepts/` — foundational primers with runnable scripts, snippets, and a notebook (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `git/` — Git material: notes, docs, scripts, and hooks tooling.
- `helm/` — Helm material: primer, install note, and chart snippet.
- `k8s/` — Kubernetes material: primer, install note, kubectl exploration, and manifests.
- `python/` — Python material: primer, docs, scripts, and snippets.
- `tf/` — Terraform material: install note, primer, and first config.
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

<details><summary>Coverage table</summary>

| Tool | notes | docs | scripts | snippets | configs | manifests | dockerfiles | src | notebooks | Last verified |
|------|-------|------|---------|----------|---------|-----------|-------------|-----|-----------|---------------|
| Bash | 3 | 2 | 5 | 1 | — | — | — | — | — | 2026-07-30 |
| Docker | 4 | — | 3 | — | — | — | 1 | 2 | — | 2026-07-19 |
| Git | 12 | 2 | 3 | — | — | — | — | — | — | 2026-07-30 |
| Helm | 2 | — | — | 1 | — | — | — | — | — | 2026-07-31 |
| Kubernetes | 4 | 1 | 2 | — | — | 1 | — | — | — | 2026-08-04 |
| Python | 2 | 1 | 2 | 1 | — | — | — | — | — | 2026-08-04 |
| Terraform | 2 | — | — | — | 1 | — | — | — | — | 2026-08-01 |
| Concepts | 3 | 4 | 8 | 5 | — | — | — | — | 2 | 2026-08-01 |

</details>

## Status

Currently working through Python (modules, packages, functions, and file processing) and Kubernetes (pod/service/event inspection and deployment manifests). All eight foundational concept primers are complete and joined by runnable scripts, code snippets, and a CI/CD + Observability notebook. Bash strict-mode/trap patterns and a directory-based system report tool are the latest additions.

---
_Last updated: 2026-08-05_