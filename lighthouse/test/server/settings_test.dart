// Settings and search against the test server: language preferences
// change what PlaybackInfo picks, a low quality limit makes the server
// transcode, and search finds the fixtures.
@Tags(['server'])
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';
import 'package:lighthouse/api/client_info.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';
import 'package:lighthouse/api/models/playback_report.dart';
import 'package:lighthouse/api/models/user_configuration.dart';
import 'package:lighthouse/core/storage.dart';
import 'package:lighthouse/features/auth/data/auth_repository.dart';
import 'package:lighthouse/features/library/data/library_repository.dart';
import 'package:lighthouse/features/player/data/playback_repository.dart';
import 'package:lighthouse/features/server/data/server_repository.dart';
import 'package:lighthouse/features/settings/data/settings_repository.dart';

void main() {
  late TestServer server;
  late TestUser user;
  late JellyfinLibraryRepository library;
  late JellyfinSettingsRepository settings;
  late JellyfinPlaybackRepository playback;
  int? bitrate;
  const client = ClientInfo(deviceId: 'flutter-settings-tests', device: 't');

  setUpAll(() async => server = await TestServer.start());
  setUp(() async {
    user = await server.createUser();
    final info = await JellyfinServerRepository(() async => client)
        .probe(server.url);
    final session = await JellyfinAuthRepository(() async => client)
        .login(info, user.name, user.password);
    library = JellyfinLibraryRepository(
      session,
      () async => client,
      onUnauthorized: () {},
    );
    settings = JellyfinSettingsRepository(
      session,
      () async => client,
      MemoryKeyValueStore(),
      onUnauthorized: () {},
    );
    bitrate = null;
    playback = JellyfinPlaybackRepository(
      session,
      () async => client,
      onUnauthorized: () {},
      maxStreamingBitrate: () async => bitrate,
    );
  });

  Future<BaseItemDto> testMovie() async =>
      (await library.search(Fixtures.testMovie))
          .firstWhere((i) => i.name == Fixtures.testMovie);

  test(
    'Portuguese audio preferred: the server picks the Portuguese track',
    () async {
      final movie = await testMovie();
      expect((await playback.prepare(movie)).audioStreamIndex, 2); // eng

      await settings.updateUserConfiguration(audioLanguage: 'por');
      expect(
        (await settings.userConfiguration()).audioLanguagePreference,
        'por',
      );
      final plan = await playback.prepare(movie);
      final audio = plan.audioStreams.firstWhere(
        (s) => s.index == plan.audioStreamIndex,
      );
      expect(audio.language, 'por');
    },
  );

  test(
    'English subtitles always: the server picks the English subtitle',
    () async {
      await settings.updateUserConfiguration(
        subtitleLanguage: 'eng',
        subtitleMode: SubtitlePlaybackMode.always,
      );
      final plan = await playback.prepare(await testMovie());
      final subtitle = plan.subtitleStreams.firstWhere(
        (s) => s.index == plan.subtitleStreamIndex,
      );
      expect(subtitle.language, 'eng');

      await settings.updateUserConfiguration(
        subtitleMode: SubtitlePlaybackMode.none,
      );
      expect(
        (await playback.prepare(await testMovie())).subtitleStreamIndex,
        isNull,
      );
    },
  );

  test('an update keeps the settings the app does not know', () async {
    final before = await server.adminGet<Map<String, dynamic>>(
      '/Users/${user.id}',
    );
    await settings.updateUserConfiguration(nextEpisodeAutoPlay: false);
    final after = await server.adminGet<Map<String, dynamic>>(
      '/Users/${user.id}',
    );
    final b = before['Configuration'] as Map<String, dynamic>;
    final a = after['Configuration'] as Map<String, dynamic>;
    expect(a['EnableNextEpisodeAutoPlay'], isFalse);
    expect(
      {...a}..remove('EnableNextEpisodeAutoPlay'),
      {...b}..remove('EnableNextEpisodeAutoPlay'),
    );
  });

  test(
    'a low quality limit: the server transcodes, and the stream is there',
    () async {
      bitrate = 100000; // below the fixture's bitrate
      final plan = await playback.prepare(await testMovie());
      expect(plan.method, PlayMethod.transcode);
      expect(plan.url.path, endsWith('.m3u8'));

      final res = await Dio(BaseOptions(validateStatus: (_) => true))
          .getUri<String>(
            plan.url,
            options: Options(
              headers: plan.headers,
              responseType: ResponseType.plain,
            ),
          );
      expect(res.statusCode, 200);
      expect(res.data, startsWith('#EXTM3U'));
    },
  );

  test('the server lists languages, Portuguese among them', () async {
    final languages = await settings.languages();
    expect(
      languages.map((l) => l.threeLetterIsoLanguageName),
      containsAll(['eng', 'por']),
    );
  });

  test('search finds each kind', () async {
    final test = await library.search('Test');
    expect({
      for (final i in test) i.name: i.type,
    }, containsPair(Fixtures.testMovie, BaseItemKind.movie));
    expect(
      test.map((i) => i.name),
      containsAll([Fixtures.testShow, Fixtures.testAlbum]),
    );
    final tracks = await library.search('Track');
    expect(tracks.map((i) => i.type).toSet(), {BaseItemKind.audio});
    expect(await library.search('nothing like this'), isEmpty);
  });
}
