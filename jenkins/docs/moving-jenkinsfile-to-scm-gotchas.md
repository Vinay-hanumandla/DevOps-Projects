---
last_verified: 2026-09-21
tool_version: n/a
sources: []
---

# Moving a Jenkinsfile from inline script to SCM

When a pipeline job is created with the **Pipeline script** option, the Jenkinsfile lives inside Jenkins configuration. Moving it to **Pipeline script from SCM** shifts ownership to the repository, which is the standard pattern for version-controlled pipelines. This page covers the four settings that trip people up during that migration.

## Purpose

Configure a Pipeline job to read its Jenkinsfile from a Git repository instead of the inline script box. The four settings that most often cause failed checkouts or "no Jenkinsfile found" errors are Script Path, Branch Specifier, Lightweight checkout, and Credentials.

## Prerequisites

- A Jenkins controller with the Git plugin installed
- A Git repository containing a `Jenkinsfile` (or differently named pipeline script) at a known path
- Credentials in Jenkins that can read the repository (username/password, SSH private key, or GitHub App token)

## Steps

### 1. Change the Definition dropdown

In the job configuration, change **Definition** from `Pipeline script` to `Pipeline script from SCM`. The **SCM** selector appears; choose `Git`.

### 2. Set Repository URL and Credentials

Enter the repository clone URL (HTTPS or SSH). Under **Credentials**, select or add a credential entry that Jenkins can use to authenticate to the Git host.

- **HTTPS URL**: Use a "Username with password" credential where the password is a personal access token (PAT), not the account password.
- **SSH URL**: Use an "SSH Username with private key" credential. The username is typically `git` for GitHub/GitLab/Bitbucket; the private key is the content of the private key file (or path to it on the controller if using the Jenkins master key).
- **GitHub App**: Use the "GitHub App" credential type if the organization uses GitHub Apps for CI access.

> Common issue: The credential ID used here must match the ID referenced in any `checkout scm` step or `withCredentials` block inside the Jenkinsfile. If the job uses one credential ID but the pipeline script expects another (e.g., via `environment { GIT_CREDENTIALS_ID = 'my-id' }`), the checkout inside the pipeline will fail even though the initial SCM checkout succeeded.

### 3. Configure Branch Specifier

Under **Branches to build**, enter the branch name pattern. The default `*/main` (or `*/master`) builds the default branch.

- Use `*/feature/*` to build any branch under `feature/`
- Use `*/main, */develop` (comma-separated) to build multiple specific branches
- Use `**` to build all branches (including PR refs) — often combined with "Discover branches" strategies in Multibranch Pipeline jobs

For a standard Pipeline job (not Multibranch), the Branch Specifier is a single pattern. If the repository uses `main` but the specifier says `*/master`, Jenkins will report "No revision found" on every build.

### 4. Set Script Path

The **Script Path** field tells Jenkins where to find the Jenkinsfile relative to the repository root. Default is `Jenkinsfile`.

- If the file is at the repo root: `Jenkinsfile` (default)
- If the file is in a subdirectory: `ci/Jenkinsfile` or `pipelines/main.jenkinsfile`
- If the file has a non-standard name: `ci/build.groovy`

The path is relative to the workspace root after checkout. A leading `./` is accepted but not required.

> Gotcha: If the repository uses a monorepo layout with multiple pipelines, each Pipeline job must point to its own Script Path. Two jobs pointing to the same repo but different Script Paths will each check out the full repo unless Lightweight checkout is enabled (see below).

### 5. Lightweight checkout (optional but recommended)

Check **Lightweight checkout** to have Jenkins retrieve only the Jenkinsfile (via `git archive` or the SCM API) instead of cloning the entire repository during the initial SCM polling/checkout phase.

- **When enabled**: The first checkout is fast and uses minimal disk space. The full clone happens later when the pipeline runs `checkout scm` inside an agent.
- **When disabled**: Jenkins performs a full clone upfront. This is slower and uses more disk, but some legacy SCM plugins or complex submodule setups may require it.

For most Git repositories, Lightweight checkout should be **on**. It reduces controller load and speeds up the "Scan Repository" / "Build Now" feedback loop.

> Caveat: If the Jenkinsfile uses `checkout scm` without arguments, the full clone happens on the agent regardless of this setting. Lightweight checkout only affects the controller-side polling/initial fetch.

## Verify

1. Save the job configuration.
2. Click **Build Now**.
3. Open the **Console Output** of the new build.
4. Confirm:
   - The log shows `Checking out git <url> into <workspace> to read Jenkinsfile` (lightweight) or a full clone message
   - The Jenkinsfile is found at the specified Script Path
   - Subsequent `checkout scm` steps inside the pipeline succeed with the configured credentials

## Common errors

| Symptom | Likely cause | Fix |
|---|---|---|
| `ERROR: Could not find Jenkinsfile at <path>` | Script Path does not match actual file location | Verify the path relative to repo root; check spelling and case sensitivity |
| `No revision found for branch */master` | Branch Specifier uses wrong default branch name | Change to `*/main` or the correct branch pattern |
| `Authentication failed` / `Permission denied` | Credentials missing, wrong type, or insufficient scope | Re-create credential with correct type (PAT for HTTPS, SSH key for SSH) and ensure token/key has read access to the repo |
| Pipeline starts but `checkout scm` fails inside agent | Credential ID used by pipeline differs from job SCM credential | Align the credential ID in `withCredentials` / `checkout` with the job's SCM credential, or use `credentialsId: ''` to inherit the job's SCM credential |
| Lightweight checkout enabled but full clone still happens on controller | SCM plugin does not support lightweight mode (rare for Git) | Disable Lightweight checkout; file a plugin issue if unexpected |

## Rollback

If the SCM-backed job fails and you need the inline script back immediately:

1. Change **Definition** back to `Pipeline script`.
2. Paste the last working Jenkinsfile content into the script box.
3. Save and run **Build Now**.

The job's build history is preserved. No data is lost by switching Definition modes.

## What the docs also suggest

The Jenkins Pipeline documentation notes that for complex multi-repository setups, a **Multibranch Pipeline** job is often preferable to multiple single-branch Pipeline jobs. Multibranch automatically discovers branches, creates sub-jobs per branch, and handles Script Path per-branch via `Jenkinsfile` detection. This page covers the single-job migration path; Multibranch is a separate pattern.