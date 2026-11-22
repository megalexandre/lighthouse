import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/data/epub/epub_book.dart';
import 'package:lighthouse/features/reader/data/epub/epub_layout.dart';
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

  test('a border kept clear widens the margins, never narrows them', () {
    const size = Size(400, 600);
    final plain = EpubLayout(book, size);
    addTearDown(plain.dispose);
    final clear = EpubLayout(
      book,
      size,
      keepClear: const EdgeInsets.only(left: 4, top: 90, right: 70),
    );
    addTearDown(clear.dispose);
    expect(clear.margins.left, plain.margins.left);
    expect(clear.margins.top, 90);
    expect(clear.margins.right, 70);
    expect(clear.margins.bottom, plain.margins.bottom);
    expect(clear.content, clear.margins.deflateSize(size));
  });

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

  test('the layout counts the book as the book does', () {
    final layout = EpubLayout(book, const Size(400, 600));
    addTearDown(layout.dispose);
    expect(layout.length, book.length);
  });

  test('a link: found under its text, nothing beside it', () {
    final layout = EpubLayout(
      EpubBook.read(
        buildEpub([
          '<p>Before the link, <a href="#end">go to the end</a>, and after.</p>'
              '<p id="end">The end.</p>',
        ]),
      ),
      const Size(400, 600),
    );
    addTearDown(layout.dispose);
    final piece = layout.pages.first.pieces.first as TextPiece;
    final [link] = piece.links;
    expect(
      piece.painter.plainText.substring(link.start, link.end),
      'go to the end',
    );
    final box = piece.painter
        .getBoxesForSelection(
          TextSelection(baseOffset: link.start, extentOffset: link.end),
        )
        .first
        .toRect();
    final origin = Offset(layout.margins.left, layout.margins.top) + piece.at;
    expect(layout.linkAt(0, origin + box.center), 'OEBPS/text/ch0.xhtml#end');
    expect(layout.linkAt(0, origin + const Offset(1, 1)), isNull);
    expect(layout.linkAt(0, Offset(200, layout.size.height - 2)), isNull);
  });

  test('drawn in the ink asked for: the text, not black', () async {
    final layout = EpubLayout(
      EpubBook.read(buildEpub(['<h1>INK</h1><p>${'mmmm ' * 30}</p>'])),
      const Size(200, 300),
    );
    addTearDown(layout.dispose);
    final recorder = ui.PictureRecorder();
    layout.paint(Canvas(recorder), 0, const {}, ink: const Color(0xFFFF0000));
    final image = await recorder.endRecording().toImage(200, 300);
    final bytes = (await image.toByteData())!;
    image.dispose();
    var red = 0;
    var other = 0;
    for (var i = 0; i < bytes.lengthInBytes; i += 4) {
      final (r, g, b, a) = (
        bytes.getUint8(i),
        bytes.getUint8(i + 1),
        bytes.getUint8(i + 2),
        bytes.getUint8(i + 3),
      );
      if (a == 0) continue;
      // Premultiplied: a red pixel, faint or not, has no green or blue.
      if (g == 0 && b == 0 && r > 0) {
        red++;
      } else {
        other++;
      }
    }
    expect(red, greaterThan(100));
    expect(other, 0);
  });

  test('smaller headings further down; preformatted text smaller, in '
      'monospace; a rule between them', () {
    final layout = EpubLayout(
      EpubBook.read(
        buildEpub(['<h3>Three</h3><h4>Four</h4><hr/><pre>code here</pre>']),
      ),
      const Size(400, 600),
    );
    addTearDown(layout.dispose);
    TextStyle styleOf(String text) =>
        textPieces(layout)
            .firstWhere((p) => p.painter.plainText == text)
            .painter
            .text!
            .style!;
    const base = EpubTypography();
    expect(styleOf('Three').fontSize, base.fontSize * 1.2);
    expect(styleOf('Four').fontSize, base.fontSize * 1.1);
    expect(styleOf('code here').fontSize, base.fontSize * 0.85);
    expect(styleOf('code here').fontFamily, 'monospace');
    expect(layout.pages.single.pieces.whereType<RulePiece>(), hasLength(1));
  });

  test('a line taller than the page: on a page of its own, cut', () {
    // 80 px tall: 48 px between the margins, for 58 px lines.
    final layout = EpubLayout(
      EpubBook.read(buildEpub(['<p>${'word ' * 12}</p>'])),
      const Size(200, 80),
      typography: const EpubTypography(fontSize: 40),
    );
    addTearDown(layout.dispose);
    final painter = textPieces(layout).first.painter;
    final lines = painter.computeLineMetrics().length;
    expect(lines, greaterThan(1));
    expect(layout.pages, hasLength(lines));
    for (final page in layout.pages) {
      final [piece] = page.pieces.whereType<TextPiece>().toList();
      expect(piece.at.dy, 0);
    }
  });

  test(
    'a page is drawn with its images (those decoded) and its rules',
    () async {
      final layout = EpubLayout(
        EpubBook.read(
          buildEpub(
            ['<img src="../blue.png"/><hr/><img src="../later.png"/>'],
            files: {
              'blue.png': pngHeader(100, 50),
              'later.png': pngHeader(100, 50),
            },
          ),
        ),
        const Size(200, 400),
      );
      addTearDown(layout.dispose);
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawColor(const Color(0xFF0000FF), BlendMode.src);
      final blue = await recorder.endRecording().toImage(100, 50);
      addTearDown(blue.dispose);

      // later.png is not decoded yet: its space stays empty.
      final page = ui.PictureRecorder();
      layout.paint(Canvas(page), 0, {
        'OEBPS/blue.png': blue,
      }, ink: const Color(0xFFFF0000));
      final image = await page.endRecording().toImage(200, 400);
      final bytes = (await image.toByteData())!;
      image.dispose();
      var bluePixels = 0;
      var inkPixels = 0;
      for (var i = 0; i < bytes.lengthInBytes; i += 4) {
        final (r, g, b, a) = (
          bytes.getUint8(i),
          bytes.getUint8(i + 1),
          bytes.getUint8(i + 2),
          bytes.getUint8(i + 3),
        );
        if (a == 255 && r == 0 && g == 0 && b == 255) bluePixels++;
        // The rule, in the ink (premultiplied: red, faint or not).
        if (a > 0 && r > 0 && g == 0 && b == 0) inkPixels++;
      }
      final [shown, _] = layout.pages.single.images.toList();
      expect(bluePixels, closeTo(shown.rect.width * shown.rect.height, 400));
      expect(inkPixels, greaterThan(10));
    },
  );
}
