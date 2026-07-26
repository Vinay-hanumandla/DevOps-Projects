# last_verified: 2026-07-26 · networking-fundamentals n/a
# I wrote this script to practice socket connections — checking if common ports are open locally.

import socket


def check_port(host, port):
    """Check if a TCP port is open on the given host."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(2)
        result = s.connect_ex((host, port))
        if result == 0:
            print(f"Port {port} on {host} is open")
        else:
            print(f"Port {port} on {host} is closed")


check_port("localhost", 22)
check_port("localhost", 80)