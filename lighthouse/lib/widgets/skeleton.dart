import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../core/theme/app_tokens.dart';
import '../l10n/l10n.dart';

/// Where content is on its way: [Bone]s in the shape of what will come,
/// with a sheen sweeping across them. The page reads as already there,
/// not as a spinner in an empty screen.
///
/// Bones are `bg-200`, the cards' colour, and the sheen `bg-300`; over the
/// video ([onMedia]) the player's `osd-surface` and `osd-hover`. With
/// animations turned off (the system's setting) the bones stay still.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, required this.child, this.onMedia = false});

  final Widget child;

  /// Over the video or a picture: the player's dark colours.
  final bool onMedia;

  /// One sweep across.
  static const period = Duration(milliseconds: 1500);

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  /// Shared by every skeleton, so the rows of one page sweep together
  /// although each started loading at its own time.
  static final _clock = Stopwatch()..start();

  late final Ticker _ticker = createTicker((_) => _phase.value = _now());
  final _phase = ValueNotifier<double>(0);

  static double _now() =>
      (_clock.elapsedMicroseconds % Skeleton.period.inMicroseconds) /
      Skeleton.period.inMicroseconds;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still && _ticker.isActive) _ticker.stop();
    if (!still && !_ticker.isActive) unawaited(_ticker.start());
  }

  @override
  void dispose() {
    _ticker.dispose();
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final base = widget.onMedia ? tokens.osdSurface : scheme.surfaceContainer;
    final sheen = widget.onMedia
        ? tokens.osdHover
        : scheme.surfaceContainerHigh;
    final bones = _BoneColor(color: base, child: widget.child);
    return Semantics(
      label: context.l10n.loading,
      liveRegion: true,
      child: ExcludeSemantics(
        child: MediaQuery.disableAnimationsOf(context)
            ? bones
            : ValueListenableBuilder<double>(
                valueListenable: _phase,
                builder: (_, phase, child) => ShaderMask(
                  // Paints the sheen on the bones only.
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [base, sheen, base],
                    stops: const [0.35, 0.5, 0.65],
                    // From off the left edge to off the right one.
                    transform: _Slide(phase * 2 - 1),
                  ).createShader(bounds),
                  child: child,
                ),
                child: bones,
              ),
      ),
    );
  }
}

/// Moves the gradient by [fraction] of the bounds' width.
class _Slide extends GradientTransform {
  const _Slide(this.fraction);

  final double fraction;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * fraction, 0, 0);
}

class _BoneColor extends InheritedWidget {
  const _BoneColor({required this.color, required super.child});

  final Color color;

  @override
  bool updateShouldNotify(_BoneColor old) => color != old.color;
}

/// One grey shape inside a [Skeleton]: a picture, a line of text, a
/// button. Without [width] it takes the width it is given.
class Bone extends StatelessWidget {
  const Bone({super.key, this.width, this.height, this.radius});

  /// A line of text [width] wide: as tall as a line of [style] at the
  /// user's font size, measured as the text would be, so a skeleton is the
  /// height of what replaces it. The bone is shorter, as letters are.
  static Widget text(BuildContext context, TextStyle? style, {double? width}) {
    final scaler = MediaQuery.textScalerOf(context);
    final painter = TextPainter(
      text: TextSpan(text: 'Ag', style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final line = painter.height;
    painter.dispose();
    final size = scaler.scale(style?.fontSize ?? 14);
    return SizedBox(
      height: line,
      child: Align(
        alignment: Alignment.centerLeft,
        // A headline's full height reads as a block, not a line.
        child: Bone(width: width, height: math.min(size * 0.8, 20)),
      ),
    );
  }

  final double? width;
  final double? height;

  /// Defaults to the theme's `radius-sm`.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final color =
        context.dependOnInheritedWidgetOfExactType<_BoneColor>()?.color ??
        Theme.of(context).colorScheme.surfaceContainer;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius ?? context.tokens.radiusSm),
      ),
    );
  }
}
