# last_verified: 2026-08-24 · python n/a
"""
config-validator.py

Reads a YAML configuration file and validates required keys, value types,
and port ranges. Exits 0 on success, 1 on validation failure.
"""

import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("PyYAML is required — install it with: pip install pyyaml")
    sys.exit(1)


REQUIRED_KEYS = {
    "app_name": str,
    "port": int,
    "debug": bool,
    "database": {
        "host": str,
        "port": int,
        "name": str,
    },
}


def load_config(path: str) -> dict:
    config_path = Path(path)
    if not config_path.exists():
        print(f"Error: config file not found: {path}")
        sys.exit(1)
    with open(config_path) as f:
        data = yaml.safe_load(f)
    return data if isinstance(data, dict) else {}


def validate_types(data: dict, schema: dict, prefix: str = "") -> list:
    errors = []
    for key, expected in schema.items():
        full_key = f"{prefix}.{key}" if prefix else key
        if key not in data:
            errors.append(f"Missing required key: {full_key}")
            continue
        value = data[key]
        if isinstance(expected, dict):
            if not isinstance(value, dict):
                errors.append(f"{full_key} must be a mapping")
            else:
                errors.extend(validate_types(value, expected, full_key))
        elif not isinstance(value, expected):
            errors.append(
                f"{full_key} must be {expected.__name__}, "
                f"got {type(value).__name__}"
            )
    return errors


def validate_ports(data: dict) -> list:
    errors = []
    port = data.get("port")
    if port is not None:
        if not isinstance(port, int) or not (1 <= port <= 65535):
            errors.append(
                f"port must be an integer between 1 and 65535, got {port}"
            )
    db = data.get("database", {})
    db_port = db.get("port")
    if db_port is not None:
        if not isinstance(db_port, int) or not (1 <= db_port <= 65535):
            errors.append(
                f"database.port must be an integer between 1 and 65535, "
                f"got {db_port}"
            )
    return errors


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: python config-validator.py <config.yaml>")
        sys.exit(1)

    config = load_config(sys.argv[1])
    errors = validate_types(config, REQUIRED_KEYS)
    errors.extend(validate_ports(config))

    if errors:
        print("Validation failed:")
        for err in errors:
            print(f"  - {err}")
        sys.exit(1)
    print("Validation passed.")


if __name__ == "__main__":
    main()
