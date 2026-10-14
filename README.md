# DevOps Projects
> A working DevOps engineer's shelf for Git, Bash, Docker, Kubernetes, Helm, Terraform, Ansible, AWX, and the tools that connect them.

[![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects/commits/main) [![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects) [![Language count](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects) [![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for Git, Bash, Docker, Kubernetes, Helm, Terraform, Ansible, AWX, GitHub Actions, Jenkins, Prometheus, Kube-Prometheus, Grafana, and Python.
Use it as a shelf you grab from while designing, debugging, or reviewing a system — not as a tutorial site, and not as a substitute for any tool's official documentation.
It deliberately leaves out credentials, environment secrets, and a walkthrough for every product it touches.

## What's in here

Notes, scripts, configs, manifests, and reusable templates for the tooling a DevOps engineer actually operates: version control and shell first, then containers and orchestration, then infrastructure as code and CI/CD, with observability and dashboarding on top.
`docs/concepts/` holds the conceptual spine — eight foundational primers, each with runnable companions — and every tool folder holds the material you reach for when putting those ideas into practice.
The `templates/` subfolders are copy-in starting points: a chart, a role, a collection, a repository, or a release workflow you can adopt wholesale rather than write from scratch.
The `awx/` folder covers the Tower-side control plane — job templates, inventories, and credentials — for teams that have outgrown running playbooks by hand.
The `kprom/` folder wraps the kube-prometheus-stack Helm chart for cluster-native monitoring with Prometheus, Grafana, and Alertmanager.

## Quick links

- [Terraform GitHub Actions plan/apply pipeline with remote backend and environment approvals](tf/docs/terraform-github-actions-plan-apply-pipeline-remote-backend-environment-approvals.md) — wiring a Terraform workflow to a remote backend with mandatory environment approvals for production, so plan and apply stay gated behind review.
- [Terraform validation gate script](tf/scripts/tf-validation-gate.sh) — wraps `terraform validate` and `terraform fmt -check` so a CI job can reject a config before it reaches plan.
- [Versioned VPC module manifest](tf/manifests/versioned-vpc-module.hcl) — a reusable VPC module pinned to a version source, with public and private subnets, NAT gateways, and route tables.
- [Kubernetes service discovery with recording rules and Alertmanager routing](prom/manifests/k8s-service-discovery-recording-rules-alertmanager.yaml) — node discovery, kube-state-metrics and blackbox scrape jobs, recording rules feeding alerts, and a two-receiver routing tree with `promtool`/`amtool` checks.
- [Service mesh, ingress, and DNS networking](k8s/notebooks/service-mesh-ingress-dns-networking.ipynb) — the three layers that decide where cluster traffic goes, each paired with a runnable model so the routing rule shows in behaviour.

## Layout

- `00_index/` — the map, quick links, glossary, and learning path for the kit.
- `docs/concepts/` — foundational concept primers and cross-tool integration patterns.
- `ansible/` — idempotent automation, collections, inventories, execution environments, and Kubernetes handoffs.
- `awx/` — job templates, inventories, credentials, and the API behind the Tower control plane.
- `bash/` — shell fundamentals, robust script patterns, debugging, and reusable scaffolds.
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

## Coverage

Counts include files nested inside template trees. `Src` and `Hooks` are support locations that only a few tools use. A folder's total (see `00_index/topics.md`) also counts root-level support dotfiles such as `docker/.dockerignore`, which has no category column here.
In the `docs/concepts/` row, `Notes` counts the eight foundational primers alongside their companion notes and `Docs` the cross-tool concept articles.

<details>
<summary>Coverage table</summary>

| Area | Notes | Docs | Scripts | Snippets | Configs | Manifests | Notebooks | Dockerfiles | Templates | Src | Hooks | Last verified |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Ansible | 3 | 6 | 5 | 1 | 4 | 3 | 1 | 0 | 28 | 0 | 0 | 2026-10-05 |
| AWX | 4 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-11 |
| Bash | 3 | 8 | 12 | 3 | 0 | 0 | 6 | 1 | 30 | 0 | 0 | 2026-10-10 |
| Docker | 5 | 5 | 8 | 0 | 0 | 3 | 0 | 5 | 36 | 2 | 0 | 2026-10-11 |
| GitHub Actions | 3 | 5 | 6 | 1 | 11 | 2 | 1 | 0 | 0 | 0 | 0 | 2026-10-03 |
| Git | 16 | 13 | 7 | 0 | 0 | 1 | 1 | 0 | 18 | 0 | 1 | 2026-10-14 |
| Grafana | 4 | 2 | 1 | 3 | 6 | 3 | 1 | 1 | 8 | 0 | 0 | 2026-10-05 |
| Helm | 6 | 3 | 1 | 1 | 7 | 3 | 1 | 0 | 19 | 0 | 0 | 2026-09-26 |
| Helm Charts | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-14 |
| Jenkins | 5 | 3 | 2 | 3 | 3 | 0 | 0 | 0 | 37 | 0 | 0 | 2026-10-14 |
| Kubernetes | 6 | 6 | 3 | 2 | 1 | 6 | 2 | 1 | 20 | 0 | 0 | 2026-10-12 |
| Kube-Prometheus | 3 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 2026-10-10 |
| Prometheus | 4 | 4 | 2 | 1 | 8 | 2 | 0 | 0 | 10 | 0 | 0 | 2026-10-14 |
| Python | 3 | 4 | 4 | 5 | 4 | 0 | 3 | 1 | 23 | 0 | 0 | 2026-10-03 |
| Repo-doc | 5 | 4 | 5 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-11 |
| Terraform | 4 | 5 | 3 | 1 | 7 | 2 | 1 | 0 | 34 | 0 | 0 | 2026-10-14 |
| Scripting companion | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | — |
| Foundational concepts | 11 | 14 | 22 | 12 | 0 | 0 | 5 | 0 | 0 | 0 | 0 | 2026-09-16 |

</details>

## Status

Currently working through Terraform CI wiring and cluster monitoring: a Terraform GitHub Actions plan/apply pipeline with a remote backend and mandatory environment approvals for production, a validation gate script that rejects unformatted or invalid configs before they reach plan, and a versioned VPC module manifest pinning a reusable module to a version source. Also active: a Prometheus manifest wiring node discovery, kube-state-metrics and blackbox probes, recording rules, and Alertmanager routing end to end, plus an AWX custom execution environment with host mounts, pull policy, and registry login on the custom resource.

---
_Last updated: 2026-10-13_
