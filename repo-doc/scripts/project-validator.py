# last_verified: 2026-10-08 · repo-doc n/a
"""Project validator: checks tool folder structure, primer existence, and level progression.

Purpose: give one runnable check that answers "does this kit checkout follow
the folder conventions" without eyeballing the tree. This is one way to do
it; the shell helper in the same directory covers a similar workflow, and
this script leans on the standard library only so it runs wherever Python
is available.

Steps: point it at the kit root; it walks each tool folder, verifies only
known category subdirectories are present, verifies each tool has exactly
one primer, and reports naming drift between dated journal files and
stable reference names.

Verify: run ``python3 repo-doc/scripts/project-validator.py --kit-root .``
from the kit root; exit 0 means all checks passed, exit 1 means at least
one problem was reported. The accompanying schema reference in
``repo-doc/configs/project-configuration-schema.yaml`` documents the
rules this script enforces.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

KNOWN_SUBDIRS = (
    "notes",
    "docs",
    "scripts",
    "snippets",
    "configs",
    "templates",
    "manifests",
    "dockerfiles",
    "notebooks",
)

DATE_PREFIX = re.compile(r"^\d{4}-\d{2}-\d{2}-")
PRIMER_GLOB = "0000-primer-*.md"

# Top-level entries that are never tool folders.
NON_TOOL_DIRS = {"docs", "00_index"}


def find_tool_dirs(kit_root: Path) -> list[Path]:
    """Return tool folders: directories holding at least one known subdir."""
    tools: list[Path] = []
    for entry in sorted(kit_root.iterdir()):
        if not entry.is_dir():
            continue
        if entry.name in NON_TOOL_DIRS or entry.name.startswith("."):
            continue
        if any((entry / sub).is_dir() for sub in KNOWN_SUBDIRS):
            tools.append(entry)
    return tools


def check_structure(tool: Path) -> list[str]:
    """Flag stray files and unknown subdirs directly under a tool folder."""
    problems: list[str] = []
    for entry in sorted(tool.iterdir()):
        if entry.is_file():
            problems.append(
                f"{tool.name}/{entry.name}: file sits at tool root, "
                "expected only category subdirs"
            )
        elif entry.is_dir() and entry.name not in KNOWN_SUBDIRS:
            problems.append(
                f"{tool.name}/{entry.name}: unknown subdir, "
                f"expected one of {', '.join(KNOWN_SUBDIRS)}"
            )
    return problems


def check_primer(tool: Path) -> list[str]:
    """Each tool keeps exactly one primer under notes/; anything else drifts."""
    problems: list[str] = []
    notes = tool / "notes"
    if not notes.is_dir():
        return [f"{tool.name}: missing notes/ directory, primer cannot exist"]
    primers = sorted(notes.glob(PRIMER_GLOB))
    if len(primers) == 0:
        problems.append(f"{tool.name}: no primer found (expected {PRIMER_GLOB})")
    elif len(primers) > 1:
        names = ", ".join(p.name for p in primers)
        problems.append(f"{tool.name}: multiple primers found: {names}")
    # A dated file must never carry the primer prefix.
    for entry in sorted(notes.iterdir()):
        if entry.is_file() and DATE_PREFIX.match(entry.name) and "primer" in entry.name:
            problems.append(
                f"{tool.name}/notes/{entry.name}: dated file must not "
                "use the primer name"
            )
    return problems


def check_level_progression(tool: Path) -> list[str]:
    """Report naming drift: primer placement and empty category dirs.

    The docs also suggest dated names for learner-stage files and stable
    kebab-case names for reference-stage files, but the boundary is a
    judgment call, so this check only warns about structural breaks
    (primer outside notes/, empty category dir) rather than grading names.
    """
    notices: list[str] = []
    for sub in KNOWN_SUBDIRS:
        subdir = tool / sub
        if not subdir.is_dir():
            continue
        # Primer files belong under notes/ only.
        if sub != "notes":
            stray = sorted(subdir.glob(PRIMER_GLOB))
            for entry in stray:
                notices.append(
                    f"{tool.name}/{sub}/{entry.name}: primer lives "
                    "outside notes/"
                )
        files = [p for p in subdir.iterdir() if p.is_file() or p.is_dir()]
        if not files:
            notices.append(f"{tool.name}/{sub}: directory exists but is empty")
    return notices


def validate(kit_root: Path) -> tuple[list[str], list[str]]:
    """Run all checks; return (errors, notices)."""
    if not kit_root.is_dir():
        raise SystemExit(f"kit root not found: {kit_root}")
    errors: list[str] = []
    notices: list[str] = []
    for tool in find_tool_dirs(kit_root):
        errors.extend(check_structure(tool))
        errors.extend(check_primer(tool))
        notices.extend(check_level_progression(tool))
    if not find_tool_dirs(kit_root):
        errors.append(f"no tool folders found under {kit_root}")
    return errors, notices


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Validate kit folder structure, primers, and naming drift."
    )
    parser.add_argument(
        "--kit-root",
        default=".",
        help="Path to the kit checkout root (default: current directory).",
    )
    args = parser.parse_args(argv)
    kit_root = Path(args.kit_root)

    try:
        errors, notices = validate(kit_root)
    except SystemExit as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    for line in notices:
        print(f"notice: {line}")
    for line in errors:
        print(f"FAIL: {line}", file=sys.stderr)

    if notices and not errors:
        print(f"ok: {len(notices)} notice(s), no blocking errors")
    elif not errors:
        print("ok: kit layout conforms")
    else:
        print(
            f"found {len(errors)} error(s) and {len(notices)} notice(s)",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
