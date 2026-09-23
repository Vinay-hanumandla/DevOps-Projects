---
last_verified: 2026-09-23
tool_version: n/a
sources: []
---

# Jenkins shared library scaffold

A project scaffold for a Jenkins shared library that wires three integration surfaces
together: Git (checkout), Docker (build and push), and Kubernetes (deploy). Drop this
directory into a standalone repository, commit it, and reference it from any pipeline
with `@Library('jenkins-shared-library') _`.

## Directory structure

```
jenkins-shared-library/
├── Jenkinsfile            # example pipeline that calls the library
├── README.md              # this file
└── vars/
    ├── checkoutAndLint.groovy   # Git checkout + lint
    ├── buildAndPushDocker.groovy  # Docker build + push
    └── deployToK8s.groovy        # Kubernetes rollout
```

Shared libraries resolve `vars/*.groovy` files as callable steps. Each file defines a
`call(...)` method that pipelines invoke as a bare step. No `src/` package is required
for this scaffold; add one when the library needs helper classes.

## Using the library

1. Commit the directory as a repository (e.g. `jenkins-shared-library`).
2. In Jenkins, add the repository as a Global Pipeline Library under
   Manage Jenkins → Configure System → Global Pipeline Libraries, or reference it
   per-branch with a `@Library` annotation.
3. The example `Jenkinsfile` shows the three integration stages in order.

## Variable reference

- `checkoutAndLint(repoUrl, branch, credentialsId)` — checks out a Git branch and
  runs a lint step. Returns the checked-out revision.
- `buildAndPushDocker(image, tag, registry)` — builds an image, tags it, and pushes it
  to a registry. Returns the fully-qualified image reference.
- `deployToK8s(imageRef, namespace, deployment)` — patches a Kubernetes Deployment
  image and waits for the rollout to complete.

## Notes

- The `vars/` steps are written in Groovy CPS (Closures Pipeline Syntax) so they can be
  called from any declarative or scripted pipeline.
- Secrets (registry credentials, K8s kubeconfig) are injected through Jenkins
  credentials and `withCredentials`; they do not appear in this scaffold.