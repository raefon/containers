#!/usr/bin/env python3
"""Generate a custom page from the installed ttyd's bundled frontend."""
import gzip
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

HANDLER = """<script>
document.addEventListener('contextmenu', function (event) {
  if (event.target instanceof Element && event.target.closest('.xterm')) {
    event.preventDefault();
  }
});
</script>
"""


def customize(html):
    if '</body>' not in html:
        raise ValueError('ttyd frontend is missing its closing body tag')
    return html.replace('</body>', HANDLER + '</body>', 1)


def main():
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    with subprocess.Popen(
        ['ttyd', '-i', '127.0.0.1', '-p', '17681', '/bin/sh'],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    ) as server:
        try:
            for attempt in range(50):
                if server.poll() is not None:
                    raise RuntimeError('ttyd exited before its frontend could be read')
                try:
                    with opener.open('http://127.0.0.1:17681/', timeout=2) as response:
                        payload = response.read()
                        if response.headers.get('Content-Encoding', '').lower() == 'gzip':
                            payload = gzip.decompress(payload)
                        html = payload.decode('utf-8')
                    break
                except urllib.error.URLError:
                    if attempt == 49:
                        raise
                    time.sleep(0.1)
            Path(sys.argv[1]).write_text(customize(html))
        finally:
            server.terminate()
            try:
                server.wait(timeout=5)
            except subprocess.TimeoutExpired:
                server.kill()
                server.wait()


if __name__ == '__main__':
    main()
