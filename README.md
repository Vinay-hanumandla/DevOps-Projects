# DevOps-Projects
> A working engineer's DevOps reference for Ansible, Bash, Docker, Git, GitHub Actions, Helm, Jenkins, Kubernetes, Python, Terraform, Grafana, and Prometheus, plus the foundational concepts they rest on.

![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)
![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)
![Languages](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)
![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, configs, and project scaffolds for Ansible, Bash, Docker, Git, GitHub Actions, Helm, Jenkins, Kubernetes, Python, Terraform, and Grafana/Prometheus, plus primers for the concepts they rest on. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs.

## What's in here

A growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, config, script, or project scaffold built while working through a tool's ecosystem and kept for later. It covers Ansible, Bash, Docker, Git, GitHub Actions, Helm, Jenkins, Kubernetes, Python, Terraform, and Grafana/Prometheus, plus eight foundational concept primers under `docs/concepts/` — each joined by runnable scripts, snippets, and CI/CD + observability notebooks. Three full project scaffolds ship as copy-in-and-rename layouts: a Git-based release workflow (`git/templates/release-workflow/`), a Bash + Docker dev toolchain (`bash/templates/bash-docker-scaffold/`), and a Bash + Docker multi-container stack whose startup ordering is wired through health checks (`bash/templates/bash-docker-healthcheck-scaffold/`).

## Quick links

- [Observability exercises — round two](docs/concepts/observability-monitoring-concepts/scripts/2026-08-20-observability-exercises.sh) — reading raw logs and latency the way a scraper would, with no dashboard in front of you
- [Deploy checklist as data](docs/concepts/scripting-automation-philosophy/snippets/2026-08-20-scripting-deploy-checklist.py) — encoding a known deploy sequence as a list and looping over it instead of copy-pasted `if` blocks
- [Release-readiness commit inventory](docs/concepts/version-control-git-workflow/snippets/2026-08-20-release-branch-commit-check.py) — asking git which commits are on `main` but not yet on the release branch
- [Dev values override](helm/configs/2026-08-20-dev-values.yaml) — the same chart tuned for a dev release
- [Prod values override](helm/configs/2026-08-20-prod-values.yaml) — the production counterpart, replica count and all

## Layout

- `ansible/` — Ansible material: primer, install notes, and first playbook config.
- `bash/` — Bash material: primer, notes, docs, scripts, notebooks, a strict-mode runner image, and two Docker project scaffolds (toolchain + health-check stack).
- `docker/` — Docker material: notes, Dockerfiles, source files, scripts, and a multi-service Compose manifest.
- `docs/concepts/` — foundational primers with runnable scripts, snippets, and notebooks (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `gha/` — GitHub Actions material: primer, install note, and workflow configs.
- `git/` — Git material: notes, docs, scripts, hooks tooling, a release-workflow scaffold, and a pipeline-trigger manifest.
- `grafana/` — Grafana material: primer and install notes, a first dashboard config, and an API snippet.
- `helm/` — Helm material: primer, install notes, chart snippet, per-environment values overrides, and a chart template.
- `jenkins/` — Jenkins material: primer, install notes, and a first pipeline snippet.
- `k8s/` — Kubernetes material: primer, install note, kubectl exploration, manifests, and a resource-listing snippet.
- `prom/` — Prometheus material: primer and install notes, a first scrape target config, and a PromQL snippet.
- `python/` — Python material: primer, docs, scripts, and snippets.
- `repo-doc/` — notes on keeping the repository's own docs and coverage tables in sync.
- `tf/` — Terraform material: install note, primer, configs, docs, and scripts.
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

<details><summary>Coverage table</summary>

| Tool | notes | docs | scripts | snippets | configs | templates | manifests | dockerfiles | src | hooks | notebooks | Last verified |
|------|-------|------|---------|----------|---------|-----------|-----------|-------------|-----|-------|-----------|---------------|
| Ansible | 2 | — | — | — | 1 | — | — | — | — | — | — | 2026-08-10 |
| Bash | 3 | 4 | 6 | 1 | — | 23 | — | 1 | — | — | 1 | 2026-08-17 |
| Docker | 5 | — | 3 | — | — | — | 1 | 1 | 2 | — | — | 2026-08-17 |
| Git | 12 | 6 | 6 | — | — | 6 | 1 | — | — | 1 | — | 2026-08-19 |
| GitHub Actions | 3 | 1 | — | — | 2 | — | — | — | — | — | — | 2026-08-06 |
| Grafana | 2 | — | — | 1 | 1 | — | — | — | — | — | — | 2026-08-19 |
| Helm | 5 | 1 | — | 1 | 4 | — | 1 | — | — | — | — | 2026-08-20 |
| Jenkins | 2 | — | — | 1 | — | — | — | — | — | — | — | 2026-08-11 |
| Kubernetes | 4 | 1 | 2 | 1 | — | — | 1 | — | — | — | — | 2026-08-19 |
| Prometheus | 2 | — | — | 1 | 1 | — | — | — | — | — | — | 2026-08-19 |
| Python | 2 | 1 | 2 | 1 | — | — | — | — | — | — | — | 2026-08-04 |
| Terraform | 3 | 2 | 1 | — | 3 | — | — | — | — | — | — | 2026-08-11 |
| Repo docs | — | 1 | — | — | — | — | — | — | — | — | — | 2026-08-10 |
| Concepts | 3 | 20 | 18 | 11 | — | — | — | — | — | — | 2 | 2026-08-20 |

</details>

## Status

All eight concept primers are complete with runnable companions, and three project scaffolds are ready to copy in. The kit covers 12 tools across configuration management, containerization, CI/CD, infrastructure as code, and observability.

---
_Last updated: 2026-08-21_
