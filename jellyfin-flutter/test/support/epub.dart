import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// A small EPUB 3 in memory: [chapters] are the bodies of its XHTML files
/// (in reading order), [files] anything else (images), by path under
/// OEBPS/. [nav]: the body of an EPUB 3 nav document (OEBPS/nav.xhtml);
/// [ncx]: the navMap of an EPUB 2 NCX (OEBPS/toc.ncx).
Archive buildEpub(
  List<String> chapters, {
  Map<String, List<int>> files = const {},
  String title = 'A Book',
  String? nav,
  String? ncx,
}) {
  final manifest = StringBuffer();
  final spine = StringBuffer();
  if (nav != null) {
    manifest.write(
      '<item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" '
      'properties="nav"/>',
    );
  }
  if (ncx != null) {
    manifest.write(
      '<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>',
    );
  }
  for (var i = 0; i < chapters.length; i++) {
    manifest.write(
      '<item id="c$i" href="text/ch$i.xhtml" '
      'media-type="application/xhtml+xml"/>',
    );
    spine.write('<itemref idref="c$i"/>');
  }
  final zip = Archive()
    ..add(ArchiveFile.string('mimetype', 'application/epub+zip'))
    ..add(
      ArchiveFile.string(
        'META-INF/container.xml',
        '<?xml version="1.0"?><container version="1.0" '
            'xmlns="urn:oasis:names:tc:opendocument:xmlns:container">'
            '<rootfiles><rootfile full-path="OEBPS/content.opf" '
            'media-type="application/oebps-package+xml"/></rootfiles>'
            '</container>',
      ),
    )
    ..add(
      ArchiveFile.string(
        'OEBPS/content.opf',
        '<?xml version="1.0"?><package xmlns="http://www.idpf.org/2007/opf" '
            'version="3.0"><metadata '
            'xmlns:dc="http://purl.org/dc/elements/1.1/">'
            '<dc:title>$title</dc:title></metadata>'
            '<manifest>$manifest</manifest>'
            '<spine${ncx != null ? ' toc="ncx"' : ''}>$spine</spine></package>',
      ),
    );
  if (nav != null) {
    zip.add(
      ArchiveFile.string(
        'OEBPS/nav.xhtml',
        '<?xml version="1.0" encoding="utf-8"?>'
            '<html xmlns="http://www.w3.org/1999/xhtml" '
            'xmlns:epub="http://www.idpf.org/2007/ops"><head><title>toc'
            '</title></head><body>$nav</body></html>',
      ),
    );
  }
  if (ncx != null) {
    zip.add(
      ArchiveFile.string(
        'OEBPS/toc.ncx',
        '<?xml version="1.0" encoding="utf-8"?>'
            '<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">'
            '<navMap>$ncx</navMap></ncx>',
      ),
    );
  }
  for (var i = 0; i < chapters.length; i++) {
    zip.add(
      ArchiveFile.string(
        'OEBPS/text/ch$i.xhtml',
        '<?xml version="1.0" encoding="utf-8"?>'
            '<html xmlns="http://www.w3.org/1999/xhtml"><head><title>x</title>'
            '<style>p { color: red }</style></head>'
            '<body>${chapters[i]}</body></html>',
      ),
    );
  }
  for (final MapEntry(:key, :value) in files.entries) {
    zip.add(ArchiveFile.bytes('OEBPS/$key', Uint8List.fromList(value)));
  }
  return zip;
}

/// [buildEpub] as the bytes of a file.
Uint8List epubBytes(List<String> chapters, {Map<String, List<int>>? files}) =>
    Uint8List.fromList(
      ZipEncoder().encode(buildEpub(chapters, files: files ?? const {})),
    );

/// The smallest valid PNG header for a [width] × [height] image (enough
/// for layout, which reads only the size).
List<int> pngHeader(int width, int height) => [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0, 0, 0, 13, ...ascii.encode('IHDR'),
  width >> 24 & 0xFF, width >> 16 & 0xFF, width >> 8 & 0xFF, width & 0xFF,
  height >> 24 & 0xFF, height >> 16 & 0xFF, height >> 8 & 0xFF, height & 0xFF,
  8, 6, 0, 0, 0,
];
