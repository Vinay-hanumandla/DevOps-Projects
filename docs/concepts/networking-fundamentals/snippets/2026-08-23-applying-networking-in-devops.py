# last_verified: 2026-08-23 · networking-fundamentals n/a
# Practicing networking in DevOps — checking service endpoints and validating network config.

import socket
import urllib.request


def check_tcp_endpoint(host, port, timeout=3):
    """Check if a TCP endpoint is reachable."""
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return {"host": host, "port": port, "reachable": True}
    except (socket.timeout, ConnectionRefusedError, OSError) as e:
        return {"host": host, "port": port, "reachable": False, "error": str(e)}


def check_http_endpoint(url, timeout=5):
    """Check if an HTTP endpoint returns a success status."""
    try:
        req = urllib.request.Request(url, method="GET")
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return {"url": url, "status": resp.status, "ok": resp.status < 400}
    except Exception as e:
        return {"url": url, "status": None, "ok": False, "error": str(e)}


def resolve_hostname(hostname):
    """Resolve a hostname to IP addresses."""
    try:
        results = socket.getaddrinfo(hostname, None)
        ips = list(set(r[4][0] for r in results))
        return {"hostname": hostname, "ips": ips}
    except socket.gaierror as e:
        return {"hostname": hostname, "ips": [], "error": str(e)}


# Common DevOps service endpoints to validate
services = [
    ("localhost", 22),
    ("localhost", 80),
    ("localhost", 443),
    ("localhost", 8080),
]

endpoints = [
    "http://localhost:80/health",
    "http://localhost:8080/api/status",
]

hostnames = [
    "github.com",
    "registry-1.docker.io",
]

print("=== TCP Endpoint Checks ===")
for host, port in services:
    result = check_tcp_endpoint(host, port)
    status = "UP" if result["reachable"] else "DOWN"
    print(f"  {host}:{port} — {status}")

print("\n=== HTTP Endpoint Checks ===")
for url in endpoints:
    result = check_http_endpoint(url)
    status = f"HTTP {result['status']}" if result["ok"] else "FAIL"
    print(f"  {url} — {status}")

print("\n=== DNS Resolution ===")
for hostname in hostnames:
    result = resolve_hostname(hostname)
    if result["ips"]:
        print(f"  {hostname} → {', '.join(result['ips'])}")
    else:
        print(f"  {hostname} → FAILED ({result.get('error', 'unknown')})")
