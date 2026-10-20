---
last_verified: 2026-10-20
tool_version: n/a
sources: []
---

# Repo: task — new tool integration starter kit

> A template scaffold for bringing a new tool into a repo-doc style kit: folder layout, coverage regeneration, validation, and a primer stub.

## Purpose

This starter kit provides the files and conventions needed to integrate a new tool into a kit that follows the repo-doc layout. It includes a new-tool bootstrap script, a coverage-table regenerator pattern, folder-structure validation, and a primer template so every tool gets consistent documentation from day one.

## When to use

Use this template when adding a new tool to an existing kit, or when bootstrapping repo-doc conventions in a new repository. Copy the template into your project and adapt the scripts to your kit's needs.

## Layout

```
repo-doc-new-tool-integration-starter-kit/
├── README.md
├── Makefile
├── .gitignore
├── scripts/
│   ├── repo-doc-new-tool.sh
│   └── 2026-09-01-regenerate-coverage-tables.sh
└── configs/
    └── tool-folder-conventions.yaml
```

## Getting started

1. Copy `scripts/repo-doc-new-tool.sh` into your repo (e.g. `repo-doc/scripts/`) and make it executable.
2. Copy or adapt `scripts/2026-09-01-regenerate-coverage-tables.sh` to build your coverage tables.
3. Add your tools to the known tools list in the coverage script.
4. Run `repo-doc-new-tool.sh <tool-name>` to create a new tool folder with all standard categories and a primer stub.

## Notes

- Standard categories: `notes/`, `docs/`, `scripts/`, `snippets/`, `configs/`, `templates/`, `manifests/`, `dockerfiles/`, `notebooks/`
- Each tool should have a primer at `notes/0000-primer-<tool>.md`
- Coverage tables are regenerated from disk, not edited by hand
