# Learning Path — DevOps

> A suggested progression from beginner to confident practitioner. Each stage builds on the previous one. If a topic is listed but has no content yet, it's marked as ⏳ (coming soon).

## Stage 1: Foundations

The concepts every DevOps task leans on. Each now has a first-day primer.

- **Linux & CLI Fundamentals** — [primer](../docs/concepts/linux-cli-fundamentals/0000-primer-linux-cli-fundamentals.md): the shell, processes, and filesystem basics underpinning every tool here.
- **Version Control & Git Workflow** — [primer](../docs/concepts/version-control-git-workflow/0000-primer-version-control-git-workflow.md) for the concepts; then [Git quickstart trip-ups](../git/notes/2026-07-13-git-quickstart-trip-ups.md) and [Undo, stage, commit, push](../git/notes/2026-07-13-undo-stage-commit-push.md) for first contact (both refreshed Jul 15).
- **Containerization Concepts** — [primer](../docs/concepts/containerization-concepts/0000-primer-containerization-concepts.md) for what an image and container are; then [Docker quickstart trip-ups](../docker/notes/2026-07-13-docker-quickstart-trip-ups.md) to see it in practice.
- **Infrastructure as Code Principles** — [primer](../docs/concepts/infrastructure-as-code-principles/0000-primer-infrastructure-as-code-principles.md): describing infrastructure in files rather than by hand.
- **Scripting & Automation Philosophy** — [primer](../docs/concepts/scripting-automation-philosophy/0000-primer-scripting-automation-philosophy.md): when to reach for a script instead of doing it manually.

## Stage 2: Core Tools

The tools unlocked from the start. Start here once the foundations make sense.

- **Git** — A handful of notes covering the basics: [quickstart trip-ups](../git/notes/2026-07-13-git-quickstart-trip-ups.md) and [undo/commit/push](../git/notes/2026-07-13-undo-stage-commit-push.md), each refreshed in Jul 15.
- **Docker** — [Quickstart trip-ups](../docker/notes/2026-07-13-docker-quickstart-trip-ups.md), [minimal non-root Dockerfile](../docker/dockerfiles/2026-07-17-minimal-image-tagged-nonroot.Dockerfile), [container run scripts](../docker/scripts/2026-07-18-first-port-mapped-container.sh), and the [sample apps](../docker/src/main.go) they build give you hands-on with images, port mapping, and multi-stage builds.
- **Bash** — [primer](../bash/notes/0000-primer-bash.md), [install and first script](../bash/notes/2026-07-18-install-bash-and-first-script.md), and a [hello-world script](../bash/scripts/2026-07-18-first-hello-world.sh) give you a first-day grounding.
- **Python** ⏳ — scripting and tooling for ops tasks.

## Stage 3: Building Skills

Intermediate concepts that unlock more advanced tools.

- **CI/CD Pipeline Concepts** — [primer](../docs/concepts/ci-cd-pipeline-concepts/0000-primer-ci-cd-pipeline-concepts.md) for the ideas; [CI/CD stage simulation](../docs/concepts/ci-cd-pipeline-concepts/scripts/2026-07-19-pipeline-stage-sim.sh) is a pure-Bash pipeline to practice build→test→deploy gating.
- **Networking Fundamentals** — [primer](../docs/concepts/networking-fundamentals/0000-primer-networking-fundamentals.md): ports, addresses, and how containers talk to each other and the host.

## Stage 4: Advanced Tools

These depend on the foundations being in place.

- **Kubernetes** ⏳ — orchestrating containers at scale (needs Containerization + Linux + Networking).
- **Helm** ⏳ — packaging Kubernetes workloads (needs Containerization + IaC).
- **Terraform** ⏳ — declarative infrastructure provisioning (needs Linux + IaC).
- **Ansible** ⏳ — configuration management and automation (needs Linux + IaC + scripting).

## Stage 5: Mastery

- **Observability & Monitoring Concepts** — [primer](../docs/concepts/observability-monitoring-concepts/0000-primer-observability-monitoring-concepts.md): knowing what your systems are doing in production.
- **Prometheus** ⏳ / **Grafana** ⏳ — metrics collection and dashboards.
- **Jenkins** ⏳ — self-hosted CI/CD pipelines.
- **GitHub Actions** ⏳ — managed CI/CD wired into the repo.

## Progression Map

Bash, Docker, and Git have tool content on disk today, and all eight foundational concepts now have primers. The rest of the map shows what unlocks what once the tool notes land.

```
Foundations (Linux, Git workflow, Containerization, IaC, Scripting)  <-- primers exist
        |
        v
  Core Tools: Bash, Docker, Git  <-- content exists here
        |
        +---> Kubernetes, Helm, Terraform, Ansible (advanced)
        |
  CI/CD + Networking  <-- concept primers exist
        |
        v
  Prometheus, Grafana, Jenkins, GitHub Actions (mastery)
```
