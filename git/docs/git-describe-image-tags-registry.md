---
last_verified: 2026-08-17
tool_version: n/a
sources: []
---

# Tagging Docker images from `git describe` and pushing to a registry

## Purpose

When a container image leaves a build machine, the image tag is the only label a registry keeps about where that image came from. Tagging from `git describe` is one way to make that tag traceable: the tag encodes both the nearest release tag and the exact commit, so a later operator can read a deployed image tag and know which source revision produced it. This doc walks a small, repeatable workflow for deriving an image tag from git history and pushing it to a registry.

This is one way to do it; more automated CI setups wrap the same idea in higher-level build/push actions, and teams differ on the exact tag scheme. Reading the docs for whichever wrapper you adopt is worth it once the manual flow below is familiar.

## Prerequisites

- A git repository that uses tags at release boundaries (`git tag -l` should show something).
- Docker CLI installed and a local image built already, or a build context ready.
- Write access / credentials for the registry you push to.

## Steps

1. **Ask git for a tag near HEAD.**

   `git describe --tags --abbrev=0` prints the nearest reachable tag with no commit-count suffix — a plain `v1.2.0`. With `git describe --tags` (no flag), git appends the commits since that tag and a short hash, e.g. `v1.2.0-3-g1a2b3c4`. That longer form is the most traceable tag you can get, because it uniquely points at a commit even after the release tag moves.

   If the repo has no tags yet, `git describe` exits non-zero rather than printing anything. Catching that case (`|| true`, or checking the exit code) and falling back to the short SHA keeps the workflow from silently tagging with an empty string.

2. **Shape the string into a Docker tag.**

   Docker tags accept lowercase letters, digits, `_`, `.` and `-`. A plain `v1.2.0` needs no work, but a tag scheme with a `/` or `:` will be rejected by the registry — those two characters are reserved. A safe pipeline is to fold the describe output to lowercase and replace anything Docker rejects with `-` before using it as a tag. `git describe` already emits lowercase, so the main real case is trimming the `g`-prefixed hash trailer when a shorter tag is wanted.

3. **Tag the local image with the registry-qualified name.**

   ```bash
   TAG=$(git describe --tags --abbrev=0)
   docker build -t registry.example.com/app:"${TAG}" .
   ```

   Registry image names are `host[:port]/namespace/name:tag`. Adding the host up front means the later `docker push` has nowhere ambiguous to go; pushing a bare `app:v1.2.0` would target Docker Hub by default, which is a classic surprise for someone first wiring this up.

4. **Authenticate and push.**

   ```bash
   docker login registry.example.com
   docker push registry.example.com/app:"${TAG}"
   ```

   Without a prior `docker login`, the push fails at the end of an (often long) upload with a `denied: requested access to the resource is denied` message rather than failing early. Doing the login before the build catches expired credentials before time is spent building.

## Verify

- `docker manifest inspect registry.example.com/app:"${TAG}"` returns the image's digests and confirms the tag resolved on the registry side.
- Re-read the tag against git: `git describe --tags --abbrev=0` printed the same value that ended up on the image. If the tag embeds a commit suffix, `git log -1 --oneline <short-hash>` shows the exact commit the image came from, closing the traceability loop.

## Get stuck?

- **Empty tag.** `git describe` on a tagless repo exits non-zero; the deletion or the shell mis-assignment then produces an empty `${TAG}`. Add the fallback to a short SHA before building, and print the tag at the top of the script so the failure is visible.
- **Push denied on the first try.** Almost always the missing `docker login`, or credentials that point at a different registry host than the image name's host. Verify the host matches, then retry.
- **What should the tag be at all?** Teams pick different schemes — the pure tag, the tag-plus-commits form, or the short SHA. The scheme matters less than picking one and applying it consistently, so the registry never carries two images that are hard to tell apart.