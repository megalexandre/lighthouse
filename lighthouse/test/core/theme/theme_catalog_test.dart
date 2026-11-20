import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/storage.dart';
import 'package:lighthouse/core/theme/appearance.dart';
import 'package:lighthouse/core/theme/theme_catalog.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  final lanterna = File('assets/themes/lanterna.json').readAsStringSync();
  final mine = lanterna.replaceFirst('"name": "Lanterna"', '"name": "Mine"');

  group('a folder of themes', () {
    late Directory dir;
    late DirectoryThemeSource source;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('jf-themes-');
      addTearDown(() => dir.delete(recursive: true));
      source = DirectoryThemeSource(
        () async => Directory('${dir.path}/themes'),
      );
    });

    test('lists its .json files in order; made if missing', () async {
      expect(await source.load(), isEmpty);
      File('${dir.path}/themes/b.json').writeAsStringSync('{}');
      File('${dir.path}/themes/a.json').writeAsStringSync(mine);
      File('${dir.path}/themes/notes.txt').writeAsStringSync('x');
      final files = await source.load();
      expect(files.map((f) => f.id), ['user:a.json', 'user:b.json']);
      expect(files.first.source, mine);
    });

    test('a file saved there is noticed', () async {
      await source.directory();
      final changed = source.changes().first;
      // The watch starts once the folder is there (asynchronously).
      await Future<void>.delayed(const Duration(milliseconds: 200));
      File('${dir.path}/themes/new.json').writeAsStringSync(mine);
      await changed.timeout(const Duration(seconds: 5));
    });

    test(
      'a file that cannot be read is left out; the others are listed',
      () async {
        await source.directory();
        File('${dir.path}/themes/a.json').writeAsStringSync(mine);
        final locked = File('${dir.path}/themes/locked.json')
          ..writeAsStringSync(mine);
        await Process.run('chmod', ['000', locked.path]);
        addTearDown(() => Process.run('chmod', ['644', locked.path]));
        expect((await source.load()).map((f) => f.id), ['user:a.json']);
      },
    );

    test('a huge file is not read', () async {
      await source.directory();
      File('${dir.path}/themes/big.json')
          .writeAsStringSync(' ' * (DirectoryThemeSource.maxBytes + 1));
      expect((await source.load()).single.source, isEmpty);
    });
  });

  group('the catalog', () {
    late MemoryUserThemes user;
    late ProviderContainer container;

    setUp(() {
      user = MemoryUserThemes({'mine.json': mine, 'broken.json': '{"color": '});
      container = ProviderContainer.test(
        overrides: [
          builtInThemesProvider.overrideWithValue(builtInThemesForTests),
          userThemeSourceProvider.overrideWithValue(user),
          appFilesStoreProvider.overrideWithValue(MemoryKeyValueStore()),
        ],
      );
    });

    Future<ThemeCatalog> settled() async {
      container.read(themeCatalogProvider);
      await pumpEventQueue();
      return container.read(themeCatalogProvider);
    }

    test('built in first, then the folder; a broken file says why', () async {
      final catalog = await settled();
      expect(catalog.entries.map((e) => e.id), [
        'builtin:lanterna.json',
        'builtin:prime.json',
        'user:broken.json',
        'user:mine.json',
      ]);
      expect(catalog.byId('user:mine.json')!.name, 'Mine');
      expect(catalog.byId('user:broken.json')!.error, contains('not JSON'));
      expect(catalog.userDirectory, MemoryUserThemes.path);
    });

    test(
      'an empty file says why; one with gaps is used, the gaps filled',
      () async {
        user.files
          ..clear()
          ..['empty.json'] = ''
          ..['partial.json'] = jsonEncode(
            (jsonDecode(mine) as Map<String, dynamic>)
              ..['name'] = 'Partial'
              ..remove('spacing'),
          );
        final catalog = await settled();
        expect(
          catalog.byId('user:empty.json')!.error,
          'empty, or larger than 1 MB',
        );
        final partial = catalog.byId('user:partial.json')!.tokens!;
        expect(partial.name, 'Partial');
        expect(partial.warnings, isNotEmpty);
      },
    );

    test(
      'a folder that cannot be read: the built-in themes all the same',
      () async {
        final unreadable = ProviderContainer.test(
          overrides: [
            builtInThemesProvider.overrideWithValue(builtInThemesForTests),
            userThemeSourceProvider.overrideWithValue(_UnreadableFolder()),
            appFilesStoreProvider.overrideWithValue(MemoryKeyValueStore()),
          ],
        );
        unreadable.read(themeCatalogProvider);
        await pumpEventQueue();
        final catalog = unreadable.read(themeCatalogProvider);
        expect(catalog.entries.map((e) => e.id), [
          'builtin:lanterna.json',
          'builtin:prime.json',
        ]);
        expect(catalog.userDirectory, isNull);
      },
    );

    test('a change in the folder: read again once it settles', () async {
      await settled();
      user.files['other.json'] = mine.replaceFirst('"Mine"', '"Other"');
      user.changed();
      await Future<void>.delayed(
        ThemeCatalogController.settle + const Duration(milliseconds: 100),
      );
      await pumpEventQueue();
      expect(
        container.read(themeCatalogProvider).byId('user:other.json')!.name,
        'Other',
      );
    });

    test(
      'the chosen theme, or the default (Prime) when it is gone or broken',
      () async {
        await settled();
        final appearance = container.read(appearanceProvider.notifier);
        await appearance.set(
          const Appearance(themeId: 'user:mine.json', mode: ThemeMode.light),
        );
        var theme = container.read(appThemeProvider);
        expect(theme.entry.name, 'Mine');
        expect(theme.mode, ThemeMode.light);
        await appearance.set(const Appearance(themeId: 'user:broken.json'));
        theme = container.read(appThemeProvider);
        expect(theme.entry.id, ThemeCatalog.defaultId);
      },
    );
  });

  testWidgets('the built-in themes are the files in assets/themes', (
    tester,
  ) async {
    final files = (await tester.runAsync(() => loadBuiltInThemes(rootBundle)))!;
    expect(
      files.map((f) => f.id),
      containsAll([ThemeCatalog.baseId, ThemeCatalog.defaultId]),
    );
    expect(files.every((f) => f.source.isNotEmpty), isTrue);
  });

  test('the default theme when Prime cannot be read: Lanterna', () {
    const lanternaEntry = ThemeEntry(
      id: ThemeCatalog.baseId,
      path: 'assets/themes/lanterna.json',
    );
    const brokenPrime = ThemeEntry(
      id: ThemeCatalog.defaultId,
      path: 'assets/themes/prime.json',
      error: 'not JSON',
    );
    const catalog = ThemeCatalog(entries: [lanternaEntry, brokenPrime]);
    expect(catalog.fallback, same(lanternaEntry));
  });
}

/// A themes folder the app may not read.
class _UnreadableFolder implements UserThemeSource {
  @override
  Future<String> directory() async =>
      throw const FileSystemException('Permission denied', '/themes');

  @override
  Future<List<ThemeFile>> load() async => const [];

  @override
  Stream<void> changes() => const Stream.empty();
}
