import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/core/storage.dart';
import 'package:jellyfin_flutter/core/theme/appearance.dart';
import 'package:jellyfin_flutter/core/theme/theme_catalog.dart';
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
}
