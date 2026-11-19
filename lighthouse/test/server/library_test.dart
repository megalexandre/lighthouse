// The real library repository against the test server and its fixture
// library (fixtures/media). Each test has its own user, so watch state set
// here never leaks into another test (see TestServer.createUser).
@Tags(['server'])
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';
import 'package:lighthouse/api/client_info.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/core/ticks.dart';
import 'package:lighthouse/features/auth/data/auth_repository.dart';
import 'package:lighthouse/features/library/data/library_repository.dart';
import 'package:lighthouse/features/server/data/server_repository.dart';

void main() {
  late TestServer server;
  late TestUser user;
  late JellyfinLibraryRepository library;
  var expired = 0;
  const client = ClientInfo(deviceId: 'flutter-library-tests', device: 'tests');

  setUpAll(() async => server = await TestServer.start());
  setUp(() async {
    user = await server.createUser();
    final info = await JellyfinServerRepository(() async => client)
        .probe(server.url);
    final session = await JellyfinAuthRepository(() async => client)
        .login(info, user.name, user.password);
    expired = 0;
    library = JellyfinLibraryRepository(
      session,
      () async => client,
      onUnauthorized: () => expired++,
    );
  });

  Future<BaseItemDto> view(String collectionType) async =>
      (await library.views()).firstWhere(
        (v) => v.collectionType == collectionType,
      );

  Future<List<BaseItemDto>> all(BaseItemDto parent) async =>
      (await library.children(parent, startIndex: 0, limit: 100)).items;

  Future<BaseItemDto> named(String collectionType, String name) async =>
      (await all(await view(collectionType))).firstWhere((i) => i.name == name);

  test('the fixture libraries', () async {
    final views = await library.views();
    expect(
      {for (final v in views) v.name: v.collectionType},
      {
        'Movies': 'movies',
        'Shows': 'tvshows',
        'Music': 'music',
        'Books': 'books',
      },
    );
    expect(views.map((v) => v.type.isFolder), everyElement(isTrue));
  });

  test('a movie library lists its movies, by name', () async {
    final movies = await all(await view('movies'));
    expect(movies.map((m) => m.name), [Fixtures.hevcMovie, Fixtures.testMovie]);
    expect(movies.map((m) => m.type), everyElement(BaseItemKind.movie));
  });

  test('pages', () async {
    final movies = await view('movies');
    final first = await library.children(movies, startIndex: 0, limit: 1);
    final second = await library.children(movies, startIndex: 1, limit: 1);
    expect(first.totalRecordCount, Fixtures.movieCount);
    expect(second.startIndex, 1);
    expect(first.items.single.id, isNot(second.items.single.id));
  });

  test('a movie in full', () async {
    final listed = await named('movies', Fixtures.testMovie);
    final movie = await library.item(listed.id);
    expect(movie.productionYear, 2020);
    expect(
      ticksToDuration(movie.runTimeTicks!).inSeconds,
      inInclusiveRange(9, 11),
    );
    expect(movie.userData!.played, isFalse);
  });

  test('posters: served without a token; none for HEVC Movie', () async {
    final movie = await named('movies', Fixtures.testMovie);
    final url = library.imageUrl(movie, maxWidth: 100);
    expect(url, isNotNull, reason: 'no Primary image tag on ${movie.name}');
    final res = await Dio().getUri<List<int>>(
      url!,
      options: Options(responseType: ResponseType.bytes),
    );
    expect(res.statusCode, 200);
    expect(res.headers.value('content-type'), startsWith('image/'));

    final hevc = await named('movies', Fixtures.hevcMovie);
    expect(library.imageUrl(hevc, maxWidth: 100), isNull);
  });

  test('series → season → episodes, in order', () async {
    final show = await named('tvshows', Fixtures.testShow);
    expect(show.type, BaseItemKind.series);
    final season = (await library.seasons(show.id)).single;
    expect(season.type, BaseItemKind.season);
    expect(season.indexNumber, 1);

    final episodes = await library.episodes(show.id, season.id);
    expect(episodes, hasLength(Fixtures.episodeCount));
    expect(episodes.map((e) => e.indexNumber), [1, 2, 3]);
    expect(episodes.map((e) => e.seriesId), everyElement(show.id));
    // Episodes have no image of their own; they borrow the show's poster.
    expect(
      library.imageUrl(episodes.first, maxWidth: 100)?.path,
      '/Items/${show.id}/Images/Primary',
    );
  });

  test('every episode of a series, in order', () async {
    final show = await named('tvshows', Fixtures.testShow);
    final episodes = await library.seriesEpisodes(show.id);
    expect(episodes.map((e) => (e.parentIndexNumber, e.indexNumber)), [
      (1, 1),
      (1, 2),
      (1, 3),
    ]);
  });

  test("tracks know their album, and show the album's cover", () async {
    final album = await named('music', Fixtures.testAlbum);
    final track = (await library.tracks(album.id)).first;
    expect(track.albumId, album.id);
    expect(track.album, Fixtures.testAlbum);
    final cover = library.imageUrl(track, maxWidth: 100);
    expect(cover?.path, '/Items/${album.id}/Images/Primary');
    final res = await Dio().getUri<List<int>>(
      cover!,
      options: Options(responseType: ResponseType.bytes),
    );
    expect(res.headers.value('content-type'), startsWith('image/'));
  });

  test('an album and its tracks', () async {
    final album = await named('music', Fixtures.testAlbum);
    expect(album.type, BaseItemKind.musicAlbum);
    expect(album.albumArtist, Fixtures.testArtist);
    final tracks = await library.tracks(album.id);
    expect(tracks.map((t) => t.name), ['Track 1', 'Track 2']);
    expect(tracks.map((t) => t.indexNumber), [1, 2]);
  });

  test('latest in a library', () async {
    final latest = await library.latest((await view('movies')).id);
    expect(latest.map((m) => m.name).toSet(), {
      Fixtures.testMovie,
      Fixtures.hevcMovie,
    });
  });

  test('continue watching: empty, then the movie left half way', () async {
    expect(await library.resume(), isEmpty);

    final movie = await named('movies', Fixtures.testMovie);
    await server.setPlaybackPosition(
      user,
      movie.id,
      const Duration(seconds: 4),
    );

    final resume = await library.resume();
    expect(resume.map((i) => i.id), [movie.id]);
    expect(resume.single.userData!.playedPercentage, closeTo(40, 5));
  });

  test('next up: the episode after the last watched', () async {
    expect(await library.nextUp(), isEmpty);

    final show = await named('tvshows', Fixtures.testShow);
    final season = (await library.seasons(show.id)).single;
    final [e1, e2, _] = await library.episodes(show.id, season.id);
    await server.markPlayed(user, e1.id);

    final next = await library.nextUp();
    expect(next.map((e) => e.id), [e2.id]);
  });

  test('a revoked token ends the session', () async {
    await JellyfinAuthRepository(() async => client).logout(library.session);
    await expectLater(library.views(), throwsA(isA<Unauthorized>()));
    expect(expired, 1);
  });
}
