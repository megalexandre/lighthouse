// The real app: search finds the Test Movie (the audio language chosen in
// Settings is in features/audio_and_subtitles.feature).
// Run: xvfb-run -a flutter test integration_test -d linux
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jellyfin_flutter/api/client_info.dart';
import 'package:jellyfin_flutter/core/storage.dart';
import 'package:jellyfin_flutter/features/auth/data/auth_repository.dart';
import 'package:jellyfin_flutter/features/auth/data/session_store.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/search/presentation/search_screen.dart';
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
    await typeInto(tester, find.byKey(SearchScreen.field), 'test mov');
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
}
