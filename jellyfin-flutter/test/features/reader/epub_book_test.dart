import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/reader/data/epub/epub_book.dart';

import '../../support/epub.dart';
import '../../support/fakes.dart';

void main() {
  List<String> describe(List<EpubBlock> blocks) => [
    for (final b in blocks)
      switch (b) {
        TextBlock() =>
          '${b.kind.name}${b.level > 0 ? b.level : ''}'
              '${b.centered ? ' centered' : ''}'
              '${b.indent > 0 ? ' indent ${b.indent}' : ''}'
              '${b.marker != null ? ' ${b.marker}' : ''}: ${b.text}',
        ImageBlock(:final path) => 'image $path',
        RuleBlock() => 'rule',
      },
  ];

  test('the fixture novel: its title and three chapters in order', () {
    final zip = ZipDecoder().decodeBytes(
      File(FakeBookRepository.files['book-epub']!).readAsBytesSync(),
    );
    final book = EpubBook.read(zip);
    expect(book.title, 'Test Novel');
    expect(book.chapters, hasLength(3));
    expect(describe(book.chapters.first.blocks), [
      'heading1: Chapter One',
      'paragraph: The first chapter of the test novel.',
    ]);
  });

  test('paragraphs, headings, quotes, lists, rules; CSS left out', () {
    final blocks = chapterBlocks('''
      <h2 class="title">Part <em>One</em></h2>
      <p>  First   line,
         same paragraph.<br/>After a break.</p>
      <div><p>Nested</p> and loose text</div>
      <blockquote><p>Quoted</p></blockquote>
      <ul><li>a</li><li>b</li></ul>
      <ol start="3"><li>c</li></ol>
      <hr/>
      <p style="text-align: center">* * *</p>
      <script>alert(1)</script>
      <pre>  keep
   spaces</pre>
    ''', '');
    expect(describe(blocks), [
      'heading2: Part One',
      'paragraph: First line, same paragraph.\nAfter a break.',
      'paragraph: Nested',
      'paragraph: and loose text',
      'quote indent 1: Quoted',
      'listItem indent 1 •: a',
      'listItem indent 1 •: b',
      'listItem indent 1 3.: c',
      'rule',
      'paragraph centered: * * *',
      'preformatted: keep\n   spaces',
    ]);
  });

  test('bold, italic and code keep their runs; one space between words', () {
    final [block as TextBlock] = chapterBlocks(
      '<p>a <b>bold</b> <i>and <strong>both</strong></i><code>x()</code></p>',
      '',
    );
    expect(block.runs.map((r) => '$r'), [
      '"a "',
      'b:"bold"',
      '" "',
      'i:"and "',
      'b:i:"both"',
      'm:"x()"',
    ]);
  });

  test('sloppy markup still reads (unclosed tags, entities)', () {
    final blocks = chapterBlocks('<p>One &amp; two<p>Three &mdash; four', '');
    expect(describe(blocks), [
      'paragraph: One & two',
      'paragraph: Three — four',
    ]);
  });

  test('images: paths from the chapter folder; missing ones dropped', () {
    final book = EpubBook.read(
      buildEpub(
        [
          '<p>Before</p><img src="../images/pic%201.png"/>'
              '<p><img src="missing.png"/>After</p>',
        ],
        files: {'images/pic 1.png': pngHeader(4, 2)},
      ),
    );
    expect(describe(book.chapters.single.blocks), [
      'paragraph: Before',
      'image OEBPS/images/pic 1.png',
      'paragraph: After',
    ]);
    expect(book.images.keys, ['OEBPS/images/pic 1.png']);
  });

  test('empty chapters are left out; a book with none is not an EPUB', () {
    expect(EpubBook.read(buildEpub(['<p>x</p>', '  '])).chapters, hasLength(1));
    expect(
      () => EpubBook.read(buildEpub(['<div> </div>'])),
      throwsFormatException,
    );
    expect(() => EpubBook.read(Archive()), throwsFormatException);
  });

  group('contents and links', () {
    test('the fixture novel: its nav document, a line per chapter', () {
      final zip = ZipDecoder().decodeBytes(
        File(FakeBookRepository.files['book-epub']!).readAsBytesSync(),
      );
      final book = EpubBook.read(zip);
      expect(book.toc.map((e) => '$e'), [
        'Chapter One -> OEBPS/chapter1.xhtml',
        'Chapter Two -> OEBPS/chapter2.xhtml',
        'Chapter Three -> OEBPS/chapter3.xhtml',
      ]);
    });

    test('nested nav lists; the toc nav, not the landmarks', () {
      final book = EpubBook.read(
        buildEpub(
          ['<p>a</p>', '<p>b</p>'],
          nav:
              '<nav epub:type="landmarks"><ol><li><a href="text/ch1.xhtml">'
              'Start</a></li></ol></nav>'
              '<nav epub:type="toc"><ol>'
              '<li><a href="text/ch0.xhtml">Part   One</a><ol>'
              '<li><a href="text/ch1.xhtml#s2">A section</a></li></ol></li>'
              '<li><span>No link</span></li>'
              '<li><a href="https://example.com/">Web</a></li>'
              '</ol></nav>',
        ),
      );
      expect(book.toc.map((e) => '$e'), [
        'Part One -> OEBPS/text/ch0.xhtml',
        '  A section -> OEBPS/text/ch1.xhtml#s2',
      ]);
    });

    test('an EPUB 2 NCX, when there is no nav document', () {
      final book = EpubBook.read(
        buildEpub(
          ['<p>a</p>', '<p>b</p>'],
          ncx:
              '<navPoint id="n1"><navLabel><text>First</text></navLabel>'
              '<content src="text/ch0.xhtml"/>'
              '<navPoint id="n2"><navLabel><text>Inner</text></navLabel>'
              '<content src="text/ch1.xhtml#x"/></navPoint></navPoint>',
        ),
      );
      expect(book.toc.map((e) => '$e'), [
        'First -> OEBPS/text/ch0.xhtml',
        '  Inner -> OEBPS/text/ch1.xhtml#x',
      ]);
    });

    test('a broken NCX: no contents, the book still reads', () {
      final book = EpubBook.read(buildEpub(['<p>a</p>'], ncx: '<navPoint>'));
      expect(book.toc, isEmpty);
      expect(book.chapters, hasLength(1));
    });

    test('links keep their target; links out of the book are not kept', () {
      final [block as TextBlock] = chapterBlocks(
        '<p>See <a href="notes.xhtml#n1">note 1</a>, <a href="#here">here</a>'
            ' and <a href="https://example.com">the web</a>.</p>',
        'OEBPS/text/ch0.xhtml',
      );
      expect(block.runs.map((r) => '$r'), [
        '"See "',
        'link OEBPS/text/notes.xhtml#n1:"note 1"',
        '", "',
        'link OEBPS/text/ch0.xhtml#here:"here"',
        '" and "',
        '"the web"',
        '"."',
      ]);
    });

    test('ids and offsets: where a target starts in the book', () {
      final book = EpubBook.read(
        buildEpub([
          '<p>12345</p>',
          '<p>abc</p><h2 id="two">Two</h2><p>x <span id="mid">y</span></p>'
              '<img src="missing.png"/><p id="after">z</p>',
        ]),
      );
      final ch1 = book.chapters[1];
      // Blocks: "abc", "Two", "x y", "z" (the missing image dropped).
      expect(ch1.anchors, {'two': 1, 'mid': 2, 'after': 3});
      expect(book.length, 5 + 3 + 3 + 3 + 1);
      expect(book.offsetOf('OEBPS/text/ch0.xhtml'), 0);
      expect(book.offsetOf('OEBPS/text/ch1.xhtml'), 5);
      expect(book.offsetOf('OEBPS/text/ch1.xhtml#two'), 8);
      expect(book.offsetOf('OEBPS/text/ch1.xhtml#mid'), 11);
      expect(book.offsetOf('OEBPS/text/ch1.xhtml#after'), 14);
      // Unknown fragment: its chapter; unknown file: nowhere.
      expect(book.offsetOf('OEBPS/text/ch1.xhtml#nope'), 5);
      expect(book.offsetOf('OEBPS/text/other.xhtml'), isNull);
    });
  });
}
