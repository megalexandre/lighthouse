import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/client_info.dart';
import 'package:lighthouse/core/storage.dart';
import 'package:lighthouse/features/reader/data/book_document.dart';
import 'package:lighthouse/features/reader/data/book_repository.dart';
import 'package:lighthouse/features/reader/data/epub/epub_book.dart';
import 'package:lighthouse/features/reader/data/epub/epub_document.dart';
import 'package:lighthouse/features/reader/data/epub/epub_layout.dart';
import 'package:lighthouse/features/reader/data/highlight.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/epub.dart';
import '../../support/fake_http.dart';
import '../../support/fakes.dart';

void main() {
  /// "alpha beta gamma ..." in paragraphs, after a heading.
  final book = EpubBook.read(
    buildEpub([
      '<h1>Title</h1>'
          '<p>alpha beta gamma delta epsilon</p>'
          '<p>zeta eta theta</p>',
      '<p>second chapter words</p>',
    ]),
  );
  const size = Size(400, 600);

  /// Where book characters [start] to [end] are drawn on page [page].
  Rect boxOf(EpubLayout layout, int page, int start, int end) =>
      layout.rectsOf(page, start, end).reduce((a, b) => a.expandToInclude(b));

  group('selecting in a laid out EPUB', () {
    late EpubLayout layout;
    setUp(() => layout = EpubLayout(book, size));
    tearDown(() => layout.dispose());

    // "Title" is 0..5, "alpha" starts at 5.
    const alpha = 5;

    test('the word under a point, in book characters', () {
      final beta = alpha + 'alpha '.length;
      final box = boxOf(layout, 0, beta, beta + 4);
      final word = layout.wordAt(0, box.center);
      expect(word, TextRange(start: beta, end: beta + 4));
      expect(EpubBookDocument(book).textOf(word!), 'beta');
    });

    test('off the text, nothing; near, the closest character', () {
      expect(layout.offsetAt(0, const Offset(2, 2)), isNull);
      expect(layout.wordAt(0, const Offset(2, 2)), isNull);
      // Far below the last line: its end.
      final end = layout.offsetAt(0, const Offset(398, 590), near: true);
      expect(end, 'Titlealpha beta gamma delta epsilonzeta eta theta'.length);
    });

    test('a range is drawn one box per line, on its own page only', () {
      final rects = layout.rectsOf(0, alpha, alpha + 'alpha beta'.length);
      expect(rects, isNotEmpty);
      for (final r in rects) {
        expect(r.left, greaterThanOrEqualTo(layout.margins.left - 0.5));
        expect(r.top, greaterThanOrEqualTo(layout.margins.top - 0.5));
      }
      // The second chapter is on page 1.
      final second = book.chapters.first.length;
      expect(layout.rectsOf(0, second, second + 6), isEmpty);
      expect(layout.rectsOf(1, second, second + 6), isNotEmpty);
    });

    test('a point on a highlight finds the characters it covers', () {
      final box = boxOf(layout, 0, alpha, alpha + 5);
      final offset = layout.offsetAt(0, box.centerLeft + const Offset(1, 0));
      expect(offset, alpha);
    });
  });

  test('the text of a range spans paragraphs, one per line', () {
    final document = EpubBookDocument(book);
    final start = 'Titlealpha beta gamma delta '.length;
    final end = 'Titlealpha beta gamma delta epsilonzeta'.length;
    expect(document.textOf(TextRange(start: start, end: end)), 'epsilon\nzeta');
  });

  test('a page with marks draws them under the text', () async {
    final document = EpubBookDocument(book);
    document.layout(size, const EpubTypography());
    addTearDown(document.dispose);
    Future<int> yellowish(List<PageMark> marks) async {
      final image = await document.pageImage(
        0,
        size,
        PageColors.plain,
        marks: marks,
      );
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.rawStraightRgba,
      ))!;
      image.dispose();
      var count = 0;
      for (var i = 0; i < bytes.lengthInBytes; i += 4) {
        // Red and green well over blue.
        if (bytes.getUint8(i + 3) > 0 &&
            bytes.getUint8(i) > 150 &&
            bytes.getUint8(i + 2) < bytes.getUint8(i) - 30) {
          count++;
        }
      }
      return count;
    }

    expect(await yellowish(const []), 0);
    expect(
      await yellowish([PageMark(5, 15, HighlightColor.yellow.fill)]),
      greaterThan(100),
    );
  });

  test('a highlight survives JSON; a broken entry is dropped', () {
    final h = Highlight(
      start: 3,
      end: 9,
      color: HighlightColor.blue,
      text: 'words',
      note: 'a thought',
      created: DateTime.utc(2026, 11, 27, 10),
    );
    expect(Highlight.fromJson(h.toJson()), h);
    expect(Highlight.fromJson({'start': 9, 'end': 3}), isNull);
    expect(Highlight.fromJson('nonsense'), isNull);
  });

  test('highlights are kept per book on this device, in order', () async {
    final store = MemoryKeyValueStore();
    final books = JellyfinBookRepository(
      testSession,
      () async => const ClientInfo(deviceId: 'dev-1', device: 'pc'),
      () async => throw UnimplementedError(),
      store,
      onUnauthorized: () {},
      adapter: FakeAdapter((_) async => throw UnimplementedError()),
    );
    Highlight at(int start) => Highlight(
      start: start,
      end: start + 4,
      color: HighlightColor.red,
      text: 'text',
      created: DateTime.utc(2026),
    );
    expect(await books.highlights('book-epub'), isEmpty);
    await books.saveHighlights('book-epub', [at(40), at(2)]);
    expect(await books.highlights('book-epub'), [at(2), at(40)]);
    expect(await books.highlights('book-other'), isEmpty);
    await books.saveHighlights('book-epub', const []);
    expect(store.values, isEmpty);
  });
}
