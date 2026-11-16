/// Sets up the throwaway Jellyfin server the tests run against, and gives
/// each test its own user so tests never see each other's watch state.
///
/// The server ("jellyfin-test" in the dev container) keeps its settings in
/// memory, so it starts unconfigured after every restart. [TestServer.start]
/// runs the setup wizard and creates the libraries the first time; on later
/// calls it only logs in. It talks to the HTTP API directly (no app code),
/// so a bug in the app's API client cannot hide a broken test setup.
library;

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

/// What the fixture library (fixtures/media) contains once scanned.
///
/// Names are exactly what the server reports. With internet metadata off,
/// Jellyfin 12.4 keeps the year in a movie's name ("Test Movie (2020)") and
/// also sets ProductionYear.
abstract final class Fixtures {
  static const movieCount = 2;
  static const episodeCount = 3;
  static const audioCount = 2;
  static const bookCount = 3;

  static const testMovie = 'Test Movie (2020)';
  static const hevcMovie = 'HEVC Movie (2021)';
  static const testShow = 'Test Show';
  static const testAlbum = 'Test Album';
  static const testArtist = 'Test Artist';

  /// Books (fixtures/media/books, tool/gen_books.py): 5 pages each for the
  /// PDF and the comic, 3 chapters for the EPUB.
  static const testBook = 'Test Book';
  static const testComic = 'Test Comic';
  static const testNovel = 'Test Novel';
  static const bookPages = 5;

  /// Items with a local poster (fixtures/media/**/poster.jpg, folder.jpg).
  /// HEVC Movie has none.
  static const withPoster = [testMovie, testShow, testAlbum];
}

/// Credentials of a user created for one test.
class TestUser {
  TestUser({required this.id, required this.name, required this.password});

  final String id;
  final String name;
  final String password;
}

class TestServerException implements Exception {
  TestServerException(this.message);
  final String message;
  @override
  String toString() => 'TestServerException: $message';
}

class TestServer {
  TestServer._(this.url, this._dio, this._adminToken);

  /// Name and password of the admin created by the setup wizard.
  static const adminName = 'admin';
  static const adminPassword = 'admin-password';

  static const _client = 'jellyfin-flutter-tests';

  /// One device per test process. Jellyfin revokes a user's token when the
  /// same user signs in again from the same device, and `flutter test` runs
  /// test files in parallel processes that all sign in as admin: with a
  /// shared id they would keep logging each other out (401s).
  static final _deviceId = 'jellyfin-flutter-tests-$pid';

  /// Base URL, e.g. http://jellyfin-test:8096
  final String url;
  final Dio _dio;
  final String _adminToken;
  static Future<TestServer>? _started;

  /// URL of the test server, from `JELLYFIN_TEST_URL`.
  static String get defaultUrl {
    final url = Platform.environment['JELLYFIN_TEST_URL'];
    if (url == null || url.isEmpty) {
      throw TestServerException(
        'JELLYFIN_TEST_URL is not set. Inside the dev container it is '
        'http://jellyfin-test:8096 (rebuild the container if it is missing).',
      );
    }
    return url;
  }

  /// Makes sure the server is set up and the fixture library is scanned,
  /// then returns a handle logged in as admin. Safe to call from every test
  /// file; within one process the work happens once.
  static Future<TestServer> start({String? url}) =>
      _started ??= _start(url ?? defaultUrl);

  static Future<TestServer> _start(String url) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: url,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Authorization': authHeader()},
      ),
    );

    final info = await _waitUntilUp(dio);
    if (info['StartupWizardCompleted'] != true) {
      try {
        await _runWizard(dio);
      } on DioException {
        // Another test process (files run in parallel) may have finished
        // the wizard first; then the /Startup endpoints refuse. Fine as
        // long as the wizard ended up completed.
        final now = await _waitUntilUp(dio);
        if (now['StartupWizardCompleted'] != true) rethrow;
      }
    }
    final token = (await _login(dio, adminName, adminPassword)).token;
    final server = TestServer._(url, dio, token);
    await server._allowResumeOfShortItems();
    await server._ensureLibraries();
    return server;
  }

  /// The `Authorization` header Jellyfin expects from a client.
  static String authHeader({String? token}) {
    final parts = [
      'Client="$_client"',
      'Device="tests"',
      'DeviceId="$_deviceId"',
      'Version="0.0.0"',
      if (token != null) 'Token="$token"',
    ];
    return 'MediaBrowser ${parts.join(', ')}';
  }

  Options get _asAdmin =>
      Options(headers: {'Authorization': authHeader(token: _adminToken)});

  static Future<Map<String, dynamic>> _waitUntilUp(Dio dio) async {
    final deadline = DateTime.now().add(const Duration(seconds: 90));
    Object? lastError;
    while (DateTime.now().isBefore(deadline)) {
      try {
        final res = await dio.get<Map<String, dynamic>>('/System/Info/Public');
        if (res.data != null) return res.data!;
      } on DioException catch (e) {
        lastError = e.message ?? e.type;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw TestServerException(
      'server at ${dio.options.baseUrl} did not '
      'answer within 90 s (last error: $lastError)',
    );
  }

  static Future<void> _runWizard(Dio dio) async {
    await dio.post<void>(
      '/Startup/Configuration',
      data: {
        'UICulture': 'en-US',
        'MetadataCountryCode': 'US',
        'PreferredMetadataLanguage': 'en',
      },
    );
    // The GET creates the first user; the POST renames it and sets a password.
    await dio.get<void>('/Startup/User');
    await dio.post<void>(
      '/Startup/User',
      data: {'Name': adminName, 'Password': adminPassword},
    );
    await dio.post<void>(
      '/Startup/RemoteAccess',
      data: {'EnableRemoteAccess': true},
    );
    await dio.post<void>('/Startup/Complete');
  }

  static Future<({String token, String userId})> _login(
    Dio dio,
    String name,
    String password,
  ) async {
    final res = await dio.post<Map<String, dynamic>>(
      '/Users/AuthenticateByName',
      data: {'Username': name, 'Pw': password},
    );
    final data = res.data!;
    return (
      token: data['AccessToken'] as String,
      userId: (data['User'] as Map<String, dynamic>)['Id'] as String,
    );
  }

  /// By default the server keeps no resume point for items shorter than 5
  /// minutes; the fixtures last seconds.
  Future<void> _allowResumeOfShortItems() async {
    final config = await adminGet<Map<String, dynamic>>(
      '/System/Configuration',
    );
    if (config['MinResumeDurationSeconds'] == 0) return;
    await _dio.post<void>(
      '/System/Configuration',
      data: {...config, 'MinResumeDurationSeconds': 0},
      options: _asAdmin,
    );
  }

  /// Libraries created on the server, by name → (collection type, path).
  static const libraries = {
    'Movies': ('movies', '/media/movies'),
    'Shows': ('tvshows', '/media/shows'),
    'Music': ('music', '/media/music'),
    'Books': ('books', '/media/books'),
  };

  Future<void> _ensureLibraries() async {
    final existing = await _libraryNames();
    for (final MapEntry(key: name, value: (type, path)) in libraries.entries) {
      if (existing.contains(name)) continue;
      try {
        await _dio.post<void>(
          '/Library/VirtualFolders',
          queryParameters: {
            'name': name,
            'collectionType': type,
            'paths': path,
            'refreshLibrary': false,
          },
          data: {'LibraryOptions': _offlineLibraryOptions},
          options: _asAdmin,
        );
      } on DioException {
        // Created meanwhile by another test process?
        if (!(await _libraryNames()).contains(name)) rethrow;
      }
    }
    if (existing.length < libraries.length) {
      await _dio.post<void>('/Library/Refresh', options: _asAdmin);
    }
    await _waitForScan();
  }

  Future<Set<String>> _libraryNames() async {
    final res = await _dio.get<List<dynamic>>(
      '/Library/VirtualFolders',
      options: _asAdmin,
    );
    return {
      for (final f in res.data!) (f as Map<String, dynamic>)['Name'] as String,
    };
  }

  /// No internet metadata or image extraction: scans stay fast and give the
  /// same result offline as online.
  static final _offlineLibraryOptions = {
    'EnableRealtimeMonitor': false,
    'EnableChapterImageExtraction': false,
    'ExtractChapterImagesDuringLibraryScan': false,
    'EnableTrickplayImageExtraction': false,
    'ExtractTrickplayImagesDuringLibraryScan': false,
    'SaveLocalMetadata': false,
    'EnableInternetProviders': false,
    'TypeOptions': [
      for (final type in [
        'Book',
        'Movie',
        'Series',
        'Season',
        'Episode',
        'MusicArtist',
        'MusicAlbum',
        'Audio',
      ])
        {
          'Type': type,
          'MetadataFetchers': <String>[],
          'ImageFetchers': <String>[],
        },
    ],
  };

  Future<void> _waitForScan() async {
    final deadline = DateTime.now().add(const Duration(seconds: 120));
    var counts = <String, int>{};
    while (DateTime.now().isBefore(deadline)) {
      counts = {
        'Movie': await _count('Movie'),
        'Episode': await _count('Episode'),
        'Audio': await _count('Audio'),
        'Book': await _count('Book'),
      };
      if (counts['Movie'] == Fixtures.movieCount &&
          counts['Episode'] == Fixtures.episodeCount &&
          counts['Audio'] == Fixtures.audioCount &&
          counts['Book'] == Fixtures.bookCount &&
          !await _scanRunning()) {
        return;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw TestServerException(
      'library scan did not finish in 120 s; '
      'found $counts. Is fixtures/media mounted at /media?',
    );
  }

  Future<int> _count(String type) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/Items',
      queryParameters: {
        'Recursive': true,
        'IncludeItemTypes': type,
        'Limit': 0,
      },
      options: _asAdmin,
    );
    return res.data!['TotalRecordCount'] as int;
  }

  Future<bool> _scanRunning() async {
    final res = await _dio.get<List<dynamic>>(
      '/ScheduledTasks',
      options: _asAdmin,
    );
    return res.data!.any((t) {
      final task = t as Map<String, dynamic>;
      return task['Key'] == 'RefreshLibrary' && task['State'] != 'Idle';
    });
  }

  var _userCounter = 0;

  /// Creates a user with access to every library, with no watch state.
  ///
  /// Test users are never deleted. Jellyfin 12.4 gives a new user the
  /// internal id of the last deleted one, and that user's watch state
  /// (positions, played) comes with it: deleting in tearDown made the next
  /// test's "fresh" user start half way through a movie. The server keeps
  /// its data in memory, so the users go away when its container restarts.
  ///
  /// A server that already went through deletions (older test runs) still
  /// hands out such ids: a user that comes with watch state is left aside
  /// and another one created.
  Future<TestUser> createUser({String password = 'test-password'}) async {
    for (var attempt = 0; attempt < 1000; attempt++) {
      final name =
          'user-${DateTime.now().microsecondsSinceEpoch}-'
          '${_userCounter++}';
      final res = await _dio.post<Map<String, dynamic>>(
        '/Users/New',
        data: {'Name': name, 'Password': password},
        options: _asAdmin,
      );
      final id = res.data!['Id'] as String;
      if (await _hasNoWatchState(id)) {
        return TestUser(id: id, name: name, password: password);
      }
    }
    throw TestServerException('every new user came with watch state');
  }

  Future<bool> _hasNoWatchState(String userId) async {
    for (final filter in ['IsPlayed', 'IsResumable']) {
      final res = await _dio.get<Map<String, dynamic>>(
        '/Items',
        queryParameters: {
          'userId': userId,
          'Recursive': true,
          'Filters': filter,
          'Limit': 0,
        },
        options: _asAdmin,
      );
      if (res.data!['TotalRecordCount'] != 0) return false;
    }
    return true;
  }

  /// Logs [user] in, returning the access token.
  Future<String> login(TestUser user) async =>
      (await _login(_dio, user.name, user.password)).token;

  Options _as(String token) =>
      Options(headers: {'Authorization': authHeader(token: token)});

  /// Marks [itemId] watched for [user] (e.g. to get Next Up going).
  Future<void> markPlayed(TestUser user, String itemId) async {
    final token = await login(user);
    await _dio.post<void>(
      '/UserPlayedItems/$itemId',
      queryParameters: {'userId': user.id},
      options: _as(token),
    );
  }

  /// Leaves [itemId] partly watched at [position] for [user], as if
  /// playback had stopped there (e.g. to fill Continue Watching).
  Future<void> setPlaybackPosition(
    TestUser user,
    String itemId,
    Duration position,
  ) async {
    final token = await login(user);
    await _dio.post<void>(
      '/UserItems/$itemId/UserData',
      queryParameters: {'userId': user.id},
      data: {'PlaybackPositionTicks': position.inMicroseconds * 10},
      options: _as(token),
    );
  }

  /// Raw admin GET, for tests that check server state directly.
  Future<T> adminGet<T>(String path, {Map<String, dynamic>? query}) async {
    final res = await _dio.get<T>(
      path,
      queryParameters: query,
      options: _asAdmin,
    );
    return res.data as T;
  }

  /// The item with exactly [name] and [type], as the server sees it for
  /// [user] (watch state included).
  Future<Map<String, dynamic>> findItem(
    TestUser user,
    String name, {
    required String type,
  }) async {
    final token = await login(user);
    final res = await _dio.get<Map<String, dynamic>>(
      '/Items',
      queryParameters: {
        'userId': user.id,
        'Recursive': true,
        'IncludeItemTypes': type,
        'SearchTerm': name,
      },
      options: _as(token),
    );
    final items = (res.data!['Items'] as List).cast<Map<String, dynamic>>();
    return items.firstWhere(
      (i) => i['Name'] == name,
      orElse: () => throw TestServerException('no $type named "$name"'),
    );
  }

  /// The OpenAPI document the server publishes, for the contract test.
  Future<Map<String, dynamic>> openApi() =>
      adminGet<Map<String, dynamic>>('/api-docs/openapi.json');
}
