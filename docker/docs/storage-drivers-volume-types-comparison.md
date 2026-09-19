---
last_verified: 2026-09-19
tool_version: n/a
---

# Docker Storage Drivers and Volume Types — Comparison for Stateful Workloads

## Purpose

This document compares Docker storage drivers and volume types to help operators choose the right configuration for stateful workloads. The choice of storage driver and volume type directly affects performance, data persistence, portability, and operational complexity.

## Storage Drivers

Docker uses a pluggable storage driver architecture. The driver determines how image layers and container writable layers are stored and managed on the host filesystem.

### overlay2 (Default on Modern Linux)

- **Mechanism**: Uses the kernel's overlay filesystem to stack read-only image layers with a single writable top layer.
- **Performance**: Near-native performance; minimal overhead for read/write operations.
- **Kernel requirement**: Linux kernel 4.0+ (widely available on supported distributions).
- **Best for**: General-purpose workloads, most production deployments.
- **Caveats**: Requires `xfs` or `ext4` with `d_type` support enabled; not compatible with `btrfs` or `zfs` backing filesystems.

### btrfs

- **Mechanism**: Leverages Btrfs subvolumes and copy-on-write snapshots for layer management.
- **Performance**: Good for workloads with frequent snapshots; copy-on-write reduces duplication.
- **Kernel requirement**: Linux kernel with Btrfs support.
- **Best for**: Environments already standardized on Btrfs; workloads benefiting from native snapshots.
- **Caveats**: Requires dedicated block device or partition formatted as Btrfs; higher memory overhead; not recommended for database workloads with heavy random writes.

### zfs

- **Mechanism**: Uses ZFS datasets and clones for layer storage; provides strong data integrity guarantees.
- **Performance**: Excellent for read-heavy workloads; ARC caching improves repeated reads.
- **Kernel requirement**: ZFS kernel modules (DKMS or native on supported distros).
- **Best for**: Workloads requiring data integrity, deduplication, or compression; environments with ZFS expertise.
- **Caveats**: High memory consumption (ARC); licensing considerations (CDDL vs GPL); operational complexity.

### vfs (Fallback)

- **Mechanism**: Simple directory-based copy-on-write; no kernel filesystem features required.
- **Performance**: Poor — copies entire layers on container start; not suitable for production.
- **Best for**: Testing on unsupported filesystems; debugging storage driver issues.
- **Caveats**: Extremely slow; high disk usage; no production use.

### aufs (Legacy)

- **Mechanism**: Union filesystem stacking multiple branches.
- **Status**: Deprecated; removed from modern Docker Engine versions.
- **Best for**: None — migrate to overlay2.

---

## Volume Types

Volumes are the preferred mechanism for persisting data independent of container lifecycle. They are managed by Docker and isolated from the host filesystem structure.

### Named Volumes (`docker volume create`)

- **Lifecycle**: Managed by Docker; persists until explicitly removed.
- **Storage location**: `/var/lib/docker/volumes/<name>/_data` (driver-dependent).
- **Portability**: Can be backed up, restored, and migrated via `docker volume` CLI or plugins.
- **Drivers**: Supports volume plugins (e.g., `local`, `nfs`, `rexray`, cloud provider plugins).
- **Best for**: Application data requiring persistence across container recreates; database files; configuration that must survive updates.

### Bind Mounts (`-v /host/path:/container/path`)

- **Lifecycle**: Tied to host filesystem; exists independently of Docker.
- **Storage location**: Any host path accessible to the Docker daemon.
- **Portability**: Low — couples container to specific host paths; not managed by `docker volume` commands.
- **Performance**: Near-native (direct host filesystem access).
- **Best for**: Development (live code reload); accessing host configuration files; log aggregation sidecars.
- **Caveats**: Host path must exist; permission mismatches common (UID/GID mapping); not portable across hosts.

### tmpfs Mounts (`--tmpfs /container/path`)

- **Lifecycle**: In-memory only; destroyed when container stops.
- **Storage location**: Host RAM (or swap if configured).
- **Performance**: Fastest possible — no disk I/O.
- **Best for**: Secrets, caches, session data, temporary computation results that must not persist.
- **Caveats**: Data lost on container stop/restart; consumes host memory; size limits apply.

---

## Volume Drivers (Plugins)

Docker's volume plugin system extends storage beyond the local host.

| Driver Category | Examples | Use Case |
|-----------------|----------|----------|
| Local (built-in) | `local` with `type=nfs`, `type=tmpfs` | NFS shares, in-memory volumes on remote hosts |
| Block storage | `rexray` (Dell EMC, AWS EBS, GCE PD), `vsphere` | Persistent block volumes in virtualized/cloud environments |
| File/Object storage | `azurefile`, `gcsfuse`, `s3fs` | Shared file systems, object-backed volumes |
| Distributed | `ceph`, `glusterfs`, `portworx`, `rook` | Multi-node clusters, high availability, replication |

---

## Decision Matrix for Stateful Workloads

| Workload Profile | Recommended Driver | Recommended Volume Type | Rationale |
|------------------|-------------------|------------------------|-----------|
| Relational database (PostgreSQL, MySQL) | overlay2 | Named volume (local or block plugin) | Consistent latency, durability, backup/restore via snapshots |
| Distributed database (Cassandra, MongoDB replica set) | overlay2 | Named volume with block plugin (EBS, PD) | Per-node persistence, cloud snapshot integration |
| Message queue (Kafka, RabbitMQ) | overlay2 | Named volume (local or NFS) | Sequential write patterns; NFS enables shared access for some topologies |
| Search index (Elasticsearch, OpenSearch) | overlay2 | Named volume with block plugin | Large sequential writes; snapshot/restore critical |
| Cache/Session store (Redis) | overlay2 | tmpfs (if persistence not required) or named volume | In-memory speed; persistence optional |
| Application config / secrets | overlay2 | Bind mount (config) / tmpfs or named volume (secrets) | Config: host-managed; Secrets: memory-only or encrypted volume |
| CI/CD build artifacts | overlay2 | Named volume or bind mount | Bind mount for host access; named volume for isolation |

---

## Verification Steps

1. **Confirm active storage driver**:
   ```bash
   docker info --format '{{.Driver}}'
   ```
   Expected: `overlay2` on modern Linux.

2. **List volumes and inspect drivers**:
   ```bash
   docker volume ls
   docker volume inspect <volume-name>
   ```

3. **Benchmark I/O for candidate configuration**:
   ```bash
   # Example: fio random read/write test inside container
   docker run --rm -v <volume>:/data alpine fio --name=randrw --ioengine=libaio --rw=randrw --bs=4k --size=1G --numjobs=4 --runtime=60 --time_based --directory=/data
   ```

4. **Test backup/restore workflow**:
   ```bash
   # Backup
   docker run --rm -v <volume>:/data -v $(pwd):/backup alpine tar czf /backup/volume-backup.tar.gz -C /data .
   # Restore
   docker run --rm -v <volume>:/data -v $(pwd):/backup alpine tar xzf /backup/volume-backup.tar.gz -C /data
   ```

5. **Validate container restart persistence**:
   ```bash
   docker run -d --name test -v <volume>:/data alpine sh -c 'echo hello > /data/test.txt'
   docker rm -f test
   docker run --rm -v <volume>:/data alpine cat /data/test.txt
   ```

---

## Common Errors

- **Permission denied on bind mounts**: Host directory owned by root; container runs as non-root UID. Fix: `chown -R <container-uid>:<container-gid> /host/path` or use `--user` mapping.
- **overlay2 on unsupported filesystem**: `xfs` without `d_type=true` or `btrfs`/`zfs` as backing fs. Fix: Reformat with supported options or switch driver.
- **Volume plugin not installed**: `docker volume create -d <plugin> ...` fails. Fix: Install and configure plugin (`docker plugin install <plugin>`).
- **tmpfs size exceeded**: Container OOM or write failures. Fix: Set `--tmpfs /path:size=512m` to limit; monitor with `docker stats`.
- **SELinux/AppArmor blocking volume access**: Denied messages in `dmesg` or audit log. Fix: Label volume with `:Z` (shared) or `:z` (private) suffix: `-v /host:/container:Z`.

---

## What to Explore Next

- Volume plugin configuration for specific cloud providers (AWS EBS CSI, GCP PD CSI, Azure Disk CSI).
- Integrating Docker volumes with Kubernetes persistent volumes via `docker-volume-plugin` or CSI migration.
- Disaster recovery drills: simulated host failure, volume restore from off-site backup.