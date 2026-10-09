# DevOps Projects
> A working DevOps engineer's shelf for Git, Bash, Docker, Kubernetes, Terraform, Ansible, AWX, and the tools that connect them.

[![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects/commits/main) [![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects) [![Language count](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects) [![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for Git, Bash, Docker, Kubernetes, Helm, Terraform, Ansible, AWX, Kube-Prometheus, GitHub Actions, Jenkins, Prometheus, Grafana, and Python.
Use it as a shelf you grab from while designing, debugging, or reviewing a system — not as a tutorial site, and not as a substitute for any tool's official documentation.
It deliberately leaves out credentials, environment secrets, and a walkthrough for every product it touches.

## What's in here

Notes, scripts, configs, manifests, and reusable templates for the tooling a DevOps engineer actually operates: version control and shell first, then containers and orchestration, then infrastructure as code and CI/CD, with observability and dashboarding on top.
`docs/concepts/` holds the conceptual spine — eight foundational primers, each with runnable companions — and every tool folder holds the material you reach for when putting those ideas into practice.
The `templates/` subfolders are copy-in starting points: a chart, a role, a collection, a repository, or a release workflow you can adopt wholesale rather than write from scratch.
The `awx/` folder covers the Tower-side control plane — job templates, inventories, and credentials — for teams that have outgrown running playbooks by hand.

## Quick links

- [Kube-Prometheus primer](kprom/notes/0000-primer-kube-prometheus.md) — what the kube-prometheus-stack chart installs and why you pass it a values file instead of hand-writing scrape configs.
- [Minimal kube-prometheus-stack local values](kprom/configs/2026-10-08-minimal-kube-prometheus-local-values.yaml) — flips Prometheus, Alertmanager, and Grafana to NodePort so the stack is reachable from a laptop on a local cluster.
- [Installing the kube-prometheus stack and exploring Grafana](kprom/notes/2026-10-08-install-kube-prometheus-stack-and-explore-grafana.md) — first cluster install, the dashboard folder the chart provisions at first boot, and the `admin`/`admin` creds gotcha.
- [Project configuration schema](repo-doc/configs/project-configuration-schema.yaml) — the YAML reference declaring the category subdirs, naming conventions, and primer rules every tool folder must follow.
- [Project folder validator](repo-doc/scripts/project-validator.py) — a standard-library Python check that walks each tool folder and confirms it follows the kit's layout conventions.

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
- `helm/` — chart structure, values, templates, testing, and registry workflows.
- `jenkins/` — controllers, jobs, declarative pipelines, credentials, and SCM-backed Jenkinsfiles.
- `k8s/` — Kubernetes objects, kubectl, Helm/Argo CD flows, and local clusters.
- `kprom/` — Kube-Prometheus stack: the kube-prometheus-stack Helm chart that brings Prometheus, Alertmanager, and Grafana onto a cluster from one release.
- `prom/` — Prometheus setup, PromQL, service discovery, and alerting.
- `python/` — Python fundamentals, configuration, async tooling, and DevOps integrations.
- `repo-doc/` — repository coverage and documentation-maintenance utilities.
- `scripting-automation-philosophy/` — the companion config for the scripting deploy-checklist snippet.
- `tf/` — Terraform projects, state, validation, manifests, and Terragrunt layouts.

## Coverage

Counts include files nested inside template trees. `Src` and `Hooks` are support locations that only a few tools use.
In the `docs/concepts/` row, `Notes` counts the eight foundational primers alongside their companion notes and `Docs` the cross-tool concept articles.

<details>
<summary>Coverage table</summary>

| Area | Notes | Docs | Scripts | Snippets | Configs | Manifests | Notebooks | Dockerfiles | Templates | Src | Hooks | Last verified |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Ansible | 3 | 6 | 5 | 1 | 4 | 3 | 1 | 0 | 28 | 0 | 0 | 2026-10-05 |
| AWX | 3 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-07 |
| Bash | 3 | 7 | 12 | 3 | 0 | 0 | 5 | 1 | 30 | 0 | 0 | 2026-09-30 |
| Docker | 5 | 4 | 8 | 0 | 0 | 3 | 0 | 5 | 36 | 2 | 0 | 2026-10-04 |
| GitHub Actions | 3 | 5 | 6 | 1 | 11 | 2 | 1 | 0 | 0 | 0 | 0 | 2026-10-03 |
| Git | 16 | 12 | 7 | 0 | 0 | 1 | 0 | 0 | 18 | 0 | 1 | 2026-09-30 |
| Grafana | 4 | 2 | 1 | 3 | 6 | 3 | 1 | 1 | 8 | 0 | 0 | 2026-10-05 |
| Helm | 6 | 3 | 1 | 1 | 7 | 3 | 1 | 0 | 19 | 0 | 0 | 2026-09-26 |
| Jenkins | 5 | 3 | 2 | 3 | 3 | 0 | 0 | 0 | 5 | 0 | 0 | 2026-09-23 |
| Kubernetes | 6 | 5 | 3 | 2 | 1 | 5 | 1 | 1 | 20 | 0 | 0 | 2026-10-07 |
| Kube-Prometheus | 2 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-08 |
| Prometheus | 4 | 3 | 2 | 1 | 7 | 1 | 0 | 0 | 10 | 0 | 0 | 2026-10-06 |
| Python | 3 | 4 | 4 | 5 | 4 | 0 | 3 | 1 | 23 | 0 | 0 | 2026-10-03 |
| Repo-doc | 5 | 3 | 4 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-10-03 |
| Terraform | 4 | 4 | 2 | 1 | 7 | 1 | 1 | 0 | 8 | 0 | 0 | 2026-09-22 |
| Scripting companion | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | — |
| Foundational concepts | 11 | 14 | 22 | 12 | 0 | 0 | 5 | 0 | 0 | 0 | 0 | 2026-08-29 |

</details>

## Status

Currently working through platform and observability: a Kubernetes secret-management chooser (encrypted-in-git vs vault-sync operator vs volume-mount driver), a one-command kube-prometheus-stack release that brings Prometheus, Alertmanager, and Grafana onto a cluster behind NodePort services, and a baked Grafana image carrying its plugins and datasource. Just landed: the Kube-Prometheus primer and a minimal local values override, a project-configuration schema and folder validator that keep the kit's own conventions checked before a PR goes up, a minimal AWX custom resource for local Minikube, the first job template run on AWX, a production-service scaffold packing HPA, PDB, NetworkPolicy, and namespace budgets behind one Kustomization, and a production cluster hardening manifest with PodSecurity admission and default-deny networking.

---
_Last updated: 2026-10-09_