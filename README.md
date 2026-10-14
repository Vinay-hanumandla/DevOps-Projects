# DevOps Projects
> A working DevOps engineer's shelf for Git, Bash, Docker, Compose, Kubernetes, Helm, Terraform, Ansible, AWX, and the tools that connect them.

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
The `awx/` folder covers the Tower-side control plane — job templates, inventories, and credentials — for teams that have outgrown running playbooks by hand.
The `kprom/` folder wraps the kube-prometheus-stack Helm chart for cluster-native monitoring with Prometheus, Grafana, and Alertmanager.
The `compose/` folder holds first-contact Compose notes and a minimal web-plus-db starting file, `hchart/` unpacks Helm chart anatomy from public charts to minimal installs, and `tfc/` records first contact with Terraform Cloud workspaces and the cloud backend block.

## Quick links

- [Docker Compose primer](compose/notes/0000-primer-compose.md) — what Compose is, services, images, networks, volumes, and the up/down loop for running a web page plus a database together.
- [My first compose up — what tripped me up](compose/notes/2026-10-14-first-compose-up.md) — port-order confusion, service names as hostnames, and remembering `down` after closing the terminal.
- [Minimal web-plus-db Compose file](compose/configs/2026-10-14-web-plus-db.yaml) — two services, nginx on 8080 plus postgres, as the smallest starting point that actually runs.
- [Terraform Cloud primer](tfc/notes/0000-primer-tfc.md) — what the hosted service adds over local Terraform: organisations, workspaces, runs, shared variables, and VCS-triggered plans.
- [Minimal Terraform Cloud backend block](tfc/configs/2026-10-14-minimal-cloud-backend.hcl) — the smallest `cloud` block pointing a config at an organisation and workspace instead of local state.

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
| Terraform | 4 | 5 | 3 | 1 | 7 | 2 | 1 | 0 | 34 | 0 | 0 | 2026-10-14 |
| Terraform Cloud | 2 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-14 |
| Scripting companion | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | — |
| Foundational concepts | 11 | 14 | 22 | 12 | 0 | 0 | 5 | 0 | 0 | 0 | 0 | 2026-09-16 |

</details>

## Status

Currently covering first contact with Docker Compose and Terraform Cloud: a two-service Compose file with port and hostname gotchas written down, and workspaces plus the minimal cloud backend block for hosted Terraform runs. Alongside that, Helm chart anatomy from a public chart teardown and a Jenkins shared-library scaffold with a Docker test harness and versioned pipeline templates.

---
_Last updated: 2026-10-15_
