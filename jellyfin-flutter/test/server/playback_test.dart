// The real playback repository against the test server: what it plans for
// the fixtures, that the stream URL serves the file, and that reports move
// the user's watch state.
@Tags(['server'])
library;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/client_info.dart';
import 'package:jellyfin_flutter/api/models/base_item_dto.dart';
import 'package:jellyfin_flutter/api/models/media_stream.dart';
import 'package:jellyfin_flutter/api/models/playback_report.dart';
import 'package:jellyfin_flutter/api/playback.dart';
import 'package:jellyfin_flutter/core/ticks.dart';
import 'package:jellyfin_flutter/features/auth/data/auth_repository.dart';
import 'package:jellyfin_flutter/features/library/data/library_repository.dart';
import 'package:jellyfin_flutter/features/player/application/playback_reporter.dart';
import 'package:jellyfin_flutter/features/player/data/playback_plan.dart';
import 'package:jellyfin_flutter/features/player/data/playback_repository.dart';
import 'package:jellyfin_flutter/features/server/data/server_repository.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';

void main() {
  late TestServer server;
  late TestUser user;
  late JellyfinLibraryRepository library;
  late JellyfinPlaybackRepository playback;
  const client = ClientInfo(
    deviceId: 'flutter-playback-tests',
    device: 'tests',
  );
  final dio = Dio(BaseOptions(validateStatus: (_) => true));

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
    playback = JellyfinPlaybackRepository(
      session,
      () async => client,
      onUnauthorized: () {},
    );
  });

  Future<BaseItemDto> movie(String name) async {
    final views = await library.views();
    final movies = views.firstWhere((v) => v.collectionType == 'movies');
    final items = await library.children(movies, startIndex: 0, limit: 10);
    return library.item(items.items.firstWhere((m) => m.name == name).id);
  }

  /// The first KB of [plan]'s stream. (12.4 serves static streams without
  /// a token too; the app sends its header anyway.)
  Future<Response<List<int>>> fetch(PlaybackPlan plan) => dio.getUri<List<int>>(
    plan.url,
    options: Options(
      responseType: ResponseType.bytes,
      headers: {...plan.headers, 'Range': 'bytes=0-1023'},
    ),
  );

  /// Plays [plan] "for" [position]: start, then stop there.
  Future<void> playUntil(PlaybackPlan plan, Duration position) async {
    final reporter = PlaybackReporter(
      playback,
      plan,
      position: () => position,
      paused: () => false,
    );
    await reporter.start();
    await reporter.progress();
    await reporter.stop();
  }

  test('Test Movie: direct play, both audio tracks, both subtitles', () async {
    final plan = await playback.prepare(await movie(Fixtures.testMovie));
    expect(plan.method, PlayMethod.directPlay);
    expect(plan.playSessionId, isNotEmpty);
    expect(plan.audioStreams.map((s) => s.language), ['eng', 'por']);
    expect(
      plan.subtitleStreams.map((s) => (s.language, s.deliveryMethod)),
      unorderedEquals([
        ('eng', SubtitleDeliveryMethod.embed),
        ('por', SubtitleDeliveryMethod.external),
      ]),
    );
  });

  test('the stream serves the file', () async {
    final plan = await playback.prepare(await movie(Fixtures.testMovie));
    final res = await fetch(plan);
    expect(res.statusCode, anyOf(200, 206));
    expect(res.data, hasLength(1024));
    // An MKV starts with the EBML magic number.
    expect(res.data!.take(4), [0x1A, 0x45, 0xDF, 0xA3]);
  });

  test('the external subtitle can be downloaded', () async {
    final plan = await playback.prepare(await movie(Fixtures.testMovie));
    final external = plan.subtitleStreams.firstWhere((s) => s.isExternal);
    final res = await dio.getUri<List<int>>(
      serverUrl(server.url, external.deliveryUrl!),
      options: Options(responseType: ResponseType.bytes),
    );
    expect(res.statusCode, 200);
    // Decoded right (the fixture has a BOM for that), ready for mpv.
    expect(utf8.decode(res.data!), contains('Português subtitle one'));
  });

  test('HEVC 10-bit is direct play too (mpv decodes it)', () async {
    final plan = await playback.prepare(await movie(Fixtures.hevcMovie));
    expect(plan.method, PlayMethod.directPlay);
  });

  test('stopping half way saves the resume point', () async {
    final item = await movie(Fixtures.testMovie);
    await playUntil(await playback.prepare(item), const Duration(seconds: 4));

    final after = await library.item(item.id);
    expect(ticksToDuration(after.userData!.playbackPositionTicks).inSeconds, 4);
    expect(after.userData!.played, isFalse);
    expect((await library.resume()).map((i) => i.id), [item.id]);
  });

  test('stopping near the end marks it watched', () async {
    final item = await movie(Fixtures.testMovie);
    await playUntil(
      await playback.prepare(item),
      ticksToDuration(item.runTimeTicks!) - const Duration(milliseconds: 200),
    );
    final after = await library.item(item.id);
    expect(after.userData!.played, isTrue);
    expect(await library.resume(), isEmpty);
  });

  test('watched by hand, and back', () async {
    final item = await movie(Fixtures.hevcMovie);
    expect((await playback.setPlayed(item.id, played: true)).played, isTrue);
    expect((await library.item(item.id)).userData!.played, isTrue);
    expect((await playback.setPlayed(item.id, played: false)).played, isFalse);
    expect((await library.item(item.id)).userData!.played, isFalse);
  });

  test('starting later asks the server from there', () async {
    final plan = await playback.prepare(
      await movie(Fixtures.testMovie),
      start: const Duration(seconds: 3),
    );
    expect(plan.start, const Duration(seconds: 3));
  });
}
