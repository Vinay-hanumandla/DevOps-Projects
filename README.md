# DevOps-Projects
> A working engineer's DevOps reference for Ansible, Bash, Docker, Git, GitHub Actions, Helm, Kubernetes, Python, Terraform, Grafana, and Prometheus, plus the foundational concepts they rest on.

![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)
![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)
![Languages](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)
![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)

> **New here? Start at [the learning path](00_index/learning-path.md).** It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for Ansible, Bash, Docker, Git, GitHub Actions, Helm, Kubernetes, Python, Terraform, and Grafana/Prometheus, plus primers for the concepts they rest on. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs.

## What's in here

A growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, config, or script built while following a tool's quickstart and kept for later. It covers Ansible, Bash, Docker, Git, GitHub Actions, Helm, Kubernetes, Python, Terraform, and Grafana/Prometheus, plus eight foundational concept primers under docs/concepts/ — each joined by runnable scripts, snippets, and a CI/CD + Observability notebook.

## Quick links

- [Git — my first file index](git-doc/docs/2026-08-10-git-index.md) — how I catalogued every file in the Git learning folder and built a coverage table
- [Helm — coverage check](helm-doc/docs/2026-08-10-helm-coverage.md) — how I compared the Helm folder against the manifest and fixed the coverage counts
- [First Ansible primer](ansible/notes/0000-primer-ansible.md) — first-day notes for Ansible: control node, managed node, playbook, inventory, modules, tasks, and roles
- [Installing Ansible and running my first command](ansible/notes/2026-08-10-install-ansible-and-run-first-command.md) — pipx install, first ping command, and the PEP 668 trap
- [First ping playbook config](ansible/configs/2026-08-10-first-ping-playbook.yaml) — minimal Ansible playbook to verify SSH connectivity to managed hosts

## Layout

- `ansible/` — Ansible material: primer, install notes, and first playbook config.
- `bash/` — Bash material: primer, notes, docs, and scripts.
- `docker/` — Docker material: notes, Dockerfiles, source files, and scripts.
- `docs/concepts/` — foundational primers with runnable scripts, snippets, and a notebook (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `gha/` — GitHub Actions material: primer, install note, and workflow config.
- `git/` — Git material: notes, docs, scripts, and hooks tooling.
- `git-doc/` — Git file index and coverage docs.
- `grafana/` — Grafana material: primer and install notes, plus a first dashboard config.
- `helm/` — Helm material: primer, install note, chart snippet, and values override config.
- `helm-doc/` — Helm coverage and manifest docs.
- `k8s/` — Kubernetes material: primer, install note, kubectl exploration, and manifests.
- `prom/` — Prometheus material: primer and install notes, plus a first scrape target config.
- `python/` — Python material: primer, docs, scripts, and snippets.
- `tf/` — Terraform material: install note, primer, first config, and project structure docs.
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

<details><summary>Coverage table</summary>

| Tool | notes | docs | scripts | snippets | configs | manifests | dockerfiles | src | notebooks | Last verified |
|------|-------|------|---------|----------|---------|-----------|-------------|-----|-----------|---------------|
| Ansible | 2 | — | — | — | 1 | — | — | — | — | 2026-08-10 |
| Bash | 3 | 2 | 6 | 1 | — | — | — | — | — | 2026-07-30 |
| Docker | 5 | — | 3 | — | — | — | 1 | 2 | — | 2026-08-06 |
| Git | 12 | 3 | 4 | — | — | — | — | — | — | 2026-08-08 |
| GitHub Actions | 3 | 1 | — | — | 2 | — | — | — | — | 2026-08-06 |
| Grafana | 2 | — | — | — | 1 | — | — | — | — | 2026-08-06 |
| Helm | 3 | — | — | 1 | 1 | — | — | — | — | 2026-08-08 |
| Kubernetes | 4 | 1 | 2 | — | — | 1 | — | — | — | 2026-08-04 |
| Prometheus | 2 | — | — | — | 1 | — | — | — | — | 2026-08-07 |
| Python | 2 | 1 | 2 | 1 | — | — | — | — | — | 2026-08-04 |
| Terraform | 3 | 1 | 1 | — | 3 | — | — | — | — | 2026-08-08 |
| Concepts | 3 | 15 | 13 | 8 | — | — | — | — | 2 | 2026-08-07 |
| Git-doc | — | 1 | — | — | — | — | — | — | — | 2026-08-10 |
| Helm-doc | — | 1 | — | — | — | — | — | — | — | 2026-08-10 |

</details>

## Status

Currently working through Ansible first-contact notes and a ping playbook config, Git file index and Helm coverage docs, and Bash log rotation tooling. All eight foundational concept primers are complete with runnable scripts, code snippets, and notebooks. Git, Docker, Bash, Python, and Kubernetes have full primers through advanced scripts and docs. Helm and GitHub Actions have configs and docs on disk. Grafana and Prometheus have landing pages, install notes, and first configs. Terraform has primers, configs, docs, and scripts. Ansible now has a first-contact primer, install notes, and a ping playbook config.

---
_Last updated: 2026-08-10_
