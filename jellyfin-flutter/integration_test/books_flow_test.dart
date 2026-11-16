// The real app reads the fixture books: a comic page by page, the place
// kept on the server and found again; a PDF drawn by PDFium.
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
import 'package:jellyfin_flutter/features/reader/presentation/reader_screen.dart';
import 'package:jellyfin_flutter/features/server/data/server_repository.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';
import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:pdfrx/pdfrx.dart';

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
    const client = ClientInfo(deviceId: 'integration-books', device: 'tests');
    final info = await JellyfinServerRepository(() async => client)
        .probe(server.url);
    final session = await JellyfinAuthRepository(() async => client)
        .login(info, user.name, user.password);
    store = MemoryKeyValueStore()
      ..values[SessionStore.sessionKey] = jsonEncode(session.toJson());
  });

  String pageText(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(ReaderScreen.pageText)).data!;

  Future<void> openBook(WidgetTester tester, String name) async {
    final books = onScreen(HomeScreen, find.text('Books'));
    await waitFor(tester, books);
    await tapOn(tester, books);
    final card = onScreen(LibraryScreen, find.text(name));
    await waitFor(tester, card);
    await tapOn(tester, card);
    await waitFor(
      tester,
      onScreen(ItemScreen, find.byKey(ItemScreen.readButton)),
    );
  }

  testWidgets('a comic: swipe, then a key, back; the server keeps page 3 '
      'and the book opens there again', (tester) async {
    await launch(tester, store);
    await openBook(tester, Fixtures.testComic);
    expect(find.text('Read'), findsOneWidget);
    await tapOn(tester, find.byKey(ItemScreen.readButton));

    await waitFor(tester, find.byKey(ReaderScreen.pageText));
    expect(pageText(tester), 'Page 1 of ${Fixtures.bookPages}');
    // Lifted from the right half, as one turns a page.
    final sheet = tester.getRect(find.byKey(ReaderScreen.pages));
    await tester.flingFrom(
      Offset(sheet.left + sheet.width * 0.85, sheet.center.dy),
      Offset(-sheet.width * 0.7, 0),
      1500,
    );
    await waitUntil(
      tester,
      () => pageText(tester) == 'Page 2 of 5',
      reason: 'the swipe to turn the page',
    );
    await pressKey(tester, LogicalKeyboardKey.arrowRight);
    await waitUntil(
      tester,
      () => pageText(tester) == 'Page 3 of 5',
      reason: 'the key to turn the page',
    );

    await tapOn(tester, find.byKey(ReaderScreen.backButton));
    await waitFor(tester, find.text('Continue reading · 40%'));

    final saved = await server.findItem(user, Fixtures.testComic, type: 'Book');
    final data = saved['UserData'] as Map<String, dynamic>;
    expect(data['PlaybackPositionTicks'], 20000);

    await tapOn(tester, find.byKey(ItemScreen.readButton));
    await waitFor(tester, find.byKey(ReaderScreen.pageText));
    expect(pageText(tester), 'Page 3 of 5');
    await tapOn(tester, find.byKey(ReaderScreen.backButton));
    await waitFor(tester, find.byKey(ItemScreen.readButton));
  });

  testWidgets('a PDF: PDFium draws its pages, and they turn', (tester) async {
    await launch(tester, store);
    await openBook(tester, Fixtures.testBook);
    await tapOn(tester, find.byKey(ItemScreen.readButton));

    await waitFor(tester, find.byKey(ReaderScreen.pageText));
    expect(pageText(tester), 'Page 1 of ${Fixtures.bookPages}');
    expect(onScreen(ReaderScreen, find.byType(PdfPageView)), findsWidgets);

    await pressKey(tester, LogicalKeyboardKey.arrowRight);
    await waitUntil(
      tester,
      () => pageText(tester) == 'Page 2 of 5',
      reason: 'the PDF page to turn',
    );
    await tapOn(tester, find.byKey(ReaderScreen.backButton));
    await waitFor(tester, find.byKey(ItemScreen.readButton));
  });
}
