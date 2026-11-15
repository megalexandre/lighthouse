import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/base_item_dto.dart';
import 'package:jellyfin_flutter/api/models/base_item_dto_query_result.dart';
import 'package:jellyfin_flutter/app.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/core/storage.dart';
import 'package:jellyfin_flutter/features/auth/data/auth_repository.dart';
import 'package:jellyfin_flutter/features/auth/data/session.dart';
import 'package:jellyfin_flutter/features/auth/data/session_store.dart';
import 'package:jellyfin_flutter/features/library/data/library_repository.dart';
import 'package:jellyfin_flutter/features/server/data/server_info.dart';
import 'package:jellyfin_flutter/features/server/data/server_repository.dart';
import 'package:jellyfin_flutter/features/server/presentation/connect_screen.dart';
import 'package:jellyfin_flutter/router.dart';
import 'package:material_ui/material_ui.dart';

const testUrl = 'http://jellyfin.test:8096';

const testServer = ServerInfo(
  url: testUrl,
  id: 'server-id',
  name: 'Test Server',
  version: '12.4.0',
);

const testSession = Session(
  server: testServer,
  userId: 'user-id',
  userName: 'alice',
  token: 'token-1',
);

/// Accepts [testServer] at any address unless [probeFailure] is set.
class FakeServerRepository implements ServerRepository {
  Failure? probeFailure;
  final probed = <String>[];

  @override
  Future<ServerInfo> probe(String input) async {
    probed.add(input);
    if (probeFailure != null) throw probeFailure!;
    return testServer;
  }
}

/// Knows one user, alice / secret.
class FakeAuthRepository implements AuthRepository {
  /// Thrown by [check]; null means the session is valid.
  Failure? checkFailure;

  /// Thrown by [logout].
  Failure? logoutFailure;

  final loggedOut = <Session>[];

  @override
  Future<Session> login(
    ServerInfo server,
    String username,
    String password,
  ) async {
    if (username != 'alice' || password != 'secret') {
      throw const Unauthorized();
    }
    return testSession.copyWith(server: server);
  }

  @override
  Future<void> check(Session session) async {
    if (checkFailure != null) throw checkFailure!;
  }

  @override
  Future<void> logout(Session session) async {
    loggedOut.add(session);
    if (logoutFailure != null) throw logoutFailure!;
  }
}

/// A small catalog, shaped like the fixture library on the test server.
abstract final class TestItems {
  static const moviesView = BaseItemDto(
    id: 'view-movies',
    name: 'Movies',
    type: BaseItemKind.collectionFolder,
    collectionType: 'movies',
  );
  static const showsView = BaseItemDto(
    id: 'view-shows',
    name: 'Shows',
    type: BaseItemKind.collectionFolder,
    collectionType: 'tvshows',
  );
  static const musicView = BaseItemDto(
    id: 'view-music',
    name: 'Music',
    type: BaseItemKind.collectionFolder,
    collectionType: 'music',
  );
  static const views = [moviesView, showsView, musicView];

  static const testMovie = BaseItemDto(
    id: 'movie-1',
    name: 'Test Movie',
    type: BaseItemKind.movie,
    productionYear: 2020,
    runTimeTicks: 92 * 60 * 10000000, // 1h 32m
    officialRating: 'PG',
    overview: 'A movie made for tests.',
  );
  static const hevcMovie = BaseItemDto(
    id: 'movie-2',
    name: 'HEVC Movie',
    type: BaseItemKind.movie,
    productionYear: 2021,
  );

  static const testShow = BaseItemDto(
    id: 'series-1',
    name: 'Test Show',
    type: BaseItemKind.series,
    overview: 'A show made for tests.',
  );
  static const season1 = BaseItemDto(
    id: 'season-1',
    name: 'Season 1',
    type: BaseItemKind.season,
    indexNumber: 1,
    seriesId: 'series-1',
    seriesName: 'Test Show',
  );
  static final episodes = [
    for (var n = 1; n <= 3; n++)
      BaseItemDto(
        id: 'episode-$n',
        name: 'Episode $n',
        type: BaseItemKind.episode,
        indexNumber: n,
        parentIndexNumber: 1,
        seriesId: 'series-1',
        seriesName: 'Test Show',
        seasonId: 'season-1',
        runTimeTicks: 45 * 60 * 10000000,
      ),
  ];

  static const testAlbum = BaseItemDto(
    id: 'album-1',
    name: 'Test Album',
    type: BaseItemKind.musicAlbum,
    albumArtist: 'Test Artist',
  );
  static final tracks = [
    for (var n = 1; n <= 2; n++)
      BaseItemDto(
        id: 'track-$n',
        name: 'Track $n',
        type: BaseItemKind.audio,
        indexNumber: n,
        runTimeTicks: 3 * 60 * 10000000,
      ),
  ];
}

/// Serves [TestItems]; [movies] can be replaced (e.g. by hundreds, to
/// page). A method listed in [failures] throws that failure instead.
class FakeLibraryRepository implements LibraryRepository {
  List<BaseItemDto> movies = [TestItems.testMovie, TestItems.hevcMovie];
  List<BaseItemDto> resumeItems = [];
  List<BaseItemDto> nextUpItems = [];

  /// Method name (views, children, item, latest, resume, nextUp, seasons,
  /// episodes, tracks) → what it throws.
  final failures = <String, Failure>{};

  /// (startIndex, limit) of every children() call.
  final childrenCalls = <(int, int)>[];

  Future<T> _answer<T>(String method, T Function() value) async {
    if (failures[method] case final Failure f) throw f;
    return value();
  }

  List<BaseItemDto> _childrenOf(String id) => switch (id) {
    'view-movies' => movies,
    'view-shows' => [TestItems.testShow],
    'view-music' => [TestItems.testAlbum],
    _ => const [],
  };

  List<BaseItemDto> get _all => [
    ...TestItems.views,
    ...movies,
    TestItems.testShow,
    TestItems.season1,
    ...TestItems.episodes,
    TestItems.testAlbum,
    ...TestItems.tracks,
  ];

  @override
  Future<List<BaseItemDto>> views() => _answer('views', () => TestItems.views);

  @override
  Future<BaseItemDtoQueryResult> children(
    BaseItemDto parent, {
    required int startIndex,
    required int limit,
  }) => _answer('children', () {
    childrenCalls.add((startIndex, limit));
    final all = _childrenOf(parent.id);
    return BaseItemDtoQueryResult(
      items: all.skip(startIndex).take(limit).toList(),
      totalRecordCount: all.length,
      startIndex: startIndex,
    );
  });

  @override
  Future<BaseItemDto> item(String id) => _answer(
    'item',
    () => _all.firstWhere(
      (i) => i.id == id,
      orElse: () => throw const ServerError('HTTP 404', statusCode: 404),
    ),
  );

  @override
  Future<List<BaseItemDto>> latest(String viewId) =>
      _answer('latest', () => _childrenOf(viewId).take(homeRowLimit).toList());

  @override
  Future<List<BaseItemDto>> resume() => _answer('resume', () => resumeItems);

  @override
  Future<List<BaseItemDto>> nextUp() => _answer('nextUp', () => nextUpItems);

  @override
  Future<List<BaseItemDto>> seasons(String seriesId) =>
      _answer('seasons', () => [TestItems.season1]);

  @override
  Future<List<BaseItemDto>> episodes(String seriesId, String seasonId) =>
      _answer('episodes', () => TestItems.episodes);

  @override
  Future<List<BaseItemDto>> tracks(String albumId) =>
      _answer('tracks', () => TestItems.tracks);

  /// No images: widget tests make no HTTP requests.
  @override
  Uri? imageUrl(BaseItemDto item, {required int maxWidth}) => null;
}

/// The app with fake server/auth repositories and an in-memory keyring.
class TestApp {
  TestApp({MemoryKeyValueStore? store})
    : store = store ?? MemoryKeyValueStore();

  final MemoryKeyValueStore store;
  final servers = FakeServerRepository();
  final auth = FakeAuthRepository();
  final library = FakeLibraryRepository();

  /// Starts as if [testSession] was stored by an earlier run.
  void signIn() =>
      store.values[SessionStore.sessionKey] = jsonEncode(testSession.toJson());

  /// Prefilled on the connect screen (empty, as in a normal build).
  String defaultServerAddress = '';

  List<Override> get overrides => [
    keyValueStoreProvider.overrideWithValue(store),
    serverRepositoryProvider.overrideWithValue(servers),
    authRepositoryProvider.overrideWithValue(auth),
    libraryRepositoryProvider.overrideWithValue(library),
    defaultServerAddressProvider.overrideWithValue(defaultServerAddress),
  ];

  ProviderContainer container() =>
      ProviderContainer.test(overrides: overrides, retry: noAutomaticRetry);

  /// Signed in, on a desktop-sized window, at [location].
  Future<void> open(WidgetTester tester, String location) async {
    useDesktopWindow(tester);
    signIn();
    await pump(tester);
    ProviderScope.containerOf(tester.element(find.byType(JellyfinApp)))
        .read(routerProvider)
        .go(location);
    await tester.pumpAndSettle();
  }

  /// Pumps a fresh app (new providers, same store): what a restart does.
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: overrides,
        retry: noAutomaticRetry,
        child: const JellyfinApp(),
      ),
    );
    await tester.pumpAndSettle();
  }
}

/// A 1600×1200 window instead of the 800×600 default, so whole screens
/// (every home row) are laid out without scrolling.
void useDesktopWindow(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1600, 1200)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
