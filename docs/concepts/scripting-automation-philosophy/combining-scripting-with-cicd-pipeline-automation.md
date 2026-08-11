---
last_verified: 2026-08-11
tool_version: n/a
sources:
  - https://www.bitslovers.com/gitlab-ci-terraform-iac-pipeline/
  - https://codenscripts.com/automating-common-dev-tasks-a-library-of-ci-cd-and-deploy-sc
---

# Combining Scripting & Automation with CI/CD — pipeline automation patterns

> How the Scripting & Automation Philosophy and CI/CD pipeline concepts combine: scripts hold the business logic, the pipeline YAML stays a thin orchestration layer, and the same scripts run locally and in CI.

## Purpose

The scripting philosophy and CI/CD are the same idea at two scales. Scripts make a single task repeatable and reviewable; pipelines orchestrate many such tasks triggered by events like a push, merge, or tag. This pattern combines them by keeping the *logic* in scripts and the *sequencing* in the pipeline. That way the exact same behavior runs on a laptop and inside a CI job, which kills the "works on my machine" class of failure [source: https://codenscripts.com/automating-common-dev-tasks-a-library-of-ci-cd-and-deploy-sc].

## Steps

1. **Build a script library with one entry point and thin delegation.** A practical library starts with one entry script (e.g. `scripts/deploy`) that delegates to task-specific scripts such as `lint.sh`, `test.sh`, `build.sh`, `deploy.sh`. CI and humans get one stable interface, and each script stays modular and testable. Shared helpers live in `scripts/lib.sh` [source: https://codenscripts.com/automating-common-dev-tasks-a-library-of-ci-cd-and-deploy-sc].

2. **Make scripts take flags, never prompts.** CI jobs are non-interactive — a script waiting on stdin deadlocks a run. Pass environment and mode via CLI args or env vars, validate them up front, and whitelist the allowed values (`staging|production`) before doing any work [source: https://codenscripts.com/automating-common-dev-tasks-a-library-of-ci-cd-and-deploy-sc].

3. **Fail fast with `set -euo pipefail` and explicit logging.** The script stops at the first error instead of cascading through partial work, and it prints the exact command so the failure is reproducible. Setting `CI=1` disables interactive behavior and makes local runs behave like CI [source: https://codenscripts.com/automating-common-dev-tasks-a-library-of-ci-cd-and-deploy-sc].

4. **Treat idempotency as a contract.** Re-running must converge to the same end state. A lint script that only reads is naturally idempotent; a build must clear `dist/` first so a half-finished build can't poison the next run; a deploy must not double-send notifications or re-apply migrations [source: https://codenscripts.com/automating-common-dev-tasks-a-library-of-ci-cd-and-deploy-sc].

5. **End deploys with a health check, not "service restarted".** Validate the artifact, extract it to a timestamped release dir, swap an atomic symlink, reload the service — then curl the health endpoint with `--fail` and only report success after it responds. A deploy that exits 0 before verifying the service gives false confidence [source: https://codenscripts.com/automating-common-dev-tasks-a-library-of-ci-cd-and-deploy-sc].

6. **Use the plan-as-artifact pattern for infrastructure changes.** When the pipeline drives Terraform, separate validate → plan → apply. `validate` is fast and runs on every commit; `plan` saves the plan as a binary artifact (plus a JSON copy posted to the merge request for review); `apply` consumes that exact saved plan — the same plan file applied twice produces the same result. Apply for dev is automatic; apply for prod is a manual gate, so a human approves the reviewed plan before anything is applied [source: https://www.bitslovers.com/gitlab-ci-terraform-iac-pipeline/].

## Verify

- Run a library script locally and from the pipeline; confirm identical behavior and that the pipeline YAML is a thin caller, not a duplicate of the logic.
- Re-run the same deploy script twice and confirm the second run converges — no duplicate notifications or releases.
- Run `terraform apply` with the saved plan artifact and confirm it uses the exact plan rather than re-planning.
- Break a check on purpose and confirm the pipeline stops before the next stage, and that a manual apply gate blocks an unapproved prod apply.

This progression — script library, then a deploy service when queuing and retries break, then GitOps with the repo as the source of truth — is the same philosophy scaled up: every action logged, gated, and reproducible [source: https://www.bitslovers.com/gitlab-ci-terraform-iac-pipeline/, https://codenscripts.com/automating-common-dev-tasks-a-library-of-ci-cd-and-deploy-sc].
