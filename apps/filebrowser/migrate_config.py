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
    mode = os.environ.get('FILEBROWSER_STORAGE_MODE', 'cloud').strip().lower()
    if mode not in ('cloud', 'local'):
        raise ValueError('FILEBROWSER_STORAGE_MODE must be cloud or local')
    storage_path = '/data' if mode == 'local' else '/storage'
    managed_storage_paths = {'/storage', '/data'}
    storage_indexes = [i for i, source in enumerate(sources)
                       if source.get('path') in managed_storage_paths]
    storage_sources = [sources[i] for i in storage_indexes]
    for source in storage_sources:
        if (set(source) - {'path', 'name', 'config'} or
                set(source.get('config', {})) - {'defaultEnabled'}):
            raise ValueError('Custom /storage or /data source settings require explicit migration')
    selected = next((s for s in storage_sources if s.get('path') == storage_path),
                    storage_sources[0] if storage_sources else None)
    if selected is None:
        selected = {'path': storage_path, 'name': 'Storage',
                    'config': {'defaultEnabled': True}}
    else:
        selected['path'] = storage_path
        selected['name'] = 'Storage'
        selected.setdefault('config', {}).setdefault('defaultEnabled', True)
    insert_at = storage_indexes[0] if storage_indexes else len(sources)
    sources[:] = [s for s in sources if s.get('path') not in managed_storage_paths]
    sources.insert(min(insert_at, len(sources)), selected)
    if not any(s.get('path') == '/config' for s in sources):
        sources.append({'path': '/config', 'name': 'Config', 'config': {'defaultEnabled': True}})
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
