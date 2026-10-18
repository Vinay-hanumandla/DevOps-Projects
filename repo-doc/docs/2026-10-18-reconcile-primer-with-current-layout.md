---
last_verified: 2026-10-18
tool_version: n/a
sources: []
---

# Reconciling the repo-doc primer with the current repository layout

I went back through the repo-doc primer after noticing the coverage tables in README.md didn't match what I was seeing on disk. The primer claims every tool folder has nine standard category subdirectories, but the actual layout is sparser and more varied.

## What the primer says vs. what exists

The primer lists these nine categories as the fixed layout every tool folder should have:

```
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

I ran `ls` across all 19 tool folders and found:

- **All 9 categories**: Only `ansible`, `gha`, `git`, `grafana`, `helm`, `k8s`, `python`, `tf` have the full set (8 tools)
- **Missing dockerfiles/notebooks**: `bash`, `docker`, `prom` lack one or both
- **Minimal sets**: `awx`, `compose`, `hchart`, `kprom`, `repo-doc`, `scripting-automation-philosophy`, `tfc` have only 2–5 categories
- **Extra categories**: `git` has `hooks/`, `docker` has `src/`, `docs` (top-level) has `concepts/`

The primer's "fixed subdirectories" claim is aspirational, not descriptive. Most tools only create categories as needed.

## Helper scripts the primer doesn't mention

The primer only calls out `2026-09-01-regenerate-coverage-tables.sh`. The `repo-doc/scripts/` directory actually has five scripts:

| Script | Purpose |
|--------|---------|
| `2026-09-01-regenerate-coverage-tables.sh` | Walks tool folders, counts files per category, prints Markdown table for README.md |
| `2026-09-10-minimal-task-automation.sh` | Small wrapper for common task operations (create branch, commit, push) |
| `2026-09-25-check-folders-and-report-gaps.sh` | Validates tool folder structure against expected categories, reports missing dirs |
| `kit-conformance-checker.py` | Python validator for kit-wide rules (naming, front-matter, required files) |
| `project-validator.py` | Validates individual project/template structures |

The primer's "What does it does?" section says the tooling does "two concrete things" (coverage table + per-tool index), but there's at least a third: structure validation via `check-folders-and-report-gaps.sh`.

## Coverage table regeneration — what actually works

I ran the coverage script from the primer's example:

```bash
bash repo-doc/scripts/2026-09-01-regenerate-coverage-tables.sh .
```

It produces a table, but the output doesn't match the README.md table exactly. The script counts files in each category, but:
- It includes the primer (`0000-primer-<tool>.md`) in the notes count, while the README table excludes it
- It doesn't handle the `hooks/` category in `git/` or `src/` in `docker/`
- The `templates/` count includes template directories as single entries, not the files inside them

The README table was hand-adjusted after generation. The primer should note this drift.

## Per-tool index generation — missing generator

The primer says "I want to write the matching per-tool `coverage.md` regenerator next" and "I'll look at how `00_index/quick-links.md` gets generated." As of this cycle, neither generator exists in `repo-doc/scripts/`. The `00_index/` files (`quick-links.md`, `learning-path.md`, `topics.md`, `glossary.md`) are large hand-maintained files, not regenerated from disk.

## What I'd try next

1. **Update the primer's category list** to reflect reality: "Most tools have a subset of these nine; categories are created on demand." List which tools have which categories.

2. **Document all five helper scripts** in the primer's "Key terminology" or a new "Helper scripts" section.

3. **Fix the coverage script** to exclude primers from notes count and handle extra categories (`hooks/`, `src/`, `concepts/`).

4. **Build the per-tool index generator** — a script that writes `<tool>/docs/coverage.md` listing that tool's files, similar to what `git/docs/2026-08-10-git-index.md` attempts.

5. **Build the 00_index generator** — a script that walks the whole tree and regenerates `quick-links.md`, `topics.md`, and `learning-path.md` from actual files, not hand edits.

The primer is still a useful first-contact doc, but it describes the intended architecture, not the current implementation. This reconciliation is the first step toward closing that gap.