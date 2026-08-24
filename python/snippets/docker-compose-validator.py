# last_verified: 2026-08-24 · python n/a
# Validates a Docker Compose file: checks required fields, image references,
# port conflicts, and volume mount syntax. Uses PyYAML for parsing.
# Run: python 2026-08-24-docker-compose-validator.py docker-compose.yaml

import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("PyYAML not installed — run: pip install pyyaml")
    sys.exit(1)


def load_compose(path: str) -> dict:
    """Load a Docker Compose YAML file and return the parsed dict."""
    compose_path = Path(path)
    if not compose_path.exists():
        print(f"File not found: {path}")
        sys.exit(1)

    with open(compose_path) as f:
        data = yaml.safe_load(f)

    if not isinstance(data, dict):
        print("Error: compose file is not a valid YAML mapping")
        sys.exit(1)

    return data


def check_required_version(data: dict) -> list[str]:
    """Verify the compose file declares a version (required for v2/v3 schemas)."""
    errors = []
    if "version" not in data:
        errors.append("Missing top-level 'version' key")
    return errors


def check_services(data: dict) -> list[str]:
    """Validate each service block: must have an image or build key."""
    errors = []
    services = data.get("services")
    if not services:
        errors.append("No 'services' section found")
        return errors

    if not isinstance(services, dict):
        errors.append("'services' must be a mapping")
        return errors

    for name, svc in services.items():
        if not isinstance(svc, dict):
            errors.append(f"Service '{name}' is not a mapping")
            continue
        if "image" not in svc and "build" not in svc:
            errors.append(f"Service '{name}' missing both 'image' and 'build'")
    return errors


def check_port_conflicts(data: dict) -> list[str]:
    """Detect duplicate host port bindings across services."""
    errors = []
    services = data.get("services", {})
    seen_ports: dict[str, str] = {}

    for name, svc in services.items():
        if not isinstance(svc, dict):
            continue
        for port_entry in svc.get("ports", []):
            port_str = str(port_entry)
            parts = port_str.split(":")
            if len(parts) == 2:
                host_port = parts[0]
                if host_port in seen_ports:
                    errors.append(
                        f"Port conflict: host port {host_port} used by "
                        f"'{seen_ports[host_port]}' and '{name}'"
                    )
                else:
                    seen_ports[host_port] = name
    return errors


def check_volumes(data: dict) -> list[str]:
    """Warn about volume mounts that look like relative paths without a leading dot."""
    warnings = []
    services = data.get("services", {})
    for name, svc in services.items():
        if not isinstance(svc, dict):
            continue
        for vol in svc.get("volumes", []):
            vol_str = str(vol)
            # named volumes (no /) and absolute paths (/) are fine
            if "/" in vol_str and not vol_str.startswith("/") and not vol_str.startswith("./"):
                warnings.append(
                    f"Service '{name}': volume '{vol_str}' looks like a "
                    f"relative path — consider prefixing with ./"
                )
    return warnings


def main():
    if len(sys.argv) < 2:
        print("Usage: python compose-validator.py <compose-file.yaml>")
        sys.exit(1)

    path = sys.argv[1]
    data = load_compose(path)

    all_errors: list[str] = []
    all_warnings: list[str] = []

    all_errors.extend(check_required_version(data))
    all_errors.extend(check_services(data))
    all_errors.extend(check_port_conflicts(data))
    all_warnings.extend(check_volumes(data))

    if all_errors:
        print("Errors:")
        for e in all_errors:
            print(f"  - {e}")

    if all_warnings:
        print("Warnings:")
        for w in all_warnings:
            print(f"  - {w}")

    if not all_errors and not all_warnings:
        print("All checks passed.")

    sys.exit(1 if all_errors else 0)


if __name__ == "__main__":
    main()
