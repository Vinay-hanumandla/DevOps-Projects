---
last_verified: 2026-08-27
tool_version: n/a
---

# Following the GitHub Actions quickstart — what tripped me up

> Following the official GitHub Actions quickstart, here's what worked and where it broke.

## What I did

I followed the GitHub Actions quickstart to set up a basic CI workflow. The goal was simple: push code and have a workflow run automatically. The quickstart made it look straightforward, but I ran into a few snags that the docs glossed over.

## Steps I took

1. Created a `.github/workflows/` directory in my repo — this is where all workflow files live.
2. Wrote a minimal workflow YAML file with a name, a trigger (`on: push`), and a job that runs on `ubuntu-latest`.
3. Added a step that uses `actions/checkout@v4` to pull the repo, then a step that runs `echo "Hello, world!"`.
4. Committed and pushed — the Actions tab lit up and the workflow ran.

## Got stuck on

- **YAML indentation matters.** I wasted 20 minutes because I mixed tabs and spaces in the workflow file. GitHub Actions silently ignores YAML errors in some cases — the workflow shows as "started" but no jobs actually run. I had to look at the raw YAML parsing to spot the tab character.

- **The `on` trigger syntax confused me.** The quickstart shows `on: push` but I wanted to trigger only on pushes to `main`. The correct syntax is `on: push: branches: [ main ]`, not `on: push: branches: main`. The array brackets are required even for a single branch.

- **Runner image versions are not pinned by default.** `ubuntu-latest` points to whatever Ubuntu version GitHub currently considers latest. This means my workflow could break when they upgrade. I learned to check the runner images documentation to see what's actually available and whether I should pin to a specific version like `ubuntu-24.04`.

- **Actions marketplace versioning.** The quickstart uses `actions/checkout@v4` but I initially typed `actions/checkout@v3` because that's what an older tutorial showed. There's no warning that the version is outdated — it just works differently or fails silently. I started checking the marketplace page for the latest major version tag.

## What I'd try next

I want to build out a real CI workflow with matrix builds across multiple OS versions, and explore caching to speed up dependency installs. I'm also curious about reusable workflows and composite actions — they seem useful once you have more than one repo that needs the same CI steps.
