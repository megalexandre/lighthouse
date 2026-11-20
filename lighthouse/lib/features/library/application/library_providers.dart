import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../data/library_repository.dart';

// One provider per thing a screen shows. They all watch the repository,
// which follows the session: signing in as someone else reloads them all.
// Screens retry with ref.invalidate (the app turns automatic retry off).

final userViewsProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) => ref.watch(libraryRepositoryProvider).views(),
);

/// The home carousel's items. A failure leaves the carousel out (the rows
/// still show); it goes to the log.
final featuredProvider = FutureProvider.autoDispose<List<BaseItemDto>>((
  ref,
) async {
  try {
    return await ref.watch(libraryRepositoryProvider).featured();
  } on Failure catch (e) {
    log.warning('home', 'carousel items not loaded', e);
    rethrow;
  }
});

final resumeProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) => ref.watch(libraryRepositoryProvider).resume(),
);

final resumeBooksProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) => ref.watch(libraryRepositoryProvider).resumeBooks(),
);

final nextUpProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) => ref.watch(libraryRepositoryProvider).nextUp(),
);

/// The episode a started series goes on with: the next one up, once some
/// episode was watched or one is in progress. Null for a series not
/// started (12.4 offers its first episode as next up all the same) or
/// watched to the end.
final continueSeriesProvider = FutureProvider.autoDispose
    .family<BaseItemDto?, String>((ref, seriesId) async {
      final (series, next) = await (
        ref.watch(itemProvider(seriesId).future),
        ref.watch(libraryRepositoryProvider).nextUpOf(seriesId),
      ).wait;
      if (next == null) return null;
      final watchedSome = (series.userData?.playedPercentage ?? 0) > 0;
      final inProgress = (next.userData?.playbackPositionTicks ?? 0) > 0;
      return watchedSome || inProgress ? next : null;
    });

/// Recently added, by library id.
final latestProvider = FutureProvider.autoDispose
    .family<List<BaseItemDto>, String>(
      (ref, viewId) => ref.watch(libraryRepositoryProvider).latest(viewId),
    );

final itemProvider = FutureProvider.autoDispose.family<BaseItemDto, String>(
  (ref, id) => ref.watch(libraryRepositoryProvider).item(id),
);

final seasonsProvider = FutureProvider.autoDispose
    .family<List<BaseItemDto>, String>(
      (ref, seriesId) => ref.watch(libraryRepositoryProvider).seasons(seriesId),
    );

final episodesProvider = FutureProvider.autoDispose
    .family<List<BaseItemDto>, ({String seriesId, String seasonId})>(
      (ref, season) => ref
          .watch(libraryRepositoryProvider)
          .episodes(season.seriesId, season.seasonId),
    );

final tracksProvider = FutureProvider.autoDispose
    .family<List<BaseItemDto>, String>(
      (ref, albumId) => ref.watch(libraryRepositoryProvider).tracks(albumId),
    );

/// What the user watched or read changed on the server (something played,
/// stopped, read, or marked). Its value only counts the changes: library
/// grids listen to it and refresh the items they hold in place.
final watchStateProvider = NotifierProvider<WatchState, int>(WatchState.new);

class WatchState extends Notifier<int> {
  @override
  int build() => 0;

  /// Every list that shows watched marks, places or unplayed counts loads
  /// again: those on a screen do (the screens under the player, the
  /// reader, a popover); the others are not alive and load fresh anyway.
  void changed() {
    ref
      ..invalidate(itemProvider)
      ..invalidate(resumeProvider)
      ..invalidate(resumeBooksProvider)
      ..invalidate(nextUpProvider)
      ..invalidate(continueSeriesProvider)
      ..invalidate(latestProvider)
      ..invalidate(seasonsProvider)
      ..invalidate(episodesProvider)
      ..invalidate(tracksProvider);
    state++;
  }
}

/// A library grid: the folder, the items loaded so far and how many exist.
@immutable
class LibraryPage {
  const LibraryPage({
    required this.parent,
    required this.items,
    required this.total,
    this.loadingMore = false,
    this.moreError,
  });

  final BaseItemDto parent;
  final List<BaseItemDto> items;
  final int total;
  final bool loadingMore;

  /// Why the last [LibraryController.loadMore] failed.
  final Failure? moreError;

  bool get hasMore => items.length < total;

  LibraryPage copyWith({
    List<BaseItemDto>? items,
    int? total,
    bool? loadingMore,
    Failure? Function()? moreError,
  }) => LibraryPage(
    parent: parent,
    items: items ?? this.items,
    total: total ?? this.total,
    loadingMore: loadingMore ?? this.loadingMore,
    moreError: moreError == null ? this.moreError : moreError(),
  );
}

final libraryControllerProvider = AsyncNotifierProvider.autoDispose
    .family<LibraryController, LibraryPage, String>(LibraryController.new);

/// Pages through the children of one library or folder. The first page
/// comes with the state; the grid asks for more as it scrolls.
class LibraryController extends AsyncNotifier<LibraryPage> {
  LibraryController(this.parentId);

  final String parentId;

  /// Items per request, as jellyfin-web does.
  static const pageSize = 100;

  LibraryRepository get _repo => ref.read(libraryRepositoryProvider);

  @override
  Future<LibraryPage> build() async {
    final repo = ref.watch(libraryRepositoryProvider);
    // Not invalidated with the other lists: that would bring back only the
    // first page, and the grid would lose its place.
    ref.listen(watchStateProvider, (_, _) => unawaited(_refresh()));
    final parent = await repo.item(parentId);
    final first = await repo.children(parent, startIndex: 0, limit: pageSize);
    return LibraryPage(
      parent: parent,
      items: first.items,
      total: first.totalRecordCount,
    );
  }

  /// The items loaded so far, again, in one request: their watched marks
  /// and places changed. In place, so the grid stays where it was; a
  /// failure keeps what is shown.
  Future<void> _refresh() async {
    final page = state.value;
    if (page == null) return;
    try {
      final fresh = await _repo.children(
        page.parent,
        startIndex: 0,
        limit: math.max(page.items.length, pageSize),
      );
      if (!ref.mounted) return;
      state = AsyncData(
        (state.value ?? page).copyWith(
          items: fresh.items,
          total: fresh.totalRecordCount,
        ),
      );
    } on Failure catch (e) {
      log.warning('library', 'grid not refreshed', e);
    }
  }

  /// Loads the next page, unless one is loading or all are loaded. A
  /// failure is kept in [LibraryPage.moreError]; calling again retries.
  Future<void> loadMore() async {
    final page = state.value;
    if (page == null || page.loadingMore || !page.hasMore) return;
    state = AsyncData(page.copyWith(loadingMore: true, moreError: () => null));
    try {
      final next = await _repo.children(
        page.parent,
        startIndex: page.items.length,
        limit: pageSize,
      );
      if (!ref.mounted) return;
      final items = [...page.items, ...next.items];
      state = AsyncData(
        page.copyWith(
          items: items,
          // An empty page means the count was stale: stop asking.
          total: next.items.isEmpty ? items.length : next.totalRecordCount,
          loadingMore: false,
        ),
      );
    } on Failure catch (e) {
      if (!ref.mounted) return;
      state = AsyncData(page.copyWith(loadingMore: false, moreError: () => e));
    }
  }
}
