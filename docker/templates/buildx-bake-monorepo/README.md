---
last_verified: 2026-09-21
tool_version: n/a
---

# Buildx Bake template for monorepo services

## Purpose

This template provides a single Buildx Bake definition that builds every service in a monorepo from one entrypoint. A shared `_common` target carries the cross-cutting build policy — registry-backed layer cache, provenance and SBOM attestations, and multi-platform output — so each service target only declares what makes it different: its Dockerfile path and its image tags. A `check` target reuses the same definition for pull-request pipelines that should build without pushing.

## When to use

Use this template when a repository holds two or more container images that must ship with the same supply-chain posture. It fits teams that publish each service to a primary registry while mirroring to a second registry for availability or locality reasons, and teams that want pull-request builds to exercise the same definition as release builds.

Do not use it for a single-image repository, where a plain build invocation is simpler, or when services need divergent build policies that would turn the shared target into a conditional maze. In those cases keep per-service definitions separate.

## Prerequisites

- A builder with multi-platform support and network access to both registries.
- Registry credentials for the primary registry, the mirror registry, and the cache repository.
- One Dockerfile per service at the path referenced by its Bake target.
- A tag value per build (commit digest, branch name, or release identifier) passed through the `TAG` variable.

## Layout

| Path | What it is |
|---|---|
| `docker-bake.hcl` | Bake definition: `default` group, shared `_common` target, per-service targets, `check` target |
| `services/api/Dockerfile`, `services/api/server.py` | Placeholder API service and its stdlib server |
| `services/web/Dockerfile`, `services/web/index.html` | Placeholder web service and its static page |
| `.env.example` | Tunable values (registries, tag, cache reference) — copy to `.env` |

## Steps

1. Copy the tunables into a local file and adjust the registry hosts: `cp .env.example .env`, then load the values into the environment before each Bake invocation.
2. Review the `_common` target in `docker-bake.hcl`. The cache reference should point at a repository the build identity can read and write; the attestation list should match what the deployment environment is prepared to verify.
3. Add a service by copying one of the existing targets: set its `dockerfile` path, list its tags under both registries, and add its name to the `default` group.
4. Run a pull-request style build that exercises compilation without publishing: `docker buildx bake check`.
5. Publish a tagged release build of every service by passing the tag explicitly, e.g. `TAG=<tag> docker buildx bake`. The shared target's `output` setting pushes each service to both registries.
6. Confirm the cache warms subsequent runs: rebuild the same inputs and check that layer reuse is reported instead of full re-execution.

## Verify

- `docker buildx bake --print` renders the full matrix (both services, both registries, cache and attestation settings) without errors.
- `docker buildx bake check` completes without pushing any image to a registry.
- A tagged bake pushes both `api` and `web` images to the primary registry and the mirror registry under the same tag.
- Rebuilding unchanged inputs reuses cached layers instead of rebuilding them.
- Each published image carries provenance and SBOM attestation metadata retrievable from the registry.

## Common errors

- **Cache repository not writable.** The build falls back to executing every layer. Confirm the cache reference and that the build identity has write access to it.
- **Mirror registry unreachable.** Tags for the unreachable registry fail while primary tags succeed. Verify network access and credentials for each registry independently before a release build.
- **Attestation metadata missing on the image.** The shared target declares attestations, but the builder must support them. Check the builder capabilities when images publish without the expected metadata.
- **New service missing from the default group.** A target that builds in isolation but not in the group run was added without updating the group list. Keep the group membership next to the target definitions so the omission is visible in review.
- **Stale tag reused across releases.** Reusing one tag for different contents makes rollbacks ambiguous. Pass a distinct tag per build rather than relying on the default.

## References

No external references were used in this note.
