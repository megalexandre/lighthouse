// The real app plays on: Test Show S01E01 to its end starts S01E02, and
// the Test Album plays track after track.
// Run: xvfb-run -a flutter test integration_test -d linux
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jellyfin_flutter/api/client_info.dart';
import 'package:jellyfin_flutter/core/storage.dart';
import 'package:jellyfin_flutter/features/auth/data/auth_repository.dart';
import 'package:jellyfin_flutter/features/auth/data/session_store.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/library/presentation/library_screen.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';
import 'package:jellyfin_flutter/features/server/data/server_repository.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';
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

  /// A fresh user, already signed in.
  setUp(() async {
    user = await server.createUser();
    const client = ClientInfo(deviceId: 'integration-playon', device: 'tests');
    final info = await JellyfinServerRepository(() async => client)
        .probe(server.url);
    final session = await JellyfinAuthRepository(() async => client)
        .login(info, user.name, user.password);
    store = MemoryKeyValueStore()
      ..values[SessionStore.sessionKey] = jsonEncode(session.toJson());
  });

  /// Home → [library] → [name] in its grid.
  Future<void> openFromLibrary(
    WidgetTester tester,
    String library,
    String name,
  ) async {
    await launch(tester, store);
    final view = find.descendant(
      of: find.byKey(HomeScreen.viewsRow),
      matching: find.text(library),
    );
    await waitFor(tester, view);
    await tapOn(tester, view);
    final card = onScreen(LibraryScreen, find.text(name));
    await waitFor(tester, card);
    await tapOn(tester, card);
  }

  /// The item playing: its name in the player's title (an episode shows
  /// "S1:E1 · Name" under the series).
  Finder playing(String name) =>
      onScreen(PlayerScreen, find.textContaining(name));

  testWidgets('S01E01 to its end: S01E02 starts, S01E01 is watched', (
    tester,
  ) async {
    await openFromLibrary(tester, 'Shows', Fixtures.testShow);
    final season = onScreen(ItemScreen, find.text('Season 1'));
    await waitFor(tester, season);
    await tapOn(tester, season);
    final first = onScreen(ItemScreen, find.text('1. Test Show S01E01'));
    await waitFor(tester, first);
    await tapOn(tester, first);
    await waitFor(
      tester,
      onScreen(ItemScreen, find.byKey(ItemScreen.playButton)),
    );
    await tapOn(tester, find.byKey(ItemScreen.playButton));

    await waitFor(tester, playing('Test Show S01E01'));
    await waitFor(tester, find.byKey(PlayerScreen.nextButton));
    // 6 s episode: jump to the end.
    await pressKey(tester, LogicalKeyboardKey.pageDown);

    await waitFor(tester, playing('Test Show S01E02'));
    await settleRoute(tester); // the E01 player leaving
    final e1 = await server.findItem(user, 'Test Show S01E01', type: 'Episode');
    expect((e1['UserData'] as Map<String, dynamic>)['Played'], isTrue);

    await tapOn(tester, find.byKey(PlayerScreen.backButton));
    await waitFor(
      tester,
      onScreen(ItemScreen, find.byKey(ItemScreen.playButton)),
    );
  });

  testWidgets('the album: Play, Next, and it plays the second track', (
    tester,
  ) async {
    await openFromLibrary(tester, 'Music', Fixtures.testAlbum);
    final play = onScreen(ItemScreen, find.byKey(ItemScreen.playButton));
    await waitFor(tester, play);
    await tapOn(tester, play);

    await waitFor(tester, find.byKey(PlayerScreen.cover));
    await waitFor(tester, playing('Track 1').first);
    await waitFor(tester, find.byKey(PlayerScreen.nextButton));
    await tapOn(tester, find.byKey(PlayerScreen.nextButton));

    await waitFor(tester, playing('Track 2').first);
    await settleRoute(tester);
    expect(find.byKey(PlayerScreen.nextButton), findsNothing);
    await tapOn(tester, find.byKey(PlayerScreen.backButton));
    await waitFor(
      tester,
      onScreen(ItemScreen, find.byKey(ItemScreen.playButton)),
    );
  });
}
