---
last_verified: 2026-09-26
tool_version: n/a
---

# Tool folder conventions — required subdirs, naming, primer rules

> My working reference for where files live in this kit. I walked the tree, wrote down what I actually saw, and noted where I got confused.

## What I did

I listed the subdirectories inside a few tool folders (`ansible/`, `bash/`, `docker/`, `prom/`, `tf/`, `repo-doc/`) and compared them. Most tools share the same set of subdirs, but no two tools have exactly the same set — each tool only grows the subdirs it actually uses. `repo-doc/` itself is the smallest: just `docs/`, `notes/`, and `scripts/` so far. This file is the first thing under `repo-doc/configs/`, and I put it here because the task Output said `config(md)`.

## Required subdirectories

The subdirectory names I kept seeing, and what goes in each:

- `notes/` — dated learning journal entries plus the one primer (see below).
- `docs/` — longer reference-style write-ups.
- `snippets/` — tiny single-file code samples.
- `scripts/` — runnable scripts.
- `configs/` — configuration files and config references (this file lives here).
- `manifests/` — deployment manifests.
- `dockerfiles/` — container build files.
- `notebooks/` — interactive notebooks.
- `templates/` — multi-file scaffolds, each in its own directory.

Two things that tripped me up: `docker/` has an extra `src/` directory that no other tool has, so the list above is a convention, not something every folder satisfies exactly. And a missing subdir just means that tool has no files of that kind yet — I created `repo-doc/configs/` for this file rather than squeezing it into `docs/`.

## File naming patterns

Every learner-stage file I found is date-prefixed journal style: `YYYY-MM-DD-<topic>.<ext>`, for example `2026-09-10-repo-task-quickstart-trip-ups.md`. The date makes the learning order visible. Reference-stage files drop the date and use stable kebab-case names instead. The one fixed exception is the primer name below — it always starts with `0000-` so it sorts above the dated entries.

## Primer exclusion rules

Each tool gets exactly one primer, ever: `notes/0000-primer-<tool>.md`. Rules I noted for myself:

- Never write a second primer for a tool that already has one — future learning goes in dated `notes/` entries.
- Never rewrite or "refresh" an existing primer in place.
- Never place primer content anywhere outside `notes/`, and never give a dated journal file the `0000-` prefix.

## Got stuck on

I first assumed every tool folder had to contain every subdir, and almost created a bunch of empty ones under `repo-doc/`. Walking `tf/` vs `repo-doc/` side by side showed me empty placeholder dirs are not the pattern — only `ansible/` has all of `configs/`, `docs/`, `manifests/`, `notes/`, `scripts/`, `snippets/`, `templates/`, and even it lacks some others.

## What I'd try next

Next I want a tiny script that walks the kit, lists each tool's subdirs, and flags any file sitting directly at a tool root or in an unexpected folder. That would turn this reference from something I eyeball into something I can re-check.
