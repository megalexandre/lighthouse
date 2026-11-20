import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../image_size.dart';
import 'epub_book.dart';

/// How the reader sets an EPUB's type: one size for the whole book, as
/// Play Books does (the publisher's CSS is not followed). The colour is not
/// part of it: pages are laid out once and drawn in any ink
/// ([EpubLayout.paint]).
@immutable
class EpubTypography {
  const EpubTypography({
    this.fontSize = 18,
    this.lineHeight = 1.45,
    this.fontFamily = 'Noto Sans',
    this.letterSpacing = 0,
    this.justify = true,
  });

  final double fontSize;

  /// Line height, as a multiple of [fontSize].
  final double lineHeight;

  /// A bundled family (pubspec.yaml), or a generic one ("serif") that the
  /// system (fontconfig) resolves.
  final String fontFamily;

  /// Extra space between letters, in logical pixels.
  final double letterSpacing;

  /// Body text justified, or flush left.
  final bool justify;

  /// The blank border of a page of [size]: wider on a big page.
  EdgeInsets margins(Size size) => EdgeInsets.symmetric(
    horizontal: (size.width * 0.08).clamp(16, 64),
    vertical: (size.height * 0.06).clamp(16, 56),
  );

  double headingScale(int level) => switch (level) {
    1 => 1.6,
    2 => 1.4,
    3 => 1.2,
    _ => 1.1,
  };

  /// The space left for each step of [TextBlock.indent].
  double get indentStep => fontSize * 1.5;

  @override
  bool operator ==(Object other) =>
      other is EpubTypography &&
      other.fontSize == fontSize &&
      other.lineHeight == lineHeight &&
      other.fontFamily == fontFamily &&
      other.letterSpacing == letterSpacing &&
      other.justify == justify;

  @override
  int get hashCode =>
      Object.hash(fontSize, lineHeight, fontFamily, letterSpacing, justify);
}

/// An [EpubBook] cut into pages of one [size]. Each chapter starts a page;
/// a paragraph that does not fit goes on over the next page, cut between
/// two lines, which stay exactly as laid out (one layout per paragraph,
/// each page shows a band of it).
///
/// Where a page is in the book is told in characters ([EpubPage.start] of
/// [length]): unlike page numbers, that does not change with the size, so
/// the place survives a resize, and its fraction is what the server keeps.
class EpubLayout {
  EpubLayout(this.book, this.size, {this.typography = const EpubTypography()}) {
    _paginate();
  }

  final EpubBook book;
  final Size size;
  final EpubTypography typography;

  final pages = <EpubPage>[];
  final _painters = <TextPainter>[];

  /// Characters in the whole book (an image counts as one).
  int get length => _length;
  int _length = 0;

  late final EdgeInsets margins = typography.margins(size);
  late final Size content = margins.deflateSize(size);

  /// How far into the book page [index] starts, from 0 to 1.
  double fractionOf(int index) =>
      _length == 0 ? 0 : pages[index].start / _length;

  /// The page holding the character at [fraction] of the book.
  int pageAt(double fraction) {
    // Rounded: a page's own fraction, back from the server, comes back as
    // a hair under its first character.
    final target = (fraction.clamp(0.0, 1.0) * _length).round();
    var low = 0;
    var high = pages.length - 1;
    while (low < high) {
      final mid = (low + high + 1) >> 1;
      if (pages[mid].start <= target) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    return low;
  }

  void dispose() {
    for (final p in _painters) {
      p.dispose();
    }
    _painters.clear();
  }

  // --- Cutting into pages ---------------------------------------------------

  var _pieces = <PagePiece>[];
  int? _pageStart;
  double _y = 0;

  void _newPage() {
    if (_pieces.isEmpty) return;
    pages.add(EpubPage(_pageStart ?? _length, _pieces));
    _pieces = [];
    _pageStart = null;
    _y = 0;
  }

  void _add(PagePiece piece, int start) {
    _pageStart ??= start;
    _pieces.add(piece);
  }

  void _paginate() {
    for (final chapter in book.chapters) {
      _newPage();
      for (final block in chapter.blocks) {
        switch (block) {
          case TextBlock():
            _text(block);
          case ImageBlock():
            _image(block);
          case RuleBlock():
            _rule();
        }
      }
    }
    _newPage();
    if (pages.isEmpty) pages.add(const EpubPage(0, []));
  }

  /// Space before a block, unless it starts the page.
  void _space(double space) {
    if (_y == 0) return;
    if (_y + space >= content.height) {
      _newPage();
    } else {
      _y += space;
    }
  }

  void _text(TextBlock block) {
    final t = typography;
    final heading = block.kind == TextKind.heading;
    final fontSize = heading
        ? t.fontSize * t.headingScale(block.level)
        : t.fontSize;
    final base = TextStyle(
      fontFamily: block.kind == TextKind.preformatted
          ? 'monospace'
          : t.fontFamily,
      fontSize: block.kind == TextKind.preformatted
          ? fontSize * 0.85
          : fontSize,
      height: t.lineHeight,
      letterSpacing: block.kind == TextKind.preformatted
          ? null
          : t.letterSpacing,
      // Laid out black; drawn in the ink asked for (see [paint]).
      color: const Color(0xFF000000),
      fontWeight: heading ? FontWeight.bold : null,
    );
    final indent = block.indent * t.indentStep;
    final width = math.max(content.width - indent, t.fontSize * 4);
    final painter = TextPainter(
      text: TextSpan(
        style: base,
        children: [
          if (block.marker case final marker?) TextSpan(text: '$marker '),
          for (final run in block.runs)
            TextSpan(
              text: run.text,
              style: TextStyle(
                fontWeight: run.bold ? FontWeight.bold : null,
                fontStyle: run.italic ? FontStyle.italic : null,
                fontFamily: run.mono ? 'monospace' : null,
              ),
            ),
        ],
      ),
      textAlign: block.centered || heading
          ? TextAlign.center
          : block.kind == TextKind.preformatted || !t.justify
          ? TextAlign.left
          : TextAlign.justify,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: width, maxWidth: width);
    _painters.add(painter);

    // Where each line starts in the text (the marker is not counted).
    final markerLength = block.marker == null ? 0 : block.marker!.length + 1;

    // Where its links are in the painter's text.
    final links = <PieceLink>[];
    var offset = markerLength;
    for (final run in block.runs) {
      if (run.href case final href?) {
        links.add(PieceLink(offset, offset + run.text.length, href));
      }
      offset += run.text.length;
    }
    final lines = painter.computeLineMetrics();
    final tops = [0.0];
    for (final line in lines) {
      tops.add(tops.last + line.height);
    }
    int lineStart(int i) => math.max(
      0,
      painter
              .getPositionForOffset(Offset(0, tops[i] + lines[i].height / 2))
              .offset -
          markerLength,
    );

    final start = _length;
    final textLength = block.length;
    _length += textLength;

    _space(heading ? fontSize * 1.1 : t.fontSize * 0.6);
    var i = 0;
    while (i < lines.length) {
      var j = i;
      while (j < lines.length && tops[j + 1] - tops[i] <= content.height - _y) {
        j++;
      }
      if (j == i) {
        if (_y > 0) {
          _newPage();
          continue;
        }
        j = i + 1; // A line taller than the page: shown cut.
      }
      _add(
        TextPiece(painter, Offset(indent, _y), tops[i], tops[j], links: links),
        start + math.min(lineStart(i), textLength),
      );
      _y += tops[j] - tops[i];
      i = j;
      if (i < lines.length) _newPage();
    }
    // A heading is not left alone at the bottom of a page.
    _y += heading ? fontSize * 0.5 : 0;
  }

  void _image(ImageBlock block) {
    final bytes = book.images[block.path];
    final natural = bytes == null ? null : encodedImageSize(bytes);
    final start = _length;
    _length += block.length;
    if (natural == null || natural.width == 0 || natural.height == 0) return;
    // Never upscaled past twice its size, never larger than the page.
    final scale = [
      content.width / natural.width,
      content.height / natural.height,
      2.0,
    ].reduce(math.min);
    final shown = Size(natural.width * scale, natural.height * scale);
    _space(typography.fontSize * 0.6);
    if (_y + shown.height > content.height) _newPage();
    _add(
      ImagePiece(
        block.path,
        Offset((content.width - shown.width) / 2, _y) & shown,
      ),
      start,
    );
    _y += shown.height;
  }

  void _rule() {
    _space(typography.fontSize * 0.6);
    final height = typography.fontSize * 1.5;
    if (_y + height > content.height) _newPage();
    _add(RulePiece(_y + height / 2), _length);
    _y += height;
  }

  // --- Drawing --------------------------------------------------------------

  /// Draws page [index] on [canvas] at this layout's size: the text and
  /// rules in [ink], the images as they are (the paper is drawn under it).
  /// [images]: the decoded images the page shows (see [EpubPage.images]);
  /// one not there yet leaves its space empty.
  void paint(
    Canvas canvas,
    int index,
    Map<String, ui.Image> images, {
    Color ink = const Color(0xFF202124),
  }) {
    final pieces = pages[index].pieces;
    canvas
      ..save()
      ..translate(margins.left, margins.top);
    for (final piece in pieces.whereType<ImagePiece>()) {
      final image = images[piece.path];
      if (image == null) continue;
      canvas.drawImageRect(
        image,
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
        piece.rect,
        Paint()..filterQuality = FilterQuality.medium,
      );
    }
    // The text is laid out black: drawn in a layer that keeps its shape
    // (antialiasing too) and takes the ink's colour.
    canvas.saveLayer(
      Offset.zero & content,
      Paint()..colorFilter = ColorFilter.mode(ink, BlendMode.srcIn),
    );
    for (final piece in pieces) {
      switch (piece) {
        case TextPiece(:final painter, :final at, :final top, :final bottom):
          canvas
            ..save()
            ..clipRect(at & Size(painter.width, bottom - top))
            ..translate(at.dx, at.dy - top);
          painter.paint(canvas, Offset.zero);
          canvas.restore();
        case RulePiece(:final y):
          final w = content.width * 0.3;
          canvas.drawLine(
            Offset((content.width - w) / 2, y),
            Offset((content.width + w) / 2, y),
            Paint()
              ..color = const Color(0x66000000)
              ..strokeWidth = 1,
          );
        case ImagePiece():
          break;
      }
    }
    canvas
      ..restore()
      ..restore();
  }

  /// The link under [point] (on page [index], at this layout's size): its
  /// target, "path/in/zip#fragment"; null when there is none.
  String? linkAt(int index, Offset point) {
    final p = point - Offset(margins.left, margins.top);
    for (final piece in pages[index].pieces) {
      if (piece is! TextPiece || piece.links.isEmpty) continue;
      final shown =
          piece.at & Size(piece.painter.width, piece.bottom - piece.top);
      if (!shown.inflate(4).contains(p)) continue;
      // In the paragraph's own layout.
      final local = p - piece.at + Offset(0, piece.top);
      for (final link in piece.links) {
        final boxes = piece.painter.getBoxesForSelection(
          TextSelection(baseOffset: link.start, extentOffset: link.end),
        );
        for (final box in boxes) {
          final rect = box.toRect();
          // Only the part of it on this page.
          if (rect.bottom <= piece.top || rect.top >= piece.bottom) continue;
          if (rect.inflate(4).contains(local)) return link.href;
        }
      }
    }
    return null;
  }
}

/// One page: what it shows, and the book character it starts at.
@immutable
class EpubPage {
  const EpubPage(this.start, this.pieces);

  final int start;
  final List<PagePiece> pieces;

  /// The images the page shows, by path in the zip.
  Iterable<ImagePiece> get images => pieces.whereType<ImagePiece>();
}

sealed class PagePiece {
  const PagePiece();
}

/// Lines [top] to [bottom] (in the paragraph's own layout) of [painter],
/// drawn at [at] on the page's content area.
final class TextPiece extends PagePiece {
  const TextPiece(
    this.painter,
    this.at,
    this.top,
    this.bottom, {
    this.links = const [],
  });

  final TextPainter painter;
  final Offset at;
  final double top;
  final double bottom;

  /// The paragraph's links (all of them, on this page or not).
  final List<PieceLink> links;

  /// The text shown (for tests and debugging).
  String get text {
    final from = painter.getPositionForOffset(Offset(0, top + 1)).offset;
    final to = painter
        .getPositionForOffset(Offset(painter.width, bottom - 1))
        .offset;
    return painter.plainText.substring(from, math.max(from, to));
  }
}

/// A link in a paragraph: characters [start] to [end] of its painter's
/// text go to [href] (see [TextRun.href]).
@immutable
class PieceLink {
  const PieceLink(this.start, this.end, this.href);

  final int start;
  final int end;
  final String href;
}

final class ImagePiece extends PagePiece {
  const ImagePiece(this.path, this.rect);

  final String path;
  final Rect rect;
}

final class RulePiece extends PagePiece {
  const RulePiece(this.y);

  final double y;
}
