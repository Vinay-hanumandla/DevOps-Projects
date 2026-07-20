# Quick Links

## I need to...

### Get started with Bash
- [Bash primer](../bash/notes/0000-primer-bash.md) — what Bash is, key terminology, and a tiny example
- [Install Bash and first script](../bash/notes/2026-07-18-install-bash-and-first-script.md) — install check, first .sh file, and permission gotcha

### Write and run a Bash script
- [Hello world with argument handling](../bash/scripts/2026-07-18-first-hello-world.sh) — a minimal script that checks for arguments

### Get started with Docker
- [Docker quickstart trip-ups](../docker/notes/2026-07-13-docker-quickstart-trip-ups.md) — what to expect and where beginners get stuck
- [Docker quickstart follow-up](../docker/notes/2026-07-15-docker-quickstart-trip-ups.md) — more gotchas after the initial run-through

### Build a container image
- [Minimal non-root Dockerfile](../docker/dockerfiles/2026-07-17-minimal-image-tagged-nonroot.Dockerfile) — multi-stage build to a distroless, non-root runtime

### Run a container
- [Run container with port map](../docker/scripts/2026-07-16-run-container-port-map.sh) — run a tagged image, map a port, verify, and tear down
- [Run nginx with port map](../docker/scripts/2026-07-18-first-port-mapped-container.sh) — run nginx, map a port, verify, and tear down

### Get started with Git
- [Git quickstart trip-ups](../git/notes/2026-07-13-git-quickstart-trip-ups.md) — first contact with Git and where it tripped me up
- [Git follow-up trip-ups](../git/notes/2026-07-15-git-quickstart-trip-ups.md) — more first-contact gotchas on the second pass

### Undo and fix a Git mistake
- [Undo, stage, commit, push](../git/notes/2026-07-13-undo-stage-commit-push.md) — unstage, discard, revert, and safely rewrite a local commit
- [Undo follow-up](../git/notes/2026-07-15-undo-stage-commit-push.md) — more undo patterns: stash, amend after push, recovering lost work

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
