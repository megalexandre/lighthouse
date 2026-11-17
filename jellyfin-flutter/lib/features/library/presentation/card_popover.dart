import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/failure.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/ticks.dart';
import '../../../router.dart';
import '../../player/data/playback_repository.dart';
import '../application/library_providers.dart';
import '../data/library_repository.dart';
import 'item_card.dart';

/// The panel a card opens under the mouse when the theme asks for it
/// (`components.cardHover: expand`, the streaming variation's card): a
/// wide picture with the progress, the title, a white Play (or Resume)
/// button, round "watched" and "details" buttons, the rating, year and
/// length, and three lines of overview.
///
/// It grows out of the card ([origin], the card's picture on screen) and
/// sits centred on it, inside the window. The list items have no overview:
/// the whole item is fetched as it opens.
class CardPopover extends ConsumerStatefulWidget {
  const CardPopover({
    super.key,
    required this.item,
    required this.origin,
    required this.onEnter,
    required this.onExit,
    required this.onDone,
  });

  final BaseItemDto item;
  final Rect origin;

  /// The pointer came onto / left the panel.
  final VoidCallback onEnter;
  final VoidCallback onExit;

  /// Something in it was chosen: close it.
  final VoidCallback onDone;

  static const panel = Key('card.popover');
  static const playButton = Key('card.popover.play');
  static const watchedButton = Key('card.popover.watched');
  static const infoButton = Key('card.popover.info');

  /// Its width for a card picture [width] wide.
  static double widthFor(double width) => (width * 1.55).clamp(380, 520);

  /// Room kept for the part under the picture, to keep it on screen.
  static const bodyHeight = 260.0;

  /// Kept clear at the top: the top bar (the floating one is 72 high)
  /// and a gap.
  static const topBarRoom = 80.0;

  @override
  ConsumerState<CardPopover> createState() => _CardPopoverState();
}

class _CardPopoverState extends ConsumerState<CardPopover>
    with SingleTickerProviderStateMixin {
  late final _grow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_grow.forward());
  }

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  BaseItemDto get _full =>
      ref.watch(itemProvider(widget.item.id)).value ?? widget.item;

  void _go(String route) {
    widget.onDone();
    unawaited(context.push(route));
  }

  Future<void> _toggleWatched(bool played) async {
    setState(() => _saving = true);
    try {
      await ref
          .read(playbackRepositoryProvider)
          .setPlayed(widget.item.id, played: !played);
      ref
        ..invalidate(itemProvider(widget.item.id))
        ..invalidate(resumeProvider)
        ..invalidate(nextUpProvider)
        ..invalidate(latestProvider);
    } on Failure catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)
            ?.showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final origin = widget.origin;
    final width = CardPopover.widthFor(origin.width);
    final pictureHeight = width * 9 / 16;
    final left = (origin.center.dx - width / 2)
        .clamp(16.0, math.max(16.0, screen.width - width - 16))
        .toDouble();
    // Below the top bar (the variation keeps it under the bar).
    final minTop = MediaQuery.paddingOf(context).top + CardPopover.topBarRoom;
    final top = (origin.center.dy - pictureHeight / 2)
        .clamp(
          minTop,
          math.max(
            minTop,
            screen.height - pictureHeight - CardPopover.bodyHeight - 8,
          ),
        )
        .toDouble();
    final still = MediaQuery.disableAnimationsOf(context);
    final curve = CurvedAnimation(
      parent: _grow,
      curve: const Cubic(0.2, 0.8, 0.2, 1),
    );
    final fade = CurvedAnimation(
      parent: _grow,
      curve: const Interval(0, 0.57, curve: Curves.easeOut),
    );
    // Grows from the card's own size and place.
    final from = origin.width / width;
    final pivot = Offset(origin.center.dx - left, origin.center.dy - top);

    return Positioned(
      left: left,
      top: top,
      width: width,
      child: MouseRegion(
        onEnter: (_) => widget.onEnter(),
        onExit: (_) => widget.onExit(),
        child: AnimatedBuilder(
          animation: _grow,
          builder: (context, child) {
            final scale = still ? 1.0 : from + (1 - from) * curve.value;
            return Opacity(
              opacity: still ? 1 : fade.value,
              child: Transform(
                transform: Matrix4.identity()
                  ..translateByDouble(pivot.dx, pivot.dy, 0, 1)
                  ..scaleByDouble(scale, scale, 1, 1)
                  ..translateByDouble(-pivot.dx, -pivot.dy, 0, 1),
                child: child,
              ),
            );
          },
          child: _panel(context, width),
        ),
      ),
    );
  }

  Widget _panel(BuildContext context, double width) {
    final item = _full;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final data = item.userData;
    final played = data?.played ?? false;
    final position = ticksToDuration(data?.playbackPositionTicks ?? 0);
    final progress = (data?.playedPercentage ?? 0) / 100;
    final resumable = !played && position > Duration.zero;
    final pixels = (width * MediaQuery.devicePixelRatioOf(context)).round();
    final picture = ref
        .watch(libraryRepositoryProvider)
        .backdropUrl(item, maxWidth: pixels);

    final (String label, IconData icon, String route) = switch (item.type) {
      BaseItemKind.series => ('Episodes', Icons.list, Routes.item(item.id)),
      BaseItemKind.book => (
        resumable ? 'Continue reading' : 'Read',
        Icons.auto_stories,
        Routes.read(item.id),
      ),
      _ => (
        resumable ? 'Resume' : 'Play',
        Icons.play_arrow,
        Routes.play(item.id, start: resumable ? position : Duration.zero),
      ),
    };
    final facts = [
      ?item.productionYear?.toString(),
      if (item.type == BaseItemKind.series && (item.childCount ?? 0) > 0)
        '${item.childCount} ${item.childCount == 1 ? 'season' : 'seasons'}'
      else if (item.runTimeTicks case final int t
          when t > 0 && item.type != BaseItemKind.book)
        formatRuntime(ticksToDuration(t)),
    ];
    final context2 = switch (item.type) {
      BaseItemKind.episode => [
        ?item.seriesName,
        ?episodeNumber(item),
      ].join(' · '),
      _ => null,
    };
    const ink = Colors.white;
    const muted = Color(0xFF9AABB6);

    return Material(
      key: CardPopover.panel,
      color: const Color(0xFF0B1118),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0x0FFFFFFF)),
      ),
      shadowColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0xBF000000),
              blurRadius: 48,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _go(Routes.item(item.id)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ColoredBox(
                  color: const Color(0xFF1B2530),
                  child: picture == null
                      ? ItemImage(item: item, width: width)
                      : Image.network(
                          picture.toString(),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              ItemImage(item: item, width: width),
                        ),
                ),
              ),
            ),
            if (progress > 0 && progress < 1)
              SizedBox(
                height: 4,
                child: ColoredBox(
                  color: const Color(0x40FFFFFF),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: ColoredBox(color: theme.colorScheme.primary),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _go(Routes.item(item.id)),
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: ink,
                        fontSize: 24,
                        height: 30 / 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (context2 != null && context2.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      context2,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          key: CardPopover.playButton,
                          onPressed: () => _go(route),
                          icon: Icon(icon, size: 26),
                          label: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ButtonStyle(
                            fixedSize: const WidgetStatePropertyAll(
                              Size.fromHeight(52),
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            backgroundColor: WidgetStateProperty.resolveWith(
                              (s) => s.contains(WidgetState.hovered)
                                  ? const Color(0xFFE3E9EF)
                                  : Colors.white,
                            ),
                            foregroundColor: const WidgetStatePropertyAll(
                              Color(0xFF00050D),
                            ),
                            iconColor: const WidgetStatePropertyAll(
                              Color(0xFF00050D),
                            ),
                            overlayColor: const WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                            textStyle: WidgetStatePropertyAll(
                              theme.textTheme.labelLarge?.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _Round(
                        key: CardPopover.watchedButton,
                        tooltip: played
                            ? 'Mark as unwatched'
                            : 'Mark as watched',
                        icon: Icons.check,
                        on: played,
                        onPressed: _saving
                            ? null
                            : () => unawaited(_toggleWatched(played)),
                      ),
                      const SizedBox(width: 12),
                      _Round(
                        key: CardPopover.infoButton,
                        tooltip: 'Details',
                        icon: Icons.info_outline,
                        onPressed: () => _go(Routes.item(item.id)),
                      ),
                    ],
                  ),
                  if (facts.isNotEmpty || item.officialRating != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (item.officialRating case final String rating) ...[
                          DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0x59FFFFFF),
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                rating,
                                style: tokens.overline.copyWith(
                                  color: ink,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Flexible(
                          child: Text(
                            facts.join('   '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: muted,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (item.overview case final String overview
                      when overview.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      overview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ink,
                        fontSize: 15,
                        height: 21 / 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Round extends StatelessWidget {
  const _Round({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.on = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool on;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    isSelected: on,
    iconSize: 26,
    icon: Icon(icon),
    style: ButtonStyle(
      fixedSize: const WidgetStatePropertyAll(Size.square(52)),
      foregroundColor: WidgetStatePropertyAll(
        on ? const Color(0xFF00050D) : Colors.white,
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) => on
            ? Colors.white
            : Colors.white.withValues(
                alpha: s.contains(WidgetState.hovered) ? 0.32 : 0.2,
              ),
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
  );
}
