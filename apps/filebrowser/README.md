# Filebrowser Quantum container

The image targets Quantum v2 configuration:

- `http.port: 80`
- `server.database.path: /config/filebrowser/data/filebrowser.sqlite` for fresh installs
- Cache under `/config/filebrowser/data/tmp`
- Direct `Storage` (`/storage`) and `Config` (`/config`) sources

Mount tenant media and provider CSI storage under `/storage`, and the tenant's
persistent configuration volume at `/config`. Do not mount another tenant's data.
The image no longer creates `/srv/data` or `/srv/config` symlinks. On startup it
unlinks only those exact legacy aliases when they point to `/data` and `/config`;
custom links, directories and the targets are never removed.

`migrate_config.py` runs before Filebrowser starts. It preserves existing custom
settings and already-configured SQLite paths (including manually fixed
`filebrowser.db` paths). It normalizes a legacy database string into the v2 object,
moves an old server port into `http.port`, and replaces only the stock `/srv` source
with direct sources. Config changes are atomic, with the original saved as
`config.yaml.before-direct-sources`. Existing non-/srv sources are retained.
Custom /srv access rules cause a failure requiring explicit migration rather than
silently discarding restrictions. Existing shares/scopes tied to /srv may need
manual updates to the new source paths; verify them before removing backups.

If a populated legacy BoltDB is found, it is copied to a timestamped backup under
`/config/filebrowser/backups/`. A distinct `.sqlite` target and `migrateFrom` are
configured so Quantum performs its upstream migration on first start. The old
file is not overwritten. An existing target refuses ambiguous migration. Verify
users, shares and scopes after startup, then remove `migrateFrom` from config only
after the database migration is confirmed. SQLite files are never converted or
renamed automatically. Never run the migrator against a database being written
by a different Filebrowser instance.

Authentication remains `noauth` behind the tenant-restricted Authentik ForwardAuth
route. The container port must not be separately exposed without authentication.
No default `bogus,bogus` account is created by the entrypoint anymore.

Run migration tests in a Python environment with PyYAML:

```sh
python3 -m unittest discover -s apps/filebrowser -p 'test_*.py'
bash -n apps/filebrowser/entrypoint.sh
```

References:
- https://filebrowserquantum.com/en/docs/getting-started/v2/migration/
- https://filebrowserquantum.com/en/docs/configuration/sources/
