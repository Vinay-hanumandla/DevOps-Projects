# DevOps-Projects
> A working engineer's DevOps reference for Ansible, Bash, Docker, Git, GitHub Actions, Helm, Jenkins, Kubernetes, Python, Terraform, Grafana, and Prometheus, plus the foundational concepts they rest on.

![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)
![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)
![Languages](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)
![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for Ansible, Bash, Docker, Git, GitHub Actions, Helm, Jenkins, Kubernetes, Python, Terraform, and Grafana/Prometheus, plus primers for the concepts they rest on. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs.

## What's in here

A growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, config, or script built while following a tool's quickstart and kept for later. It covers Ansible, Bash, Docker, Git, GitHub Actions, Helm, Jenkins, Kubernetes, Python, Terraform, and Grafana/Prometheus, plus eight foundational concept primers under `docs/concepts/` — each joined by runnable scripts, snippets, and a CI/CD + Observability notebook.

## Quick links

- [Comparing log rotation approaches](bash/notebooks/comparing-log-rotation-approaches.ipynb) — notebook comparing inotifywait-based and cron-based log rotation strategies
- [Debug and profile with set -x and trace traps](bash/docs/debug-and-profile-with-set-x-and-trace-traps.md) — notes on using Bash's execution trace and DEBUG trap for profiling
- [Applying version control in DevOps](docs/concepts/version-control-git-workflow/snippets/2026-08-11-applying-version-control-in-devops.py) — Python snippet that parses Git commit history and correlates commits with deployment events
- [Hello world Jenkins pipeline](jenkins/snippets/2026-08-11-hello-world-pipeline.groovy) — a minimal declarative Jenkins pipeline for a hello-world stage
- [Terraform coverage check](tf/docs/2026-08-11-terraform-coverage.md) — reconciling the Terraform folder against the manifest and fixing the counts

## Layout

- `ansible/` — Ansible material: primer, install notes, and first playbook config.
- `bash/` — Bash material: primer, notes, docs, scripts, and notebooks.
- `docker/` — Docker material: notes, Dockerfiles, source files, and scripts.
- `docs/concepts/` — foundational primers with runnable scripts, snippets, and notebooks (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `gha/` — GitHub Actions material: primer, install note, workflow configs, and docs.
- `git/` — Git material: notes, docs, scripts, and hooks tooling.
- `grafana/` — Grafana material: primer and install notes, plus a first dashboard config.
- `helm/` — Helm material: primer, install note, chart snippet, values override config, and docs.
- `jenkins/` — Jenkins material: primer, install notes, and pipeline snippet.
- `k8s/` — Kubernetes material: primer, install note, kubectl exploration, manifests, and docs.
- `prom/` — Prometheus material: primer and install notes, plus a first scrape target config.
- `python/` — Python material: primer, docs, scripts, and snippets.
- `repo-doc/` — notes on keeping the repository's own docs and coverage tables in sync.
- `tf/` — Terraform material: install note, primer, configs, docs, and scripts.
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

<details><summary>Coverage table</summary>

| Tool | notes | docs | scripts | snippets | configs | manifests | dockerfiles | src | hooks | notebooks | Last verified |
|------|-------|------|---------|----------|---------|-----------|-------------|-----|-------|-----------|---------------|
| Ansible | 2 | — | — | — | 1 | — | — | — | — | — | 2026-08-10 |
| Bash | 3 | 2 | 6 | 1 | — | — | — | — | — | 1 | 2026-08-12 |
| Docker | 5 | — | 3 | — | — | — | 1 | 2 | — | — | 2026-08-06 |
| Git | 12 | 4 | 4 | — | — | — | — | — | 1 | — | 2026-08-11 |
| GitHub Actions | 3 | 1 | — | — | 2 | — | — | — | — | — | 2026-08-06 |
| Grafana | 2 | — | — | — | 1 | — | — | — | — | — | 2026-08-06 |
| Helm | 3 | 1 | — | 1 | 1 | — | — | — | — | — | 2026-08-11 |
| Jenkins | 2 | — | — | 1 | — | — | — | — | — | — | 2026-08-11 |
| Kubernetes | 4 | 1 | 2 | — | — | 1 | — | — | — | — | 2026-08-04 |
| Prometheus | 2 | — | — | — | 1 | — | — | — | — | — | 2026-08-07 |
| Python | 2 | 1 | 2 | 1 | — | — | — | — | — | — | 2026-08-05 |
| Terraform | 3 | 2 | 1 | — | 3 | — | — | — | — | — | 2026-08-11 |
| Concepts | 3 | 15 | 13 | 8 | — | — | — | — | — | 2 | 2026-08-11 |

</details>

## Status

Recently added first-contact material for Ansible (primer, install note, ping playbook) and refreshed the Git and Helm coverage tables so they match what's actually on disk. All eight foundational concept primers are complete and joined by runnable scripts, snippets, and a CI/CD + Observability notebook. Grafana, Prometheus, GitHub Actions, Terraform, Bash, and Jenkins have landing pages, install notes, and first configs on disk. Added a Terraform coverage-table check and a Jenkins hello-world pipeline snippet this cycle.

---
_Last updated: 2026-08-12_
