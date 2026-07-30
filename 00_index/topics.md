# Topics

> A map of what's here. For a beginner-to-advanced reading order, see [learning-path.md](learning-path.md).

## Bash  ·  10 files

- **primer:** [Bash — quick primer](../bash/notes/0000-primer-bash.md)
- **notes** (3): most recent → [Bash guide — trip-ups](../bash/notes/2026-07-23-bash-guide-trip-ups.md), [Install Bash and first script](../bash/notes/2026-07-18-install-bash-and-first-script.md)
- **docs** (2): most recent → [Strict mode and trap patterns](../bash/docs/strict-mode-trap-patterns.md), [Robust Bash scripting](../bash/docs/2026-07-23-robust-bash-scripts.md)
- **scripts** (5): most recent → [System report tool](../bash/scripts/system-report-tool.sh), [Safe Bash template](../bash/scripts/2026-07-23-safe-bash-template.sh), [Hello world with argument handling](../bash/scripts/2026-07-18-first-hello-world.sh)
- _…and 2 more under `bash/scripts/` — browse the folder._

## Docker  ·  10 files

- **primer:** [Docker — quick primer](../docker/notes/0000-primer-docker.md)
- **notes** (4): most recent → [Install Docker](../docker/notes/2026-07-19-install-docker.md), [Docker follow-up trip-ups](../docker/notes/2026-07-15-docker-quickstart-trip-ups.md), [Docker quickstart trip-ups](../docker/notes/2026-07-13-docker-quickstart-trip-ups.md)
- **dockerfiles** (1): [Minimal non-root image](../docker/dockerfiles/2026-07-17-minimal-image-tagged-nonroot.Dockerfile)
- **scripts** (3): [Hello-world container](../docker/scripts/2026-07-19-first-hello-world.sh), [Run nginx with port map](../docker/scripts/2026-07-18-first-port-mapped-container.sh), [Run container with port map](../docker/scripts/2026-07-16-run-container-port-map.sh)
- **src** (2): [Sample Python HTTP server](../docker/src/2026-07-16-server.py), [Sample Go HTTP server](../docker/src/main.go)

## Git  ·  18 files

- **primer:** [Git — quick primer](../git/notes/0000-primer-git.md)
- **notes** (12): most recent → [Companion forgotten undo notes 15](../git/notes/2026-07-28-git-companion-forgotten-undo-notes-15.md), [Companion forgotten undo notes](../git/notes/2026-07-28-git-companion-forgotten-undo-notes.md), [Companion readme quickstart trip-ups](../git/notes/2026-07-28-git-companion-readme-quickstart-trip-ups.md), [Companion readme](../git/notes/2026-07-27-git-companion-readme.md), [Install Git](../git/notes/2026-07-20-install-git.md)
- **docs** (2): [Interactive rebase vs merge commit](../git/docs/interactive-rebase-vs-merge-commit.md), [How I wired Git hooks into local dev](../git/docs/how-i-wired-git-hooks-into-my-local-dev-workflow.md)
- **scripts** (3): [Feature branch rebase workflow](../git/scripts/feature-branch-rebase-workflow.sh), [Branch, merge, revert](../git/scripts/2026-07-20-branch-merge-revert.sh), [First repo lifecycle](../git/scripts/2026-07-20-first-repo.sh)
- **hooks** (1): [Install Git hooks](../git/hooks/install.sh)
- _…and more under `git/` — browse the folder._

## Python  ·  3 files

- **primer:** [Python — quick primer](../python/notes/0000-primer-python.md)
- **scripts** (1): [Create venv and run](../python/scripts/2026-07-22-create-venv-and-run.py)
- **snippets** (1): [First script — variables and types](../python/snippets/2026-07-22-first-script-variables-types.py)

## Terraform  ·  2 files

- **notes** (1): [Install Terraform and run first version command](../tf/notes/2026-07-26-install-terraform-and-run-first-version-command.md)
- **configs** (1): [First Terraform local file resource](../tf/configs/2026-07-26-first-terraform-local-file-resource.hcl)

## Concepts (docs/concepts/)  ·  23 files

Foundational primers on the ideas the tools build on — one primer per concept, plus runnable scripts and snippets for most.

- **CI/CD Pipeline Concepts** (6): [primer](../docs/concepts/ci-cd-pipeline-concepts/0000-primer-ci-cd-pipeline-concepts.md) · [gate-before-merge with branch protection](../docs/concepts/ci-cd-pipeline-concepts/gate-before-merge-branch-protection.md) · [companion requirements notes](../docs/concepts/ci-cd-pipeline-concepts/notes/2026-07-28-companion-requirements.md) · script: [CI/CD stage simulation](../docs/concepts/ci-cd-pipeline-concepts/scripts/2026-07-19-pipeline-stage-sim.sh) · snippet: [Artifact promotion](../docs/concepts/ci-cd-pipeline-concepts/snippets/2026-07-20-artifact-promotion.py) · notebook: [Pipeline metrics and health dashboards](../docs/concepts/ci-cd-pipeline-concepts/notebooks/pipeline-metrics-and-health-dashboards.ipynb)
- **Containerization Concepts** (3): [primer](../docs/concepts/containerization-concepts/0000-primer-containerization-concepts.md) · script: [Container lifecycle inspection](../docs/concepts/containerization-concepts/scripts/2026-07-20-container-lifecycle-inspection.sh) · snippet: [Image manifest parser](../docs/concepts/containerization-concepts/snippets/2026-07-22-image-manifest-parser.py)
- **Infrastructure as Code Principles** (3): [primer](../docs/concepts/infrastructure-as-code-principles/0000-primer-infrastructure-as-code-principles.md) · script: [IaC idempotency check](../docs/concepts/infrastructure-as-code-principles/scripts/2026-07-22-iac-idempotency-check.sh) · snippet: [Declarative state diff](../docs/concepts/infrastructure-as-code-principles/snippets/2026-07-22-declarative-state-diff.py)
- **Linux & CLI Fundamentals** (4): [primer](../docs/concepts/linux-cli-fundamentals/0000-primer-linux-cli-fundamentals.md) · [errors I found](../docs/concepts/linux-cli-fundamentals/notes/2026-07-28-errors-i-found.md) · script: [File permissions and processes](../docs/concepts/linux-cli-fundamentals/scripts/2026-07-24-linux-file-permissions-and-process-management.sh) · snippet: [Subprocess wrapper](../docs/concepts/linux-cli-fundamentals/snippets/2026-07-24-subprocess-wrapper.py)
- **Networking Fundamentals** (3): [primer](../docs/concepts/networking-fundamentals/0000-primer-networking-fundamentals.md) · script: [Network connectivity check](../docs/concepts/networking-fundamentals/scripts/2026-07-25-practice-network-connectivity-dns-port-inspection.sh) · snippet: [Socket connection tester](../docs/concepts/networking-fundamentals/snippets/2026-07-26-socket-connection-tester.py)
- **Observability & Monitoring Concepts** (1): [primer](../docs/concepts/observability-monitoring-concepts/0000-primer-observability-monitoring-concepts.md)
- **Scripting & Automation Philosophy** (1): [primer](../docs/concepts/scripting-automation-philosophy/0000-primer-scripting-automation-philosophy.md)
- **Version Control & Git Workflow** (2): [primer](../docs/concepts/version-control-git-workflow/0000-primer-version-control-git-workflow.md) · [companion readme](../docs/concepts/version-control-git-workflow/notes/2026-07-28-companion-readme.md)
- _…and more under `docs/concepts/` — browse the folder._
