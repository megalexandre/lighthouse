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
}
