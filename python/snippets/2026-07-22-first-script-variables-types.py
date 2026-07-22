# last_verified: 2026-07-22 · Python n/a

# my_first_script.py — variables, types, and a print
# Running this confirms basic Python syntax works in my environment.

service_name = "nginx"
container_port = 80
is_running = True
replica_count = 3

print(f"Service:   {service_name}")
print(f"Port:      {container_port}  (type: {type(container_port).__name__})")
print(f"Running:   {is_running}  (type: {type(is_running).__name__})")
print(f"Replicas:  {replica_count}")

mixed = [1, "two", 3.0, True]
for item in mixed:
    print(f"  List item: {item}  ->  {type(item).__name__}")
