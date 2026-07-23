---
last_verified: 2026-07-23
tool_version: n/a
sources:
  - https://www.fosslinux.com/105140/10-must-know-bash-shell-scripting-tips-and-tricks-for-beginners.htm
  - https://www.mechanicalrock.io/blog/modern-bash
---

# What I learned about writing robust Bash scripts: gotchas and patterns

I've been writing small Bash scripts for a few weeks and I started noticing recurring mistakes. This doc is my personal checklist of what to remember and what to avoid.

## Group repeated logic into functions

I wrote a 60-line linear script this week that did the same file-check in three places. Every time I needed to change the check, I had to edit three separate blocks. Once the script crossed ~50 lines, I should have refactored into functions. Now I group related commands into `local` functions so the main flow reads top to bottom.

## Add `trap` on `EXIT` for cleanup

Several of my scripts create temp files or start background services, and I kept leaving them behind when the script crashed. A `trap` on `EXIT` guarantees cleanup whether the script exits normally, on error, or via Ctrl+C.

```bash
TMPFILE=$(mktemp)
cleanup() { rm -f "$TMPFILE"; }
trap cleanup EXIT
```

## Check for missing commands up front

I had a backup script that ran on cron and silently failed because `tar` wasn't in the cron environment's `$PATH`. Running the script with `env -i` first lets me spot missing dependencies before they break scheduled runs.

## Use `getopts` instead of parsing `$1 $2` manually

I built a few scripts that hard-coded flag positions. When I added a second optional flag, everything broke. `getopts` handles short options, their arguments, and error reporting reliably — and it's built into Bash, so I don't need to import anything.

## Watch out for unquoted variables

This is the mistake I still make most often. Forgetting quotes around a variable that contains spaces turns one value into many. I check every variable expansion now and make sure it's inside double quotes unless I specifically want word splitting.

## Idempotent backups with `rsync`

I wrote a backup script that used `cp` without deleting stale files. After a few runs, the target had files the source had already deleted — I was comparing the wrong two trees. Switching to `rsync -av --delete` makes the script safe to re-run because the target becomes an exact copy every time.

## What I'd try next

I want to try the `.btr/` directory layout for local project tasks and see if it beats my current habit of scattering scripts in a flat `scripts/` folder.
