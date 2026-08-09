# DevOps-Projects
> A working engineer's DevOps reference for Bash, Docker, Git, GitHub Actions, Helm, Kubernetes, Python, Terraform, Grafana, and Prometheus, plus the foundational concepts they rest on.

![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)
![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)
![Languages](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)
![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for Bash, Docker, Git, GitHub Actions, Helm, Kubernetes, Python, Terraform, Grafana, and Prometheus, plus primers for the concepts they rest on. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs.

## What's in here

A growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, config, or script built while following a tool's quickstart and kept for later. It covers Bash, Docker, Git, GitHub Actions, Helm, Kubernetes, Python, Terraform, and Grafana/Prometheus, plus eight foundational concept primers under docs/concepts/ — each joined by runnable scripts, snippets, and a CI/CD + Observability notebook.

## Quick links

- [Semantic-release-like git automation script](git/scripts/semantic-release-automation.sh) — Bash script that automates version bumping, changelog generation, and git tagging following semantic-release conventions
- [First Helm values override config](helm/configs/2026-08-08-first-values-override.yaml) — a minimal Helm values override to customise a chart's defaults
- [Helm chart repo exploration notes](helm/notes/2026-08-08-explore-helm-chart-repo.md) — notes on exploring and adding Helm chart repositories
- [Minimal Terraform provider resource config](tf/configs/2026-08-08-minimal-provider-resource.hcl) — a minimal Terraform config creating a provider resource
- [Terraform quickstart trip-ups](tf/notes/2026-08-08-quickstart-trip-ups.md) — what to expect and where beginners get stuck with Terraform

## Layout

- `bash/` — Bash material: primer, notes, docs, and scripts.
- `docker/` — Docker material: notes, Dockerfiles, source files, and scripts.
- `docs/concepts/` — foundational primers with runnable scripts, snippets, and a notebook (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `gha/` — GitHub Actions material: primer, install note, and workflow config.
- `git/` — Git material: notes, docs, scripts, and hooks tooling.
- `grafana/` — Grafana material: primer and install notes, plus a first dashboard config.
- `helm/` — Helm material: primer, install note, chart snippet, and values override.
- `k8s/` — Kubernetes material: primer, install note, kubectl exploration, and manifests.
- `prom/` — Prometheus material: primer and install notes, plus a first scrape target config.
- `python/` — Python material: primer, docs, scripts, and snippets.
- `tf/` — Terraform material: install note, primer, first configs, and project structure docs.
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

<details><summary>Coverage table</summary>

| Tool | notes | docs | scripts | snippets | configs | manifests | dockerfiles | src | notebooks | Last verified |
|------|-------|------|---------|----------|---------|-----------|-------------|-----|-----------|---------------|
| Bash | 3 | 2 | 5 | 1 | — | — | — | — | — | 2026-07-30 |
| Docker | 5 | — | 3 | — | — | — | 1 | 2 | — | 2026-08-06 |
| Git | 12 | 2 | 4 | — | — | — | — | 1 | — | 2026-07-30 |
| GitHub Actions | 3 | 1 | — | — | 2 | — | — | — | — | 2026-08-06 |
| Grafana | 2 | — | — | — | 1 | — | — | — | — | 2026-08-06 |
| Helm | 3 | — | — | 1 | 1 | — | — | — | — | 2026-08-08 |
| Kubernetes | 4 | 1 | 2 | — | — | 1 | — | — | — | 2026-08-04 |
| Prometheus | 2 | — | — | — | 1 | — | — | — | — | 2026-08-07 |
| Python | 2 | 1 | 2 | 1 | — | — | — | — | — | 2026-08-04 |
| Terraform | 3 | 1 | 1 | — | 3 | — | — | — | — | 2026-08-08 |
| Concepts | 3 | 15 | 13 | 8 | — | — | — | — | 2 | 2026-08-07 |

</details>

## Status

Currently working through observability concepts (RED-method golden signals, CI/CD pipeline metric collection probes, and combining observability with containerization), scripting & automation philosophy (scripting exercises and DevOps application snippets), and version control git workflow practice (repo state, branch, and upstream tracking exercises). All eight foundational concept primers are complete and joined by runnable scripts, code snippets, and a CI/CD + Observability notebook. Grafana and Prometheus have landing pages, install notes, and first configs on disk. GitHub Actions, Terraform, and Bash sections are also complete with configs, docs, and scripts. Helm now has a values override config and chart repo exploration notes.

---
_Last updated: 2026-08-08_
