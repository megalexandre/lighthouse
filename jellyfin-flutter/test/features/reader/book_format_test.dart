import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/features/reader/data/book_document.dart';
import 'package:jellyfin_flutter/features/reader/data/book_format.dart';
import 'package:jellyfin_flutter/features/reader/data/reading_position.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  Uint8List fixture(String id) =>
      File(FakeBookRepository.files[id]!).readAsBytesSync();

  test('formats are told by content', () {
    expect(detectBookFormat(fixture('book-pdf')), BookFormat.pdf);
    expect(detectBookFormat(fixture('book-comic')), BookFormat.comic);
    expect(detectBookFormat(fixture('book-epub')), BookFormat.epub);
    expect(
      detectBookFormat(Uint8List.fromList('hello'.codeUnits)),
      BookFormat.unknown,
    );
    // A zip with no images is no comic.
    final empty = ZipEncoder().encode(
      Archive()..add(ArchiveFile.string('a.txt', 'x')),
    );
    expect(detectBookFormat(Uint8List.fromList(empty)), BookFormat.unknown);
  });

  test('comic pages: images only, numbers in order', () {
    final zip = Archive();
    for (final name in [
      '10.png',
      '2.png',
      '1.jpg',
      'notes.txt',
      '__MACOSX/',
      '.hidden.png',
    ]) {
      zip.add(ArchiveFile.string(name, 'x'));
    }
    expect(comicPages(zip).map((f) => f.name), ['1.jpg', '2.png', '10.png']);
    expect(compareNatural('page2', 'page10'), lessThan(0));
    expect(compareNatural('Page 1', 'page 1'), 0);
  });

  test('the fixture comic has its 5 pages in order', () async {
    final doc = await openBook(File(FakeBookRepository.files['book-comic']!));
    expect(doc, isA<ComicBookDocument>());
    expect(doc.pageCount, 5);
  });

  testWidgets('a comic page image: one decode, at the size asked for', (
    tester,
  ) async {
    await tester.runAsync(() async {
      // A tall scan, 1200 × 1800, as PNG.
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawColor(const Color(0xFF336699), BlendMode.src);
      final scan = await recorder.endRecording().toImage(1200, 1800);
      final png = (await scan.toByteData(format: ui.ImageByteFormat.png))!;
      scan.dispose();
      final doc = ComicBookDocument(
        Archive()..add(ArchiveFile.bytes('1.png', png.buffer.asUint8List())),
      );

      final page = await doc.pageImage(0, const Size(400, 400));
      expect((page.width, page.height), (267, 400));
      page.dispose();
      expect(doc.pageAspectRatio(0), closeTo(2 / 3, 1e-9));
    });
  });

  test('an EPUB is not readable yet, and says so', () async {
    await expectLater(
      openBook(File(FakeBookRepository.files['book-epub']!)),
      throwsA(isA<NotReadable>()),
    );
  });

  group('position ↔ page, on the 12.4 scale (10000 ticks a page)', () {
    test('both ways', () {
      expect(positionForPage(2, 5, 50000), 20000);
      expect(pageForPosition(20000, 5, 50000), 2);
      expect(pageForPosition(0, 5, 50000), 0);
    });

    test('a length that is not 10000 a page is followed', () {
      // e.g. a server that counts the book as 100 units.
      expect(positionForPage(1, 4, 100), 25);
      expect(pageForPosition(75, 4, 100), 3);
    });

    test('no length: 10000 a page', () {
      expect(positionForPage(3, 10, null), 30000);
      expect(pageForPosition(30000, 10, null), 3);
    });

    test('out of range is clamped to the book', () {
      expect(pageForPosition(999999, 5, 50000), 4);
      expect(pageForPosition(-1, 5, 50000), 0);
    });
  });
}
