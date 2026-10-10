---
last_verified: 2026-10-10
tool_version: n/a
sources: []
---

# Declarative pipeline scaffold with shared library, credential binding, and multi-branch discovery

A project scaffold for a Jenkins declarative pipeline that demonstrates reusable shared library integration, credential binding patterns, and multi-branch pipeline discovery configuration. Drop this directory into a repository and configure it as a multi-branch pipeline in Jenkins.

## Directory structure

```
declarative-pipeline-scaffold/
├── Jenkinsfile                    # Main declarative pipeline
├── README.md                      # This file
├── jenkins-config.yaml            # Multi-branch pipeline configuration (Job DSL / Configuration as Code)
└── vars/
    ├── gitCheckout.groovy         # Git checkout with credential binding
    ├── dockerBuildPush.groovy     # Docker build and push with registry credentials
    ├── k8sDeploy.groovy           # Kubernetes deployment with kubeconfig credentials
    └── slackNotify.groovy         # Slack notification with webhook credential
```

## Purpose

Provides a production-ready declarative pipeline template that teams can copy and adapt. It shows how to:
- Reference a shared library for reusable pipeline steps
- Bind credentials securely using `withCredentials` and environment variables
- Configure multi-branch discovery via Job DSL or Configuration as Code
- Structure stages for CI (lint, test), build (Docker), and CD (Kubernetes deploy)

## When to use

- Starting a new project that needs a Jenkins pipeline
- Migrating from scripted to declarative pipelines
- Standardizing pipeline patterns across multiple repositories
- Learning credential binding and shared library integration patterns

## Prerequisites

- Jenkins 2.400+ with Pipeline, Git, and Credentials plugins
- A configured shared library (global or folder-level) named `pipeline-lib`
- Credentials stored in Jenkins:
  - `git-credentials-id` — username/password or SSH key for Git
  - `registry-credentials-id` — username/password for container registry
  - `kubeconfig-credentials-id` — kubeconfig file for Kubernetes
  - `slack-webhook-id` — secret text for Slack incoming webhook URL
- Kubernetes cluster accessible from Jenkins agents
- Container registry accessible from Jenkins agents

## Pipeline stages

| Stage | Purpose | Shared library step |
|-------|---------|---------------------|
| Checkout | Clone repository with credentials | `gitCheckout` |
| Lint & Test | Run linters and unit tests | (inline) |
| Build Image | Build and push Docker image | `dockerBuildPush` |
| Scan Image | Vulnerability scan (optional) | (inline) |
| Deploy Staging | Deploy to staging namespace | `k8sDeploy` |
| Integration Test | Run integration tests | (inline) |
| Deploy Production | Deploy to production namespace | `k8sDeploy` |
| Notify | Send Slack notification | `slackNotify` |

## Shared library steps

Each `vars/*.groovy` file defines a `call(...)` method invoked as a pipeline step.

### gitCheckout

```groovy
gitCheckout(
    repoUrl: 'https://github.com/org/repo.git',
    branch: 'main',
    credentialsId: 'git-credentials-id'
)
```

Returns the checked-out commit SHA.

### dockerBuildPush

```groovy
dockerBuildPush(
    image: 'myapp',
    tag: env.BUILD_NUMBER,
    registry: 'registry.example.com',
    credentialsId: 'registry-credentials-id',
    dockerfile: 'Dockerfile',
    buildArgs: ['VERSION': '1.0.0']
)
```

Returns the fully-qualified image reference.

### k8sDeploy

```groovy
k8sDeploy(
    imageRef: 'registry.example.com/myapp:123',
    namespace: 'staging',
    deployment: 'myapp',
    kubeconfigId: 'kubeconfig-credentials-id',
    timeout: '300s'
)
```

Patches the Deployment image and waits for rollout.

### slackNotify

```groovy
slackNotify(
    webhookId: 'slack-webhook-id',
    status: currentBuild.result ?: 'SUCCESS',
    message: "Build ${env.BUILD_NUMBER} ${currentBuild.result ?: 'SUCCESS'}"
)
```

Posts a formatted message to Slack.

## Multi-branch pipeline configuration

### Via Job DSL

```groovy
multibranchPipelineJob('myapp-pipeline') {
    branchSources {
        github {
            repoOwner('myorg')
            repository('myapp')
            credentialsId('github-scan-credentials')
            includes('*/main', '*/release/*', '*/feature/*')
            excludes('*/dependabot/*')
        }
    }
    orphanedItemStrategy {
        discardOldItems {
            numToKeep(10)
            daysToKeep(30)
        }
    }
    triggers {
        periodic(15) // scan every 15 minutes
    }
}
```

### Via Configuration as Code

```yaml
jobs:
  - script: >
      multibranchPipelineJob('myapp-pipeline') {
          branchSources {
              github {
                  repoOwner('myorg')
                  repository('myapp')
                  credentialsId('github-scan-credentials')
                  includes('*/main', '*/release/*', '*/feature/*')
                  excludes('*/dependabot/*')
              }
          }
          orphanedItemStrategy {
              discardOldItems {
                  numToKeep(10)
                  daysToKeep(30)
              }
          }
          triggers {
              periodic(15)
          }
      }
```

## Credential binding patterns

| Credential type | Binding syntax | Use case |
|-----------------|----------------|----------|
| Username/password | `usernamePassword(credentialsId, usernameVariable, passwordVariable)` | Git, Docker registry |
| SSH key | `sshUserPrivateKey(credentialsId, keyFileVariable, usernameVariable, passphraseVariable)` | Git over SSH |
| Secret text | `string(credentialsId, variable)` | API tokens, webhook URLs |
| Kubeconfig | `kubeconfig(credentialsId, variable)` | Kubernetes access |

Always bind credentials inside the narrowest scope (stage or `withCredentials` block) to minimize exposure.

## Verify

1. Create a new repository with this scaffold.
2. Add the required credentials to Jenkins.
3. Create a multi-branch pipeline job pointing to the repository (via Job DSL, CasC, or UI).
4. Trigger a build on the `main` branch.
5. Verify all stages complete: Checkout → Lint → Build → Scan → Deploy Staging → Test → Deploy Production → Notify.
6. Check Slack for the notification message.

## Common errors

| Symptom | Cause | Resolution |
|---------|-------|------------|
| `gitCheckout` fails with authentication error | Wrong credentials ID or insufficient permissions | Verify credentials ID exists and has repo access |
| `dockerBuildPush` fails on `docker login` | Registry credentials expired or wrong format | Regenerate registry credentials; ensure username/password type |
| `k8sDeploy` times out on rollout | Deployment stuck (image pull error, resource limits) | Check pod events: `kubectl describe pod -n <ns>` |
| Multi-branch job doesn't discover branches | GitHub credentials lack `repo` scope or webhook not configured | Use a PAT with `repo` and `admin:repo_hook` scopes |
| Shared library step not found | Library name mismatch or not loaded | Check `@Library('pipeline-lib') _` matches configured library name |

## References

- Jenkins Pipeline Syntax: `https://www.jenkins.io/doc/book/pipeline/syntax/`
- Shared Libraries: `https://www.jenkins.io/doc/book/pipeline/shared-libraries/`
- Credentials Binding: `https://plugins.jenkins.io/credentials-binding/`
- Job DSL Plugin: `https://plugins.jenkins.io/job-dsl/`
- Configuration as Code: `https://plugins.jenkins.io/configuration-as-code/`