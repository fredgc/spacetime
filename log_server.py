#!/usr/bin/env python3
import http.server
import socketserver
import sys
from datetime import datetime

PORT = 5001

def log_print(data):
    formatted_now = datetime.now().strftime('%H:%M:%S')
    stamped_data = f"{formatted_now}: {data}";
    # Write to log file and console
    with open('client_logs.log', 'a') as f:
        f.write(stamped_data + '\n')
    print(stamped_data, flush=True)
    

class LogHandler(http.server.BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        # Handle CORS preflight request
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length).decode('utf-8')
        
        log_print(post_data)
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()

    def log_message(self, format, *args):
        # Suppress standard HTTP request logging to keep console clean
        pass

if __name__ == '__main__':
    formatted_now = datetime.now().strftime('------------- Starting log server %Y-%m-%d.')
    log_print(formatted_now)
    # Allow address reuse to make restarting the server easy
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), LogHandler) as httpd:
        log_print(f"Log server running on port {PORT}. Writing to client_logs.log...")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nShutting down log server.")
            sys.exit(0)
