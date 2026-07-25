# Quick Links

## I need to...

### Get started with Bash
- [Bash primer](../bash/notes/0000-primer-bash.md) — what Bash is, key terminology, and a tiny example
- [Install Bash and first script](../bash/notes/2026-07-18-install-bash-and-first-script.md) — install check, first .sh file, and permission gotcha
- [Bash guide — trip-ups](../bash/notes/2026-07-23-bash-guide-trip-ups.md) — quoting, word splitting, exit codes, and trap

### Write and run a Bash script
- [Hello world with argument handling](../bash/scripts/2026-07-18-first-hello-world.sh) — a minimal script that checks for arguments
- [Safe Bash template](../bash/scripts/2026-07-23-safe-bash-template.sh) — a reusable skeleton with `set -euo pipefail`

### Write robust Bash
- [Robust Bash scripting](../bash/docs/2026-07-23-robust-bash-scripts.md) — strict mode, error handling, and safe defaults

### Get started with Docker
- [Docker primer](../docker/notes/0000-primer-docker.md) — what Docker is, images vs containers, and a minimal workflow
- [Docker quickstart trip-ups](../docker/notes/2026-07-13-docker-quickstart-trip-ups.md) — what to expect and where beginners get stuck
- [Docker follow-up trip-ups](../docker/notes/2026-07-15-docker-quickstart-trip-ups.md) — more gotchas after the initial run-through
- [Install Docker](../docker/notes/2026-07-19-install-docker.md) — check installation, verify the daemon is running
- [Hello-world container](../docker/scripts/2026-07-19-first-hello-world.sh) — pull and run the hello-world image to verify Docker works

### Build a container image
- [Minimal non-root Dockerfile](../docker/dockerfiles/2026-07-17-minimal-image-tagged-nonroot.Dockerfile) — multi-stage build to a distroless, non-root runtime

### Run a container
- [Run container with port map](../docker/scripts/2026-07-16-run-container-port-map.sh) — run a tagged image, map a port, verify, and tear down
- [Run nginx with port map](../docker/scripts/2026-07-18-first-port-mapped-container.sh) — run nginx, map a port, verify, and tear down

### Get started with Git
- [Git primer](../git/notes/0000-primer-git.md) — what Git is, key concepts, and a minimal workflow
- [Git quickstart trip-ups](../git/notes/2026-07-13-git-quickstart-trip-ups.md) — first contact with Git and where it tripped me up
- [Git follow-up trip-ups](../git/notes/2026-07-15-git-quickstart-trip-ups.md) — more first-contact gotchas on the second pass
- [Install Git](../git/notes/2026-07-20-install-git.md) — check installation and configure user identity
- [First repo lifecycle](../git/scripts/2026-07-20-first-repo.sh) — init, add, commit, status in a minimal example

### Undo and fix a Git mistake
- [Undo, stage, commit, push](../git/notes/2026-07-13-undo-stage-commit-push.md) — unstage, discard, revert, and safely rewrite a local commit
- [Undo follow-up](../git/notes/2026-07-15-undo-stage-commit-push.md) — more undo patterns: stash, amend after push, recovering lost work

### Branch, merge, and revert
- [Branch, merge, revert](../git/scripts/2026-07-20-branch-merge-revert.sh) — create branches, merge them, and undo a merge

### Get started with Python
- [Python primer](../python/notes/0000-primer-python.md) — variables, types, functions, lists, dicts, venv, and pip

### Write and run a Python script
- [Create venv and run](../python/scripts/2026-07-22-create-venv-and-run.py) — end-to-end virtual-environment setup and a runner inside it
- [First script — variables and types](../python/snippets/2026-07-22-first-script-variables-types.py) — declare variables, inspect types, and print mixed-type lists

### Understand a DevOps concept before touching a tool
- [Linux & CLI Fundamentals](../docs/concepts/linux-cli-fundamentals/0000-primer-linux-cli-fundamentals.md) — the shell, processes, and filesystem basics everything leans on
- [Networking Fundamentals](../docs/concepts/networking-fundamentals/0000-primer-networking-fundamentals.md) — ports, addresses, and how containers reach the host
- [Containerization Concepts](../docs/concepts/containerization-concepts/0000-primer-containerization-concepts.md) — images, containers, and why they exist
- [Version Control & Git Workflow](../docs/concepts/version-control-git-workflow/0000-primer-version-control-git-workflow.md) — the ideas behind commits, branches, and remotes
- [CI/CD Pipeline Concepts](../docs/concepts/ci-cd-pipeline-concepts/0000-primer-ci-cd-pipeline-concepts.md) — build, test, deploy, and why it's automated
- [Infrastructure as Code Principles](../docs/concepts/infrastructure-as-code-principles/0000-primer-infrastructure-as-code-principles.md) — describing infrastructure in files, not by hand
- [Scripting & Automation Philosophy](../docs/concepts/scripting-automation-philosophy/0000-primer-scripting-automation-philosophy.md) — when to reach for a script instead of doing it manually
- [Observability & Monitoring Concepts](../docs/concepts/observability-monitoring-concepts/0000-primer-observability-monitoring-concepts.md) — knowing what your systems are doing in production

### Practice a concept hands-on
- [CI/CD stage simulation](../docs/concepts/ci-cd-pipeline-concepts/scripts/2026-07-19-pipeline-stage-sim.sh) — a pure-Bash build→test→deploy pipeline with fail-fast gating
- [Container lifecycle inspection](../docs/concepts/containerization-concepts/scripts/2026-07-20-container-lifecycle-inspection.sh) — inspect running and stopped containers using the Docker API
- [IaC idempotency check](../docs/concepts/infrastructure-as-code-principles/scripts/2026-07-22-iac-idempotency-check.sh) — verify that a provisioning step produces the same result on repeat runs
- [Artifact promotion](../docs/concepts/ci-cd-pipeline-concepts/snippets/2026-07-20-artifact-promotion.py) — promote a build artifact across pipeline stages with an audit trail
- [Image manifest parser](../docs/concepts/containerization-concepts/snippets/2026-07-22-image-manifest-parser.py) — parse container image manifests and extract layer metadata
- [File permissions and processes](../docs/concepts/linux-cli-fundamentals/scripts/2026-07-24-linux-file-permissions-and-process-management.sh) — inspect and modify Linux file permissions, then list and filter running processes
- [Subprocess wrapper](../docs/concepts/linux-cli-fundamentals/snippets/2026-07-24-subprocess-wrapper.py) — run a command and capture stdout/stderr/return code from Python
- [Network connectivity check](../docs/concepts/networking-fundamentals/scripts/2026-07-24-network-connectivity-dns-port-inspection.sh) — test TCP connectivity to a host:port and diagnose why it's unreachable
- [Declarative state diff](../docs/concepts/infrastructure-as-code-principles/snippets/2026-07-22-declarative-state-diff.py) — compute the diff between a declared config and live state
