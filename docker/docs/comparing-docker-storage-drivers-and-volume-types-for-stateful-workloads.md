---
last_verified: 2026-10-11
tool_version: n/a
---

# Comparing Docker storage drivers and volume types for stateful workloads

## Purpose

Docker's storage driver determines how image layers and container writable layers are stored on the host, while the volume type determines how application data persists independent of the container lifecycle. This document walks through the driver and volume options and gives a decision path for stateful workloads, written from the perspective of someone who has just run through the options on a test host.

## Drivers at a glance

- **overlay2** — Uses the kernel overlay filesystem to stack read-only image layers with a single writable top layer. Near-native performance. Requires Linux kernel 4.0+ and `xfs` or `ext4` with `d_type` support. The default on modern Linux and the right choice for most workloads.
- **btrfs** — Leverages Btrfs subvolumes and copy-on-write snapshots. Good for snapshot-heavy workflows, but higher memory overhead and not recommended for database workloads with heavy random writes.
- **zfs** — Uses ZFS datasets and clones with strong data integrity guarantees and ARC caching. Excellent for read-heavy workloads with deduplication or compression needs, but high memory consumption and operational complexity.
- **vfs** — Simple directory-based copy-on-write with no kernel filesystem features. Extremely slow and copies entire layers on container start. Fallback only, for testing on unsupported filesystems.
- **aufs** — Legacy union filesystem. Deprecated and removed from modern Docker Engine versions. Migrate to overlay2.

## Volume types at a glance

- **Named volumes** (`docker volume create`) — Managed by Docker, persist until explicitly removed, stored at `/var/lib/docker/volumes/<name>/_data`. Best for application data that must survive container recreates, database files, and configuration. Supports volume plugins.
- **Bind mounts** (`-v /host/path:/container/path`) — Tied to the host filesystem and not managed by Docker. Near-native performance. Best for development, live code reload, and host config files. Low portability and permission mismatches are common.
- **tmpfs mounts** (`--tmpfs /container/path`) — In-memory only, destroyed when the container stops. Fastest possible I/O. Best for secrets, caches, and session data that must not persist.

## Decision path

1. Confirm the active driver with `docker info --format '{{.Driver}}'`. On modern Linux the answer should be `overlay2`.
2. For data that must survive a container recreate, choose a named volume. For host files or development, choose a bind mount. For temporary data that must never hit disk, choose tmpfs.
3. For multi-node or cloud deployments, look at volume plugins (block storage like AWS EBS or GCE PD, file/object storage, distributed drivers like Ceph or Portworx) instead of the local driver.
4. Validate the choice with a persistence test: write a file in a container, stop and remove the container, then start a new one attached to the same volume and confirm the file is still there.

## Verify

- `docker info --format '{{.Driver}}'` returns the expected driver.
- `docker volume ls` and `docker volume inspect <name>` show the volume and its driver.
- A write-then-restart test confirms persistence for named volumes.
- `docker run --rm -v <volume>:/data alpine fio ...` benchmarks I/O for the candidate configuration.

## Common errors

- **overlay2 on an unsupported filesystem** — `xfs` without `d_type=true`, or `btrfs`/`zfs` as the backing filesystem. Check the host filesystem with `df -T` and reformat or switch drivers.
- **Permission denied on bind mounts** — the host directory is owned by root but the container runs as a non-root UID. Fix with `chown -R <uid>:<gid> /host/path`, `--user` mapping, or the `:Z`/`:z` SELinux label suffix.
- **Volume plugin not installed** — `docker volume create -d <plugin>` fails. Install the plugin with `docker plugin install <plugin>` on every node.
- **tmpfs size exceeded** — the container OOMs or writes fail. Set `--tmpfs /path:size=512m` and monitor with `docker stats`.
