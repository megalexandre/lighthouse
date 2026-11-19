import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/l10n.dart';
import '../application/reader_preferences.dart';
import 'reader_screen.dart';

/// The theme, for any book; the type size and face, for an EPUB.
class DisplaySheet extends ConsumerWidget {
  const DisplaySheet({super.key, required this.reflowable});

  final bool reflowable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs =
        ref.watch(readerPreferencesProvider).value ?? const ReaderPreferences();
    // From the preferences at the time of the tap, not of this build: two
    // quick taps on "larger" are two steps.
    void update(ReaderPreferences Function(ReaderPreferences) change) {
      final now =
          ref.read(readerPreferencesProvider).value ??
          const ReaderPreferences();
      unawaited(ref.read(readerPreferencesProvider.notifier).set(change(now)));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<ReaderTheme>(
            showSelectedIcon: false,
            segments: [
              for (final theme in ReaderTheme.values)
                ButtonSegment(
                  value: theme,
                  label: Text(
                    theme.label(context.l10n),
                    key: ReaderScreen.themeChoice(theme),
                  ),
                ),
            ],
            selected: {prefs.theme},
            onSelectionChanged: (s) =>
                update((p) => p.copyWith(theme: s.single)),
          ),
          if (reflowable) ...[
            const SizedBox(height: 16),
            _FontSize(
              size: prefs.fontSize,
              onStep: (step) => update((p) => p.resized(step)),
            ),
            const SizedBox(height: 16),
            _Typeface(
              sans: prefs.sansSerif,
              onChanged: (sans) => update((p) => p.copyWith(sansSerif: sans)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Smaller, the size in pixels, larger; each button off at its end of
/// [ReaderPreferences.fontSizes].
class _FontSize extends StatelessWidget {
  const _FontSize({required this.size, required this.onStep});

  final double size;

  /// -1 smaller, 1 larger.
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    final sizes = ReaderPreferences.fontSizes;
    return Row(
      children: [
        IconButton.outlined(
          key: ReaderScreen.fontSmaller,
          tooltip: context.l10n.smallerText,
          icon: const Icon(Icons.text_decrease),
          onPressed: size > sizes.first ? () => onStep(-1) : null,
        ),
        Expanded(
          child: Text(
            context.l10n.fontSizePx(size.round()),
            key: ReaderScreen.fontSize,
            textAlign: TextAlign.center,
          ),
        ),
        IconButton.outlined(
          key: ReaderScreen.fontBigger,
          tooltip: context.l10n.largerText,
          icon: const Icon(Icons.text_increase),
          onPressed: size < sizes.last ? () => onStep(1) : null,
        ),
      ],
    );
  }
}

/// Serif or sans, each label in its own face.
class _Typeface extends StatelessWidget {
  const _Typeface({required this.sans, required this.onChanged});

  final bool sans;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<bool>(
    showSelectedIcon: false,
    segments: [
      ButtonSegment(
        value: false,
        label: Text(
          context.l10n.serif,
          key: ReaderScreen.typefaceChoice(sans: false),
          style: const TextStyle(fontFamily: 'serif'),
        ),
      ),
      ButtonSegment(
        value: true,
        label: Text(
          context.l10n.sans,
          key: ReaderScreen.typefaceChoice(sans: true),
          style: const TextStyle(fontFamily: 'sans-serif'),
        ),
      ),
    ],
    selected: {sans},
    onSelectionChanged: (s) => onChanged(s.single),
  );
}
