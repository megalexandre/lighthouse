import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/l10n.dart';
import '../application/reader_preferences.dart';
import 'reader_screen.dart';

/// The display options: the theme and the page layout, for any book; how
/// the type is set (face, size, line height, letter spacing, alignment),
/// for an EPUB. One titled section each.
class DisplaySheet extends ConsumerWidget {
  const DisplaySheet({super.key, required this.reflowable});

  final bool reflowable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs =
        ref.watch(readerPreferencesProvider).value ?? const ReaderPreferences();
    final l10n = context.l10n;
    // From the preferences at the time of the tap, not of this build: two
    // quick taps on "larger" are two steps.
    void update(ReaderPreferences Function(ReaderPreferences) change) {
      final now =
          ref.read(readerPreferencesProvider).value ??
          const ReaderPreferences();
      unawaited(ref.read(readerPreferencesProvider.notifier).set(change(now)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Section(
            title: l10n.readerTheme,
            child: SegmentedButton<ReaderTheme>(
              showSelectedIcon: false,
              segments: [
                for (final theme in ReaderTheme.values)
                  ButtonSegment(
                    value: theme,
                    label: Text(
                      theme.label(l10n),
                      key: ReaderScreen.themeChoice(theme),
                    ),
                  ),
              ],
              selected: {prefs.theme},
              onSelectionChanged: (s) =>
                  update((p) => p.copyWith(theme: s.single)),
            ),
          ),
          if (reflowable) ...[
            _Section(
              title: l10n.readerFont,
              child: _FontMenu(
                font: prefs.font,
                onChanged: (font) => update((p) => p.copyWith(font: font)),
              ),
            ),
            _Section(
              title: l10n.fontSizeLabel,
              child: _Stepper(
                values: ReaderPreferences.fontScales,
                value: prefs.fontScale,
                label: l10n.percent(prefs.fontScale),
                valueKey: ReaderScreen.fontSize,
                smaller: (
                  key: ReaderScreen.fontSmaller,
                  icon: Icons.text_decrease,
                  tooltip: l10n.smallerText,
                ),
                bigger: (
                  key: ReaderScreen.fontBigger,
                  icon: Icons.text_increase,
                  tooltip: l10n.largerText,
                ),
                onStep: (step) => update((p) => p.resized(step)),
              ),
            ),
            _Section(
              title: l10n.lineHeight,
              child: _Stepper(
                values: ReaderPreferences.lineSpacings,
                value: prefs.lineSpacing,
                label: l10n.percent(prefs.lineSpacing),
                valueKey: ReaderScreen.lineSpacing,
                smaller: (
                  key: ReaderScreen.lineSpacingSmaller,
                  icon: Icons.unfold_less,
                  tooltip: l10n.lessLineHeight,
                ),
                bigger: (
                  key: ReaderScreen.lineSpacingBigger,
                  icon: Icons.unfold_more,
                  tooltip: l10n.moreLineHeight,
                ),
                onStep: (step) => update(
                  (p) => p.copyWith(
                    lineSpacing: ReaderPreferences.step(
                      ReaderPreferences.lineSpacings,
                      p.lineSpacing,
                      step,
                      100,
                    ),
                  ),
                ),
              ),
            ),
            _Section(
              title: l10n.letterSpacing,
              child: _Stepper(
                values: ReaderPreferences.letterSpacings,
                value: prefs.letterSpacing,
                label: '${prefs.letterSpacing}',
                valueKey: ReaderScreen.letterSpacing,
                smaller: (
                  key: ReaderScreen.letterSpacingSmaller,
                  icon: Icons.compress,
                  tooltip: l10n.lessLetterSpacing,
                ),
                bigger: (
                  key: ReaderScreen.letterSpacingBigger,
                  icon: Icons.expand,
                  tooltip: l10n.moreLetterSpacing,
                ),
                // The icons are vertical; letters spread sideways.
                quarterTurns: 1,
                onStep: (step) => update(
                  (p) => p.copyWith(
                    letterSpacing: ReaderPreferences.step(
                      ReaderPreferences.letterSpacings,
                      p.letterSpacing,
                      step,
                      0,
                    ),
                  ),
                ),
              ),
            ),
            _Section(
              title: l10n.justify,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: false,
                      tooltip: l10n.alignLeft,
                      icon: Icon(
                        Icons.format_align_left,
                        key: ReaderScreen.justifyChoice(justify: false),
                      ),
                    ),
                    ButtonSegment(
                      value: true,
                      tooltip: l10n.alignJustified,
                      icon: Icon(
                        Icons.format_align_justify,
                        key: ReaderScreen.justifyChoice(justify: true),
                      ),
                    ),
                  ],
                  selected: {prefs.justify},
                  onSelectionChanged: (s) =>
                      update((p) => p.copyWith(justify: s.single)),
                ),
              ),
            ),
          ],
          _Section(
            title: l10n.pageLayout,
            child: SegmentedButton<PageLayout>(
              showSelectedIcon: false,
              segments: [
                for (final (layout, icon, label) in [
                  (PageLayout.auto, Icons.auto_awesome, l10n.layoutAuto),
                  (PageLayout.single, Icons.crop_portrait, l10n.layoutSingle),
                  (PageLayout.double, Icons.menu_book, l10n.layoutDouble),
                ])
                  ButtonSegment(
                    value: layout,
                    icon: Icon(icon),
                    label: Text(label, key: ReaderScreen.layoutChoice(layout)),
                  ),
              ],
              selected: {prefs.layout},
              onSelectionChanged: (s) =>
                  update((p) => p.copyWith(layout: s.single)),
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled block of the sheet.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

/// The faces, each name in its own face.
class _FontMenu extends StatelessWidget {
  const _FontMenu({required this.font, required this.onChanged});

  final ReaderFont font;
  final ValueChanged<ReaderFont> onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => DropdownMenu<ReaderFont>(
      key: ReaderScreen.fontMenu,
      width: constraints.maxWidth,
      initialSelection: font,
      requestFocusOnTap: false,
      textStyle: TextStyle(fontFamily: font.family),
      dropdownMenuEntries: [
        for (final f in ReaderFont.values)
          DropdownMenuEntry(
            value: f,
            label: f.family,
            style: MenuItemButton.styleFrom(
              textStyle: TextStyle(fontFamily: f.family),
            ),
          ),
      ],
      onSelected: (f) {
        if (f != null) onChanged(f);
      },
    ),
  );
}

typedef _StepButton = ({Key key, IconData icon, String tooltip});

/// Smaller, the value, larger; each button off at its end of [values].
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.values,
    required this.value,
    required this.label,
    required this.valueKey,
    required this.smaller,
    required this.bigger,
    required this.onStep,
    this.quarterTurns = 0,
  });

  final List<int> values;
  final int value;
  final String label;
  final Key valueKey;
  final _StepButton smaller;
  final _StepButton bigger;

  /// -1 smaller, 1 larger.
  final ValueChanged<int> onStep;
  final int quarterTurns;

  @override
  Widget build(BuildContext context) {
    Widget button(_StepButton b, {required bool enabled, required int step}) =>
        IconButton.outlined(
          key: b.key,
          tooltip: b.tooltip,
          icon: RotatedBox(quarterTurns: quarterTurns, child: Icon(b.icon)),
          onPressed: enabled ? () => onStep(step) : null,
        );
    return Row(
      children: [
        button(smaller, enabled: value > values.first, step: -1),
        Expanded(
          child: Text(label, key: valueKey, textAlign: TextAlign.center),
        ),
        button(bigger, enabled: value < values.last, step: 1),
      ],
    );
  }
}
