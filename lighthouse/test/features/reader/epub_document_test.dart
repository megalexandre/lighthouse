import 'dart:io';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
