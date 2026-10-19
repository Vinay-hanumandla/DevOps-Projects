---
last_verified: 2026-10-19
tool_version: n/a
sources: []
---

# Moving the Jenkinsfile from inline script to SCM

## Purpose

Move a Pipeline job from "Pipeline script" (inline) to "Pipeline script from SCM" to version-control the Jenkinsfile. This covers the four settings that most often cause issues: Script Path, branch specifier, lightweight checkout, and credential-ID gotchas.

## When to use

Use SCM-backed Jenkinsfiles for jobs that should track changes in Git (reviews, branches, history). Keep inline only for throwaway experiments.

## Prerequisites

- Access to the Jenkins job configuration
- The Jenkinsfile committed to a Git repository
- Appropriate credentials if the repo requires auth

## Steps

1. **Commit the Jenkinsfile** - Put the Jenkinsfile at a known path in the repo (commonly `Jenkinsfile` at root).
2. **Change job definition** - In the job config, set Definition to `Pipeline script from SCM` and select the SCM (e.g., Git).
3. **Configure the critical fields**:
   - **Script Path**: Path to Jenkinsfile relative to repo root (e.g., `Jenkinsfile`, `pipelines/build/Jenkinsfile`). Case-sensitive.
   - **Branch Specifier**: Branch to checkout for the Jenkinsfile (e.g., `*/main`, `refs/heads/main`). Wrong branch is a common "No revision found" cause.
   - **Lightweight checkout**: When enabled, Jenkins tries to only fetch the Jenkinsfile. Some SCM/plugin combinations don't fully support it; if you see odd behavior, disable it.
   - **Credentials**: If the repo is private, set the credential ID used by the SCM checkout. Note: credentials used inside the pipeline (`checkout scm` with `credentialsId`) must align with job SCM credentials in many setups.
4. **Save and test** - Run a build and check Console Output for checkout/Jenkinsfile resolution.
5. **Verify behavior** - Ensure `checkout scm` in the pipeline works as expected with the configured credential-ID.

## Verify

- Console shows the repo being checked out and the correct Script Path being loaded.
- No "Could not find Jenkinsfile" or auth errors.
- A subsequent `checkout scm` step succeeds without re-prompting for creds.

## Common errors

| Symptom | Likely cause | Fix |
|---|---|---|
| `ERROR: Could not find Jenkinsfile at <path>` | Wrong Script Path or file not committed | Confirm path relative to repo root and that file exists on the specified branch |
| `No revision found for branch */master` | Branch Specifier doesn't match repo default/branch name | Use `*/main` (or `refs/heads/<branch>`) |
| Auth failure on SCM checkout | Missing/incorrect credential-ID | Use the correct credential type (SSH key for SSH, PAT for HTTPS) with read access |
| `checkout scm` fails on agent even though job checkout works | Credential ID mismatch between job SCM and pipeline step | Inherit via job SCM or pass the same `credentialsId` |

## What to try next

If lightweight checkout causes issues, disable it. For multi-branch workflows, consider a Multibranch Pipeline instead of single-job SCM-backed pipelines.
