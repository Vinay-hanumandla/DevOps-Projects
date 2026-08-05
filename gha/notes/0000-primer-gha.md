---
last_verified: 2026-08-05
tool_version: n/a
sources:
  - https://www.clouddevopshub.com/blog/15-ci-cd-concepts-every-devops-engineer-must-master-in-2026-complete-guide
---

# GitHub Actions — quick primer

> First-day notes for someone who's never used GitHub Actions. Personal voice, plain language.

## What is it?

GitHub Actions is a CI/CD platform built into GitHub. It lets you automate workflows — like running tests, building artifacts, or deploying code — every time something happens in your repository. Think of it as a way to tell GitHub "when this event happens, run these steps." It's like cron jobs for your repo, but triggered by things like pushes, pull requests, or releases.

## What does it do?

It lets you define workflows in YAML files stored in your repo under `.github/workflows/`. Each workflow has one or more jobs, and each job runs a series of steps on a virtual machine. You can build your code, run tests, lint your scripts, and even deploy — all automatically.

## Why does it exist?

Before GitHub Actions, teams had to set up separate CI/CD servers (like Jenkins or Travis CI) and wire them into GitHub. GitHub Actions eliminates that by putting the automation engine right inside GitHub. You write the workflow config alongside your code, and GitHub handles the rest.

## Key terminology

- **Workflow** — a YAML file that defines an automated process. Example: `.github/workflows/ci.yml` runs your test suite on every push.
- **Job** — a set of steps that run on the same runner. Example: a "build" job compiles your code, a "test" job runs the test suite.
- **Step** — a single action or shell command within a job. Example: `run: npm test` executes your test suite.
- **Runner** — the virtual machine that executes your workflow steps. Example: `ubuntu-latest` is a Linux runner provided by GitHub.
- **Action** — a reusable unit of work, like checking out your repo or caching dependencies. Example: `actions/checkout@v4` fetches your code.

## A tiny example

```yaml
name: hello-actions
on: push
jobs:
  greet:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout
      - run: echo "Hello from GitHub Actions"
```

This workflow triggers on every push, checks out the repo, and prints a greeting. It's the smallest thing you can build.

## What I'll cover next

I want to try writing a workflow that actually runs my test suite, then explore how to use secrets and environment variables. After that I'll look at matrix builds for testing across multiple versions.