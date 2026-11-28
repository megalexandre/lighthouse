import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/theme/app_tokens.dart';
import '../l10n/l10n.dart';

/// The app's loading indicator, where no `Skeleton` fits (the video
/// waiting for data, a book or the player opening, a busy button): a thin
/// ring, its track faint, and an arc of it going round at an even pace,
/// not Material's arc that grows and shrinks. With [value] it is a
/// progress ring instead, filled that far (holding the player's padlock).
///
/// The arc is `accent` over a faint `ink`; over the video ([onMedia])
/// `osd-accent` over `osd-track`. With animations turned off (the
/// system's setting) the arc stands still, as the skeleton's bones do.
class LoadingRing extends StatefulWidget {
  const LoadingRing({
    super.key,
    this.size = 40,
    this.strokeWidth = 3,
    this.onMedia = false,
    this.color,
    this.value,
  });

  /// Inside a button: the button's own ink.
  const LoadingRing.small({super.key, this.color})
    : size = 20,
      strokeWidth = 2,
      onMedia = false,
      value = null;

  final double size;
  final double strokeWidth;

  /// Over the video or a book's page: the player's colours.
  final bool onMedia;

  /// The arc's colour, in place of the theme's.
  final Color? color;

  /// From 0 to 1: how far the ring is filled. Null: loading.
  final double? value;

  /// One turn of the arc.
  static const period = Duration(milliseconds: 1000);

  @override
  State<LoadingRing> createState() => _LoadingRingState();
}

class _LoadingRingState extends State<LoadingRing>
    with SingleTickerProviderStateMixin {
  late final _turn = AnimationController(
    vsync: this,
    duration: LoadingRing.period,
  );

  bool get _spins =>
      widget.value == null && !MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _follow();
  }

  @override
  void didUpdateWidget(LoadingRing old) {
    super.didUpdateWidget(old);
    _follow();
  }

  void _follow() {
    if (_spins && !_turn.isAnimating) unawaited(_turn.repeat());
    if (!_spins && _turn.isAnimating) _turn.stop();
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final arc =
        widget.color ?? (widget.onMedia ? tokens.osdAccent : scheme.primary);
    final track = widget.color != null
        ? arc.withValues(alpha: 0.24)
        : widget.onMedia
        ? tokens.osdTrack
        : scheme.onSurface.withValues(alpha: 0.12);
    final ring = SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _turn,
        builder: (_, _) => CustomPaint(
          painter: _RingPainter(
            arc: arc,
            track: track,
            strokeWidth: widget.strokeWidth,
            value: widget.value,
            turn: _turn.value,
          ),
        ),
      ),
    );
    if (widget.value != null) return ring;
    return Semantics(
      label: context.l10n.loading,
      liveRegion: true,
      child: ExcludeSemantics(child: ring),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.arc,
    required this.track,
    required this.strokeWidth,
    required this.value,
    required this.turn,
  });

  final Color arc;
  final Color track;
  final double strokeWidth;
  final double? value;

  /// Where the spinning arc is, from 0 to 1 of a turn.
  final double turn;

  /// The spinning arc: a quarter of the ring.
  static const _sweep = math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = track);
    paint.color = arc;
    const top = -math.pi / 2;
    if (value case final double value) {
      if (value <= 0) return;
      canvas.drawArc(rect, top, 2 * math.pi * value.clamp(0, 1), false, paint);
    } else {
      canvas.drawArc(rect, top + 2 * math.pi * turn, _sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.turn != turn ||
      old.value != value ||
      old.arc != arc ||
      old.track != track ||
      old.strokeWidth != strokeWidth;
}
