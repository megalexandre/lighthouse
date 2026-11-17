import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../failure.dart';
import '../log.dart';
import '../storage.dart';
import 'theme_builder.dart';
import 'theme_catalog.dart';

/// The theme the user picked, if they picked one, and in which mode (dark
/// by default).
///
/// [themeId] null means "the app's default" (ThemeCatalog.defaultId): a
/// new default reaches everyone who never chose a theme. Only a choice in
/// the theme list sets it; changing the mode does not.
@immutable
class Appearance {
  const Appearance({this.themeId, this.mode = ThemeMode.dark});

  final String? themeId;
  final ThemeMode mode;

  /// The theme to show.
  String get theme => themeId ?? ThemeCatalog.defaultId;

  Appearance copyWith({String? themeId, ThemeMode? mode}) =>
      Appearance(themeId: themeId ?? this.themeId, mode: mode ?? this.mode);

  /// The choice is stored as `chosenTheme`. Files written before (with a
  /// `theme` key) stored the default of the time alongside a mode change:
  /// that key is not read, so they follow today's default.
  Map<String, String> toJson() => {'chosenTheme': ?themeId, 'mode': mode.name};

  factory Appearance.fromJson(Map<String, dynamic> json) => Appearance(
    themeId: switch (json['chosenTheme']) {
      final String id when id.isNotEmpty => id,
      _ => null,
    },
    mode: ThemeMode.values.asNameMap()[json['mode']] ?? ThemeMode.dark,
  );

  @override
  bool operator ==(Object other) =>
      other is Appearance && other.themeId == themeId && other.mode == mode;

  @override
  int get hashCode => Object.hash(themeId, mode);
}

/// The app's own small files (the appearance), in its data folder: not
/// secret, so not in the keyring.
final appFilesStoreProvider = Provider<KeyValueStore>(
  (_) => FileKeyValueStore(
    () async =>
        Directory('${(await getApplicationSupportDirectory()).path}/settings'),
  ),
);

final appearanceProvider = NotifierProvider<AppearanceController, Appearance>(
  AppearanceController.new,
);

/// The [Appearance], kept on this device. Starts with the default and
/// switches to the stored one as soon as it is read.
class AppearanceController extends Notifier<Appearance> {
  static const _key = 'appearance';
  bool _changed = false;

  @override
  Appearance build() {
    Future(() async {
      final raw = await ref.read(appFilesStoreProvider).read(_key);
      // A choice made meanwhile wins over the stored one.
      if (raw == null || _changed || !ref.mounted) return;
      try {
        state = Appearance.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } on Object catch (e) {
        log.warning('theme', 'appearance unreadable, using the default', e);
      }
    }).ignore();
    return const Appearance();
  }

  Future<void> set(Appearance appearance) async {
    _changed = true;
    if (appearance == state) return;
    state = appearance;
    try {
      await ref
          .read(appFilesStoreProvider)
          .write(_key, jsonEncode(appearance.toJson()));
    } on Failure catch (e) {
      log.warning('theme', 'could not store the appearance', e);
    }
  }
}

/// The app's themes, ready for MaterialApp.
@immutable
class AppTheme {
  const AppTheme({
    required this.entry,
    required this.light,
    required this.dark,
    required this.mode,
  });

  /// The theme shown (the default when the chosen one is gone or broken).
  final ThemeEntry entry;
  final ThemeData light;
  final ThemeData dark;
  final ThemeMode mode;
}

final appThemeProvider = Provider<AppTheme>((ref) {
  final catalog = ref.watch(themeCatalogProvider);
  final appearance = ref.watch(appearanceProvider);
  final chosen = catalog.byId(appearance.theme);
  final entry = chosen?.tokens != null ? chosen! : catalog.fallback;
  final tokens = entry.tokens!;
  return AppTheme(
    entry: entry,
    light: buildTheme(tokens, Brightness.light),
    dark: buildTheme(tokens, Brightness.dark),
    mode: appearance.mode,
  );
});
