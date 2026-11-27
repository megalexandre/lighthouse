import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:material_ui/material_ui.dart';

import '../book_document.dart';
import 'epub_book.dart';
import 'epub_layout.dart';

/// An EPUB in the reader: reflowable, so it has pages only once laid out
/// for a size ([layout]); the reader screen does that for the sheet it
/// shows, and again when the window changes.
class EpubBookDocument implements BookDocument {
  EpubBookDocument(this.book);

  final EpubBook book;

  /// The type of the current layout.
  EpubTypography get typography =>
      _layout?.typography ?? const EpubTypography();

  /// The blank border of the current layout's pages.
  EdgeInsets get margins => _layout?.margins ?? EdgeInsets.zero;

  EpubLayout? _layout;

  /// The layout before the current one, kept until the next change: a
  /// frame may still paint its pages while the screen catches up.
  EpubLayout? _retired;
  int _version = 0;

  /// Decoded images by path, the most recently used last. Users get
  /// clones (see [ui.Image.clone]), so one can be dropped from here while
  /// a page still shows it.
  final _decoded = <String, ui.Image>{};
  final _decoding = <String, Future<ui.Image?>>{};
  static const _keepDecoded = 8;

  /// Images are decoded at most this wide: enough for any page.
  static const _maxImageWidth = 2048;

  bool _disposed = false;

  EpubLayout get _current {
    final layout = _layout;
    if (layout == null) throw StateError('EPUB not laid out yet');
    return layout;
  }

  @override
  bool get reflowable => true;

  @override
  int get pageCount => _layout?.pages.length ?? 0;

  @override
  int get layoutVersion => _version;

  @override
  bool layout(
    Size size,
    EpubTypography typography, {
    EdgeInsets keepClear = EdgeInsets.zero,
  }) {
    if (size.isEmpty ||
        (_layout?.size == size &&
            _layout?.typography == typography &&
            _layout?.keepClear == keepClear)) {
      return false;
    }
    _retired?.dispose();
    _retired = _layout;
    _layout = EpubLayout(
      book,
      size,
      typography: typography,
      keepClear: keepClear,
    );
    _version++;
    return true;
  }

  @override
  double pageAspectRatio(int index) => _layout?.size.aspectRatio ?? 2 / 3;

  @override
  double fractionOf(int index) => _layout?.fractionOf(index) ?? 0;

  @override
  int pageAt(double fraction) => _layout?.pageAt(fraction) ?? 0;

  @override
  Future<List<TocEntry>> contents() async {
    final length = book.length;
    if (length == 0) return const [];
    final entries = [
      for (final entry in book.toc)
        if (book.offsetOf(entry.target) case final offset?)
          TocEntry(entry.title, offset / length, depth: entry.depth),
    ];
    if (entries.isNotEmpty) return entries;
    // No table of contents: each chapter that opens with a heading.
    var start = 0;
    for (final chapter in book.chapters) {
      if (chapter.blocks.firstOrNull case final TextBlock heading
          when heading.kind == TextKind.heading) {
        entries.add(TocEntry(heading.text, start / length));
      }
      start += chapter.length;
    }
    return entries;
  }

  @override
  double? linkAt(int index, Offset at) {
    final layout = _layout;
    if (layout == null || index < 0 || index >= layout.pages.length) {
      return null;
    }
    final href = layout.linkAt(
      index,
      Offset(at.dx * layout.size.width, at.dy * layout.size.height),
    );
    final offset = href == null ? null : book.offsetOf(href);
    if (offset == null || book.length == 0) return null;
    return offset / book.length;
  }

  @override
  bool get selectable => true;

  /// [at] in the unit square, at the current layout's size.
  Offset? _point(int index, Offset at) {
    final layout = _layout;
    if (layout == null || index < 0 || index >= layout.pages.length) {
      return null;
    }
    return Offset(at.dx * layout.size.width, at.dy * layout.size.height);
  }

  @override
  int? offsetAt(int index, Offset at, {bool near = false}) {
    final point = _point(index, at);
    return point == null ? null : _layout!.offsetAt(index, point, near: near);
  }

  @override
  TextRange? wordAt(int index, Offset at) {
    final point = _point(index, at);
    return point == null ? null : _layout!.wordAt(index, point);
  }

  @override
  List<Rect> rectsOf(int index, TextRange range) {
    final layout = _layout;
    if (layout == null) return const [];
    final size = layout.size;
    return [
      for (final r in layout.rectsOf(index, range.start, range.end))
        Rect.fromLTRB(
          r.left / size.width,
          r.top / size.height,
          r.right / size.width,
          r.bottom / size.height,
        ),
    ];
  }

  @override
  double fractionAt(int offset) =>
      book.length == 0 ? 0 : (offset / book.length).clamp(0.0, 1.0);

  @override
  String textOf(TextRange range) {
    final parts = <String>[];
    var start = 0;
    for (final chapter in book.chapters) {
      if (start >= range.end) break;
      if (start + chapter.length <= range.start) {
        start += chapter.length;
        continue;
      }
      for (final block in chapter.blocks) {
        final end = start + block.length;
        if (block is TextBlock && end > range.start && start < range.end) {
          parts.add(
            block.text.substring(
              math.max(0, range.start - start),
              math.min(block.length, range.end - start),
            ),
          );
        }
        start = end;
      }
    }
    return parts.join('\n').trim();
  }

  @override
  Widget buildPage(
    int index,
    PageColors colors, {
    List<PageMark> marks = const [],
  }) => _EpubPageView(
    key: ValueKey((_version, index)),
    document: this,
    layout: _current,
    index: index,
    ink: colors.ink,
    marks: marks,
  );

  @override
  Future<ui.Image> pageImage(
    int index,
    Size maxSize,
    PageColors colors, {
    List<PageMark> marks = const [],
  }) async {
    final layout = _current;
    final images = await _imagesFor(layout.pages[index]);
    try {
      final scale = math.min(
        maxSize.width / layout.size.width,
        maxSize.height / layout.size.height,
      );
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)..scale(scale);
      layout.paint(canvas, index, images, ink: colors.ink, marks: marks);
      final picture = recorder.endRecording();
      try {
        return await picture.toImage(
          math.max(1, (layout.size.width * scale).round()),
          math.max(1, (layout.size.height * scale).round()),
        );
      } finally {
        picture.dispose();
      }
    } finally {
      for (final image in images.values) {
        image.dispose();
      }
    }
  }

  /// The images [page] shows, decoded, as clones the caller disposes.
  Future<Map<String, ui.Image>> _imagesFor(EpubPage page) async {
    final result = <String, ui.Image>{};
    for (final piece in page.images) {
      final image = await _image(piece.path);
      if (image != null) result[piece.path] = image;
    }
    return result;
  }

  Future<ui.Image?> _image(String path) async {
    var image = _decoded.remove(path);
    if (image == null) {
      // Two pages asking at once share one decode.
      final pending = _decoding.putIfAbsent(path, () => _decode(path));
      image = await pending;
      unawaited(_decoding.remove(path)); // Done: awaited just above.
      if (image == null || _disposed) return null;
      // The other asker got here first and cached this same image.
      final cached = _decoded.remove(path);
      if (cached != null && !identical(cached, image)) {
        image.dispose();
        image = cached;
      }
    }
    _decoded[path] = image; // Most recently used: last.
    while (_decoded.length > _keepDecoded) {
      _decoded.remove(_decoded.keys.first)?.dispose();
    }
    return image.clone();
  }

  Future<ui.Image?> _decode(String path) async {
    final bytes = book.images[path];
    if (bytes == null) return null;
    try {
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      try {
        final codec = await descriptor.instantiateCodec(
          targetWidth: descriptor.width > _maxImageWidth
              ? _maxImageWidth
              : null,
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
    } on Object {
      return null; // An image the engine cannot read: left blank.
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _layout?.dispose();
    _retired?.dispose();
    _layout = _retired = null;
    for (final image in _decoded.values) {
      image.dispose();
    }
    _decoded.clear();
  }
}

/// Page [index] of [layout], drawn to fill the space it gets; its images
/// appear once decoded.
class _EpubPageView extends StatefulWidget {
  const _EpubPageView({
    super.key,
    required this.document,
    required this.layout,
    required this.index,
    required this.ink,
    this.marks = const [],
  });

  final EpubBookDocument document;
  final EpubLayout layout;
  final int index;
  final Color ink;
  final List<PageMark> marks;

  @override
  State<_EpubPageView> createState() => _EpubPageViewState();
}

class _EpubPageViewState extends State<_EpubPageView> {
  Map<String, ui.Image> _images = const {};

  @override
  void initState() {
    super.initState();
    final page = widget.layout.pages[widget.index];
    if (page.images.isEmpty) return;
    unawaited(
      widget.document._imagesFor(page).then((images) {
        if (!mounted) {
          for (final image in images.values) {
            image.dispose();
          }
          return;
        }
        setState(() => _images = images);
      }),
    );
  }

  @override
  void dispose() {
    for (final image in _images.values) {
      image.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: CustomPaint(
      painter: _PagePainter(
        widget.layout,
        widget.index,
        _images,
        widget.ink,
        widget.marks,
      ),
    ),
  );
}

class _PagePainter extends CustomPainter {
  _PagePainter(this.layout, this.index, this.images, this.ink, this.marks);

  final EpubLayout layout;
  final int index;
  final Map<String, ui.Image> images;
  final Color ink;
  final List<PageMark> marks;

  @override
  void paint(Canvas canvas, Size size) {
    // The sheet can differ by a hair from the size laid out for (while
    // the window changes): scaled to fit.
    final scale = math.min(
      size.width / layout.size.width,
      size.height / layout.size.height,
    );
    canvas
      ..save()
      ..scale(scale);
    layout.paint(canvas, index, images, ink: ink, marks: marks);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PagePainter old) =>
      old.layout != layout ||
      old.index != index ||
      old.images != images ||
      old.ink != ink ||
      !listEquals(old.marks, marks);
}
