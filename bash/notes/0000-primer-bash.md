---
last_verified: 2026-07-18
tool_version: 5.2.37
sources:
  - https://oneuptime.com/blog/post/2026-01-24-bash-command-not-found/view
  - https://dev.to/beta_shorts_7f1150259405a/top-5-bash-pitfalls-that-newbies-keep-getting-wrong-5337
  - https://oneuptime.com/blog/post/2026-02-13-bash-best-practices/view
---

# Bash — quick primer

> First-day notes for someone who's never used Bash. Personal voice, plain language.

## What is it?

Bash (Bourne Again SHell) is a command-line shell and scripting language that runs on almost every Linux and macOS system. It's the thing you're talking to when you open a terminal. If you've ever typed a command and hit Enter, you've used a shell — Bash is just the most common one.

You can think of it as a glue language: instead of writing a full program to copy files, rename them, and send an alert, you can write a few lines of Bash that call `cp`, `mv`, and `mail` and chain them together. It's what DevOps people reach for first when they need to automate something quickly.

## What does it do?

Bash lets you run commands, pass arguments, store results in variables, loop over files, check conditions, and pipe output from one command into another. You can write a `.sh` file with a sequence of commands and run it like a program. Most CI/CD pipelines, deployment scripts, and local dev tooling are built on Bash or a Bash-compatible shell.

## Why does it exist?

Before shells, you interacted with computers through punch cards or single-key commands. The UNIX shell (the predecessor to Bash) introduced the idea of a programmable command-line environment — you could save a sequence of commands to a file and replay them. Bash, created in 1989 by Brian Fox for the GNU Project, became the standard because it combined features from earlier shells (sh, csh, ksh) into one free, widely available package.

Day to day, it's what sysadmins and DevOps engineers use to inspect servers, move logs, restart services, and wire together other tools. If you work in ops, you can't avoid it — and you shouldn't want to.

## Key terminology

- **Shell** — The program that reads your typed commands and runs them. Bash is a shell.
- **Script** — A text file containing Bash commands, usually with a `.sh` extension. Run it with `bash script.sh` or `./script.sh` after making it executable.
- **Variable** — A named value. Set with `name="value"`, read with `$name`. Example: `greeting="Hello"` then `echo $greeting`.
- **Pipe (`|`)** — Sends the output of one command as input to another. Example: `ls | grep ".md"` lists only markdown files.
- **Exit code** — Every command returns a number: 0 means success, anything else means failure. Scripts use this in conditionals.
- **`$PATH`** — A colon-separated list of directories where the shell looks for executables. If you get "command not found", your command isn't in `$PATH`.
- **Shebang** — The first line of a script (`#!/usr/bin/env bash`) that tells the system which interpreter to use.

## A tiny example

```bash
name="world"
echo "Hello, $name!"
if [ "$name" = "world" ]; then
  echo "Default greeting used."
fi
```

This sets a variable, prints it inside a string, and checks a condition with `if`. Save it as `hello.sh`, run `bash hello.sh`.

## What I'll cover next

I want to get comfortable writing multi-step scripts that combine commands, handle errors gracefully, and accept arguments. After that, I'll work through real-world patterns like looping over log files and building a simple deployment helper.
