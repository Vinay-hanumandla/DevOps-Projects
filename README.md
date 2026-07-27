# DevOps-Projects
> A working engineer's DevOps reference — Bash, Docker, Git, Python, Terraform, and the foundational concepts they rest on.

![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)
![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)
![Languages](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)
![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)

> **New here?** Start at [the learning path](00_index/learning-path.md). It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and the foundational concepts behind Bash, Docker, Git, Python, and Terraform. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs. Right now it covers Bash, Docker, Git, Python, and Terraform, plus primers and hands-on companions for the concepts they rest on; more tools land as I work through them.

## What's in here

A small, growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, config, or script built while following a tool's quickstart and kept for later. It holds Bash material (primer, install notes, trip-ups guide, robust scripting patterns, hello-world and safe-template scripts, plus companion scripts), Docker material (primer, quickstart trip-ups, install note, multi-stage Dockerfile, sample apps, and container scripts), Git material (primer, quickstart trip-ups, undo/commit/push walkthroughs, install note, and branch-merge-revert script), Python material (primer, first script, snippets), Terraform material (install note and first config), and a set of foundational concept primers under `docs/concepts/` — each now joined by a runnable script or snippet that puts the ideas into practice.

## Quick links

- [Companion hello script for Bash](bash/scripts/2026-07-27-companion-hello.sh) — a companion script for the hello-world pattern with argument handling and strict mode
- [Companion test script for Bash](bash/scripts/2026-07-27-companion-test.sh) — test companion that exercises the safe Bash template patterns
- [Network connectivity tester (Python)](docs/concepts/networking-fundamentals/snippets/2026-07-26-socket-connection-tester.py) — Python snippet for testing TCP connectivity to a host:port
- [Network connectivity check (Bash)](docs/concepts/networking-fundamentals/scripts/2026-07-25-practice-network-connectivity-dns-port-inspection.sh) — Bash script to diagnose why a host:port is unreachable
- [File permissions and processes (Bash)](docs/concepts/linux-cli-fundamentals/scripts/2026-07-24-linux-file-permissions-and-process-management.sh) — inspect and modify Linux file permissions, then list and filter running processes

## Layout

- `bash/` — Bash material: primer, notes, docs, and scripts.
- `docker/` — Docker material: notes, Dockerfiles, source files, and scripts.
- `git/` — Git material: notes and workflow scripts.
- `python/` — Python material: primer, scripts, and snippets.
- `tf/` — Terraform material: install note and first config.
- `docs/concepts/` — foundational primers with runnable scripts and snippets (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

| Tool | notes | docs | scripts | snippets | dockerfiles | src | Last verified |
|------|-------|------|---------|----------|-------------|-----|---------------|
| Bash | 3 | 1 | 4 | — | — | — | 2026-07-27 |
| Docker | 4 | — | 3 | — | 1 | 2 | 2026-07-19 |
| Git | 6 | — | 2 | — | — | — | 2026-07-20 |
| Python | 1 | — | 1 | 1 | — | — | 2026-07-22 |
| Terraform | 1 | — | — | — | — | — | 2026-07-26 |

Foundational concept primers (one each) live under `docs/concepts/`: CI/CD, containerization, infrastructure-as-code, Linux & CLI, networking, observability & monitoring, scripting & automation, and version control — primers last verified 2026-07-19. Five of the eight now have runnable scripts and four have code snippets. A networking snippet was added most recently.

## Status

Working through first-contact material for Bash, Docker, Git, and Python, and laying down primers for the DevOps concepts underneath them. All eight foundational concept primers are in place; six now have runnable scripts and four have code snippets. Terraform tooling material is also starting to land.

---
_Last updated: 2026-07-27_