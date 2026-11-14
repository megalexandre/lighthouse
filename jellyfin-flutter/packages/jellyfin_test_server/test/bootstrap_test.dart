// Runs against the real test server: `dart test` (needs JELLYFIN_TEST_URL).
@Tags(['server'])
library;

import 'package:jellyfin_test_server/jellyfin_test_server.dart';
import 'package:test/test.dart';

void main() {
  late TestServer server;

  setUpAll(() async => server = await TestServer.start());

  test('fixture library is scanned', () async {
    final views = await server.adminGet<List<dynamic>>(
      '/Library/VirtualFolders',
    );
    expect(
      views.map((v) => (v as Map)['Name']),
      containsAll(TestServer.libraries.keys),
    );
  });

  test('start is idempotent', () async {
    final again = await TestServer.start();
    expect(again.url, server.url);
  });

  test('each test user has its own empty watch state', () async {
    final user = await server.createUser();
    addTearDown(() => server.deleteUser(user));

    final movie = await server.findItem(
      user,
      Fixtures.testMovie,
      type: 'Movie',
    );
    final userData = movie['UserData'] as Map<String, dynamic>;
    expect(userData['Played'], isFalse);
    expect(userData['PlaybackPositionTicks'], 0);
  });
}
