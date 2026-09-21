# DevOps Projects

> A working DevOps engineer's shelf for Git, Bash, Docker, Kubernetes, Terraform, Ansible, and the tools that connect them.

[![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects/commits/main) [![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects) [![Language count](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects) [![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable examples, and configs for Git, Bash, Docker, Kubernetes, Terraform, Ansible, GitHub Actions, Jenkins, Prometheus, Grafana, Helm, and Python.
Use it as a shelf you grab from while designing, debugging, or reviewing a system — not as a substitute for each tool's official docs.
It deliberately leaves out customer-specific credentials, environment secrets, and a full tutorial for every product.

## What's in here

This kit is organized around Git, Bash, Docker, GitHub Actions, Jenkins, Kubernetes, Helm, Terraform, Ansible, Prometheus, Grafana, Python, repo-doc, and foundational DevOps concepts.
The repository currently holds 425 content files across notes, docs, scripts, snippets, configs, manifests, notebooks, Dockerfiles, and reusable templates.
`docs/concepts/` holds the conceptual spine; each tool folder holds the material you reach for when putting those ideas into practice.

## Quick links

- [Minimal static web app values](helm/configs/2026-09-21-minimal-static-web-app-values.yaml) — slim nginx Helm values with ConfigMap-backed static content.
- [Buildx Bake monorepo environment example](docker/templates/buildx-bake-monorepo/.env.example) — registry, tag, and cache tunables for a multi-service build.
- [Buildx Bake monorepo template](docker/templates/buildx-bake-monorepo/README.md) — one entrypoint for shared cache, attestations, and dual-registry image outputs.
- [Buildx Bake definition](docker/templates/buildx-bake-monorepo/docker-bake.hcl) — shared policy plus API and web targets, with a non-publishing check target.
- [Monorepo API Dockerfile](docker/templates/buildx-bake-monorepo/services/api/Dockerfile) — the placeholder Python API image used by the Bake template.

## Layout

- `00_index/` — the map, quick links, glossary, and learning path for the kit.
- `docs/concepts/` — foundational concepts and cross-tool integration patterns.
- `ansible/` — idempotent automation, collections, inventories, and Kubernetes handoffs.
- `bash/` — shell fundamentals, robust script patterns, debugging, and reusable scaffolds.
- `docker/` — images, Compose, Buildx, registries, and container delivery patterns.
- `gha/` — GitHub Actions workflows, reusable actions, triggers, and local debugging.
- `git/` — repositories, branches, hooks, worktrees, releases, and CI integration.
- `grafana/` — dashboards, provisioning, alerts, and Jsonnet-oriented dashboard code.
- `helm/` — chart structure, values, templates, testing, and registry workflows.
- `jenkins/` — controllers, jobs, declarative pipelines, credentials, and SCM-backed Jenkinsfiles.
- `k8s/` — Kubernetes objects, kubectl, Helm/Argo CD flows, and local clusters.
- `prom/` — Prometheus setup, PromQL, service discovery, and alerting.
- `python/` — Python fundamentals, configuration, async tooling, and DevOps integrations.
- `repo-doc/` — repository coverage and documentation-maintenance utilities.
- `scripting-automation-philosophy/` — the small companion note for repeatable automation habits.
- `tf/` — Terraform projects, state, validation, manifests, and Terragrunt layouts.

## Coverage

Counts include files nested inside template trees. `Other` is a root-level support file that does not belong to a content category.

<details>
<summary>Coverage table</summary>

| Area | Notes | Docs | Scripts | Snippets | Configs | Manifests | Notebooks | Dockerfiles | Templates | Src | Hooks | Other | Last verified |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Ansible | 3 | 3 | 3 | 1 | 4 | 1 | 0 | 0 | 15 | 0 | 0 | 0 | 2026-09-18 |
| Bash | 3 | 6 | 9 | 1 | 0 | 0 | 4 | 1 | 30 | 0 | 0 | 0 | 2026-09-09 |
| Docker | 5 | 3 | 7 | 0 | 0 | 2 | 0 | 4 | 25 | 2 | 0 | 1 | 2026-09-21 |
| GitHub Actions | 3 | 3 | 2 | 1 | 6 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 2026-09-02 |
| Git | 16 | 10 | 6 | 0 | 0 | 1 | 0 | 0 | 14 | 0 | 1 | 0 | 2026-09-20 |
| Grafana | 4 | 1 | 1 | 3 | 6 | 2 | 1 | 0 | 0 | 0 | 0 | 0 | 2026-09-16 |
| Helm | 5 | 2 | 1 | 1 | 7 | 2 | 1 | 0 | 0 | 0 | 0 | 0 | 2026-09-08 |
| Jenkins | 4 | 2 | 0 | 3 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-21 |
| Kubernetes | 5 | 4 | 3 | 2 | 1 | 4 | 1 | 1 | 10 | 0 | 0 | 0 | 2026-09-19 |
| Prometheus | 4 | 2 | 2 | 1 | 6 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-19 |
| Python | 3 | 3 | 4 | 4 | 4 | 0 | 2 | 1 | 7 | 0 | 0 | 0 | 2026-09-14 |
| repo-doc | 3 | 2 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-21 |
| Scripting companion | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-16 |
| Terraform | 4 | 3 | 2 | 1 | 7 | 1 | 1 | 0 | 8 | 0 | 0 | 0 | 2026-09-20 |
| Foundational concepts | 8 | 17 | 22 | 12 | 0 | 0 | 5 | 0 | 0 | 0 | 0 | 0 | 2026-08-29 |

</details>

## Status

Currently expanding first-contact and integration coverage across Docker Buildx Bake, Helm values, Jenkins SCM-backed pipelines, Grafana provisioning, Terragrunt layouts, and Python async tooling.

---

_Last updated: 2026-09-21_