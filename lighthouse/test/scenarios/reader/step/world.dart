import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';
import 'package:lighthouse/features/reader/application/reader_controller.dart';
import 'package:lighthouse/features/reader/data/epub/epub_book.dart';
import 'package:lighthouse/features/reader/data/epub/epub_document.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';

/// What the steps of a scenario share: the app with its fake server,
/// library, player... (see test/support/fakes.dart). Made by
/// `the app is signed in`, each scenario its own.
late TestApp app;

/// The window the app opens in (`the window is`); the desktop one unless
/// said.
Size window = TestWindows.desktop;

/// Where the page was at `I note where the page is`.
Rect? pageNoted;

/// The scenario's tester, for the hooks: `Hooks.afterEach` closes the app
/// with it, and gets no tester of its own.
late WidgetTester tester;

/// Changes the book with that id in the fake library.
void changeBook(String itemId, BaseItemDto Function(BaseItemDto) change) {
  app.library.books = [
    for (final b in app.library.books) b.id == itemId ? change(b) : b,
  ];
}

/// What the reader shows: the open book's layout, for EPUB settings.
EpubBookDocument epubShown(WidgetTester tester, String itemId) =>
    app
            .containerOf(tester)
            .read(readerControllerProvider(itemId))
            .value!
            .document
        as EpubBookDocument;

/// Whether a page was lifted (being turned) in the middle of the last
/// touchpad swipe (see `I swipe two fingers on the touchpad`).
bool liftedMidSwipe = false;

/// What the last copy put on the clipboard (see `I copy it`).
String? clipboard;

/// Where [word] (its first occurrence in the book) is on the page shown,
/// in the window.
Rect wordOnPage(WidgetTester tester, String word) {
  final screen = tester.widget<ReaderScreen>(find.byType(ReaderScreen));
  final session = app
      .containerOf(tester)
      .read(readerControllerProvider(screen.itemId))
      .value!;
  final document = session.document as EpubBookDocument;
  final text = [
    for (final chapter in document.book.chapters)
      for (final block in chapter.blocks)
        block is TextBlock ? block.text : ' ' * block.length,
  ].join();
  final start = text.indexOf(word);
  expect(start, isNot(-1), reason: '"$word" is not in the book');
  final rects = document.rectsOf(
    session.page,
    TextRange(start: start, end: start + word.length),
  );
  expect(rects, isNotEmpty, reason: '"$word" is not on the page shown');
  final page = tester.getRect(find.byKey(ReaderScreen.pages));
  final unit = rects.reduce((a, b) => a.expandToInclude(b));
  return Rect.fromLTRB(
    page.left + unit.left * page.width,
    page.top + unit.top * page.height,
    page.left + unit.right * page.width,
    page.top + unit.bottom * page.height,
  );
}

/// Where the voice note button of a mark over [word] (its first occurrence
/// in the book) is drawn on the page shown, in the window; whether or not
/// there is a voice note there.
Rect voiceButtonOnPage(WidgetTester tester, String word) {
  final screen = tester.widget<ReaderScreen>(find.byType(ReaderScreen));
  final session = app
      .containerOf(tester)
      .read(readerControllerProvider(screen.itemId))
      .value!;
  final document = session.document as EpubBookDocument;
  final text = [
    for (final chapter in document.book.chapters)
      for (final block in chapter.blocks)
        block is TextBlock ? block.text : ' ' * block.length,
  ].join();
  final start = text.indexOf(word);
  final unit = document.badgeOf(
    session.page,
    TextRange(start: start, end: start + word.length),
  )!;
  final page = tester.getRect(find.byKey(ReaderScreen.pages));
  return Rect.fromLTRB(
    page.left + unit.left * page.width,
    page.top + unit.top * page.height,
    page.left + unit.right * page.width,
    page.top + unit.bottom * page.height,
  );
}

/// Adds [values] to the reader preferences stored on this device, as an
/// earlier run would have left them.
void storeReaderPreferences(Map<String, Object> values) {
  final stored = app.readerStore.values['preferences'];
  app.readerStore.values['preferences'] = jsonEncode({
    if (stored != null) ...jsonDecode(stored) as Map<String, dynamic>,
    ...values,
  });
}
