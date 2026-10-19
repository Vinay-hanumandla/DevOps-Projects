---
last_verified: 2026-10-19
tool_version: n/a
sources: []
---

# Jenkins Shared Library Scaffold (reusable steps + custom DSL)

## Purpose

A minimal, testable scaffold for a Jenkins shared library that exposes reusable steps via `vars/` and shared classes via `src/`, with an example pipeline template and a simple test harness layout.

## When to use

Use this when you want to standardize pipeline logic (notifications, linting, builds, deploys) and keep pipelines declarative/simple by calling custom steps.

## Layout

- `vars/` - Global variables/steps callable from Jenkinsfiles (e.g., `sendSlackNotification`)
- `src/` - Groovy classes for reusable logic (e.g., `com.example.jenkinslib.Utils`)
- `tests/` - Pipeline Unit (or compatible) test scaffolds
- `pipeline-templates/` - Example Jenkinsfiles showing how to consume the library
- `Jenkinsfile` - Example library test/validation pipeline

## Usage

1. Load the library in Jenkins (Global Shared Libraries) or via `@Library` in a Jenkinsfile.
2. Call a step: `sendSlackNotification channel: '#ci', message: 'Build ok'`
3. Extend `vars/` and `src/` with your own reusable steps and DSL helpers.

## Prerequisites

- Jenkins with Pipeline Shared Libraries configured
- Access to a test Jenkins instance or Jenkins Pipeline Unit for local tests
