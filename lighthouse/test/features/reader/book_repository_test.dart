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

  JellyfinBookRepository repo(FakeAdapter adapter) => JellyfinBookRepository(
    testSession,
    () async => client,
    () async => cache,
    MemoryKeyValueStore(),
    onUnauthorized: () {},
    adapter: adapter,
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
}
