import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// What kind of book a file is, told by its content (the server's names
/// and types vary; the bytes do not).
enum BookFormat {
  pdf,

  /// A zip of page images (.cbz).
  comic,

  /// A zip with an EPUB package (mimetype application/epub+zip).
  epub,

  /// Anything else (e.g. .cbr, a RAR: not read yet).
  unknown,
}

/// The format of a book file, from its first bytes (and, for a zip, from
/// its EPUB "mimetype" entry).
BookFormat detectBookFormat(Uint8List bytes) => switch (headFormat(bytes)) {
  HeadFormat.pdf => BookFormat.pdf,
  HeadFormat.zip => readZipBook(bytes).format,
  HeadFormat.unknown => BookFormat.unknown,
};

/// What the first bytes of a file say: enough to tell a PDF (opened from
/// the file, not read into memory) from a zip (read whole, see
/// [readZipBook]). [headLength] bytes are enough.
enum HeadFormat { pdf, zip, unknown }

const headLength = 8;

HeadFormat headFormat(Uint8List head) {
  if (_startsWith(head, '%PDF-')) return HeadFormat.pdf;
  if (_startsWith(head, 'PK\u0003\u0004')) return HeadFormat.zip;
  return HeadFormat.unknown;
}

/// What a zip book holds: [BookFormat.epub], [BookFormat.comic] with its
/// page images in reading order, or [BookFormat.unknown] (no images, or
/// not a readable zip). Plain data, so it can come back from an isolate.
typedef ZipBook = ({BookFormat format, List<Uint8List> pages});

ZipBook readZipBook(Uint8List bytes) {
  const none = (format: BookFormat.unknown, pages: <Uint8List>[]);
  try {
    final zip = ZipDecoder().decodeBytes(bytes);
    final mimetype = zip.findFile('mimetype');
    if (mimetype != null &&
        utf8.decode(mimetype.content).trim() == 'application/epub+zip') {
      return (format: BookFormat.epub, pages: <Uint8List>[]);
    }
    final pages = [for (final f in comicPages(zip)) f.content];
    return pages.isEmpty ? none : (format: BookFormat.comic, pages: pages);
  } on Object {
    return none;
  }
}

bool _startsWith(Uint8List bytes, String prefix) {
  if (bytes.length < prefix.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (bytes[i] != prefix.codeUnitAt(i)) return false;
  }
  return true;
}

const _imageExtensions = {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'};

/// The page images of a comic, in reading order: by name, numbers compared
/// as numbers ("page2" before "page10"), folders and other files left out.
List<ArchiveFile> comicPages(Archive zip) {
  final pages = [
    for (final f in zip.files)
      if (f.isFile &&
          !f.name.split('/').last.startsWith('.') &&
          _imageExtensions.any((e) => f.name.toLowerCase().endsWith(e)))
        f,
  ]..sort((a, b) => compareNatural(a.name, b.name));
  return pages;
}

final _chunk = RegExp(r'\d+|\D+');

/// Compares [a] and [b] with runs of digits taken as numbers.
int compareNatural(String a, String b) {
  final pa = _chunk.allMatches(a.toLowerCase()).map((m) => m[0]!).toList();
  final pb = _chunk.allMatches(b.toLowerCase()).map((m) => m[0]!).toList();
  for (var i = 0; i < pa.length && i < pb.length; i++) {
    final (x, y) = (pa[i], pb[i]);
    final (nx, ny) = (int.tryParse(x), int.tryParse(y));
    final c = nx != null && ny != null ? nx.compareTo(ny) : x.compareTo(y);
    if (c != 0) return c;
  }
  return pa.length.compareTo(pb.length);
}
