# last_verified: 2026-07-21 · containerization concepts L2
"""
Parse an OCI/Docker image manifest from a JSON file and print layer info.

I'm following the OCI image spec — the manifest links to a config object
and a list of layers (each being a filesystem diff). This is the core
data structure that Docker, containerd, and other runtimes use to
assemble container root filesystems.
"""

import json
import sys


def parse_manifest(path: str) -> None:
    with open(path) as f:
        manifest = json.load(f)

    # The schema version tells us whether this is Docker V2 or OCI.
    # OCI uses "schemaVersion": 2 with an extra "mediaType" field.
    schema = manifest.get("schemaVersion", "unknown")
    media_type = manifest.get("mediaType", "not set")

    print(f"Schema version: {schema}")
    print(f"Media type:     {media_type}")
    print()

    # The config blob holds the image's metadata — CMD, ENV, history, etc.
    config = manifest.get("config", {})
    print(f"Config digest: {config.get('digest', 'n/a')}")
    print(f"Config size:   {config.get('size', 'n/a')} bytes")
    print()

    # Layers are the real meat — each is a compressed tarball (a "diff").
    # When you run `docker pull`, these are the blobs being downloaded.
    layers = manifest.get("layers", [])
    print(f"Layers ({len(layers)}):")
    for i, layer in enumerate(layers):
        digest = layer.get("digest", "n/a")
        size = layer.get("size", 0)
        # size here is the compressed size; the uncompressed size is
        # only visible once you extract the tarball
        print(f"  [{i}] {digest}  ({size} bytes compressed)")

    # Short sanity: no layers means this isn't a runnable image
    if not layers:
        print("\nNo layers found — this manifest describes an empty image.")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python parse_manifest.py <manifest.json>")
        sys.exit(1)
    parse_manifest(sys.argv[1])
