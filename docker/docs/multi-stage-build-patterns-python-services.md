---
last_verified: 2026-09-20
tool_version: n/a
---

# Multi-stage build patterns for Python services

## Purpose

A multi-stage build separates dependency compilation and application assembly from the runtime image. For a Python service, that separation makes it possible to keep build-time tooling out of the final image while choosing a runtime profile that matches the service's operational needs.

This note compares three runtime profiles: slim, distroless, and Alpine. The comparison is about the workflow and trade-offs, not a claim that one profile is always smaller, safer, or faster. The right choice depends on the service's dependencies, debugging needs, and release process.

## When to use

Use a multi-stage pattern when the service needs compilation, dependency resolution, or test tooling that should not ship with the running process. It is also useful when the same source tree must produce images for different runtime policies, such as a diagnostic build for development and a reduced build for deployment.

Choose the runtime profile after inventorying what the service actually needs. A profile that is convenient during development can be a poor fit when the runtime environment is expected to be minimal. Conversely, a reduced runtime is not useful if the service depends on tooling or libraries that are difficult to reproduce outside the build stage.

## Prerequisites

- A Python service with a repeatable dependency manifest.
- A build process that can install dependencies and assemble the application without interactive input.
- A defined service entrypoint and a way to exercise its health or readiness behavior.
- A test environment that can run the final image, not only the source tree.
- A record of the runtime requirements so that a profile change can be reviewed rather than guessed.

## Runtime profiles

### Slim runtime

A slim runtime is a practical default when the service benefits from a conventional runtime environment. It is a useful fit when native dependencies, diagnostic utilities, or operational tooling are part of the normal service workflow.

The main trade-off is that the final image contains more runtime material than a reduced profile. That can make the image easier to inspect, but it also increases the amount of content that must be reviewed and maintained. Keep the runtime stage explicit: copy only the dependency artifacts and application files that the service needs, and leave compilers, caches, and test fixtures in the build stage.

### Distroless runtime

A distroless runtime is appropriate when the service's runtime dependencies are known and can be copied deliberately from the build stage. It favors a small, focused runtime over an interactive debugging environment.

This profile changes the troubleshooting workflow. Instead of assuming that a shell or general-purpose utilities will be available inside the running image, verify dependencies during the build and provide an external diagnostic path for incidents. The pattern works best for services with a stable, well-understood runtime surface and a release process that tests the final image as a unit.

### Alpine runtime

An Alpine runtime can suit a service whose dependencies and runtime behavior have been validated against that environment. It is a reasonable option when a small base and a distinct runtime ecosystem are intentional requirements.

The important constraint is compatibility. A dependency that works in one runtime profile should not be assumed to work in another without a clean build and runtime test. Pay particular attention to native extensions, process behavior, and any tooling that the service invokes at startup. If those checks are not repeatable, a more conventional runtime profile is usually easier to operate.

## Comparison

| Decision area | Slim | Distroless | Alpine |
|---|---|---|---|
| Runtime convenience | Best fit when conventional runtime tooling is useful | Intentionally limited; plan diagnostics outside the image | Useful when its runtime assumptions are accepted |
| Dependency work | Broad compatibility is often convenient | Dependencies must be assembled and copied deliberately | Compatibility must be tested for the service |
| Debugging | Easier to inspect from inside the image | Requires build-time checks or a separate diagnostic approach | Requires the same explicit verification as any profile change |
| Operational discipline | Review the runtime contents regularly | Keep the runtime surface narrow and documented | Record why this profile is appropriate for the service |
| Good first use | General Python services and services with native dependencies | Stable services with a known runtime contract | Services validated for the Alpine runtime environment |

The profiles are not a universal ranking. A slim image can be the most maintainable choice for one service, while a distroless or Alpine image can be the clearer choice for another.

## Steps

1. **Inventory the runtime contract.** List the files, libraries, environment values, and entrypoint behavior the service needs after startup. Separate these requirements from tools used only to build or test the code.

2. **Create one reproducible build stage.** Resolve dependencies from the manifest, compile anything that must be compiled, and run the service's automated checks. Keep this stage independent of the runtime profile.

3. **Copy explicit artifacts into the runtime stage.** Transfer the installed dependency set and application source or package only. Do not copy the build workspace wholesale when a narrower set of files is sufficient.

4. **Select the runtime profile deliberately.** Use slim when runtime convenience and broad compatibility matter most. Use distroless when the runtime contract is stable and diagnostics can be handled externally. Use Alpine when the service has been validated for that environment and the choice is part of the design.

5. **Define the launch and health path.** Keep the service entrypoint consistent across profiles. Exercise the same readiness or health behavior in every candidate image so that a profile change does not hide a startup regression.

6. **Record the decision.** Note the service requirements that led to the selected profile, the checks performed, and the conditions that would justify changing it. This makes a future base-image review a reasoned comparison rather than an unexplained substitution.

## Verify

- Build each candidate from a clean context and confirm that dependency resolution is reproducible.
- Run the service's automated checks in the build stage before copying artifacts to the runtime stage.
- Inspect the final runtime contents and remove files that are not part of the documented runtime contract.
- Start the final image and exercise the service entrypoint, health behavior, and representative request path.
- Compare behavior across the candidate profiles using the same application inputs and environment values.
- Confirm that logs, signals, working directories, and dependency loading remain consistent after the runtime profile changes.
- Repeat the checks after dependency or base-image changes; do not treat a previously selected profile as permanently correct.

## Common errors

- **Copying the build workspace into the runtime image.** This brings build-only material into the final image and weakens the reason for using multiple stages.
- **Changing only the base profile and assuming the result is equivalent.** Dependency compatibility and runtime behavior need to be exercised again.
- **Choosing a reduced runtime without a diagnostic plan.** The image may start correctly in tests while remaining difficult to investigate during an incident.
- **Mixing development and runtime requirements.** Interactive tools and test dependencies belong in the build workflow unless the service genuinely needs them at runtime.
- **Treating image size as the only decision.** Startup behavior, dependency compatibility, maintainability, and troubleshooting all affect the final choice.

## References

No external references were used in this note.
