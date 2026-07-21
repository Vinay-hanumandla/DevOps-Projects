# last_verified: 2026-07-21 · infrastructure-as-code-principles L2
"""
Compare a declarative desired-state dict against an actual-state dict
and print the differences.

Declarative IaC means "I declare what I want, and the tool figures out
how to get there" (vs. imperative scripts that list every step).
Terraform, Ansible, and Kubernetes all work this way. The core operation
is a three-way diff: desired vs actual creates a plan of what to
create, update, or delete.
"""


def diff_state(desired: dict, actual: dict) -> dict:
    changes = {"create": {}, "update": {}, "delete": {}}

    # Keys in desired but not in actual — need to create
    for key in desired:
        if key not in actual:
            changes["create"][key] = desired[key]

    # Keys in actual but not in desired — need to delete
    for key in actual:
        if key not in desired:
            changes["delete"][key] = actual[key]

    # Keys in both but values differ — need to update
    for key in desired:
        if key in actual and desired[key] != actual[key]:
            changes["update"][key] = {"from": actual[key], "to": desired[key]}

    return changes


# Example: managing a simple firewall rule set
desired_firewall = {
    "allow-ssh":   {"port": 22,  "proto": "tcp", "source": "10.0.0.0/8"},
    "allow-http":  {"port": 80,  "proto": "tcp", "source": "0.0.0.0/0"},
    "allow-https": {"port": 443, "proto": "tcp", "source": "0.0.0.0/0"},
}

actual_firewall = {
    "allow-ssh":   {"port": 22,  "proto": "tcp", "source": "10.0.0.0/8"},
    "allow-http":  {"port": 8080, "proto": "tcp", "source": "0.0.0.0/0"},
    "allow-dns":   {"port": 53,  "proto": "udp", "source": "10.0.0.0/8"},
}

changes = diff_state(desired_firewall, actual_firewall)

print("=== Declarative State Diff ===")
print(f"\nTo CREATE ({len(changes['create'])}):")
for k, v in changes["create"].items():
    print(f"  + {k}: {v}")

print(f"\nTo UPDATE ({len(changes['update'])}):")
for k, v in changes["update"].items():
    print(f"  ~ {k}: {v['from']} \u2192 {v['to']}")

print(f"\nTo DELETE ({len(changes['delete'])}):")
for k, v in changes["delete"].items():
    print(f"  - {k}: {v}")
