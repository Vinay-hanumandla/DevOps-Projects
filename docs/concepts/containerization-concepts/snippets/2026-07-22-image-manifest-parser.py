# last_verified: 2026-07-22 · n/a
"""
Parse an OCI/Docker image manifest from a JSON file and print layer info.

I wanted to understand what happens inside docker pull, so I wrote this
to inspect the structure that container runtimes use to assemble images.
"""

import json
import sys
import os


def parse_manifest(path: str) -> None:
    if not os.path.exists(path):
        print(f"Error: {path} not found")
        sys.exit(1)

    with open(path) as f:
        manifest = json.load(f)

    schema = manifest.get("schemaVersion", "unknown")
    media_type = manifest.get("mediaType", "not set")

    print(f"Schema version: {schema}")
    print(f"Media type:     {media_type}")
    print()

    config = manifest.get("config", {})
    if config:
        print(f"Config digest: {config.get('digest', 'n/a')}")
        print(f"Config size:   {config.get('size', 0)} bytes")
        print()

    layers = manifest.get("layers", [])
    print(f"Layers ({len(layers)}):")
    total_size = 0
    for i, layer in enumerate(layers):
        digest = layer.get("digest", "n/a")
        short = digest[7:19] if len(digest) > 19 else digest
        size = layer.get("size", 0)
        total_size += size
        media = layer.get("mediaType", "unknown")
        fmt = media.split(".")[-1] if "." in media else media
        print(f"  [{i}] {short}  ({size} bytes, {fmt})")

    print(f"\nTotal compressed layer size: {total_size} bytes "
          f"({total_size / 1024 / 1024:.1f} MB)")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python parse_manifest.py <manifest.json>")
        sys.exit(1)
    parse_manifest(sys.argv[1])
