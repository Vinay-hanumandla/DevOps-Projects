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

- [Moving the Jenkinsfile from inline script to SCM](jenkins/docs/2026-09-19-moving-jenkinsfile-to-scm-gotchas.md) — Script Path, branch specifier, lightweight checkout, and credential-ID gotchas when a job points at a repo
- [Provisioned dashboard with panels and variables](grafana/configs/provisioned-dashboard-panels-variables.yaml) — file-provisioned datasource, dashboard provider, and service-overview dashboard with a templating variable, no UI clicks
- [Shared-library + credentials pipeline](jenkins/snippets/2026-09-19-shared-library-credentials.groovy) — pulls a helper from a global shared library and binds a secret-text credential without printing it
- [Grafana dashboard API wrapper](grafana/scripts/grafana-http-api-dashboard-wrapper.sh) — one CLI for list, idempotent create/update, and safe delete of dashboards via the HTTP API
- [Minimal custom JavaScript action](gha/scripts/action.yml) — the smallest viable custom action: two inputs in, one greeting output out, on the node20 runtime

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
`tf/` — provider configs, null resources, multi-resource setups, and state-lock workflow scripts.

> Counts below were regenerated from the filesystem on 2026-09-19 and include every file under each tool's category folders (recursively, so scaffolded template trees under `templates/` are counted in full).

## Coverage

<details>
<summary>Coverage table</summary>

| Tool | notes | docs | scripts | configs | manifests | notebooks | dockerfiles | templates | src | hooks | snippets | Last verified |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Ansible | 3 | 3 | 3 | 4 | 1 | — | — | 16 | — | — | 1 | 2026-09-18 |
| Bash | 3 | 6 | 8 | — | — | 4 | 1 | 30 | — | — | 1 | 2026-09-18 |
| Docker | 5 | 2 | 7 | — | 2 | — | 3 | 10 | 2 | — | — | 2026-09-19 |
| GitHub Actions | 3 | 3 | 2 | 6 | — | 1 | — | — | — | — | — | 2026-09-19 |
| Git | 16 | 9 | 6 | — | 1 | — | — | 15 | — | 4 | — | 2026-09-18 |
| Grafana | 4 | 1 | 1 | 6 | 1 | 1 | — | — | — | — | 3 | 2026-09-19 |
| Helm | 5 | 2 | 1 | 6 | 2 | 1 | — | — | — | — | 1 | 2026-09-18 |
| Jenkins | 4 | 1 | — | 1 | — | — | — | — | — | — | 3 | 2026-09-19 |
| Kubernetes | 5 | 3 | 3 | 1 | 4 | 1 | 1 | 10 | — | — | 2 | 2026-09-19 |
| Prometheus | 4 | 1 | 2 | 6 | — | — | — | — | — | — | 1 | 2026-09-18 |
| Python | 3 | 3 | 4 | 4 | — | 1 | 1 | 8 | — | — | 4 | 2026-09-18 |
| Terraform | 4 | 3 | 2 | 6 | — | — | — | — | — | — | 1 | 2026-09-18 |
| Repo-doc | 2 | 2 | 2 | — | — | — | — | — | — | — | — | 2026-09-18 |
| Concepts | 8 | 17 | 22 | — | — | 5 | — | — | — | — | 12 | 2026-09-16 |

</details>

## Status

Currently working through L4–L5 first-contact notes for Ansible, Python, and GitHub Actions. Recent additions tighten the Ansible shelf (replacing shell-outs with idempotent modules, block/rescue error handling) and the Kubernetes shelf (a production deployment with HPA, PDB, NetworkPolicy, and quota, plus a Terraform ownership-boundary guide), alongside Prometheus configs for Kubernetes service discovery and the remote-write vs federation choice. The newest additions move Jenkins from inline pipeline scripts to SCM-backed jobs (Script Path and checkout gotchas, plus a shared-library credentials snippet) and make Grafana fully declarative (a file-provisioned dashboard with panels and variables, plus a single API wrapper for list, create/update, and delete).

---
_Last updated: 2026-09-19_
