// The real app loses its server (a proxy in between is taken down) and
// gets it back: the banner shows, then goes, and the screen reloads by
// itself.
// Run: xvfb-run -a flutter test integration_test -d linux
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jellyfin_flutter/api/client_info.dart';
import 'package:jellyfin_flutter/core/storage.dart';
import 'package:jellyfin_flutter/features/auth/data/auth_repository.dart';
import 'package:jellyfin_flutter/features/auth/data/session_store.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';
import 'package:jellyfin_flutter/features/library/presentation/library_screen.dart';
import 'package:jellyfin_flutter/features/server/data/server_repository.dart';
import 'package:jellyfin_flutter/features/server/presentation/connection_banner.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';
import 'package:media_kit/media_kit.dart';

import 'support/app.dart';
import 'support/proxy.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TestServer server;
  late FlakyProxy proxy;
  late MemoryKeyValueStore store;

  setUpAll(() async {
    MediaKit.ensureInitialized();
    server = await TestServer.start();
  });

  setUp(() async {
    proxy = await FlakyProxy.start(server.url);
    addTearDown(proxy.close);
    final user = await server.createUser();
    const client = ClientInfo(deviceId: 'integration-proxy', device: 'tests');
    // Signed in through the proxy: the app only knows its address.
    final info = await JellyfinServerRepository(() async => client)
        .probe(proxy.url);
    final session = await JellyfinAuthRepository(() async => client)
        .login(info, user.name, user.password);
    store = MemoryKeyValueStore()
      ..values[SessionStore.sessionKey] = jsonEncode(session.toJson());
  });

  testWidgets('server gone: the banner; back: it goes, the grid loads', (
    tester,
  ) async {
    await launch(tester, store);
    final movies = onScreen(HomeScreen, find.text('Movies'));
    await waitFor(tester, movies);
    expect(find.byKey(ConnectionBanner.banner), findsNothing);

    proxy.up = false;
    await tapOn(tester, movies);
    await waitFor(tester, find.byKey(ConnectionBanner.banner));
    expect(
      onScreen(LibraryScreen, find.text(Fixtures.testMovie)),
      findsNothing,
    );

    // Back: no tap needed, the app finds it and reloads the grid.
    proxy.up = true;
    await waitFor(
      tester,
      onScreen(LibraryScreen, find.text(Fixtures.testMovie)),
    );
    expect(find.byKey(ConnectionBanner.banner), findsNothing);
  });
}
