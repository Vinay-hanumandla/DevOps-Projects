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

A growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, config, or script built while following a tool's quickstart and kept for later. It covers Bash (primer, install notes, trip-ups guide, robust scripting patterns, strict-mode and trap docs, hello-world and safe-template scripts, companion scripts, and a directory-based system report tool), Docker (primer, quickstart trip-ups, install note, multi-stage Dockerfile, sample apps, and container scripts), Git (primer, quickstart trip-ups, undo/commit/push walkthroughs, install note, branch-merge and feature-branch rebase scripts, hooks tooling, and an interactive rebase reference), Helm (primer, install note, and first chart snippet), Kubernetes (primer, install note, and kubectl exploration scripts), Python (primer, first script, snippets), Terraform (install note, primer, and first config), and foundational concept primers under docs/concepts/ — each joined by a runnable script or snippet, plus a CI/CD + Observability notebook and a gate-before-merge reference.

## Quick links

- [Kubernetes — explore kubectl CLI](k8s/notes/2026-08-03-explore-kubectl-cli.md) — kubectl CLI exploration notes with common commands and output explanations
- [Install Minikube and run kubectl version](k8s/scripts/2026-08-03-install-minikube-and-run-kubectl-version.sh) — install Minikube, start a cluster, and verify kubectl
- [Kubernetes — quick primer](k8s/notes/0000-primer-kubernetes.md) — first-contact notes for Kubernetes concepts and kubectl basics
- [Terraform — quick primer](tf/notes/0000-primer-terraform.md) — first-contact notes for Terraform's install and version command
- [Helm — quick primer](helm/notes/0000-primer-helm.md) — first-day notes for Helm charts, templating, and package management for Kubernetes

## Layout

- `bash/` — Bash material: primer, notes, docs, and scripts.
- `docker/` — Docker material: notes, Dockerfiles, source files, and scripts.
- `docs/concepts/` — foundational primers with runnable scripts, snippets, and a notebook (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `git/` — Git material: notes, docs, scripts, and hooks tooling.
- `helm/` — Helm material: primer, install note, and chart snippet.
- `k8s/` — Kubernetes material: primer, install note, and kubectl exploration scripts.
- `python/` — Python material: primer, scripts, and snippets.
- `tf/` — Terraform material: install note, primer, and first config.
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

<details><summary>Coverage table</summary>

| Tool | notes | docs | scripts | hooks | snippets | configs | dockerfiles | src | notebooks | Last verified |
|------|-------|------|---------|-------|----------|---------|-------------|-----|-----------|---------------|
| Bash | 3 | 2 | 5 | — | 1 | — | — | — | — | 2026-07-31 |
| Docker | 4 | — | 3 | — | — | — | 1 | 2 | — | 2026-07-19 |
| Git | 12 | 2 | 3 | 1 | — | — | — | — | — | 2026-07-30 |
| Helm | 2 | — | — | — | 1 | — | — | — | — | 2026-07-31 |
| Kubernetes | 3 | — | 2 | — | — | — | — | — | — | 2026-08-03 |
| Python | 1 | — | 1 | — | 1 | — | — | — | — | 2026-07-22 |
| Terraform | 2 | — | — | — | — | 1 | — | — | — | 2026-08-01 |

Foundational concept primers (one each) live under docs/concepts/: CI/CD, containerization, infrastructure-as-code, Linux & CLI, networking, observability & monitoring, scripting, and version control. Five of the eight now have runnable scripts and five have code snippets. CI/CD additionally has a companion notes file, a gate-before-merge reference, and an observability notebook covering DORA metrics and pipeline health dashboards. Primers last verified 2026-08-01.

</details>

## Status

Currently working through Kubernetes content (k8s-004 through k8s-006) — primer, Minikube install script, and kubectl exploration notes. All eight foundational concept primers are complete and joined by runnable scripts, code snippets, and a CI/CD + Observability notebook. Bash strict-mode/trap patterns and a directory-based system report tool are the latest additions.

---
_Last updated: 2026-08-03_