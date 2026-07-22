# last_verified: 2026-07-22 · n/a
"""
Compare desired vs actual state and report what needs creating, updating,
or deleting.

Declarative IaC means I describe the target state and let the tool figure
out how to get there — the core operation is a diff between desired
and actual state. This is how Terraform, Ansible, and Kubernetes work.
"""


def deep_diff(desired: dict, actual: dict, path: str = "") -> dict:
    changes = {"create": {}, "update": {}, "delete": {}}

    for key in desired:
        key_path = f"{path}.{key}" if path else key
        if key not in actual:
            changes["create"][key_path] = desired[key]
        elif isinstance(desired[key], dict) and isinstance(actual.get(key), dict):
            sub = deep_diff(desired[key], actual[key], key_path)
            for k in ("create", "update", "delete"):
                changes[k].update(sub[k])
        elif desired[key] != actual[key]:
            changes["update"][key_path] = {"from": actual[key], "to": desired[key]}

    for key in actual:
        key_path = f"{path}.{key}" if path else key
        if key not in desired:
            changes["delete"][key_path] = actual[key]

    return changes


# Example: managing firewall rules for a small web app
desired = {
    "rules": {
        "allow-ssh":   {"port": 22,  "cidr": "10.0.0.0/8"},
        "allow-http":  {"port": 80,  "cidr": "0.0.0.0/0"},
        "allow-https": {"port": 443, "cidr": "0.0.0.0/0"},
    },
    "dns": "10.0.0.53",
}

actual = {
    "rules": {
        "allow-ssh":  {"port": 22,  "cidr": "10.0.0.0/8"},
        "allow-http": {"port": 8080, "cidr": "0.0.0.0/0"},
        "allow-dns":  {"port": 53,  "cidr": "10.0.0.0/8"},
    },
    "dns": "10.0.0.53",
}

changes = deep_diff(desired, actual)

print("=== IaC Declarative State Diff ===")
for action in ("create", "update", "delete"):
    items = changes[action]
    if not items:
        continue
    symbol = {"create": "+", "update": "~", "delete": "-"}[action]
    print(f"\n  {symbol} {action.upper()} ({len(items)})")
    for k, v in items.items():
        if action == "update":
            print(f"     {k}: {v['from']} -> {v['to']}")
        else:
            print(f"     {k}: {v}")
