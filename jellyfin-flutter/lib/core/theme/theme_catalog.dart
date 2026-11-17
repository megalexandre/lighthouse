import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../log.dart';
import 'design_tokens.dart';

/// A theme file: its text (a design system's tokens.json) and where it
/// came from.
class ThemeFile {
  const ThemeFile({required this.id, required this.path, required this.source});

  /// `builtin:<file>` or `user:<file>`.
  final String id;
  final String path;
  final String source;
}

/// A theme the user can pick: read ([tokens], maybe with warnings), or
/// refused ([error]).
class ThemeEntry {
  const ThemeEntry({
    required this.id,
    required this.path,
    this.tokens,
    this.error,
  });

  final String id;
  final String path;
  final DesignTokens? tokens;
  final String? error;

  bool get builtIn => id.startsWith('builtin:');
  String get fileName => path.split(RegExp(r'[/\\]')).last;
  String get name => tokens?.name ?? fileName;
  List<String> get warnings => tokens?.warnings ?? const [];
}

/// Every theme there is: the app's own, then the user's folder.
class ThemeCatalog {
  const ThemeCatalog({required this.entries, this.userDirectory});

  final List<ThemeEntry> entries;

  /// Where the user's themes go (null until known).
  final String? userDirectory;

  /// The base theme: complete by itself, it fills in any other theme's
  /// gaps.
  static const baseId = 'builtin:lanterna.json';

  /// The theme shown until the user picks one (or when theirs is gone or
  /// broken): Prime.
  static const defaultId = 'builtin:prime.json';

  ThemeEntry get base => entries.firstWhere((e) => e.id == baseId);

  /// The default theme, or the base when the default cannot be read.
  ThemeEntry get fallback => switch (byId(defaultId)) {
    final ThemeEntry e when e.tokens != null => e,
    _ => base,
  };

  ThemeEntry? byId(String id) => entries.where((e) => e.id == id).firstOrNull;
}

/// The built-in themes' files, read before the app starts (main, tests):
/// the first frame already has its theme.
final builtInThemesProvider = Provider<List<ThemeFile>>(
  (_) => throw UnimplementedError('load them with loadBuiltInThemes()'),
);

/// The built-in themes, `assets/themes/*.json`.
Future<List<ThemeFile>> loadBuiltInThemes(AssetBundle bundle) async {
  final manifest = await AssetManifest.loadFromAssetBundle(bundle);
  final paths =
      manifest
          .listAssets()
          .where((p) => p.startsWith('assets/themes/') && p.endsWith('.json'))
          .toList()
        ..sort();
  return [
    for (final path in paths)
      ThemeFile(
        id: 'builtin:${path.split('/').last}',
        path: path,
        source: await bundle.loadString(path, cache: false),
      ),
  ];
}

/// The user's own themes: files in a folder, watched for changes.
abstract interface class UserThemeSource {
  /// The folder's path, made if missing.
  Future<String> directory();

  Future<List<ThemeFile>> load();

  /// Something in the folder changed.
  Stream<void> changes();
}

final userThemeSourceProvider = Provider<UserThemeSource>(
  (_) => DirectoryThemeSource(
    () async =>
        Directory('${(await getApplicationSupportDirectory()).path}/themes'),
  ),
);

/// Themes as `*.json` files in a folder (the app's data folder/themes).
class DirectoryThemeSource implements UserThemeSource {
  DirectoryThemeSource(this._directory);

  final Future<Directory> Function() _directory;

  /// Far bigger than any tokens file: a bigger one is not read.
  static const maxBytes = 1 << 20;

  Future<Directory> _dir() async {
    final dir = await _directory();
    await dir.create(recursive: true);
    return dir;
  }

  @override
  Future<String> directory() async => (await _dir()).path;

  @override
  Future<List<ThemeFile>> load() async {
    final dir = await _dir();
    final files =
        await dir
              .list()
              .where((e) => e is File && e.path.endsWith('.json'))
              .cast<File>()
              .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    final result = <ThemeFile>[];
    for (final file in files) {
      final name = file.uri.pathSegments.last;
      try {
        if (await file.length() > maxBytes) {
          result.add(ThemeFile(id: 'user:$name', path: file.path, source: ''));
          continue;
        }
        result.add(
          ThemeFile(
            id: 'user:$name',
            path: file.path,
            source: await file.readAsString(),
          ),
        );
      } on FileSystemException catch (e) {
        log.warning('theme', 'cannot read ${file.path}', e.message);
      }
    }
    return result;
  }

  @override
  Stream<void> changes() async* {
    final dir = await _dir();
    yield* dir.watch().where((e) => e.path.endsWith('.json')).map((_) {});
  }
}

final themeCatalogProvider =
    NotifierProvider<ThemeCatalogController, ThemeCatalog>(
      ThemeCatalogController.new,
    );

/// Reads the themes: the built-in ones at once, the user's folder right
/// after, and again whenever a file there changes (saving a theme in an
/// editor shows it in the app).
class ThemeCatalogController extends Notifier<ThemeCatalog> {
  /// Editors save in several steps (temp file, rename): one reload after.
  static const settle = Duration(milliseconds: 300);

  late List<ThemeEntry> _builtIn;
  Timer? _settle;

  @override
  ThemeCatalog build() {
    _builtIn = _readBuiltIn(ref.watch(builtInThemesProvider));
    final source = ref.watch(userThemeSourceProvider);
    final subscription = source.changes().listen(
      (_) {
        _settle?.cancel();
        _settle = Timer(settle, () => unawaited(_loadUser(source)));
      },
      onError: (Object e) =>
          log.warning('theme', 'cannot watch the themes folder', e),
    );
    ref.onDispose(() {
      _settle?.cancel();
      unawaited(subscription.cancel());
    });
    unawaited(_loadUser(source));
    return ThemeCatalog(entries: _builtIn);
  }

  static List<ThemeEntry> _readBuiltIn(List<ThemeFile> files) {
    final defaults = files.where((f) => f.id == ThemeCatalog.baseId);
    if (defaults.isEmpty) {
      throw StateError('The built-in Lanterna theme is missing');
    }
    // Complete by itself (no fallback): a gap there is a build error.
    final lanterna = DesignTokens.parse(defaults.first.source);
    return [
      ThemeEntry(
        id: defaults.first.id,
        path: defaults.first.path,
        tokens: lanterna,
      ),
      for (final file in files)
        if (file.id != ThemeCatalog.baseId) _entry(file, lanterna),
    ];
  }

  static ThemeEntry _entry(ThemeFile file, DesignTokens fallback) {
    if (file.source.isEmpty) {
      return ThemeEntry(
        id: file.id,
        path: file.path,
        error: 'empty, or larger than 1 MB',
      );
    }
    try {
      final tokens = DesignTokens.parse(file.source, fallback: fallback);
      for (final w in tokens.warnings) {
        log.warning('theme', '${file.path}: $w');
      }
      return ThemeEntry(id: file.id, path: file.path, tokens: tokens);
    } on FormatException catch (e) {
      log.warning('theme', '${file.path}: refused', e.message);
      return ThemeEntry(id: file.id, path: file.path, error: e.message);
    }
  }

  Future<void> _loadUser(UserThemeSource source) async {
    try {
      final directory = await source.directory();
      final files = await source.load();
      if (!ref.mounted) return;
      final fallback = _builtIn.first.tokens!;
      state = ThemeCatalog(
        entries: [..._builtIn, for (final f in files) _entry(f, fallback)],
        userDirectory: directory,
      );
    } on Object catch (e) {
      log.warning('theme', 'cannot read the themes folder', e);
    }
  }

  /// Reads the folder again now.
  Future<void> reload() => _loadUser(ref.read(userThemeSourceProvider));
}

/// No user themes (integration tests: the desktop's folder is left alone).
class NoUserThemes implements UserThemeSource {
  const NoUserThemes();

  @override
  Future<String> directory() async => '';

  @override
  Future<List<ThemeFile>> load() async => const [];

  @override
  Stream<void> changes() => const Stream.empty();
}

/// User themes in memory (widget tests): [files] by file name; [changed]
/// says the folder changed.
class MemoryUserThemes implements UserThemeSource {
  MemoryUserThemes([Map<String, String>? files]) : files = files ?? {};

  static const path = '/themes';

  final Map<String, String> files;
  final _changes = StreamController<void>.broadcast();

  void changed() => _changes.add(null);

  @override
  Future<String> directory() async => path;

  @override
  Future<List<ThemeFile>> load() async => [
    for (final name in files.keys.toList()..sort())
      ThemeFile(id: 'user:$name', path: '$path/$name', source: files[name]!),
  ];

  @override
  Stream<void> changes() => _changes.stream;
}
