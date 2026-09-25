---
last_verified: 2026-09-25
tool_version: n/a
sources: []
---

# Integrating GitHub Actions with external services: OIDC, Vault, and cloud provider token exchange

> Reference patterns for authenticating GitHub Actions workflows against external systems without storing long-lived secrets.

## Purpose

This document describes how to configure GitHub Actions workflows to authenticate with external services using OpenID Connect (OIDC) token exchange, HashiCorp Vault, and major cloud provider identity federation. The goal is to eliminate long-lived credentials from workflows and instead use short-lived, workload-specific tokens that are bound to the workflow run's identity.

## When to use

Use these patterns when:

- Workflows need to access cloud resources (AWS, GCP, Azure) and you want to avoid storing static access keys in repository secrets.
- Secrets must be retrieved from HashiCorp Vault at runtime rather than embedded in the workflow.
- Compliance requirements mandate short-lived, auditable credentials with workload identity binding.
- You need to assume roles or exchange tokens across multiple cloud accounts or projects within a single workflow.

## Prerequisites

- A GitHub repository with Actions enabled.
- Administrative access to configure OIDC trust relationships in the target external service (cloud provider or Vault).
- The `id-token: write` permission granted at the workflow or job level to request OIDC tokens from GitHub's OIDC provider.
- Familiarity with the target service's IAM or authentication configuration (IAM roles, service accounts, Vault roles).

## Steps

### 1. Enable OIDC token issuance in the workflow

Add the required permission to allow the workflow to request an OIDC token from GitHub's provider. This token encodes the workflow's identity (repository, ref, environment, actor) and is used by the external service to verify the caller.

```yaml
permissions:
  id-token: write
  contents: read
```

Place this at the workflow level (applies to all jobs) or at the job level for finer control.

### 2. Request an OIDC token for a specific audience

Use the `actions/id-token-request` action or the `ACTIONS_ID_TOKEN_REQUEST_URL` and `ACTIONS_ID_TOKEN_REQUEST_TOKEN` environment variables to request a token. The `audience` parameter must match what the external service expects.

```yaml
- name: Request OIDC token for AWS
  id: oidc
  uses: actions/id-token-request@v2
  with:
    audience: sts.amazonaws.com
```

The token is available in `steps.oidc.outputs.id_token`.

### 3. Exchange the OIDC token for cloud credentials (AWS)

Configure an IAM role with a trust policy that allows the GitHub OIDC provider to assume the role, conditioned on the token's claims (repository, ref, environment). Then use `aws-actions/configure-aws-credentials` to perform the exchange.

Trust policy example (principal is GitHub's OIDC provider, condition matches repository and optional ref):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:sub": "repo:myorg/myrepo:ref:refs/heads/main"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
```

Workflow step:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/github-actions-deploy
    role-session-name: GitHubActions-${{ github.run_id }}
    aws-region: us-east-1
```

### 4. Exchange the OIDC token for cloud credentials (GCP)

Create a Workload Identity Pool and Provider in GCP that trusts GitHub's OIDC provider. Grant the pool access to a service account. Then use `google-github-actions/auth` to exchange the token.

```yaml
- name: Authenticate to GCP
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: projects/123456789/locations/global/workloadIdentityPools/my-pool/providers/my-provider
    service_account: github-actions@my-project.iam.gserviceaccount.com
    token_format: access_token
```

### 5. Exchange the OIDC token for cloud credentials (Azure)

Create an Azure AD app registration with a federated identity credential that trusts GitHub's OIDC issuer and the repository/subject claims. Then use `azure/login` to exchange the token.

```yaml
- name: Log in to Azure
  uses: azure/login@v2
  with:
    client-id: <app-client-id>
    tenant-id: <tenant-id>
    subscription-id: <subscription-id>
    allow-no-subscriptions: true
```

### 6. Retrieve secrets from HashiCorp Vault using OIDC

Configure a Vault JWT/OIDC auth method pointing to GitHub's OIDC issuer (`https://token.actions.githubusercontent.com`). Create a Vault role bound to the repository and optional ref/environment claims. Then use the Vault CLI or `hashicorp/vault-action` to authenticate and read secrets.

Vault auth method configuration (via CLI):

```bash
vault auth enable jwt
vault write auth/jwt/config \
  oidc_discovery_url="https://token.actions.githubusercontent.com" \
  bound_issuer="https://token.actions.githubusercontent.com"
vault write auth/jwt/role/github-actions \
  bound_audiences="sts.amazonaws.com" \
  bound_subject="repo:myorg/myrepo:ref:refs/heads/main" \
  policies="myapp-secrets" \
  ttl="1h"
```

Workflow step using the Vault action:

```yaml
- name: Read secrets from Vault
  uses: hashicorp/vault-action@v2
  with:
    url: https://vault.example.com
    method: jwt
    role: github-actions
    token: ${{ steps.oidc.outputs.id_token }}
    secrets: secret/data/myapp/config
  env:
    VAULT_NAMESPACE: mynamespace
```

### 7. Chain token exchanges for multi-cloud or multi-account scenarios

A single workflow can exchange the GitHub OIDC token for credentials in multiple systems sequentially. Request the token once with a broad audience (or multiple audiences via separate requests), then pass it to each provider's authentication action.

```yaml
- name: Request OIDC token
  id: oidc
  uses: actions/id-token-request@v2
  with:
    audience: api://AzureADTokenExchange

- name: Login to Azure
  uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

- name: Request second token for AWS
  id: oidc-aws
  uses: actions/id-token-request@v2
  with:
    audience: sts.amazonaws.com

- name: Configure AWS
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: us-east-1
```

## Verify

1. Trigger a workflow run (push to the configured branch or tag).
2. Confirm the job requesting the OIDC token completes without permission errors.
3. Verify each cloud authentication step succeeds and subsequent CLI commands (aws, gcloud, az, vault) operate with the exchanged credentials.
4. In the external service's audit logs, verify the assumed role or service account matches the expected identity and that the session name includes the GitHub run ID for traceability.
5. Attempt a workflow run from an untrusted ref (e.g., a fork or unconfigured branch) and confirm the external service rejects the token due to claim mismatch.

## Common errors

| Symptom | Likely cause | Resolution |
|---------|--------------|------------|
| `Error: Not authorized to perform sts:AssumeRoleWithWebIdentity` | Trust policy condition does not match token claims (sub, aud, repository). | Update the trust policy `StringEquals`/`StringLike` conditions to match the exact `sub` and `aud` values emitted by GitHub for the workflow. |
| `OIDC token request failed: audience not allowed` | The requested audience is not in the token's `aud` claim or the external provider rejects it. | Ensure the `audience` parameter in `actions/id-token-request` matches what the target provider expects (e.g., `sts.amazonaws.com` for AWS, the Workload Identity Provider resource name for GCP). |
| `Vault login failed: token validation failed` | Vault's JWT auth method issuer/audience/subject constraints don't match the token. | Verify `bound_issuer`, `bound_audiences`, and `bound_subject` in the Vault role match the token's claims. Use `vault write auth/jwt/login role=... jwt=$TOKEN` manually to debug. |
| `azure/login: AADSTS70021: No matching federated identity` | Federated identity credential on the Azure AD app doesn't match the token's `sub` or `aud`. | Recreate the federated identity credential with the correct subject (`repo:org/repo:ref:refs/heads/main`) and audience (`api://AzureADTokenExchange`). |
| `google-github-actions/auth: Could not generate credentials` | Workload Identity Pool provider not configured to accept the token's subject/issuer. | In GCP console, verify the provider's attribute mapping and condition allow the repository and ref from the GitHub token. |

## References

- GitHub Actions OIDC documentation: configuring the `id-token` permission and requesting tokens
- AWS IAM OIDC federation: creating roles with GitHub Actions trust policies
- Google Cloud Workload Identity Federation: GitHub Actions provider setup
- Azure AD workload identity federation: federated identity credentials for GitHub Actions
- HashiCorp Vault JWT/OIDC auth method: configuration and role binding