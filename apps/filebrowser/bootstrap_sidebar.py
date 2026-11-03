#!/usr/bin/env python3
"""Seed the no-auth tenant sidebar once, through Filebrowser's own API."""
import json
import os
from pathlib import Path
import sys
import tempfile
import time
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen
import yaml


def initialize(config, marker, api):
    marker = Path(marker)
    if marker.exists():
        return 'already initialized'
    if config.get('auth', {}).get('methods', {}).get('noauth') is not True:
        return 'skipped: authentication is not noauth'
    user = api('GET', '/api/users?username=self')
    if not user.get('username') or not isinstance(user.get('scopes'), list):
        raise ValueError('Filebrowser user is not ready')
    scopes = {s['name']: s for s in user['scopes']}
    links = list(user.get('sidebarLinks') or [])
    expected = []
    for source in config.get('server', {}).get('sources', []):
        if source.get('path') not in ('/storage', '/config'):
            continue
        if source.get('config', {}).get('defaultEnabled') is not True:
            continue
        name = source.get('name') or Path(source['path']).name
        scope = scopes.get(name)
        if not scope:
            raise ValueError('Managed source grants are not ready')
        if not scope.get('permissions', {}).get('view'):
            continue
        expected.append(name)
        if any(x.get('category', '').split('-')[0] == 'source' and x.get('sourceName') == name for x in links):
            continue
        links.append({'name': name, 'category': 'source', 'target': scope.get('scope') or '/',
                      'icon': '', 'sourceName': name})
    if not expected:
        raise ValueError('No accessible managed sources are ready')
    path = '/api/users?' + urlencode({'username': user['username']})
    if links != (user.get('sidebarLinks') or []):
        api('PATCH', path, {'which': ['sidebarLinks'], 'data': {'sidebarLinks': links}})
    verified = api('GET', '/api/users?username=self').get('sidebarLinks') or []
    if any(not any(x.get('sourceName') == name and x.get('category', '').startswith('source')
                   for x in verified) for name in expected):
        raise ValueError('Sidebar update was not verified')
    marker.parent.mkdir(parents=True, exist_ok=True)
    fd, temp = tempfile.mkstemp(prefix='.sidebar-', dir=marker.parent)
    try:
        with os.fdopen(fd, 'w') as stream:
            json.dump({'version': 1, 'username': user['username'], 'sources': expected}, stream)
        os.replace(temp, marker)
    finally:
        if os.path.exists(temp): os.unlink(temp)
    return 'initialized'


def main():
    config = yaml.safe_load(Path(sys.argv[1]).read_text())
    if config.get('auth', {}).get('methods', {}).get('noauth') is not True:
        print('Filebrowser sidebar setup skipped: custom authentication.')
        return
    http = config.get('http', {})
    base = 'http://127.0.0.1:' + str(http.get('port', 80)) + '/' + str(http.get('baseURL', '')).strip('/')
    base = base.rstrip('/')
    database = Path(config['server']['database']['path'])
    marker = database.with_name(database.name + '.sidebar-v1.json')
    def api(method, path, body=None):
        request = Request(base + path, method=method,
                          data=json.dumps(body).encode() if body is not None else None,
                          headers={'Content-Type': 'application/json'})
        with urlopen(request, timeout=3) as response:
            raw = response.read()
            return json.loads(raw) if raw else None
    deadline = time.monotonic() + 90
    while True:
        try:
            result = initialize(config, marker, api)
            print('Filebrowser sidebar setup: ' + result, flush=True)
            return
        except (HTTPError, URLError, TimeoutError, ValueError, OSError):
            if time.monotonic() >= deadline:
                raise SystemExit('Filebrowser sidebar setup did not complete; retry on next restart. No account settings were reset.') from None
            time.sleep(2)


if __name__ == '__main__':
    main()
