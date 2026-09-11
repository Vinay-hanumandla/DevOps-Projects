# last_verified: 2026-09-10 · kubernetes n/a
"""
kubectl-pod-metrics.py

A custom kubectl-style plugin that lists pods in a given namespace
(or all namespaces) with their current CPU and memory usage, pulled
from the Metrics API (metrics.k8s.io/v1beta1).

Usage:
    python3 kubectl-pod-metrics.py [namespace]

Requires:
    pip install kubernetes
    A valid kubeconfig (default or explicit via KUBECONFIG env var).
"""

import sys
from kubernetes import client, config


def format_cpu(millicores: int) -> str:
    """Convert CPU millicores to a human-friendly string."""
    if millicores >= 1000:
        return f"{millicores / 1000:.1f}c"
    return f"{millicores}m"


def format_memory(kibibytes: int) -> str:
    """Convert memory Ki to a human-friendly string."""
    if kibibytes >= 1048576:
        return f"{kibibytes / 1048576:.1f}Gi"
    if kibibytes >= 1024:
        return f"{kibibytes / 1024:.0f}Mi"
    return f"{kibibytes}Ki"


def get_pod_metrics(namespace: str = "default") -> list[dict]:
    """Query the Metrics API and return pod-level CPU/memory usage."""
    try:
        config.load_kube_config()
    except config.ConfigException:
        config.load_incluster_config()

    metrics_api = client.CustomObjectsApi()
    group = "metrics.k8s.io"
    version = "v1beta1"

    if namespace == "--all-namespaces" or namespace == "-A":
        resources = metrics_api.list_cluster_custom_object(
            group=group, version=version, plural="pods"
        )
        items = resources.get("items", [])
    else:
        resources = metrics_api.list_namespaced_custom_object(
            group=group, version=version, plural="pods", namespace=namespace
        )
        items = resources.get("items", [])

    results = []
    for item in items:
        name = item["metadata"]["name"]
        ns = item["metadata"]["namespace"]
        containers = item.get("containers", [])

        total_cpu = sum(
            _parse_cpu(c["usage"].get("cpu", "0")) for c in containers
        )
        total_mem = sum(
            _parse_memory(c["usage"].get("memory", "0")) for c in containers
        )

        results.append({
            "namespace": ns,
            "name": name,
            "cpu": format_cpu(total_cpu),
            "memory": format_memory(total_mem),
        })

    return results


def _parse_cpu(value: str) -> int:
    """Parse a Kubernetes CPU value (e.g. '250m', '1') into millicores."""
    value = value.strip()
    if value.endswith("n"):
        return int(value[:-1]) // 1_000_000
    if value.endswith("m"):
        return int(value[:-1])
    return int(float(value) * 1000)


def _parse_memory(value: str) -> int:
    """Parse a Kubernetes memory value (e.g. '128Mi', '1Gi') into Ki."""
    value = value.strip()
    if value.endswith("Ki"):
        return int(value[:-2])
    if value.endswith("Mi"):
        return int(value[:-2]) * 1024
    if value.endswith("Gi"):
        return int(value[:-2]) * 1048576
    if value.endswith("Ti"):
        return int(value[:-2]) * 1073741824
    return int(value)


def main() -> None:
    namespace = sys.argv[1] if len(sys.argv) > 1 else "default"
    pods = get_pod_metrics(namespace)

    if not pods:
        print(f"No pod metrics found in namespace '{namespace}'.")
        print("Is the Metrics Server installed? Check: kubectl get apiservice v1beta1.metrics.k8s.io")
        return

    # Print a table
    header = f"{'NAMESPACE':<20} {'POD':<45} {'CPU':<10} {'MEMORY':<10}"
    print(header)
    print("-" * len(header))
    for p in sorted(pods, key=lambda x: (x["namespace"], x["name"])):
        print(f"{p['namespace']:<20} {p['name']:<45} {p['cpu']:<10} {p['memory']:<10}")


if __name__ == "__main__":
    main()
