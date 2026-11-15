import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/culture_dto.dart';
import '../../../api/models/user_configuration.dart';
import '../../../core/failure.dart';
import '../../../widgets/error_retry.dart';
import '../../auth/application/auth_controller.dart';
import '../application/settings_providers.dart';
import '../data/settings_repository.dart';

/// Playback settings: quality (this device), audio and subtitle languages,
/// when subtitles show, next episode autoplay (the user's, on the server).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const qualityField = Key('settings.quality');
  static const audioLanguageField = Key('settings.audioLanguage');
  static const subtitleLanguageField = Key('settings.subtitleLanguage');
  static const subtitleModeField = Key('settings.subtitleMode');
  static const autoplaySwitch = Key('settings.autoplay');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).value?.session;
    final config = ref.watch(userConfigurationProvider);
    final quality = ref.watch(maxStreamingBitrateProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const _Heading('Playback'),
          _Choice<int?>(
            key: qualityField,
            label: 'Maximum quality',
            help:
                'On this device. Above it the server converts the video '
                'down; lower it on a slow network.',
            value: quality,
            options: qualityOptions,
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
          if (session != null) ...[
            const _Heading('Account'),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(session.userName),
              subtitle: Text(session.server.name),
            ),
          ],
        ],
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
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languages = ref.watch(languagesProvider).value ?? const [];
    final options = languageOptions(languages, [
      ?config.audioLanguagePreference,
      ?config.subtitleLanguagePreference,
    ]);
    return Column(
      children: [
        _LanguageChoice(
          key: SettingsScreen.audioLanguageField,
          label: 'Audio language',
          help:
              'Played when a file has it. Saved for your account on '
              'the server.',
          value: config.audioLanguagePreference ?? noLanguage,
          options: [(noLanguage, "The file's default"), ...options],
          onChanged: (v) =>
              _save(context, ref, (c) => c.change(audioLanguage: v)),
        ),
        _LanguageChoice(
          key: SettingsScreen.subtitleLanguageField,
          label: 'Subtitle language',
          value: config.subtitleLanguagePreference ?? noLanguage,
          options: [(noLanguage, 'Any'), ...options],
          onChanged: (v) =>
              _save(context, ref, (c) => c.change(subtitleLanguage: v)),
        ),
        _Choice<SubtitlePlaybackMode>(
          key: SettingsScreen.subtitleModeField,
          label: 'Show subtitles',
          value: config.subtitleMode,
          options: const [
            (SubtitlePlaybackMode.defaultMode, 'When the file says so'),
            (
              SubtitlePlaybackMode.smart,
              'When the audio is in another language',
            ),
            (SubtitlePlaybackMode.always, 'Always'),
            (SubtitlePlaybackMode.onlyForced, 'Only forced subtitles'),
            (SubtitlePlaybackMode.none, 'Never'),
          ],
          onChanged: (v) =>
              _save(context, ref, (c) => c.change(subtitleMode: v)),
        ),
        SwitchListTile(
          key: SettingsScreen.autoplaySwitch,
          title: const Text('Play the next episode automatically'),
          value: config.enableNextEpisodeAutoPlay,
          onChanged: (v) =>
              _save(context, ref, (c) => c.change(nextEpisodeAutoPlay: v)),
        ),
      ],
    );
  }
}

/// (code, name) for the language pickers, one per code: the server lists
/// regional variants under the same code ("Portuguese (Brazil)" is "por"
/// too), and only the code is saved, so the plain name stands for all.
/// Codes in [keep] that the server list lacks stay selectable as their
/// code.
List<(String, String)> languageOptions(
  List<CultureDto> cultures,
  List<String> keep,
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
  return [for (final e in options.entries) (e.key, e.value)];
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
  Widget build(BuildContext context) => ListTile(
    title: Text(label),
    subtitle: help == null ? null : Text(help!),
    trailing: DropdownButton<T>(
      value: options.any((o) => o.$1 == value) ? value : options.first.$1,
      onChanged: (v) => onChanged(v as T),
      items: [
        for (final (v, text) in options)
          DropdownMenuItem<T>(value: v, child: Text(text)),
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
  Widget build(BuildContext context) => ListTile(
    title: Text(label),
    subtitle: help == null ? null : Text(help!),
    trailing: DropdownMenu<String>(
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
