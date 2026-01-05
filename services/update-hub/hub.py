from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
import sys
import urllib.request
import threading

DATA_FILE = "/var/lib/update-hub/status.json"

def load_status():
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, 'r') as f:
            return json.load(f)
    return {"latest_commit": None, "hosts": {}}

def save_status(status):
    os.makedirs(os.path.dirname(DATA_FILE), exist_ok=True)
    with open(DATA_FILE, 'w') as f:
        json.dump(status, f, indent=2)

def notify_hosts(status):
    # wg1 ネットワーク内の固定マッピング
    IP_MAP = {
        "torii-chan": "10.0.1.1",
        "kagutsuchi-sama": "10.0.1.3",
        "shosoin-tan": "10.0.1.4",
        "sando-kun": "10.0.1.2",
    }
    
    for hostname in status.get("hosts", {}).keys():
        ip = IP_MAP.get(hostname)
        if not ip:
            continue
            
        try:
            url = f"http://{ip}:8081/trigger-update"
            print(f"Notifying {hostname} at {url}...")
            req = urllib.request.Request(url, method='POST')
            with urllib.request.urlopen(req, timeout=1) as f:
                pass
        except Exception as e:
            print(f"Failed to notify {hostname}: {e}")

class HubHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        status = load_status()
        if self.path == "/status":
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(status).encode())
        elif self.path == "/latest-commit":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(str(status.get("latest_commit", "")).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        data = json.loads(post_data.decode())
        status = load_status()

        if self.path == "/producer/done":
            status["latest_commit"] = data.get("commit")
            save_status(status)
            self.send_response(200)
            self.end_headers()
            threading.Thread(target=notify_hosts, args=(status,)).start()
        elif self.path == "/consumer/reported":
            hostname = data.get("host")
            if hostname:
                status["hosts"][hostname] = {
                    "commit": data.get("commit"),
                    "last_update": data.get("timestamp")
                }
                save_status(status)
            self.send_response(200)
            self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    server = HTTPServer(('0.0.0.0', port), HubHandler)
    print(f"Starting update-hub on port {port}...")
    server.serve_forever()
