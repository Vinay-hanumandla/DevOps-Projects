---
last_verified: 2026-10-03
tool_version: n/a
sources:
  - https://docs.docker.com/guides/gha/
---

# GitHub Actions workflow security hardening

> Least-privilege token scopes, keyless cloud authentication, secret-handling gates, and dependency pinning for workflows that can reach production-adjacent systems.

## Purpose

A workflow file is executable configuration that lives in the repository. The default credentials it runs with, the third-party actions it pulls in, and the event data it interpolates into shell commands are all attack surface. This reference covers the four controls that reduce that surface: scoping the workflow token, replacing stored cloud keys with short-lived federated credentials, keeping secrets out of Git history, and pinning third-party actions to an immutable ref.

## When to use

Apply these controls when any of the following is true:

- The workflow pushes images, writes releases, publishes packages, or applies infrastructure.
- The workflow runs on `pull_request` events, which means it executes code proposed by someone who may not have write access.
- The workflow consumes third-party actions that the team does not own.
- The workflow authenticates to a cloud provider, a cluster, or a secret store.

For a first CI workflow that only lints a fork's pull request, the `permissions` block alone is usually sufficient; the rest of this document matters as soon as credentials are involved.

## Prerequisites

- Administrative access to the repository settings, to change the default workflow token permissions and enable code-security features.
- An identity provider already configured to trust the repository, if OIDC federation is used.
- A short list of the API calls each job actually makes, since the permission set is derived from that list rather than the other way round.

## Steps

### 1. Declare an explicit token scope for every job

The `GITHUB_TOKEN` is minted per job and its scopes come from the `permissions` block, not from the repository defaults. Declaring the key sets every scope that is *not* listed to `none`, so an explicit block is a default-deny statement rather than an additive one.

```yaml
permissions: {}          # workflow level: no scopes for any job

jobs:
  test:
    runs-on: ubuntu-latest
    permissions:
      contents: read     # checkout and read the repository
    steps:
      - uses: actions/checkout@v6
        persist-credentials: false
```

Two properties matter here. First, `persist-credentials: false` stops the checkout action from leaving the token in the local git config, so a later step that runs repository-controlled code cannot reuse it. Second, job-level `permissions` overrides the workflow-level block entirely, which lets a read-only test job coexist with a publishing job in the same file.

### 2. Derive the scope list from the API calls, not from habit

For each job, list the calls it makes and grant only the matching scope:

| Job activity | Scope to grant |
|---|---|
| Check out code, read tree | `contents: read` |
| Read PR metadata, post a review comment | `pull-requests: write` |
| Push a container image to a registry | `packages: write`, `contents: read` |
| Create a release or a deployment record | `contents: write`, `deployments: write` |
| Upload a code-scanning result | `security-events: write` |
| Exchange an OIDC token for cloud credentials | `id-token: write` |

Granting `contents: write` to a job that only builds is the most common over-grant, because the workflow file is copied from a template that needed it for a release job.

### 3. Replace stored cloud keys with OIDC

A long-lived cloud access key in repository secrets is a credential that outlives the job that needs it and cannot be scoped to one repository, one ref, or one run. Requesting a federated token instead bounds the credential to the run that requested it; the trust policy on the cloud side then decides whether the presented claims are acceptable.

```yaml
  deploy:
    permissions:
      contents: read
      id-token: write      # required to request the token at all
      deployments: write
    steps:
      - name: Request federated token
        id: oidc
        env:
          AUDIENCE: api://GitHubActions
        run: |
          token=$(curl -s "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=${AUDIENCE}" \
            -H "Authorization: bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" | jq -r .value)
          echo "token=$token" >> "$GITHUB_OUTPUT"
```

The `id-token: write` scope is the permission that makes this possible, and it is the one scope that cannot be constrained further from inside the workflow: a job holding it can mint a token with any audience. Bound it by the trust policy conditions on the provider side — audience, repository, and ref — so a token minted by an untrusted ref is rejected on arrival. The mechanics of each provider's exchange, and the claim conditions each one expects, are covered in [OIDC token exchange with GitHub Actions](./oidc-token-exchange.md).

### 4. Keep secrets out of the repository

Repository secrets are the right place for values that must exist, and the wrong place for anything that leaked into a commit — a value in history is in history, and removing the commit does not remove it from any clone that already fetched it.

- Enable secret scanning and push protection in the repository's code-security settings so a matching credential blocks the push instead of being discovered later.
- Run the same scan locally before pushing, so the fix happens on the developer machine rather than in a failed CI run.
- Rotate any credential that has ever been committed, in the order it was exposed. Rotation is the control; redaction is cleanup.
- Expect secrets to be unavailable to workflows triggered by pull requests from forks. A job whose design assumes a secret is available will behave differently on an untrusted ref, which is why step 3 removes the need for the secret in the first place.

### 5. Pin third-party actions to an immutable ref

A tag is a mutable pointer. Pinning `uses:` to a major tag means the code that runs today can differ from the code that ran last week without any change to the repository, which makes both review and incident response unreliable.

```yaml
    steps:
      # <full-40-character-commit-sha> is a placeholder — resolve it yourself from
      # the action's repository before committing; never copy a SHA from a blog post.
      - uses: actions/checkout@<full-40-character-commit-sha>   # v6
      - uses: docker/login-action@<full-40-character-commit-sha> # v4
```

The 40-character commit SHA is immutable; the trailing comment records the human-readable version for the next upgrade. This is the same action set the Docker GitHub Actions guide pins by tag — `actions/checkout@v6`, `docker/metadata-action@v6`, `docker/login-action@v4`, `docker/setup-buildx-action@v4`, `docker/build-push-action@v7` — so the SHA form maps directly onto a documented example.

Configure automated updates for GitHub Actions dependencies so the SHA pins stay current; a pinning policy without an update path becomes a reason to stop upgrading, and frozen actions are their own supply-chain problem.

### 6. Never interpolate untrusted event data into a `run:` block

The workflow runner substitutes `${{ }}` expressions into the script text before the shell sees it. When the expression contains attacker-controlled data — a pull request title, a branch name, a comment body — that data becomes shell syntax, and the injected command runs with the job's token.

```yaml
    steps:
      - name: Announce the branch
        env:
          BRANCH_NAME: ${{ github.head_ref }}     # passed as data, not as code
        run: |
          echo "building ${BRANCH_NAME}"
```

Routing every untrusted value through `env:` makes it a shell variable instead of script text. The same rule applies to `actions/checkout` with a `ref:` taken from event data, and to any `github.event.*` path that a user can influence.

### 7. Treat privileged triggers as privileged code

`pull_request_target` runs in the context of the base repository, where repository secrets are available. Combining it with a checkout of the pull request head merges "untrusted code" with "trusted credentials" in one job. Prefer plain `pull_request` for anything that checks out proposed code, and move privileged work behind an environment that requires approval.

```yaml
  deploy:
    environment: production        # required reviewers configured on the environment
    runs-on: ubuntu-latest
    steps:
      - run: ./scripts/deploy.sh   # this repository's own deployment entrypoint
```

## Verify

1. **Scope audit.** For each job, confirm the granted scopes match a call the job actually makes. Removing a scope and re-running the workflow is the fastest way to find an over-grant: the run fails with a permission error at the exact step that needed it.
2. **Fork behaviour.** Open a pull request from a fork and confirm the workflow runs with the reduced scope set and fails cleanly at any step that would have needed a secret, rather than failing later in a confusing way.
3. **Injection resistance.** Create a branch whose name contains shell metacharacters and confirm the workflow handles it as a string.
4. **Federation.** Trigger the deploy job from an untrusted ref and confirm the cloud provider rejects the token, then confirm the same job succeeds from the protected branch.
5. **Pin integrity.** Confirm every `uses:` entry resolves to a 40-character SHA rather than a tag.

## Common errors

| Symptom | Likely cause | Resolution |
|---|---|---|
| `403 Resource not accessible by integration` on a step that worked under the old default token | The scope was removed while narrowing the `permissions` block, or a job-level block overrode the workflow-level one | Add the single scope the failing call needs to that job's block; do not widen the workflow-level block to compensate |
| Workflow passes on branch pushes and fails on pull requests from forks | A step depends on a repository secret that is not exposed to untrusted refs | Replace the secret with a federated token, or gate the step so untrusted events never reach it |
| Cloud provider rejects the federated token with a claim-mismatch error | The trust policy conditions do not match the claims the current ref or environment produces | Align the provider's audience, repository, and ref conditions with the workflow's actual trigger; see [OIDC token exchange](./oidc-token-exchange.md) |
| Build steps behave differently between two runs with no repository change | The action was pinned by tag and the tag now points at different code | Pin by commit SHA and configure automated updates |
| A known credential is still usable after being removed from the branch | The value remains in history and in existing clones | Rotate the credential; treat history rewriting as cleanup only |
