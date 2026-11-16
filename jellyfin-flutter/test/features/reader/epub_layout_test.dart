import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/reader/data/epub/epub_book.dart';
import 'package:jellyfin_flutter/features/reader/data/epub/epub_layout.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/epub.dart';

void main() {
  /// A chapter of [paragraphs] paragraphs of [words] words each.
  String chapter(String name, int paragraphs, {int words = 40}) => [
    '<h1>$name</h1>',
    for (var p = 0; p < paragraphs; p++)
      '<p>${List.generate(words, (w) => '$name-p$p-w$w').join(' ')}</p>',
  ].join();

  final book = EpubBook.read(
    buildEpub([chapter('one', 12), chapter('two', 3), chapter('three', 20)]),
  );

  List<TextPiece> textPieces(EpubLayout layout) => [
    for (final page in layout.pages) ...page.pieces.whereType<TextPiece>(),
  ];

  test('nothing goes past the bottom of a page', () {
    final layout = EpubLayout(book, const Size(400, 600));
    addTearDown(layout.dispose);
    expect(layout.pages.length, greaterThan(5));
    for (final page in layout.pages) {
      for (final piece in page.pieces.whereType<TextPiece>()) {
        expect(
          piece.at.dy + piece.bottom - piece.top,
          lessThanOrEqualTo(layout.content.height + 0.001),
        );
      }
    }
  });

  test('every line of every paragraph is shown once, in order', () {
    final layout = EpubLayout(book, const Size(400, 600));
    addTearDown(layout.dispose);
    final pieces = textPieces(layout);
    final paragraphs = book.chapters.expand((c) => c.blocks).length;
    final byPainter = <TextPainter, List<TextPiece>>{};
    for (final piece in pieces) {
      (byPainter[piece.painter] ??= []).add(piece);
    }
    expect(byPainter, hasLength(paragraphs));
    for (final MapEntry(key: painter, value: bands) in byPainter.entries) {
      // Bands follow each other with no gap and cover the whole paragraph.
      expect(bands.first.top, 0);
      for (var i = 1; i < bands.length; i++) {
        expect(bands[i].top, bands[i - 1].bottom);
      }
      expect(bands.last.bottom, closeTo(painter.height, 0.001));
    }
    // A paragraph that goes on over the next page: on two pages.
    expect(byPainter.values.where((b) => b.length > 1), isNotEmpty);
  });

  test('each chapter starts a page, with its heading first', () {
    final layout = EpubLayout(book, const Size(400, 600));
    addTearDown(layout.dispose);
    final firsts = [
      for (final page in layout.pages)
        if (page.pieces.first case TextPiece(:final painter, top: 0))
          painter.plainText,
    ];
    expect(firsts, containsAllInOrder(['one', 'two', 'three']));
  });

  test('places: pages in order, and a fraction finds its page', () {
    final layout = EpubLayout(book, const Size(400, 600));
    addTearDown(layout.dispose);
    expect(layout.fractionOf(0), 0);
    for (var i = 1; i < layout.pages.length; i++) {
      expect(layout.fractionOf(i), greaterThan(layout.fractionOf(i - 1)));
      expect(layout.pageAt(layout.fractionOf(i)), i);
    }
    expect(layout.pageAt(1), layout.pages.length - 1);
    expect(layout.pageAt(0.999999), layout.pages.length - 1);
  });

  test('another size, other pages, the same place', () {
    final big = EpubLayout(book, const Size(800, 1000));
    final small = EpubLayout(book, const Size(300, 450));
    addTearDown(big.dispose);
    addTearDown(small.dispose);
    expect(small.pages.length, greaterThan(big.pages.length));
    expect(big.length, small.length);
    // Page 3 of the big layout starts with a word; the small layout's page
    // for that place shows the same word.
    final fraction = big.fractionOf(3);
    final word = (big.pages[3].pieces.first as TextPiece).text.split(' ').first;
    final page = small.pages[small.pageAt(fraction)];
    expect(
      page.pieces.whereType<TextPiece>().map((p) => p.text).join(' '),
      contains(word),
    );
  });

  test('images fit the page; one that does not fit starts the next', () {
    final layout = EpubLayout(
      EpubBook.read(
        buildEpub(
          [
            '<p>${'word ' * 60}</p><img src="../tall.png"/>'
                '<img src="../wide.png"/>',
          ],
          files: {
            'tall.png': pngHeader(100, 2000),
            'wide.png': pngHeader(4000, 1000),
          },
        ),
      ),
      const Size(400, 600),
    );
    addTearDown(layout.dispose);
    final images = [for (final p in layout.pages) ...p.images];
    expect(images.map((i) => i.path), ['OEBPS/tall.png', 'OEBPS/wide.png']);
    for (final image in images) {
      expect(image.rect.width, lessThanOrEqualTo(layout.content.width + 0.001));
      expect(
        image.rect.bottom,
        lessThanOrEqualTo(layout.content.height + 0.001),
      );
    }
    // The tall one takes a page of its own, from the top.
    expect(images.first.rect.top, 0);
    expect(images.first.rect.height, closeTo(layout.content.height, 0.001));
  });

  test('a list item shows its bullet; the text is what is counted', () {
    final layout = EpubLayout(
      EpubBook.read(buildEpub(['<ol><li>first</li><li>second</li></ol>'])),
      const Size(400, 600),
    );
    addTearDown(layout.dispose);
    final texts = textPieces(layout).map((p) => p.painter.plainText);
    expect(texts, ['1. first', '2. second']);
    expect(layout.length, 'firstsecond'.length);
  });
}
