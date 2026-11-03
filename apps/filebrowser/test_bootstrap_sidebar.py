import copy
import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('sidebar', Path(__file__).with_name('bootstrap_sidebar.py'))
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)


class SidebarTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(); self.addCleanup(self.temp.cleanup)
        self.marker = Path(self.temp.name) / 'marker.json'
        self.config = {'auth': {'methods': {'noauth': True}}, 'server': {'sources': [
            {'path': path, 'name': name, 'config': {'defaultEnabled': True}}
            for path, name in [('/storage', 'Storage'), ('/config', 'Config')]]}}
        self.user = {'username': 'admin', 'scopes': [
            {'name': name, 'scope': scope, 'permissions': {'view': True, 'modify': False}}
            for name, scope in [('Storage', '/'), ('Config', '/sonarr')]],
            'sidebarLinks': [{'name': 'Custom', 'category': 'custom', 'target': '/settings'}]}
        self.writes = []

    def api(self, method, path, body=None):
        if method == 'GET': return copy.deepcopy(self.user)
        self.writes.append(copy.deepcopy(body))
        self.assertEqual(['sidebarLinks'], body['which'])
        self.assertEqual({'sidebarLinks'}, set(body['data']))
        self.user['sidebarLinks'] = copy.deepcopy(body['data']['sidebarLinks'])

    def test_merges_links_preserving_custom_links_and_restricted_scope(self):
        original_scopes = copy.deepcopy(self.user['scopes'])
        self.assertEqual('initialized', m.initialize(self.config, self.marker, self.api))
        self.assertEqual('Custom', self.user['sidebarLinks'][0]['name'])
        self.assertEqual('/sonarr', self.user['sidebarLinks'][-1]['target'])
        self.assertEqual(original_scopes, self.user['scopes'])
        # Subsequent manual removals must survive restarts.
        self.user['sidebarLinks'] = []
        self.assertEqual('already initialized', m.initialize(self.config, self.marker, self.api))
        self.assertEqual([], self.user['sidebarLinks'])
        self.assertEqual(1, len(self.writes))

    def test_existing_source_links_are_not_duplicated(self):
        self.user['sidebarLinks'] += [
            {'name': 'My config', 'category': 'source', 'sourceName': 'Config', 'target': '/sonarr'},
            {'name': 'My storage', 'category': 'source', 'sourceName': 'Storage', 'target': '/'}]
        m.initialize(self.config, self.marker, self.api)
        self.assertEqual([], self.writes)

    def test_waits_for_source_grants_without_recording_success(self):
        self.user['scopes'].pop()
        with self.assertRaises(ValueError): m.initialize(self.config, self.marker, self.api)
        self.assertFalse(self.marker.exists())
        self.assertEqual([], self.writes)

    def test_restricted_and_custom_auth_are_not_expanded(self):
        self.user['scopes'][1]['permissions']['view'] = False
        m.initialize(self.config, self.marker, self.api)
        self.assertNotIn('Config', [x.get('sourceName') for x in self.user['sidebarLinks']])
        self.marker.unlink()
        self.config['auth']['methods']['noauth'] = False
        self.assertIn('skipped', m.initialize(self.config, self.marker, lambda *a: self.fail('API should not be called')))

    def test_failed_verification_does_not_record_success(self):
        def api(method, path, body=None):
            return copy.deepcopy(self.user) if method == 'GET' else None
        with self.assertRaises(ValueError): m.initialize(self.config, self.marker, api)
        self.assertFalse(self.marker.exists())


if __name__ == '__main__': unittest.main()
