import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/failure.dart';
import 'book_format.dart';
import 'epub/epub_book.dart';
import 'epub/epub_document.dart';
import 'epub/epub_layout.dart';
import 'image_size.dart';

/// The colours a page is shown in (the reader's theme): text in [ink] on
/// [paper]. Pictures (comics, an EPUB's images) keep theirs.
@immutable
class PageColors {
  const PageColors({required this.paper, required this.ink});

  /// Black on white: pages as the file has them.
  static const plain = PageColors(
    paper: Color(0xFFFFFFFF),
    ink: Color(0xFF202124),
  );

  final Color paper;
  final Color ink;

  /// For a page drawn black on white (a PDF): white becomes [paper],
  /// black [ink], and every colour in between in proportion. Null for
  /// [plain] (nothing to change).
  ColorFilter? get recolor {
    if (this == plain) return null;
    // Out = ink + (paper − ink) × in, per channel (the bias is in 0..255).
    List<double> row(int channel, double i, double p) => [
      for (var c = 0; c < 3; c++) c == channel ? p - i : 0,
      0,
      i * 255,
    ];
    return ColorFilter.matrix([
      ...row(0, ink.r, paper.r),
      ...row(1, ink.g, paper.g),
      ...row(2, ink.b, paper.b),
      0, 0, 0, 1, 0, //
    ]);
  }

  @override
  bool operator ==(Object other) =>
      other is PageColors && other.paper == paper && other.ink == ink;

  @override
  int get hashCode => Object.hash(paper, ink);
}

/// A line of a book's table of contents: [title], going to [fraction] of
/// the book (see [BookDocument.pageAt]); [depth] 0 for the top level.
@immutable
class TocEntry {
  const TocEntry(this.title, this.fraction, {this.depth = 0});

  final String title;
  final double fraction;
  final int depth;

  @override
  String toString() => '${'  ' * depth}$title @ $fraction';
}

/// An open book, page by page.
abstract interface class BookDocument {
  int get pageCount;

  /// Page [index] (0-based) in [colors], fitted to the space it gets.
  Widget buildPage(int index, PageColors colors);

  /// Page [index] in [colors] as an image about [maxSize] pixels (aspect
  /// kept), for the page-turn animation, which bends pictures, not
  /// widgets. Where the page is empty it may be transparent (the paper
  /// shows through).
  Future<ui.Image> pageImage(int index, Size maxSize, PageColors colors);

  /// Width ÷ height of page [index]: the sheet that turns has its shape.
  double pageAspectRatio(int index);

  /// Whether the pages depend on the space they get (an EPUB): such a
  /// book has no pages until [layout], and new ones whenever the size
  /// changes. A PDF or a comic has its pages ([FixedPages]).
  bool get reflowable;

  /// Cuts the book into pages of [size] (logical pixels), its type set as
  /// [typography] says and out of the border [keepClear]. True when the
  /// pages changed.
  bool layout(Size size, EpubTypography typography, {EdgeInsets keepClear});

  /// Changes whenever the pages do: pictures of the old ones are stale.
  int get layoutVersion;

  /// How far into the book page [index] starts, from 0 to 1: the place as
  /// the server keeps it, whatever the pages.
  double fractionOf(int index);

  /// The page at [fraction] of the book.
  int pageAt(double fraction);

  /// The table of contents; empty when the book has none.
  Future<List<TocEntry>> contents();

  /// Where a link at [at] on page [index] goes, as a fraction of the book
  /// (see [pageAt]); null when there is no link there. [at] is in the
  /// page's own unit square: (0, 0) top left, (1, 1) bottom right.
  double? linkAt(int index, Offset at);

  Future<void> dispose();
}

/// A book whose pages are what the file says (PDF, comic).
mixin FixedPages implements BookDocument {
  @override
  bool get reflowable => false;

  @override
  bool layout(
    Size size,
    EpubTypography typography, {
    EdgeInsets keepClear = EdgeInsets.zero,
  }) => false;

  @override
  int get layoutVersion => 0;

  @override
  double fractionOf(int index) => pageCount == 0 ? 0 : index / pageCount;

  @override
  int pageAt(double fraction) => pageCount == 0
      ? 0
      : (fraction * pageCount).round().clamp(0, pageCount - 1);

  @override
  Future<List<TocEntry>> contents() async => const [];

  @override
  double? linkAt(int index, Offset at) => null;
}

/// The book [file] opened for reading. Throws [NotReadable] for a format
/// the reader does not handle (yet).
///
/// A PDF stays on disk (PDFium reads what it needs); only its first bytes
/// are read here. A comic or an EPUB is read, unzipped and parsed in
/// another isolate, so a big one does not freeze the screen.
Future<BookDocument> openBook(File file) async {
  final head = await _readHead(file);
  switch (headFormat(head)) {
    case HeadFormat.pdf:
      return PdfBookDocument.open(file.path);
    case HeadFormat.unknown:
      throw const NotReadable('this file type');
    case HeadFormat.zip:
      final path = file.path;
      final zip = await Isolate.run(
        () => readZipBook(File(path).readAsBytesSync()),
      );
      return switch (zip.format) {
        BookFormat.comic => ComicBookDocument(zip.pages),
        BookFormat.epub => switch (zip.epub) {
          final EpubBook book => EpubBookDocument(book),
          null => throw const NotReadable('this EPUB file'),
        },
        _ => throw const NotReadable('this file type'),
      };
  }
}

Future<Uint8List> _readHead(File file) async {
  final raf = await file.open();
  try {
    return await raf.read(headLength);
  } finally {
    await raf.close();
  }
}

/// A comic: each page is an image in the zip.
class ComicBookDocument with FixedPages implements BookDocument {
  /// The page images, encoded (PNG, JPEG...), in reading order.
  ComicBookDocument(this._pages);

  final List<Uint8List> _pages;

  @override
  int get pageCount => _pages.length;

  @override
  double pageAspectRatio(int index) {
    final size = encodedImageSize(_pages[index]);
    return size == null || size.height == 0 ? 2 / 3 : size.width / size.height;
  }

  /// Drawings keep their colours, whatever the theme. A small one grows to
  /// the space it gets, as [pageImage] does.
  @override
  Widget buildPage(int index, PageColors colors) => SizedBox.expand(
    child: Image.memory(
      _pages[index],
      fit: BoxFit.contain,
      gaplessPlayback: true,
    ),
  );

  @override
  Future<ui.Image> pageImage(int index, Size maxSize, PageColors colors) async {
    // The size from the header (ImageDescriptor does not decode), then one
    // decode straight at the size needed, not at full scan resolution.
    final buffer = await ui.ImmutableBuffer.fromUint8List(_pages[index]);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    try {
      final fit = _fit(
        Size(descriptor.width.toDouble(), descriptor.height.toDouble()),
        maxSize,
      );
      final codec = await descriptor.instantiateCodec(
        targetWidth: fit.width.round(),
        targetHeight: fit.height.round(),
      );
      try {
        return (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
    } finally {
      descriptor.dispose();
      buffer.dispose();
    }
  }

  @override
  Future<void> dispose() async {}
}

/// [natural] scaled to fit in [box], aspect kept.
Size _fit(Size natural, Size box) {
  final scale = [
    box.width / natural.width,
    box.height / natural.height,
  ].reduce((a, b) => a < b ? a : b);
  return Size(
    (natural.width * scale).clamp(1, double.infinity),
    (natural.height * scale).clamp(1, double.infinity),
  );
}

/// A PDF, drawn by PDFium (pdfrx).
class PdfBookDocument with FixedPages implements BookDocument {
  PdfBookDocument._(this._document);

  static Future<PdfBookDocument> open(String path) async {
    await pdfrxFlutterInitialize();
    return PdfBookDocument._(await PdfDocument.openFile(path));
  }

  final PdfDocument _document;

  @override
  int get pageCount => _document.pages.length;

  @override
  double pageAspectRatio(int index) {
    final page = _document.pages[index];
    return page.height == 0 ? 2 / 3 : page.width / page.height;
  }

  /// The page is drawn black on white, then recoloured (see
  /// [PageColors.recolor]): in the dark theme a PDF reads light on dark.
  @override
  Widget buildPage(int index, PageColors colors) {
    final page = PdfPageView(
      document: _document,
      pageNumber: index + 1,
      decoration: const BoxDecoration(color: Colors.white),
    );
    final recolor = colors.recolor;
    return recolor == null
        ? page
        : ColorFiltered(colorFilter: recolor, child: page);
  }

  @override
  Future<ui.Image> pageImage(int index, Size maxSize, PageColors colors) async {
    final page = _document.pages[index];
    final fit = _fit(Size(page.width, page.height), maxSize);
    final rendered = await page.render(
      fullWidth: fit.width,
      fullHeight: fit.height,
      backgroundColor: 0xFFFFFFFF,
    );
    if (rendered == null) throw StateError('PDFium could not draw page $index');
    final ui.Image image;
    try {
      image = await rendered.createImage();
    } finally {
      rendered.dispose();
    }
    final recolor = colors.recolor;
    if (recolor == null) return image;
    try {
      final recorder = ui.PictureRecorder();
      Canvas(recorder)
          .drawImage(image, Offset.zero, Paint()..colorFilter = recolor);
      final picture = recorder.endRecording();
      try {
        return await picture.toImage(image.width, image.height);
      } finally {
        picture.dispose();
      }
    } finally {
      image.dispose();
    }
  }

  /// The PDF's outline (bookmarks), when it has one.
  @override
  Future<List<TocEntry>> contents() async {
    final entries = <TocEntry>[];
    void walk(List<PdfOutlineNode> nodes, int depth) {
      for (final node in nodes) {
        final page = node.dest?.pageNumber;
        final title = node.title.trim();
        if (page != null && title.isNotEmpty) {
          entries.add(TocEntry(title, fractionOf(page - 1), depth: depth));
        }
        walk(node.children, depth + 1);
      }
    }

    walk(await _document.loadOutline(), 0);
    return entries;
  }

  @override
  Future<void> dispose() => _document.dispose();
}
