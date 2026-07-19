---
last_verified: 2026-07-19
tool_version: n/a
sources: []
---

# Scripting & Automation Philosophy — quick primer

> First-day notes on Scripting & Automation Philosophy. What it is, why it matters, and the key ideas to know.

## What is it?

Scripting & Automation Philosophy is the set of habits and principles behind writing small programs (scripts) that do repetitive or tedious work for you instead of you doing it by hand. It is not a single tool — it is a way of thinking: *if I have to do this more than once, I should make the computer do it.*

It's like a recipe you write down so that anyone (including a future you) can reproduce a dish without guessing. But here the recipe runs on a machine, and instead of cooking dinner it might rename a hundred files, deploy an app, or check a server's health.

## Why does it matter for devops?

As a DevOps practitioner you are surrounded by tasks that are easy once but painful the tenth time: configuring servers, rotating logs, kicking off builds, checking the same three dashboards. Doing those by hand is slow and error-prone.

Automation is the whole reason the role exists. When you script a task, you make it repeatable, reviewable, and shareable. A task captured in a script can be run the same way at 3am as at 3pm, by you or by a teammate, without relying on memory.

## Key terminology

- **Script** — a small file of commands executed top to bottom. Example: a `backup.sh` that tars a folder and copies it offsite.
- **Idempotency** — running the script twice produces the same end state as running it once. Example: `mkdir -p logs` won't error if `logs` already exists.
- **Idempotent automation** — automation that is safe to re-run. Example: a playbook that only restarts a service if its config actually changed.
- **DRY (Don't Repeat Yourself)** — avoid copying the same logic; put it in one place. Example: a helper `log()` function instead of `echo` in ten spots.
- **Strict mode** — settings that make a script fail loudly on errors. Example: `set -euo pipefail` (used once you're past day one) so a failed step stops the run.
- **Exit code** — the number a script returns to say success (0) or failure (non-zero). Example: `exit 1` signals something went wrong to whatever called the script.
- **Orchestration** — coordinating many automated steps. Example: a CI pipeline that builds, tests, then deploys.

## A concrete example

```bash
#!/usr/bin/env bash
# rename every .txt file in the current folder to .md
for file in *.txt; do
  mv "$file" "${file%.txt}.md"
done
echo "Renamed files."
```

This tiny loop shows the core idea: a repetitive manual task (rename N files) becomes one command you can run again and again.

## How this connects to what's next

Once these habits click, the same philosophy shows up everywhere — in Bash scripts, Python utilities, Infrastructure as Code, and CI/CD pipelines. The tools change, but the question stays the same: *what can I stop doing by hand?*
