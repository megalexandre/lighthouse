import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';
import 'package:lighthouse/features/reader/application/reader_controller.dart';
import 'package:lighthouse/features/reader/data/epub/epub_document.dart';

import '../../../support/fakes.dart';

/// What the steps of a scenario share: the app with its fake server,
/// library, player... (see test/support/fakes.dart). Made by
/// `the app is signed in`, each scenario its own.
late TestApp app;

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
