# DevOps-Projects

> A working engineer's DevOps reference for Ansible, Bash, Docker, Git, GitHub Actions, Helm, Jenkins, Kubernetes, Python, Terraform, Grafana, and Prometheus, plus the foundational concepts they rest on.

---

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, configs, and project scaffolds for Ansible, Bash, Docker, Git, GitHub Actions, Helm, Jenkins, Kubernetes, Python, Terraform, and Grafana/Prometheus, plus primers for the concepts they rest on. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs.

## What's in here

A growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, config, script, or project scaffold built while working through a tool's ecosystem and kept for later. It covers 12 tools across configuration management, containerization, CI/CD, infrastructure as code, and observability, plus eight foundational concept primers under `docs/concepts/` — each joined by runnable scripts, snippets, and notebooks. Three full project scaffolds ship as copy-in-and-rename layouts: a Git-based release workflow (`git/templates/release-workflow/`), a Bash + Docker toolchain (`bash/templates/bash-docker-scaffold/`), and a Bash + Docker multi-container stack whose startup ordering is wired through health checks (`bash/templates/bash-docker-healthcheck-scaffold/`).

---

## Quick links

- [Multi-service application manifest](k8s/manifests/multi-service-application.yaml) — Kubernetes Deployment with frontend, backend, and Redis cache
- [Docker Compose validator](python/snippets/docker-compose-validator.py) — Python snippet validating Docker Compose service definitions
- [Config validator script](python/scripts/config-validator.py) — Python configuration validator with type and port checks
- [Network interface routing practice](docs/concepts/networking-fundamentals/scripts/2026-08-24-network-interface-and-routing-practice.sh) — hands-on network interface and routing inspection
- [Multi-pod deployment script](k8s/scripts/multi-pod-deployment.sh) — kubectl script deploying multiple pods

---

## Layout

- `ansible/` — Ansible material: primer, install notes, and playbook configs.
- `bash/` — Bash material: primer, notes, docs, scripts, notebooks, a strict-mode runner image, and two Docker project scaffolds.
- `docker/` — Docker material: notes, Dockerfiles, source files, scripts, and a multi-service Compose manifest.
- `docs/concepts/` — foundational primers with runnable scripts, snippets, and notebooks (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `gha/` — GitHub Actions material: primer, install note, and workflow configs.
- `git/` — Git material: notes, docs, scripts, hooks tooling, a release-workflow scaffold, and a pipeline-trigger manifest.
- `grafana/` — Grafana material: primer and install notes, dashboard configs, and API snippets.
- `helm/` — Helm material: primer, install notes, chart snippet, per-environment values overrides, and a chart template.
- `jenkins/` — Jenkins material: primer, install notes, and a first pipeline snippet.
- `k8s/` — Kubernetes material: primer, install note, kubectl exploration, configs, manifests, and resource-listing snippets.
- `prom/` — Prometheus material: primer and install notes, scrape configs, and a PromQL snippet.
- `python/` — Python material: primer, notes, docs, scripts, and snippets.
- `repo-doc/` — notes on keeping the repository's own docs and coverage tables in sync.
- `tf/` — Terraform material: primer, install note, configs, docs, and scripts.
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

---

## Coverage

<details><summary>Coverage table</summary>

| Tool | notes | docs | scripts | snippets | configs | templates | manifests | dockerfiles | src | hooks | notebooks | Last verified |
|------|-------|------|---------|----------|---------|-----------|-----------|-------------|-----|-------|-----------|---------------|
| Ansible | 2 | — | — | — | 2 | — | — | — | — | — | — | 2026-08-22 |
| Bash | 3 | 4 | 6 | 1 | — | 23 | — | 1 | — | — | 1 | 2026-08-17 |
| Docker | 5 | — | 3 | — | — | — | 1 | 1 | 2 | — | — | 2026-08-17 |
| Git | 12 | 6 | 6 | — | — | 6 | 1 | — | 1 | — | — | 2026-08-19 |
| GitHub Actions | 3 | 1 | — | — | 2 | — | — | — | — | — | — | 2026-08-06 |
| Grafana | 2 | — | — | 2 | 2 | — | — | — | — | — | — | 2026-08-22 |
| Helm | 5 | 1 | — | 1 | 4 | — | 1 | — | — | — | — | 2026-08-20 |
| Jenkins | 2 | — | — | 1 | — | — | — | — | — | — | — | 2026-08-11 |
| Kubernetes | 4 | 1 | 3 | 1 | 1 | — | 2 | — | — | — | — | 2026-08-24 |
| Prometheus | 2 | — | — | 1 | 2 | — | — | — | — | — | — | 2026-08-22 |
| Python | 3 | 1 | 3 | 5 | 1 | — | — | — | — | — | — | 2026-08-24 |
| Terraform | 3 | 2 | 1 | — | 3 | — | — | — | — | — | — | 2026-08-11 |
| Repo docs | — | 1 | — | — | — | — | — | — | — | — | — | 2026-08-10 |
| Concepts | 8 | 20 | 18 | 11 | — | — | — | — | — | — | 4 | 2026-08-24 |

</details>

---

## Status

All eight concept primers are complete with runnable companions, and three project scaffolds are ready to copy in. The kit covers 12 tools across configuration management, containerization, CI/CD, infrastructure as code, and observability. The newest additions are a Kubernetes multi-service application manifest, a Docker Compose validator snippet, a Python config validator script, and a network interface routing practice exercise.

---

_Last updated: 2026-08-24_
