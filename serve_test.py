from http.server import HTTPServer, SimpleHTTPRequestHandler
import os

def run_server():
    # Change to the project directory
    os.chdir("H:/nextproject")
    
    # Create server
    server_address = ('', 8001)
    httpd = HTTPServer(server_address, SimpleHTTPRequestHandler)
    
    print("Starting test server on http://localhost:8001")
    print("Open http://localhost:8001/test.html in your browser")
    print("Press Ctrl+C to stop the server")
    
    # Start server
    httpd.serve_forever()

if __name__ == "__main__":
    run_server() 