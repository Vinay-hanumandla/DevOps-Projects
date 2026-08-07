# DevOps-Projects
> A working engineer's DevOps reference for Bash, Docker, Git, GitHub Actions, Helm, Kubernetes, Python, and Terraform, plus the foundational concepts they rest on.

![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)
![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)
![Languages](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)
![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for Bash, Docker, Git, GitHub Actions, Helm, Kubernetes, Python, and Terraform, plus primers for the concepts they rest on. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs.

## What's in here

A growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, config, or script built while following a tool's quickstart and kept for later. It covers Bash, Docker, Git, GitHub Actions, Helm, Kubernetes, Python, and Terraform, plus eight foundational concept primers under docs/concepts/ — each joined by runnable scripts, snippets, and a CI/CD + Observability notebook.

## Quick links

- [Minimal CI workflow](gha/configs/2026-08-06-minimal-ci-workflow.yaml) — a minimal GitHub Actions workflow for CI
- [How I learned to read workflow logs](gha/docs/2026-08-06-how-i-learned-to-read-workflow-logs-and-debug-failures.md) — debugging failed GitHub Actions runs
- [GitHub Actions quickstart trip-ups](gha/notes/2026-08-06-github-actions-quickstart-trip-ups.md) — more gotchas after the initial run-through
- [Observability exercises](docs/concepts/observability-monitoring-concepts/scripts/2026-08-06-observability-exercises.sh) — hands-on exercises for observability concepts
- [First Terraform provider resource](tf/configs/2026-08-06-first-terraform-provider-resource.hcl) — a Terraform config that creates a provider resource

## Layout

- `bash/` — Bash material: primer, notes, docs, and scripts.
- `docker/` — Docker material: notes, Dockerfiles, source files, and scripts.
- `docs/concepts/` — foundational primers with runnable scripts, snippets, and a notebook (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `gha/` — GitHub Actions material: primer, install note, and workflow config.
- `git/` — Git material: notes, docs, scripts, and hooks tooling.
- `grafana/` — Grafana material: install note, primer, and dashboard config.
- `helm/` — Helm material: primer, install note, and chart snippet.
- `k8s/` — Kubernetes material: primer, install note, kubectl exploration, and manifests.
- `prom/` — Prometheus material: install note, primer, and scrape config.
- `python/` — Python material: primer, docs, scripts, and snippets.
- `tf/` — Terraform material: install note, primer, first config, and project structure docs.
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

<details><summary>Coverage table</summary>

| Tool | notes | docs | scripts | snippets | configs | manifests | dockerfiles | src | notebooks | Last verified |
|------|-------|------|---------|----------|---------|-----------|-------------|-----|-----------|---------------|
| Bash | 3 | 2 | 5 | 1 | — | — | — | — | — | 2026-07-31 |
| Docker | 4 | — | 3 | — | — | — | 1 | 2 | — | 2026-07-19 |
| Git | 12 | 2 | 3 | — | — | — | — | — | — | 2026-07-30 |
| GitHub Actions | 3 | 1 | — | — | 2 | — | — | — | — | 2026-08-06 |
| Helm | 2 | — | — | 1 | — | — | — | — | — | 2026-07-31 |
| Kubernetes | 4 | 1 | 2 | — | — | 1 | — | — | — | 2026-08-04 |
| Python | 2 | 1 | 2 | 1 | — | — | — | — | — | 2026-08-04 |
| Terraform | 2 | 1 | — | — | 2 | — | — | — | — | 2026-08-06 |
| Concepts | 2 | 8 | 8 | 5 | — | — | — | — | 2 | 2026-08-06 |

</details>

## Status

Currently working through GitHub Actions (workflow configs and log debugging), Terraform (provider resources and project structure), and observability concepts (new exercises script). All eight foundational concept primers are complete and joined by runnable scripts, code snippets, and a CI/CD + Observability notebook. Bash strict-mode/trap patterns and a directory-based system report tool are the latest additions to the Bash section.

---
_Last updated: 2026-08-06_