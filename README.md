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

- [Terraform dynamic inventory for Ansible](ansible/manifests/terraform-dynamic-inventory.yaml) — builds the Ansible inventory straight from Terraform workspace outputs, no CLI or backend credentials on the control node
- [Comparing environment-aware Python config](python/notebooks/comparing-env-aware-config.ipynb) — typed settings classes vs layered loaders vs minimal env readers, side by side
- [Reusable composite action caller](gha/configs/reusable-composite-action-caller.yaml) — example caller showing defaults, per-call overrides, and outputs from a shared action
- [Reusable composite action](gha/configs/reusable-composite-action/action.yml) — Node toolchain install with npm cache, smoke test, and optional artifact upload
- [Ansible role scaffold with Molecule](ansible/templates/ansible-role-molecule-collection/README.md) — copy-in role layout with Molecule tests, collection packaging, and a Terraform-outputs handoff

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
`scripting-automation-philosophy/` — companion app config for the scripting deploy-checklist snippet.
`tf/` — provider configs, null resources, multi-resource setups, and state-lock workflow scripts.

## Coverage

<details>
<summary>Coverage table</summary>

| Tool | notes | docs | scripts | configs | manifests | notebooks | dockerfiles | templates | src | hooks | snippets | Last verified |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Ansible | 3 | 1 | 2 | 4 | 1 | — | — | 16 | — | — | — | 2026-09-17 |
| Bash | 3 | 6 | 8 | — | — | 3 | 1 | 30 | — | — | 1 | 2026-09-09 |
| Docker | 5 | 1 | 6 | — | 1 | — | 2 | — | 2 | — | — | 2026-09-07 |
| GitHub Actions | 3 | 3 | — | 6 | — | 1 | — | — | — | — | — | 2026-09-16 |
| Git | 16 | 9 | 6 | — | 1 | — | — | 15 | — | 1 | — | 2026-09-13 |
| Grafana | 4 | 1 | — | 5 | 1 | 1 | — | — | — | — | 3 | 2026-09-16 |
| Helm | 5 | 2 | 1 | 6 | 2 | 1 | — | — | — | — | 1 | 2026-09-13 |
| Jenkins | 4 | — | — | 1 | — | — | — | — | — | — | 2 | 2026-09-06 |
| Kubernetes | 5 | 2 | 3 | 1 | 3 | 1 | 1 | — | — | — | 2 | 2026-09-16 |
| Prometheus | 4 | — | 1 | 4 | — | — | — | — | — | — | 1 | 2026-09-03 |
| Python | 3 | 3 | 4 | 4 | — | 1 | 1 | 8 | — | — | 4 | 2026-09-17 |
| Terraform | 4 | 3 | 2 | 6 | — | — | — | — | — | — | 1 | 2026-09-12 |
| Repo-doc | 2 | 2 | 2 | — | — | — | — | — | — | — | — | 2026-09-10 |
| Concepts | — | 22 | 22 | — | — | 5 | — | — | — | — | 12 | 2026-09-16 |

</details>

## Status

Currently working through L4–L5 first-contact notes for Ansible, Python, and GitHub Actions. Recent additions include a Terraform dynamic inventory manifest for the provision-to-configure handoff, an environment-aware Python config notebook, a reusable composite action with a caller workflow, and a Molecule-tested Ansible role scaffold with collection packaging.

---
_Last updated: 2026-09-17_
