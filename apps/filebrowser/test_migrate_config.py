import importlib.util
from pathlib import Path
import tempfile
import unittest
import yaml

spec=importlib.util.spec_from_file_location('migration',Path(__file__).with_name('migrate_config.py'))
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)

class ConfigMigrationTest(unittest.TestCase):
    def test_manual_sqlite_fix_is_preserved_and_sources_are_direct(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d);db=root/'filebrowser.db';db.write_bytes(m.SQLITE_HEADER+b'keep database')
            path=root/'config.yaml';cfg={'server':{'database':{'path':str(db)},'cacheDir':'custom','sources':[{'path':'/srv','config':{'defaultEnabled':True}}]},'http':{'port':80},'auth':{'methods':{'noauth':True}},'frontend':{'name':'Custom'}}
            path.write_text(yaml.safe_dump(cfg));before=db.read_bytes()
            self.assertTrue(m.migrate(path));self.assertFalse(m.migrate(path))
            result=yaml.safe_load(path.read_text())
            self.assertEqual({'path':str(db)},result['server']['database'])
            self.assertEqual(['/storage','/config'],[s['path'] for s in result['server']['sources']])
            self.assertEqual('Custom',result['frontend']['name'])
            self.assertEqual(before,db.read_bytes())
            self.assertTrue(path.with_name('config.yaml.before-direct-sources').exists())

    def test_legacy_database_is_backed_up_and_imported_to_new_path(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d);db=root/'old.db';db.write_bytes(b'legacy BoltDB fixture')
            path=root/'config.yaml';path.write_text(yaml.safe_dump({'server':{'port':80,'database':str(db),'sources':[]}}))
            m.migrate(path);cfg=yaml.safe_load(path.read_text())
            self.assertEqual(str(root/'old.sqlite'),cfg['server']['database']['path'])
            self.assertEqual(db.read_bytes(),Path(cfg['server']['database']['migrateFrom']).read_bytes())
            self.assertEqual(80,cfg['http']['port'])
            self.assertFalse((root/'old.sqlite').exists())

    def test_custom_legacy_source_rules_require_explicit_migration(self):
        with tempfile.TemporaryDirectory() as d:
            path=Path(d)/'config.yaml';original=yaml.safe_dump({'server':{'database':{'path':'/config/filebrowser.sqlite'},'sources':[{'path':'/srv','config':{'denyByDefault':True}}]}});path.write_text(original)
            with self.assertRaises(ValueError):m.migrate(path)
            self.assertEqual(original,path.read_text())
