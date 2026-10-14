---
last_verified: 2026-10-14
tool_version: n/a
sources: []
---

# Terraform GitHub Actions Plan/Apply Pipeline with Remote Backend and Environment Approvals

## Purpose

Configure a GitHub Actions workflow to automate Terraform plan and apply operations using a remote backend (such as Terraform Cloud or an S3 bucket) with mandatory environment approvals for production deployments.

## Steps

### 1. Configure Remote Backend

In your Terraform configuration, set up a remote backend to store state securely. For example, using Terraform Cloud:

```hcl
terraform {
  backend "remote" {
    organization = "your-organization"
    workspaces {
      name = "your-workspace"
    }
  }
}
```

Alternatively, for an S3 backend:

```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "path/to/your/key.tfstate"
    region = "us-east-1"
  }
}
```

### 2. Set Up GitHub Secrets

Store sensitive values as GitHub Secrets:
- AWS credentials (if using S3 backend) or Terraform Cloud token
- Any variable values needed by your Terraform configuration

### 3. Create the Workflow File

Create `.github/workflows/terraform.yml` with the following content:

```yaml
name: Terraform

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  terraform:
    runs-on: ubuntu-latest
    environment: production  # Reference to the environment requiring approval
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        id: plan
        run: terraform plan -out=tfplan
        env:
          TF_VAR_access_key: ${{ secrets.AWS_ACCESS_KEY_ID }}
          TF_VAR_secret_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Terraform Apply
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve tfplan
        env:
          TF_VAR_access_key: ${{ secrets.AWS_ACCESS_KEY_ID }}
          TF_VAR_secret_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### 4. Configure Environment Protection Rules

In your GitHub repository settings, create an environment named "production" and configure required reviewers or approval checks.

## Verify

1. Push a change to the main branch.
2. Observe that the workflow triggers and pauses for approval before the apply step.
3. After approval, verify that the Terraform apply runs successfully and updates the remote backend state.
4. Check the Terraform Cloud console or S3 bucket to confirm the state file is updated.