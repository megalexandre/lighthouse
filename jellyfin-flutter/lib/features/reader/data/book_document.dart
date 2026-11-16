import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/failure.dart';
import 'book_format.dart';
import 'image_size.dart';

/// An open book, page by page.
abstract interface class BookDocument {
  int get pageCount;

  /// Page [index] (0-based), fitted to the space it gets.
  Widget buildPage(int index);

  /// Page [index] as an image about [maxSize] pixels (aspect kept), for
  /// the page-turn animation, which bends pictures, not widgets.
  Future<ui.Image> pageImage(int index, Size maxSize);

  /// Width ÷ height of page [index]: the sheet that turns has its shape.
  double pageAspectRatio(int index);

  Future<void> dispose();
}

/// The book [file] opened for reading. Throws [NotReadable] for a format
/// the reader does not handle (yet).
///
/// A PDF stays on disk (PDFium reads what it needs); only its first bytes
/// are read here. A comic is read and unzipped in another isolate, so a
/// big one does not freeze the screen.
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
        BookFormat.epub => throw const NotReadable('EPUB'),
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
class ComicBookDocument implements BookDocument {
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

  @override
  Widget buildPage(int index) =>
      Image.memory(_pages[index], fit: BoxFit.contain, gaplessPlayback: true);

  @override
  Future<ui.Image> pageImage(int index, Size maxSize) async {
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
class PdfBookDocument implements BookDocument {
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

  @override
  Widget buildPage(int index) => PdfPageView(
    document: _document,
    pageNumber: index + 1,
    decoration: const BoxDecoration(color: Colors.white),
  );

  @override
  Future<ui.Image> pageImage(int index, Size maxSize) async {
    final page = _document.pages[index];
    final fit = _fit(Size(page.width, page.height), maxSize);
    final rendered = await page.render(
      fullWidth: fit.width,
      fullHeight: fit.height,
      backgroundColor: 0xFFFFFFFF,
    );
    if (rendered == null) throw StateError('PDFium could not draw page $index');
    try {
      return await rendered.createImage();
    } finally {
      rendered.dispose();
    }
  }

  @override
  Future<void> dispose() => _document.dispose();
}
