---
last_verified: 2026-09-01
tool_version: n/a
sources: []
---

# Repo: task — quick primer

> First-day notes for the documentation tooling that ships with this kit. What it is, why it exists, and the moving parts I need to know about.

## What is it?

The "Repo: task" tooling is the small collection of conventions and helper scripts I use to keep this kit's documentation in sync with the actual files on disk. It's not a single binary — it's a way of working: every tool folder has the same `notes/`, `docs/`, `scripts/`, `snippets/`, `configs/`, `templates/`, `manifests/`, `dockerfiles/`, and `notebooks/` subdirectory layout, and a couple of helper scripts regenerate the coverage tables from that layout. Think of it as the housekeeping layer that sits behind `README.md` and the per-tool `index.md` pages.

## What does it do?

It does two concrete things right now. First, it gives me a coverage table — the `Tool | notes | docs | scripts | …` grid at the top of `README.md` — and a way to regenerate that table by counting files on disk instead of editing it by hand. Second, it gives each tool folder an `index.md` (or `coverage.md`) page that lists the files inside that tool, also generated from disk. The point is that adding a new file should not require me to remember to bump a count somewhere else.

## Why does it exist?

Because the kit grows every cycle. The first time I added a `helm/docs/` file I had to manually update three different tables to add a "docs = 1" entry — and I missed one. That's the failure mode the tooling exists to prevent: the docs and the filesystem drifting apart. Before this existed, the README claimed a tool had `—` for some category when it actually had two files; the `index.md` for Git was missing itself. The tooling exists so that the next time I add a file, the count is right without me having to think about it.

## Key terminology

- **Tool folder** — a top-level directory under the repo root (`bash/`, `git/`, `terraform/`, …) that holds everything for one tool. The first path segment of any file I write is always a tool folder.
- **Category subdir** — one of the fixed subdirectories under a tool folder (`notes/`, `docs/`, `scripts/`, `snippets/`, `configs/`, `templates/`, `manifests/`, `dockerfiles/`, `notebooks/`). The second path segment picks the category.
- **Coverage table** — the row-per-tool grid in `README.md` showing how many files exist in each category. The source of truth is the filesystem; the table is regenerated, not hand-edited.
- **Index / coverage doc** — the per-tool `index.md` or `coverage.md` (e.g. `git/docs/2026-08-10-git-index.md`) that lists the files inside that tool folder, again regenerated from disk.
- **Primer** — a fixed `0000-primer-<tool>.md` in each tool's `notes/` directory. It sorts above dated learning entries and is the first-contact intro to that tool. Excluded from the "notes" count in coverage tables because it's a reference, not a dated entry.
- **`00_index/`** — the navigation directory (`quick-links.md`, `learning-path.md`, `topics.md`, `glossary.md`). I don't edit it by hand — it's regenerated from the file tree.

## A tiny example

The smallest useful thing the tooling does is the coverage-table regeneration. From the repo root I run:

```bash
bash repo-doc/scripts/2026-09-01-regenerate-coverage-tables.sh .
```

It walks each tool folder, counts files in each category subdirectory, and prints a Markdown grid that I can paste into `README.md`. The output is the same shape as the table at the top of the README — the difference is the numbers come from `find` instead of my memory.

## What I'll cover next

I want to write the matching per-tool `coverage.md` regenerator next — same pattern, but the output is one file inside `<tool>/docs/` instead of a single big table. After that I'll look at how `00_index/quick-links.md` gets generated, because that's the third table that needs to stay in sync and right now I'm not sure where the generator lives.
