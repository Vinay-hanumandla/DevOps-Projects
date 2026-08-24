# last_verified: 2026-08-24 · python n/a
"""
validate-docker-compose.py

Validates a docker-compose.yml file for required service definitions,
missing images/build contexts, and malformed port entries.
"""

import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("PyYAML is required — install it with: pip install pyyaml")
    sys.exit(1)


def load_compose(path: str) -> dict:
    compose_path = Path(path)
    if not compose_path.exists():
        print(f"Error: {path} not found")
        sys.exit(1)
    with open(compose_path) as f:
        data = yaml.safe_load(f)
    return data if isinstance(data, dict) else {}


def validate_services(compose: dict) -> list:
    errors = []
    services = compose.get("services", {})
    if not services:
        errors.append("No services defined under top-level 'services'")
        return errors

    for name, svc in services.items():
        if not isinstance(svc, dict):
            errors.append(f"Service '{name}' is not a mapping")
            continue
        if "image" not in svc and "build" not in svc:
            errors.append(
                f"Service '{name}' must define either 'image' or 'build'"
            )
        ports = svc.get("ports")
        if ports is not None:
            if not isinstance(ports, list):
                errors.append(f"Service '{name}' ports must be a list")
            else:
                for p in ports:
                    if not isinstance(p, (str, int)):
                        errors.append(
                            f"Service '{name}' has invalid port entry: {p}"
                        )
    return errors


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: python validate-docker-compose.py <docker-compose.yml>")
        sys.exit(1)

    compose = load_compose(sys.argv[1])
    errors = validate_services(compose)

    if errors:
        print("Docker Compose validation failed:")
        for err in errors:
            print(f"  - {err}")
        sys.exit(1)
    print("Docker Compose validation passed.")


if __name__ == "__main__":
    main()
