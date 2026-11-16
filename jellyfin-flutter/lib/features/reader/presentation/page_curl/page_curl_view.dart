import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'curl_geometry.dart';
import 'page_curl_painter.dart';

/// Renders sheet [index] (paper and page, as shown) as an image of [size]
/// logical pixels at [pixelRatio].
typedef SheetImageBuilder = Future<ui.Image> Function(
  int index,
  Size size,
  double pixelRatio,
);

/// A book's pages that turn like paper, following the finger (as Google
/// Play Books does): drag on the right half to lift the page, on the left
/// half to bring the previous one back. Let go past the middle (or flick)
/// and it turns; otherwise it falls back. [turnNext] and [turnPrevious]
/// play the same turn for keys and taps.
///
/// At rest the page is the widget [sheetBuilder] builds (crisp, live);
/// while turning, images of the two sheets ([sheetImage]) are bent by a
/// shader (shaders/page_curl.frag).
class PageCurlView extends ConsumerStatefulWidget {
  const PageCurlView({
    super.key,
    required this.pageCount,
    required this.page,
    required this.sheetBuilder,
    required this.sheetImage,
    required this.onTurned,
    this.paper = const Color(0xFFFFFFFF),
  });

  final int pageCount;

  /// The page shown at rest (0-based).
  final int page;
  final Widget Function(int index) sheetBuilder;
  final SheetImageBuilder sheetImage;

  /// A turn finished: [page] is now the one to show.
  final ValueChanged<int> onTurned;
  final Color paper;

  @override
  PageCurlViewState createState() => PageCurlViewState();
}

/// A turn in progress: the sheet lifted, the page under it, where it was
/// grabbed and where that point is now.
class _Turn {
  _Turn({
    required this.forward,
    required this.from,
    required this.grab,
    required this.finger,
  });

  /// Forward: the page lifts to show the next. Backward: the previous page
  /// comes back over this one.
  final bool forward;
  final int from;
  final Offset grab;
  Offset finger;

  int get sheet => forward ? from : from - 1;
  int get under => forward ? from + 1 : from;
  int get after => forward ? from + 1 : from - 1;

  Offset get flat => grab;
  Offset get turned => turnedFinger(grab);

  /// Where the finger must end for this turn to happen.
  Offset get completion => forward ? turned : flat;
}

class PageCurlViewState extends ConsumerState<PageCurlView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _settle = AnimationController(vsync: this)
    ..addListener(_onSettleTick)
    ..addStatusListener(_onSettleStatus);
  Animation<Offset>? _settleTo;
  bool _settleCompletes = false;

  _Turn? _turn;
  Offset? _dragStart;
  Size _size = Size.zero;

  /// Sheet images for the current size, by page.
  final _images = <int, ui.Image>{};
  final _loading = <int>{};
  Size? _imagesSize;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  @override
  void dispose() {
    _settle.dispose();
    _dropImages();
    super.dispose();
  }

  void _dropImages() {
    for (final image in _images.values) {
      image.dispose();
    }
    _images.clear();
  }

  // --- Images --------------------------------------------------------------

  /// Gets the sheets around [page] ready, so a turn starts without a wait.
  void _prefetch() {
    if (_size.isEmpty) return;
    if (_imagesSize != _size) {
      _dropImages();
      _imagesSize = _size;
    }
    final wanted = {
      for (var i = widget.page - 1; i <= widget.page + 1; i++)
        if (i >= 0 && i < widget.pageCount) i,
      if (_turn case final _Turn t) ...[t.sheet, t.under],
    };
    for (final index in _images.keys.toList()) {
      if (!wanted.contains(index)) _images.remove(index)?.dispose();
    }
    wanted.forEach(_load);
  }

  void _load(int index) {
    if (_images.containsKey(index) || _loading.contains(index)) return;
    _loading.add(index);
    final size = _size;
    final ratio = MediaQuery.devicePixelRatioOf(context);
    unawaited(
      widget.sheetImage(index, size, ratio).then((image) {
        _loading.remove(index);
        if (!mounted || _imagesSize != size) {
          image.dispose();
          return;
        }
        setState(() {
          _images.remove(index)?.dispose();
          _images[index] = image;
        });
      }, onError: (Object _) => _loading.remove(index)),
    );
  }

  // --- Turns from a finger -------------------------------------------------

  void _onPanStart(DragStartDetails details) {
    _finishNow();
    final start = details.localPosition;
    final forward = start.dx >= _size.width / 2;
    final from = widget.page;
    if (forward ? from >= widget.pageCount - 1 : from <= 0) return;
    final grab = Offset(_size.width, start.dy.clamp(0, _size.height));
    _dragStart = start;
    setState(() {
      _turn = _Turn(
        forward: forward,
        from: from,
        grab: grab,
        finger: forward ? grab : turnedFinger(grab),
      );
    });
    _prefetch();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final turn = _turn;
    final start = _dragStart;
    if (turn == null || start == null || _settle.isAnimating) return;
    final moved = details.localPosition - start;
    setState(() {
      turn.finger = turn.forward
          // The grabbed edge follows the finger's movement.
          ? turn.grab + moved
          // Coming back from fully turned: one page width of finger travel
          // brings it all the way.
          : Offset(-_size.width + 2 * moved.dx, turn.grab.dy + moved.dy);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final turn = _turn;
    _dragStart = null;
    if (turn == null) return;
    final v = details.velocity.pixelsPerSecond;
    final finger = constrainToSpine(_size, turn.grab, turn.finger);
    final turns = turn.forward
        ? shouldTurn(_size, finger, v)
        // Mirrored: a flick right, or past the middle, brings it back.
        : !shouldTurn(_size, Offset(_size.width - finger.dx, 0), -v);
    final target = turns
        ? turn.completion
        : (turn.forward ? turn.flat : turn.turned);
    _animateTo(
      target,
      completes: turns,
      duration: settleDuration(_size, finger, target),
      curve: Curves.easeOutCubic,
    );
  }

  // --- Turns from keys and taps --------------------------------------------

  /// Turns to the next page, as a hand would from the bottom corner.
  void turnNext() => _autoTurn(forward: true);

  /// Brings the previous page back.
  void turnPrevious() => _autoTurn(forward: false);

  void _autoTurn({required bool forward}) {
    _finishNow();
    final from = widget.page;
    if (forward ? from >= widget.pageCount - 1 : from <= 0) return;
    if (_reduceMotion || _size.isEmpty) {
      widget.onTurned(forward ? from + 1 : from - 1);
      return;
    }
    final grab = autoGrab(_size);
    final turn = _Turn(
      forward: forward,
      from: from,
      grab: grab,
      finger: forward ? grab : turnedFinger(grab),
    );
    setState(() => _turn = turn);
    _prefetch();
    _animateTo(
      turn.completion,
      completes: true,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  // --- Settling ------------------------------------------------------------

  void _animateTo(
    Offset target, {
    required bool completes,
    required Duration duration,
    required Curve curve,
  }) {
    final turn = _turn!;
    _settleCompletes = completes;
    _settleTo = Tween(
      begin: constrainToSpine(_size, turn.grab, turn.finger),
      end: target,
    ).animate(CurvedAnimation(parent: _settle, curve: curve));
    _settle
      ..duration = duration
      ..forward(from: 0);
  }

  void _onSettleTick() {
    final turn = _turn;
    final to = _settleTo;
    if (turn == null || to == null) return;
    setState(() => turn.finger = to.value);
  }

  void _onSettleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _end();
  }

  /// Ends a turn: the page changes if it was turning to the other side.
  void _end() {
    final turn = _turn;
    if (turn == null) return;
    final completes = _settleCompletes;
    _settleTo = null;
    setState(() => _turn = null);
    if (completes) widget.onTurned(turn.after);
  }

  /// A new turn while one settles: the old one ends where it was going.
  void _finishNow() {
    if (_settle.isAnimating) {
      _settle.stop();
      _end();
    }
  }

  /// 1 while the sheet is up, fading to 0 as it lands on either side.
  double _shadowFor(_Turn turn) {
    final f = constrainToSpine(_size, turn.grab, turn.finger);
    final rest = [
      (f - turn.flat).distance,
      (f - turn.turned).distance,
    ].reduce((a, b) => a < b ? a : b);
    return (rest / (_size.width * 0.5)).clamp(0.0, 1.0);
  }

  // --- Drawing -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final program = ref.watch(pageCurlProgramProvider).value;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (size != _size) {
          _size = size;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _prefetch();
          });
        }
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onPanCancel: () {
            if (_turn != null && !_settle.isAnimating) {
              _onPanEnd(DragEndDetails());
            }
          },
          child: _sheets(program, size),
        );
      },
    );
  }

  Widget _sheets(ui.FragmentProgram? program, Size size) {
    final turn = _turn;
    if (turn == null) {
      _schedulePrefetch();
      return widget.sheetBuilder(widget.page);
    }
    final curl = curlFor(size, turn.grab, turn.finger);
    if (curl == null) return widget.sheetBuilder(turn.sheet);
    final front = _images[turn.sheet];
    final under = _images[turn.under];
    if (program != null && front != null && under != null) {
      return CustomPaint(
        size: size,
        painter: PageCurlPainter(
          program: program,
          front: front,
          under: under,
          curl: curl,
          shadow: _shadowFor(turn),
          paper: widget.paper,
        ),
      );
    }
    // No shader, or the images are not ready yet: a flat fold, the page
    // beneath showing past the fold line.
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.sheetBuilder(turn.under),
        ClipPath(
          clipper: _FlatPartClipper(curl),
          child: widget.sheetBuilder(turn.sheet),
        ),
      ],
    );
  }

  bool _prefetchScheduled = false;

  void _schedulePrefetch() {
    if (_prefetchScheduled) return;
    _prefetchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchScheduled = false;
      if (mounted) _prefetch();
    });
  }
}

/// The part of the sheet still lying flat: the page's rectangle cut by
/// the fold line (the lifted side removed).
class _FlatPartClipper extends CustomClipper<Path> {
  _FlatPartClipper(this.curl);

  final CurlGeometry curl;

  @override
  Path getClip(Size size) {
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(size.width, size.height),
      Offset(0, size.height),
    ];
    double side(Offset p) =>
        (p - curl.point).dx * curl.direction.dx +
        (p - curl.point).dy * curl.direction.dy;
    final kept = <Offset>[];
    for (var i = 0; i < corners.length; i++) {
      final a = corners[i];
      final b = corners[(i + 1) % corners.length];
      final (da, db) = (side(a), side(b));
      if (da <= 0) kept.add(a);
      if ((da < 0) != (db < 0)) kept.add(a + (b - a) * (da / (da - db)));
    }
    final path = Path();
    if (kept.isNotEmpty) path.addPolygon(kept, true);
    return path;
  }

  @override
  bool shouldReclip(_FlatPartClipper old) => old.curl != curl;
}
