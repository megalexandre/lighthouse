import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/failure.dart';
import '../data/library_repository.dart';

// One provider per thing a screen shows. They all watch the repository,
// which follows the session: signing in as someone else reloads them all.
// Screens retry with ref.invalidate (the app turns automatic retry off).

final userViewsProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) => ref.watch(libraryRepositoryProvider).views(),
);

/// The home carousel's items.
final featuredProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) => ref.watch(libraryRepositoryProvider).featured(),
);

final resumeProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) => ref.watch(libraryRepositoryProvider).resume(),
);

final resumeBooksProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) => ref.watch(libraryRepositoryProvider).resumeBooks(),
);

final nextUpProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) => ref.watch(libraryRepositoryProvider).nextUp(),
);

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
    final parent = await repo.item(parentId);
    final first = await repo.children(parent, startIndex: 0, limit: pageSize);
    return LibraryPage(
      parent: parent,
      items: first.items,
      total: first.totalRecordCount,
    );
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
