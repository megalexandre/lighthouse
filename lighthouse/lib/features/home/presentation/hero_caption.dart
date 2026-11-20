import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/ticks.dart';
import '../../../l10n/l10n.dart';
import '../../../router.dart';
import '../../../widgets/focus_ring.dart';
import '../../library/application/library_providers.dart';
import '../../library/presentation/item_card.dart';
import 'hero_carousel.dart';

/// The slide's text and buttons: MOVIE or SERIES, the title in capitals
/// (sized to the window), the facts, the start of the overview, Play (for
/// a series: its next episode once started, else Episodes) and More info.
class HeroCaption extends StatelessWidget {
  const HeroCaption({super.key, required this.item, required this.narrow});

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
        formatRuntime(ticksToDuration(t), context.l10n),
      ?item.officialRating,
    ].join(' · ');
    return DefaultTextStyle.merge(
      style: TextStyle(color: ink),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            movie ? context.l10n.heroMovie : context.l10n.heroSeries,
            style: tokens.overline.copyWith(
              color: theme.colorScheme.inversePrimary,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: tokens.space(3)),
          _Title(name: item.name, narrow: narrow),
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
          _Actions(item: item, movie: movie, narrow: narrow),
        ],
      ),
    );
  }
}

/// The item's name in capitals, sized to the window (so not a fixed step
/// of the type scale), over a soft shadow.
class _Title extends StatelessWidget {
  const _Title({required this.name, required this.narrow});

  final String name;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final size = narrow
        ? 30.0
        : (MediaQuery.sizeOf(context).width * 0.042).clamp(36.0, 68.0);
    return Text(
      name.toUpperCase(),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
        color: tokens.osdInk,
        fontSize: size,
        height: 1.08,
        fontWeight: FontWeight.w600,
        letterSpacing: size * (narrow ? 0.08 : 0.14),
        shadows: [
          Shadow(
            blurRadius: 16,
            color: tokens.mediaShade.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}

/// Play and More info. A series plays on from its next episode once
/// started (where that one was left, when it is in progress); until then,
/// or while the server is asked, the button opens its episodes.
class _Actions extends ConsumerWidget {
  const _Actions({
    required this.item,
    required this.movie,
    required this.narrow,
  });

  final BaseItemDto item;
  final bool movie;
  final bool narrow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = movie
        ? null
        : ref.watch(continueSeriesProvider(item.id)).value;
    final l10n = context.l10n;
    final number = next == null ? null : episodeNumber(next, l10n);
    return Row(
      children: [
        if (movie || next != null)
          _WhiteButton(
            key: HeroCarousel.playButton,
            label: number == null ? l10n.play : l10n.playEpisode(number),
            icon: Icons.play_arrow,
            big: !narrow,
            onPressed: () => context.push(switch (next) {
              final BaseItemDto e => Routes.play(
                e.id,
                start: ticksToDuration(e.userData?.playbackPositionTicks ?? 0),
              ),
              null => Routes.play(item.id),
            }),
          )
        else
          _WhiteButton(
            key: HeroCarousel.playButton,
            label: l10n.episodes,
            icon: Icons.list,
            big: !narrow,
            onPressed: () => context.push(Routes.item(item.id)),
          ),
        SizedBox(width: context.tokens.space(4)),
        _RoundButton(
          key: HeroCarousel.infoButton,
          tooltip: context.l10n.moreInfo,
          icon: Icons.info_outline,
          big: !narrow,
          onPressed: () => context.push(Routes.item(item.id)),
        ),
      ],
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
