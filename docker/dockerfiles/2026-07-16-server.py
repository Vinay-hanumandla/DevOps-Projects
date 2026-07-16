# last_verified: 2026-07-16 · Docker 29.2.0
import http.server


# Handler that always responds with a plain-text greeting.
# Using http.server.SimpleHTTPRequestHandler because it's built-in — no
# extra dependencies to install in the container.
class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(b"Hello from the non-root container!\n")


if __name__ == "__main__":
    # Bind to 0.0.0.0 so the container accepts connections from outside itself
    server = http.server.HTTPServer(("0.0.0.0", 8000), Handler)
    server.serve_forever()
