import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/ticks.dart';
import '../../../l10n/l10n.dart';
import '../../../router.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/error_retry.dart';
import '../../library/application/library_providers.dart';
import '../../library/presentation/item_card.dart';
import 'item_screen.dart';

/// Section title, then [body] for the list's loading/error/data states.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.items,
    required this.onRetry,
    required this.builder,
  });

  final String title;
  final AsyncValue<List<BaseItemDto>> items;
  final VoidCallback onRetry;
  final Widget Function(List<BaseItemDto> items) builder;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      switch (items) {
        AsyncData(value: final items) when items.isEmpty => Text(
          context.l10n.nothingHere,
        ),
        AsyncData(value: final items) => builder(items),
        AsyncError(:final error) => ErrorRetry(error: error, onRetry: onRetry),
        _ => const Center(child: CircularProgressIndicator()),
      },
    ],
  );
}

class SeasonList extends ConsumerWidget {
  const SeasonList({super.key, required this.seriesId});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _Section(
    title: context.l10n.seasons,
    items: ref.watch(seasonsProvider(seriesId)),
    onRetry: () => ref.invalidate(seasonsProvider(seriesId)),
    builder: (seasons) => Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final season in seasons) ItemCard(item: season, width: 150),
      ],
    ),
  );
}

class EpisodeList extends ConsumerWidget {
  const EpisodeList({
    super.key,
    required this.seriesId,
    required this.seasonId,
  });

  final String seriesId;
  final String seasonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = episodesProvider((seriesId: seriesId, seasonId: seasonId));
    return _Section(
      title: context.l10n.episodes,
      items: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      builder: (episodes) => Column(
        children: [
          for (final episode in episodes) _EpisodeTile(episode: episode),
        ],
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({required this.episode});

  final BaseItemDto episode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (episode.userData?.playedPercentage ?? 0) / 100;
    final number = episode.indexNumber;
    return InkWell(
      key: ItemScreen.episodeKey(episode.id),
      borderRadius: BorderRadius.circular(context.tokens.radiusMd),
      onTap: () => context.push(Routes.item(episode.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.tokens.radiusMd),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ItemImage(item: episode, width: 200),
                      if (progress > 0)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: LinearProgressIndicator(value: progress),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          number == null
                              ? episode.name
                              : '$number. ${episode.name}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      if (episode.userData?.played ?? false)
                        const Icon(
                          Icons.check_circle_outline,
                          key: ItemCard.watchedMark,
                          size: 18,
                        ),
                    ],
                  ),
                  if (episode.runTimeTicks case final int ticks when ticks > 0)
                    Text(
                      formatRuntime(ticksToDuration(ticks), context.l10n),
                      style: theme.textTheme.bodySmall,
                    ),
                  if (episode.overview case final String overview
                      when overview.isNotEmpty)
                    Text(
                      overview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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

class TrackList extends ConsumerWidget {
  const TrackList({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _Section(
    title: context.l10n.tracks,
    items: ref.watch(tracksProvider(albumId)),
    onRetry: () => ref.invalidate(tracksProvider(albumId)),
    builder: (tracks) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The album plays on from the chosen track (see PlayerScreen).
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppButton(
            key: ItemScreen.playButton,
            icon: Icons.play_arrow,
            label: context.l10n.play,
            onPressed: () => context.push(Routes.play(tracks.first.id)),
          ),
        ),
        for (final track in tracks)
          ListTile(
            key: ItemScreen.trackKey(track.id),
            contentPadding: EdgeInsets.zero,
            onTap: () => context.push(Routes.play(track.id)),
            leading: SizedBox(
              width: 32,
              child: Text(
                track.indexNumber?.toString() ?? '',
                textAlign: TextAlign.end,
              ),
            ),
            title: Text(track.name),
            trailing: track.runTimeTicks == null
                ? null
                : Text(
                    formatRuntime(
                      ticksToDuration(track.runTimeTicks!),
                      context.l10n,
                    ),
                  ),
          ),
      ],
    ),
  );
}
