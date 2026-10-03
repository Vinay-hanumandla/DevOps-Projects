# last_verified: 2026-10-03 · python 3.13.5
"""Migration patterns toward recent-Python idioms: match, except*, TaskGroup.

Purpose: show the three replacements side by side so an older codebase can
be migrated mechanically — mapping dispatch moves to ``match``, grouped
fan-out failures move to ``except*``, and manual task bookkeeping moves to
``asyncio.TaskGroup``.

When to use: when modernising error handling or dispatch logic that was
written with long if/elif chains, bare ``except Exception`` blocks, and
hand-rolled ``asyncio.create_task`` + ``asyncio.gather`` wiring.

Run: python migration-match-except-star-taskgroup.py
Stdlib only: asyncio. Exits non-zero if any self-check fails.
"""

import asyncio

# --- Pattern 1: match replaces an if/elif dispatch chain -------------------


def handle_event(event: dict) -> str:
    """Route an event mapping to a handler name via structural matching."""
    match event:
        case {"type": "deploy", "env": "prod", "version": version}:
            return f"deploy-prod:{version}"
        case {"type": "deploy", "env": env}:
            return f"deploy-{env}"
        case {"type": "rollback", "to": target}:
            return f"rollback:{target}"
        case {"type": kind}:
            return f"unknown:{kind}"
        case _:
            return "malformed"


# --- Pattern 2 + 3: TaskGroup fan-out with except* handling ----------------

RESULTS: dict[str, str] = {}


async def fetch(name: str, fail_as: str | None = None) -> None:
    """Simulated fetch: sleeps briefly, stores the result or raises by name.

    Successes are recorded inside the task itself so they survive even when
    a sibling task fails and the group raises an ExceptionGroup.
    """
    await asyncio.sleep(0.01)
    if fail_as == "connection":
        raise ConnectionError(f"{name} unreachable")
    if fail_as == "value":
        raise ValueError(f"{name} bad payload")
    RESULTS[name] = f"{name}-ok"


async def collect(specs: list[tuple[str, str | None]]) -> None:
    """Run all fetches concurrently inside a TaskGroup."""
    async with asyncio.TaskGroup() as group:
        for name, fail in specs:
            group.create_task(fetch(name, fail))


def summarize(specs: list[tuple[str, str | None]]) -> dict[str, list[str]]:
    """Collect specs, bucketing per-kind failures via except* handlers."""
    outcome: dict[str, list[str]] = {"ok": [], "conn": [], "bad": []}
    try:
        asyncio.run(collect(specs))
    except* ConnectionError as eg:
        outcome["conn"] = [str(e) for e in eg.exceptions]
    except* ValueError as eg:
        outcome["bad"] = [str(e) for e in eg.exceptions]
    outcome["ok"] = sorted(RESULTS.values())
    RESULTS.clear()
    return outcome


def main() -> None:
    # match dispatch checks (replaces the old if/elif chain on event["type"])
    assert handle_event({"type": "deploy", "env": "prod", "version": "v3"}) == "deploy-prod:v3"
    assert handle_event({"type": "deploy", "env": "stage"}) == "deploy-stage"
    assert handle_event({"type": "rollback", "to": "v2"}) == "rollback:v2"
    assert handle_event({"type": "ping"}) == "unknown:ping"
    assert handle_event({}) == "malformed"

    # all-success fan-out: every result lands in RESULTS, no exception escapes
    good = summarize([("a", None), ("b", None), ("c", None)])
    assert good == {"ok": ["a-ok", "b-ok", "c-ok"], "conn": [], "bad": []}, good

    # mixed fan-out: each failure kind is caught by its own except* branch
    mixed = summarize([("a", None), ("db", "connection"), ("cfg", "value")])
    assert mixed["ok"] == ["a-ok"], mixed
    assert len(mixed["conn"]) == 1 and "db unreachable" in mixed["conn"][0], mixed
    assert len(mixed["bad"]) == 1 and "cfg bad payload" in mixed["bad"][0], mixed

    print("match dispatch: 5 checks passed")
    print(f"all-success fan-out: {good['ok']}")
    print(f"mixed fan-out: ok={mixed['ok']} conn={len(mixed['conn'])} bad={len(mixed['bad'])}")


if __name__ == "__main__":
    main()
