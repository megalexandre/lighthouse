// The real app: search finds the Test Movie; Portuguese chosen as the
// audio language in Settings is what mpv then plays.
// Run: xvfb-run -a flutter test integration_test -d linux
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jellyfin_flutter/api/client_info.dart';
import 'package:jellyfin_flutter/core/storage.dart';
import 'package:jellyfin_flutter/features/auth/data/auth_repository.dart';
import 'package:jellyfin_flutter/features/auth/data/session_store.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/player/application/player_controller.dart';
import 'package:jellyfin_flutter/features/player/data/player_engine.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';
import 'package:jellyfin_flutter/features/search/presentation/search_screen.dart';
import 'package:jellyfin_flutter/features/server/data/server_repository.dart';
import 'package:jellyfin_flutter/features/settings/presentation/settings_screen.dart';
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

  setUp(() async {
    user = await server.createUser();
    const client = ClientInfo(deviceId: 'integration-search', device: 'tests');
    final info = await JellyfinServerRepository(() async => client)
        .probe(server.url);
    final session = await JellyfinAuthRepository(() async => client)
        .login(info, user.name, user.password);
    store = MemoryKeyValueStore()
      ..values[SessionStore.sessionKey] = jsonEncode(session.toJson());
  });

  Future<void> searchTestMovie(WidgetTester tester) async {
    await waitFor(tester, find.byKey(HomeScreen.searchButton));
    await tapOn(tester, find.byKey(HomeScreen.searchButton));
    await waitFor(tester, find.byKey(SearchScreen.field));
    await tester.enterText(find.byKey(SearchScreen.field), 'test mov');
    final result = onScreen(SearchScreen, find.text(Fixtures.testMovie));
    await waitFor(tester, result);
    await tapOn(tester, result);
    await waitFor(
      tester,
      onScreen(ItemScreen, find.byKey(ItemScreen.playButton)),
    );
  }

  testWidgets('search: type, see the movie, open it', (tester) async {
    await launch(tester, store);
    await searchTestMovie(tester);
    expect(
      tester.widgetList<Text>(find.byKey(ItemScreen.title)).last.data,
      Fixtures.testMovie,
    );
  });

  testWidgets('Portuguese audio in Settings: the movie plays in Portuguese', (
    tester,
  ) async {
    await launch(tester, store);
    await waitFor(tester, find.byKey(HomeScreen.settingsButton));
    await tapOn(tester, find.byKey(HomeScreen.settingsButton));

    final audio = find.descendant(
      of: find.byKey(SettingsScreen.audioLanguageField),
      matching: find.byType(TextField),
    );
    await waitFor(tester, audio);
    await tapOn(tester, audio);
    // Typed through the (simulated) text input, as keystrokes are: the
    // menu filters on that, not on a text set directly.
    tester.testTextInput.register();
    addTearDown(tester.testTextInput.unregister);
    await tester.showKeyboard(audio);
    tester.testTextInput.enterText('portug');
    await tester.pump();
    // The language list comes from the server.
    // The open menu's entry (the menu also keeps hidden copies of every
    // entry, to measure its width).
    final portuguese = find
        .widgetWithText(MenuItemButton, 'Portuguese')
        .hitTestable();
    await waitFor(tester, portuguese);
    await tapOn(tester, portuguese);
    await waitUntil(
      tester,
      () => tester.widget<TextField>(audio).controller?.text == 'Portuguese',
      reason: 'the field to show Portuguese',
    );
    // Saved on the server (the change is async).
    var savedLanguage = '';
    await waitUntil(
      tester,
      () => savedLanguage == 'por',
      reason: 'the server to keep "por" (has "$savedLanguage")',
      poll: () async {
        final user_ = await server.adminGet<Map<String, dynamic>>(
          '/Users/${user.id}',
        );
        savedLanguage =
            ((user_['Configuration'] as Map)['AudioLanguagePreference']
                as String?) ??
            '';
      },
    );

    await tapOn(tester, find.byType(BackButton));
    await searchTestMovie(tester);
    await tapOn(tester, find.byKey(ItemScreen.playButton));
    await waitFor(tester, find.byKey(PlayerScreen.audioMenu));

    final request = tester
        .widget<PlayerScreen>(find.byType(PlayerScreen))
        .request;
    final engine =
        ProviderScope.containerOf(tester.element(find.byType(PlayerScreen)))
                .read(playerControllerProvider(request))
                .value!
                .engine
            as MediaKitEngine;
    var lang = '';
    await waitUntil(
      tester,
      () => lang == 'por',
      reason: 'mpv to play the Portuguese track (it plays "$lang")',
      poll: () async =>
          lang = await engine.mpvProperty('current-tracks/audio/lang'),
    );

    await tapOn(tester, find.byKey(PlayerScreen.backButton));
    await waitFor(
      tester,
      onScreen(ItemScreen, find.byKey(ItemScreen.resumeButton)),
    );
  });
}
