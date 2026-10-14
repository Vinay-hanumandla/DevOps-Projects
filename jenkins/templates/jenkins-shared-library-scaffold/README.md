---
last_verified: 2026-10-14
tool_version: n/a
sources: []
---

# Jenkins Shared Library Scaffold with Docker Test Harness & Versioned Pipeline Templates

A comprehensive project scaffold for a Jenkins shared library that provides reusable pipeline steps, a Docker-based test harness for unit testing, and versioned pipeline templates for different maturity levels.

## Directory Structure

```
jenkins-shared-library-scaffold/
├── README.md                      # This file
├── Jenkinsfile                    # Example pipeline using the library
├── vars/                          # Shared library steps (callable from pipelines)
│   ├── checkoutAndLint.groovy     # Git checkout + lint
│   ├── buildAndPushDocker.groovy  # Docker build + push with caching
│   ├── deployToK8s.groovy         # Kubernetes deploy (rolling/blue-green/canary)
│   ├── scanImage.groovy           # Trivy security scanning
│   ├── runTests.groovy            # Container-based test execution
│   └── slackNotify.groovy         # Slack notifications
├── src/                           # Helper classes (Groovy packages)
│   └── com/example/jenkinslib/
│       └── Utils.groovy           # Docker, K8s, Git utilities
├── tests/                         # Jenkins Pipeline Unit tests
│   ├── runAllTests.groovy         # Test runner
│   ├── checkoutAndLintTest.groovy
│   ├── buildAndPushDockerTest.groovy
│   ├── deployToK8sTest.groovy
│   ├── scanImageTest.groovy
│   ├── runTestsTest.groovy
│   └── slackNotifyTest.groovy
├── docker-test-harness/           # Docker-based test environment
│   ├── Dockerfile                 # Test container with Pipeline Unit
│   ├── docker-compose.yml         # Compose for local testing
│   └── run-tests.sh               # Test runner script
└── pipeline-templates/            # Versioned pipeline templates
    ├── v1/                        # Basic CI/CD pipeline
    │   ├── Jenkinsfile
    │   └── README.md
    └── v2/                        # Advanced multi-environment pipeline
        ├── Jenkinsfile
        ├── README.md
        └── config/
            ├── staging.groovy
            └── production.groovy
```

## Quick Start

### 1. Use as a Shared Library

Commit this directory as a standalone repository (e.g., `jenkins-shared-library-scaffold`).

In Jenkins, add it as a Global Pipeline Library:
- **Manage Jenkins → Configure System → Global Pipeline Libraries**
- Name: `jenkins-shared-library-scaffold`
- Source: Your Git repository URL
- Credentials: As needed

Reference in your pipeline:
```groovy
@Library('jenkins-shared-library-scaffold') _

pipeline {
    agent any
    stages {
        stage('Example') {
            steps {
                script {
                    checkoutAndLint([
                        repoUrl: 'https://github.com/your/repo.git',
                        branch: 'main',
                        credentialsId: 'github-creds'
                    ])
                }
            }
        }
    }
}
```

### 2. Run Tests Locally

```bash
# Using Docker (recommended)
cd docker-test-harness
./run-tests.sh

# Or with docker-compose
docker-compose up --build --abort-on-container-exit test-harness
```

### 3. Choose a Pipeline Template

Copy a template to your application repository:

```bash
# Basic pipeline (v1)
cp pipeline-templates/v1/Jenkinsfile /path/to/your/repo/Jenkinsfile

# Advanced pipeline (v2)
cp -r pipeline-templates/v2/* /path/to/your/repo/
```

## Shared Library Steps Reference

### checkoutAndLint
```groovy
checkoutAndLint([
    repoUrl: 'https://github.com/org/repo.git',
    branch: 'main',
    credentialsId: 'github-credentials-id',
    lintCommand: 'npm ci && npm run lint'  // optional
])
```
Returns: checked-out commit SHA

### buildAndPushDocker
```groovy
buildAndPushDocker([
    image: 'myapp',
    tag: 'v1.0.0-123',
    registry: 'registry.example.com',
    credentialsId: 'registry-credentials-id',
    dockerfile: 'Dockerfile',           // optional
    buildArgs: [VERSION: '1.0.0'],      // optional
    context: '.',                        // optional
    target: 'production',                // optional (multi-stage)
    platform: 'linux/amd64',             // optional
    cacheFrom: 'registry.example.com/myapp:latest',  // optional
    cacheTo: 'type=inline'               // optional
])
```
Returns: fully-qualified image reference

### deployToK8s
```groovy
deployToK8s([
    imageRef: 'registry.example.com/myapp:v1.0.0-123',
    namespace: 'production',
    deployment: 'myapp',
    kubeconfigId: 'kubeconfig-credentials-id',
    timeout: '300s',                     // optional
    container: 'app',                    // optional
    strategy: 'rolling'                  // optional: rolling, blue-green, canary
    // For canary:
    canaryWeight: 10                     // optional (1-100)
])
```

### scanImage
```groovy
scanImage([
    imageRef: 'registry.example.com/myapp:v1.0.0-123',
    severity: 'HIGH,CRITICAL',           // optional
    format: 'table',                     // optional: table, json, sarif
    output: 'trivy-report.json',         // optional
    ignoreUnfixed: false,                // optional
    exitCode: 1                          // optional
])
```

### runTests
```groovy
runTests([
    imageRef: 'registry.example.com/myapp:v1.0.0-123',
    testCommand: 'npm test',             // optional
    coverageCommand: 'npm run coverage', // optional
    envVars: [NODE_ENV: 'test'],         // optional
    volumes: ['/host/path:/container'],  // optional
    workingDir: '/app'                   // optional
])
```

### slackNotify
```groovy
slackNotify([
    webhookId: 'slack-webhook-id',
    status: 'SUCCESS',                   // optional: SUCCESS, FAILURE, UNSTABLE
    message: 'Build 123 deployed!',      // optional
    channel: '#deployments',             // optional
    username: 'Jenkins',                 // optional
    iconEmoji: ':jenkins:'               // optional
])
```

## Pipeline Templates

### v1 — Basic CI/CD
- Single-environment deployment
- Sequential stages
- Minimal configuration
- Best for: Simple apps, learning, small teams

[View v1 template](./pipeline-templates/v1/README.md)

### v2 — Advanced Multi-Environment
- Staging → Production workflow
- Multiple deployment strategies (rolling, blue-green, canary)
- Manual approval gate for production
- Parallel unit/integration testing
- Environment-specific config files
- Health checks and rollback support
- Best for: Production apps, larger teams, compliance requirements

[View v2 template](./pipeline-templates/v2/README.md)

## Docker Test Harness

The `docker-test-harness/` directory provides a self-contained test environment using [Jenkins Pipeline Unit](https://github.com/jenkinsci/JenkinsPipelineUnit).

### Components

| File | Purpose |
|------|---------|
| `Dockerfile` | Test container with Groovy + Pipeline Unit |
| `docker-compose.yml` | Compose file for easy local runs |
| `run-tests.sh` | Runner script (Docker, Compose, or local) |

### Running Tests

```bash
# Quick start with Docker
cd docker-test-harness
./run-tests.sh

# With docker-compose (shows logs)
docker-compose up --build --abort-on-container-exit test-harness

# Local (requires groovy installed)
./run-tests.sh --local
```

### Writing Tests

Tests use the Jenkins Pipeline Unit framework. Each test file:
1. Creates a `JenkinsPipelineUnit` instance
2. Mocks pipeline steps (`sh`, `checkout`, `withCredentials`, etc.)
3. Loads the step under test with `suite.loadStep('vars/StepName.groovy')`
4. Calls the step and asserts results

See `tests/*.groovy` for examples.

## Requirements

### Jenkins
- Jenkins 2.400+
- Pipeline plugin
- Credentials Binding plugin
- Kubernetes CLI plugin (for `withKubeCredentials`)
- Docker Pipeline plugin (optional, for agent docker)

### Runtime (for pipelines)
- Docker (for build/test steps)
- kubectl (for deploy step)
- trivy (for scan step)
- curl (for slack notify)

### Testing
- Docker (for test harness)
- OR: Groovy 3+ + Jenkins Pipeline Unit 2.8+

## Customization

### Adding New Steps
1. Create `vars/YourStep.groovy` with a `call(Map config)` method
2. Add tests in `tests/YourStepTest.groovy`
3. Run tests to verify

### Extending Helper Classes
Add methods to `src/com/example/jenkinslib/Utils.groovy` or create new classes in `src/`.

### Custom Pipeline Templates
Create new directories under `pipeline-templates/vN/` following the v1/v2 pattern.

## License

This scaffold is provided as-is for educational and practical use. Adapt freely for your projects.