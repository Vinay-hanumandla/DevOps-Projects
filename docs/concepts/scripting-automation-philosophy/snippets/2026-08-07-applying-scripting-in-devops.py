# last_verified: 2026-08-07 · scripting-automation-philosophy n/a
# I wrote this to practice applying scripting in DevOps: reading a simple
# host inventory file and turning each entry into a readiness check.
# It shows the scripting habit of "extract the repeatable logic into a
# function and loop over it" instead of copy-pasting for every host.

def parse_inventory(path):
    """Read a 'host role env' inventory into a list of dicts."""
    hosts = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split()
            if len(parts) == 3:
                host, role, env = parts
                hosts.append({"host": host, "role": role, "env": env})
    return hosts

def readiness_check(host_info):
    """Say what deploy action a host would get (role + env based)."""
    role = host_info["role"]
    env = host_info["env"]
    if env == "prod":
        return f"  {host_info['host']} ({role}): blue/green deploy"
    return f"  {host_info['host']} ({role}): rolling restart"

# --- demo with a temp inventory file ---
demo_lines = [
    "# host role env",
    "web-01 web prod",
    "web-02 web staging",
    "db-01 db prod",
]
demo_path = "/tmp/demo_inventory.txt"
with open(demo_path, "w") as f:
    f.write("\n".join(demo_lines) + "\n")

print("=== Applying scripting in DevOps: inventory readiness ===")
for entry in parse_inventory(demo_path):
    print(readiness_check(entry))
print("Done — one function, reused for every host.")
