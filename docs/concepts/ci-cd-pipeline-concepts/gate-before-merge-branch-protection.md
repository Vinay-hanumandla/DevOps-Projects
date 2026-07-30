---
last_verified: 2026-07-30
tool_version: n/a
sources:
  - https://skillions.in/devops-explained-in-2026-how-ci-cd-docker-kubernetes-accelerate-modern-software-development/
  - https://johanneskueber.com/posts/2026-06-19-oci-gitpos-automatic-promotion/
  - https://www.bmc.com/blogs/devops-containers/
---

# CI/CD Pipeline Concepts: gate-before-merge with branch protection

> Combining CI/CD with Version Control: how branch protection rules and pipeline gates work together to block broken merges.

## Purpose

This doc explains how CI/CD pipelines and Version Control systems combine through the gate-before-merge pattern with branch protection. The idea is straightforward: no code reaches the main branch unless the pipeline says it is safe, and the VCS enforces that rule mechanically.

In the CI/CD + VCS integration pattern, the repository is the source of truth that triggers the pipeline. The pipeline validates the change and, if it passes, the VCS gate allows the merge to proceed. This pattern replaces manual review gates with automated, repeatable checks that every contributor and every merge request must satisfy.

## When to use

Use the gate-before-merge pattern when multiple people collaborate on a shared codebase and you need to ensure that every change has been validated by the automated pipeline before it reaches the protected branch. This is the standard approach for teams adopting CI/CD with Git-based workflows.

## Steps

1. **Define branch protection rules** in the VCS platform. Require status checks to pass before merging. Block direct pushes to the target branch. Require pull requests for all changes.

2. **Configure the CI pipeline** to run the appropriate checks on every pull request: lint, unit tests, integration tests, and image builds where applicable.

3. **Wire the pipeline status back to the VCS** so the branch protection rules can read the result. Most CI systems provide a status API or commit-status endpoint that the VSC platform polls.

4. **Enforce the gate in the merge workflow**. The VCS platform refuses to merge the pull request until every required check is green. The OCI-First GitOps pattern extends this idea: image promotions move through dev → staging → prod gates, each verified before the next stage starts. Verification layers include app image signatures, deployment artifact signatures, pointer commits, and admission controllers.

5. **Review the DORA metrics** to see whether the gate is working. Lead time for changes and change failure rate are the two metrics most affected by a well-tuned gate-before-merge setup. A good gate keeps the change failure rate low without inflating lead time.

## Verify

Confirm that a pull request cannot be merged when any required check is red. Test by pushing a change that intentionally fails a test and verifying that the merge button stays disabled.

## Common errors

- **Stale status checks** — a pipeline run from a previous commit remains green after a new push. The pipeline should re-run on every new commit in the pull request.
- **Incomplete branch protection** — enabling status checks but not blocking direct pushes means a force-push can bypass the gate. Always enable the "require branches to be up to date" rule alongside status checks.
- **Missing verification layers** — running only unit tests at the merge gate leaves integration and security checks to later stages, where failures are more expensive to fix.

## References

- CI/CD + Docker + Kubernetes integration pattern — https://skillions.in/devops-explained-in-2026-how-ci-cd-docker-kubernetes-accelerate-modern-software-development/
- OCI-First GitOps with Kargo + Flux + Renovate — https://johanneskueber.com/posts/2026-06-19-oci-gitpos-automatic-promotion/
- DORA metrics and container orchestration — https://www.bmc.com/blogs/devops-containers/