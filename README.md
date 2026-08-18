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

- [Rebase vs merge at scale](git/docs/rebase-vs-merge-at-scale.md) — how rebase and merge strategies behave once a repo crosses hundreds of contributors and long-lived release branches
- [Install Helm with package manager](helm/notes/2026-08-18-install-helm-with-package-manager.md) — package-manager install, version check, and shell completion setup
- [Parameterised config generation](docs/concepts/infrastructure-as-code-principles/parameterised-config-generation.md) — generating per-environment configs from a single source of truth with loops and conditionals
- [Network topology Terraform script](docs/concepts/infrastructure-as-code-principles/scripts/network-topology-terraform.sh) — generates a Terraform config from a simple network-topology description
- [Multi-service Docker Compose config](docker/manifests/2026-08-17-multi-service-docker-compose.yaml) — a multi-service Docker Compose stack with web, cache, and worker services on the default network

## Layout

- `ansible/` — Ansible material: primer, install notes, and first playbook config.
- `bash/` — Bash material: primer, notes, docs, scripts, notebooks, a strict-mode runner image, and two Docker project scaffolds (toolchain + health-check stack).
- `docker/` — Docker material: notes, Dockerfiles, source files, scripts, and a multi-service Compose manifest.
- `docs/concepts/` — foundational primers with runnable scripts, snippets, and notebooks (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `gha/` — GitHub Actions material: primer, install note, and workflow configs.
- `git/` — Git material: notes, docs, scripts, hooks tooling, a release-workflow scaffold, and a pipeline-trigger manifest.
- `grafana/` — Grafana material: primer and install notes, plus a first dashboard config.
- `helm/` — Helm material: primer, install note, chart snippet, values override config, chart template, and manifests.
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
| Bash | 3 | 4 | 6 | 1 | — | 23 | — | 1 | — | — | 1 | 2026-08-17 |
| Docker | 5 | — | 3 | — | — | — | 1 | 1 | 2 | — | — | 2026-08-17 |
| Git | 12 | 6 | 5 | — | — | 6 | 1 | — | — | 1 | — | 2026-08-17 |
| GitHub Actions | 3 | 1 | — | — | 2 | — | — | — | — | — | — | 2026-08-06 |
| Grafana | 2 | — | — | — | 1 | — | — | — | — | — | — | 2026-08-06 |
| Helm | 4 | 1 | — | 1 | 1 | — | 1 | — | — | — | — | 2026-08-18 |
| Jenkins | 2 | — | — | 1 | — | — | — | — | — | — | — | 2026-08-11 |
| Kubernetes | 4 | 1 | 2 | — | — | — | 1 | — | — | — | — | 2026-08-04 |
| Prometheus | 2 | — | — | — | 1 | — | — | — | — | — | — | 2026-08-07 |
| Python | 2 | 1 | 2 | 1 | — | — | — | — | — | — | — | 2026-08-04 |
| Terraform | 3 | 2 | 1 | — | 3 | — | — | — | — | — | — | 2026-08-11 |
| Concepts | 3 | 19 | 16 | 9 | — | — | — | — | — | — | 2 | 2026-08-18 |

</details>

## Status

New this cycle: a Git doc comparing rebase vs merge at scale, a Helm note on package-manager install, an IaC doc on parameterised config generation with a companion Terraform script, and a multi-service Docker Compose manifest. The kit now carries 189 files across 13 tool areas, all eight concept primers complete with runnable companions, and three project scaffolds ready to copy in.

---
_Last updated: 2026-08-18_
