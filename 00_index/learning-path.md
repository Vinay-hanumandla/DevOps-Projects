# Learning Path — DevOps

> A suggested progression from beginner to confident practitioner. Each stage builds on the previous one. If a topic is listed but has no content yet, it's marked as ⏳ (coming soon).

## Stage 1: Foundations

The concepts every DevOps task leans on. No primers are written yet — these are the next things to capture.

- **Linux & CLI Fundamentals** ⏳ — the shell, processes, and filesystem basics underpinning every tool here.
- **Version Control & Git Workflow** ⏳ — branching, merging, and PR-based collaboration.
- **Containerization Concepts** ⏳ — what an image and a container actually are, and why they matter.
- **Infrastructure as Code Principles** ⏳ — describing infrastructure in files rather than by hand.
- **Scripting & Automation Philosophy** ⏳ — when to reach for a script instead of doing it manually.

## Stage 2: Core Tools

The tools unlocked from the start. Start here once the foundations make sense.

- **Docker** — [Docker quickstart trip-ups](docker/notes/2026-07-13-docker-quickstart-trip-ups.md) covers what to expect on first contact, [Minimal non-root Dockerfile](docker/dockerfiles/2026-07-13-minimal-nonroot-image.Dockerfile) shows a real multi-stage build, and [First port-mapped container](docker/scripts/2026-07-13-first-port-mapped-container.sh) runs and tears down a container.
- **Bash** ⏳ — command-line scripting for day-to-day automation.
- **Git** — [Git quickstart trip-ups](git/notes/2026-07-13-git-quickstart-trip-ups.md) covers first contact and where it tripped me up, and [Undo, stage, commit, push](git/notes/2026-07-13-undo-stage-commit-push.md) walks the stage → commit → push cycle and how to undo each step.
- **Python** ⏳ — scripting and tooling for ops tasks.

## Stage 3: Building Skills

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
  Core Tools: Docker  <-- content exists here
        |
        +---> Kubernetes, Helm, Terraform, Ansible (advanced)
        |
  CI/CD + Networking
        |
        v
  Prometheus, Grafana, Jenkins, GitHub Actions (mastery)
```
