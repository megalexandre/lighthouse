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
      font: ReaderFont.literata,
      fontScale: 135,
      lineSpacing: 115,
      letterSpacing: 2,
      justify: false,
      layout: PageLayout.double,
    );
    expect(ReaderPreferences.fromJson(prefs.toJson()), prefs);
    expect(
      ReaderPreferences.fromJson({
        'theme': 'neon',
        'font': 'comic',
        'fontScale': 101,
        'lineSpacing': 'x',
        'letterSpacing': -1,
        'layout': 'triple',
      }),
      const ReaderPreferences(),
    );
  });

  test('the type the preferences set', () {
    final type = const ReaderPreferences(
      font: ReaderFont.atkinson,
      fontScale: 150,
      lineSpacing: 80,
      letterSpacing: 2,
      justify: false,
    ).typography;
    expect(type.fontFamily, 'Atkinson Hyperlegible');
    expect(type.fontSize, 27);
    expect(type.lineHeight, closeTo(1.16, 1e-9));
    expect(type.letterSpacing, closeTo(27 * 0.05, 1e-9));
    expect(type.justify, isFalse);
    // The defaults: Noto Sans, as the type was set before at 100%.
    final base = const ReaderPreferences().typography;
    expect(base.fontFamily, 'Noto Sans');
    expect(base.fontSize, 18);
    expect(base.lineHeight, 1.45);
    expect(base.letterSpacing, 0);
    expect(base.justify, isTrue);
  });

  test('a size stored in pixels becomes the nearest step', () {
    ReaderPreferences read(Map<String, Object> json) =>
        ReaderPreferences.fromJson(json);
    expect(read({'fontSize': 18}).fontScale, 100);
    expect(read({'fontSize': 24, 'sansSerif': true}).fontScale, 135);
    expect(read({'fontSize': 14}).fontScale, 80);
    expect(read({'fontSize': 32}).fontScale, 175);
    expect(read({'fontSize': 32, 'fontScale': 90}).fontScale, 90);
  });

  test('sizes step within the list', () {
    const prefs = ReaderPreferences();
    expect(prefs.resized(1).fontScale, 110);
    expect(prefs.resized(-2).fontScale, 80);
    expect(prefs.resized(-9).fontScale, 80);
    expect(prefs.resized(99).fontScale, 175);
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
