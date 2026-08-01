---
last_verified: 2026-08-01
tool_version: n/a
sources: []
---

# Combining IaC with Version Control: state file management strategies

## Purpose
Infrastructure as Code tools maintain a state file that records the real-world resources they have created. When that state file interacts with version control, teams need strategies that keep the config as the source of truth while avoiding merge conflicts, secret leaks, and concurrent corruption. This document outlines the common patterns for managing state files alongside version-controlled infrastructure config.

## When to use
Apply these strategies whenever multiple people or automation pipelines apply changes to the same IaC-managed environment. They are relevant for shared environments like staging or production where concurrent runs can corrupt state, and for any team that wants the version control history to reflect actual infrastructure changes.

## Prerequisites
- An IaC tool that persists state.
- A version control repository containing the infrastructure configuration.
- A remote backend or a conflict-resolution process for state files.

## Steps

### 1. Decide where state lives
The simplest setup stores the state file in the same repository as the config. This works for solo developers or short-lived environments. For teams, a remote backend (typically an object store with a locking mechanism) serialises apply runs and prevents two operators from writing state at the same time.

### 2. Control what enters version control
If state files are stored locally, add them to `.gitignore` to prevent merge conflicts and avoid accidentally committing secrets that some tools embed in state. Version-control the config, variable definitions, and backend access policy instead. If a remote backend is used, version-control the backend configuration and access policy, not the state data itself.

### 3. Isolate state per environment
Each environment should have its own state file or backend workspace. Naming conventions such as `project-dev.tfstate`, `project-staging.tfstate`, and `project-prod.tfstate` make the separation explicit. Some tools offer built-in workspace support that achieves the same isolation without separate files.

### 4. Detect drift from the version-controlled config
Run the IaC tool's plan or preview command in CI on every pull request. When the plan shows differences between the proposed config and the recorded state, reviewers can catch unintended changes before they reach production. Some teams supplement this with a nightly drift job that alerts when real infrastructure has diverged from the version-controlled config.

### 5. Refresh local state understanding
Provide a script or Make target that reads the current state from the backend and displays what changed since the last apply. This lets developers correlate version control history with live infrastructure without manually downloading or parsing state files.

## Verify
After implementing the strategy, confirm that a new team member can clone the repository, run the refresh command, and see a plan that matches the team's expectations. Also verify that two concurrent apply runs to the same environment are serialised by the locking mechanism and do not produce a corrupted state file.
