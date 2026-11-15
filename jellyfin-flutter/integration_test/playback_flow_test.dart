// The real app plays the Test Movie from the test server (libmpv, software
// decoding, no sound), and the server keeps where it stopped.
// Run: xvfb-run -a flutter test integration_test -d linux
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jellyfin_flutter/api/client_info.dart';
import 'package:jellyfin_flutter/core/storage.dart';
import 'package:jellyfin_flutter/core/ticks.dart';
import 'package:jellyfin_flutter/features/auth/data/auth_repository.dart';
import 'package:jellyfin_flutter/features/auth/data/session_store.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/library/presentation/library_screen.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';
import 'package:jellyfin_flutter/features/server/data/server_repository.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';
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

  /// A fresh user, already signed in.
  setUp(() async {
    user = await server.createUser();
    const client = ClientInfo(deviceId: 'integration-play', device: 'tests');
    final info = await JellyfinServerRepository(() async => client)
        .probe(server.url);
    final session = await JellyfinAuthRepository(() async => client)
        .login(info, user.name, user.password);
    store = MemoryKeyValueStore()
      ..values[SessionStore.sessionKey] = jsonEncode(session.toJson());
  });

  /// What the player's position label shows, as a duration.
  Duration shownPosition(WidgetTester tester) {
    final text = tester.widget<Text>(find.byKey(PlayerScreen.positionText));
    final [m, s] = text.data!.split(':').map(int.parse).toList();
    return Duration(minutes: m, seconds: s);
  }

  Future<void> openTestMovie(WidgetTester tester) async {
    await launch(tester, store);
    final movies = find.descendant(
      of: find.byKey(HomeScreen.viewsRow),
      matching: find.text('Movies'),
    );
    await waitFor(tester, movies);
    await tapOn(tester, movies);
    final card = onScreen(LibraryScreen, find.text(Fixtures.testMovie));
    await waitFor(tester, card);
    await tapOn(tester, card);
    await waitFor(
      tester,
      onScreen(ItemScreen, find.byKey(ItemScreen.playButton)),
    );
  }

  testWidgets('play, pause after 2 s, leave: the server keeps the position, '
      'and Resume starts there', (tester) async {
    await openTestMovie(tester);
    await tapOn(tester, find.byKey(ItemScreen.playButton));

    await waitFor(tester, find.byKey(PlayerScreen.positionText));
    await waitUntil(
      tester,
      () => shownPosition(tester) > const Duration(seconds: 2),
      reason: 'playback to pass 2 s',
    );

    await tapOn(tester, find.byKey(PlayerScreen.playPauseButton));
    await waitFor(tester, find.byTooltip('Play'));
    final paused = shownPosition(tester);

    await tapOn(tester, find.byKey(PlayerScreen.backButton));
    await waitFor(tester, find.byKey(ItemScreen.resumeButton));
    expect(find.byType(PlayerScreen), findsNothing);

    // The server agrees.
    final movie = await server.findItem(
      user,
      Fixtures.testMovie,
      type: 'Movie',
    );
    final userData = movie['UserData'] as Map<String, dynamic>;
    final saved = ticksToDuration(userData['PlaybackPositionTicks'] as int);
    expect(saved, greaterThan(const Duration(seconds: 2)));
    expect(saved.inSeconds, closeTo(paused.inSeconds, 1));
    expect(find.text('Resume from ${formatPosition(saved)}'), findsOneWidget);

    // Resume: the player starts at the saved point, not at 0.
    await tapOn(tester, find.byKey(ItemScreen.resumeButton));
    await waitFor(tester, find.byKey(PlayerScreen.positionText));
    await waitUntil(
      tester,
      () => shownPosition(tester) >= Duration(seconds: saved.inSeconds),
      reason: 'resume at ${formatPosition(saved)}',
      timeout: const Duration(seconds: 10),
    );
    expect(shownPosition(tester), lessThan(saved + const Duration(seconds: 4)));
    await tapOn(tester, find.byKey(PlayerScreen.backButton));
    await waitFor(tester, find.byKey(ItemScreen.resumeButton));
  });

  testWidgets('played to the end: watched, back on the details', (
    tester,
  ) async {
    await openTestMovie(tester);
    await tapOn(tester, find.byKey(ItemScreen.playButton));
    await waitFor(tester, find.byKey(PlayerScreen.positionText));

    // 10 s movie: seek near the end and let it finish.
    for (var i = 0; i < 9; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    }
    await waitUntil(
      tester,
      () => find.byType(PlayerScreen).evaluate().isEmpty,
      reason: 'the player to close at the end',
    );
    await waitFor(tester, find.byKey(ItemScreen.playButton));

    final data =
        (await server.findItem(
              user,
              Fixtures.testMovie,
              type: 'Movie',
            ))['UserData']
            as Map<String, dynamic>;
    expect(data['Played'], isTrue);
    expect(find.byKey(ItemScreen.resumeButton), findsNothing);
  });
}
