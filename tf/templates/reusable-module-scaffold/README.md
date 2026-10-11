---
last_verified: 2026-10-11
tool_version: n/a
---

# Reusable Terraform Module Scaffold

## Purpose

This template provides a production-ready scaffold for building reusable Terraform modules. It includes variable validation, output contracts, a Terratest-based test harness, and a CI workflow — the pieces every module needs before it ships to a private registry or gets consumed by downstream configurations.

## Prerequisites

- Terraform CLI >= 1.5
- Go >= 1.22 (for Terratest)
- A Terraform backend (S3, GCS, Azure Storage, or equivalent) configured for integration tests

## Layout

```text
reusable-module-scaffold/
├── modules/
│   └── example-module/
│       ├── main.tf              # Example resource using validated inputs
│       ├── variables.tf         # Validated inputs with regex/enum checks
│       ├── outputs.tf           # Contract outputs for downstream consumers
│       ├── versions.tf          # Provider/version constraints
│       ├── go.mod               # Terratest dependencies
│       └── test/
│           └── main_test.go     # Terratest cases: happy path, disabled, validation failures
├── examples/
│   └── basic/
│       └── main.tf              # Minimal consumption example
└── .github/
    └── workflows/
        └── test.yml             # CI: matrix Go versions, Terratest, fmt, validate
```

## Steps

1. Copy the `reusable-module-scaffold` directory into a new repository.
2. Rename `modules/example-module` to your module name (e.g., `modules/vpc`).
3. Edit `variables.tf`: replace the example variables with your module's actual inputs. Keep the `validation` blocks — they are the contract callers rely on.
4. Edit `outputs.tf`: define the contract outputs your downstream configurations will consume. Every output must have a `description`.
5. Edit `main.tf` and `versions.tf`: implement the real resources and pin provider versions.
6. Update `test/main_test.go`: adjust the expected outputs and add cases for your resources.
7. Run the test suite locally:

   ```sh
   cd modules/your-module
   go mod tidy
   go test -v -timeout 20m ./test/...
   ```

8. Push to a branch; the GitHub Actions workflow (`.github/workflows/test.yml`) runs on every PR and push to `main`.

## Verify

- `terraform init -backend=false && terraform validate` passes in both `modules/your-module/` and `examples/basic/`.
- `terraform fmt -check -diff` reports no changes.
- `go test -v ./test/...` passes: happy path, disabled module, and validation-rejection cases.
- CI workflow shows green on the matrix (Go 1.22, 1.23).

## Design Decisions

- **Variable validation over runtime checks**: Regex and enum validations in `variables.tf` fail fast at plan time, not apply time.
- **Output contracts**: Every output has a description and a stable name. Downstream modules import the contract, not implementation details.
- **Null provider for tests**: The example uses `hashicorp/null` so Terratest runs without cloud credentials. Swap in real providers for integration tests against a live backend.
- **Matrix Go versions**: Testing against two minor Go versions catches stdlib/terratest compatibility drift early.
- **No Terratest `go.sum` in template**: `go mod tidy` generates it on first run; committing it would pin transitive deps to the template author's machine.

## What Comes Next

- Add a `versions.tf` with real provider pins (AWS, Azure, GCP, Kubernetes, etc.).
- Expand `test/main_test.go` with resource-specific assertions (ARN formats, naming conventions, tag propagation).
- Wire the CI workflow to a real backend for `terraform plan`/`apply` stages behind manual approvals.
- Publish to a private module registry with semantic versioning; tag releases from `main` only.