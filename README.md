# DevOps-Projects

> A working DevOps engineer's reference — Ansible, Docker, Git, Helm, Jenkins, Kubernetes, Python, Terraform, Grafana, and Prometheus notes, snippets, configs, and project scaffolds.

[![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects/commits/main)
[![License](https://img.shields.io/github/license/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects/blob/main/LICENSE)
[![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)
[![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for the tools listed above. Use it as a shelf you grab from, not a tutorial site. It deliberately does not try to replace each tool's official docs.

## What's in here

This kit covers 14 tools across the DevOps lifecycle: version control (Git), containerization (Docker), infrastructure provisioning (Terraform), configuration management (Ansible), orchestration (Kubernetes), packaging (Helm), CI/CD (GitHub Actions, Jenkins), observability (Prometheus, Grafana), and scripting (Bash, Python). Each tool folder contains first-contact notes, runnable scripts, configs, and where useful, templates or manifests. Foundational concepts in `docs/concepts/` explain the ideas the tools build on.

## Quick links

- [Git companion file quickstart](git/notes/2026-09-10-git-companion-file-quickstart.txt) — first-contact notes on Git's file-level operations
- [Git companion readme primer](git/notes/2026-09-10-git-companion-readme-primer.txt) — primer on Git's readme and documentation conventions
- [Git companion readme quickstart](git/notes/2026-09-10-git-companion-readme-quickstart.md) — quickstart for Git's readme and documentation workflows
- [Git CI/CD integration patterns](git/docs/git-cicd-integration-patterns.md) — patterns for wiring Git into CI/CD pipelines
- [Repo-doc quickstart trip-ups](repo-doc/notes/2026-09-10-repo-task-quickstart-trip-ups.md) — first-contact pitfalls when using the repo-doc toolkit

## Layout

`00_index/` — navigation hub: topics map, quick links, glossary, and learning path.
`ansible/` — playbooks, ad-hoc commands, and first-contact notes.
`bash/` — robust shell scripting patterns, toolchain scaffolds, and production service templates.
`docker/` — container runnables, multi-stage Dockerfiles, Compose stacks, and multi-arch builds.
`docs/concepts/` — foundational primers on CI/CD, containerization, IaC, Linux CLI, networking, observability, scripting, and version control.
`gha/` — GitHub Actions workflows, matrix builds, and release automation configs.
`git/` — branch workflows, hooks, release scaffolds, and commit-message conventions.
`grafana/` — dashboard configs, datasource provisioning, and API helpers.
`helm/` — chart values overrides, release workflows, and first chart templates.
`jenkins/` — declarative pipeline configs, credentials binding, and agent setup notes.
`k8s/` — cluster manifests, kubectl scripts, and multi-service application configs.
`prom/` — scrape configs, alerting rules, and PromQL query helpers.
`python/` — config validators, file processors, and DevOps utility scripts.
`repo-doc/` — helpers for keeping the kit's own coverage tables and docs in sync.
`tf/` — provider configs, null resources, multi-resource setups, and state-lock workflow scripts.

## Coverage

<details>
<summary>Coverage table</summary>

| Tool | notes | docs | scripts | configs | manifests | snippets | notebooks | dockerfiles | templates | src | Last verified |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Ansible | 3 | 1 | 1 | 4 | — | — | — | — | — | — | 2026-08-31 |
| Bash | 3 | 5 | 8 | — | — | 1 | 3 | 1 | 30 | — | 2026-09-05 |
| Docker | 5 | 1 | 6 | — | 1 | — | — | 2 | — | 2 | 2026-09-03 |
| GitHub Actions | 3 | 3 | — | 4 | — | — | 1 | — | — | — | 2026-09-04 |
| Git | 12 | 8 | 6 | — | 1 | — | — | — | 15 | — | 2026-09-10 |
| Grafana | 4 | — | — | 5 | — | 3 | — | — | — | — | 2026-09-09 |
| Helm | 5 | 2 | 1 | 5 | 1 | 1 | — | — | — | — | 2026-09-08 |
| Jenkins | 4 | — | — | 1 | — | 2 | — | — | — | — | 2026-09-06 |
| Kubernetes | 4 | 2 | 3 | 1 | 2 | 1 | — | — | — | — | 2026-08-27 |
| Prometheus | 4 | — | 1 | 4 | — | 1 | — | — | — | — | 2026-09-03 |
| Python | 3 | 2 | 3 | 1 | — | 4 | — | — | — | — | 2026-08-25 |
| Terraform | 4 | 3 | 2 | 5 | — | 1 | — | — | — | — | 2026-09-05 |
| Concepts | — | 8 | 8 | — | — | 7 | 3 | — | — | — | 2026-08-29 |
| Repo-doc | 2 | 2 | 1 | — | — | — | — | — | — | — | 2026-09-10 |

</details>

## Status

Currently working through L3–L4 first-contact notes for Helm, Jenkins, and Terraform. Recent additions include Git companion quickstart files and repo-doc tooling overview.

---
_Last updated: 2026-09-10_
