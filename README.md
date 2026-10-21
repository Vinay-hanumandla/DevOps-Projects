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

- [AWX quickstart script](awx/scripts/2026-10-20-awx-quickstart.sh) — End-to-end AWX bootstrap from CR to running job.
- [Ansible execution environment curated collections](ansible/manifests/execution-environment-curated-collections.yaml) — Pinned collections for reproducible EE builds.
- [Ansible requirements](ansible/manifests/requirements.yml) — Galaxy collection dependencies for the curated EE.
- [Ansible requirements.txt](ansible/manifests/requirements.txt) — Python-level dependencies for execution environments.
- [Ansible bindep](ansible/manifests/bindep.txt) — System packages required by the curated execution environment.

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
| Ansible | 3 | 6 | 5 | 1 | 4 | 6 | 1 | 0 | 28 | 0 | 0 | 2026-08-10 |
| AWX | 4 | 0 | 1 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-20 |
| Bash | 3 | 8 | 12 | 3 | 0 | 0 | 6 | 1 | 30 | 0 | 0 | 2026-07-18 |
| Compose | 2 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-14 |
| Docker | 5 | 5 | 8 | 0 | 0 | 3 | 0 | 5 | 36 | 2 | 0 | 2026-07-19 |
| GitHub Actions | 3 | 6 | 6 | 1 | 11 | 2 | 1 | 0 | 6 | 0 | 0 | 2026-08-05 |
| Git | 16 | 14 | 7 | 0 | 0 | 1 | 1 | 0 | 26 | 0 | 1 | 2026-07-20 |
| Grafana | 4 | 2 | 1 | 3 | 6 | 3 | 1 | 1 | 8 | 0 | 0 | 2026-08-06 |
| Helm | 6 | 5 | 3 | 1 | 7 | 3 | 1 | 0 | 28 | 0 | 0 | 2026-07-31 |
| Helm Charts | 2 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-14 |
| Jenkins | 5 | 4 | 2 | 3 | 3 | 0 | 0 | 0 | 45 | 0 | 0 | 2026-08-11 |
| Kubernetes | 6 | 6 | 3 | 2 | 1 | 6 | 2 | 1 | 20 | 0 | 0 | 2026-08-02 |
| Kube-Prometheus | 3 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 2026-10-08 |
| Prometheus | 4 | 4 | 2 | 1 | 8 | 2 | 0 | 0 | 10 | 0 | 0 | 2026-08-07 |
| Python | 3 | 4 | 4 | 5 | 4 | 0 | 3 | 1 | 24 | 0 | 0 | 2026-07-22 |
| Repo-doc | 5 | 5 | 5 | 1 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-01 |
| Terraform | 4 | 5 | 3 | 1 | 7 | 2 | 1 | 0 | 34 | 0 | 0 | 2026-08-01 |
| Terraform Cloud | 2 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-14 |

</details>

## Status

Currently expanding AWX coverage with a quickstart script and execution environment manifests. Ansible execution environment content added this cycle.

---
_Last updated: 2026-10-21_