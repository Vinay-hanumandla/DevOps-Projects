# last_verified: 2026-09-17 · docker n/a
# Minimal stdlib-only API so the scaffold runs without extra installs.
# GET /health -> 200 {"status": "ok"} (used by the Compose healthcheck).
# GET /        -> 200 greeting. Reads DB_* / CACHE_URL env for info only.
import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(os.environ.get("API_PORT", "8000"))


class Handler(BaseHTTPRequestHandler):
    def _send(self, code, payload):
        body = json.dumps(payload).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/health":
            self._send(200, {"status": "ok"})
        elif self.path == "/":
            self._send(200, {
                "service": "api",
                "db_host": os.environ.get("DB_HOST", "db"),
                "cache_url": os.environ.get("CACHE_URL", "redis://cache:6379"),
            })
        else:
            self._send(404, {"error": "not found"})

    def log_message(self, *args):  # keep container logs quiet
        pass


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
