import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/client_info.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/core/storage.dart';
import 'package:lighthouse/features/reader/data/book_repository.dart';

import '../../support/fake_http.dart';
import '../../support/fakes.dart';

void main() {
  const client = ClientInfo(deviceId: 'dev-1', device: 'pc');
  final book = TestItems.testComic;
  final content = Uint8List.fromList(List.generate(4096, (i) => i % 251));
  late Directory cache;

  setUp(() => cache = Directory.systemTemp.createTempSync('books-'));
  tearDown(() => cache.deleteSync(recursive: true));

  JellyfinBookRepository repo(
    FakeAdapter adapter, {
    int cacheLimit = JellyfinBookRepository.defaultCacheLimit,
  }) => JellyfinBookRepository(
    testSession,
    () async => client,
    () async => cache,
    MemoryKeyValueStore(),
    onUnauthorized: () {},
    adapter: adapter,
    cacheLimit: cacheLimit,
  );

  /// A server whose answers wait for [release].
  FakeAdapter held(Completer<void> release, {int status = 200}) =>
      FakeAdapter((_) async {
        await release.future;
        return ResponseBody(Stream.value(content), status);
      });

  test(
    'asked twice while it downloads: one download, one whole book',
    () async {
      final release = Completer<void>();
      final adapter = held(release);
      final books = repo(adapter);

      // The reader closed and opened again before the first download ended.
      final first = books.file(book);
      final second = books.file(book);
      release.complete();
      final files = await Future.wait([first, second]);

      expect(adapter.requests, hasLength(1));
      expect(files[0].path, files[1].path);
      expect(files[0].readAsBytesSync(), content);
      // Nothing left beside it.
      expect(cache.listSync(), hasLength(1));
    },
  );

  test('once in the cache, no download', () async {
    final release = Completer<void>()..complete();
    final adapter = held(release);
    final books = repo(adapter);

    await books.file(book);
    await books.file(book);
    expect(adapter.requests, hasLength(1));
  });

  test('a failed download can be tried again', () async {
    var fail = true;
    final adapter = FakeAdapter(
      (_) async => fail
          ? ResponseBody.fromString('', 500)
          : ResponseBody(Stream.value(content), 200),
    );
    final books = repo(adapter);

    await expectLater(books.file(book), throwsA(isA<Failure>()));
    expect(cache.listSync(), isEmpty, reason: 'no half book left');

    fail = false;
    expect((await books.file(book)).readAsBytesSync(), content);
    expect(adapter.requests, hasLength(2));
  });

  test(
    'temporary files of a killed run are removed; a fresh one is not',
    () async {
      final name = bookCacheFile(cache, testSession.server.id, book.id).path;
      final old = File('$name.1-0.part')
        ..writeAsStringSync('half')
        ..setLastModifiedSync(
          DateTime.now().subtract(const Duration(hours: 1)),
        );
      // Another app's download, under way.
      final fresh = File('$name.2-0.part')..writeAsStringSync('half');

      final release = Completer<void>()..complete();
      await repo(held(release)).file(book);

      expect(old.existsSync(), isFalse);
      expect(fresh.existsSync(), isTrue);
    },
  );

  group('the cache keeps within its limit', () {
    final now = DateTime(2026, 11, 19, 12);
    CachedBook entry(String name, int size, int hoursAgo) =>
        (path: name, size: size, used: now.subtract(Duration(hours: hoursAgo)));

    test('within the limit: nothing goes', () {
      expect(
        booksToEvict([entry('a', 40, 3), entry('b', 60, 1)], 100, keep: 'b'),
        isEmpty,
      );
    });

    test('over it: the ones opened longest ago go, until it fits', () {
      final books = [
        entry('new', 50, 1),
        entry('oldest', 50, 30),
        entry('old', 50, 20),
        entry('recent', 50, 5),
      ];
      expect(booksToEvict(books, 100, keep: 'new'), ['oldest', 'old']);
    });

    test('never the book being opened, even when it alone is too big', () {
      final books = [entry('huge', 500, 99), entry('small', 10, 1)];
      expect(booksToEvict(books, 100, keep: 'huge'), ['small']);
    });

    /// A book already in the cache, of [size] bytes, last opened [ago].
    File cached(String name, int size, Duration ago) =>
        File('${cache.path}/$name')
          ..writeAsBytesSync(Uint8List(size))
          ..setLastModifiedSync(DateTime.now().subtract(ago));

    test(
      'a download past the limit removes the books opened longest ago',
      () async {
        final oldest = cached('oldest', 3000, const Duration(days: 30));
        final recent = cached('recent', 3000, const Duration(hours: 1));
        final release = Completer<void>()..complete();

        // 3000 + 3000 + the new book's 4096 > 8000: the oldest goes.
        final file = await repo(held(release), cacheLimit: 8000).file(book);

        expect(file.existsSync(), isTrue);
        expect(recent.existsSync(), isTrue);
        expect(oldest.existsSync(), isFalse);
      },
    );

    test('opening a book from the cache makes it the last to go', () async {
      final release = Completer<void>()..complete();
      final books = repo(held(release), cacheLimit: 8000);
      final comic = await books.file(book);
      comic.setLastModifiedSync(
        DateTime.now().subtract(const Duration(days: 9)),
      );
      final other = cached('other', 3000, const Duration(days: 1));

      await books.file(book); // Read again: now the latest.
      cached('third', 3000, const Duration(minutes: 1));
      await books.file(book); // Over the limit: "other" is the oldest now.

      expect(comic.existsSync(), isTrue);
      expect(other.existsSync(), isFalse);
    });
  });
}
