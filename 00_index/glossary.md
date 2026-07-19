# Glossary

## Docker

- **Image** — an immutable, layered template (built from a Dockerfile) that defines a container's filesystem and start command.
- **Container** — a running instance of an image; isolated but ephemeral, so anything written inside is lost when it stops unless a volume is mounted.
- **Tag** — a label on an image (e.g. `nginx:1.25`); pulling without one defaults to `:latest`, which is why pinning a version matters for reproducibility.
- **Port mapping** — binding a host port to a container port with `-p host:container` (host port first); `docker port <container>` shows the resolved mapping.
- **Detached mode** — running a container with `-d` so it runs in the background instead of holding the terminal; view its output later with `docker logs <container>`.
- **Multi-stage build** — using several `FROM` stages in one Dockerfile to build in a heavy toolchain image and copy only the compiled artifact into a small final image.
- **Distroless image** — a minimal final image containing only the app and its runtime dependencies (no shell, package manager, or OS utilities), which shrinks attack surface.
- **Non-root runtime** — configuring the container to run as an unprivileged UID instead of root, a basic security hardening step.
- **Volume** — a persistent, host-managed storage mount that survives container restarts, used when data must outlive the container.

## Bash

- **Shell** — the program that reads typed commands and runs them; Bash is the most common Unix/Linux shell.
- **Script** — a text file containing Bash commands, usually with a `.sh` extension, run with `bash script.sh` or `./script.sh` after making it executable.
- **Variable** — a named value, set with `name="value"` and read with `$name`.
- **Pipe (`|`)** — sends the output of one command as input to another (e.g. `ls | grep ".md"`).
- **Exit code** — every command returns a number: 0 means success, non-zero means failure.
- **`$PATH`** — a colon-separated list of directories where the shell looks for executables.
- **Shebang** — the first line of a script (`#!/usr/bin/env bash`) that tells the system which interpreter to use.

## Git

- **Staging area (index)** — the intermediate holding place between your working directory and a commit; `git add` moves changes here, `git commit` snapshots them.
- **Commit** — a snapshot of the staged changes with an author stamp and message; the unit of history in a repository.
- **Branch** — a movable pointer to a commit; `git switch <name>` creates the context where new commits land without touching other lines of work.
- **HEAD** — the currently checked-out commit/branch; commands like `git reset` and `git restore` resolve "here" against it.
- **Remote** — another copy of the repository (usually `origin`); `git push` sends commits to it and `git fetch`/`pull` brings theirs in.
- **Upstream tracking** — a branch's remembered remote counterpart, set with `git push -u`, so later `git push`/`git pull` need no extra arguments.
- **Stash** — a scratch holding area for uncommitted changes (`git stash`) so you can switch context and reapply them later with `git stash pop`.
- **Revert** — `git revert <commit>` makes a new commit that undoes an earlier one; safe on shared branches because it doesn't rewrite history.
- **Reset** — `git reset` moves HEAD (and optionally the index/working tree); `--soft` keeps changes staged, `--hard` discards them, so use it with care.
- **Amend** — `git commit --amend` rewrites the most recent commit (message or contents); fine locally, dangerous once pushed.
- **Patch staging** — `git add -p` stages only selected hunks of a file so unrelated edits can land in separate commits.

## Concepts

- **CI/CD** — Continuous Integration (merging and testing code changes often) plus Continuous Delivery/Deployment (automatically getting those changes to production-ready or live states).
- **Pipeline** — an ordered sequence of automated stages (typically build → test → deploy) where each stage must pass before the next runs.
- **Fail-fast** — stopping a pipeline the moment a stage fails so broken changes don't waste time or reach later stages; usually gated on exit codes.
- **Infrastructure as Code (IaC)** — managing servers, networks, and services through version-controlled definition files instead of manual clicks, so environments are reproducible.
- **Idempotence** — applying the same configuration repeatedly yields the same end state; a core property that makes IaC and automation safe to re-run.
- **Observability** — the ability to understand a system's internal state from its external outputs (metrics, logs, traces) without adding new instrumentation each time.
- **Monitoring** — collecting and tracking metrics, logs, and alerts so you know when something breaks; the practical, threshold-driven side of observability.
- **Metric** — a numeric measurement sampled over time (e.g. request latency, CPU usage) used to track system health and trigger alerts.
- **Port** — a numbered endpoint on a host that identifies a specific service, letting one machine run many networked programs at once.
- **Protocol** — an agreed set of rules for how machines exchange data (e.g. TCP, HTTP); both ends must speak the same one to communicate.
- **CLI** — command-line interface: interacting with a system by typing text commands rather than clicking a graphical desktop.
- **Kernel** — the core of an operating system that manages hardware, processes, and memory; the Linux kernel underpins most servers and containers.
