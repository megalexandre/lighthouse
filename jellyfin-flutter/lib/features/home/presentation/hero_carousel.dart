import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/ticks.dart';
import '../../../router.dart';
import '../../../widgets/focus_ring.dart';
import '../../library/data/library_repository.dart';

/// The home page's opening carousel (the theme's `homeHero: carousel`):
/// what was added lately, full width, one at a time.
///
/// Each slide: the item's backdrop under gradients that keep the text
/// readable, its kind, its name in large capitals, the facts, two lines of
/// overview, a white Play button and a round "More info" one. The slides
/// change every [interval] with a cross-fade (none with reduced motion),
/// and hold still while the pointer is on the carousel; arrows and dots
/// move through them by hand.
class HeroCarousel extends ConsumerStatefulWidget {
  const HeroCarousel({super.key, required this.items});

  final List<BaseItemDto> items;

  static const interval = Duration(seconds: 8);
  static const fade = Duration(milliseconds: 700);

  static const playButton = Key('hero.play');
  static const infoButton = Key('hero.info');
  static const nextButton = Key('hero.next');
  static const previousButton = Key('hero.previous');
  static Key dot(int index) => Key('hero.dot.$index');

  /// Its height in a window [size]: 16:9 of the width, at least 560 and at
  /// most 86 % of the height (a phone: 640).
  static double heightFor(Size size) => size.width < 760
      ? 640
      : math.max(560.0, math.min(size.width * 9 / 16, size.height * 0.86));

  @override
  ConsumerState<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends ConsumerState<HeroCarousel> {
  int _index = 0;
  Timer? _timer;
  bool _held = false;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restart() {
    _timer?.cancel();
    if (widget.items.length < 2) return;
    _timer = Timer.periodic(HeroCarousel.interval, (_) {
      if (!_held && mounted) _go(_index + 1);
    });
  }

  void _go(int index, {bool byHand = false}) {
    final count = widget.items.length;
    setState(() => _index = (index % count + count) % count);
    if (byHand) _restart();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final item = items[_index % items.length];
    final size = MediaQuery.sizeOf(context);
    final still = MediaQuery.disableAnimationsOf(context);
    final narrow = size.width < 760;
    return MouseRegion(
      onEnter: (_) => _held = true,
      onExit: (_) => _held = false,
      child: SizedBox(
        height: HeroCarousel.heightFor(size),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: still ? Duration.zero : HeroCarousel.fade,
              child: _Slide(
                key: ValueKey(item.id),
                item: item,
                narrow: narrow,
                still: still,
              ),
            ),
            if (items.length > 1 && !narrow) ...[
              _Arrow(
                buttonKey: HeroCarousel.previousButton,
                forward: false,
                onTap: () => _go(_index - 1, byHand: true),
              ),
              _Arrow(
                buttonKey: HeroCarousel.nextButton,
                forward: true,
                onTap: () => _go(_index + 1, byHand: true),
              ),
            ],
            if (items.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: narrow ? 48 : HeroCarousel.heightFor(size) * 0.15 - 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < items.length; i++)
                      _Dot(
                        key: HeroCarousel.dot(i),
                        on: i == _index,
                        onTap: () => _go(i, byHand: true),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends ConsumerStatefulWidget {
  const _Slide({
    super.key,
    required this.item,
    required this.narrow,
    required this.still,
  });

  final BaseItemDto item;
  final bool narrow;
  final bool still;

  @override
  ConsumerState<_Slide> createState() => _SlideState();
}

class _SlideState extends ConsumerState<_Slide> {
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
    final left = widget.narrow ? context.tokens.space(4) : 72.0;
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
          right: widget.narrow ? left : null,
          bottom: widget.narrow ? 96 : HeroCarousel.heightFor(size) * 0.15,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.narrow
                  ? double.infinity
                  : math.min(700, size.width * 0.48),
            ),
            child: _Caption(item: widget.item, narrow: widget.narrow),
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

/// The slide's text and buttons: MOVIE or SERIES, the title in capitals
/// (sized to the window), the facts, the start of the overview, Play (or
/// Episodes) and More info.
class _Caption extends StatelessWidget {
  const _Caption({required this.item, required this.narrow});

  final BaseItemDto item;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final ink = tokens.osdInk;
    final movie = item.type != BaseItemKind.series;
    final facts = [
      ?item.productionYear?.toString(),
      if (item.runTimeTicks case final int t when t > 0 && movie)
        formatRuntime(ticksToDuration(t)),
      ?item.officialRating,
    ].join(' · ');
    final titleSize = narrow
        ? 30.0
        : (MediaQuery.sizeOf(context).width * 0.042).clamp(36.0, 68.0);
    return DefaultTextStyle.merge(
      style: TextStyle(color: ink),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            movie ? 'MOVIE' : 'SERIES',
            style: tokens.overline.copyWith(
              color: theme.colorScheme.inversePrimary,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: tokens.space(3)),
          Text(
            item.name.toUpperCase(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            // Sized to the window, so not a fixed step of the scale.
            style: theme.textTheme.displayLarge?.copyWith(
              color: ink,
              fontSize: titleSize,
              height: 1.08,
              fontWeight: FontWeight.w600,
              letterSpacing: titleSize * (narrow ? 0.08 : 0.14),
              shadows: [
                Shadow(
                  blurRadius: 16,
                  color: tokens.mediaShade.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.space(4)),
          if (facts.isNotEmpty)
            Text(
              facts,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.osdInkMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (item.overview case final String overview
              when overview.isNotEmpty) ...[
            SizedBox(height: tokens.space(3)),
            Text(
              overview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  (narrow
                          ? theme.textTheme.bodyLarge
                          : theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w400,
                            ))
                      ?.copyWith(color: ink),
            ),
          ],
          SizedBox(height: tokens.space(6)),
          Row(
            children: [
              _WhiteButton(
                key: HeroCarousel.playButton,
                label: movie ? 'Play' : 'Episodes',
                icon: movie ? Icons.play_arrow : Icons.list,
                big: !narrow,
                onPressed: () => context.push(
                  movie ? Routes.play(item.id) : Routes.item(item.id),
                ),
              ),
              SizedBox(width: tokens.space(4)),
              _RoundButton(
                key: HeroCarousel.infoButton,
                tooltip: 'More info',
                icon: Icons.info_outline,
                big: !narrow,
                onPressed: () => context.push(Routes.item(item.id)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The hero's main button: white, dark text (the variation's "Assistir").
class _WhiteButton extends StatelessWidget {
  const _WhiteButton({
    super.key,
    required this.label,
    required this.icon,
    required this.big,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool big;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(tokens.radiusMd);
    return FocusRing(
      borderRadius: radius,
      color: tokens.osdInk,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: big ? 32 : 26),
        label: Text(label),
        style: ButtonStyle(
          fixedSize: WidgetStatePropertyAll(Size.fromHeight(big ? 60 : 52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.fromLTRB(20, 0, 28, 0),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: radius),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.hovered)
                ? tokens.mediaButtonHover
                : tokens.osdInk,
          ),
          foregroundColor: WidgetStatePropertyAll(tokens.mediaButtonInk),
          iconColor: WidgetStatePropertyAll(tokens.mediaButtonInk),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          textStyle: WidgetStatePropertyAll(
            (big ? theme.titleLarge : theme.titleMedium)?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.big,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool big;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = big ? 60.0 : 52.0;
    final ink = context.tokens.osdInk;
    return FocusRing(
      borderRadius: BorderRadius.circular(size),
      color: ink,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        iconSize: big ? 30 : 26,
        icon: Icon(icon),
        style: ButtonStyle(
          fixedSize: WidgetStatePropertyAll(Size.square(size)),
          foregroundColor: WidgetStatePropertyAll(ink),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => ink.withValues(
              alpha: s.contains(WidgetState.hovered) ? 0.34 : 0.22,
            ),
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.buttonKey,
    required this.forward,
    required this.onTap,
  });

  /// On the button itself (the arrow's area is the carousel's height).
  final Key buttonKey;
  final bool forward;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Align(
    alignment: forward ? Alignment.centerRight : Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: IconButton(
        key: buttonKey,
        tooltip: forward ? 'Next' : 'Previous',
        onPressed: onTap,
        iconSize: 44,
        color: context.tokens.osdInk,
        icon: Icon(forward ? Icons.chevron_right : Icons.chevron_left),
        style: const ButtonStyle(
          fixedSize: WidgetStatePropertyAll(Size(56, 96)),
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
    ),
  );
}

class _Dot extends StatelessWidget {
  const _Dot({super.key, required this.on, required this.onTap});

  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: on,
    label: 'Slide',
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: on ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: on
                ? context.tokens.osdInk
                : context.tokens.osdInk.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    ),
  );
}
