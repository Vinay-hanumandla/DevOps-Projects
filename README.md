# DevOps Projects
> A working DevOps engineer's shelf for Git, Bash, Docker, Kubernetes, Terraform, Ansible, and the tools that connect them.

[![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects/commits/main) [![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects) [![Language count](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects) [![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable examples, and configs for Git, Bash, Docker, Kubernetes, Terraform, Ansible, GitHub Actions, Jenkins, Prometheus, Grafana, Python, and more.
Use it as a shelf you grab from while designing, debugging, or reviewing a system — not as a substitute for each tool's official docs.
It deliberately leaves out customer-specific credentials, environment secrets, and a full tutorial for every product.

## What's in here

This kit is organized around Git, Bash, Docker, GitHub Actions, Jenkins, Kubernetes, Helm, Terraform, Ansible, Prometheus, Grafana, Python, repo-doc, and foundational DevOps concepts.
The repository holds content files across notes, docs, scripts, snippets, configs, manifests, notebooks, Dockerfiles, and reusable templates.
`docs/concepts/` holds the conceptual spine; each tool folder holds the material you reach for when putting those ideas into practice.

## Quick links

- [Terraform — module composition patterns](tf/docs/module-composition-patterns.md) — composing Terraform modules with fan-out patterns and shared state boundaries.
- [Prometheus local monitoring stack](prom/manifests/local-monitoring-stack.yaml) — a one-shot Prometheus + Alertmanager + Node Exporter stack for local evaluation.
- [Git — signed commits and CI provenance](git/docs/signed-commits-and-ci-provenance.md) — signing commits and verifying build origins in CI.
- [Helm — values merge: set vs file](helm/notes/2026-09-21-values-merge-set-vs-file.md) — how `--set` and `--values` interact, and when each wins.
- [Helm — minimal static web app values](helm/configs/2026-09-21-minimal-static-web-app-values.yaml) — slim nginx Helm values with ConfigMap-backed static content.

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
- `scripting-automation-philosophy/` — the companion note for repeatable automation habits.
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
| Git | 16 | 11 | 6 | 0 | 0 | 1 | 0 | 0 | 12 | 0 | 1 | 0 | 2026-09-21 |
| Grafana | 4 | 1 | 1 | 3 | 6 | 2 | 1 | 0 | 0 | 0 | 0 | 0 | 2026-09-16 |
| Helm | 6 | 2 | 1 | 1 | 7 | 2 | 1 | 0 | 0 | 0 | 0 | 0 | 2026-09-21 |
| Jenkins | 4 | 2 | 0 | 3 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-21 |
| Kubernetes | 5 | 4 | 3 | 2 | 1 | 4 | 1 | 1 | 10 | 0 | 0 | 0 | 2026-09-19 |
| Prometheus | 4 | 2 | 2 | 1 | 6 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-19 |
| Python | 3 | 3 | 4 | 4 | 4 | 0 | 2 | 1 | 7 | 0 | 0 | 0 | 2026-09-14 |
| repo-doc | 3 | 2 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-21 |
| Scripting companion | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-16 |
| Terraform | 4 | 4 | 2 | 1 | 7 | 1 | 1 | 0 | 8 | 0 | 0 | 0 | 2026-09-22 |
| Foundational concepts | 8 | 17 | 22 | 12 | 0 | 0 | 5 | 0 | 0 | 0 | 0 | 0 | 2026-09-22 |

</details>

## Status

Currently expanding first-contact and integration coverage across Docker Buildx Bake, Helm values, Jenkins SCM-backed pipelines, Grafana provisioning, Terragrunt layouts, and Python async tooling.

---

_Last updated: 2026-09-22_
