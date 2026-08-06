---
last_verified: 2026-08-06
tool_version: n/a
---

# GitHub Actions quickstart — what tripped me up

> Following the GitHub Actions quickstart, here's what worked and where I got stuck.

## What I did

I followed the GitHub Actions quickstart to set up a basic workflow that runs on pushes and pull requests. The goal was to get a workflow file in place and see it execute at least once.

## Steps I took

1. Created `.github/workflows/ci.yml` in my repo.
2. Defined a `push` and `pull_request` trigger targeting the `main` branch.
3. Added a single job with `actions/checkout` and a `run` step.
4. Committed and pushed to trigger the workflow.

## Got stuck on

- I forgot to add the `branches` filter under `on: push`, so the workflow fired on every push to every branch. That's fine for testing, but it's noisy and not what you want in a real setup.
- I assumed `actions/checkout` would automatically make my workflow file visible to subsequent steps. It doesn't — the checkout step fetches the repo at the commit that triggered the workflow, so the workflow file itself is already there by the time the job runs.
- I didn't realize that `on: pull_request` triggers on all PR types (opened, synchronize, reopened) by default. I had to read the docs to understand the event payload differences.

## What I'd try next

I want to add a step that actually runs a test command or linter to make the workflow do real work. Then I'd explore how to use `secrets` to pass tokens safely, and finally look at matrix builds to test across multiple versions.