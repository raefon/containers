#!/usr/bin/env python3
"""Normalize the owned v1 layout before startup; preserve custom settings and data."""
import os
from pathlib import Path
import shutil
import tempfile
import time
import yaml

SQLITE_HEADER = b'SQLite format 3\0'


def migrate(config_file):
    path = Path(config_file)
    original = path.read_text()
    config = yaml.safe_load(original)
    if not isinstance(config, dict): raise ValueError('Filebrowser config must be a mapping')
    server = config.setdefault('server', {})
    http = config.setdefault('http', {})
    if 'port' in server:
        http.setdefault('port', server.pop('port'))
    database = server.get('database')
    if isinstance(database, str):
        legacy = Path(database)
        if not legacy.is_absolute():
            raise ValueError('Legacy database path must be absolute; resolve it before migration')
        if legacy.is_file() and legacy.stat().st_size:
            with legacy.open('rb') as stream: is_sqlite = stream.read(16) == SQLITE_HEADER
            if is_sqlite:
                server['database'] = {'path': database}
            else:
                # The old file is never overwritten: Quantum imports it into a new SQLite DB.
                backup = path.parent / 'backups' / f'legacy-{time.time_ns()}'
                backup.mkdir(parents=True)
                copied = backup / legacy.name
                shutil.copy2(legacy, copied)
                target = legacy.with_suffix('.sqlite')
                if target.exists(): raise ValueError('SQLite target already exists; inspect before migrating BoltDB')
                server['database'] = {'path': str(target), 'migrateFrom': str(copied)}
        else:
            server['database'] = {'path': str(legacy.with_suffix('.sqlite'))}
    elif not isinstance(database, dict) or not database.get('path'):
        raise ValueError('Missing server.database.path; refusing to select an unrelated database')
    # Only replace the old /srv source; preserve unrelated custom sources/options.
    sources = server.setdefault('sources', [])
    legacy_sources = [s for s in sources if s.get('path') == '/srv']
    if legacy_sources:
        if any(set(s) - {'path', 'name', 'config'} or
               set(s.get('config', {})) - {'defaultEnabled'} for s in legacy_sources):
            raise ValueError('Custom /srv source settings require explicit permission/rule migration')
        sources[:] = [s for s in sources if s.get('path') != '/srv']
    for source, name in (('/storage', 'Storage'), ('/config', 'Config')):
        if not any(s.get('path') == source for s in sources):
            sources.append({'path': source, 'name': name, 'config': {'defaultEnabled': True}})
    if config == yaml.safe_load(original): return False
    backup = path.with_name(path.name + '.before-direct-sources')
    if not backup.exists(): shutil.copy2(path, backup)
    fd, temp = tempfile.mkstemp(prefix='.config-', dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as output: yaml.safe_dump(config, output, sort_keys=False)
        shutil.copymode(path, temp)
        os.replace(temp, path)
    finally:
        if os.path.exists(temp): os.unlink(temp)
    return True


if __name__ == '__main__':
    import sys
    try:
        changed = migrate(sys.argv[1])
        print('Filebrowser config migrated; backup preserved.' if changed else 'Filebrowser config already current.')
    except (ValueError, OSError, yaml.YAMLError):
        raise SystemExit('Filebrowser config migration failed; existing data preserved. Inspect configuration and backups before retrying.')
