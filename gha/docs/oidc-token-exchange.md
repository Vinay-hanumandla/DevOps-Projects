---
last_verified: 2026-09-25
tool_version: n/a
---

# OIDC token exchange with GitHub Actions

> Reference patterns for authenticating GitHub Actions workflows against external systems using short-lived tokens.

## Purpose

This document describes how to configure GitHub Actions workflows to authenticate with external services using OpenID Connect (OIDC) token exchange, HashiCorp Vault, and major cloud provider identity federation.

## When to use

Use these patterns when workflows need to access cloud resources (AWS, GCP, Azure) without storing static access keys, or when secrets must be retrieved from HashiCorp Vault at runtime.

## Prerequisites

- A GitHub repository with Actions enabled.
- Administrative access to configure OIDC trust relationships in the target external service.
- The `id-token: write` permission granted at the workflow or job level.

## Steps

### 1. Enable OIDC token issuance

Add the required permission to allow the workflow to request an OIDC token from GitHub's provider.

```yaml
permissions:
  id-token: write
  contents: read
```

### 2. Request an OIDC token

GitHub exposes two environment variables for requesting an OIDC token: `ACTIONS_ID_TOKEN_REQUEST_URL` and `ACTIONS_ID_TOKEN_REQUEST_TOKEN`. Request the token by calling the URL with the token, then decode the JWT to inspect its claims.

```yaml
- name: Request OIDC token
  id: oidc
  run: |
    TOKEN=$(curl -s "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=api://GitHubActions" \
      -H "Authorization: bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" \
      | jq -r .value)
    echo "id_token=$TOKEN" >> "$GITHUB_OUTPUT"
```

The token is available in `steps.oidc.outputs.id_token`.

### 3. Exchange the OIDC token for AWS credentials

Configure an IAM role with a trust policy that allows the GitHub OIDC provider to assume the role, conditioned on the token's claims. Then use `aws-actions/configure-aws-credentials` to perform the exchange.

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/github-actions-deploy
    role-session-name: GitHubActions-${{ github.run_id }}
    aws-region: us-east-1
```

### 4. Exchange the OIDC token for GCP credentials

Create a Workload Identity Pool and Provider in GCP that trusts GitHub's OIDC provider. Grant the pool access to a service account. Then use `google-github-actions/auth` to exchange the token.

```yaml
- name: Authenticate to GCP
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: projects/123456789/locations/global/workloadIdentityPools/my-pool/providers/my-provider
    service_account: github-actions@my-project.iam.gserviceaccount.com
    token_format: access_token
```

### 5. Exchange the OIDC token for Azure credentials

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

Configure a Vault JWT/OIDC auth method pointing to GitHub's OIDC issuer. Create a Vault role bound to the repository and optional ref/environment claims. Then use the Vault CLI or `hashicorp/vault-action` to authenticate and read secrets.

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

### 7. Chain token exchanges for multi-cloud scenarios

A single workflow can exchange the GitHub OIDC token for credentials in multiple systems sequentially. Request the token once, then pass it to each provider's authentication action.

```yaml
- name: Request OIDC token
  id: oidc
  run: |
    TOKEN=$(curl -s "${ACTIONS_ID_TOKEN_REQUEST_URL}&audience=api://GitHubActions" \
      -H "Authorization: bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" \
      | jq -r .value)
    echo "id_token=$TOKEN" >> "$GITHUB_OUTPUT"

- name: Login to Azure
  uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## Verify

1. Trigger a workflow run (push to the configured branch or tag).
2. Confirm the job requesting the OIDC token completes without permission errors.
3. Verify each cloud authentication step succeeds and subsequent CLI commands operate with the exchanged credentials.
4. In the external service's audit logs, verify the assumed role or service account matches the expected identity.
5. Attempt a workflow run from an untrusted ref and confirm the external service rejects the token due to claim mismatch.

## Common errors

| Symptom | Likely cause | Resolution |
|---------|--------------|------------|
| `Error: Not authorized to perform sts:AssumeRoleWithWebIdentity` | Trust policy condition does not match token claims. | Update the trust policy conditions to match the exact `sub` and `aud` values emitted by GitHub for the workflow. |
| `OIDC token request failed: audience not allowed` | The requested audience is not in the token's `aud` claim. | Ensure the `audience` parameter matches what the target provider expects. |
| `Vault login failed: token validation failed` | Vault's JWT auth method constraints don't match the token. | Verify `bound_issuer`, `bound_audiences`, and `bound_subject` in the Vault role. |
| `azure/login: AADSTS70021: No matching federated identity` | Federated identity credential on the Azure AD app doesn't match the token's `sub` or `aud`. | Recreate the federated identity credential with the correct subject and audience. |

## References

- GitHub Actions OIDC documentation: configuring the `id-token` permission and requesting tokens
- AWS IAM OIDC federation: creating roles with GitHub Actions trust policies
- Google Cloud Workload Identity Federation: GitHub Actions provider setup
- Azure AD workload identity federation: federated identity credentials for GitHub Actions
- HashiCorp Vault JWT/OIDC auth method: configuration and role binding