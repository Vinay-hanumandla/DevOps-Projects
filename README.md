# DevOps Projects
> A working DevOps engineer's shelf for Git, Bash, Docker, Compose, Kubernetes, Helm, Terraform, Ansible, AWX, Jenkins, Prometheus, and the tools that connect them.

[![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects/commits/main) [![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects) [![Language count](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects) [![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for Git, Bash, Docker, Compose, Kubernetes, Helm, Helm Charts, Terraform, Terraform Cloud, Ansible, AWX, GitHub Actions, Jenkins, Prometheus, Kube-Prometheus, Grafana, and Python.
Use it as a shelf you grab from while designing, debugging, or reviewing a system — not as a tutorial site, and not as a substitute for any tool's official documentation.
It deliberately leaves out credentials, environment secrets, and a walkthrough for every product it touches.

## What's in here

Notes, scripts, configs, manifests, and reusable templates for the tooling a DevOps engineer actually operates: version control and shell first, then containers and orchestration, then infrastructure as code and CI/CD, with observability and dashboarding on top.
`docs/concepts/` holds the conceptual spine — eight foundational primers, each with runnable companions — and every tool folder holds the material you reach for when putting those ideas into practice.
The `templates/` subfolders are copy-in starting points: a chart, a role, a collection, a repository, or a release workflow you can adopt wholesale rather than write from scratch.

## Quick links

- [Moving Jenkinsfile from inline to SCM](jenkins/docs/moving-jenkinsfile-from-inline-to-scm-script-path-branch-lightweight-checkout-credential-gotchas.md) — script paths, branches, lightweight checkout, and credential gotchas when moving from inline pipeline to a Jenkinsfile in SCM.
- [Shared library reusable steps scaffold — Jenkinsfile](jenkins/templates/shared-library-reusable-steps-dsl-scaffold/Jenkinsfile) — entry point for the shared-library scaffold demonstrating reusable steps and DSL patterns.
- [Shared library reusable steps scaffold — README](jenkins/templates/shared-library-reusable-steps-dsl-scaffold/README.md) — structure and usage of the shared-library scaffold template.
- [Shared library pipeline template — simple Jenkinsfile](jenkins/templates/shared-library-reusable-steps-dsl-scaffold/pipeline-templates/simple/Jenkinsfile) — simple pipeline template that consumes shared-library reusable steps.
- [Shared library utility](jenkins/templates/shared-library-reusable-steps-dsl-scaffold/src/com/example/jenkinslib/Utils.groovy) — example Groovy utility class in the shared-library scaffold.

## Layout

- `00_index/` — the map, quick links, glossary, and learning path for the kit.
- `docs/concepts/` — foundational concept primers and cross-tool integration patterns.
- `ansible/` — idempotent automation, collections, inventories, execution environments, and Kubernetes handoffs.
- `awx/` — job templates, inventories, credentials, and the API behind the Tower control plane.
- `bash/` — shell fundamentals, robust script patterns, debugging, and reusable scaffolds.
- `compose/` — Docker Compose first-contact notes and a minimal multi-service starting file.
- `docker/` — images, Compose, Buildx, registries, and container delivery patterns.
- `gha/` — GitHub Actions workflows, reusable actions, triggers, and local debugging.
- `git/` — repositories, branches, hooks, worktrees, releases, and CI integration.
- `grafana/` — dashboards, provisioning, alerts, and Jsonnet-oriented dashboard code.
- `hchart/` — Helm Charts packaging: chart anatomy, releases, values, templates, hooks, and repositories.
- `helm/` — chart structure, values, templates, testing, and registry workflows.
- `jenkins/` — controllers, jobs, declarative pipelines, credentials, and SCM-backed Jenkinsfiles.
- `k8s/` — Kubernetes objects, kubectl, Helm/Argo CD flows, and local clusters.
- `kprom/` — Kube-Prometheus stack: the kube-prometheus-stack chart, local values, and notes for cluster-native Prometheus + Grafana + Alertmanager on Kubernetes.
- `prom/` — Prometheus setup, PromQL, service discovery, and alerting.
- `python/` — Python fundamentals, configuration, async tooling, and DevOps integrations.
- `repo-doc/` — repository coverage and documentation-maintenance utilities.
- `scripting-automation-philosophy/` — the companion config for the scripting deploy-checklist snippet.
- `tf/` — Terraform projects, state, validation, manifests, reusable module scaffolding, and Terragrunt layouts.
- `tfc/` — Terraform Cloud workspaces, remote runs, and variables for the hosted Terraform service.

## Coverage

Counts include files nested inside template trees. `Src` and `Hooks` are support locations that only a few tools use. A folder's total (see `00_index/topics.md`) also counts root-level support dotfiles such as `docker/.dockerignore`, which has no category column here.
In the `docs/concepts/` row, `Notes` counts the eight foundational primers alongside their companion notes and `Docs` the cross-tool concept articles.

<details>
<summary>Coverage table</summary>

| Area | Notes | Docs | Scripts | Snippets | Configs | Manifests | Notebooks | Dockerfiles | Templates | Src | Hooks | Last verified |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Ansible | 3 | 6 | 5 | 1 | 4 | 3 | 1 | 0 | 28 | 0 | 0 | 2026-10-05 |
| AWX | 4 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-12 |
| Bash | 3 | 8 | 12 | 3 | 0 | 0 | 6 | 1 | 30 | 0 | 0 | 2026-10-10 |
| Compose | 2 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-14 |
| Docker | 5 | 5 | 8 | 0 | 0 | 3 | 0 | 5 | 36 | 2 | 0 | 2026-10-11 |
| GitHub Actions | 3 | 5 | 6 | 1 | 11 | 2 | 1 | 0 | 0 | 0 | 0 | 2026-10-03 |
| Git | 16 | 13 | 7 | 0 | 0 | 1 | 1 | 0 | 18 | 0 | 1 | 2026-10-14 |
| Grafana | 4 | 2 | 1 | 3 | 6 | 3 | 1 | 1 | 8 | 0 | 0 | 2026-10-06 |
| Helm | 6 | 3 | 1 | 1 | 7 | 3 | 1 | 0 | 19 | 0 | 0 | 2026-09-26 |
| Helm Charts | 2 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-14 |
| Jenkins | 5 | 3 | 2 | 3 | 3 | 0 | 0 | 0 | 37 | 0 | 0 | 2026-10-14 |
| Kubernetes | 6 | 6 | 3 | 2 | 1 | 6 | 2 | 1 | 20 | 0 | 0 | 2026-10-12 |
| Kube-Prometheus | 3 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 2026-10-12 |
| Prometheus | 4 | 4 | 2 | 1 | 8 | 2 | 0 | 0 | 10 | 0 | 0 | 2026-10-14 |
| Python | 3 | 4 | 4 | 5 | 4 | 0 | 3 | 1 | 23 | 0 | 0 | 2026-10-03 |
| Repo-doc | 5 | 4 | 5 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-11 |

</details>

---
_Last updated: 2026-10-19_
