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

- [Debugging and profiling Bash with set -x and trace traps](bash/docs/debug-and-profile-with-set-x-and-trace-traps.md) — tracing a failing script to its line and timing functions with RETURN traps, using only built-ins
- [Applying version control in DevOps — commit-history changelog](docs/concepts/version-control-git-workflow/snippets/2026-08-11-applying-version-control-in-devops.py) — grouping conventional commits into release notes straight from git history
- [Jenkins — hello-world pipeline](jenkins/snippets/2026-08-11-hello-world-pipeline.groovy) — a minimal declarative pipeline job to paste in and hit Build Now
- [Combining Scripting & Automation with CI/CD pipeline patterns](docs/concepts/scripting-automation-philosophy/combining-scripting-with-cicd-pipeline-automation.md) — keeping logic in scripts and sequencing in the pipeline YAML
- [Terraform validate → plan → apply idempotent script](docs/concepts/scripting-automation-philosophy/scripts/terraform-plan-apply-idempotent.sh) — plan-as-artifact workflow where apply consumes a reviewed saved plan

## Layout

- `ansible/` — Ansible material: primer, install notes, and first playbook config.
- `bash/` — Bash material: primer, notes, docs, and scripts.
- `docker/` — Docker material: notes, Dockerfiles, source files, and scripts.
- `docs/concepts/` — foundational primers with runnable scripts, snippets, and a notebook (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `gha/` — GitHub Actions material: primer, install note, and workflow config.
- `git/` — Git material: notes, docs, scripts, and hooks tooling.
- `grafana/` — Grafana material: primer and install notes, plus a first dashboard config.
- `helm/` — Helm material: primer, install note, chart snippet, and values override config.
- `jenkins/` — Jenkins material: primer, install notes, and a first pipeline snippet.
- `k8s/` — Kubernetes material: primer, install note, kubectl exploration, and manifests.
- `prom/` — Prometheus material: primer and install notes, plus a first scrape target config.
- `python/` — Python material: primer, docs, scripts, and snippets.
- `repo-doc/` — notes on keeping the repository's own docs and coverage tables in sync.
- `tf/` — Terraform material: install note, primer, first config, and project structure docs.
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

<details><summary>Coverage table</summary>

| Tool | notes | docs | scripts | snippets | configs | manifests | dockerfiles | src | hooks | notebooks | Last verified |
|------|-------|------|---------|----------|---------|-----------|-------------|-----|-----------|---------------|
| Ansible | 2 | — | — | — | 1 | — | — | — | — | — | 2026-08-10 |
| Bash | 3 | 3 | 6 | 1 | — | — | — | — | — | — | 2026-08-11 |
| Docker | 5 | — | 3 | — | — | — | 1 | 2 | — | — | 2026-08-06 |
| Git | 12 | 4 | 4 | — | — | — | — | — | 1 | — | 2026-08-10 |
| GitHub Actions | 3 | 1 | — | — | 2 | — | — | — | — | — | 2026-08-06 |
| Grafana | 2 | — | — | — | 1 | — | — | — | — | — | 2026-08-06 |
| Helm | 3 | 1 | — | 1 | 1 | — | — | — | — | — | 2026-08-10 |
| Jenkins | 2 | — | — | 1 | — | — | — | — | — | — | 2026-08-11 |
| Kubernetes | 4 | 1 | 2 | — | — | 1 | — | — | — | — | 2026-08-04 |
| Prometheus | 2 | — | — | — | 1 | — | — | — | — | — | 2026-08-07 |
| Python | 2 | 1 | 2 | 1 | — | — | — | — | — | — | 2026-08-04 |
| Terraform | 3 | 2 | 1 | — | 3 | — | — | — | — | — | 2026-08-11 |
| Concepts | 3 | 16 | 14 | 9 | — | — | — | — | — | 2 | 2026-08-11 |

</details>

## Status

Jenkins joined the fold this cycle: a first-contact primer, an install-and-open-the-UI note, and a hello-world pipeline snippet — the plan of record is to wire up a job that checks out code from a repo next. Also added Bash debugging/profiling notes (set -x and trace traps), a Scripting × CI/CD pipeline-patterns guide with a plan-as-artifact Terraform script, and a commit-history changelog snippet. All eight foundational concept primers are complete and joined by runnable scripts, snippets, and notebooks. Ansible, Grafana, Prometheus, GitHub Actions, and Helm have landing pages, install notes, and first configs on disk; Terraform's coverage table was re-reconciled against the folder.

---
_Last updated: 2026-08-11_
