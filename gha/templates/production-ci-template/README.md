---
last_verified: 2026-10-19
tool_version: n/a
sources:
  - https://docs.github.com/en/actions/using-workflows/reusing-workflows
  - https://docs.github.com/en/actions/creating-actions/creating-a-composite-action
  - https://docs.github.com/en/actions/security-guides/encrypted-secrets
  - https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment
  - https://docs.github.com/en/actions/security-guides/hardening-security-for-github-actions
  - https://docs.docker.com/guides/gha/
---

# Production CI Template

> Complete GitHub Actions CI/CD pipeline with matrix builds, dependency caching, environment approvals, and OIDC-to-cloud deployment.

## Purpose

This template provides a production-ready CI/CD pipeline for containerized applications. It implements security hardening, multi-platform testing, dependency caching, environment-gated deployments, and keyless cloud authentication via OIDC federation.

## When to use

Use this template when:

- You need a CI pipeline that tests across multiple OS/python version combinations.
- You deploy to Kubernetes clusters on AWS, GCP, and/or Azure.
- You require manual approval gates for production deployments.
- You want to eliminate long-lived cloud credentials from repository secrets.
- You need SBOM generation and vulnerability scanning in your pipeline.

Do not use this template for:

- Simple single-environment projects without cloud deployment.
- Projects that don't use container images.
- Teams without administrative access to configure OIDC trust relationships.

## Prerequisites

- GitHub repository with Actions enabled.
- Administrative access to repository settings (for environments, secrets, OIDC).
- Cloud provider accounts with OIDC trust configured:
  - **AWS**: IAM role with trust policy for GitHub OIDC provider, `sts:AssumeRoleWithWebIdentity` permission.
  - **GCP**: Workload Identity Pool and Provider trusting GitHub, service account with required IAM roles.
  - **Azure**: AD app registration with federated identity credential, subscription access.
- Kubernetes clusters accessible via `kubectl` with contexts named `staging` and `production`.
- Container registry (GHCR used by default).
- Repository secrets configured:
  - `AWS_ACCOUNT_ID`
  - `GCP_PROJECT`, `GCP_PROJECT_NUMBER`
  - `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`
  - `KUBECONFIG_STAGING`, `KUBECONFIG_PRODUCTION`
  - `CODECOV_TOKEN` (optional)

## Structure

```
production-ci-template/
├── ci.yml                           # Main CI workflow (matrix builds, lint, test, build, scan)
├── deploy.yml                       # Deploy workflow (environment approvals, OIDC, K8s deploy)
├── reusable-ci.yml                  # Reusable workflow for shared CI logic
└── .github/actions/
    ├── cache-dependencies/
    │   └── action.yml               # Composite action: multi-language dependency caching
    └── configure-environment/
        └── action.yml               # Composite action: cloud OIDC + kubectl setup
```

## Quick start

1. Copy this directory to your repository as `.github/workflows/`:

   ```bash
   cp -r production-ci-template/* .github/workflows/
   cp -r production-ci-template/.github/actions/ .github/actions/
   ```

2. Create GitHub environments `staging` and `production` with required reviewers.

3. Configure OIDC trust in each cloud provider (see [OIDC token exchange](../../docs/oidc-token-exchange.md)).

4. Add required repository secrets (see Prerequisites).

5. Update image names, Kubernetes contexts, and deployment manifests to match your application.

## Workflows

### CI (`ci.yml`)

Triggers: push to `main`/`develop`, pull requests to `main`, manual dispatch.

Jobs:

| Job | Description | Matrix |
|-----|-------------|--------|
| `lint-and-test` | Lint (ruff, mypy), test (pytest), coverage | 5 combinations: linux/macos/windows × python 3.11/3.12/3.13 |
| `build-and-push` | Multi-arch Docker build, push to GHCR, cache, SBOM | Single (ubuntu-latest) |
| `security-scan` | Trivy filesystem scan, CodeQL analysis | Single (ubuntu-latest) |

Key features:

- **Matrix builds**: 5 OS/python combinations with `fail-fast: false`.
- **Dependency caching**: pip cache via `actions/setup-python`, Docker layer cache via Buildx.
- **Security hardening**: least-privilege `permissions`, pinned action SHAs, `persist-credentials: false`.
- **Artifacts**: coverage XML, SARIF results uploaded to Codecov/GitHub Security.
- **Provenance & SBOM**: `docker/build-push-action` generates SLSA provenance and SPDX SBOM.

### Deploy (`deploy.yml`)

Triggers: manual dispatch (with environment/input selection), version tags (`v*`).

Jobs:

| Job | Environment | Approval | Description |
|-----|-------------|----------|-------------|
| `deploy-staging` | `staging` | None | Auto-deploys on tag push or manual staging dispatch |
| `deploy-production` | `production` | Required (2 approvals) | Manual only, gated behind `deploy-staging` |

Key features:

- **Environment approvals**: `production` environment requires 2 approvals from `platform-team`/`tech-leads`.
- **OIDC authentication**: AWS/GCP/Azure credentials exchanged via short-lived federated tokens.
- **Manual dispatch inputs**: target environment, image tag, emergency skip-approval flag.
- **Deployment records**: GitHub Deployment API creates tracked deployment statuses.
- **Smoke tests**: health endpoint verification post-deploy.

### Reusable CI (`reusable-ci.yml`)

Callable workflow for sharing CI logic across repositories. Accepts `language-version`, `os`, `cache-suffix` inputs and returns `test-result`, `coverage-file` outputs.

Example caller:

```yaml
jobs:
  test:
    uses: ./.github/workflows/reusable-ci.yml
    with:
      language-version: '3.12'
      os: 'ubuntu-latest'
      cache-suffix: 'myproject'
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
```

## Composite actions

### `cache-dependencies`

Restores and saves caches for pip, npm, and Docker layers in a single step.

```yaml
- uses: ./.github/actions/cache-dependencies
  with:
    python-version: '3.12'
    node-version: '20'
    cache-key-suffix: 'myapp'
```

Outputs: `cache-hit` (boolean).

### `configure-environment`

Sets up cloud credentials (AWS/GCP/Azure via OIDC) and kubectl context for a target environment.

```yaml
- uses: ./.github/actions/configure-environment
  with:
    environment: production
    aws-role-arn: arn:aws:iam::123456789012:role/github-actions-production
    gcp-workload-identity-provider: projects/123/locations/global/workloadIdentityPools/gha/providers/prod
    gcp-service-account: github-actions-prod@my-project.iam.gserviceaccount.com
    azure-client-id: ${{ secrets.AZURE_CLIENT_ID }}
    azure-tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    azure-subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    kubernetes-context: production
```

Outputs: `kubeconfig` (path).

## Security model

| Control | Implementation |
|---------|----------------|
| Least-privilege tokens | Job-level `permissions` blocks, `persist-credentials: false` on checkout |
| Keyless cloud auth | OIDC federation for AWS/GCP/Azure, no static access keys in secrets |
| Secret scanning | Enabled in repo settings, push protection on |
| Action pinning | All `uses:` pinned to 40-char commit SHAs with version comments |
| Supply chain | SBOM (SPDX), SLSA provenance, Trivy + CodeQL scanning |
| Injection prevention | Untrusted event data routed through `env:` not inline `${{ }}` |
| Privileged triggers | `pull_request_target` avoided; production gated by environment approval |

## Verify

1. **CI pass**: Push to a feature branch; confirm all 5 matrix jobs complete, coverage uploaded, SARIF visible in Security tab.
2. **Build artifacts**: Check `ghcr.io/<owner>/<repo>` for multi-arch images with `latest`, `sha-<short>`, and branch tags.
3. **Staging deploy**: Trigger `deploy.yml` manually with `environment: staging`; verify pods roll over and health endpoint returns 200.
4. **Production gate**: Trigger `deploy.yml` with `environment: production`; confirm approval issue created, requires 2 approvals.
5. **OIDC rejection**: Trigger production deploy from a fork PR; confirm cloud providers reject the federated token.
6. **Pin integrity**: `grep -r "uses:.*@" .github/workflows/` — every line should show a 40-char SHA.

## Common errors

| Symptom | Likely cause | Resolution |
|---------|--------------|------------|
| `403 Resource not accessible by integration` | Missing scope in job `permissions` | Add required scope (`contents: read`, `packages: write`, `id-token: write`, `deployments: write`, `security-events: write`) |
| `OIDC token request failed` | Trust policy condition mismatch | Verify `sub` claim format: `repo:<owner>/<repo>:ref:refs/heads/main` or `environment:<name>` |
| `Vault login failed` | JWT auth method constraints mismatch | Align `bound_issuer`, `bound_audiences`, `bound_subject` in Vault role |
| `azure/login: No matching federated identity` | Federated credential subject/audience mismatch | Recreate federated identity with correct `subject` (repo:org/repo:environment:prod) |
| `docker buildx cache miss` | Cache key mismatch across runs | Ensure `cache-from`/`cache-to` use `type=gha` consistently; check Buildx version |
| Matrix job timeout | Tests exceed 15 min | Increase `timeout-minutes` or split test suite |
| Approval never triggered | Environment not configured | Create `production` environment in repo settings, add required reviewers |

## Customization points

- **Matrix dimensions**: Edit `strategy.matrix` in `ci.yml` to add/remove OS/python versions.
- **Linter/test commands**: Replace `ruff`, `mypy`, `pytest` invocations in `reusable-ci.yml`.
- **Cloud providers**: Remove unused OIDC steps from `.github/actions/configure-environment/action.yml`.
- **Kubernetes deployment**: Replace `kubectl set image` with Helm/ArgoCD/Kustomize as needed.
- **Notifications**: Add Slack/Discord/PagerDuty webhooks in `deploy-production` success/failure steps.

## References

- [Reusing workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Creating a composite action](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)
- [GitHub Actions security hardening](../../docs/workflow-security-hardening.md)
- [OIDC token exchange with GitHub Actions](../../docs/oidc-token-exchange.md)
- [Docker GitHub Actions guide](https://docs.docker.com/guides/gha/)
- [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)