---
last_verified: 2026-10-14
tool_version: n/a
sources: []
---

# Pipeline Template v1 — Basic CI/CD

A minimal CI/CD pipeline using the Jenkins shared library scaffold. This template covers the essential stages for a simple application deployment.

## Stages

| Stage | Purpose | Shared Library Step |
|-------|---------|---------------------|
| Checkout & Lint | Clone repo and run linter | `checkoutAndLint` |
| Build & Push | Build Docker image and push to registry | `buildAndPushDocker` |
| Security Scan | Scan image for vulnerabilities | `scanImage` |
| Run Tests | Execute unit tests in container | `runTests` |
| Deploy | Deploy to Kubernetes | `deployToK8s` |

## Required Credentials

| Credential ID | Type | Description |
|---------------|------|-------------|
| `github-credentials-id` | Username/Password or SSH | Git repository access |
| `registry-credentials-id` | Username/Password | Container registry access |
| `kubeconfig-credentials-id` | Kubeconfig | Kubernetes cluster access |
| `slack-webhook-id` | Secret text | Slack incoming webhook URL |

## Configuration

Edit the `environment` block to match your setup:

```groovy
environment {
    REGISTRY = 'your-registry.io'
    IMAGE_NAME = 'your-app'
    NAMESPACE = 'your-namespace'
    DEPLOYMENT = 'your-deployment'
}
```

## When to Use

- Simple applications with single-environment deployment
- Teams new to Jenkins shared libraries
- Projects that don't need complex deployment strategies

## Next Steps

For multi-environment deployments, staging/production separation, or advanced deployment strategies (blue-green, canary), see [v2 template](../v2/README.md).