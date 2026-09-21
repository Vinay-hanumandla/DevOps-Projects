---
last_verified: 2026-09-21
tool_version: n/a
sources: []
---

# repo-doc CLI install and first scaffold

> First-day notes for installing the repo-doc tooling and generating a project documentation scaffold. Personal voice, plain language.

## What I did

I wanted to see if there's a standalone `repo-doc` CLI I can install (like `npm install -g repo-doc` or `pip install repo-doc`) instead of just running the scripts from this repo. Searched the repo and the web — there isn't one. The "repo-doc CLI" the task mentions is just the scripts that live in `repo-doc/scripts/` in this kit.

So I "installed" it by adding the scripts directory to my PATH for the session:

```bash
export PATH="/work/DevOps-Projects/repo-doc/scripts:$PATH"
```

Then I ran the coverage table generator to verify it works:

```bash
regenerate-coverage-tables.sh /work/DevOps-Projects
```

It printed a Markdown table with file counts per tool per category. That worked.

## Generating a project documentation scaffold

The task says "generate my first project documentation scaffold." Looking at the repo-doc tooling, there's no explicit "scaffold" command. The scaffold is the tool folder layout itself — every tool gets the same category subdirectories:

```
<tool>/
  notes/
  docs/
  scripts/
  snippets/
  configs/
  templates/
  manifests/
  dockerfiles/
  notebooks/
```

So "generating a scaffold" means creating this directory structure for a new tool. I tried it manually:

```bash
mkdir -p /tmp/test-tool/{notes,docs,scripts,snippets,configs,templates,manifests,dockerfiles,notebooks}
```

Then I ran the coverage script against `/tmp` to see if it detects the new tool:

```bash
regenerate-coverage-tables.sh /tmp
```

It did not detect `test-tool` because the script only looks for known tool folders (it has a hardcoded list or heuristic). The coverage table still only showed the existing tools.

## What tripped me up

**No standalone CLI exists.** The "repo-doc CLI" is just the scripts in this repo. There's no package to install from a registry.

**No scaffold command.** The tooling doesn't have a `repo-doc init` or `repo-doc new-tool` command. Creating a new tool folder is a manual `mkdir -p` job.

**Coverage script has a fixed tool list.** The `regenerate-coverage-tables.sh` script only counts files for tools it already knows about. A brand new tool folder won't appear in the table until the script is updated (or the heuristic is improved).

## What I'd try next

Write a small wrapper script (`repo-doc-new-tool.sh`) that:
1. Takes a tool name as argument
2. Creates the full category subdirectory structure
3. Creates the `0000-primer-<tool>.md` stub in `notes/`
4. Optionally updates the coverage table script's known-tool list

That would make "generating a scaffold" a one-command operation instead of manual directory creation.