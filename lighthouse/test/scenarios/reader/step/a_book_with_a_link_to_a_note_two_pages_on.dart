import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../support/epub.dart';
import '../../../support/fakes.dart';
import 'world.dart';

/// Usage: Given a book {'book-links'} with a link to a note two pages on
///
/// Three chapters: the first starts with a long link to a note at the end
/// of the third.
Future<void> aBookWithALinkToANoteTwoPagesOn(
  WidgetTester tester,
  String itemId,
) async {
  final dir = Directory.systemTemp.createTempSync('jf-links-');
  addTearDown(() => dir.deleteSync(recursive: true));
  final file = File('${dir.path}/links.epub')
    ..writeAsBytesSync(
      epubBytes([
        '<p><a href="ch2.xhtml#note">${'see the note ' * 12}</a></p>',
        '<p>${'filler ' * 30}</p>',
        '<p>${'more ' * 30}</p><p id="note">The note.</p>',
      ]),
    );
  app.library.books = [TestItems.testNovel.copyWith(id: itemId, name: 'Links')];
  app.books.extraFiles[itemId] = file.path;
}
