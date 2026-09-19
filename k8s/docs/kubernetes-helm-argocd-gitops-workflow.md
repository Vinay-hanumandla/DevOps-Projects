---
last_verified: 2026-09-19
tool_version: n/a
---

# Integrating Kubernetes with Helm and Argo CD: end-to-end GitOps workflow

> How an application change travels from a repo commit to a running workload when Helm renders the desired state and Argo CD reconciles it inside the cluster.

## Purpose

Teams that deploy to Kubernetes by hand eventually hit the same problem: the cluster works, but nobody can say exactly which commit it is running or reproduce that state elsewhere. Helm addresses the packaging side by templating related manifests into one releasable chart with explicit values per environment. Argo CD addresses the delivery side by watching a repo path and reconciling the cluster toward whatever that path declares. Together they form a GitOps loop where the repo is the source of truth, the chart is the unit of change, and the cluster converges on its own.

## When to use this pattern

This setup fits teams making repeated application releases to one or more clusters where changes need review before they land. It is also useful when several environments should run the same chart with different values, or when an incident requires answering "what changed" from repo history rather than from someone's shell history.

It is less useful for a one-off experiment on a throwaway cluster, where the extra moving parts slow things down. The workflow pays off once releases recur and need to be repeatable.

## Prerequisites

- A reachable cluster with admin-equivalent access for the initial setup.
- The command-line clients for Kubernetes, Helm, and Argo CD installed where the setup is performed.
- An application repo containing a Helm chart, with environment-specific value files kept beside the chart.
- A separate location for the desired-state declarations Argo CD watches — either a path in the same repo or a dedicated config repo.

## Steps

1. **Package the application as a chart.** Keep templates for the workload objects (deployment, service, config) and expose environment differences through named value files. Render locally and inspect the output before anything touches the cluster.

2. **Publish the desired state to the watched path.** Commit the chart reference and the value file for the target environment to the path Argo CD tracks. The commit message should identify the release so later history reads clearly.

3. **Declare the Argo CD application.** Point an application entry at the repo, the watched path, and the destination cluster and namespace. This is the one manual binding step; everything after it flows from repo content.

4. **Let Argo CD reconcile.** Argo CD compares the watched path against the live cluster and applies the difference. Review the sync result in the Argo CD view and confirm the expected resources appeared.

5. **Promote through environments by committing.** Move a release forward by updating the value reference on the next environment's path, not by re-running commands against the cluster. Each promotion is a reviewable commit.

6. **Roll forward on failure.** If a release misbehaves, fix it with a new commit rather than editing live objects. Direct cluster edits get overwritten at the next sync and leave history disagreeing with reality.

## Verify

After a sync, confirm the application entry reports a healthy synced state, the workload objects match the chart values for that environment, and traffic reaches the new revision. For a promotion, verify each environment independently — a healthy staging sync does not prove the values file for the next environment is correct.

## Common mistakes

The most common mistake is editing live objects to "fix" something quickly and then wondering why the change vanished at the next sync. Another is storing environment values in several places so the environments drift apart silently. A third is pointing Argo CD at a branch head that moves under it, so nobody can tell which commit a sync actually delivered — pin the watched revision explicitly.
