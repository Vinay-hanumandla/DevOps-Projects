# last_verified: 2026-08-24 · python n/a
"""
validate-dockerfile.py

Validates a Dockerfile for common issues: missing FROM, using :latest,
missing USER, missing WORKDIR, and missing HEALTHCHECK.
"""

import sys
from pathlib import Path


def load_dockerfile(path: str) -> list[str]:
    compose_path = Path(path)
    if not compose_path.exists():
        print(f"Error: {path} not found")
        sys.exit(1)
    return compose_path.read_text().splitlines()


def validate(lines: list[str]) -> tuple[list[str], list[str]]:
    errors = []
    warnings = []
    has_from = False
    has_cmd_or_entrypoint = False
    has_user = False
    has_healthcheck = False
    has_workdir = False

    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        parts = stripped.split()
        instruction = parts[0].upper()

        if instruction == "FROM":
            has_from = True
            if len(parts) >= 2 and parts[1].endswith(":latest"):
                warnings.append(
                    f"Line {i}: FROM uses :latest tag — pin a specific version"
                )
        elif instruction in ("CMD", "ENTRYPOINT"):
            has_cmd_or_entrypoint = True
        elif instruction == "USER":
            has_user = True
        elif instruction == "HEALTHCHECK":
            has_healthcheck = True
        elif instruction == "WORKDIR":
            has_workdir = True

    if not has_from:
        errors.append("No FROM instruction found")
    if not has_cmd_or_entrypoint:
        errors.append("No CMD or ENTRYPOINT instruction found")
    if not has_user:
        warnings.append("No USER instruction — container will run as root")
    if not has_workdir:
        warnings.append("No WORKDIR instruction — default working directory is /")
    if not has_healthcheck:
        warnings.append(
            "No HEALTHCHECK instruction — orchestrator cannot detect unhealthy containers"
        )

    return errors, warnings


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: python validate-dockerfile.py <Dockerfile>")
        sys.exit(1)

    lines = load_dockerfile(sys.argv[1])
    errors, warnings = validate(lines)

    if errors:
        print("Errors:")
        for err in errors:
            print(f"  - {err}")
    if warnings:
        print("Warnings:")
        for warn in warnings:
            print(f"  - {warn}")
    if not errors and not warnings:
        print("Dockerfile validation passed.")

    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
