import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/client_info.dart';
import '../../../api/images.dart';
import '../../../api/items.dart';
import '../../../api/jellyfin_api.dart';
import '../../../api/models/base_item_dto.dart';
import '../../../api/models/base_item_dto_query_result.dart';
import '../../../api/shows.dart';
import '../../../core/failure.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/data/session.dart';
import '../../auth/data/session_client.dart';
import '../../server/application/connection_controller.dart';

/// Browsing the signed-in user's media. Every method throws a [Failure].
abstract interface class LibraryRepository {
  /// The user's libraries.
  Future<List<BaseItemDto>> views();

  /// One page of what [parent] (a library or folder) shows as a grid.
  Future<BaseItemDtoQueryResult> children(
    BaseItemDto parent, {
    required int startIndex,
    required int limit,
  });

  Future<BaseItemDto> item(String id);

  /// Recently added to the library [viewId].
  Future<List<BaseItemDto>> latest(String viewId);

  /// What the home carousel shows: the movies and series added last,
  /// across the libraries, with their overview.
  Future<List<BaseItemDto>> featured();

  /// Continue watching.
  Future<List<BaseItemDto>> resume();

  /// Continue reading: books partly read, last read first.
  Future<List<BaseItemDto>> resumeBooks();

  /// Next episode of each series in progress.
  Future<List<BaseItemDto>> nextUp();

  /// The episode of [seriesId] to watch next: the one in progress, else the
  /// first one not watched. Null when every episode was watched.
  Future<BaseItemDto?> nextUpOf(String seriesId);

  Future<List<BaseItemDto>> seasons(String seriesId);
  Future<List<BaseItemDto>> episodes(String seriesId, String seasonId);

  /// Every episode of the series, all seasons, in broadcast order.
  Future<List<BaseItemDto>> seriesEpisodes(String seriesId);

  /// Movies, shows, episodes, albums and songs whose name matches
  /// [term].
  Future<List<BaseItemDto>> search(String term);

  /// Tracks of an album, in disc and track order.
  Future<List<BaseItemDto>> tracks(String albumId);

  /// The image to show for [item] at about [maxWidth] pixels, or null when
  /// it has none.
  Uri? imageUrl(BaseItemDto item, {required int maxWidth});

  /// A wide picture of [item] (its backdrop), or its own image when it has
  /// no backdrop; null when it has neither.
  Uri? backdropUrl(BaseItemDto item, {required int maxWidth});
}

/// How many items the home carousel shows.
const featuredLimit = 6;

/// What search looks for, in the order results are shown.
const searchKinds = [
  BaseItemKind.movie,
  BaseItemKind.series,
  BaseItemKind.episode,
  BaseItemKind.musicAlbum,
  BaseItemKind.audio,
  BaseItemKind.book,
];

/// How many items the home rows ask for.
const homeRowLimit = 16;

/// What a grid of [parent]'s children lists: a movie library lists every
/// movie in it, wherever it sits in folders; a plain folder lists what is
/// directly inside.
({bool recursive, List<BaseItemKind> types}) childrenQuery(
  BaseItemDto parent,
) => switch (parent.collectionType) {
  'movies' => (recursive: true, types: [BaseItemKind.movie]),
  'tvshows' => (recursive: true, types: [BaseItemKind.series]),
  'music' => (recursive: true, types: [BaseItemKind.musicAlbum]),
  'boxsets' => (recursive: true, types: [BaseItemKind.boxSet]),
  'books' => (recursive: true, types: [BaseItemKind.book]),
  _ => (recursive: false, types: const []),
};

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final session = ref.watch(
    authControllerProvider.select((auth) => auth.value?.session),
  );
  // Signing out rebuilds the screens still on stage during the transition
  // to login; they get Unauthorized (shown as an error for that moment)
  // instead of an exception escaping the provider.
  if (session == null) return const SignedOutLibraryRepository();
  // Read now, not when a call finishes: by then this provider may be gone
  // (signed out mid-playback), and its ref with it.
  final client = ref.read(clientInfoProvider.future);
  final auth = ref.read(authControllerProvider.notifier);
  final connection = ref.read(connectionProvider.notifier);
  return JellyfinLibraryRepository(
    session,
    () => client,
    onUnauthorized: auth.sessionExpired,
    onReachability: connection.report,
  );
});

class JellyfinLibraryRepository implements LibraryRepository {
  JellyfinLibraryRepository(
    Session session,
    Future<ClientInfo> Function() client, {
    required void Function() onUnauthorized,
    ReachabilityListener? onReachability,
    HttpClientAdapter? adapter,
  }) : _client = SessionClient(
         session,
         client,
         onUnauthorized: onUnauthorized,
         onReachability: onReachability,
         adapter: adapter,
       );

  final SessionClient _client;

  Session get session => _client.session;
  String get _user => _client.userId;

  Future<T> _call<T>(Future<T> Function(JellyfinApi api) request) =>
      _client.call(request);

  @override
  Future<List<BaseItemDto>> views() =>
      _call((api) async => (await api.userViews(_user)).items);

  @override
  Future<BaseItemDtoQueryResult> children(
    BaseItemDto parent, {
    required int startIndex,
    required int limit,
  }) {
    final query = childrenQuery(parent);
    return _call(
      (api) => api.items(
        userId: _user,
        parentId: parent.id,
        recursive: query.recursive,
        includeItemTypes: query.types,
        startIndex: startIndex,
        limit: limit,
      ),
    );
  }

  @override
  Future<BaseItemDto> item(String id) => _call((api) => api.item(_user, id));

  @override
  Future<List<BaseItemDto>> latest(String viewId) =>
      _call((api) => api.latest(_user, parentId: viewId, limit: homeRowLimit));

  @override
  Future<List<BaseItemDto>> featured() => _call(
    (api) async => (await api.items(
      userId: _user,
      recursive: true,
      includeItemTypes: const [BaseItemKind.movie, BaseItemKind.series],
      sortBy: const [ItemSort.dateCreated],
      descending: true,
      limit: featuredLimit,
      fields: const ['Overview'],
    )).items,
  );

  @override
  Future<List<BaseItemDto>> resume() => _call(
    (api) async => (await api.resume(_user, limit: homeRowLimit)).items,
  );

  @override
  Future<List<BaseItemDto>> resumeBooks() => _call(
    (api) async => (await api.resume(
      _user,
      limit: homeRowLimit,
      mediaTypes: const ['Book'],
    )).items,
  );

  @override
  Future<List<BaseItemDto>> nextUp() => _call(
    (api) async => (await api.nextUp(_user, limit: homeRowLimit)).items,
  );

  @override
  Future<BaseItemDto?> nextUpOf(String seriesId) => _call(
    (api) async => (await api.nextUp(
      _user,
      limit: 1,
      seriesId: seriesId,
    )).items.firstOrNull,
  );

  @override
  Future<List<BaseItemDto>> seasons(String seriesId) =>
      _call((api) async => (await api.seasons(_user, seriesId)).items);

  @override
  Future<List<BaseItemDto>> episodes(String seriesId, String seasonId) => _call(
    (api) async =>
        (await api.episodes(_user, seriesId, seasonId: seasonId)).items,
  );

  @override
  Future<List<BaseItemDto>> seriesEpisodes(String seriesId) =>
      _call((api) async => (await api.episodes(_user, seriesId)).items);

  @override
  Future<List<BaseItemDto>> search(String term) => _call(
    (api) async => (await api.items(
      userId: _user,
      recursive: true,
      searchTerm: term,
      includeItemTypes: searchKinds,
      limit: 100,
    )).items,
  );

  @override
  Future<List<BaseItemDto>> tracks(String albumId) => _call(
    (api) async => (await api.items(
      userId: _user,
      parentId: albumId,
      sortBy: const [ItemSort.parentIndex, ItemSort.index, ItemSort.name],
    )).items,
  );

  @override
  Uri? imageUrl(BaseItemDto item, {required int maxWidth}) {
    // An episode without its own image borrows the series poster; a
    // track, its album's cover.
    final (String, String)? source = switch (item) {
      BaseItemDto(primaryImageTag: final String tag) => (item.id, tag),
      BaseItemDto(
        seriesId: final String series,
        seriesPrimaryImageTag: final String tag,
      ) =>
        (series, tag),
      BaseItemDto(
        albumId: final String album,
        albumPrimaryImageTag: final String tag,
      ) =>
        (album, tag),
      _ => null,
    };
    if (source == null) return null;
    final (id, tag) = source;
    return itemImageUrl(
      session.server.url,
      id,
      ImageType.primary,
      tag: tag,
      maxWidth: maxWidth,
    );
  }

  @override
  Uri? backdropUrl(BaseItemDto item, {required int maxWidth}) =>
      switch (item.backdropImageTags) {
        [final tag, ...] => itemImageUrl(
          session.server.url,
          item.id,
          ImageType.backdrop,
          tag: tag,
          maxWidth: maxWidth,
        ),
        _ => imageUrl(item, maxWidth: maxWidth),
      };
}

/// What the app browses with while nobody is signed in: every call fails
/// with [Unauthorized], and nothing has an image.
class SignedOutLibraryRepository implements LibraryRepository {
  const SignedOutLibraryRepository();

  Future<T> _fail<T>() => Future.error(const Unauthorized());

  @override
  Future<List<BaseItemDto>> views() => _fail();

  @override
  Future<BaseItemDtoQueryResult> children(
    BaseItemDto parent, {
    required int startIndex,
    required int limit,
  }) => _fail();

  @override
  Future<BaseItemDto> item(String id) => _fail();

  @override
  Future<List<BaseItemDto>> latest(String viewId) => _fail();

  @override
  Future<List<BaseItemDto>> featured() => _fail();

  @override
  Future<List<BaseItemDto>> resume() => _fail();

  @override
  Future<List<BaseItemDto>> resumeBooks() => _fail();

  @override
  Future<List<BaseItemDto>> nextUp() => _fail();

  @override
  Future<BaseItemDto?> nextUpOf(String seriesId) => _fail();

  @override
  Future<List<BaseItemDto>> seasons(String seriesId) => _fail();

  @override
  Future<List<BaseItemDto>> episodes(String seriesId, String seasonId) =>
      _fail();

  @override
  Future<List<BaseItemDto>> seriesEpisodes(String seriesId) => _fail();

  @override
  Future<List<BaseItemDto>> search(String term) => _fail();

  @override
  Future<List<BaseItemDto>> tracks(String albumId) => _fail();

  @override
  Uri? imageUrl(BaseItemDto item, {required int maxWidth}) => null;

  @override
  Uri? backdropUrl(BaseItemDto item, {required int maxWidth}) => null;
}
