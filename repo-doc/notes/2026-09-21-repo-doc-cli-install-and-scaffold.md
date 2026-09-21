---
last_verified: 2026-09-21
tool_version: n/a
sources: []
---

# repo-doc CLI install and first scaffold

> First-day notes for installing the repo-doc tooling and generating a project documentation scaffold.

## What I did

I looked for a standalone `repo-doc` CLI to install (npm, pip, cargo) — there isn't one. The "CLI" is just the scripts in `repo-doc/scripts/`. I added it to PATH:

```bash
export PATH="/work/DevOps-Projects/repo-doc/scripts:$PATH"
regenerate-coverage-tables.sh /work/DevOps-Projects
```

It printed the coverage table. Works.

## Generating a scaffold

No `repo-doc init` command exists. The scaffold is the tool folder layout — every tool gets the same category subdirs (`notes/`, `docs/`, `scripts/`, `snippets/`, `configs/`, `templates/`, `manifests/`, `dockerfiles/`, `notebooks/`). I created one manually:

```bash
mkdir -p /tmp/test-tool/{notes,docs,scripts,snippets,configs,templates,manifests,dockerfiles,notebooks}
```

Ran the coverage script against `/tmp` — it didn't detect `test-tool` because the script only counts known tools.

## What tripped me up

**No standalone CLI.** Just scripts in this repo.

**No scaffold command.** Manual `mkdir -p` required.

**Coverage script has fixed tool list.** New tools won't appear until the script is updated.

## What I'd try next

Write a `repo-doc-new-tool.sh` wrapper that creates the directory structure, adds the primer stub, and updates the coverage script's known-tool list.