from http.server import BaseHTTPRequestHandler, HTTPServer
import subprocess
import sys

class TriggerHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        # 送信元チェック (Hub からのみ許可)
        client_ip = self.client_address[0]
        # Allow Hub (10.0.1.1) and localhost
        if client_ip != '10.0.1.1' and client_ip != '127.0.0.1':
            self.send_response(403)
            self.end_headers()
            self.wfile.write(b'Forbidden')
            print(f'Blocked update trigger request from {client_ip}')
            return

        if self.path == '/trigger-update':
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'Update triggered')
            print('Received update trigger. Starting nixos-auto-update.service...')
            # 非同期でサービスを起動
            subprocess.Popen(['systemctl', 'start', 'nixos-auto-update.service'])
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8081
    server = HTTPServer(('0.0.0.0', port), TriggerHandler)
    print(f'Listening for update triggers on port {port}...')
    server.serve_forever()
