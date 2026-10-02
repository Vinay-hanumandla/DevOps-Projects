# DevOps Projects
> A working DevOps engineer's shelf for Git, Bash, Docker, Kubernetes, Terraform, Ansible, and the tools that connect them.

[![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects/commits/main) [![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects) [![Language count](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects) [![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)](https://github.com/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for Git, Bash, Docker, Kubernetes, Helm, Terraform, Ansible, GitHub Actions, Jenkins, Prometheus, Grafana, and Python.
Use it as a shelf you grab from while designing, debugging, or reviewing a system — not as a tutorial site, and not as a substitute for any tool's official documentation.
It deliberately leaves out credentials, environment secrets, and a walkthrough for every product it touches.

## What's in here

Notes, scripts, configs, manifests, and reusable templates for the tooling a DevOps engineer actually operates: version control and shell first, then containers and orchestration, then infrastructure as code and CI/CD, with observability and dashboarding on top.
`docs/concepts/` holds the conceptual spine — eight foundational primers, each with runnable companions — and every tool folder holds the material you reach for when putting those ideas into practice.
The `templates/` subfolders are copy-in starting points: a chart, a role, a collection, a repository, or a release workflow you can adopt wholesale rather than write from scratch.

## Quick links

- [Signed image promotion for GitOps](docker/manifests/gitops-image-promotion.yaml) — moves one built digest through dev → staging → prod without rebuilding, verifying its signature before each step and recording the reference the deployment repo pins.
- [Production distroless image with vulnerability gate](docker/dockerfiles/production-distroless-vuln-gated.Dockerfile) — Go build in named build/test stages with a non-root distroless runtime, SBOM attestation, and a scan gate before the digest is promoted.
- [Microservices multistage scaffold](docker/templates/microservices-multistage-scaffold/README.md) — a Compose stack where every built service uses a two-stage Dockerfile, with health-gated startup and file-based secrets.
- [Retry with circuit breaker](bash/scripts/retry-with-circuit-breaker.sh) — wraps any command in jittered exponential-backoff retries and stops calling a dependency after enough consecutive failures.
- [Coproc, FIFO, and nameref patterns](bash/snippets/coproc-fifo-and-named-variables.sh) — a long-lived coproc worker, a kernel-scheduled FIFO pool, and dispatch without eval or globals.

## Layout

- `00_index/` — the map, quick links, glossary, and learning path for the kit.
- `docs/concepts/` — foundational concept primers and cross-tool integration patterns.
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
- `scripting-automation-philosophy/` — the companion config for the scripting deploy-checklist snippet.
- `tf/` — Terraform projects, state, validation, manifests, and Terragrunt layouts.

## Coverage

Counts include files nested inside template trees. `Src`, `Hooks`, and `Other` are support locations that only a few tools use.
In the `docs/concepts/` row, the `Notes` column holds the eight foundational primers and `Docs` the cross-tool concept articles; `Other` covers their companion notes and follow-on docs.

<details>
<summary>Coverage table</summary>

| Area | Notes | Docs | Scripts | Snippets | Configs | Manifests | Notebooks | Dockerfiles | Templates | Src | Hooks | Other | Last verified |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Ansible | 3 | 5 | 5 | 1 | 4 | 2 | 0 | 0 | 21 | 0 | 0 | 0 | 2026-09-30 |
| Bash | 3 | 7 | 12 | 3 | 0 | 0 | 5 | 1 | 30 | 0 | 0 | 0 | 2026-09-30 |
| Docker | 5 | 3 | 7 | 0 | 0 | 3 | 0 | 5 | 36 | 2 | 0 | 1 | 2026-10-01 |
| GitHub Actions | 3 | 4 | 4 | 1 | 9 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 2026-09-26 |
| Git | 16 | 12 | 7 | 0 | 0 | 1 | 0 | 0 | 18 | 0 | 1 | 0 | 2026-09-30 |
| Grafana | 4 | 1 | 1 | 3 | 6 | 2 | 1 | 0 | 0 | 0 | 0 | 0 | 2026-09-21 |
| Helm | 6 | 3 | 1 | 1 | 7 | 3 | 1 | 0 | 19 | 0 | 0 | 0 | 2026-09-26 |
| Jenkins | 5 | 3 | 2 | 3 | 3 | 0 | 0 | 0 | 5 | 0 | 0 | 0 | 2026-09-23 |
| Kubernetes | 5 | 4 | 3 | 2 | 1 | 4 | 1 | 1 | 10 | 0 | 0 | 0 | 2026-09-19 |
| Prometheus | 4 | 3 | 2 | 1 | 7 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-28 |
| Python | 3 | 3 | 4 | 4 | 4 | 0 | 2 | 1 | 7 | 0 | 0 | 0 | 2026-09-20 |
| Repo-doc | 4 | 3 | 3 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-26 |
| Terraform | 4 | 4 | 2 | 1 | 7 | 1 | 1 | 0 | 8 | 0 | 0 | 0 | 2026-09-22 |
| Scripting companion | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2026-09-16 |
| Foundational concepts | 8 | 13 | 22 | 12 | 0 | 0 | 5 | 0 | 0 | 0 | 0 | 4 | 2026-09-16 |

</details>

## Status

Currently hardening the image-supply side of the story: Dockerfiles that ship a non-root distroless runtime with an SBOM attestation and a vulnerability-scan gate, and a signed promotion manifest that moves one digest through dev → staging → prod without rebuilding. Just landed: the promotion manifest and the vuln-gated distroless Dockerfile, on top of the microservices multistage scaffold and the Bash retry-with-breaker work.

---
_Last updated: 2026-10-02_
