import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/culture_dto.dart';
import '../../../api/models/user_configuration.dart';
import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../../../core/theme/appearance.dart';
import '../../../core/theme/theme_catalog.dart';
import '../../../core/window_size.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/error_retry.dart';
import '../../auth/application/auth_controller.dart';
import '../application/settings_providers.dart';
import '../data/settings_repository.dart';

/// Playback settings: quality (this device), audio and subtitle languages,
/// when subtitles show, next episode autoplay (the user's, on the server);
/// the app's look (theme and mode, this device; docs/THEMES.md).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const qualityField = Key('settings.quality');
  static const audioLanguageField = Key('settings.audioLanguage');
  static const subtitleLanguageField = Key('settings.subtitleLanguage');
  static const subtitleModeField = Key('settings.subtitleMode');
  static const autoplaySwitch = Key('settings.autoplay');
  static const themeField = Key('settings.theme');
  static const languageField = Key('settings.language');
  static Key modeChoice(ThemeMode mode) => Key('settings.mode.${mode.name}');
  static const themesFolder = Key('settings.themesFolder');
  static const themeIssues = Key('settings.themeIssues');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).value?.session;
    final config = ref.watch(userConfigurationProvider);
    final quality = ref.watch(maxStreamingBitrateProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      // Clear of a notch at the sides; the gesture bar is scrolled past.
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(
            top: 16,
            bottom: 16 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            _Heading(context.l10n.playback),
            _Choice<int?>(
              key: qualityField,
              label: context.l10n.maxQuality,
              help: context.l10n.maxQualityHelp,
              value: quality,
              options: [
                for (final (bits, label) in qualityOptions)
                  (bits, bits == null ? context.l10n.qualityMaximum : label),
              ],
              onChanged: (v) =>
                  ref.read(maxStreamingBitrateProvider.notifier).set(v),
            ),
            switch (config) {
              AsyncData(value: final config) => _UserSettings(config: config),
              AsyncError(:final error) => ErrorRetry(
                error: error,
                onRetry: () => ref.invalidate(userConfigurationProvider),
              ),
              _ => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            },
            _Heading(context.l10n.appearance),
            const _AppearanceSettings(),
            if (session != null) ...[
              _Heading(context.l10n.account),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(session.userName),
                subtitle: Text(session.server.name),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The settings kept on the server for this user.
class _UserSettings extends ConsumerWidget {
  const _UserSettings({required this.config});

  final UserConfiguration config;

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(UserConfigurationController c) change,
  ) async {
    try {
      await change(ref.read(userConfigurationProvider.notifier));
    } on Failure catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.describe(context.l10n))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languages = ref.watch(languagesProvider).value ?? const [];
    final options = languageOptions(languages, [
      ?config.audioLanguagePreference,
      ?config.subtitleLanguagePreference,
    ], context.l10n);
    return Column(
      children: [
        _LanguageChoice(
          key: SettingsScreen.audioLanguageField,
          label: context.l10n.audioLanguage,
          help: context.l10n.audioLanguageHelp,
          value: config.audioLanguagePreference ?? noLanguage,
          options: [(noLanguage, context.l10n.fileDefault), ...options],
          onChanged: (v) =>
              _save(context, ref, (c) => c.change(audioLanguage: v)),
        ),
        _LanguageChoice(
          key: SettingsScreen.subtitleLanguageField,
          label: context.l10n.subtitleLanguage,
          value: config.subtitleLanguagePreference ?? noLanguage,
          options: [(noLanguage, context.l10n.anyLanguage), ...options],
          onChanged: (v) =>
              _save(context, ref, (c) => c.change(subtitleLanguage: v)),
        ),
        _Choice<SubtitlePlaybackMode>(
          key: SettingsScreen.subtitleModeField,
          label: context.l10n.showSubtitles,
          value: config.subtitleMode,
          options: [
            (SubtitlePlaybackMode.defaultMode, context.l10n.subtitlesDefault),
            (SubtitlePlaybackMode.smart, context.l10n.subtitlesSmart),
            (SubtitlePlaybackMode.always, context.l10n.subtitlesAlways),
            (SubtitlePlaybackMode.onlyForced, context.l10n.subtitlesForced),
            (SubtitlePlaybackMode.none, context.l10n.subtitlesNever),
          ],
          onChanged: (v) =>
              _save(context, ref, (c) => c.change(subtitleMode: v)),
        ),
        SwitchListTile(
          key: SettingsScreen.autoplaySwitch,
          title: Text(context.l10n.autoplayNext),
          value: config.enableNextEpisodeAutoPlay,
          onChanged: (v) =>
              _save(context, ref, (c) => c.change(nextEpisodeAutoPlay: v)),
        ),
      ],
    );
  }
}

/// (code, name) for the language pickers, one per code, named in the
/// app's language and sorted by that name. The server lists regional
/// variants under the same code ("Portuguese (Brazil)" is "por" too), and
/// only the code is saved, so one name stands for all: the app's own, or
/// else the server's plain (shortest) one. Codes in [keep] that the server
/// list lacks stay selectable as their code.
List<(String, String)> languageOptions(
  List<CultureDto> cultures,
  List<String> keep,
  AppLocalizations l10n,
) {
  final options = <String, String>{};
  for (final c in cultures) {
    final code = c.threeLetterIsoLanguageName!;
    final known = options[code];
    if (known == null || c.displayName.length < known.length) {
      options[code] = c.displayName;
    }
  }
  for (final code in keep) {
    if (code.isNotEmpty) options.putIfAbsent(code, () => code);
  }
  return [
    for (final e in options.entries)
      (e.key, languageName(e.key, l10n) ?? e.value),
  ]..sort((a, b) => _sortKey(a.$2).compareTo(_sortKey(b.$2)));
}

/// [name] as the sort sees it: case and accents dropped, so "Árabe"
/// sorts with the A's (Dart has no collation of its own).
String _sortKey(String name) {
  final lower = name.toLowerCase();
  final out = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    out.write(_unaccented[ch] ?? ch);
  }
  return out.toString();
}

const _unaccented = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', //
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', //
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', //
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', //
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', //
  'ç': 'c', 'ñ': 'n', 'ý': 'y', 'ÿ': 'y',
};

/// Opens a folder in the desktop's file manager.
final folderOpenerProvider = Provider<Future<void> Function(String path)>(
  (_) => (path) async {
    if (!Platform.isLinux) return;
    try {
      await Process.start('xdg-open', [path], mode: ProcessStartMode.detached);
    } on ProcessException catch (e) {
      log.warning('settings', 'cannot open $path', e.message);
    }
  },
);

/// The theme (built in, or from the user's folder) and the mode.
class _AppearanceSettings extends ConsumerWidget {
  const _AppearanceSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(themeCatalogProvider);
    final appearance = ref.watch(appearanceProvider);
    final shown = ref.watch(appThemeProvider).entry;
    // From the appearance at the tap, not at this build.
    Future<void> update(Appearance Function(Appearance) change) => ref
        .read(appearanceProvider.notifier)
        .set(change(ref.read(appearanceProvider)));
    final usable = [
      for (final e in catalog.entries)
        if (e.tokens != null) e,
    ];
    final broken = [
      for (final e in catalog.entries)
        if (e.tokens == null) e,
    ];
    final twoModes = shown.tokens!.hasLightAndDark;
    final folder = catalog.userDirectory;
    final issues = [
      for (final w in shown.warnings) '${shown.fileName}: $w',
      for (final e in broken)
        context.l10n.themeNotUsed(e.fileName, '${e.error}'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Choice<String>(
          key: SettingsScreen.themeField,
          label: context.l10n.theme,
          help: context.l10n.themeHelp,
          value: shown.id,
          options: [
            for (final e in usable)
              (e.id, e.builtIn ? e.name : context.l10n.themeFromFolder(e.name)),
          ],
          onChanged: (id) => update((a) => a.copyWith(themeId: id)),
        ),
        _Choice<AppLanguage>(
          key: SettingsScreen.languageField,
          label: context.l10n.settingsLanguage,
          help: context.l10n.settingsLanguageHelp,
          value: ref.watch(appLanguageProvider),
          options: [for (final l in AppLanguage.values) (l, l.name)],
          onChanged: (language) =>
              update((a) => a.copyWith(language: language)),
        ),
        _ModeChoice(
          mode: appearance.mode,
          enabled: twoModes,
          onChanged: (mode) => unawaited(update((a) => a.copyWith(mode: mode))),
        ),
        if (folder != null && folder.isNotEmpty) _ThemesFolder(folder: folder),
        if (issues.isNotEmpty) _ThemeIssues(issues: issues),
      ],
    );
  }
}

/// Dark, light or the system's, when the theme has both.
class _ModeChoice extends StatelessWidget {
  const _ModeChoice({
    required this.mode,
    required this.enabled,
    required this.onChanged,
  });

  final ThemeMode mode;
  final bool enabled;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) => _SettingTile(
    title: context.l10n.mode,
    help: enabled ? null : context.l10n.singleMode,
    control: ({required below}) => SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      segments: [
        for (final (value, label) in [
          (ThemeMode.dark, context.l10n.modeDark),
          (ThemeMode.light, context.l10n.modeLight),
          (ThemeMode.system, context.l10n.modeSystem),
        ])
          ButtonSegment(
            value: value,
            label: Text(label, key: SettingsScreen.modeChoice(value)),
            enabled: enabled,
          ),
      ],
      selected: {mode},
      onSelectionChanged: (s) => onChanged(s.single),
    ),
  );
}

/// Where the user's own themes go, with a button to open it.
class _ThemesFolder extends ConsumerWidget {
  const _ThemesFolder({required this.folder});

  final String folder;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    key: SettingsScreen.themesFolder,
    title: Text(context.l10n.yourThemes),
    subtitle: Text(context.l10n.yourThemesHelp(folder)),
    trailing: Platform.isLinux
        ? TextButton(
            onPressed: () => unawaited(ref.read(folderOpenerProvider)(folder)),
            child: Text(context.l10n.openFolder),
          )
        : null,
  );
}

/// What is wrong with the themes: warnings of the one shown, files that
/// could not be used.
class _ThemeIssues extends StatelessWidget {
  const _ThemeIssues({required this.issues});

  final List<String> issues;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    key: SettingsScreen.themeIssues,
    leading: Icon(
      Icons.warning_amber,
      color: Theme.of(context).colorScheme.error,
    ),
    title: Text(context.l10n.themeIssues(issues.length)),
    children: [
      for (final issue in issues)
        ListTile(dense: true, title: SelectableText(issue)),
    ],
  );
}

/// A setting's label and help, with its control beside them; under them
/// when the row is too narrow for both (a phone).
class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.title, required this.control, this.help});

  final String title;
  final String? help;

  /// The control, told whether it sits under the label (with the row's
  /// whole width) or beside it.
  final Widget Function({required bool below}) control;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final help = this.help;
      if (WindowSize.ofWidth(constraints.maxWidth).atLeast(WindowSize.medium)) {
        return ListTile(
          title: Text(title),
          subtitle: help == null ? null : Text(help),
          trailing: control(below: false),
        );
      }
      final theme = Theme.of(context);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.bodyLarge),
            if (help != null)
              Text(
                help,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 8),
            control(below: true),
          ],
        ),
      );
    },
  );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );
}

/// A labelled dropdown.
class _Choice<T> extends StatelessWidget {
  const _Choice({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.help,
  });

  final String label;
  final String? help;
  final T value;
  final List<(T, String)> options;
  final Future<void> Function(T value) onChanged;

  @override
  Widget build(BuildContext context) => _SettingTile(
    title: label,
    help: help,
    control: ({required below}) => DropdownButton<T>(
      // Under the label: as wide as the row, long options cut short.
      isExpanded: below,
      value: options.any((o) => o.$1 == value) ? value : options.first.$1,
      onChanged: (v) => onChanged(v as T),
      items: [
        for (final (v, text) in options)
          DropdownMenuItem<T>(
            value: v,
            child: Text(text, overflow: TextOverflow.ellipsis),
          ),
      ],
    ),
  );
}

/// A language picker: hundreds of languages, so it filters as you type
/// ("port" → Portuguese).
class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.help,
  });

  static const width = 260.0;

  final String label;
  final String? help;
  final String value;
  final List<(String, String)> options;
  final Future<void> Function(String value) onChanged;

  @override
  Widget build(BuildContext context) => _SettingTile(
    title: label,
    help: help,
    control: ({required below}) => DropdownMenu<String>(
      // Rebuilt when the value or the list changes, so the field shows it.
      key: ValueKey((value, options.length)),
      width: width,
      initialSelection: options.any((o) => o.$1 == value)
          ? value
          : options.first.$1,
      enableFilter: true,
      requestFocusOnTap: true,
      menuHeight: 320,
      onSelected: (v) {
        if (v != null && v != value) unawaited(onChanged(v));
      },
      dropdownMenuEntries: [
        for (final (code, name) in options)
          DropdownMenuEntry<String>(value: code, label: name),
      ],
    ),
  );
}
