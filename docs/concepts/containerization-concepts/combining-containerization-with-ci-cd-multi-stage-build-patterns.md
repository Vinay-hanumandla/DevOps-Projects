---
last_verified: 2026-07-31
tool_version: n/a
sources:
  - https://codeandcoffe.com/docker-deep-dive-containerization-in-2026/
  - https://www.bmc.com/blogs/devops-containers/
---

# Combining Containerization with CI/CD — multi-stage build patterns

> How CI/CD pipelines use Docker multi-stage builds to produce lean, secure images.

## Purpose

This pattern combines containerization with CI/CD to automate the creation of optimized Docker images. Multi-stage builds use multiple `FROM` statements in a single Dockerfile, allowing the build stage to compile or install dependencies and the final stage to copy only the runtime artifacts. This keeps production images small and reduces the attack surface.

## When to use

Use multi-stage builds in CI/CD pipelines when the build process requires compilers, SDKs, or build tools that should not ship to the runtime image. This is common for compiled languages (Go, Rust, Java) and for applications that need build-time dependency resolution.

## Steps

1. **Define a build stage** that installs dependencies and compiles the application. This stage uses a full base image with build tools.
2. **Define a final stage** that uses a minimal base image (such as `distroless` or `alpine`). Copy the compiled artifacts from the build stage using `COPY --from=builder`.
3. **Integrate the Dockerfile into the CI/CD pipeline** so that `docker build` runs automatically on each commit or pull request.
4. **Scan the resulting image** for vulnerabilities before pushing to a registry. Tools like `docker scout cves` automate this step.

## Verify

1. Run `docker build` locally and confirm the final image size is significantly smaller than a single-stage build would produce.
2. Inspect the image with `docker inspect` to verify no build tools remain in the final layer.
3. In the CI/CD pipeline, confirm the build step completes without errors and the image is pushed to the registry.

## How this connects to what's next

This pattern is a foundation for secure container delivery. The next step is adding image scanning and signing to the pipeline, which feeds into observability by ensuring only verified images reach production.