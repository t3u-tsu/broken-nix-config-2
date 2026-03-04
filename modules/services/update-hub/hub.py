import http.server
import json
import os
import sys
import urllib.request
import threading
import argparse
import logging
import subprocess

DATA_FILE = "/var/lib/update-hub/status.json"

# Setup logging
logger = logging.getLogger("update-hub")
logger.setLevel(logging.INFO)
stdout_handler = logging.StreamHandler(sys.stdout)
stdout_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logger.addHandler(stdout_handler)

# Global configuration
MY_HOSTNAME = None

def load_status():
    if os.path.exists(DATA_FILE):
        try:
            with open(DATA_FILE, 'r') as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"Failed to load status file: {e}")
    return {"latest_commit": None, "hosts": {}}

def save_status(status):
    try:
        os.makedirs(os.path.dirname(DATA_FILE), exist_ok=True)
        with open(DATA_FILE, 'w') as f:
            json.dump(status, f, indent=2)
    except Exception as e:
        logger.error(f"Failed to save status file: {e}")

def trigger_local_update():
    try:
        logger.info("Triggering local update via systemctl...")
        subprocess.Popen(['systemctl', 'start', 'nixos-auto-update.service'])
    except Exception as e:
        logger.error(f"Failed to trigger local update: {e}")

def notify_hosts(status, producer_hostname=None):
    for hostname, info in status.get("hosts", {}).items():
        # Producer 自身への通知はスキップ
        if producer_hostname and hostname == producer_hostname:
            logger.info(f"Skipping notification for producer: {hostname}")
            continue

        # 自分自身 (Hub) への通知はローカルで実行
        if hostname == MY_HOSTNAME:
            trigger_local_update()
            continue

        # それ以外は Webhook 経由で通知
        ip = info.get("ip")
        if not ip:
            logger.warning(f"No IP recorded for host: {hostname}")
            continue
            
        try:
            url = f"http://{ip}:8081/trigger-update"
            logger.info(f"Notifying remote host {hostname} at {url}...")
            req = urllib.request.Request(url, method='POST')
            with urllib.request.urlopen(req, timeout=5) as f:
                pass
            logger.info(f"Successfully notified {hostname}")
        except Exception as e:
            logger.error(f"Failed to notify {hostname}: {e}")

class HubHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        logger.info("%s - - [%s] %s" % (self.client_address[0], self.log_date_time_string(), format%args))

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
        try:
            content_length = int(self.headers['Content-Length'])
            data = json.loads(self.rfile.read(content_length).decode())
            status = load_status()

            if self.path == "/producer/done":
                commit = data.get("commit")
                producer = data.get("host")
                logger.info(f"Received producer update: {commit} from {producer}")
                status["latest_commit"] = commit
                save_status(status)
                self.send_response(200)
                self.end_headers()
                threading.Thread(target=notify_hosts, args=(status, producer)).start()

            elif self.path == "/consumer/reported":
                hostname = data.get("host")
                commit = data.get("commit")
                client_ip = self.client_address[0]
                logger.info(f"Received report from {hostname} ({client_ip}): {commit}")
                if hostname:
                    status["hosts"][hostname] = {
                        "commit": commit,
                        "last_update": data.get("timestamp"),
                        "ip": client_ip # 動的に送信元 IP を記録
                    }
                    save_status(status)
                self.send_response(200)
                self.end_headers()
            else:
                self.send_response(404)
                self.end_headers()
        except Exception as e:
            logger.error(f"Error processing POST request: {e}")
            self.send_response(500)
            self.end_headers()

def main():
    parser = argparse.ArgumentParser(description='NixOS Update Hub')
    parser.add_argument('--port', type=int, default=8080)
    parser.add_argument('--hostname', required=True, help='My own hostname')
    parser.add_argument('--log-file')
    args = parser.parse_args()

    global MY_HOSTNAME
    MY_HOSTNAME = args.hostname

    if args.log_file:
        file_handler = logging.FileHandler(args.log_file)
        file_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
        logger.addHandler(file_handler)

    server = http.server.HTTPServer(('0.0.0.0', args.port), HubHandler)
    logger.info(f"Starting update-hub on {MY_HOSTNAME}:{args.port} (Dynamic Discovery enabled)")
    server.serve_forever()

if __name__ == "__main__":
    main()