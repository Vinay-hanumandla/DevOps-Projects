---
last_verified: 2026-10-20
tool_version: n/a
sources: []
---

# Closing the dead index.md and coverage.md references

> The repo-doc primer promised a per-tool `index.md` (or `coverage.md`) page that
> does not exist for most tools. This note records what was promised, what is
> actually on disk, and the wording that replaced the promise.

## Purpose

The primer for this tool told a first-time reader that every tool folder carries
its own index page, generated from the file tree the same way the coverage table
is. That is the fast path a primer is supposed to give: one sentence, one mental
model, no footnotes. The problem is that the model does not match the kit. Two
tool folders have a page, the other sixteen tool folders that keep a `notes/`
directory have none, and no generator exists that could add the missing ones on
demand.

A primer that describes an architecture the reader cannot find is worse than one
that describes a smaller architecture accurately, because the reader spends their
first hour looking for the thing the primer promised. This note closes that gap:
it states the promise, states the reality, and explains why the promise was
withdrawn instead of fulfilled.

## What the primer promised against what exists

| Primer claim | State on disk |
|---|---|
| every tool folder gets an `index.md` or `coverage.md` page | two pages only: [git index](../../git/docs/2026-08-10-git-index.md) and [helm coverage](../../helm/docs/2026-08-10-helm-coverage.md) |
| the per-tool pages are generated from the file tree | both pages are hand-written; no generator for them lives in `repo-doc/scripts/` |
| a matching per-tool regenerator is the next thing to write | still unwritten, and nothing in the kit depends on it |

The `git` and `helm` pages are real, useful, and worth keeping. They are simply
not part of a generated set.

## The two options, and why one was chosen

**Option A — generate a page for every tool folder.** This is the option the
primer implied. It needs a generator, and it needs that generator to run after
every content change, otherwise each new page is stale the day it is written.
Sixteen new pages would also have to agree with the two existing ones on
structure, which means picking a format and then rewriting the `git` and `helm`
pages to match. That is a lot of machinery for a listing the kit already
publishes elsewhere: the navigation pages under `00_index/` already point at
what sits in each tool folder, without asking for a second copy per folder.

**Option B — reword the primer and the quickstart note.** The primer stops
claiming a page per tool folder, and the quickstart note stops leaving the
question open. Cost is a paragraph of editing; the two real pages stay exactly
as they are, and the primer describes what a reader can actually find on day one.

Option B is the one taken here. It is the smaller claim, and a primer that makes
the smaller true claim is worth more than one that makes the larger promise. If
a per-tool generator is written later, the primer can grow back into the fuller
description on the day the pages exist.

## Steps taken

1. [The primer](../notes/0000-primer-repo-doc.md) — the housekeeping-layer
   sentence in "What is it?" no longer ends with a reference to per-tool index
   pages; the second thing the tooling does is now described as the shared
   category vocabulary between the coverage script and the folder check; the
   "Coverage doc" term now says plainly that only two tools have such a
   page and that they are hand-written; "What I'll cover next" no longer
   promises a per-tool regenerator.
2. [The quickstart note](../notes/2026-09-10-repo-task-quickstart-trip-ups.md) —
   trip-up 5 said the per-tool index step "I have not found yet". It now records
   the outcome: there is no second step, the two existing pages are hand-written,
   and the primer has been reworded to match.
3. This note, so the decision and the reasoning survive the next edit to the
   primer.

## Verify

```bash
grep -n "index.md\|coverage.md" repo-doc/notes/0000-primer-repo-doc.md
ls git/docs/2026-08-10-git-index.md helm/docs/2026-08-10-helm-coverage.md
```

The first command should show the two real page paths and no promise of a page
per tool folder; the second should list both files, because the primer now names
them as examples of what exists rather than as a rule.

The link checker in [the cross-tool reference validator](../scripts/cross-tool-reference-validator.sh)
covers the mechanical half of this: it resolves the relative links and changelog
paths the kit publishes, so a note that points at a file which is not there gets
reported. It does not read prose, so a promise like the one this note removes
still has to be caught by hand — which is what the table above is for.

## What I'd try next

Write the per-tool generator only if another tool actually asks for a page of its
own. Until then the honest primer is the one that lists two pages and says so.
