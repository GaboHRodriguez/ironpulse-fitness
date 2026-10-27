import os
import subprocess
import threading
import webbrowser
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

PORT = 8765
WEB_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "web")


class QuietHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def log_message(self, format, *args):
        pass


def open_app_window():
    url = f"http://127.0.0.1:{PORT}"
    edge_paths = [
        r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
        r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    ]
    for path in edge_paths:
        if os.path.exists(path):
            subprocess.Popen([
                path,
                f"--app={url}",
                "--window-size=1180,820",
                "--app-name=IronPulse Fitness",
            ])
            return
    webbrowser.open(url)


if __name__ == "__main__":
    print("=================================================================")
    print("  IRONPULSE FITNESS - EJECUTANDO APLICACION EN WINDOWS DESKTOP")
    print("  (Cierra esta ventana cuando termines de usar la aplicacion)")
    print("=================================================================")
    server = ThreadingHTTPServer(("127.0.0.1", PORT), QuietHandler)
    threading.Timer(0.6, open_app_window).start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
