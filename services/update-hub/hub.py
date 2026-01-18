from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
import sys
import urllib.request
import threading
import argparse
import logging

DATA_FILE = "/var/lib/update-hub/status.json"

# Setup logging
logger = logging.getLogger("update-hub")
logger.setLevel(logging.INFO)

# Default handler (stdout) - systemd will capture this
stdout_handler = logging.StreamHandler(sys.stdout)
stdout_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logger.addHandler(stdout_handler)

# Global configuration
CONFIG = {}

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

def notify_hosts(status, producer_hostname=None):
    ip_map = CONFIG.get("ip_map", {})
    
    for hostname in status.get("hosts", {}).keys():
        if producer_hostname and hostname == producer_hostname:
            logger.info(f"Skipping notification for producer: {hostname}")
            continue

        ip = ip_map.get(hostname)
        if not ip:
            logger.warning(f"No IP mapping found for host: {hostname}")
            continue
            
        try:
            url = f"http://{ip}:8081/trigger-update"
            logger.info(f"Notifying {hostname} at {url}...")
            req = urllib.request.Request(url, method='POST')
            with urllib.request.urlopen(req, timeout=5) as f:
                pass
            logger.info(f"Successfully notified {hostname}")
        except Exception as e:
            logger.error(f"Failed to notify {hostname}: {e}")

class HubHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Override standard HTTP logging to use our logger
        logger.info("%s - - [%s] %s" %
                     (self.client_address[0],
                      self.log_date_time_string(),
                      format%args))

    def do_GET(self):
        try:
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
        except Exception as e:
            logger.error(f"Error processing GET request: {e}")
            self.send_response(500)
            self.end_headers()

    def do_POST(self):
        try:
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode())
            status = load_status()

            if self.path == "/producer/done":
                commit = data.get("commit")
                producer = data.get("host") # Get producer hostname if provided
                logger.info(f"Received producer update: {commit} from {producer}")
                status["latest_commit"] = commit
                save_status(status)
                self.send_response(200)
                self.end_headers()
                threading.Thread(target=notify_hosts, args=(status, producer)).start()

            elif self.path == "/consumer/reported":
                hostname = data.get("host")
                commit = data.get("commit")
                logger.info(f"Received consumer report from {hostname}: {commit}")
                if hostname:
                    status["hosts"][hostname] = {
                        "commit": commit,
                        "last_update": data.get("timestamp")
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
    parser.add_argument('--port', type=int, default=8080, help='Port to listen on')
    parser.add_argument('--config', required=True, help='Path to JSON configuration file')
    parser.add_argument('--log-file', help='Path to log file')
    args = parser.parse_args()

    # Configure logging to file if requested
    if args.log_file:
        try:
            file_handler = logging.FileHandler(args.log_file)
            file_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
            logger.addHandler(file_handler)
        except Exception as e:
            print(f"Failed to setup file logging: {e}", file=sys.stderr)

    # Load configuration
    global CONFIG
    try:
        with open(args.config, 'r') as f:
            CONFIG = json.load(f)
        logger.info(f"Loaded configuration from {args.config}")
    except Exception as e:
        logger.critical(f"Failed to load config file: {e}")
        sys.exit(1)

    server = HTTPServer(('0.0.0.0', args.port), HubHandler)
    logger.info(f"Starting update-hub on port {args.port}...")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logger.info("Server stopping...")
        server.server_close()

if __name__ == "__main__":
    main()
