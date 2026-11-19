import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../api/models/media_stream.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/ticks.dart';
import '../../../core/window_size.dart';
import '../../../l10n/l10n.dart';
import '../../../router.dart';
import '../../../widgets/media_badge.dart';
import '../../library/presentation/item_card.dart';
import 'item_screen.dart';

/// The file's technical labels, as the design system shows them: its
/// resolution (4K, 1080P, 720P), dynamic range (HDR10, DOLBY VISION, HLG),
/// surround sound (5.1, 7.1) and CC when it has subtitles.
List<String> technicalBadges(BaseItemDto item) {
  final streams = item.mediaStreams;
  final video = streams
      .where((s) => s.type == MediaStreamType.video)
      .firstOrNull;
  final channels = streams
      .where((s) => s.type == MediaStreamType.audio)
      .map((s) => s.channels ?? 0)
      .fold(0, (a, b) => a > b ? a : b);
  return [
    if (video?.width case final int w)
      if (w >= 3200)
        '4K'
      else if (w >= 1800)
        '1080P'
      else if (w >= 1200)
        '720P',
    if (video?.videoRangeType case final String range)
      if (range.startsWith('DOVI'))
        'Dolby Vision'
      else if (range.startsWith('HDR10'))
        'HDR10'
      else if (range == 'HLG')
        'HLG',
    if (channels >= 8) '7.1' else if (channels >= 6) '5.1',
    if (streams.any((s) => s.type == MediaStreamType.subtitle)) 'CC',
  ];
}

/// Year · 1h 32m · rating, whichever are known.
String itemFacts(BaseItemDto item, AppLocalizations l10n) => [
  ?episodeNumber(item, l10n),
  ?item.productionYear?.toString(),
  // A book's "length" is its page count in server units, not a time.
  if (item.runTimeTicks case final int ticks
      when ticks > 0 && item.type != BaseItemKind.book)
    formatRuntime(ticksToDuration(ticks), l10n),
  ?item.officialRating,
].join(' · ');

/// The item's poster beside its text (above it in a narrow window).
class ItemHeader extends StatelessWidget {
  const ItemHeader({super.key, required this.item});

  final BaseItemDto item;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = WindowSize.ofWidth(constraints.maxWidth)
          .atLeast(WindowSize.medium);
      final poster = _Poster(
        item: item,
        width: wide ? 240.0 : constraints.maxWidth,
      );
      final text = _HeaderText(item: item);
      if (!wide) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [poster, const SizedBox(height: 16), text],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          poster,
          const SizedBox(width: 32),
          Expanded(child: text),
        ],
      );
    },
  );
}

/// The item's picture, rounded as its card is.
class _Poster extends StatelessWidget {
  const _Poster({required this.item, required this.width});

  final BaseItemDto item;
  final double width;

  @override
  Widget build(BuildContext context) {
    final aspect = cardAspectRatio(item.type);
    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          aspect < 1 ? context.tokens.radiusSm : context.tokens.radiusMd,
        ),
        child: AspectRatio(
          aspectRatio: aspect,
          child: ItemImage(item: item, width: width),
        ),
      ),
    );
  }
}

/// The series (a link), the name, the artist, the facts, the technical
/// badges, "Watched", and the overview.
class _HeaderText extends StatelessWidget {
  const _HeaderText({required this.item});

  final BaseItemDto item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final facts = itemFacts(item, context.l10n);
    final badges = technicalBadges(item);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((item.seriesId, item.seriesName) case (
          final String seriesId,
          final String seriesName,
        ))
          TextButton(
            key: ItemScreen.seriesLink,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => context.push(Routes.item(seriesId)),
            child: Text(seriesName, style: theme.textTheme.titleMedium),
          ),
        Text(
          item.name,
          key: ItemScreen.title,
          style: theme.textTheme.headlineLarge,
        ),
        if (item.albumArtist case final String artist)
          Text(artist, style: theme.textTheme.titleMedium),
        if (facts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              facts,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (badges.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: context.tokens.space(1),
              runSpacing: context.tokens.space(1),
              children: [for (final b in badges) MediaBadge(b)],
            ),
          ),
        if (item.userData?.played ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 18),
                const SizedBox(width: 6),
                Text(context.l10n.watched),
              ],
            ),
          ),
        if (item.overview case final String overview when overview.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(overview, style: theme.textTheme.bodyLarge),
          ),
      ],
    );
  }
}
