import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../core/theme/app_tokens.dart';

/// A horizontal row (built by [builder] with the [ScrollController] it is
/// given) with arrows at its ends that page through it, when the theme
/// asks for them (`components.rowArrows`).
///
/// An arrow shows only where there is more to see; on narrow windows there
/// are none (a finger swipes). Reduced motion: the row jumps.
class RowArrows extends StatefulWidget {
  const RowArrows({super.key, required this.builder, this.inset = 0});

  final Widget Function(ScrollController controller) builder;

  /// Space at the top and bottom of the row the arrows leave free (the
  /// room cards grow into on hover).
  final double inset;

  static const previousKey = Key('row.previous');
  static const nextKey = Key('row.next');

  /// Below this width the row has no arrows.
  static const minWidth = 760.0;

  @override
  State<RowArrows> createState() => _RowArrowsState();
}

class _RowArrowsState extends State<RowArrows> {
  final _controller = ScrollController();
  bool _canBack = false;
  bool _canForward = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update() {
    if (!mounted || !_controller.hasClients) return;
    final p = _controller.position;
    final back = p.pixels > p.minScrollExtent + 1;
    final forward = p.pixels < p.maxScrollExtent - 1;
    if (back != _canBack || forward != _canForward) {
      setState(() {
        _canBack = back;
        _canForward = forward;
      });
    }
  }

  void _page(int direction) {
    if (!_controller.hasClients) return;
    final p = _controller.position;
    final target = (p.pixels + direction * p.viewportDimension * 0.85).clamp(
      p.minScrollExtent,
      p.maxScrollExtent,
    );
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpTo(target);
    } else {
      unawaited(
        _controller.animateTo(
          target,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final row = NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        _update();
        return false;
      },
      child: widget.builder(_controller),
    );
    if (!context.tokens.components.rowArrows ||
        MediaQuery.sizeOf(context).width < RowArrows.minWidth) {
      return row;
    }
    return Stack(
      children: [
        row,
        if (_canBack)
          _Arrow(
            key: RowArrows.previousKey,
            forward: false,
            inset: widget.inset,
            onTap: () => _page(-1),
          ),
        if (_canForward)
          _Arrow(
            key: RowArrows.nextKey,
            forward: true,
            inset: widget.inset,
            onTap: () => _page(1),
          ),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    super.key,
    required this.forward,
    required this.inset,
    required this.onTap,
  });

  final bool forward;
  final double inset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ground = theme.scaffoldBackgroundColor;
    final dark = theme.brightness == Brightness.dark;
    return Positioned(
      top: inset,
      bottom: inset,
      left: forward ? null : 0,
      right: forward ? 0 : null,
      width: 64,
      child: Tooltip(
        message: forward ? 'More' : 'Back',
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            hoverColor: Colors.transparent,
            child: DecoratedBox(
              // The page's own colour, fading into the row.
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: forward ? Alignment.centerRight : Alignment.centerLeft,
                  end: forward ? Alignment.centerLeft : Alignment.centerRight,
                  colors: [ground, ground.withValues(alpha: 0)],
                  stops: const [0.15, 1],
                ),
              ),
              child: Center(
                child: Icon(
                  forward ? Icons.chevron_right : Icons.chevron_left,
                  size: 48,
                  color: dark ? Colors.white : theme.colorScheme.onSurface,
                  shadows: dark
                      ? const [Shadow(blurRadius: 3, color: Color(0x99000000))]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
