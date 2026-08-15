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

A growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, config, script, or project scaffold built while working through a tool's ecosystem and kept for later. It covers Ansible, Bash, Docker, Git, GitHub Actions, Helm, Jenkins, Kubernetes, Python, Terraform, and Grafana/Prometheus, plus eight foundational concept primers under `docs/concepts/` — each joined by runnable scripts, snippets, and CI/CD + observability notebooks. Two recent additions are full project scaffolds: a Git-based release workflow (`git/templates/release-workflow/`) and a Bash + Docker toolchain setup (`bash/templates/bash-docker-scaffold/`), both copy-in-and-rename layouts.

## Quick links

- [Monitoring containerized apps in production](docs/concepts/containerization-concepts/monitoring-containerized-apps-in-production.md) — instrumenting containers with metrics, logs, and traces so they're no longer black boxes
- [Integrating Bash with Git](bash/docs/integrating-bash-with-git.md) — fail-fast, re-runnable patterns for release scripts that touch git
- [Helm first chart template](helm/manifests/2026-08-14-first-chart-template.yaml) — a minimal trimmed Deployment template with `.Values.*` placeholders
- [Git PR helper](git/scripts/git-pr-helper.sh) — reusable branch-create, delete, clean-check, and PR-open helper with safety guards
- [Release workflow scaffold README](git/templates/release-workflow/README.md) — copy-in layout for tag-driven releases with make targets and shell helpers

## Layout

- `ansible/` — Ansible material: primer, install notes, and first playbook config.
- `bash/` — Bash material: primer, notes, docs, scripts, notebooks, and a Docker-toolchain project scaffold.
- `docker/` — Docker material: notes, Dockerfiles, source files, and scripts.
- `docs/concepts/` — foundational primers with runnable scripts, snippets, and notebooks (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `gha/` — GitHub Actions material: primer, install note, and workflow configs.
- `git/` — Git material: notes, docs, scripts, hooks tooling, and a release-workflow scaffold.
- `grafana/` — Grafana material: primer and install notes, plus a first dashboard config.
- `helm/` — Helm material: primer, install note, chart snippet, values override config, and manifests.
- `jenkins/` — Jenkins material: primer, install notes, and a first pipeline snippet.
- `k8s/` — Kubernetes material: primer, install note, kubectl exploration, and manifests.
- `prom/` — Prometheus material: primer and install notes, plus a first scrape target config.
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
| Bash | 3 | 4 | 6 | 1 | — | 9 | — | — | — | — | 1 | 2026-08-14 |
| Docker | 5 | — | 3 | — | — | — | — | 1 | 2 | — | — | 2026-08-06 |
| Git | 12 | 4 | 5 | — | — | 6 | — | — | — | 1 | — | 2026-08-14 |
| GitHub Actions | 3 | 1 | — | — | 2 | — | — | — | — | — | — | 2026-08-06 |
| Grafana | 2 | — | — | — | 1 | — | — | — | — | — | — | 2026-08-06 |
| Helm | 3 | 1 | — | 1 | 1 | — | 1 | — | — | — | — | 2026-08-10 |
| Jenkins | 2 | — | — | 1 | — | — | — | — | — | — | — | 2026-08-11 |
| Kubernetes | 4 | 1 | 2 | — | — | — | 1 | — | — | — | — | 2026-08-04 |
| Prometheus | 2 | — | — | — | 1 | — | — | — | — | — | — | 2026-08-07 |
| Python | 2 | 1 | 2 | 1 | — | — | — | — | — | — | — | 2026-08-04 |
| Terraform | 3 | 2 | 1 | — | 3 | — | — | — | — | — | — | 2026-08-11 |
| Concepts | 3 | 18 | 15 | 9 | — | — | — | — | — | — | 2 | 2026-08-14 |

</details>

## Status

Two project scaffolds landed this cycle: a tag-driven Git release workflow and a Bash + Docker toolchain layout, both copy-in-and-rename with make targets and self-contained shell helpers. A container observability guide, a Bash+Git integration doc, and a Helm chart manifest are the other new additions. The rest stays as it was: all eight concept primers complete with runnable companions, and Ansible, Grafana, Prometheus, GitHub Actions, Jenkins, Helm, and Terraform holding landing pages and first configs.

---
_Last updated: 2026-08-14_
