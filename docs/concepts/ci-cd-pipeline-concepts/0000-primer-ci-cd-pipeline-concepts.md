---
last_verified: 2026-07-19
tool_version: n/a
sources:
  - https://about.gitlab.com/topics/ci-cd/
  - https://skillrealm-learn.planandmultiply.io/en/blog/cicd-pipeline-explained-beginners
  - https://devops.com/a-beginners-guide-to-ci-cd-and-ci-cd-pipelines/
---

# CI/CD Pipeline Concepts — quick primer

> First-day notes on CI/CD. What it is, why it matters, and the key ideas to know before I touch any pipeline tool.

## What is it?

A CI/CD pipeline is an automated workflow that runs a series of checks every time code changes. The typical shape is Source → Build → Test → Package → Deploy → Monitor. Each stage has to pass before the next one runs, so a bad change gets stopped early instead of reaching production.

It's like a quality conveyor belt for code: instead of a person manually building, testing, and deploying by hand (and forgetting a step), the machine does it the same way every single time. You push code; the pipeline decides if it's safe to go further.

## Why does it matter for DevOps?

Before CI/CD, teams did "integration hell" — everyone worked on separate branches for weeks, then tried to merge everything on a Friday and spent the weekend fixing conflicts. CI/CD replaces that with small, frequent integrations.

The point for a DevOps practitioner is that it removes manual handoffs and creates a reproducible, auditable path from a commit to a running service. Modern guidance even frames it as a security imperative: scanning code at commit time catches vulnerabilities immediately, not weeks later. I'll be running into this every time I wire up GitHub Actions, Jenkins, or similar later.

## Key terminology

- **Pipeline** — the whole automated workflow. Example: a `.github/workflows/ci.yml` file that runs on every push.
- **Stage** — a logical phase with a gate, like "Build" or "Test". Example: the test stage only runs if build succeeded.
- **Gate** — a pass/fail checkpoint. Example: "unit tests must be green" is a gate before deploy.
- **Artifact** — a build output you can store and ship. Example: a Docker image or a compiled binary.
- **Environment** — a target like dev, staging, or prod. Example: deploy to staging first, then prod.
- **Fail-fast** — stop the pipeline at the first failure instead of running everything. Example: run the 5-second lint check before the 10-minute integration test.
- **Rollback** — revert to the previous working version. Example: if prod smoke tests fail, go back to the last good release.
- **Runner / agent** — the machine that actually executes the jobs. Example: GitHub-hosted runners run my workflow steps.
- **Shift-left** — run quality and security checks early in the pipeline. Example: lint and SAST at commit time, not after deploy.
- **Canary deployment** — roll out to a small percentage of users first. Example: send 5% of traffic to the new version before going all-in.

## A concrete example

A minimal pipeline shape for a Python service, expressed as stages rather than any one tool's syntax:

```
push to main
  -> stage: checkout code
  -> stage: install deps (pip install -r requirements.txt)
  -> stage: lint + unit tests (pytest)
  -> stage: build + tag Docker image
  -> stage: deploy to staging + smoke test
  -> gate:   manual approval
  -> stage: canary rollout to 5% of prod
```

This shows the fail-fast idea: if `pytest` fails, we never build or deploy. Each arrow is a gate.

## How this connects to what's next

This concept is the foundation for the actual tools I'll learn — GitHub Actions and Jenkins both just implement these stages and gates. Once I understand pipeline/delivery/deployment, the YAML and web UIs will make a lot more sense. It also unlocks the more concrete Containerization and Infrastructure as Code ideas, since those are usually the "build" and "deploy" stages of the same pipeline.
