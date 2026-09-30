# last_verified: 2026-09-30 · docker n/a
# Minimal stdlib-only API so the scaffold runs without extra installs.
# GET /health -> 200 {"status": "ok"} (used by Compose and image HEALTHCHECK).
# GET /        -> 200 greeting with peer host info.
import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(os.environ.get("API_PORT", "8000"))


def read_secret(path, default=""):
    try:
        with open(path) as f:
            return f.read().strip()
    except OSError:
        return default


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
