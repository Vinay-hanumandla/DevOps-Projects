# last_verified: 2026-08-22 · python n/a
# Reads a YAML config file and prints the values.
# Followed the quickstart; this is my first script that actually parses a config.

import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("PyYAML not installed — run: pip install pyyaml")
    sys.exit(1)


def read_config(path: str) -> dict:
    """Load a YAML config file and return it as a dict."""
    config_path = Path(path)
    if not config_path.exists():
        print(f"Config file not found: {path}")
        sys.exit(1)

    with open(config_path) as f:
        data = yaml.safe_load(f)

    return data


def print_config(data: dict, indent: int = 0) -> None:
    """Pretty-print the config dict, handling nested dicts."""
    prefix = "  " * indent
    for key, value in data.items():
        if isinstance(value, dict):
            print(f"{prefix}{key}:")
            print_config(value, indent + 1)
        else:
            print(f"{prefix}{key}: {value}")


if __name__ == "__main__":
    config_file = sys.argv[1] if len(sys.argv) > 1 else "app-config.yaml"
    config = read_config(config_file)
    print(f"--- Config from {config_file} ---")
    print_config(config)
