import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/failure.dart';
import '../../library/data/library_repository.dart';

/// What plays before and after an item: the episodes around it in its
/// series, the tracks around it in its album. Nothing for a movie.
typedef Neighbors = ({BaseItemDto? previous, BaseItemDto? next});

const noNeighbors = (previous: null, next: null);

/// The items just before and after [itemId] in [queue].
Neighbors neighborsIn(List<BaseItemDto> queue, String itemId) {
  final at = queue.indexWhere((i) => i.id == itemId);
  if (at < 0) return noNeighbors;
  return (
    previous: at > 0 ? queue[at - 1] : null,
    next: at + 1 < queue.length ? queue[at + 1] : null,
  );
}

final playNeighborsProvider = FutureProvider.autoDispose
    .family<Neighbors, String>((ref, itemId) async {
      final library = ref.watch(libraryRepositoryProvider);
      try {
        final item = await library.item(itemId);
        final queue = switch (item) {
          BaseItemDto(type: BaseItemKind.episode, seriesId: final String id) =>
            await library.seriesEpisodes(id),
          BaseItemDto(type: BaseItemKind.audio, albumId: final String id) =>
            await library.tracks(id),
          _ => const <BaseItemDto>[],
        };
        return neighborsIn(queue, itemId);
      } on Failure catch (e) {
        // Playback goes on without Next / Previous.
        debugPrint('could not find what plays next: $e');
        return noNeighbors;
      }
    });
