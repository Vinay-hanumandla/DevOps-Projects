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

- [OIDC token exchange](gha/docs/oidc-token-exchange.md) — replacing long-lived cloud keys in workflows with short-lived tokens, including the trust relationship you configure on the other side.
- [Labeled-issue JavaScript action](gha/scripts/custom-js-action/action.yml) — a real custom action: validated inputs, three outputs, and a Node entrypoint that talks to the REST API.
- [Shared shell lint-and-test composite action](gha/configs/shared-shell-ci/action.yml) — reusable action that runs ShellCheck and shell tests with independently toggleable stages and outputs callers can gate on.
- [Shared shell CI caller workflow](gha/configs/shared-shell-ci-caller.yaml) — example caller showing zero-argument defaults, per-call overrides, and downstream jobs gated on the shared action's outputs.
- [Helm values merge: `--set` vs `-f`](helm/notes/2026-09-21-values-merge-set-vs-file.md) — which value source actually wins, settled by rendering a scratch chart and reading the output.

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
| Ansible | 3 | 4 | 4 | 1 | 4 | 1 | 0 | 0 | 15 | 0 | 0 | 0 | 2026-09-23 |
| Bash | 3 | 6 | 10 | 2 | 0 | 0 | 4 | 1 | 30 | 0 | 0 | 0 | 2026-09-23 |
| Docker | 5 | 3 | 7 | 0 | 0 | 2 | 0 | 4 | 25 | 2 | 0 | 1 | 2026-09-21 |
| GitHub Actions | 3 | 4 | 4 | 1 | 8 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 2026-09-25 |
| Git | 16 | 11 | 6 | 0 | 0 | 1 | 0 | 0 | 14 | 0 | 1 | 0 | 2026-09-21 |
| Grafana | 4 | 1 | 1 | 3 | 6 | 2 | 1 | 0 | 0 | 0 | 0 | 0 | 2026-09-21 |
| Helm | 6 | 2 | 1 | 1 | 7 | 2 | 1 | 0 | 0 | 0 | 0 | 0 | 2026-09-21 |
| Jenkins | 5 | 3 | 2 | 3 | 3 | 0 | 0 | 0 | 5 | 0 | 0 | 0 | 2026-09-23 |
| Kubernetes | 5 | 4 | 3 | 2 | 1 | 4 | 1 | 1 | 10 | 0 | 0 | 0 | 2026-09-19 |
| Prometheus | 4 | 2 | 2 | 1 | 6 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-21 |
| Python | 3 | 3 | 4 | 4 | 4 | 0 | 2 | 1 | 7 | 0 | 0 | 0 | 2026-09-20 |
| repo-doc | 4 | 2 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-23 |
| Scripting companion | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-16 |
| Terraform | 4 | 4 | 2 | 1 | 7 | 1 | 1 | 0 | 8 | 0 | 0 | 0 | 2026-09-22 |
| Foundational concepts | 8 | 17 | 22 | 12 | 0 | 0 | 5 | 0 | 0 | 0 | 0 | 0 | 2026-09-16 |

</details>

## Status

Currently working through GitHub Actions authentication — OIDC token exchange against cloud providers and Vault, plus a worked custom JavaScript action that validates its inputs and returns structured results.

---

_Last updated: 2026-09-25_
