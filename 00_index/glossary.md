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
- **Dockerfile** — a recipe for building an image; each instruction (`FROM`, `RUN`, `COPY`) creates a cached layer.
- **Daemon / Engine** — the background process (`dockerd`) that manages images, containers, networks, and volumes; the `docker` CLI talks to it via a socket.
- **Registry** — a server that stores and distributes images; Docker Hub is the default public registry.
- **Layer** — each instruction in a Dockerfile creates a layer; Docker caches layers so rebuilding is fast when only the last few instructions changed.
- **Manifest** — the JSON document that describes an image's layers, config, and platform (Docker V2 or OCI format); `docker manifest inspect <image>` shows it.
- **docker compose** — Docker's built-in multi-container orchestration tool (V2); define services in a `compose.yaml` and start everything with `docker compose up`.

## Bash

- **Shell** — the program that reads typed commands and runs them; Bash is the most common Unix/Linux shell.
- **Script** — a text file containing Bash commands, usually with a `.sh` extension, run with `bash script.sh` or `./script.sh` after making it executable.
- **Variable** — a named value, set with `name="value"` and read with `$name`.
- **Pipe (`|`)** — sends the output of one command as input to another (e.g. `ls | grep ".md"`).
- **Exit code** — every command returns a number: 0 means success, non-zero means failure.
- **`$PATH`** — a colon-separated list of directories where the shell looks for executables.
- **Shebang** — the first line of a script (`#!/usr/bin/env bash`) that tells the system which interpreter to use.
- **`$?`** — the exit code of the last foreground command; useful for inline error checks without an explicit `if`.
- **Stderr** — the separate output stream (`>&2`) for error messages, distinct from normal output (stdout); redirecting it independently keeps diagnostics from polluting a command's real output.
- **Positional parameters** — the arguments passed to a script or function, accessed as `$1`, `$2`, etc.; `$@` holds all of them as separate words, `$*` as a single string.
- **Word splitting** — the shell's behaviour of splitting unquoted variable expansions on characters in `$IFS` (space, tab, newline by default), which causes bugs when a value contains spaces unless quoted.
- **IFS** — the Internal Field Separator, used by the shell to split words after expansion; overriding it (e.g. `IFS=,`) changes how `read` and loops parse delimited input.
- **`trap`** — a builtin that registers a command to run when the shell receives a signal or event (e.g. `EXIT`, `ERR`, `SIGINT`), used for cleanup and error handling.

## Git

- **Repository** — the folder Git is tracking, plus the hidden `.git` database that stores all history.
- **Working tree** — the actual files on disk that you edit, as opposed to the committed snapshots stored in `.git`.
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
- **Rebase** — replaying your commits on top of another branch (e.g. `git rebase main`); linearises history but rewrites commit hashes, so avoid it on shared branches without coordination.
- **Hook** — a script in `.git/hooks/` that Git runs automatically at a named point in its workflow (e.g. `pre-commit`, `pre-push`); used for linting, testing, or enforcing policy before a Git operation completes.
- **Feature branch** — a short-lived branch dedicated to a single change or feature; typically rebased onto `main` before merging to keep history clean.

## Helm

- **Helm** — a package manager for Kubernetes that defines, installs, and upgrades complex applications using charts.
- **Chart** — a Helm package containing templates and default values; `helm install myapp ./mychart/` renders and deploys everything in that chart.
- **Release** — a running instance of a chart in a cluster; installing the same chart twice with different names gives you two releases.
- **Values file** — a YAML file that overrides a chart's defaults; `helm install myapp ./mychart/ -f custom-values.yaml` applies custom configuration.
- **Repository** — a hosted collection of charts others can use; `helm repo add stable https://charts.helm.sh/stable` registers one.
- **Helmfile** — a declarative file that lists multiple releases to deploy as one group, like a lockfile for Helm.
- **Dependency** — a chart can depend on other charts; your app chart might pull in a Redis chart and a PostgreSQL chart.

## Python

- **Type** — the category of a value (`int`, `float`, `str`, `bool`, `list`, `dict`); `type(value)` returns it, and knowing it prevents surprises like `5 / 2` giving `2.5` instead of `2`.
- **Virtual environment (venv)** — an isolated directory containing its own Python interpreter and installed packages; created with `python -m venv .venv` so nothing leaks in or out between projects.
- **pip** — Python's package installer; `pip install requests` fetches and installs a library, usually combined with a venv to keep dependencies reproducible.
- **Module** — a `.py` file containing functions, classes, or constants; `import os` loads the built-in `os` module for filesystem and environment access.
- **f-string** — a string with `f""` containing `{}` placeholders evaluated at runtime; faster and more readable than the older `.format()` style.

## Terraform

- **Provider** — a plugin that knows how to talk to a specific cloud or service. Example: the AWS provider lets Terraform create EC2 instances and S3 buckets.
- **Resource** — a single piece of infrastructure declared in a config file. Example: `aws_instance.example` represents a virtual machine.
- **State file** — Terraform's record of what it has created. It maps config files to real resources so Terraform knows what to update or skip.
- **Plan** — Terraform's preview of what changes it will make before applying them. Run `terraform plan` to review the diff before committing changes.
- **Apply** — the command that makes the planned changes real. After approving the plan, `terraform apply` creates or updates resources.
- **Drift** — the gap between the real-world state of infrastructure and what Terraform's state file says exists; detected when the actual resources have changed outside Terraform.
- **Declarative** — describing the desired end state rather than the steps to reach it; Terraform configs are declarative, so you say what you want and Terraform figures out how to get there.

## Helm

- **Chart** — a Helm package containing templates and default values. Example: `helm install myapp ./mychart/` renders and deploys everything in that chart.
- **Release** — a running instance of a chart in a cluster. Installing the same chart twice with different names gives you two releases.
- **Values file** — a YAML file that overrides a chart's defaults. Example: `helm install myapp ./mychart/ -f custom-values.yaml` sets custom config.
- **Repository** — a hosted collection of charts others can use. Example: `helm repo add stable https://charts.helm.sh/stable` adds a public repo.
- **Helmfile** — a declarative file that lists multiple releases to deploy. A `helmfile.yaml` declares all infra apps in one place.
- **Dependency** — a chart can depend on other charts. Your app chart might depend on a Redis chart and a PostgreSQL chart.

## Concepts

- **Artifact** — a build output (binary, package, container image, or report) produced by one pipeline stage and consumed by the next; promoting an artifact means moving a specific version through dev → staging → prod.
- **CI/CD** — Continuous Integration (merging and testing code changes often) plus Continuous Delivery/Deployment (automatically getting those changes to production-ready or live states).
- **Pipeline** — an ordered sequence of automated stages (typically build → test → deploy) where each stage must pass before the next runs.
- **Gate** — a checkpoint in a pipeline that must succeed before the next stage runs; examples are test pass/fail, security scan thresholds, and manual approval steps.
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
- **Branch protection** — a repository-level rule that blocks direct pushes to a branch and requires status checks to pass before a pull request can be merged, enforcing the gate-before-merge pattern.
- **DORA metrics** — the four standard metrics for software delivery performance: deployment frequency, lead time for changes, change failure rate, and mean time to restore (MTTR).
- **Health dashboard** — a visual display of pipeline metrics and signal trends (build duration, queue time, test flake rate, deploy success) used to detect regressions in developer velocity.
- **Artifact immutability** — the principle that a build artifact should not change between environments; the same container image or binary runs in dev, staging, and production so failures are configuration problems, not binary-diff debugging.
