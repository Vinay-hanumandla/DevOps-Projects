# last_verified: 2026-08-07 · observability-monitoring-concepts n/a
# I wrote this to practice turning raw request logs into golden-signal metrics.
# The RED method (Rate, Errors, Duration) is what I want to extract from logs
# before I can dashboard or alert on anything.

import re
from datetime import datetime, timedelta

sample_logs = [
    "2026-08-07 10:00:01 GET /api/users 200 0.042",
    "2026-08-07 10:00:02 POST /api/orders 201 0.120",
    "2026-08-07 10:00:03 GET /api/users 500 0.005",
    "2026-08-07 10:00:04 GET /api/users 200 0.038",
    "2026-08-07 10:00:05 GET /api/users 503 0.002",
]

# Parse status codes from sample log lines
status_pattern = re.compile(r"\s(\d{3})\s")
statuses = [
    int(status_pattern.search(line).group(1))
    for line in sample_logs
    if status_pattern.search(line)
]

# Golden signal: error rate
total = len(statuses)
errors = sum(1 for s in statuses if s >= 500)
error_rate = (errors / total) * 100

print(f"Total requests: {total}")
print(f"Error requests: {errors}")
print(f"Error rate:     {error_rate:.1f}%")

# Mimic what an AlertManager rule would evaluate
threshold = 5.0
if error_rate > threshold:
    print(f"ALERT: error rate {error_rate:.1f}% exceeds {threshold}% threshold")
else:
    print("OK: error rate within threshold")
