import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/client_info.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/library/data/library_repository.dart';

import '../../support/fake_http.dart';
import '../../support/fakes.dart';

void main() {
  const client = ClientInfo(deviceId: 'dev-1', device: 'pc');

  JellyfinLibraryRepository repo(
    FakeAdapter adapter, {
    void Function()? onUnauthorized,
  }) => JellyfinLibraryRepository(
    testSession,
    () async => client,
    onUnauthorized: onUnauthorized ?? () {},
    adapter: adapter,
  );

  group('what a library grid lists', () {
    BaseItemDto library(String? type) => BaseItemDto(
      id: 'v',
      name: 'v',
      type: BaseItemKind.collectionFolder,
      collectionType: type,
    );

    const cases = [
      ('movies', true, [BaseItemKind.movie]),
      ('tvshows', true, [BaseItemKind.series]),
      ('music', true, [BaseItemKind.musicAlbum]),
      ('boxsets', true, [BaseItemKind.boxSet]),
      ('homevideos', false, <BaseItemKind>[]),
      (null, false, <BaseItemKind>[]),
    ];
    for (final (type, recursive, types) in cases) {
      test('$type', () {
        final query = childrenQuery(library(type));
        expect(query.recursive, recursive);
        expect(query.types, types);
      });
    }
  });

  test('children of a movie library: every movie, by name, one page', () async {
    final adapter = FakeAdapter(
      (_) async => json({'Items': <Object>[], 'TotalRecordCount': 0}),
    );
    await repo(adapter)
        .children(TestItems.moviesView, startIndex: 100, limit: 50);
    final query = adapter.requests.single.uri.queryParametersAll;
    expect(query['userId'], [testSession.userId]);
    expect(query['parentId'], [TestItems.moviesView.id]);
    expect(query['recursive'], ['true']);
    expect(query['includeItemTypes'], ['Movie']);
    expect(query['sortBy'], ['SortName']);
    expect(query['startIndex'], ['100']);
    expect(query['limit'], ['50']);
  });

  test('a 401 tells the app the session expired, and still fails', () async {
    var expired = 0;
    final r = repo(
      FakeAdapter((_) async => json({}, status: 401)),
      onUnauthorized: () => expired++,
    );
    await expectLater(r.views(), throwsA(isA<Unauthorized>()));
    expect(expired, 1);
  });

  test('other failures do not end the session', () async {
    var expired = 0;
    final r = repo(
      FakeAdapter((_) async => json({}, status: 500)),
      onUnauthorized: () => expired++,
    );
    await expectLater(r.views(), throwsA(isA<ServerError>()));
    expect(expired, 0);
  });

  group('image URL', () {
    final r = repo(FakeAdapter((_) async => json({})));

    test('the item own primary image', () {
      final url = r.imageUrl(
        TestItems.testMovie.copyWith(imageTags: {'Primary': 'tag1'}),
        maxWidth: 300,
      )!;
      expect(url.path, '/Items/movie-1/Images/Primary');
      expect(url.queryParameters, {
        'tag': 'tag1',
        'maxWidth': '300',
        'quality': '90',
      });
      expect(url.origin, testUrl);
    });

    test('an episode without one borrows the series poster', () {
      final url = r.imageUrl(
        TestItems.episodes.first.copyWith(seriesPrimaryImageTag: 'show'),
        maxWidth: 300,
      )!;
      expect(url.path, '/Items/series-1/Images/Primary');
      expect(url.queryParameters['tag'], 'show');
    });

    test('nothing to show', () {
      expect(r.imageUrl(TestItems.hevcMovie, maxWidth: 300), isNull);
    });
  });

  test(
    'signed out, browsing fails with Unauthorized instead of throwing',
    () async {
      const r = SignedOutLibraryRepository();
      await expectLater(r.views(), throwsA(isA<Unauthorized>()));
      expect(r.imageUrl(TestItems.testMovie, maxWidth: 1), isNull);
    },
  );
}
