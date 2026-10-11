# last_verified: 2026-10-10 · repo-doc n/a
"""Kit conformance checker: task schema, manifest sync, and level progression.

Purpose: give one runnable check that answers "do the task list, the
manifest snapshot, and the kit tree agree with each other" before a change
goes through CI. This is one way to do it; the shell and structure
validators in the same area cover folder layout and primers, while this
script covers the planning side: entry shape, queue consistency, and
prefix-to-folder progression.

Steps: point it at a kit checkout root plus a task list file and a manifest
file. It parses the ACTIVE section of the task list, validates each entry
carries the required fields with known values, cross-checks the manifest
queues against the parsed entries and the completed index, and resolves
each entry's id prefix to a folder on disk.

Verify: run ``python3 repo-doc/scripts/kit-conformance-checker.py --kit-root .
--tasks-file <task-list> --manifest <manifest>`` from the kit root; exit 0
means conformant, exit 1 means at least one problem was reported, exit 2
means an input file could not be read. Omit --tasks-file or --manifest to
skip that input's checks with a notice instead of an error.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

TASK_HEADER = re.compile(r"^\[(?P<status>[ !~]|[a-z]+)\]\s+(?P<id>[a-z0-9-]+)\s+(?P<title>.+)$")
LEVEL = re.compile(r"^L\d+$")
SIZE = {"small", "medium", "large"}
OUTPUT = re.compile(
    r"^(notes(\(primer\))?|docs|notebook|dockerfile|template"
    r"|snippet\([a-z+]+\)|script\([a-z+]+\)|config\([a-z]+\)|manifest\([a-z]+\))$"
)
DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
TASK_ID = re.compile(r"^([a-z-]+?)-?(\d+)$")

REQUIRED_FIELDS = ("Level:", "Size:", "Output:", "Generated:")

# Id prefixes with no kit directory; entries under them are skipped with a
# notice rather than reported as missing folders.
OUT_OF_SCOPE_PREFIXES = {"hchart", "tfc", "compose"}

# Open states: a task still to do. Anything else (stuck markers included)
# is reported as a notice so a human can decide what to do with it.
OPEN_STATUSES = {" ", "!", "~"}


def parse_active_tasks(text: str) -> tuple[dict[str, dict[str, str]], list[str]]:
    """Parse the ACTIVE section; return (entries, schema problems)."""
    entries: dict[str, dict[str, str]] = {}
    problems: list[str] = []
    active = False
    current: dict[str, str] | None = None
    for lineno, raw in enumerate(text.splitlines(), start=1):
        line = raw.strip()
        if line == "## ACTIVE":
            active = True
            continue
        if line == "## BACKLOG":
            break
        if not active or not line or line.startswith("<!--"):
            continue
        match = TASK_HEADER.match(line)
        if match:
            current = {
                "status": match.group("status"),
                "title": match.group("title"),
                "line": str(lineno),
            }
            entries[match.group("id")] = current
            continue
        if current is None:
            continue
        for field in REQUIRED_FIELDS:
            if line.startswith(field):
                current[field] = line[len(field):].strip()
                break
    for task_id, entry in entries.items():
        for field in REQUIRED_FIELDS:
            if field not in entry:
                problems.append(f"{task_id}: missing required field {field}")
        if "Level:" in entry and not LEVEL.match(entry["Level:"]):
            problems.append(f"{task_id}: bad Level {entry['Level:']!r}, expected L<number>")
        if "Size:" in entry and entry["Size:"] not in SIZE:
            problems.append(f"{task_id}: bad Size {entry['Size:']!r}, expected one of small/medium/large")
        if "Output:" in entry and not OUTPUT.match(entry["Output:"]):
            problems.append(f"{task_id}: bad Output {entry['Output:']!r}")
        if "Generated:" in entry and not DATE.match(entry["Generated:"]):
            problems.append(f"{task_id}: bad Generated date {entry['Generated:']!r}, expected YYYY-MM-DD")
    return entries, problems


def concept_slug(title: str) -> str:
    """Derive the concepts folder slug from the part before the colon."""
    name = title.split(":")[0]
    slug = re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")
    return slug


def check_manifest_sync(
    kit_root: Path, manifest: dict, entries: dict[str, dict[str, str]]
) -> tuple[list[str], list[str]]:
    """Cross-check manifest queues against parsed entries and completed ids."""
    errors: list[str] = []
    notices: list[str] = []
    queues = manifest.get("queues", {})
    completed = set(manifest.get("completed", {}).get("ids", []))
    for task_id in queues.get("active", []):
        if task_id not in entries:
            errors.append(f"{task_id}: queued as active in manifest but missing from task list")
        elif task_id in completed:
            errors.append(f"{task_id}: queued as active in manifest but already in completed index")
    for task_id, entry in entries.items():
        if entry["status"] in OPEN_STATUSES and task_id in completed:
            errors.append(f"{task_id}: still open in task list but already in completed index")
        if entry["status"] in OPEN_STATUSES and task_id not in queues.get("active", []):
            notices.append(f"{task_id}: open in task list but absent from manifest queue snapshot")
        if entry["status"] not in OPEN_STATUSES:
            notices.append(f"{task_id}: status [{entry['status']}] needs a human decision, skipped")
    notices.append("backlog queue not cross-checked: backlog section carries no parseable entries")
    tools = manifest.get("tools", {})
    for key, tool in tools.items():
        primer = tool.get("primer")
        if tool.get("has_primer") and primer:
            if not (kit_root / primer).is_file():
                errors.append(f"primer:{key}: manifest flags a primer but {primer} is missing on disk")
    return errors, notices


def check_progression(
    kit_root: Path, entries: dict[str, dict[str, str]]
) -> tuple[list[str], list[str]]:
    """Resolve each open entry's id prefix to a folder under the kit root."""
    errors: list[str] = []
    notices: list[str] = []
    for task_id, entry in entries.items():
        if entry["status"] not in OPEN_STATUSES:
            continue
        match = TASK_ID.match(task_id)
        if not match:
            errors.append(f"{task_id}: id does not match <prefix>-<number> shape")
            continue
        prefix = match.group(1)
        if prefix in OUT_OF_SCOPE_PREFIXES:
            notices.append(f"{task_id}: prefix {prefix!r} has no kit folder, skipped")
            continue
        if prefix == "con":
            target = kit_root / "docs" / "concepts" / concept_slug(entry["title"])
        else:
            target = kit_root / prefix
        if not target.is_dir():
            errors.append(f"{task_id}: no folder {target} under kit root for id prefix")
    return errors, notices


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Check task schema, manifest sync, and level progression."
    )
    parser.add_argument("--kit-root", default=".", help="Path to the kit checkout root.")
    parser.add_argument("--tasks-file", default=None, help="Path to the task list file.")
    parser.add_argument("--manifest", default=None, help="Path to the manifest JSON file.")
    args = parser.parse_args(argv)
    kit_root = Path(args.kit_root)

    if not kit_root.is_dir():
        print(f"error: kit root not found: {kit_root}", file=sys.stderr)
        return 2

    errors: list[str] = []
    notices: list[str] = []
    entries: dict[str, dict[str, str]] = {}

    if args.tasks_file is None:
        notices.append("no task list given, schema checks skipped")
    else:
        tasks_path = Path(args.tasks_file)
        if not tasks_path.is_file():
            print(f"error: task list not found: {tasks_path}", file=sys.stderr)
            return 2
        entries, schema_problems = parse_active_tasks(tasks_path.read_text())
        errors.extend(schema_problems)
        if not entries:
            errors.append(f"no task entries parsed from {tasks_path}")

    manifest: dict = {}
    if args.manifest is None:
        notices.append("no manifest given, sync checks skipped")
    else:
        manifest_path = Path(args.manifest)
        if not manifest_path.is_file():
            print(f"error: manifest not found: {manifest_path}", file=sys.stderr)
            return 2
        try:
            manifest = json.loads(manifest_path.read_text())
        except json.JSONDecodeError as exc:
            print(f"error: manifest is not valid JSON: {exc}", file=sys.stderr)
            return 2

    if manifest and entries:
        sync_errors, sync_notices = check_manifest_sync(kit_root, manifest, entries)
        errors.extend(sync_errors)
        notices.extend(sync_notices)
    if entries:
        prog_errors, prog_notices = check_progression(kit_root, entries)
        errors.extend(prog_errors)
        notices.extend(prog_notices)

    for line in notices:
        print(f"notice: {line}")
    for line in errors:
        print(f"FAIL: {line}", file=sys.stderr)

    if errors:
        print(f"found {len(errors)} error(s) and {len(notices)} notice(s)", file=sys.stderr)
        return 1
    if notices:
        print(f"ok: {len(notices)} notice(s), no blocking errors")
    else:
        print("ok: tasks, manifest, and kit tree agree")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
