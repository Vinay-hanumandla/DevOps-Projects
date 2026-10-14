---
last_verified: 2026-10-14
tool_version: n/a
---

# Prometheus production operations runbook

## Purpose

Keep a self-hosted Prometheus server recoverable: regular backups of the time-series store, a tested restore path, sane compaction and retention behaviour, write-ahead log (WAL) settings that survive restarts without excessive replay time, and a disaster recovery order of operations for a lost data directory.

## When to use

This runbook applies to a single Prometheus server (or each server in a pair) that stores its own local TSDB data. It does not cover remote-write backends or Thanos/Cortex-style long-term storage — those systems own their own durability story. Use it when setting up backups for the first time, after any storage-layout change, and as the checklist to follow during an actual outage.

## Prerequisites

- Filesystem access to the host running Prometheus and to the data directory it was started with.
- Enough free disk for at least one full copy of the data directory plus head-room for one WAL replay cycle.
- A place to store snapshots off-host (object storage, NFS share, or a backup host).

## Steps

### 1. Take a backup

There are two supported approaches; snapshot-then-copy is the preferred one because it does not require downtime.

**Option A — snapshot via the admin API, then copy.** Enable the admin API on the server, trigger a snapshot, and copy the resulting snapshot directory off-host. The snapshot is a consistent point-in-time view of all persisted blocks; the live WAL is not part of it, so a few minutes of the freshest samples are expected to be missing after a restore from snapshot alone.

**Option B — stop, copy, start.** Stop the Prometheus process cleanly so the in-memory head is flushed, copy the entire data directory, then start it again. This captures everything including the WAL, at the cost of a scrape gap during the downtime. Prefer this before major upgrades.

In both cases verify the copy completed (compare directory listings or checksums) before rotating the previous backup out.

### 2. Restore from a backup

1. Stop the Prometheus process.
2. Move the damaged data directory aside rather than deleting it — a partial WAL can still be useful for diagnosis.
3. Place the backup copy at the configured data directory path and fix ownership so the server process can read and write it.
4. Start Prometheus and watch the log for WAL replay and block loading messages; the server becomes queryable once replay finishes.
5. Confirm the oldest sample timestamp matches the backup's age — that bounds how much history was lost.

A snapshot restore replays no WAL (snapshots contain only sealed blocks), so expect the most recent minutes before the snapshot to be absent. A full-directory restore replays the WAL and loses only what never reached disk.

### 3. Understand compaction

Prometheus compacts small persisted blocks into larger ones automatically in the background. There is normally nothing to tune here, but two behaviours matter operationally:

- Compaction needs free disk head-room: keep usage well below full, because a compaction cycle temporarily holds both the input blocks and the output block.
- Overlapping or uncompactable blocks after an unclean shutdown are usually resolved by the next compaction cycle; persistent compaction errors in the log point at corrupted blocks, and the fix is to drop the offending block directory and re-backfill from a peer or accept the gap.

### 4. WAL tuning

The WAL records every incoming sample before it is persisted, so it bounds both durability and restart time:

- **Replay time vs. durability.** A larger in-memory head means more samples held before flushing, which lengthens replay after a restart. If restarts take uncomfortably long, the lever is flushing more often (smaller head / shorter persisted-block ranges), at the cost of more, smaller blocks for compaction to merge.
- **Disk layout.** Keep the WAL on fast local disk. Network filesystems under the WAL path cause stalls that surface as scrape timeouts and query slowness, not as clear error messages.
- **Corruption handling.** If the log reports an unreadable WAL segment on startup, the documented recovery is to stop the server, remove the corrupt segment files, and restart — losing only the samples in those segments. Always snapshot the damaged directory first so the decision is reversible.

### 5. Disaster recovery order of operations

1. Confirm scope: one server down (fail over reads to the peer if paired) or all replicas down (restore from the newest off-host backup).
2. Provision a host with the same server configuration and mount the backup.
3. Restore per step 2, then re-attach alerting and remote-write consumers.
4. Backfill the gap if a peer still holds it; otherwise record the gap window for SLO accounting.
5. After recovery, take a fresh backup immediately — the restored server is now running on your only good copy.

## Verify

- Trigger a test snapshot and confirm a new timestamped snapshot directory appears under the data directory.
- Perform a restore drill on a spare host quarterly: stop, copy backup in, start, and confirm queries return data up to the backup's age.
- After any WAL or retention change, restart once in a maintenance window and time the replay; record the duration next to this runbook so the next on-call has a baseline.

## See also

- `hybrid-service-discovery.md` — the target-inventory layout this server scrapes, useful context when deciding what a restored server must re-discover.
- `promql-advanced-patterns.md` — query patterns for checking data completeness after a restore (e.g. confirming series presence across the gap window).
