import 'package:material_ui/material_ui.dart';

import '../core/theme/app_tokens.dart';

/// The design system's focus ring: 2 px in the accent, 2 px away from
/// [child], around it while it (or anything inside it) has the focus.
///
/// Shown only when the focus moves with keys (keyboard, remote, gamepad),
/// as a browser's `:focus-visible`: a click leaves no ring.
class FocusRing extends StatefulWidget {
  const FocusRing({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.color,
    this.gap = 2,
    this.width = 2,
  });

  final Widget child;

  /// The child's own corners (the ring follows them, [gap] further out).
  final BorderRadius borderRadius;

  /// Default: the theme's accent (`osd-accent` over the video: pass it).
  final Color? color;
  final double gap;
  final double width;

  @override
  State<FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<FocusRing> {
  bool _focused = false;

  bool get _keyboard =>
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_onMode);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onMode);
    super.dispose();
  }

  void _onMode(FocusHighlightMode _) {
    if (mounted && _focused) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Focus(
    canRequestFocus: false,
    skipTraversal: true,
    onFocusChange: (focused) => setState(() => _focused = focused),
    child: CustomPaint(
      foregroundPainter: _focused && _keyboard
          ? _RingPainter(
              color: widget.color ?? Theme.of(context).colorScheme.primary,
              radius: widget.borderRadius,
              gap: widget.gap,
              width: widget.width,
            )
          : null,
      child: widget.child,
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.color,
    required this.radius,
    required this.gap,
    required this.width,
  });

  final Color color;
  final BorderRadius radius;
  final double gap;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final outset = gap + width / 2;
    final rect = (Offset.zero & size).inflate(outset);
    final rrect = radius
        .copyWith(
          topLeft: radius.topLeft + Radius.circular(outset),
          topRight: radius.topRight + Radius.circular(outset),
          bottomLeft: radius.bottomLeft + Radius.circular(outset),
          bottomRight: radius.bottomRight + Radius.circular(outset),
        )
        .toRRect(rect);
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.gap != gap ||
      old.width != width;
}

/// A [FocusRing] around a child with the theme's medium radius.
extension FocusRingX on Widget {
  Widget withFocusRing(BuildContext context, {double? radius, Color? color}) =>
      FocusRing(
        borderRadius: BorderRadius.circular(radius ?? context.tokens.radiusMd),
        color: color,
        child: this,
      );
}
