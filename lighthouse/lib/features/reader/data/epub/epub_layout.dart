import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../book_document.dart' show PageBadge, PageMark;
import '../image_size.dart';
import 'epub_book.dart';

/// How the reader sets an EPUB's type: one size for the whole book, as
/// Play Books does (the publisher's CSS is not followed). The colour is not
/// part of it: pages are laid out once and drawn in any ink
/// ([EpubLayout.paint]) without laying them out again.
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

  /// The blank border of a page of [size]: wider on a big page, and never
  /// narrower than [keepClear].
  EdgeInsets margins(Size size, {EdgeInsets keepClear = EdgeInsets.zero}) {
    final horizontal = (size.width * 0.08).clamp(16.0, 64.0);
    final vertical = (size.height * 0.06).clamp(16.0, 56.0);
    return EdgeInsets.fromLTRB(
      math.max(horizontal, keepClear.left),
      math.max(vertical, keepClear.top),
      math.max(horizontal, keepClear.right),
      math.max(vertical, keepClear.bottom),
    );
  }

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
  EpubLayout(
    this.book,
    this.size, {
    this.typography = const EpubTypography(),
    this.keepClear = EdgeInsets.zero,
  }) {
    _paginate();
  }

  final EpubBook book;
  final Size size;
  final EpubTypography typography;

  /// The least blank border (a page under the system's bars and the notch).
  final EdgeInsets keepClear;

  final pages = <EpubPage>[];
  final _painters = <TextPainter>[];

  /// Characters in the whole book (an image counts as one).
  int get length => _length;
  int _length = 0;

  late final EdgeInsets margins = typography.margins(
    size,
    keepClear: keepClear,
  );
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
        TextPiece(
          painter,
          Offset(indent, _y),
          tops[i],
          tops[j],
          links: links,
          textStart: start,
          textLength: textLength,
          markerLength: markerLength,
        ),
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
    List<PageMark> marks = const [],
  }) {
    final pieces = pages[index].pieces;
    canvas
      ..save()
      ..translate(margins.left, margins.top);
    // Under the text, as a marker on paper.
    for (final mark in marks) {
      final paint = Paint()..color = mark.color;
      for (final rect in _rects(index, mark.start, mark.end)) {
        canvas.drawRect(rect, paint);
      }
    }
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
    // The text straight in the ink, not laid out black and recoloured in a
    // layer: on Android's Vulkan renderer such a layer left a grey copy of
    // every letter a few pixels below it.
    for (final piece in pieces) {
      switch (piece) {
        case TextPiece(:final painter, :final at, :final top, :final bottom):
          _inked(painter, ink);
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
              ..color = ink.withValues(alpha: 0.4)
              ..strokeWidth = 1,
          );
        case ImagePiece():
          break;
      }
    }
    // Over the text: a voice note's button.
    for (final mark in marks) {
      final badge = mark.badge;
      final circle = badge == null ? null : _badge(index, mark.start, mark.end);
      if (badge == null || circle == null) continue;
      _paintBadge(canvas, circle, mark.color.withValues(alpha: 1), badge);
    }
    canvas.restore();
  }

  /// A round button in [color]: a white triangle (play) or square (stop).
  void _paintBadge(Canvas canvas, Rect circle, Color color, PageBadge badge) {
    final r = circle.width / 2;
    final c = circle.center;
    canvas
      // A white rim keeps it apart from the text and any paper.
      ..drawCircle(c, r + 1.5, Paint()..color = const Color(0xFFFFFFFF))
      ..drawCircle(c, r, Paint()..color = color);
    final white = Paint()..color = const Color(0xFFFFFFFF);
    switch (badge) {
      case PageBadge.play:
        // Nudged right: a triangle looks centred by its weight, not its box.
        final s = r * 0.5;
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - s * 0.7, c.dy - s)
            ..lineTo(c.dx + s * 1.1, c.dy)
            ..lineTo(c.dx - s * 0.7, c.dy + s)
            ..close(),
          white,
        );
      case PageBadge.stop:
        canvas.drawRect(
          Rect.fromCenter(center: c, width: r * 0.8, height: r * 0.8),
          white,
        );
    }
  }

  /// Where a mark over book characters [start] to [end] has its badge on
  /// page [index], on the whole page (see [BookDocument.badgeOf]).
  Rect? badgeOf(int index, int start, int end) =>
      _badge(index, start, end)?.shift(Offset(margins.left, margins.top));

  /// As [badgeOf], on the content area: past the end of the range's last
  /// line, raised to its top, kept on the page.
  Rect? _badge(int index, int start, int end) {
    if (index < 0 || index >= pages.length) return null;
    // Only on the page where the range ends.
    final next = index + 1 < pages.length ? pages[index + 1].start : _length;
    if (end > next) return null;
    final rects = _rects(index, start, end);
    if (rects.isEmpty) return null;
    final last = rects.reduce(
      (a, b) => (b.top > a.top + 1 || (b.top >= a.top - 1 && b.right > a.right))
          ? b
          : a,
    );
    final r = typography.fontSize * 0.5;
    final x = (last.right + r * 0.5).clamp(
      r - margins.left + 2,
      content.width + margins.right - r - 2,
    );
    // Its centre near the line's top, in the leading above the letters.
    final y = math.max(last.top - r * 0.3, r - margins.top + 2);
    return Rect.fromCircle(center: Offset(x.toDouble(), y), radius: r);
  }

  /// [painter] in [ink]. Only the colour changes, which needs no new
  /// layout: the paragraph is only built again for painting, and its
  /// lines stay where they were.
  void _inked(TextPainter painter, Color ink) {
    final text = painter.text! as TextSpan;
    if (text.style?.color == ink) return;
    painter.text = TextSpan(
      style: text.style?.copyWith(color: ink),
      children: text.children,
    );
  }

  // --- Selecting text -------------------------------------------------------

  /// The paragraph band on page [index] nearest [p] (on the content area),
  /// and how far [p] is from it.
  (TextPiece, double)? _nearest(int index, Offset p) {
    (TextPiece, double)? best;
    for (final piece in pages[index].pieces.whereType<TextPiece>()) {
      final r = piece.shown;
      final dx = math.max(math.max(r.left - p.dx, p.dx - r.right), 0.0);
      final dy = math.max(math.max(r.top - p.dy, p.dy - r.bottom), 0.0);
      final distance = math.sqrt(dx * dx + dy * dy);
      if (best == null || distance < best.$2) best = (piece, distance);
    }
    return best;
  }

  /// The text under [point] (on page [index], at this layout's size): its
  /// band, and the position in its painter. [near]: the nearest text on
  /// the page when there is none right there (to drag a selection past
  /// the last line).
  (TextPiece, int)? _hit(int index, Offset point, {required bool near}) {
    final p = point - Offset(margins.left, margins.top);
    final (piece, distance) = _nearest(index, p) ?? (null, 0.0);
    if (piece == null || (!near && distance > 4)) return null;
    final shown = piece.shown;
    // Kept inside the band: a point above it would be in the paragraph's
    // lines on the page before.
    final inside = Offset(
      p.dx.clamp(shown.left, shown.right),
      p.dy.clamp(
        shown.top + 0.5,
        math.max(shown.top + 0.5, shown.bottom - 0.5),
      ),
    );
    final local = inside - piece.at + Offset(0, piece.top);
    return (piece, piece.painter.getPositionForOffset(local).offset);
  }

  /// The book character at [point] on page [index] (the caret's place
  /// before it); null off the text, unless [near].
  int? offsetAt(int index, Offset point, {bool near = false}) {
    final (piece, position) = _hit(index, point, near: near) ?? (null, 0);
    return piece?.toBook(position);
  }

  /// The word at [point] on page [index], in book characters; null off the
  /// text or between words.
  TextRange? wordAt(int index, Offset point) {
    final (piece, position) = _hit(index, point, near: false) ?? (null, 0);
    if (piece == null) return null;
    final text = piece.painter.plainText;
    // The character under the point, not the caret after it.
    var at = position;
    if (at >= text.length || (at > 0 && text[at].trim().isEmpty)) at--;
    if (at < piece.markerLength || text[at].trim().isEmpty) return null;
    final word = piece.painter.getWordBoundary(TextPosition(offset: at));
    final range = TextRange(
      start: piece.toBook(word.start),
      end: piece.toBook(word.end),
    );
    return range.isCollapsed ? null : range;
  }

  /// Where book characters [start] to [end] are drawn on page [index], one
  /// box per line, on the whole page (margins included).
  List<Rect> rectsOf(int index, int start, int end) => [
    for (final r in _rects(index, start, end))
      r.shift(Offset(margins.left, margins.top)),
  ];

  /// As [rectsOf], on the content area.
  List<Rect> _rects(int index, int start, int end) {
    final rects = <Rect>[];
    if (index < 0 || index >= pages.length || end <= start) return rects;
    for (final piece in pages[index].pieces.whereType<TextPiece>()) {
      final from = math.max(start, piece.textStart);
      final to = math.min(end, piece.textStart + piece.textLength);
      if (to <= from) continue;
      final boxes = piece.painter.getBoxesForSelection(
        TextSelection(
          baseOffset: piece.toPainter(from),
          extentOffset: piece.toPainter(to),
        ),
      );
      for (final box in boxes) {
        final r = box.toRect();
        // Only the lines on this page.
        if (r.bottom <= piece.top + 0.5 || r.top >= piece.bottom - 0.5) {
          continue;
        }
        rects.add(r.shift(piece.at - Offset(0, piece.top)));
      }
    }
    return rects;
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
    this.textStart = 0,
    this.textLength = 0,
    this.markerLength = 0,
  });

  final TextPainter painter;
  final Offset at;
  final double top;
  final double bottom;

  /// The book character the paragraph starts at, and how many it has.
  final int textStart;
  final int textLength;

  /// The list marker before the text in [painter] ("• "), not part of the
  /// book's characters.
  final int markerLength;

  /// The band of the paragraph shown, on the page's content area.
  Rect get shown => at & Size(painter.width, bottom - top);

  /// [book] (a book character) as a position in [painter]'s text.
  int toPainter(int book) =>
      (book - textStart).clamp(0, textLength) + markerLength;

  /// [position] in [painter]'s text as a book character.
  int toBook(int position) =>
      textStart + (position - markerLength).clamp(0, textLength);

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
