import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../book_document.dart';
import 'epub_book.dart';
import 'epub_layout.dart';

/// An EPUB in the reader: reflowable, so it has pages only once laid out
/// for a size ([layout]); the reader screen does that for the sheet it
/// shows, and again when the window changes.
class EpubBookDocument implements BookDocument {
  EpubBookDocument(this.book, {this.typography = const EpubTypography()});

  final EpubBook book;
  final EpubTypography typography;

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
  bool layout(Size size) {
    if (size.isEmpty || _layout?.size == size) return false;
    _retired?.dispose();
    _retired = _layout;
    _layout = EpubLayout(book, size, typography: typography);
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
  Widget buildPage(int index) => _EpubPageView(
    key: ValueKey((_version, index)),
    document: this,
    layout: _current,
    index: index,
  );

  @override
  Future<ui.Image> pageImage(int index, Size maxSize) async {
    final layout = _current;
    final images = await _imagesFor(layout.pages[index]);
    try {
      final scale = math.min(
        maxSize.width / layout.size.width,
        maxSize.height / layout.size.height,
      );
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)..scale(scale);
      layout.paint(canvas, index, images);
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
  });

  final EpubBookDocument document;
  final EpubLayout layout;
  final int index;

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
      painter: _PagePainter(widget.layout, widget.index, _images),
    ),
  );
}

class _PagePainter extends CustomPainter {
  _PagePainter(this.layout, this.index, this.images);

  final EpubLayout layout;
  final int index;
  final Map<String, ui.Image> images;

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
    layout.paint(canvas, index, images);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PagePainter old) =>
      old.layout != layout || old.index != index || old.images != images;
}
