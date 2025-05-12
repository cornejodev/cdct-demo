import json
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer
import requests
import time

# === 1. Contract Definition ===
contract = {
    "request": {"method": "GET", "path": "/user/123"},
    "response": {"status": 200, "body": {"id": 123, "name": "Alice"}},
}


# === 2. Provider Implementation ===
class ProviderHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/user/123":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"id": 123, "name": "Alice"}).encode())
        else:
            self.send_response(404)
            self.end_headers()


def run_provider():
    server = HTTPServer(("localhost", 8001), ProviderHandler)
    print("Provider running on http://localhost:8001")
    server.serve_forever()


# === 3. Consumer Test ===
def consumer_test():
    req = contract["request"]
    expected = contract["response"]

    url = f"http://localhost:8001{req['path']}"
    print(f"Consumer sending request to: {url}")
    res = requests.request(method=req["method"], url=url)

    assert res.status_code == expected["status"], "Status code mismatch"
    assert res.json() == expected["body"], "Response body mismatch"
    print("Contract test passed!")


# === Main Execution ===
if __name__ == "__main__":
    # Start provider in background thread
    t = threading.Thread(target=run_provider, daemon=True)
    t.start()

    # Give server a second to start
    time.sleep(1)

    # Run consumer test
    try:
        consumer_test()
    except AssertionError as e:
        print(f"Contract test failed: {e}")
