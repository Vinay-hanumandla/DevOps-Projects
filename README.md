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

- [Terragrunt multi-environment layout](tf/templates/terragrunt-multi-env/README.md) — one reusable Terraform module shared across dev, staging, and prod with per-environment inputs and a shared remote-state backend
- [Async patterns comparison](python/notebooks/async-patterns-comparison.ipynb) — asyncio vs trio vs anyio for I/O-bound DevOps tooling like endpoint probing and artifact copies
- [Worktree workflows for parallel feature development](git/docs/worktree-parallel-feature-development.md) — one clone hosting several checked-out branches at once, sharing a single object store
- [Multi-stage build patterns for Python services](docker/docs/multi-stage-build-patterns-python-services.md) — slim vs distroless vs Alpine runtime profiles and the trade-offs that pick between them
- [Root module fan-out composition](tf/manifests/root-module-fan-out-composition.hcl) — VPC, EKS, and RDS submodules wired together by passing outputs between module blocks

## Layout

`00_index/` — navigation hub: topics map, quick links, glossary, and learning path.
`ansible/` — playbooks, ad-hoc commands, and first-contact notes.
`bash/` — robust shell scripting patterns, toolchain scaffolds, and production service templates.
`docker/` — container runnables, multi-stage Dockerfiles, Compose stacks, multi-arch builds, and storage guidance for stateful workloads.
`docs/concepts/` — foundational primers on CI/CD, containerization, IaC, Linux CLI, networking, observability, scripting, and version control.
`gha/` — GitHub Actions workflows, matrix builds, release automation configs, and a minimal custom JavaScript action.
`git/` — branch workflows, hooks, release scaffolds, and commit-message conventions.
`grafana/` — dashboard configs, datasource provisioning, and API helpers.
`helm/` — chart values overrides, release workflows, and first chart templates.
`jenkins/` — declarative pipeline configs, credentials binding, and agent setup notes.
`k8s/` — cluster manifests, kubectl scripts, multi-service application configs, and a Helm-chart scaffold with ingress and monitoring.
`prom/` — scrape configs, alerting rules, and PromQL query helpers.
`python/` — config validators, file processors, and DevOps utility scripts.
`repo-doc/` — helpers for keeping the kit's own coverage tables and docs in sync.
`scripting-automation-philosophy/` — companion app config for the scripting deploy-checklist snippet.
`tf/` — provider configs, null resources, multi-resource setups, state-lock workflow scripts, and a Terragrunt multi-environment scaffold.

> Counts below were regenerated from the filesystem on 2026-09-20 and include every file under each tool's category folders (recursively, so scaffolded template trees under `templates/` are counted in full).

## Coverage

<details>
<summary>Coverage table</summary>

| Tool | notes | docs | scripts | configs | manifests | notebooks | dockerfiles | templates | src | hooks | snippets | Last verified |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Ansible | 3 | 3 | 3 | 4 | 1 | — | — | 16 | — | — | 1 | 2026-09-18 |
| Bash | 3 | 6 | 9 | — | — | 4 | 1 | 30 | — | — | 1 | 2026-09-20 |
| Docker | 5 | 3 | 7 | — | 2 | — | 4 | 18 | 2 | — | — | 2026-09-20 |
| GitHub Actions | 3 | 3 | 2 | 6 | — | 1 | — | — | — | — | 1 | 2026-09-20 |
| Git | 16 | 10 | 6 | — | 1 | — | — | 15 | — | 1 | — | 2026-09-20 |
| Grafana | 4 | 1 | 1 | 6 | 1 | 1 | — | — | — | — | 3 | 2026-09-19 |
| Helm | 5 | 2 | 1 | 6 | 2 | 1 | — | — | — | — | 1 | 2026-09-18 |
| Jenkins | 4 | 2 | — | 1 | — | — | — | — | — | — | 3 | 2026-09-19 |
| Kubernetes | 5 | 4 | 3 | 1 | 4 | 1 | 1 | 10 | — | — | 2 | 2026-09-19 |
| Prometheus | 4 | 2 | 2 | 6 | — | — | — | — | — | — | 1 | 2026-09-19 |
| Python | 3 | 3 | 4 | 4 | — | 2 | 1 | 8 | — | — | 4 | 2026-09-20 |
| Terraform | 4 | 3 | 2 | 7 | 1 | 1 | — | 8 | — | — | 1 | 2026-09-20 |
| Repo-doc | 2 | 2 | 2 | — | — | — | — | — | — | — | — | 2026-09-18 |
| Concepts | 8 | 17 | 22 | — | — | 5 | — | — | — | — | 12 | 2026-09-16 |

</details>

## Status

Currently rounding out the Terraform shelf past single-root modules: a Terragrunt multi-environment scaffold that shares one module across dev, staging, and prod, plus a root-module fan-out composition wiring VPC, EKS, and RDS through outputs. Alongside that, the Git shelf gained worktree workflows for parallel branches, Docker gained multi-stage Python runtime profiles and a hardened production Dockerfile, and Python gained an asyncio/trio/anyio comparison for I/O-bound tooling.

---
_Last updated: 2026-09-20_
