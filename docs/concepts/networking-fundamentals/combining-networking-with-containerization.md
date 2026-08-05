---
last_verified: 2026-08-05
tool_version: n/a
sources:
  - https://ortamarco.me/en/blog/complete-docker-guide-2026/
  - https://kodekloud.com/blog/docker-tutorial-for-beginners/
---

# Combining Networking with Containerization — container network models explained

> How Docker's network drivers map to the networking fundamentals (IP, ports, routing, DNS) and how containers talk to each other and the outside world.

## Purpose

This doc explains how container networking maps to the networking fundamentals covered in the networking-fundamentals primer. Every container gets its own isolated network namespace — a virtual network stack with its own loopback interface, IP addresses, routing table, and DNS resolver. Docker's network drivers decide how that namespace connects to the host and to other containers. Understanding the model helps when a container can't reach another container, can't resolve a hostname, or can't bind to a port.

## When to use

Use this reference when a containerized service fails to connect to another service, DNS resolution fails inside a container, or port mapping doesn't work as expected. This matters whenever containers need to communicate — within a host, across hosts, or with the outside world.

## Container network models

Docker provides network drivers that control how a container participates in the network:

- **Bridge** (default) — each container gets its own network namespace connected to a virtual bridge on the host. Containers on the same bridge can reach each other by IP. The host performs NAT so containers can reach the internet; use `-p host_port:container_port` to publish a port to the outside.
- **Host** — the container skips its own namespace and binds directly to the host's network stack. No isolation; no port publishing needed because the container shares the host's IP and ports.
- **Overlay** — connects containers running on different Docker daemons (or Swarm nodes) over an encapsulated tunnel. This is how multi-host container clusters form a single logical network.
- **None** — the container gets a namespace with only a loopback interface. No external connectivity at all.

## How it connects to networking fundamentals

The four drivers build on the same primitives from the networking-fundamentals primer:

- **Network namespace** — like a virtual machine's virtual NIC, but lighter. It gives the container its own IP stack so port numbers and addresses don't collide with the host or other containers.
- **veth pairs** — a virtual ethernet cable with one end in the container's namespace and the other plugged into the host-side bridge. This is the physical-layer equivalent of a crossover cable, but virtual.
- **Routing** — each container has its own routing table. The bridge driver adds a default route through the host so outbound traffic leaves the container, traverses the host, and reaches the wider network via the host's default gateway.
- **DNS** — Docker embeds a DNS server that resolves container names to IPs on the same network. This is the same DNS resolution concept from the primer, but applied to container-to-container name lookups instead of public DNS.

## Steps

1. **Inspect the container's network namespace** with `docker inspect <container>` and look at the `NetworkSettings.Networks` key to see which driver and bridge it is attached to.
2. **Check IP and routing inside the container** by running `ip addr` and `ip route` inside the container namespace: `docker exec <container> ip route`.
3. **Verify port publishing** with `docker port <container>` — this shows which host ports map to which container ports. If a service isn't reachable, confirm the published port matches the container's listening port.
4. **Test connectivity** from another container on the same network: `docker run --network <network> --rm <image> ping <target_container>`.

## Verify

Run these from the host to confirm the model is working:

```bash
# Show which network mode a container is attached to
docker inspect -f '{{.HostConfig.NetworkMode}}' <container>

# Show allocated IP of the container
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container>

# Test that two containers on the same bridge can reach each other
docker run --rm --network <network> busybox ping -c 1 <container_ip>
```

A container that resolves DNS but can't ping another container is likely on the default bridge — move both to a user-defined network so Docker's embedded DNS can resolve names.

## Common errors

- **Published port already in use** — the host port is already bound by another process or container. Check with `docker port` and `ss -tlnp` to find the conflict, then pick a free host port.
- **DNS resolution fails inside container** — the container can reach the bridge but Docker's embedded DNS isn't resolving container names. Confirm both containers are on the same user-defined network, not the default bridge.
- **Container can't reach the internet** — outbound NAT isn't working. Check that the host has a default route and that iptables allows forwarding and masquerading.
- **Port published but connection refused** — the container's application isn't listening on the expected port. Confirm the `CMD` or `ENTRYPOINT` runs a long-running process, not a one-shot command.

## References

- Docker networking overview (drivers, bridge, host, overlay, none) — https://ortamarco.me/en/blog/complete-docker-guide-2026/
- Docker networking tutorials and port mapping — https://kodekloud.com/blog/docker-tutorial-for-beginners/