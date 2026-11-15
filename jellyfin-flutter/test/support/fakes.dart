import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/base_item_dto.dart';
import 'package:jellyfin_flutter/api/models/base_item_dto_query_result.dart';
import 'package:jellyfin_flutter/api/models/culture_dto.dart';
import 'package:jellyfin_flutter/api/models/media_source_info.dart';
import 'package:jellyfin_flutter/api/models/media_stream.dart';
import 'package:jellyfin_flutter/api/models/playback_report.dart';
import 'package:jellyfin_flutter/api/models/user_configuration.dart';
import 'package:jellyfin_flutter/api/models/user_item_data_dto.dart';
import 'package:jellyfin_flutter/app.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/core/storage.dart';
import 'package:jellyfin_flutter/core/window.dart';
import 'package:jellyfin_flutter/features/auth/data/auth_repository.dart';
import 'package:jellyfin_flutter/features/auth/data/session.dart';
import 'package:jellyfin_flutter/features/auth/data/session_store.dart';
import 'package:jellyfin_flutter/features/library/data/library_repository.dart';
import 'package:jellyfin_flutter/features/player/data/playback_plan.dart';
import 'package:jellyfin_flutter/features/player/data/playback_repository.dart';
import 'package:jellyfin_flutter/features/player/data/player_engine.dart';
import 'package:jellyfin_flutter/features/server/data/server_info.dart';
import 'package:jellyfin_flutter/features/server/data/server_repository.dart';
import 'package:jellyfin_flutter/features/server/presentation/connect_screen.dart';
import 'package:jellyfin_flutter/features/settings/data/settings_repository.dart';
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
        albumId: 'album-1',
        album: 'Test Album',
        albumArtist: 'Test Artist',
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
  Future<List<BaseItemDto>> search(String term) => _answer('search', () {
    searches.add(term);
    final t = term.toLowerCase();
    return [
      for (final i in _all)
        if (!i.type.isFolder &&
            i.type != BaseItemKind.season &&
            i.name.toLowerCase().contains(t))
          i,
    ];
  });

  /// Every term search() was called with.
  final searches = <String>[];

  @override
  Future<List<BaseItemDto>> seriesEpisodes(String seriesId) =>
      _answer('seriesEpisodes', () => TestItems.episodes);

  @override
  Future<List<BaseItemDto>> tracks(String albumId) =>
      _answer('tracks', () => TestItems.tracks);

  /// No images: widget tests make no HTTP requests.
  @override
  Uri? imageUrl(BaseItemDto item, {required int maxWidth}) => null;
}

/// Plans every item for direct play from a fake URL, and records the
/// reports. A method listed in [failures] throws that failure instead.
class FakePlaybackRepository implements PlaybackRepository {
  final failures = <String, Failure>{};
  final started = <PlaybackProgressInfo>[];
  final progress = <PlaybackProgressInfo>[];
  final stopped = <PlaybackStopInfo>[];

  /// itemId → played, from [setPlayed].
  final played = <String, bool>{};

  static Uri urlFor(String itemId, {int attempt = 0}) =>
      Uri.parse('$testUrl/Videos/$itemId/stream?static=true&attempt=$attempt');

  /// The tracks of every plan, numbered like the Test Movie on a real
  /// server: an external Portuguese .srt first, then the file's video,
  /// two audio tracks and an English subtitle.
  static const streams = [
    MediaStream(
      index: 0,
      type: MediaStreamType.subtitle,
      language: 'por',
      displayTitle: 'Portuguese - SUBRIP - External',
      isExternal: true,
      deliveryMethod: SubtitleDeliveryMethod.external,
      deliveryUrl: '/Videos/x/x/Subtitles/0/0/Stream.subrip?ApiKey=k',
    ),
    MediaStream(index: 1, type: MediaStreamType.video),
    MediaStream(
      index: 2,
      type: MediaStreamType.audio,
      language: 'eng',
      displayTitle: 'English - AAC - Mono - Default',
      isDefault: true,
    ),
    MediaStream(
      index: 3,
      type: MediaStreamType.audio,
      language: 'por',
      displayTitle: 'Português - Portuguese - AAC - Mono',
    ),
    MediaStream(
      index: 4,
      type: MediaStreamType.subtitle,
      language: 'eng',
      displayTitle: 'English - SUBRIP',
      deliveryMethod: SubtitleDeliveryMethod.embed,
    ),
  ];

  /// How plans play; set to transcode to test track changes that need a
  /// new stream.
  PlayMethod method = PlayMethod.directPlay;

  /// Subtitle the server suggests (null: none).
  int? defaultSubtitle;

  /// (start, audio, subtitle) of every prepare() call.
  final prepareCalls = <(Duration, int?, int?)>[];

  @override
  Future<PlaybackPlan> prepare(
    BaseItemDto item, {
    Duration start = Duration.zero,
    int? audioStreamIndex,
    int? subtitleStreamIndex,
  }) async {
    if (failures['prepare'] case final Failure f) throw f;
    prepareCalls.add((start, audioStreamIndex, subtitleStreamIndex));
    final subtitle = subtitleStreamIndex ?? defaultSubtitle;
    return PlaybackPlan(
      item: item,
      source: MediaSourceInfo(
        id: item.id,
        supportsDirectPlay: method != PlayMethod.transcode,
        mediaStreams: streams,
        defaultAudioStreamIndex: 2,
      ),
      playSessionId: 'play-session',
      method: method,
      url: urlFor(item.id, attempt: prepareCalls.length - 1),
      headers: const {'Authorization': 'MediaBrowser Token="token-1"'},
      start: start,
      audioStreamIndex: audioStreamIndex ?? 2,
      subtitleStreamIndex: subtitle == null || subtitle < 0 ? null : subtitle,
    );
  }

  @override
  Future<void> reportStart(PlaybackProgressInfo info) async =>
      started.add(info);

  @override
  Future<void> reportProgress(PlaybackProgressInfo info) async =>
      progress.add(info);

  @override
  Future<void> reportStopped(PlaybackStopInfo info) async => stopped.add(info);

  @override
  Future<UserItemDataDto> setPlayed(
    String itemId, {
    required bool played,
  }) async {
    if (failures['setPlayed'] case final Failure f) throw f;
    this.played[itemId] = played;
    return UserItemDataDto(played: played);
  }
}

/// A player that plays nothing: tests move it with [advance], [finish]...
class FakePlayerEngine implements PlayerEngine {
  Uri? openedUrl;
  Map<String, String>? openedHeaders;
  Duration? openedStart;
  bool disposed = false;

  /// Thrown by [open], when set.
  Object? openError;

  @override
  Duration position = Duration.zero;
  @override
  Duration duration = Duration.zero;
  @override
  bool playing = false;

  final _position = StreamController<Duration>.broadcast();
  final _duration = StreamController<Duration>.broadcast();
  final _playing = StreamController<bool>.broadcast();
  final _buffering = StreamController<bool>.broadcast();
  final _completed = StreamController<void>.broadcast();
  final _error = StreamController<String>.broadcast();

  @override
  Future<void> open(
    Uri url, {
    Map<String, String> headers = const {},
    Duration start = Duration.zero,
  }) async {
    if (openError case final Object e) throw e;
    openedUrl = url;
    opened.add(url);
    openedHeaders = headers;
    openedStart = start;
    position = start;
    duration = const Duration(minutes: 10);
    _duration.add(duration);
    _position.add(position);
    _setPlaying(true);
  }

  void _setPlaying(bool value) {
    playing = value;
    _playing.add(value);
  }

  /// Moves the position forward, as playing does.
  void advance(Duration by) {
    position += by;
    _position.add(position);
  }

  /// Plays to the end.
  void finish() {
    position = duration;
    _position.add(position);
    _setPlaying(false);
    _completed.add(null);
  }

  @override
  Future<void> play() async => _setPlaying(true);

  @override
  Future<void> pause() async => _setPlaying(false);

  @override
  Future<void> playOrPause() async => _setPlaying(!playing);

  @override
  Future<void> seek(Duration to) async {
    position = to;
    _position.add(to);
  }

  @override
  Stream<Duration> get positionStream => _position.stream;
  @override
  Stream<Duration> get durationStream => _duration.stream;
  @override
  Stream<bool> get playingStream => _playing.stream;
  @override
  Stream<bool> get bufferingStream => _buffering.stream;
  @override
  Stream<void> get completedStream => _completed.stream;
  @override
  Stream<String> get errorStream => _error.stream;

  /// Every track change, in order: `audio 2`, `subtitle no`, `add PATH`.
  final trackLog = <String>[];

  @override
  EngineTrack audioTrack = (id: 'auto', language: null, title: null);
  @override
  EngineTrack subtitleTrack = (id: 'auto', language: null, title: null);

  @override
  Future<void> selectAudioTrack(String mpvId) async {
    trackLog.add('audio $mpvId');
    audioTrack = (id: mpvId, language: null, title: null);
  }

  @override
  Future<void> selectSubtitleTrack(String mpvId) async {
    trackLog.add('subtitle $mpvId');
    subtitleTrack = (id: mpvId, language: null, title: null);
  }

  @override
  Future<void> addSubtitle(Uri url, {String? title, String? language}) async {
    trackLog.add('add ${url.path}');
    subtitleTrack = (id: '$url', language: language, title: title);
  }

  @override
  double volume = 100;
  @override
  bool muted = false;
  final _volume = StreamController<double>.broadcast();
  final _muted = StreamController<bool>.broadcast();

  @override
  Stream<double> get volumeStream => _volume.stream;
  @override
  Stream<bool> get mutedStream => _muted.stream;

  @override
  Future<void> setVolume(double v) async {
    volume = v.clamp(0, 100).toDouble();
    _volume.add(volume);
  }

  @override
  Future<void> setMuted(bool m) async {
    muted = m;
    _muted.add(m);
  }

  /// URLs opened, in order (a transcode track change reopens).
  final opened = <Uri>[];

  @override
  Widget buildVideo() => const ColoredBox(color: Color(0xFF000000));

  @override
  Future<void> dispose() async {
    disposed = true;
    await _position.close();
    await _duration.close();
    await _playing.close();
    await _buffering.close();
    await _completed.close();
    await _error.close();
    await _volume.close();
    await _muted.close();
  }
}

/// Settings kept in memory; [failures] as in the other fakes.
class FakeSettingsRepository implements SettingsRepository {
  UserConfiguration config = const UserConfiguration();
  int? bitrate;
  final failures = <String, Failure>{};

  @override
  Future<UserConfiguration> userConfiguration() async {
    if (failures['userConfiguration'] case final Failure f) throw f;
    return config;
  }

  @override
  Future<UserConfiguration> updateUserConfiguration({
    String? audioLanguage,
    String? subtitleLanguage,
    SubtitlePlaybackMode? subtitleMode,
    bool? nextEpisodeAutoPlay,
  }) async {
    if (failures['update'] case final Failure f) throw f;
    return config = config.copyWith(
      audioLanguagePreference: audioLanguage ?? config.audioLanguagePreference,
      subtitleLanguagePreference:
          subtitleLanguage ?? config.subtitleLanguagePreference,
      subtitleMode: subtitleMode ?? config.subtitleMode,
      enableNextEpisodeAutoPlay:
          nextEpisodeAutoPlay ?? config.enableNextEpisodeAutoPlay,
    );
  }

  /// As long as the server's (hundreds), so pickers must filter.
  @override
  Future<List<CultureDto>> languages() async => [
    const CultureDto(displayName: 'English', threeLetterIsoLanguageName: 'eng'),
    const CultureDto(
      displayName: 'Portuguese',
      threeLetterIsoLanguageName: 'por',
    ),
    for (var i = 0; i < 300; i++)
      CultureDto(
        displayName: 'Language $i',
        threeLetterIsoLanguageName: 'x${i.toString().padLeft(2, '0')}',
      ),
  ];

  @override
  Future<int?> maxStreamingBitrate() async => bitrate;

  @override
  Future<void> setMaxStreamingBitrate(int? bitsPerSecond) async =>
      bitrate = bitsPerSecond;
}

/// A window that only remembers whether it is full screen.
class FakeAppWindow implements AppWindow {
  @override
  bool isFullScreen = false;
}

/// The app with fake server/auth repositories and an in-memory keyring.
class TestApp {
  TestApp({MemoryKeyValueStore? store})
    : store = store ?? MemoryKeyValueStore();

  final MemoryKeyValueStore store;
  final servers = FakeServerRepository();
  final auth = FakeAuthRepository();
  final library = FakeLibraryRepository();
  final playback = FakePlaybackRepository();
  final window = FakeAppWindow();
  final settings = FakeSettingsRepository();

  /// Every engine the app made, last one = current playback.
  final engines = <FakePlayerEngine>[];
  FakePlayerEngine get engine => engines.last;

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
    playbackRepositoryProvider.overrideWithValue(playback),
    appWindowProvider.overrideWithValue(window),
    settingsRepositoryProvider.overrideWithValue(settings),
    playerEngineFactoryProvider.overrideWithValue(() {
      final engine = FakePlayerEngine();
      engines.add(engine);
      return engine;
    }),
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
