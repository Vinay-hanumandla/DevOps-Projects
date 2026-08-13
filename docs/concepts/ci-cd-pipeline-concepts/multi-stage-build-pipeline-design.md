---
last_verified: 2026-08-13
tool_version: n/a
---

# Combining CI/CD Pipeline Concepts with Containerization: multi-stage build pipeline design

> Designing CI/CD pipelines that incorporate container multi-stage builds to separate build-time and runtime environments.

## Purpose

This document explains how CI/CD pipeline design combines with containerization through multi-stage build patterns. The core idea is to use a CI/CD pipeline to drive a container multi-stage build, where one stage compiles or assembles the application and a subsequent stage copies only the runtime artifacts into a minimal base image. This approach keeps the final container image small and limits the attack surface by excluding build tools from the runtime environment.

## When to use

Use this pattern when the CI/CD pipeline needs to produce container images as part of the delivery workflow. It is particularly relevant for compiled languages, applications with native dependencies, or any workflow where the build environment differs substantially from the runtime environment.

## Prerequisites

- A functioning CI/CD pipeline that can execute shell commands or dedicated build steps.
- A container runtime available in the pipeline environment.
- Basic familiarity with container image layers and base image selection.

## Steps

1. **Define the pipeline trigger.** Configure the pipeline to run on the events that should produce a new image: push to the main branch, pull request updates, or tag creation. The trigger determines when the multi-stage build runs.

2. **Set up the build stage.** In the Dockerfile, declare a build stage that installs compilers, SDKs, and build-time dependencies. This stage produces the compiled artifact or bundled application. The CI/CD pipeline invokes the build command targeting this stage.

3. **Define the final stage.** Add a second stage that uses a minimal base image. Copy the compiled artifacts from the build stage. The CI/CD pipeline builds this stage to produce the final image.

4. **Run tests in the pipeline.** Before pushing the image, execute any tests that validate the compiled artifact. This keeps test feedback in the CI/CD system rather than inside the container.

5. **Push the image.** After the final stage builds successfully, push the image to a container registry. Tag the image with the commit SHA or pipeline run number so every deployment can be traced back to a specific pipeline execution.

## Verify

1. Build the image locally using the same Dockerfile the pipeline uses. Confirm the final image size is smaller than a single-stage build that includes build tools.
2. Inspect the image layers to verify no build tools or source code remain in the final stage.
3. Trigger the pipeline and confirm it produces an image, runs the defined tests, and pushes the tagged image to the registry.
