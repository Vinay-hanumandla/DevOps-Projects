---
last_verified: 2026-10-19
tool_version: n/a
sources:
  - https://docs.github.com/en/actions/using-workflows/reusing-workflows
  - https://docs.github.com/en/actions/creating-actions/creating-a-composite-action
  - https://docs.github.com/en/actions/creating-actions/creating-a-javascript-action
---

# Choosing between reusable workflows, composite actions, and custom JavaScript actions

> Decision framework for the three composition mechanisms GitHub Actions provides. Each solves a different reuse problem — this guide maps requirements to the right choice.

## Purpose

GitHub Actions offers three ways to share logic across workflows: reusable workflows (called via `workflow_call`), composite actions (step bundles invoked with `uses:` inside a job), and custom JavaScript actions (Node.js programs that run as a single step). They overlap in capability but differ in isolation, input/output model, distribution, and operational complexity. This reference gives a decision checklist and a side-by-side comparison so you can pick the right one for a given sharing scenario.

## When to use

Use this guide when:

- You have CI logic duplicated across two or more workflow files and want to extract it.
- You are designing a shared component that other repositories or teams will consume.
- You need to decide whether a piece of logic belongs in a workflow, an action, or a custom program.

Do not use this guide for:
- One-off workflows that will never be shared (no extraction needed).
- Decisions about third-party actions from the Marketplace (those are consumption, not authoring).

## Prerequisites

- A GitHub repository where you can create `.github/workflows/` and `.github/actions/` directories.
- For JavaScript actions: Node.js 20+ installed locally for development and `npm` available to initialize a package (the published action runs on the runner's built-in Node, no `node_modules` required if you use only stdlib).
- Write access to the repository to push workflow and action files.

## Quick decision checklist

| Requirement | Reusable workflow | Composite action | JavaScript action |
|---|---|---|---|
| Share an entire job (with `runs-on`, `steps`, `outputs`) | **Yes** | No | No |
| Share a step sequence that runs inside a caller's job | No | **Yes** | No |
| Need complex logic: loops, conditionals, API calls, parsing | Awkward (shell only) | Awkward (shell only) | **Yes** |
| Inputs/outputs typed and validated declaratively | **Yes** (workflow_call) | **Yes** (action.yml) | Manual (stdin/env) |
| Distribute across repositories without copying files | **Yes** (call by ref) | **Yes** (call by ref) | **Yes** (publish to Marketplace or reference by repo/path) |
| Run on self-hosted runners with custom tooling | **Yes** | **Yes** (uses caller's runner) | **Yes** (runs on caller's runner) |
| Need to execute shell commands directly | Via `run:` steps | Via `run:` steps | Via `child_process` (extra work) |
| Version independently from caller workflows | **Yes** (tags/branches/SHA) | **Yes** (tags/branches/SHA) | **Yes** (npm version or git tags) |
| Secret handling | Passed explicitly via `secrets:` | Inherits caller's secrets automatically | Inherits caller's secrets automatically |
| Learning curve | Low (YAML only) | Low (YAML only) | Medium (Node.js, packaging) |

## Detailed comparison

### Reusable workflows

A reusable workflow is a complete workflow file triggered by `workflow_call`. It defines its own `jobs`, each with `runs-on`, `steps`, `outputs`, and `secrets`. The caller invokes it with `uses: ./.github/workflows/name.yml` (or a cross-repo ref) and passes `with:` inputs and `secrets:`.

**Strengths**
- Encapsulates a full job: the caller does not need to know the runner, the steps, or the internal structure.
- Declarative input/output contract via `workflow_call.inputs` and `workflow_call.outputs` — validation happens at call time.
- Outputs are job-level, mapped explicitly: `value: ${{ jobs.<job_id>.outputs.<name> }}`.
- Can be versioned by git tag, branch, or commit SHA; callers pin to a specific ref.

**Limitations**
- Always runs as a separate job. The caller must `needs:` it if subsequent jobs depend on its outputs.
- Cannot inject steps into the caller's job; no access to the caller's workspace state except via passed inputs/outputs/artifacts.
- Limited to shell logic inside `run:` steps. Complex data transformation requires multi-line bash or calling out to a script/action.

**Typical use cases**
- Shared test suite run by multiple downstream workflows.
- Build-and-push job used by every service repository.
- Security scan job that publishes SARIF and returns a pass/fail output.

### Composite actions

A composite action is a YAML file at `.github/actions/<name>/action.yml` with `runs.using: composite`. It bundles a sequence of `run:` steps (and `uses:` of other actions) that execute inside the caller's job. It declares `inputs`, `outputs`, and `runs.steps`.

**Strengths**
- Runs inline in the caller's job — shares the same runner, workspace, and environment. No `needs:` coordination needed.
- Inputs/outputs declared in `action.yml` with type validation (`string`, `boolean`, `number`).
- Can use other actions (`uses:`) inside its steps, enabling composition of actions.
- Distributed the same way as reusable workflows (local path, cross-repo ref, or Marketplace).

**Limitations**
- Cannot define `runs-on` — inherits the caller's runner. If the logic requires a specific OS or architecture, the caller must provide it.
- No job-level isolation: a failing step fails the caller's job directly; no independent timeout or retry policy.
- Still limited to shell logic in `run:` steps. Complex logic pushes you toward a JavaScript action.

**Typical use cases**
- Shared setup sequence: checkout, toolchain install, cache restore.
- Reusable check bundle: lint → test → format → annotate, parameterized by mode.
- Wrapper around a CLI tool that standardizes flags and output parsing.

### Custom JavaScript actions

A JavaScript action is a Node.js program (usually a single `index.js` or `main.js`) declared in `action.yml` with `runs.using: 'node20'` (or `node16`/`node20`). It runs as a single step in the caller's job. Inputs arrive via `INPUT_<NAME>` environment variables; outputs are written to `GITHUB_OUTPUT`.

**Strengths**
- Full programming language: loops, conditionals, structured data, HTTP calls, JSON parsing, crypto, etc.
- No shell escaping or quoting issues — inputs are proper strings, not interpolated into script text.
- Can use the GitHub REST/GraphQL API directly via `fetch` (built into Node 18+).
- Runs on the caller's runner with no extra dependencies if you stick to stdlib.

**Limitations**
- Input/output handling is manual: `process.env.INPUT_<NAME>` and appending to `GITHUB_OUTPUT`. No declarative validation — you write the checks.
- Packaging: the action must be distributed with its code. Options: (a) check in `node_modules` (bloats repo), (b) use `@vercel/ncc` to bundle into one file, (c) publish to npm and reference by package name (adds publish step). The stdlib-only approach avoids all three but limits you to Node built-ins.
- Debugging is harder: logs show only `console.log`/`console.error`; no step-by-step YAML visibility.
- Versioning typically via git tags on the action's repository or npm versions.

**Typical use cases**
- GitHub API interactions: create issues, query labels, manage deployments, comment on PRs.
- Complex data transformation: merge coverage reports, generate matrices from external sources, parse SBOMs.
- Custom validation logic that cannot be expressed in shell (e.g., semantic version comparison, schema validation).
- Any task where shell would exceed 50 lines or require fragile string manipulation.

## Decision flowchart

```
START: Do you need to share a full job with its own runner?
  ├─ YES → Reusable workflow
  └─ NO: Do you need complex logic (API calls, loops, JSON parsing, conditionals beyond shell)?
        ├─ YES → JavaScript action
        └─ NO: Do you need the steps to run inside the caller's job (share workspace, env, runner)?
              ├─ YES → Composite action
              └─ NO → Reusable workflow (job-level isolation is acceptable)
```

## Side-by-side example: "Run tests and publish a summary"

### Reusable workflow (`.github/workflows/test-and-summary.yml`)

```yaml
name: test-and-summary
on:
  workflow_call:
    inputs:
      test-command:
        type: string
        default: npm test
    outputs:
      summary:
        description: One-line test result
        value: ${{ jobs.test.outputs.summary }}
jobs:
  test:
    runs-on: ubuntu-latest
    outputs:
      summary: ${{ steps.record.outputs.summary }}
    steps:
      - uses: actions/checkout@v4
      - run: ${{ inputs.test-command }}
      - id: record
        run: echo "summary=tests passed" >> "$GITHUB_OUTPUT"
```

**Caller:**
```yaml
jobs:
  test:
    uses: ./.github/workflows/test-and-summary.yml
    with:
      test-command: make test
  notify:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - run: echo "Result: ${{ needs.test.outputs.summary }}"
```

### Composite action (`.github/actions/test-and-summary/action.yml`)

```yaml
name: test-and-summary
description: Run tests and emit a summary output
inputs:
  test-command:
    description: Command to run tests
    required: false
    default: npm test
outputs:
  summary:
    description: One-line test result
    value: ${{ steps.record.outputs.summary }}
runs:
  using: composite
  steps:
    - uses: actions/checkout@v4
    - run: ${{ inputs.test-command }}
      shell: bash
    - id: record
      run: echo "summary=tests passed" >> "$GITHUB_OUTPUT"
      shell: bash
```

**Caller:**
```yaml
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: ./.github/actions/test-and-summary
        id: test
        with:
          test-command: make test
      - run: echo "Result: ${{ steps.test.outputs.summary }}"
```

### JavaScript action (`.github/actions/test-summary-js/index.js`)

```javascript
// last_verified: 2026-10-19 · gha n/a
'use strict';

const { execSync } = require('child_process');
const fs = require('fs');

const testCommand = (process.env.INPUT_TEST_COMMAND || 'npm test').trim();
const outputPath = process.env.GITHUB_OUTPUT;
if (!outputPath) throw new Error('GITHUB_OUTPUT not set');

try {
  execSync(testCommand, { stdio: 'inherit', shell: '/bin/bash' });
  fs.appendFileSync(outputPath, 'summary=tests passed\n');
} catch (e) {
  fs.appendFileSync(outputPath, 'summary=tests failed\n');
  process.exitCode = 1;
}
```

**`action.yml`:**
```yaml
name: test-summary-js
description: Run tests and emit a summary output (JS)
inputs:
  test-command:
    description: Command to run tests
    required: false
    default: npm test
outputs:
  summary:
    description: One-line test result
runs:
  using: node20
  main: index.js
```

**Caller:**
```yaml
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: ./.github/actions/test-summary-js
        id: test
        with:
          test-command: make test
      - run: echo "Result: ${{ steps.test.outputs.summary }}"
```

## Common errors

| Symptom | Likely cause | Resolution |
|---|---|---|
| `workflow_call` inputs not received | Caller used `with:` but the reusable workflow expects `inputs:` at the top level | Ensure the reusable workflow has `on.workflow_call.inputs` defined; caller uses `with:` correctly |
| Composite action output empty | Step wrote to `GITHUB_OUTPUT` but `action.yml` output `value` references wrong step ID | Match `value: ${{ steps.<id>.outputs.<name> }}` exactly to the step's `id:` |
| JavaScript action `INPUT_` vars empty | Input name in `action.yml` has hyphens (e.g., `test-command`) but env var is `INPUT_TEST_COMMAND` | Hyphens become underscores and are uppercased; use `process.env.INPUT_TEST_COMMAND` |
| Caller fails with "action not found" | Referenced path (`.github/actions/...`) does not exist in the repository at the checked-out ref | Ensure the action directory is committed and the caller checks out the correct ref/branch |
| Reusable workflow output not available to later jobs | Caller job missing `needs:` or output not declared in `workflow_call.outputs` | Add `needs: <job_id>` and declare the output in the reusable workflow's `on.workflow_call.outputs` |
| Composite action `uses:` another action fails | Nested action not found at the relative path from the composite action's directory | Use absolute repo path (`owner/repo/path@ref`) or ensure nested action is checked out |

## References

- [Reusing workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows) — GitHub docs on `workflow_call`, inputs, outputs, secrets.
- [Creating a composite action](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) — Composite action structure, `runs.using: composite`, inputs/outputs.
- [Creating a JavaScript action](https://docs.github.com/en/actions/creating-actions/creating-a-javascript-action) — Node.js action structure, `runs.using: node20`, input/output handling.
- [gha/manifests/reusable-workflow-ecosystem.yaml](../manifests/reusable-workflow-ecosystem.yaml) — Working three-layer example in this kit.
- [gha/scripts/custom-js-action/index.js](../scripts/custom-js-action/index.js) — Stdlib-only JavaScript action pattern used in this kit.