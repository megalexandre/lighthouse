import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/failure.dart';
import '../../../core/ticks.dart';
import '../../../router.dart';
import '../../../widgets/error_retry.dart';
import '../../library/application/library_providers.dart';
import '../../library/presentation/item_card.dart';
import '../../player/data/playback_repository.dart';

/// Detail page of one item: picture, facts and overview, then what is
/// inside it (seasons of a series, episodes of a season, tracks of an
/// album).
class ItemScreen extends ConsumerWidget {
  const ItemScreen({super.key, required this.itemId});

  static const title = Key('item.title');
  static const seriesLink = Key('item.series');
  static const playButton = Key('item.play');
  static const resumeButton = Key('item.resume');
  static const watchedButton = Key('item.watched');
  static Key episodeKey(String id) => Key('episode.$id');
  static Key trackKey(String id) => Key('track.$id');

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(itemProvider(itemId));
    return Scaffold(
      appBar: AppBar(title: Text(item.value?.name ?? '')),
      body: switch (item) {
        AsyncData(value: final item) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _Header(item: item),
            if (isPlayable(item)) ...[
              const SizedBox(height: 24),
              _PlayButtons(item: item),
            ],
            const SizedBox(height: 32),
            ...switch (item.type) {
              BaseItemKind.series => [_Seasons(seriesId: item.id)],
              BaseItemKind.season when item.seriesId != null => [
                _Episodes(seriesId: item.seriesId!, seasonId: item.id),
              ],
              BaseItemKind.musicAlbum => [_Tracks(albumId: item.id)],
              _ => const <Widget>[],
            },
          ],
        ),
        AsyncError(:final error) => Center(
          child: ErrorRetry(
            error: error,
            onRetry: () => ref.invalidate(itemProvider(itemId)),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// Whether [item] opens in the player (series, seasons and albums list
/// what to play instead).
bool isPlayable(BaseItemDto item) => switch (item.type) {
  BaseItemKind.movie ||
  BaseItemKind.episode ||
  BaseItemKind.video ||
  BaseItemKind.audio => true,
  _ => false,
};

/// Play (or Resume + Start over when partly watched), and watched / not.
class _PlayButtons extends ConsumerStatefulWidget {
  const _PlayButtons({required this.item});

  final BaseItemDto item;

  @override
  ConsumerState<_PlayButtons> createState() => _PlayButtonsState();
}

class _PlayButtonsState extends ConsumerState<_PlayButtons> {
  bool _saving = false;

  BaseItemDto get item => widget.item;

  Future<void> _play(Duration start) async {
    await context.push(Routes.play(item.id, start: start));
  }

  Future<void> _toggleWatched(bool played) async {
    setState(() => _saving = true);
    try {
      await ref
          .read(playbackRepositoryProvider)
          .setPlayed(item.id, played: !played);
      ref
        ..invalidate(itemProvider(item.id))
        ..invalidate(resumeProvider)
        ..invalidate(nextUpProvider);
    } on Failure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = item.userData;
    final played = data?.played ?? false;
    final position = ticksToDuration(data?.playbackPositionTicks ?? 0);
    final resumable = !played && position > Duration.zero;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (resumable) ...[
          FilledButton.icon(
            key: ItemScreen.resumeButton,
            icon: const Icon(Icons.play_arrow),
            label: Text('Resume from ${formatPosition(position)}'),
            onPressed: () => _play(position),
          ),
          OutlinedButton.icon(
            key: ItemScreen.playButton,
            icon: const Icon(Icons.replay),
            label: const Text('Start over'),
            onPressed: () => _play(Duration.zero),
          ),
        ] else
          FilledButton.icon(
            key: ItemScreen.playButton,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play'),
            onPressed: () => _play(Duration.zero),
          ),
        IconButton(
          key: ItemScreen.watchedButton,
          tooltip: played ? 'Mark as unwatched' : 'Mark as watched',
          isSelected: played,
          icon: const Icon(Icons.check_circle_outline),
          selectedIcon: const Icon(Icons.check_circle),
          onPressed: _saving ? null : () => _toggleWatched(played),
        ),
      ],
    );
  }
}

/// Year · 1h 32m · rating, whichever are known.
String itemFacts(BaseItemDto item) => [
  ?episodeNumber(item),
  ?item.productionYear?.toString(),
  if (item.runTimeTicks case final int ticks when ticks > 0)
    formatRuntime(ticksToDuration(ticks)),
  ?item.officialRating,
].join(' · ');

class _Header extends StatelessWidget {
  const _Header({required this.item});

  final BaseItemDto item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final facts = itemFacts(item);
    final seriesId = item.seriesId;

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (seriesId != null && item.seriesName != null)
          TextButton(
            key: ItemScreen.seriesLink,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => context.push(Routes.item(seriesId)),
            child: Text(item.seriesName!, style: theme.textTheme.titleMedium),
          ),
        Text(
          item.name,
          key: ItemScreen.title,
          style: theme.textTheme.headlineMedium,
        ),
        if (item.albumArtist != null)
          Text(item.albumArtist!, style: theme.textTheme.titleMedium),
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
        if (item.userData?.played ?? false)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 18),
                SizedBox(width: 6),
                Text('Watched'),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;
        final posterWidth = wide ? 240.0 : constraints.maxWidth;
        final poster = SizedBox(
          width: posterWidth,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: cardAspectRatio(item.type),
              child: ItemImage(item: item, width: posterWidth),
            ),
          ),
        );
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
}

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
        AsyncData(value: final items) when items.isEmpty => const Text(
          'Nothing here yet.',
        ),
        AsyncData(value: final items) => builder(items),
        AsyncError(:final error) => ErrorRetry(error: error, onRetry: onRetry),
        _ => const Center(child: CircularProgressIndicator()),
      },
    ],
  );
}

class _Seasons extends ConsumerWidget {
  const _Seasons({required this.seriesId});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _Section(
    title: 'Seasons',
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

class _Episodes extends ConsumerWidget {
  const _Episodes({required this.seriesId, required this.seasonId});

  final String seriesId;
  final String seasonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = episodesProvider((seriesId: seriesId, seasonId: seasonId));
    return _Section(
      title: 'Episodes',
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
      borderRadius: BorderRadius.circular(8),
      onTap: () => context.push(Routes.item(episode.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
                        const Icon(Icons.check_circle_outline, size: 18),
                    ],
                  ),
                  if (episode.runTimeTicks case final int ticks when ticks > 0)
                    Text(
                      formatRuntime(ticksToDuration(ticks)),
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

class _Tracks extends ConsumerWidget {
  const _Tracks({required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => _Section(
    title: 'Tracks',
    items: ref.watch(tracksProvider(albumId)),
    onRetry: () => ref.invalidate(tracksProvider(albumId)),
    builder: (tracks) => Column(
      children: [
        for (final track in tracks)
          ListTile(
            key: ItemScreen.trackKey(track.id),
            contentPadding: EdgeInsets.zero,
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
                : Text(formatRuntime(ticksToDuration(track.runTimeTicks!))),
          ),
      ],
    ),
  );
}
