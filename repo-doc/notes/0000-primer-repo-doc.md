---
last_verified: 2026-10-20
tool_version: n/a
sources: []
---

# Repo: task — quick primer

> First-day notes for the documentation tooling that ships with this kit. What it is, why it exists, and the moving parts I need to know about.

## What is it?

The "Repo: task" tooling is the small collection of conventions and helper scripts I use to keep this kit's documentation in sync with the actual files on disk. It's not a single binary — it's a way of working: every tool folder has the same `notes/`, `docs/`, `scripts/`, `snippets/`, `configs/`, `templates/`, `manifests/`, `dockerfiles/`, and `notebooks/` subdirectory layout, and a couple of helper scripts regenerate the coverage tables from that layout. Think of it as the housekeeping layer that sits behind the `README.md` coverage table.

## What does it do?

It does two concrete things right now. First, it gives me a coverage table — the `Tool | notes | docs | scripts | …` grid at the top of `README.md` — and a way to regenerate that table by counting files on disk instead of editing it by hand. Second, it gives the folder check a shared vocabulary with the coverage script — both read the same category subdirectory names, so a file that lands in the wrong subdirectory shows up in both places. The point is that adding a new file should not require me to remember to bump a count somewhere else.

## Why does it exist?

Because the kit grows every cycle. The first time I added a `helm/docs/` file I had to manually update three different tables to add a "docs = 1" entry — and I missed one. That's the failure mode the tooling exists to prevent: the docs and the filesystem drifting apart. Before this existed, the README claimed a tool had `—` for some category when it actually had two files; the Git index page did not even list itself. The tooling exists so that the next time I add a file, the count is right without me having to think about it.

## Key terminology

- **Tool folder** — a top-level directory under the repo root (`bash/`, `git/`, `terraform/`, …) that holds everything for one tool. The first path segment of any file I write is always a tool folder.
- **Category subdir** — one of the fixed subdirectories under a tool folder (`notes/`, `docs/`, `scripts/`, `snippets/`, `configs/`, `templates/`, `manifests/`, `dockerfiles/`, `notebooks/`). The second path segment picks the category.
- **Coverage table** — the row-per-tool grid in `README.md` showing how many files exist in each category. The source of truth is the filesystem; the table is regenerated, not hand-edited.
- **Coverage doc** — a hand-written page listing the files inside one tool folder. Example: `git/docs/2026-08-10-git-index.md` and `helm/docs/2026-08-10-helm-coverage.md` — only those two tools have one, so don't expect a page in every folder.
- **Primer** — a fixed `0000-primer-<tool>.md` in each tool's `notes/` directory. It sorts above dated learning entries and is the first-contact intro to that tool. Excluded from the "notes" count in coverage tables because it's a reference, not a dated entry.
- **`00_index/`** — the navigation directory (`quick-links.md`, `learning-path.md`, `topics.md`, `glossary.md`). I don't edit it by hand — it's regenerated from the file tree.

## A tiny example

The smallest useful thing the tooling does is the coverage-table regeneration. From the repo root I run:

```bash
bash repo-doc/scripts/2026-09-01-regenerate-coverage-tables.sh .
```

It walks each tool folder, counts files in each category subdirectory, and prints a Markdown grid that I can paste into `README.md`. The output is the same shape as the table at the top of the README — the difference is the numbers come from `find` instead of my memory.

## What I'll cover next

What I want next is to make the counts in `README.md` regenerate themselves instead of being copy-pasted by hand, and to give the two tools that already have a coverage page the same wording. After that I want the folder check to fail loudly when a count drifts, instead of printing a list I have to read.
