// Books against the test server's fixture books (fixtures/media/books):
// download, the place kept on 12.4's scale (10000 ticks a page), "continue
// reading", read / unread, search.
@Tags(['server'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/client_info.dart';
import 'package:jellyfin_flutter/api/models/base_item_dto.dart';
import 'package:jellyfin_flutter/core/storage.dart';
import 'package:jellyfin_flutter/features/auth/data/auth_repository.dart';
import 'package:jellyfin_flutter/features/library/data/library_repository.dart';
import 'package:jellyfin_flutter/features/reader/data/book_format.dart';
import 'package:jellyfin_flutter/features/reader/data/book_repository.dart';
import 'package:jellyfin_flutter/features/reader/data/reading_position.dart';
import 'package:jellyfin_flutter/features/server/data/server_repository.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';

void main() {
  late TestServer server;
  late JellyfinLibraryRepository library;
  late JellyfinBookRepository books;
  late Directory cache;
  const client = ClientInfo(deviceId: 'flutter-books-tests', device: 'tests');

  setUpAll(() async => server = await TestServer.start());
  setUp(() async {
    final user = await server.createUser();
    final info = await JellyfinServerRepository(() async => client)
        .probe(server.url);
    final session = await JellyfinAuthRepository(() async => client)
        .login(info, user.name, user.password);
    library = JellyfinLibraryRepository(
      session,
      () async => client,
      onUnauthorized: () {},
    );
    cache = await Directory.systemTemp.createTemp('jf-books-');
    addTearDown(() => cache.delete(recursive: true));
    books = JellyfinBookRepository(
      session,
      () async => client,
      () async => cache,
      MemoryKeyValueStore(),
      onUnauthorized: () {},
    );
  });

  Future<Map<String, BaseItemDto>> all() async {
    final views = await library.views();
    final view = views.firstWhere((v) => v.collectionType == 'books');
    final page = await library.children(view, startIndex: 0, limit: 50);
    return {for (final b in page.items) b.name: b};
  }

  test('the Books library lists the three books', () async {
    final found = await all();
    expect(
      found.keys,
      unorderedEquals([
        Fixtures.testBook,
        Fixtures.testComic,
        Fixtures.testNovel,
      ]),
    );
    expect(found.values.map((b) => b.type), everyElement(BaseItemKind.book));
    // 12.4's scale: 10000 ticks a page.
    expect(
      found[Fixtures.testComic]!.runTimeTicks,
      Fixtures.bookPages * ticksPerPage,
    );
  });

  test('each file downloads, once, and is what it says', () async {
    final found = await all();
    final expected = {
      Fixtures.testBook: BookFormat.pdf,
      Fixtures.testComic: BookFormat.comic,
      Fixtures.testNovel: BookFormat.epub,
    };
    for (final MapEntry(key: name, value: format) in expected.entries) {
      final file = await books.file(found[name]!);
      expect(detectBookFormat(await file.readAsBytes()), format, reason: name);
      final modified = file.lastModifiedSync();
      // The second time it comes from the cache.
      expect((await books.file(found[name]!)).lastModifiedSync(), modified);
    }
    expect(cache.listSync().where((f) => f.path.endsWith('.part')), isEmpty);
  });

  test(
    'the place: saved on page 3, the server says 40 %, continue reading',
    () async {
      final comic = (await all())[Fixtures.testComic]!;
      expect(await library.resumeBooks(), isEmpty);

      await books.savePosition(
        comic.id,
        positionForPage(2, Fixtures.bookPages, comic.runTimeTicks),
      );
      final after = await library.item(comic.id);
      expect(after.userData!.playbackPositionTicks, 20000);
      expect(after.userData!.playedPercentage, closeTo(40, 0.01));
      expect(after.userData!.played, isFalse);
      expect(
        pageForPosition(
          after.userData!.playbackPositionTicks,
          Fixtures.bookPages,
          after.runTimeTicks,
        ),
        2,
      );
      expect((await library.resumeBooks()).map((b) => b.id), [comic.id]);
      // Books stay out of "Continue watching".
      expect(await library.resume(), isEmpty);
    },
  );

  test('read and unread', () async {
    final pdf = (await all())[Fixtures.testBook]!;
    await books.setRead(pdf.id, read: true);
    expect((await library.item(pdf.id)).userData!.played, isTrue);
    await books.setRead(pdf.id, read: false);
    expect((await library.item(pdf.id)).userData!.played, isFalse);
  });

  test('search finds books', () async {
    final found = await library.search('Test Comic');
    expect(found.map((b) => (b.name, b.type)), [
      (Fixtures.testComic, BaseItemKind.book),
    ]);
  });
}
