import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/client_info.dart';
import 'package:lighthouse/core/storage.dart';
import 'package:lighthouse/features/reader/application/reader_preferences.dart';
import 'package:lighthouse/features/reader/data/book_repository.dart';

import '../../support/fakes.dart';

void main() {
  test('preferences: stored and read back; bad values fall back', () {
    const prefs = ReaderPreferences(
      theme: ReaderTheme.sepia,
      fontSize: 24,
      sansSerif: true,
    );
    expect(ReaderPreferences.fromJson(prefs.toJson()), prefs);
    expect(
      ReaderPreferences.fromJson({'theme': 'neon', 'fontSize': 19, 'x': 1}),
      const ReaderPreferences(),
    );
    expect(prefs.typography.fontFamily, 'sans-serif');
  });

  test('type sizes step within the list', () {
    const prefs = ReaderPreferences();
    expect(prefs.resized(1).fontSize, 20);
    expect(prefs.resized(-2).fontSize, 14);
    expect(prefs.resized(-9).fontSize, 14);
    expect(prefs.resized(99).fontSize, 32);
  });

  test('the light theme leaves PDFs as they are', () {
    expect(ReaderTheme.light.pageColors.recolor, isNull);
    expect(ReaderTheme.dark.pageColors.recolor, isNotNull);
  });

  group('bookmarks on this device', () {
    late MemoryKeyValueStore store;
    late JellyfinBookRepository books;

    setUp(() {
      store = MemoryKeyValueStore();
      books = JellyfinBookRepository(
        testSession,
        () async => const ClientInfo(deviceId: 'dev-1', device: 'pc'),
        () => throw UnimplementedError(),
        store,
        onUnauthorized: () {},
      );
    });

    test('kept per book, in order; none left means no file', () async {
      expect(await books.bookmarks('item-1'), isEmpty);
      await books.saveBookmarks('item-1', [0.5, 0.25]);
      expect(await books.bookmarks('item-1'), [0.25, 0.5]);
      expect(await books.bookmarks('item-2'), isEmpty);
      // The key names server and book, encoded (no path in it).
      expect(store.values.keys.single, startsWith('bookmarks-'));
      expect(store.values.keys.single, isNot(contains('/')));
      await books.saveBookmarks('item-1', []);
      expect(store.values, isEmpty);
    });

    test(
      'a broken file reads as no bookmarks; odd values are skipped',
      () async {
        await books.saveBookmarks('item-1', [0.5]);
        final key = store.values.keys.single;
        store.values[key] = '[0.1, "x", 7, -1, 0.9]';
        expect(await books.bookmarks('item-1'), [0.1, 0.9]);
        store.values[key] = 'not json';
        expect(await books.bookmarks('item-1'), isEmpty);
      },
    );
  });
}
