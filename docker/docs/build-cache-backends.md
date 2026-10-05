---
last_verified: 2026-10-04
tool_version: n/a
---

# Choosing between Docker build cache backends: inline, registry, and remote cache for CI pipelines

## Purpose

CI pipelines rebuild images from scratch on every run unless the build cache is shared between runs. This note compares three cache backends — inline cache, registry cache, and remote cache stored outside the registry — so a team can pick the one that matches its pipeline shape: single-branch builds on ephemeral runners, multi-branch builds that share layers, or builds that need cache to survive registry cleanup.

## When to use

Use inline cache when the pipeline is simple: one branch builds and pushes the image, and later runs only need to rebuild that same image faster. The cache travels inside the pushed image, so there is nothing extra to configure or clean up.

Use registry cache when several branches or jobs should share layers. The cache is pushed as a separate image alongside the release image, so a feature-branch build can reuse layers produced by the main branch without pulling the whole release image.

Use a remote cache backend when the cache should live independently of the images being released — for example when registry retention rules prune old tags, or when the CI platform offers its own cache storage that runners can reach faster than the registry.

## Prerequisites

- A build setup that supports separate cache import and export (a builder with distinct cache-from and cache-to steps).
- Push access to wherever the cache will live: the image repository for the inline and registry backends, or the remote storage for the remote backend.
- A repeatable layer order — dependency installation before source copy — so that cache hits are likely across runs.
- A way to observe hit rates per pipeline run, such as builder output that reports cached versus executed steps.

## Steps

1. **Order the build for cache reuse.** Keep dependency installation in early layers and application source in later layers. This ordering benefits every backend equally and is the cheapest win before choosing one.

2. **Start with inline cache for a single-branch pipeline.** Export the cache into the pushed image itself and import it on the next run. There is one artifact to manage and no extra cleanup policy to write.

3. **Move to registry cache when branches need to share layers.** Export the cache to a dedicated cache tag and import from both that tag and the main release tag. A feature-branch run then hits layers built by the main branch even though it never pulled the release image.

4. **Move to a remote backend when the registry is the wrong home for cache.** Point the export at the remote storage and the import at the same location. Keep the release tags and the cache lifecycle on independent retention rules so that pruning old release tags never discards cache that active branches still need.

5. **Scope cache keys per branch with a fallback.** Import from the branch-specific cache first and fall back to the main-branch cache. This keeps experimental branches fast without letting their layers pollute the shared cache.

6. **Record the decision per pipeline.** Note which backend each pipeline uses, where its cache lives, and when to revisit the choice (for example when a second branch starts building the same image, or when registry cleanup starts deleting cache tags).

## Verify

- Run the same pipeline twice without source changes and confirm the second run reports cache hits for the unchanged layers.
- Open a short-lived branch, push one commit, and confirm its build reuses the main-branch layers instead of rebuilding them.
- After the retention window passes, confirm that active branches still get cache hits — a missed hit here means cleanup is deleting cache that builds still need.
- Compare end-to-end pipeline duration before and after the change over several runs, not a single run, since cold versus warm runners add noise.

## Common errors

| Symptom | Likely cause | Fix |
|---|---|---|
| Every run rebuilds all layers | Cache import points at a tag that is never pushed, or each run uses a fresh cache key | Import from a tag the pipeline actually pushes; add a stable fallback key |
| Feature branches never hit cache | Import list contains only the branch tag, which is empty on first push | Add the main-branch cache as a fallback import |
| Cache hits disappear after cleanup | Cache shares a tag pattern with release images and gets pruned | Store cache under its own tag or backend with its own retention rule |
| Cache grows without bound | Each run pushes a new cache artifact and nothing expires old ones | Set a retention rule on the cache location and keep one tag per active branch |
| Local builds are fast but CI is slow | Layers are ordered for local iteration, not for CI change patterns | Move dependency installation above source copy so CI changes invalidate fewer layers |

## References

- Builder output for the pipeline's own runs (cache-hit reporting per step).
- The registry's tag list and retention settings for the image repository in use.
