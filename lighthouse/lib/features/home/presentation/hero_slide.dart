import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/window_size.dart';
import '../../library/data/library_repository.dart';
import 'hero_caption.dart';
import 'hero_carousel.dart';

/// One slide of the carousel: the item's backdrop, slowly zooming while
/// shown, under shades and its caption.
class HeroSlide extends ConsumerStatefulWidget {
  const HeroSlide({
    super.key,
    required this.item,
    required this.narrow,
    required this.still,
  });

  final BaseItemDto item;
  final bool narrow;
  final bool still;

  @override
  ConsumerState<HeroSlide> createState() => _SlideState();
}

class _SlideState extends ConsumerState<HeroSlide> {
  /// The picture settles from a slight zoom while the slide shows.
  bool _settled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _settled = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pixels = (size.width * MediaQuery.devicePixelRatioOf(context))
        .round();
    final url = ref
        .watch(libraryRepositoryProvider)
        .backdropUrl(widget.item, maxWidth: pixels);
    // Clear of a notch at the sides (a phone on its side); the picture
    // still runs to the edges.
    final system = MediaQuery.paddingOf(context);
    final margin = widget.narrow ? context.tokens.space(4) : 72.0;
    final left = margin + system.left;
    return Stack(
      fit: StackFit.expand,
      children: [
        _Backdrop(
          url: url,
          zoomed: !_settled && !widget.still,
          still: widget.still,
        ),
        const _Shades(),
        Positioned(
          left: left,
          right: widget.narrow ? margin + system.right : null,
          bottom: WindowSize.isShort(context)
              ? 36
              : widget.narrow
              ? 96
              : HeroCarousel.heightFor(size) * 0.15,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.narrow
                  ? double.infinity
                  : math.min(700, size.width * 0.48),
            ),
            child: HeroCaption(item: widget.item, narrow: widget.narrow),
          ),
        ),
      ],
    );
  }
}

/// The item's backdrop, which settles from a slight zoom ([zoomed]) while
/// the slide shows; over a picture, the player's dark behind it.
class _Backdrop extends StatelessWidget {
  const _Backdrop({
    required this.url,
    required this.zoomed,
    required this.still,
  });

  final Uri? url;
  final bool zoomed;

  /// Reduced motion: no zoom at all.
  final bool still;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.tokens.mediaShade,
    child: switch (url) {
      null => null,
      // Clipped to the slide: a Stack does not clip what a transform
      // pushes out.
      final url => ClipRect(
        child: AnimatedScale(
          scale: zoomed ? 1.04 : 1,
          duration: still ? Duration.zero : const Duration(seconds: 9),
          child: Image.network(
            url.toString(),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    },
  );
}

/// Dark on the left for the text, the page's colour at the bottom, a
/// little shade at the top for the bar over it.
class _Shades extends StatelessWidget {
  const _Shades();

  @override
  Widget build(BuildContext context) {
    final night = context.tokens.mediaShade;
    final ground = Theme.of(context).scaffoldBackgroundColor;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                night.withValues(alpha: 0.95),
                night.withValues(alpha: 0.75),
                night.withValues(alpha: 0.2),
                night.withValues(alpha: 0),
              ],
              stops: const [0, 0.28, 0.55, 0.7],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [ground, ground.withValues(alpha: 0)],
              stops: const [0, 0.26],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                night.withValues(alpha: 0.5),
                night.withValues(alpha: 0),
              ],
              stops: const [0, 0.18],
            ),
          ),
        ),
      ],
    );
  }
}
