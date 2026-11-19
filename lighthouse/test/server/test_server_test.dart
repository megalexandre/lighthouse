// Checks the test server is set up before any app test relies on it.
@Tags(['server'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';

void main() {
  test('test server has the fixture library', () async {
    final server = await TestServer.start();
    final user = await server.createUser();

    final movie = await server.findItem(
      user,
      Fixtures.testMovie,
      type: 'Movie',
    );
    expect(movie['Name'], Fixtures.testMovie);
  });
}
