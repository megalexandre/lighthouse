import 'dart:io';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/application/reader_preferences.dart';
import 'package:lighthouse/features/reader/data/book_document.dart';
import 'package:lighthouse/features/reader/data/epub/epub_book.dart';
import 'package:lighthouse/features/reader/data/epub/epub_document.dart';
import 'package:lighthouse/features/reader/data/epub/epub_layout.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/epub.dart';
import '../../support/fakes.dart';

void main() {
  const size = Size(400, 600);
  const type = EpubTypography();

  test('the contents go to the pages their chapters start', () async {
    final doc = EpubBookDocument(
      EpubBook.read(
        ZipDecoder().decodeBytes(
          File(FakeBookRepository.files['book-epub']!).readAsBytesSync(),
        ),
      ),
    );
    addTearDown(doc.dispose);
    doc.layout(size, type);
    final toc = await doc.contents();
    expect(toc.map((e) => e.title), [
      'Chapter One',
      'Chapter Two',
      'Chapter Three',
    ]);
    expect(toc.map((e) => doc.pageAt(e.fraction)), [0, 1, 2]);
  });

  test('no table of contents: the chapters that open with a heading', () async {
    final doc = EpubBookDocument(
      EpubBook.read(
        buildEpub([
          '<h1>One</h1><p>a</p>',
          '<p>no heading</p>',
          '<h2>Three</h2>',
        ]),
      ),
    );
    addTearDown(doc.dispose);
    doc.layout(size, type);
    final toc = await doc.contents();
    expect(toc.map((e) => e.title), ['One', 'Three']);
    expect(toc.map((e) => doc.pageAt(e.fraction)), [0, 2]);
  });

  test('no link where there is none, or to a file not in the book', () {
    final doc = EpubBookDocument(
      EpubBook.read(
        buildEpub([
          '<p><a href="notes.xhtml#n2">${'link ' * 20}</a></p>',
          '<p>${'filler ' * 400}</p>',
          '<p id="n1">${'note one ' * 200}</p><p id="n2">Note two.</p>',
        ]),
      ),
    );
    addTearDown(doc.dispose);
    // No layout yet: no links.
    expect(doc.linkAt(0, const Offset(0.5, 0.1)), isNull);
    doc.layout(size, type);
    expect(doc.linkAt(0, const Offset(0.5, 0.9)), isNull);
    // The chapter "notes.xhtml" is not in the book: the link goes nowhere.
    expect(doc.linkAt(0, const Offset(0.3, 0.08)), isNull);
  });

  test('a link inside the book: its page, whatever the layout', () {
    final doc = EpubBookDocument(
      EpubBook.read(
        buildEpub([
          '<p><a href="ch2.xhtml#n2">${'link ' * 20}</a></p>',
          '<p>${'filler ' * 400}</p>',
          '<p id="n1">${'note one ' * 200}</p><p id="n2">Note two.</p>',
        ]),
      ),
    );
    addTearDown(doc.dispose);
    for (final type in const [EpubTypography(), EpubTypography(fontSize: 28)]) {
      doc.layout(size, type);
      final target = doc.linkAt(0, const Offset(0.3, 0.08));
      expect(target, isNotNull, reason: '${type.fontSize} px');
      // The last page holds "Note two.".
      expect(doc.pageAt(target!), doc.pageCount - 1);
    }
  });

  test(
    'a PDF in another theme: white becomes the paper, black the ink',
    () async {
      expect(PageColors.plain.recolor, isNull);
      const colors = PageColors(
        paper: Color(0xFF102030),
        ink: Color(0xFFE0D0C0),
      );
      final recorder = ui.PictureRecorder();
      Canvas(recorder)
        ..saveLayer(null, Paint()..colorFilter = colors.recolor)
        ..drawRect(
          const Rect.fromLTWH(0, 0, 1, 1),
          Paint()..color = Colors.white,
        )
        ..drawRect(
          const Rect.fromLTWH(1, 0, 1, 1),
          Paint()..color = Colors.black,
        )
        ..restore();
      final image = await recorder.endRecording().toImage(2, 1);
      final bytes = (await image.toByteData())!;
      image.dispose();
      List<int> pixel(int x) => [
        for (var c = 0; c < 3; c++) bytes.getUint8(x * 4 + c),
      ];
      expect(pixel(0), [0x10, 0x20, 0x30]);
      expect(pixel(1), [0xE0, 0xD0, 0xC0]);
    },
  );

  group('images', () {
    /// A real [width] × [height] PNG, all [color].
    Future<List<int>> png(
      Color color, {
      int width = 60,
      int height = 40,
    }) async {
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawColor(color, BlendMode.src);
      final image = await recorder.endRecording().toImage(width, height);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return bytes!.buffer.asUint8List();
    }

    /// How many opaque pixels of page [index] are [color].
    Future<int> pixelsOf(EpubBookDocument doc, int index, Color color) async {
      final image = await doc.pageImage(index, size, ReaderTheme.light.colors);
      final bytes = (await image.toByteData())!;
      image.dispose();
      final rgba = color.toARGB32();
      final want = (rgba >> 16 & 0xFF, rgba >> 8 & 0xFF, rgba & 0xFF);
      var n = 0;
      for (var i = 0; i < bytes.lengthInBytes; i += 4) {
        if (bytes.getUint8(i + 3) == 255 &&
            (bytes.getUint8(i), bytes.getUint8(i + 1), bytes.getUint8(i + 2)) ==
                want) {
          n++;
        }
      }
      return n;
    }

    Color shade(int i) => Color(0xFF000000 | (i * 20 + 30) << 16 | 0x40 << 8);

    test(
      'each page shows its own image, also once older ones are let go',
      () async {
        // A chapter, so a page, per image: more than the document keeps
        // decoded at once.
        const count = 10;
        final doc = EpubBookDocument(
          EpubBook.read(
            buildEpub(
              [for (var i = 0; i < count; i++) '<img src="../i$i.png"/>'],
              files: {
                for (var i = 0; i < count; i++) 'i$i.png': await png(shade(i)),
              },
            ),
          ),
        );
        addTearDown(doc.dispose);
        doc.layout(size, type);
        expect(doc.pageCount, count);
        for (var i = 0; i < count; i++) {
          expect(await pixelsOf(doc, i, shade(i)), greaterThan(1000));
        }
        // The first was let go: decoded again, the same.
        expect(await pixelsOf(doc, 0, shade(0)), greaterThan(1000));
      },
    );

    test('two pages asking at once both get it; one that cannot be read is '
        'left blank', () async {
      const blue = Color(0xFF0000FF);
      final doc = EpubBookDocument(
        EpubBook.read(
          buildEpub(
            ['<img src="../blue.png"/><img src="../broken.png"/>'],
            // A PNG header only: the engine cannot decode it.
            files: {
              'blue.png': await png(blue),
              'broken.png': pngHeader(60, 40),
            },
          ),
        ),
      );
      addTearDown(doc.dispose);
      doc.layout(size, type);
      final [a, b] = await Future.wait([
        pixelsOf(doc, 0, blue),
        pixelsOf(doc, 0, blue),
      ]);
      expect(a, greaterThan(1000));
      expect(b, a);
    });
  });

  testWidgets('a page on screen shows its images once they are decoded', (
    tester,
  ) async {
    const blue = Color(0xFF0000FF);
    final doc = (await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawColor(blue, BlendMode.src);
      final image = await recorder.endRecording().toImage(60, 40);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return EpubBookDocument(
        EpubBook.read(
          buildEpub(
            ['<p>Before.</p><img src="../blue.png"/>'],
            files: {'blue.png': png!.buffer.asUint8List()},
          ),
        ),
      );
    }))!;
    addTearDown(doc.dispose);
    doc.layout(size, type);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      Center(
        child: RepaintBoundary(
          key: boundary,
          child: SizedBox.fromSize(
            size: size,
            child: doc.buildPage(0, ReaderTheme.light.colors),
          ),
        ),
      ),
    );

    /// Blue pixels on screen (real image work: off the fake clock).
    Future<int> bluePixels() async => (await tester.runAsync(() async {
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await render.toImage();
      final bytes = (await image.toByteData())!;
      image.dispose();
      var n = 0;
      for (var i = 0; i < bytes.lengthInBytes; i += 4) {
        if (bytes.getUint8(i) == 0 &&
            bytes.getUint8(i + 1) == 0 &&
            bytes.getUint8(i + 2) == 255) {
          n++;
        }
      }
      return n;
    }))!;

    var shown = 0;
    for (var i = 0; i < 50 && shown == 0; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
      shown = await bluePixels();
    }
    expect(shown, greaterThan(1000));
    // Gone from the screen: its decoded images are let go with it.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('laid out again at the same size and type: nothing changes', () {
    final doc = EpubBookDocument(EpubBook.read(buildEpub(['<p>text</p>'])));
    addTearDown(doc.dispose);
    expect(doc.layout(size, type), isTrue);
    final version = doc.layoutVersion;
    expect(doc.layout(size, type), isFalse);
    expect(doc.layoutVersion, version);
    expect(doc.layout(Size.zero, type), isFalse, reason: 'no size yet');
  });
}
