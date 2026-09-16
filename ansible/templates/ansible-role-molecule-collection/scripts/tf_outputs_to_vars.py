# last_verified: 2026-09-16 · ansible n/a
# Converts a `terraform output -json` artifact into the Ansible handoff vars
# file ansible/group_vars/all/terraform_outputs.yml.
# Usage: tf_outputs_to_vars.py <tf-outputs.json> <destination.yml>
# Only the documented handoff keys are carried over; everything else is ignored
# so Terraform-side renames cannot silently reshape role inputs.
"""Map Terraform JSON outputs onto the Ansible handoff vars file."""
import json
import sys

HANDOFF_KEYS = ("vpc_id", "db_endpoint", "redis_endpoint", "s3_bucket", "lb_dns")


def main(src: str, dest: str) -> None:
    with open(src, encoding="utf-8") as fh:
        outputs = json.load(fh)
    lines = ["---", "# Auto-generated from `terraform output -json`. Do not edit by hand."]
    for key in HANDOFF_KEYS:
        entry = outputs.get(key, {})
        value = entry.get("value", "") if isinstance(entry, dict) else entry
        lines.append(f"{key}: {json.dumps(value)}")
    with open(dest, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
