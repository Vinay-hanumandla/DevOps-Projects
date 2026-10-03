---
last_verified: 2026-10-03
tool_version: n/a
sources: []
---

# Integrating Python with Docker and GitHub Actions: production CI pipeline for lint, type-check, test, and publish

> A reference layout for a Python service that runs lint, type-check, and tests in GitHub Actions, then builds and publishes a Docker image plus the Python package from the same pipeline.

## Purpose

This document describes a single continuous-integration pipeline that takes a Python project from pull request to published artifacts. The pipeline has four quality gates — lint, type-check, test, and Docker build — followed by a publish stage that pushes the container image to a registry and the built package to a package index. The goal is one workflow where a green run means the change is safe to release, with no manual build or publish step.

## When to use

Use this shape when the project ships as both a Python package and a container image, which is the common case for services and workers. It fits repositories with a `pyproject.toml`, a test suite runnable with a single command, and a `Dockerfile` at the repo root. For a library that never ships a container, the Docker stages can be dropped and the remaining gates stay unchanged. For a matrix-testing or release-notes setup, the sibling integration guide covers that angle and this document focuses on the gated build-and-publish flow.

## Prerequisites

- A Python project with declared dependencies and a lockfile or pinned requirements file.
- A linter configuration, a type-checker configuration, and a test suite that all run locally with one command each.
- A `Dockerfile` with at least a runtime stage; a multi-stage file with a dedicated test stage is recommended.
- A container registry and a package index the workflow is authorized to push to, with credentials stored as encrypted secrets or exchanged via short-lived identity tokens.

## Steps

### 1. Fix the repository layout

Keep the pipeline inputs in conventional locations so every gate can assume them:

```
.
├── .github/workflows/ci.yml
├── Dockerfile
├── pyproject.toml
├── tests/
└── src/<package>/
```

The workflow file owns the gate order. The `Dockerfile` owns the runtime image. Nothing else in the repo needs to know about CI.

### 2. Gate 1 — lint

Run the linter first because it is the fastest gate and catches the cheapest defects. The step installs dependencies, then runs the linter over the package and test trees:

```yaml
- name: Lint
  run: |
    pip install -e ".[dev]"
    ruff check src tests
```

A lint failure stops the pipeline before slower gates consume runner minutes. Keep lint rules in the repository configuration so local runs and CI runs evaluate the same rule set.

### 3. Gate 2 — type-check

Run the type-checker as a separate job or step so its failures are reported independently of lint and tests:

```yaml
- name: Type-check
  run: mypy src
```

Type-checking only the shipped package (not generated code or vendored fixtures) keeps the signal clean. New modules should be covered by the checker's scope from the start; narrowing the scope later to silence errors hides real defects.

### 4. Gate 3 — test

Run the test suite with a short traceback mode so failures are readable in the workflow log:

```yaml
- name: Test
  run: pytest --tb=short
```

Tests run against the installed package (`pip install -e .` in an earlier step), not against stray files on the path, so import errors surface here rather than after release. Coverage thresholds belong in the test configuration, not in the workflow file, so the same threshold applies locally.

### 5. Gate 4 — Docker build

Build the image only after the three code gates pass, using the repository `Dockerfile`. A multi-stage file lets the image reuse the test stage for an in-image smoke check:

```dockerfile
FROM python:slim AS base
WORKDIR /app
COPY pyproject.toml ./
RUN pip install .
COPY src/ ./src/

FROM base AS test
COPY tests/ ./tests/
RUN pytest --tb=short

FROM base AS runtime
CMD ["python", "-m", "<package>"]
```

The workflow builds the `runtime` target for publishing. Building the `test` target on pull requests gives an early signal that the package installs and passes tests inside the actual image filesystem, not just on the runner.

### 6. Publish — image and package

Publish runs only on the protected branch (or on tag pushes), never on pull requests. The workflow signs in to the registry, builds with the commit SHA as the image tag, and pushes:

```yaml
jobs:
  publish:
    needs: [lint, typecheck, test, docker-build]
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - name: Build and push image
        run: |
          docker build -t my-registry/my-service:${{ github.sha }} .
          docker push my-registry/my-service:${{ github.sha }}
      - name: Build and publish package
        run: |
          python -m build
          python -m twine upload dist/*
```

The `needs` clause is the release guarantee: nothing publishes unless all four gates passed on the same commit. Tagging the image with the commit SHA makes every published image traceable to the exact commit that produced it; a floating tag can be moved to the SHA after the run succeeds.

## Verify

- Open a pull request with a deliberate lint error and confirm the pipeline fails at the lint gate while later gates are skipped.
- Push a fix and confirm all four gates pass on the same commit.
- Merge to the protected branch (or push a tag, depending on the trigger) and confirm the publish job runs, the image appears in the registry with the commit-SHA tag, and the package appears in the index.
- Pull the published image on a clean machine and run the service entrypoint to confirm the runtime stage contains everything the application needs.

## Common errors

| Symptom | Likely cause | Fix |
|---|---|---|
| Tests pass on the runner but fail inside the image | Test stage installs dev extras the runtime stage omits, or the image copies a different file set | Install the same dependency set in both stages; copy `src/` identically and re-run the image test target |
| Pipeline publishes from a pull request | Missing branch or tag guard on the publish job | Add the `if` condition on the protected ref so forks and pull requests can never reach the push steps |
| Lint passes locally but fails in CI | Linter configuration not committed, or local and CI install different extras | Commit the linter configuration and install the same `.[dev]` extras in both places |
| Type-check errors appear only in CI | Local runs check a narrower path than the workflow | Run the identical `mypy src` invocation locally; keep the scope in one committed configuration |
| Image tag cannot be traced to a commit | Floating tag overwritten by concurrent runs | Tag every build with the commit SHA and move the floating tag only after verification |

## References

- Sibling guide: `python-github-actions-integration.md` (matrix testing, dependency caching, release automation).
- Sibling comparison: `comparing-python-configuration-approaches.md` (packaging and configuration choices this pipeline assumes).
