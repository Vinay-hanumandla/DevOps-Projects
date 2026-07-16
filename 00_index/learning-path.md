# Learning Path — DevOps

> A suggested progression from beginner to confident practitioner. Each stage builds on the previous one. If a topic is listed but has no content yet, it's marked as ⏳ (coming soon).

## Stage 1: Foundations

The concepts every DevOps task leans on.

- **Linux & CLI Fundamentals** ⏳ — the shell, processes, and filesystem basics underpinning every tool here.
- **Version Control & Git Workflow** — [Git quickstart trip-ups](../git/notes/2026-07-13-git-quickstart-trip-ups.md) covers first contact; [Undo, stage, commit, push](../git/notes/2026-07-13-undo-stage-commit-push.md) walks the working cycle. Refreshed notes from Jul 15 add a second perspective on each.
- **Containerization Concepts** — [Docker quickstart trip-ups](../docker/notes/2026-07-13-docker-quickstart-trip-ups.md) covers what an image and container are on first contact; the Jul 15 refresh adds more gotchas.
- **Infrastructure as Code Principles** ⏳ — describing infrastructure in files rather than by hand.
- **Scripting & Automation Philosophy** ⏳ — when to reach for a script instead of doing it manually.

## Stage 2: Core Tools

The tools unlocked from the start. Start here once the foundations make sense.

- **Git** — A handful of notes covering the basics: [quickstart trip-ups](../git/notes/2026-07-13-git-quickstart-trip-ups.md) and [undo/commit/push](../git/notes/2026-07-13-undo-stage-commit-push.md), each refreshed in Jul 15.
- **Docker** — [Quickstart trip-ups](../docker/notes/2026-07-13-docker-quickstart-trip-ups.md), [minimal non-root Dockerfile](../docker/dockerfiles/2026-07-13-minimal-nonroot-image.Dockerfile), [tagged-build variant](../docker/dockerfiles/2026-07-16-minimal-image-tagged-nonroot.Dockerfile), and [container run scripts](../docker/scripts/2026-07-13-first-port-mapped-container.sh) give you hands-on with images, port mapping, and multi-stage builds.
- **Bash** ⏳ — command-line scripting for day-to-day automation.
- **Python** ⏳ — scripting and tooling for ops tasks.

## Stage 3: Building Skills

Intermediate concepts that unlock more advanced tools.

- **CI/CD Pipeline Concepts** ⏳ — automating build, test, and deploy once the basics are solid.
- **Networking Fundamentals** ⏳ — ports, bridges, and how containers talk to each other and the host.

## Stage 4: Advanced Tools

These depend on the foundations being in place.

- **Kubernetes** ⏳ — orchestrating containers at scale (needs Containerization + Linux + Networking).
- **Helm** ⏳ — packaging Kubernetes workloads (needs Containerization + IaC).
- **Terraform** ⏳ — declarative infrastructure provisioning (needs Linux + IaC).
- **Ansible** ⏳ — configuration management and automation (needs Linux + IaC + scripting).

## Stage 5: Mastery

- **Observability & Monitoring Concepts** ⏳ — knowing what your systems are doing in production.
- **Prometheus** ⏳ / **Grafana** ⏳ — metrics collection and dashboards.
- **Jenkins** ⏳ — self-hosted CI/CD pipelines.
- **GitHub Actions** ⏳ — managed CI/CD wired into the repo.

## Progression Map

Docker and Git have content on disk today. The rest of the map shows what unlocks what once the notes land.

```
Foundations (Linux, Git, Containerization, IaC, Scripting)
        |
        v
  Core Tools: Docker, Git  <-- content exists here
        |
        +---> Kubernetes, Helm, Terraform, Ansible (advanced)
        |
  CI/CD + Networking
        |
        v
  Prometheus, Grafana, Jenkins, GitHub Actions (mastery)
```
