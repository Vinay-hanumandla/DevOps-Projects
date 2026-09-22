# DevOps Projects
> A working DevOps engineer's shelf for Git, Bash, Docker, Kubernetes, Terraform, Ansible, and the CI/CD and observability tools that connect them.

[![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects/commits/main) [![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects) [![Language count](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects) [![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for the tools above. Use it as a shelf you grab from, not a tutorial site. It deliberately does not try to replace each tool's official docs.

## What's in here

This kit covers 13 tools across the DevOps lifecycle: version control (Git), containerization (Docker), infrastructure provisioning (Terraform), configuration management (Ansible), orchestration (Kubernetes), packaging (Helm), CI/CD (GitHub Actions, Jenkins), observability (Prometheus, Grafana), and scripting (Bash, Python). Each tool folder contains first-contact notes, runnable scripts, configs, and where useful, templates or manifests. Foundational concepts in `docs/concepts/` explain the ideas the tools build on.

## Quick links

- [Signed commits and CI provenance](git/docs/signed-commits-and-ci-provenance.md) — signing keys, envelope signing, and how CI verifies commit provenance
- [Values merge vs file](helm/notes/2026-09-21-values-merge-set-vs-file.md) — when `--values` merges against `--set` and why order matters
- [Minimal static web app values](helm/configs/2026-09-21-minimal-static-web-app-values.yaml) — slim nginx Helm values with ConfigMap-backed static content
- [Buildx Bake monorepo environment example](docker/templates/buildx-bake-monorepo/.env.example) — registry, tag, and cache tunables for a multi-service build
- [Buildx Bake monorepo template](docker/templates/buildx-bake-monorepo/README.md) — one entrypoint for shared cache, attestations, and dual-registry image outputs

## Layout

`00_index/` — navigation hub: topics map, quick links, glossary, and learning path.
`ansible/` — playbooks, ad-hoc commands, and first-contact notes.
`bash/` — robust shell scripting patterns, toolchain scaffolds, and production service templates.
`docker/` — container runnables, multi-stage Dockerfiles, Compose stacks, and storage guidance for stateful workloads.
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

## Coverage

<details>
<summary>Coverage table</summary>

| Tool | notes | docs | scripts | configs | manifests | notebooks | dockerfiles | templates | src | hooks | snippets | Last verified |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Ansible | 3 | 3 | 3 | 4 | 1 | — | — | 15 | — | — | 1 | 2026-09-18 |
| Bash | 3 | 6 | 9 | — | — | 4 | 1 | 30 | — | — | 1 | 2026-09-09 |
| Docker | 5 | 3 | 7 | — | 2 | — | 4 | 25 | 2 | — | — | 2026-09-21 |
| GitHub Actions | 3 | 3 | 2 | 6 | — | 1 | — | — | — | — | 1 | 2026-09-02 |
| Git | 16 | 11 | 6 | — | 1 | — | — | 14 | — | 1 | — | 2026-09-21 |
| Grafana | 4 | 1 | 1 | 6 | 2 | 1 | — | — | — | — | 3 | 2026-09-16 |
| Helm | 6 | 2 | 1 | 7 | 2 | 1 | — | — | — | — | 1 | 2026-09-21 |
| Jenkins | 4 | 2 | — | 1 | — | — | — | — | — | — | 3 | 2026-09-21 |
| Kubernetes | 5 | 4 | 3 | 1 | 4 | 1 | 1 | 10 | — | — | 2 | 2026-09-19 |
| Prometheus | 4 | 2 | 2 | 6 | — | — | — | — | — | — | 1 | 2026-09-19 |
| Python | 3 | 3 | 4 | 4 | — | 2 | 1 | 7 | — | — | 4 | 2026-09-14 |
| Terraform | 4 | 3 | 2 | 7 | 1 | 1 | — | 8 | — | — | 1 | 2026-09-20 |
| Repo-doc | 3 | 2 | 2 | — | — | — | — | — | — | — | — | 2026-09-21 |
| Concepts | 8 | 17 | 22 | — | — | 5 | — | — | — | — | 12 | 2026-08-29 |

</details>

## Status

Currently expanding first-contact and integration coverage across Docker Buildx Bake, Helm values, Jenkins SCM-backed pipelines, Grafana provisioning, Terragrunt layouts, and Python async tooling.

---
_Last updated: 2026-09-22_