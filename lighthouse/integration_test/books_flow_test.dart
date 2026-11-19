// The real app draws PDFs with PDFium (the place kept on the server, for a
// comic and an EPUB, is in features/reading.feature).
// Run: xvfb-run -a flutter test integration_test -d linux
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:lighthouse/features/reader/application/reader_controller.dart';
import 'package:lighthouse/features/reader/application/reader_preferences.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:lighthouse/features/server/data/server_repository.dart';
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

  testWidgets('a PDF in the dark theme: PDFium draws it light on dark', (
    tester,
  ) async {
    final readerStore = MemoryKeyValueStore()
      ..values['preferences'] = '{"theme":"dark"}';
    await launch(tester, store, readerStore: readerStore);
    await openBook(tester, Fixtures.testBook);
    await tapOn(tester, find.byKey(ItemScreen.readButton));
    await waitFor(tester, find.byKey(ReaderScreen.pageText));
    expect(
      find.ancestor(
        of: find.byType(PdfPageView),
        matching: find.byType(ColorFiltered),
      ),
      findsWidgets,
    );

    // The picture the page turn bends: the page's white is the dark paper.
    final session = ProviderScope.containerOf(
      tester.element(find.byType(ReaderScreen)),
    ).read(readerControllerProvider(_bookId(tester))).value!;
    final image = await tester.runAsync(
      () => sheetImage(
        session,
        0,
        const Size(200, 300),
        1,
        ReaderTheme.dark.pageColors,
      ),
    );
    final bytes = (await tester.runAsync(image!.toByteData))!;
    final paper = ReaderTheme.dark.colors.paper;
    // A corner: page margin, no text.
    expect(
      [bytes.getUint8(0), bytes.getUint8(1), bytes.getUint8(2)],
      [
        for (final c in [paper.r, paper.g, paper.b])
          closeTo((c * 255).round(), 2),
      ],
    );
    image.dispose();
    await tapOn(tester, find.byKey(ReaderScreen.backButton));
    await waitFor(tester, find.byKey(ItemScreen.readButton));
  });
}

/// The id of the book the reader shows.
String _bookId(WidgetTester tester) =>
    tester.widget<ReaderScreen>(find.byType(ReaderScreen)).itemId;
