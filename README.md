# DevOps-Projects
> A working DevOps engineer's reference for Ansible, Bash, Docker, GitHub Actions, Git, Grafana, Helm, Jenkins, Kubernetes, Prometheus, Python, and Terraform — notes, snippets, configs, and project scaffolds.

[![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects/commits/main)
[![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)
[![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)
[![Language count](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for the tools above. Use it as a shelf you grab from, not a tutorial site. It deliberately does not try to replace each tool's official docs.

## What's in here

This kit covers 13 tools across the DevOps lifecycle: version control (Git), containerization (Docker), infrastructure provisioning (Terraform), configuration management (Ansible), orchestration (Kubernetes), packaging (Helm), CI/CD (GitHub Actions, Jenkins), observability (Prometheus, Grafana), and scripting (Bash, Python). Each tool folder contains first-contact notes, runnable scripts, configs, and where useful, templates or manifests. Foundational concepts in `docs/concepts/` explain the ideas the tools build on.

## Quick links

- [Bats-core production test suite](bash/notebooks/bats-core-production-test-suite.ipynb) — health-check, log-rotation, and secret-rotation suites with per-test isolation, runnable in CI via `bats tests/`
- [command/shell vs purpose-built idempotent modules](ansible/docs/command-shell-vs-idempotent-modules.md) — when a shell-out is a bug, which module replaces it, and how to guard the ones that must stay
- [Block/rescue/always deploy with handlers](ansible/snippets/block-rescue-always-handlers.yaml) — tries a config deploy, rolls back on failure, always reports, and restarts the service only on change
- [Production-ready Kubernetes deployment](k8s/manifests/production-deployment.yaml) — Deployment with HPA, PodDisruptionBudget, NetworkPolicy, and ResourceQuota for production traffic
- [Integrating Kubernetes with Terraform](k8s/docs/integrating-kubernetes-with-terraform.md) — where cluster provisioning ends and workload management begins, and how to keep the two from owning the same resource

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
`scripting-automation-philosophy/` — companion app config for the scripting deploy-checklist snippet.
`tf/` — provider configs, null resources, multi-resource setups, and state-lock workflow scripts.

> Counts below were regenerated from the filesystem on 2026-09-19 and include every file under each tool's category folders (recursively, so scaffolded template trees under `templates/` are counted in full).

## Coverage

<details>
<summary>Coverage table</summary>

| Tool | notes | docs | scripts | configs | manifests | notebooks | dockerfiles | templates | src | hooks | snippets | Last verified |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Ansible | 3 | 3 | 3 | 4 | 1 | — | — | 16 | — | — | 1 | 2026-09-18 |
| Bash | 3 | 6 | 8 | — | — | 4 | 1 | 30 | — | — | 1 | 2026-09-18 |
| Docker | 5 | 1 | 7 | — | 2 | — | 3 | 10 | 2 | — | — | 2026-09-18 |
| GitHub Actions | 3 | 3 | — | 6 | — | 1 | — | — | — | — | — | 2026-09-18 |
| Git | 16 | 9 | 6 | — | 1 | — | — | 15 | — | 4 | — | 2026-09-18 |
| Grafana | 4 | 1 | — | 5 | 1 | 1 | — | — | — | — | 3 | 2026-09-18 |
| Helm | 5 | 2 | 1 | 6 | 2 | 1 | — | — | — | — | 1 | 2026-09-18 |
| Jenkins | 4 | — | — | 1 | — | — | — | — | — | — | 2 | 2026-09-18 |
| Kubernetes | 5 | 3 | 3 | 1 | 4 | 1 | 1 | — | — | — | 2 | 2026-09-18 |
| Prometheus | 4 | 1 | 2 | 6 | — | — | — | — | — | — | 1 | 2026-09-18 |
| Python | 3 | 3 | 4 | 4 | — | 1 | 1 | 8 | — | — | 4 | 2026-09-18 |
| Terraform | 4 | 3 | 2 | 6 | — | — | — | — | — | — | 1 | 2026-09-18 |
| Repo-doc | 2 | 2 | 2 | — | — | — | — | — | — | — | — | 2026-09-18 |
| Concepts | 8 | 17 | 22 | — | — | 5 | — | — | — | — | 12 | 2026-09-18 |

</details>

## Status

Currently working through L4–L5 first-contact notes for Ansible, Python, and GitHub Actions. Recent additions tighten the Ansible shelf (replacing shell-outs with idempotent modules, block/rescue error handling) and the Kubernetes shelf (a production deployment with HPA, PDB, NetworkPolicy, and quota, plus a Terraform ownership-boundary guide), alongside Prometheus configs for Kubernetes service discovery and the remote-write vs federation choice. The newest addition is a bats-core notebook that puts production Bash scripts — health checks, log rotation, secret rotation — under per-test isolation runnable in CI.

---
_Last updated: 2026-09-19_
