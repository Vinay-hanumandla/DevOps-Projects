# DevOps-Projects

> A working engineer's devops reference for Ansible, Bash, Docker, Git, GitHub Actions, Helm, Jenkins, Kubernetes, Python, Terraform, Grafana, and Prometheus, plus the foundational concepts they rest on.

---

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, configs, and project scaffolds for Ansible, Bash, Docker, Git, GitHub Actions, Helm, Jenkins, Kubernetes, Python, Terraform, and Grafana/Prometheus, plus primers for the concepts they rest on. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs.

## What's in here

A growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, config, script, or project scaffold built while working through a tool's ecosystem and kept for later. It covers Ansible, Bash, Docker, Git, GitHub Actions, Helm, Jenkins, Kubernetes, Python, Terraform, and Grafana/Prometheus, plus eight foundational concept primers under `docs/concepts/` — each joined by runnable scripts, snippets, and CI/CD + observability notebooks. Four project scaffolds ship as copy-in-and-rename layouts: a Git-based release workflow (`git/templates/release-workflow/`), a Bash + Docker dev toolchain (`bash/templates/bash-docker-scaffold/`), a Bash + Docker multi-container stack whose startup ordering is wired through health checks (`bash/templates/bash-docker-healthcheck-scaffold/`), and a Bash production-scaffold with retry, logging, and test harness (`bash/templates/bash-production-scaffold/`).

---

## Quick links

- [Environment-credentials pipeline (Jenkins)](jenkins/snippets/2026-09-05-environment-credentials-pipeline.groovy) — a Jenkins pipeline snippet using environment credentials binding
- [Minimal declarative Jenkinsfile](jenkins/configs/2026-09-05-minimal-declarative-jenkinsfile.jenkinsfile) — a minimal declarative Jenkins pipeline config
- [Minimal CI workflow (refresh)](gha/configs/2026-09-04-minimal-ci-workflow.yaml) — a refreshed GitHub Actions CI workflow with lint, plan, and lock-handled Terraform apply
- [Terraform init/validate/plan/apply with lock handling](tf/scripts/2026-09-04-tf-init-validate-plan-apply-with-lock-handling.sh) — Terraform workflow script with state-lock handling for CI
- [Multi-resource Terraform config](tf/configs/multi-resource-terraform-config.hcl) — a Terraform config wiring multiple resources through locals and outputs

---

## Layout

- `ansible/` — Ansible material: primer, install notes, playbook configs, and an ad-hoc toolkit script.
- `bash/` — Bash material: primer, notes, docs, scripts, notebooks, a strict-mode runner image, and three Docker project scaffolds (toolchain, health-check stack, and production scaffold).
- `docker/` — Docker material: notes, Dockerfiles, source files, scripts, a multi-service Compose manifest, and a Compose healthcheck ordering doc.
- `docs/concepts/` — foundational primers with runnable scripts, snippets, and notebooks (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `gha/` — GitHub Actions material: primer, install note, workflow configs (including matrix + cache + artifact and a refreshed minimal CI), and docs on debugging and tag-triggered releases.
- `git/` — Git material: notes, docs, scripts, hooks tooling, a release-workflow scaffold, and a pipeline-trigger manifest.
- `grafana/` — Grafana material: primer, install notes, dashboard configs, and API snippets.
- `helm/` — Helm material: primer, install notes, chart snippet, per-environment values overrides, and a chart template.
- `jenkins/` — Jenkins material: primer, install notes, a quickstart follow-up, a declarative Jenkinsfile, and pipeline snippets.
- `k8s/` — Kubernetes material: primer, install notes, kubectl exploration, configs, manifests, scripts, and a resource-listing snippet.
- `prom/` — Prometheus material: primer and install notes, scrape target configs, alerting rules, a PromQL snippet, and a query helper script.
- `python/` — Python material: primer, notes, docs, scripts, snippets, and configs.
- `repo-doc/` — notes on keeping the repository's own docs and coverage tables in sync.
- `tf/` — Terraform material: primer, install notes, configs (including a multi-resource and a null resource), docs, and scripts (including a lock-handled init/validate/plan/apply).
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

---

## Coverage

<details><summary>Coverage table</summary>

| Tool | notes | docs | scripts | snippets | configs | templates | manifests | dockerfiles | src | hooks | notebooks | Last verified |
|------|-------|------|---------|----------|---------|-----------|-----------|-------------|-----|-------|-----------|---------------|
| Ansible | 3 | — | 1 | — | 3 | — | — | — | — | — | — | 2026-08-31 |
| Bash | 3 | 5 | 6 | 1 | — | 30 | — | 1 | — | — | 2 | 2026-08-25 |
| Docker | 5 | 1 | 4 | — | — | — | 1 | 2 | 2 | — | — | 2026-09-04 |
| GitHub Actions | 3 | 3 | — | — | 4 | — | — | — | — | — | — | 2026-09-04 |
| Git | 12 | 6 | 6 | — | — | 6 | 1 | — | 1 | 1 | — | 2026-08-18 |
| Grafana | 4 | — | — | 2 | 5 | — | — | — | — | — | — | 2026-08-30 |
| Helm | 5 | 1 | — | 1 | 4 | — | 1 | — | — | — | — | 2026-08-19 |
| Jenkins | 2 | — | — | 1 | 1 | — | — | — | — | — | — | 2026-09-05 |
| Kubernetes | 4 | 2 | 3 | 1 | 1 | — | 2 | — | — | — | — | 2026-08-27 |
| Prometheus | 4 | — | 1 | 1 | 4 | — | — | — | — | — | — | 2026-09-03 |
| Python | 3 | 2 | 3 | 4 | 1 | — | — | — | — | — | — | 2026-08-25 |
| Terraform | 4 | 2 | 2 | 1 | 5 | — | — | — | — | — | — | 2026-09-04 |
| Repo docs | — | 1 | 1 | — | — | — | — | — | — | — | — | 2026-08-10 |
| Concepts | 20 | 17 | 11 | 9 | — | — | — | — | — | — | 4 | 2026-08-29 |

</details>

---

## Status

All eight concept primers are complete with runnable companions, and four project scaffolds are ready to copy in. The kit covers 12 tools across configuration management, containerization, CI/CD, infrastructure as code, and observability. The newest additions are a declarative Jenkinsfile, an environment-credentials pipeline snippet, a refreshed minimal GHA CI workflow, a Terraform init/validate/plan/apply script with state-lock handling, and a multi-resource Terraform config.

---

_Last updated: 2026-09-05_
