---
last_verified: 2026-10-14
tool_version: n/a
sources: []
---

# Pipeline Template v2 — Advanced Multi-Environment CI/CD

An advanced CI/CD pipeline with multi-environment deployment, deployment strategies, approval gates, and parallel testing.

## Features

- **Multi-environment**: Staging → Production with environment-specific config
- **Deployment strategies**: Rolling, Blue-Green, Canary (configurable per deploy)
- **Approval gates**: Manual approval required for production
- **Parallel testing**: Unit and integration tests run in parallel
- **Environment config**: External config files per environment
- **Health checks**: Automated post-deploy verification
- **Artifact archiving**: Security scan reports archived

## Stages

| Stage | Environment | Strategy | Approval |
|-------|-------------|----------|----------|
| Checkout & Lint | All | - | No |
| Build & Push | All | - | No |
| Security Scan | All | - | No |
| Unit Tests | All | - | No |
| Integration Tests | All | - | No |
| Deploy Staging | Staging | Rolling | No |
| Staging Smoke Tests | Staging | - | No |
| Deploy Production | Production | Configurable | **Yes** |
| Production Health Check | Production | - | No |

## Required Credentials

| Credential ID | Type | Description |
|---------------|------|-------------|
| `github-credentials-id` | Username/Password or SSH | Git repository access |
| `registry-credentials-id` | Username/Password | Container registry access |
| `kubeconfig-credentials-id` | Kubeconfig | Kubernetes cluster access |
| `slack-webhook-id` | Secret text | Slack incoming webhook URL |

## Environment Configuration

Create config files in your repository:

**config/staging.groovy**
```groovy
return [
    namespace: 'staging',
    deployment: 'myapp-staging',
    strategy: 'rolling',
    timeout: '300s'
]
```

**config/production.groovy**
```groovy
return [
    namespace: 'production',
    deployment: 'myapp',
    strategy: 'blue-green',  // rolling, blue-green, or canary
    timeout: '600s',
    canaryWeight: 10  // for canary strategy
]
```

## Deployment Strategies

### Rolling (default)
Standard Kubernetes rolling update. Zero-downtime if properly configured.

### Blue-Green
Deploys to a parallel "green" deployment, then switches service selector.
Requires: `myapp-green` deployment and service with version labels.

### Canary
Deploys to a canary deployment, routes percentage of traffic, then promotes.
Requires: `myapp-canary` deployment and service with version labels.
Configure `canaryWeight` (1-100) for traffic percentage.

## When to Use

- Production applications requiring safe deployment practices
- Teams needing manual approval for production
- Applications supporting multiple deployment strategies
- Projects with separate staging/production clusters or namespaces

## Migration from v1

1. Add `config/staging.groovy` and `config/production.groovy`
2. Update Jenkinsfile to v2 template
3. Configure production approval submitters
4. Set up blue-green/canary deployments if desired