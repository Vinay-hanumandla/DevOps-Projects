# DevOps-Projects
> A working engineer's DevOps reference — Bash, Docker, Git, and Python notes and scripts, plus primers and runnable companions for the core DevOps concepts.

![Last commit](https://img.shields.io/github/last-commit/Vinay-hanumandla/DevOps-Projects)
![Top language](https://img.shields.io/github/languages/top/Vinay-hanumandla/DevOps-Projects)
![Languages](https://img.shields.io/github/languages/count/Vinay-hanumandla/DevOps-Projects)
![Repo size](https://img.shields.io/github/repo-size/Vinay-hanumandla/DevOps-Projects)

> **New here?** Start at [the learning path](00_index/learning-path.md). It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and the foundational concepts behind Bash, Docker, Git, and Python. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs. Right now it covers Bash, Docker, Git, and Python, plus primers and hands-on companions for the concepts they rest on; more tools land as I work through them.

## What's in here

A small, growing collection of hands-on DevOps artifacts. Each entry is a dated note, snippet, or config built while following a tool's quickstart and kept for later. It holds Bash material (primer, install notes, hello-world script), Docker material (primer, quickstart trip-ups notes, install note, multi-stage Dockerfile, sample apps, and container scripts), Git material (primer, quickstart trip-ups notes, undo/commit/push walkthroughs, install note, and branch-merge-revert script), Python material (primer, first script, snippets), and a set of foundational concept primers under `docs/concepts/` — each now joined by a runnable script or snippet that puts the ideas into practice.

## Quick links

- [File permissions and processes](docs/concepts/linux-cli-fundamentals/scripts/2026-07-22-file-permissions-and-processes.sh) — inspect and modify Linux file permissions, then list and filter running processes
- [Subprocess wrapper](docs/concepts/linux-cli-fundamentals/snippets/2026-07-22-subprocess-wrapper.py) — run a command and capture stdout/stderr/return code from Python
- [Network connectivity check](docs/concepts/networking-fundamentals/scripts/2026-07-22-network-connectivity-check.sh) — test TCP connectivity to a host:port and diagnose why it's unreachable
- [Python primer](python/notes/0000-primer-python.md) — variables, types, functions, lists, dicts, venv, and pip
- [Create venv and run](python/scripts/2026-07-22-create-venv-and-run.py) — end-to-end virtual-environment setup and a runner inside it

## Layout

- `bash/` — Bash material: primer, notes, and scripts.
- `docker/` — Docker material: notes, Dockerfiles, source files, and scripts.
- `git/` — Git material: notes and workflow scripts.
- `python/` — Python material: primer, scripts, and snippets.
- `docs/concepts/` — foundational primers with runnable scripts and snippets (CI/CD, containerization, IaC, Linux, networking, observability, scripting, version control).
- `00_index/` — the map: topics, quick links, glossary, and learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

## Coverage

| Tool | notes | scripts | dockerfiles | src | snippets | Last verified |
|------|-------|---------|-------------|-----|----------|---------------|
| Bash | 1 | 1 | — | — | — | 2026-07-18 |
| Docker | 3 | 3 | 1 | 2 | — | 2026-07-19 |
| Git | 5 | 2 | — | — | — | 2026-07-20 |
| Python | 1 | 1 | — | — | 1 | 2026-07-22 |

Foundational concept primers (one each) live under `docs/concepts/`: CI/CD, containerization, infrastructure-as-code, Linux & CLI, networking, observability & monitoring, scripting & automation, and version control — all last verified 2026-07-22. Five of the eight now have runnable scripts and four have code snippets.

## Status

Working through first-contact material for Bash, Docker, Git, and Python, and laying down primers for the DevOps concepts underneath them. All eight foundational concept primers are in place; CI/CD, containerization, IaC, Linux & CLI, and networking have gained runnable scripts and snippets. More tool-specific depth is on the way.

---
_Last updated: 2026-07-23_
