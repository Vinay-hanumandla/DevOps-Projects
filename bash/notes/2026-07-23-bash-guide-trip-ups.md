---
last_verified: 2026-07-23
tool_version: 5.2.37
sources:
  - https://linuxjunkies.org/guides/bash-scripting-for-beginners
  - https://unixy.io/blog/shell-scripting-pitfalls/
---

# Bash guide — what tripped me up

I followed the Bash scripting guide and wrote down the parts that confused me. Most of it clicked once I stopped thinking like a Python programmer and started treating the shell as a text-processing pipeline.

## Variables: quoting is the invisible wall

My first mistakes were all about quoting. I kept writing `for f in $files` instead of `for f in "$files"` and watching filenames with spaces explode into separate words. The guide uses quotes everywhere, but it's easy to skip when you're typing fast.

```bash
# WRONG — splits on spaces
for f in $files; do echo "$f"; done

# RIGHT — passes the whole string
for f in "$files"; do echo "$f"; done
```

## Exit codes vs. output

I assumed a failed command would yell loudly. Actually, most commands just print to stderr and exit with a non-zero code. If I don't check `$?`, my script keeps running like nothing happened.

```bash
mkdir /tmp/test 2>/dev/null
echo $?  # prints 1 if the dir already exists, but the script didn't stop
```

## Globs that skip hidden files

I noticed my loops were skipping `.bashrc` and other dotfiles. The default glob `*` doesn't match hidden files. I had to remember `.*` explicitly, then filter out `.` and `..` so I don't climb into parent directories by accident.

## Traps and cleanup

I wrote a script that created a temp file and forgot to delete it when I hit Ctrl+C. The guide recommends `trap` with a cleanup function so the script always removes its mess, even when interrupted.

```bash
TMPFILE=$(mktemp)
cleanup() { rm -f "$TMPFILE"; }
trap cleanup EXIT

echo "working..." > "$TMPFILE"
# even if I crash here, cleanup runs on exit
```

## `read` eats the trailing newline

I tried to read a file line-by-line with `while read line`, but the body only ran once. Turns out I forgot that by default `read` splits on IFS and my variable assignment lost the newline. Adding `IFS= read -r line` fixed it.

## What I'd try next

I want to practice `getopts` for flag parsing, then write a small wrapper around `rsync` that keeps dated backups and rotates old ones. The backup-with-rotation pattern from the research looks like a nice next project.
