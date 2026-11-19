import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../widgets/error_retry.dart';
import '../../library/application/library_providers.dart';
import 'item_actions.dart';
import 'item_children.dart';
import 'item_header.dart';

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
  static const readButton = Key('item.read');
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
            ItemHeader(item: item),
            if (isPlayable(item)) ...[
              const SizedBox(height: 24),
              PlayButtons(item: item),
            ],
            if (item.type == BaseItemKind.book) ...[
              const SizedBox(height: 24),
              ReadButtons(item: item),
            ],
            const SizedBox(height: 32),
            ...switch (item.type) {
              BaseItemKind.series => [SeasonList(seriesId: item.id)],
              BaseItemKind.season when item.seriesId != null => [
                EpisodeList(seriesId: item.seriesId!, seasonId: item.id),
              ],
              BaseItemKind.musicAlbum => [TrackList(albumId: item.id)],
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
