---
last_verified: 2026-09-23
tool_version: n/a
sources: []
---

# Following the repo-task tutorial — what actually happened

> Worked through the repo-doc tutorial end to end and wrote down where it went smoothly and where I got confused. This is a follow-up to my earlier quickstart notes.

## What I tried

I followed the tutorial path for adding a new learning file to the kit: pick a tool folder, put the file in the right category subdirectory, then run the repo tooling so the counts stay in sync. I wanted to understand the full loop, not just the single coverage-table script I ran last time. Concretely I did three things in order: read the primer's layout section, created a scratch note under one tool's `notes/` folder, and re-ran the coverage-table script from the repo root to see my file show up.

```bash
bash repo-doc/scripts/2026-09-01-regenerate-coverage-tables.sh .
```

## What worked

The layout convention clicked faster this time. Every tool folder has the same set of category subdirectories (`notes/`, `docs/`, `scripts/`, and so on), and the filename tells you the story: primers sort first with the `0000-` prefix, my dated journal-style notes sort after them. Once I saw that, placing the scratch file felt obvious instead of guessy.

The coverage script also behaved the way the tutorial said it would. Running it from the repo root printed the grid, and my scratch file bumped the count for that tool by one. Deleting the scratch file and re-running brought the count back down, which was a nice confirmation that the counting is live rather than cached somewhere.

## Got stuck on

**1. Two scripts that sound like they do the same thing.** The tutorial mentions both the coverage-table script and a separate index-regeneration step, and I burned time assuming one of them calls the other. They do not — at least not in the version I ran. The coverage script only prints the top-level table to stdout. The per-tool index pages update through a different step I still have not found. I kept re-running the coverage script expecting index files to change, and of course nothing changed.

**2. Stdout versus files, again.** I knew from last time that the coverage output goes to stdout, but the tutorial reads like the tooling "updates" things in place, so I expected it to rewrite the README for me. It does not. I had to copy the table out of the terminal myself. That is fine for a learning kit, but the tutorial wording had me double-checking whether I had passed the wrong argument for a while before I accepted the copy-paste workflow.

**3. Naming my scratch file.** The primer is clear that learner-stage files get a date prefix, but I hesitated over the topic slug — how long, how specific, hyphens versus underscores. I looked at neighboring notes and copied their shape (date plus short kebab-case topic), which resolved it, but the tutorial itself does not give a naming recipe beyond "dated entries." A single example slug in the tutorial would have saved me the detour.

## What I'd try next

- Hunt down the index-regeneration step and run it on purpose, so I can describe both halves of the tooling loop from experience rather than guessing.
- Practice the naming pattern a few more times until the slug choice feels automatic — probably by drafting two or three note titles before writing.
- Re-read the primer's category-subdirectory list with fresh eyes now that I have placed a file myself, and check whether I can explain in one sentence what belongs in each category without looking.
