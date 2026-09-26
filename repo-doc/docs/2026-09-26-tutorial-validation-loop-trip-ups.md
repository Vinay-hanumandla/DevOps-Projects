---
last_verified: 2026-09-26
tool_version: n/a
---

# Following the tutorial again — the pre-PR validation loop

> My earlier trip-ups notes covered the coverage-table script and file naming. This time I followed the tutorial once more, end to end, for the part that comes after the file is written: checking that everything is actually in the right place before opening a PR.

## What I tried

I picked a finished draft file and walked the whole "is this ready" loop by hand: re-read the folder-conventions reference to confirm the category subdir, checked the front-matter block at the top, added the one-line CHANGELOG entry, and then ran the folder-check workflow script from the kit root to see whether my file showed up cleanly:

```bash
bash repo-doc/scripts/2026-09-25-check-folders-and-report-gaps.sh .
```

The script ran clean on the first try and printed three sections: the coverage grid, a folder-structure check, and a gap report. Seeing my file bump the right cell in the grid was the moment the loop clicked for me.

## What worked

The conventions reference (`../configs/2026-09-26-tool-folder-conventions.md`) answered the placement question fast. My file was a reference-style write-up, so `docs/` was the right home, and the reference confirmed the date-prefix rule for learner-stage files, which matched what neighboring files already looked like.

The workflow script behaved exactly as its header comment says: coverage tables first (reusing the older coverage script), then folder validation, then gaps. Running it from the kit root with `.` needed no other setup.

## Got stuck on

**1. The front-matter block.** My draft opened straight with the title heading and no front-matter at all. I only caught it when comparing against a neighboring doc. Every Markdown file here starts with a small block carrying `last_verified` and `tool_version` — I had to go back and add it. Lesson learned: check the top of the file first, not last.

**2. The CHANGELOG one-liner.** I knew an entry was expected but I hesitated over where it goes — top or bottom, dated heading or not. Looking at the file itself resolved it: entries group under a date heading with the newest date on top, one bullet per change naming the tool folder. I added mine under today's heading and re-read the neighboring bullets to match their shape.

**3. Reading the gap report.** The script flagged lines like `gap: git/templates exists but is empty` and `unknown subdir: docker/src`, and for a minute I worried my new file had broken something. It had not — those lines describe the pre-existing tree (empty scaffold dirs, a couple of unconventional subdirs), not my change. The report is descriptive, not a verdict on my file. What I actually needed from it was the absence of any complaint about my tool's `docs/` folder.

**4. The slug, again.** Naming still takes me a minute — specific enough to be findable, short enough to scan. Copying the shape of neighboring dated files (date plus kebab-case topic) is still the fastest way through.

## What I'd try next

- Run the validation loop before writing the file next time, so I see the "before" grid and can spot my file landing in the "after" run.
- Memorize the front-matter shape so a new doc starts with it instead of getting it patched in at the end.
- Keep a personal checklist of the four steps (placement, front-matter, CHANGELOG, check script) somewhere I will actually look at it.
