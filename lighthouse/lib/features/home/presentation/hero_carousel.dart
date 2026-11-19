import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/window_size.dart';
import 'hero_controls.dart';
import 'hero_slide.dart';

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
  /// most 86 % of the height (below expanded: 640).
  static double heightFor(Size size) => isNarrow(size.width)
      ? 640
      : math.max(560.0, math.min(size.width * 9 / 16, size.height * 0.86));

  /// Below expanded: the phone and tablet layout (smaller title, no
  /// arrows).
  static bool isNarrow(double width) =>
      !WindowSize.ofWidth(width).atLeast(WindowSize.expanded);

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
    final narrow = HeroCarousel.isNarrow(size.width);
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
              child: HeroSlide(
                key: ValueKey(item.id),
                item: item,
                narrow: narrow,
                still: still,
              ),
            ),
            if (items.length > 1 && !narrow) ...[
              HeroArrow(
                buttonKey: HeroCarousel.previousButton,
                forward: false,
                onTap: () => _go(_index - 1, byHand: true),
              ),
              HeroArrow(
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
                      HeroDot(
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
