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

- [GitOps image build, sign, and push](docker/manifests/gitops-image-build-and-push.yaml) — in-cluster Job pipeline that builds an image, signs it, pushes by immutable digest, and records the reference for the deployment repo to pin
- [Production distroless Dockerfile with SBOM](docker/dockerfiles/production-distroless-sbom.Dockerfile) — multi-stage Go build, Syft-generated SPDX bill of materials, and a non-root distroless runtime
- [Multi-service Compose app scaffold](docker/templates/multi-service-compose-app/README.md) — copy-in stack (web front, API, database, cache) with health-gated startup, file-based secrets, and a tools profile for one-shot helpers
- [Gated playbook run](ansible/scripts/ansible-playbook-gated-run.sh) — syntax-check, check-mode dry run, and optional lint before the apply, then an idempotency rerun that must report changed=0
- [Managing Kubernetes with Ansible](ansible/docs/managing-kubernetes-with-ansible.md) — raw manifests and CRDs, Helm releases, and Kustomize overlays through the kubernetes.core collection

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

> Counts below were regenerated from the filesystem on 2026-09-18 and include every file under each tool's category folders (recursively, so scaffolded template trees under `templates/` are counted in full).

## Coverage

<details>
<summary>Coverage table</summary>

| Tool | notes | docs | scripts | configs | manifests | notebooks | dockerfiles | templates | src | hooks | snippets | Last verified |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Ansible | 3 | 2 | 4 | 4 | 1 | — | — | 16 | — | — | — | 2026-09-18 |
| Bash | 3 | 6 | 11 | — | — | 3 | 1 | 30 | — | — | 1 | 2026-09-18 |
| Docker | 5 | 1 | 7 | — | 2 | — | 3 | 10 | 2 | — | — | 2026-09-18 |
| GitHub Actions | 3 | 3 | — | 5 | — | 1 | — | — | — | — | — | 2026-09-18 |
| Git | 16 | 9 | 9 | — | 1 | — | — | 15 | — | 4 | — | 2026-09-18 |
| Grafana | 4 | 1 | — | 5 | 1 | 1 | — | — | — | — | 3 | 2026-09-18 |
| Helm | 5 | 2 | 1 | 6 | 2 | 1 | — | — | — | — | 1 | 2026-09-18 |
| Jenkins | 4 | — | — | 1 | — | — | — | — | — | — | 2 | 2026-09-18 |
| Kubernetes | 5 | 2 | 3 | 1 | 3 | 1 | 1 | — | — | — | 2 | 2026-09-18 |
| Prometheus | 4 | 1 | 2 | 6 | — | — | — | — | — | — | 1 | 2026-09-18 |
| Python | 3 | 3 | 4 | 4 | — | 1 | 1 | 8 | — | — | 4 | 2026-09-18 |
| Terraform | 4 | 3 | 2 | 6 | — | — | — | — | — | — | 1 | 2026-09-18 |
| Repo-doc | 2 | 2 | 2 | — | — | — | — | — | — | — | — | 2026-09-18 |
| Concepts | — | 22 | 22 | — | — | 5 | — | — | — | — | 12 | 2026-09-18 |

</details>

## Status

Currently working through L4–L5 first-contact notes for Ansible, Python, and GitHub Actions. Recent additions round out the Docker shelf: an in-cluster GitOps build-sign-push manifest that records an immutable image reference, a production distroless Dockerfile with a Syft-generated SBOM, and a multi-service Compose app scaffold with health-gated startup and file-based secrets.

---
_Last updated: 2026-09-18_
