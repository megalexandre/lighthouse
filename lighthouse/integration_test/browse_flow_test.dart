// The real app against the test server's fixture library: from home into
// a library and down to a detail page.
// Run: xvfb-run -a flutter test integration_test -d linux
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';
import 'package:lighthouse/api/client_info.dart';
import 'package:lighthouse/core/storage.dart';
import 'package:lighthouse/features/auth/data/auth_repository.dart';
import 'package:lighthouse/features/auth/data/session_store.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/library/presentation/library_screen.dart';
import 'package:lighthouse/features/server/data/server_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart';

import 'support/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TestServer server;
  late TestUser user;
  late MemoryKeyValueStore store;

  setUpAll(() async {
    MediaKit.ensureInitialized();
    server = await TestServer.start();
  });

  /// A fresh user, already signed in: the app opens on home. (Signing in
  /// through the screens is auth_flow_test's job.)
  setUp(() async {
    user = await server.createUser();
    const client = ClientInfo(deviceId: 'integration-browse', device: 'tests');
    final info = await JellyfinServerRepository(() async => client)
        .probe(server.url);
    final session = await JellyfinAuthRepository(() async => client)
        .login(info, user.name, user.password);
    store = MemoryKeyValueStore()
      ..values[SessionStore.sessionKey] = jsonEncode(session.toJson());
  });

  Finder inViews(String name) => find.descendant(
    of: find.byKey(HomeScreen.viewsRow),
    matching: find.text(name),
  );

  /// Title of the detail page on top (others may be underneath).
  String title(WidgetTester tester) =>
      tester.widgetList<Text>(find.byKey(ItemScreen.title)).last.data!;

  testWidgets('home → Movies → Test Movie', (tester) async {
    await launch(tester, store);
    await waitFor(tester, inViews('Movies'));
    expect(inViews('Shows'), findsOneWidget);
    expect(inViews('Music'), findsOneWidget);
    await waitFor(tester, find.text('Latest in Movies'));

    await tapOn(tester, inViews('Movies'));
    await waitFor(
      tester,
      onScreen(LibraryScreen, find.text(Fixtures.testMovie)),
    );
    expect(
      onScreen(LibraryScreen, find.text(Fixtures.hevcMovie)),
      findsOneWidget,
    );

    await tapOn(tester, onScreen(LibraryScreen, find.text(Fixtures.testMovie)));
    await waitFor(tester, find.byKey(ItemScreen.title));
    expect(title(tester), Fixtures.testMovie);
    expect(find.textContaining('2020 · 10s'), findsOneWidget);
    // The poster comes from the server (an Image, not the placeholder).
    final poster = onScreen(ItemScreen, find.byType(Image));
    await waitFor(tester, poster);
    expect(poster, findsOneWidget);

    // Back twice: the grid, then home.
    await tapOn(tester, find.byType(BackButton));
    await waitFor(tester, find.byType(LibraryScreen));
    await tapOn(tester, find.byType(BackButton));
    await waitFor(tester, find.byKey(HomeScreen.viewsRow));
  });

  testWidgets('home → Shows → Test Show → Season 1 → episode 2', (
    tester,
  ) async {
    await launch(tester, store);
    await waitFor(tester, inViews('Shows'));
    await tapOn(tester, inViews('Shows'));

    await waitFor(
      tester,
      onScreen(LibraryScreen, find.text(Fixtures.testShow)),
    );
    await tapOn(tester, onScreen(LibraryScreen, find.text(Fixtures.testShow)));
    final season = onScreen(ItemScreen, find.text('Season 1'));
    await waitFor(tester, season);
    expect(title(tester), Fixtures.testShow);
    await tapOn(tester, season);

    await waitFor(tester, onScreen(ItemScreen, find.text('Episodes')));
    await waitFor(
      tester,
      onScreen(ItemScreen, find.text('3. Test Show S01E03')),
    );
    expect(
      onScreen(ItemScreen, find.textContaining('. Test Show S01E0')),
      findsNWidgets(3),
    );
    await tapOn(tester, onScreen(ItemScreen, find.textContaining('2. ')));

    await waitFor(tester, onScreen(ItemScreen, find.textContaining('S1:E2')));
    expect(find.byKey(ItemScreen.seriesLink), findsOneWidget);
  });
}
