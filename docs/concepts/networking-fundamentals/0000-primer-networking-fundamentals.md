---
last_verified: 2026-07-19
tool_version: n/a
---

# Networking Fundamentals — quick primer

> First-day notes on computer networking. What it is, why it matters, and the key ideas to know.

## What is it?

Networking is how computers talk to each other. When a browser loads a website, a Docker container pulls an image, or a monitoring agent sends a metric — that's networking in action. At its simplest, networking is about sending data from point A to point B and knowing what to do with it when it arrives.

Think of it like a postal system. Every computer has an address (IP address). Data is broken into envelopes (packets). Protocols are the rules about how envelopes are addressed, sorted, and delivered. TCP is like certified mail — it confirms delivery and re-sends if lost. UDP is like a postcard — faster but no guarantee it arrives.

## Why does it matter for DevOps?

DevOps engineers manage connections between services constantly. A container needs to reach a database. A CI/CD runner needs to pull code from GitHub. A Kubernetes pod needs to talk to another pod across nodes. When something doesn't connect, you need to debug it — and that means understanding IP addresses, ports, DNS, firewalls, and load balancers.

You don't need to be a network engineer who can configure BGP. But you do need to know why `curl http://localhost:8080` works but `curl http://service-b:8080` doesn't, or what "connection refused" really means.

## Key terminology

- **IP address** — A unique identifier for a device on a network. IPv4 looks like `192.168.1.10`; IPv6 looks like `2001:db8::1`. Every device on a network needs one.
- **Port** — A numbered channel on a device that a specific service uses. Port 80 = HTTP, 443 = HTTPS, 22 = SSH, 5432 = PostgreSQL. Combined with an IP: `192.168.1.10:5432` means "that database server, port 5432".
- **DNS (Domain Name System)** — The phonebook of the internet. It maps human-readable names like `google.com` to IP addresses like `142.250.80.46`. Without DNS, you'd type IP addresses for everything.
- **TCP vs UDP** — TCP is reliable and ordered (web traffic, SSH). UDP is faster but lossy (video streaming, DNS queries). Your choice depends on whether you need every byte or just speed.
- **HTTP/HTTPS** — The protocol browsers and APIs use. HTTP is plain text; HTTPS adds encryption via TLS. Status codes: 200 (OK), 404 (not found), 500 (server error).
- **Firewall** — A filter that allows or blocks traffic based on IP, port, or protocol. `iptables` on Linux, security groups in AWS. The most common first networking problem: "I can reach the server but the firewall blocks the port."
- **NAT (Network Address Translation)** — Allows multiple devices on a private network (like `192.168.x.x`) to share a single public IP. Your home router does this.
- **Latency vs bandwidth** — Latency is the delay (how long a packet takes to arrive). Bandwidth is throughput (how much data can be sent per second). A fast network has low latency and high bandwidth.
- **Load balancer** — A tool that distributes incoming traffic across multiple servers. A single service behind a load balancer gets a single DNS name; the balancer routes requests to healthy backend instances.

## A concrete example

```bash
# Check if a service is reachable on a specific port
nc -zv google.com 443
# -z = scan without sending data, -v = verbose
# Output: "Connection to google.com port 443 [tcp/https] succeeded!"

# Trace the route packets take to a destination
traceroute google.com
# Shows every router hop between you and google.com
```

The first command (`nc`) is how I test whether a port is open from my machine. The second (`traceroute`) shows the path traffic takes — useful when something is slow and I want to find where the delay is.

## How this connects to what's next

Networking is the foundation for understanding how Docker containers communicate (container networking), how Kubernetes connects pods across nodes (CNI plugins, services, ingress), and how monitoring tools like Prometheus scrape metrics from targets. Before you can secure or debug a distributed system, you need to understand how its pieces talk to each other.
