---
last_verified: 2026-09-23
tool_version: n/a
sources: []
---

# Integrating Jenkins pipelines with GitHub Actions and Argo CD for progressive delivery

## Purpose

Cover one way to split delivery work across three systems that often coexist: Jenkins builds and publishes the artifact, GitHub Actions runs policy and integration checks on the resulting change, and Argo CD rolls the change out progressively. The docs also suggest a fully Jenkins-driven rollout, but this page describes the split setup because it matches teams that already have Jenkins for builds and want GitOps-style promotion without moving everything at once.

## When to use

Use this pattern when Jenkins is already the build system of record, the deployment target is Kubernetes, and releases need staged promotion (dev, then staging, then a slice of production) rather than a single all-at-once apply. If there is only one environment, or deploys are manual `kubectl apply` runs from a laptop, this split adds coordination overhead without much payoff.

## Prerequisites

- A Jenkins controller with a pipeline job that reads its Jenkinsfile from source control
- A container registry the Jenkins agents and the cluster can both reach
- A Git repository holding the deploy manifests or Helm values that Argo CD watches
- An Argo CD application pointing at that repository and target cluster

## Steps

### 1. Let Jenkins own build and publish, nothing else

Keep the Jenkinsfile narrow: check out source, run unit tests, build the container image, push it with an immutable tag (commit SHA or build number), and stop. One approach that works well is having the pipeline write the resulting image tag to a small text artifact (for example `image-tag.txt`) archived with the build, so the exact tag is traceable without digging through console logs.

The pipeline does not apply anything to the cluster at this stage. That separation is deliberate: cluster state changes only through the Git repository Argo CD watches, so every promotion is a reviewable commit.

### 2. Make the promotion a commit, not a deploy command

A second, short Jenkins stage (or a downstream job triggered only on the main branch) opens the config repository, updates the image tag in the environment overlay for the first environment (dev), and pushes that commit. The docs also suggest updating a values file or a kustomize overlay depending on layout; either works as long as the change is confined to one environment's directory.

Keeping one commit per environment promotion matters: it gives each stage its own review point and its own revert point.

### 3. Gate the middle with GitHub Actions checks

On the config repository, a workflow runs on pull requests that touch the staging and production overlays. Its job is policy, not building: confirm the image tag matches an archived Jenkins build, confirm only the expected overlay files changed, and run any integration or smoke-test suite the team trusts.

A useful shape is two jobs in the workflow: one fast validation job (diff scope, tag format) and one slower test job. Branch protection on the staging and production overlay paths requires both to pass before merge, so a bad promotion commit cannot slip through even if someone pushes directly.

### 4. Let Argo CD sync progressively per environment

Each environment gets its own Argo CD application (or its own target revision/overlay) with automated sync enabled for dev and manual or windowed sync for staging and production. The typical progression this page follows:

1. Dev syncs automatically on every config-repo commit — fast feedback.
2. Staging syncs after the GitHub Actions checks pass and someone approves the pull request.
3. Production syncs in slices: first a canary subset, then the remainder after health checks look clean.

The canary slice can be a separate Argo CD application targeting a labeled subset of the workload, or a progressive strategy managed alongside Argo CD. Either way, the promotion from canary to full is itself a config-repo commit, so the history shows exactly when the slice widened.

### 5. Wire status back so each system can see the others

At minimum, surface three links on every promotion commit message: the Jenkins build URL, the GitHub Actions run URL, and the Argo CD application health after sync. This is low-tech but it is the piece teams miss most often — without it, debugging a stuck promotion means hunting across three UIs with only a timestamp to correlate them.

## Verify

1. Push a test change through Jenkins on a feature branch and confirm the image appears in the registry with the expected immutable tag.
2. Merge to main and confirm the dev overlay commit lands in the config repository.
3. Open the Argo CD UI and confirm the dev application turns healthy after sync.
4. Open a pull request promoting the same tag to staging, confirm both GitHub Actions jobs pass, merge, and confirm the staging application syncs.
5. Promote to the production canary slice, watch health checks, then widen to full and confirm the config-repo history shows one commit per stage.

## Common errors

| Symptom | Likely cause | Fix |
|---|---|---|
| Dev syncs but staging never updates | Promotion commit went to the wrong overlay path | Check the downstream job's target directory; confirm it edits only the intended environment overlay |
| GitHub Actions workflow skips on promotion PRs | Path filter does not match the overlay layout | Align the workflow trigger paths with the actual overlay directories |
| Argo CD shows OutOfSync right after a good sync | Jenkins pushed a second tag commit while the sync was in flight | Serialize promotions per environment; re-sync and confirm the application settles on the latest commit |
| Canary looks healthy but full rollout stalls | Production sync still set to manual from initial setup | Trigger the sync explicitly, then decide whether production should stay manual or move to windowed auto-sync |
| Cannot tell which build a running pod came from | Tag recorded only in console logs | Read the archived `image-tag.txt` (or equivalent) from the Jenkins build and compare with the overlay value in the config repo |

## What the docs also suggest

The Jenkins Pipeline documentation and the Argo CD application documentation each describe end-to-end flows owned by a single system. This page takes the middle path — Jenkins for build, GitHub Actions for gates, Argo CD for rollout — because that is the shape most teams land in when they adopt GitOps incrementally rather than replacing their build system outright.
