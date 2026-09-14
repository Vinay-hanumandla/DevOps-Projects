# DevOps-Projects

> A working DevOps engineer's reference — Ansible, Bash, Docker, GitHub Actions, Git, Grafana, Helm, Jenkins, Kubernetes, Prometheus, Python, Terraform, and more notes, snippets, configs, and project scaffolds.

[![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects/commits/main)
[![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)
[![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)
[![Language count](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for the tools listed above. Use it as a shelf you grab from, not a tutorial site. It deliberately does not try to replace each tool's official docs.

## What's in here

This kit covers 14 tools across the DevOps lifecycle: version control (Git), containerization (Docker), infrastructure provisioning (Terraform), configuration management (Ansible), orchestration (Kubernetes), packaging (Helm), CI/CD (GitHub Actions, Jenkins), observability (Prometheus, Grafana), and scripting (Bash, Python). Each tool folder contains first-contact notes, runnable scripts, configs, and where useful, templates or manifests. Foundational concepts in `docs/concepts/` explain the ideas the tools build on.

## Quick links

- [Git companion forgotten undo notes](git/notes/2026-08-25-forgotten.md) — companion notes on Git's forgotten undo patterns: amend, push, and recovering lost work
- [Helm hooks lifecycle manifest](helm/manifests/hooks-lifecycle.yaml) — Helm hooks for pre-install, post-upgrade, and rollback lifecycle events
- [Zero-downtime rolling deployment](k8s/manifests/zero-downtime-rolling-deployment.yaml) — readiness probes, PodDisruptionBudget, and surge/unhealthy thresholds for rolling updates
- [Reusable VPC module](tf/configs/reusable-vpc-module.hcl) — Terraform module creating a VPC with public and private subnets, NAT gateways, and route tables
- [Chart.yaml scaffold](helm/configs/chart-scaffold.yaml) — Helm chart scaffold demonstrating conditional dependencies, subchart pinning, and version constraints

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

| Tool | notes | docs | scripts | configs | manifests | snippets | notebooks | dockerfiles | templates | src | hooks | Last verified |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Ansible | 3 | 1 | 2 | 4 | — | — | — | — | — | — | — | 2026-09-10 |
| Bash | 3 | 6 | 8 | — | — | 1 | 3 | 1 | 30 | — | — | 2026-09-09 |
| Docker | 5 | 1 | 6 | — | 1 | — | — | 2 | — | 2 | — | 2026-09-03 |
| GitHub Actions | 3 | 3 | — | 4 | — | — | 1 | — | — | — | — | 2026-09-02 |
| Git | 16 | 9 | 6 | — | 1 | — | — | — | 15 | — | 1 | 2026-09-13 |
| Grafana | 4 | — | — | 5 | — | 3 | — | — | — | — | — | 2026-08-27 |
| Helm | 5 | 2 | 1 | 6 | 2 | 1 | — | — | — | — | — | 2026-09-08 |
| Jenkins | 4 | — | — | 1 | — | 2 | — | — | — | — | — | 2026-09-06 |
| Kubernetes | 4 | 2 | 3 | 1 | 3 | 2 | — | — | — | — | — | 2026-08-27 |
| Prometheus | 4 | — | 1 | 4 | — | 1 | — | — | — | — | — | 2026-08-30 |
| Python | 3 | 2 | 3 | 1 | — | 4 | — | — | — | — | — | 2026-08-25 |
| Terraform | 4 | 3 | 2 | 6 | — | 1 | — | — | — | — | — | 2026-09-05 |
| Repo-doc | 2 | 2 | 2 | — | — | — | — | — | — | — | — | 2026-09-10 |
| Concepts | — | 8 | 8 | — | — | 7 | 3 | — | — | — | — | 2026-08-29 |

</details>

## Status

Currently working through L3–L4 first-contact notes for Helm, Jenkins, and Terraform. Recent additions include a reusable VPC module, a zero-downtime rolling deployment manifest, Helm hooks lifecycle manifest, and Git companion undo notes.

---
_Last updated: 2026-09-13_