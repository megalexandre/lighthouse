import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../../../l10n/l10n.dart';
import '../data/book_document.dart';
import '../data/book_repository.dart';
import '../data/epub/epub_layout.dart';

/// The reader's colours: the page ([colors]), and the desk around it.
enum ReaderTheme {
  light(
    PageColors(paper: Color(0xFFFFFFFF), ink: Color(0xFF202124)),
    desk: Color(0xFF303134),
  ),
  sepia(
    PageColors(paper: Color(0xFFF4ECD8), ink: Color(0xFF4B3A2A)),
    desk: Color(0xFF3A332A),
  ),
  dark(
    PageColors(paper: Color(0xFF1F1F1F), ink: Color(0xFFD5D5D5)),
    desk: Color(0xFF0B0B0B),
  );

  const ReaderTheme(this.colors, {required this.desk});

  final PageColors colors;
  final Color desk;

  /// The light theme keeps a PDF exactly as it is.
  PageColors get pageColors => this == light ? PageColors.plain : colors;

  String label(AppLocalizations l10n) => switch (this) {
    light => l10n.readerLight,
    sepia => l10n.readerSepia,
    dark => l10n.readerDark,
  };
}

/// The faces offered for an EPUB, all bundled (assets/fonts/README.md).
enum ReaderFont {
  /// The default: a humanist sans, the free face closest to Amazon Ember.
  notoSans('Noto Sans'),

  /// A serif made for reading on screens.
  literata('Literata'),

  /// Made for low vision: letters that cannot be mistaken for each other.
  atkinson('Atkinson Hyperlegible');

  const ReaderFont(this.family);

  /// The family in pubspec.yaml; also its name in the menu (a proper name,
  /// the same in every language).
  final String family;
}

/// One page at a time, two side by side (an open book), or two when the
/// window is wide enough for them ([auto]).
enum PageLayout { auto, single, double }

/// How the user likes to read, on this device, for every book: the theme
/// and the page layout (any book), and how an EPUB's type is set.
///
/// The type settings are steps, as the display sheet offers them: size and
/// line height in percent of the defaults, letter spacing in steps of
/// [letterSpacingStep] of an em.
@immutable
class ReaderPreferences {
  const ReaderPreferences({
    this.theme = ReaderTheme.light,
    this.font = ReaderFont.notoSans,
    this.fontScale = 100,
    this.lineSpacing = 100,
    this.letterSpacing = 0,
    this.justify = true,
    this.layout = PageLayout.auto,
  });

  /// The steps offered, smallest to largest.
  static const fontScales = [80, 90, 100, 110, 120, 135, 150, 175];
  static const lineSpacings = [80, 90, 100, 115, 130, 150];
  static const letterSpacings = [0, 1, 2, 3, 4, 5];

  /// What 100% is: the size and line height the type was set in before
  /// these settings existed.
  static const baseFontSize = 18.0;
  static const baseLineHeight = 1.45;

  /// One step of [letterSpacing], in ems.
  static const letterSpacingStep = 0.025;

  final ReaderTheme theme;
  final ReaderFont font;
  final int fontScale;
  final int lineSpacing;
  final int letterSpacing;

  /// Justified, or set flush left (ragged right).
  final bool justify;
  final PageLayout layout;

  double get fontSize => baseFontSize * fontScale / 100;

  EpubTypography get typography => EpubTypography(
    fontSize: fontSize,
    lineHeight: baseLineHeight * lineSpacing / 100,
    fontFamily: font.family,
    letterSpacing: fontSize * letterSpacing * letterSpacingStep,
    justify: justify,
  );

  /// [value] moved [steps] along [steps] list [values] (clamped at its
  /// ends); a value not in it starts from [fallback].
  static int step(List<int> values, int value, int steps, int fallback) {
    var index = values.indexOf(value);
    if (index < 0) index = values.indexOf(fallback);
    return values[(index + steps).clamp(0, values.length - 1)];
  }

  /// One size step bigger ([steps] > 0) or smaller, within [fontScales].
  ReaderPreferences resized(int steps) =>
      copyWith(fontScale: step(fontScales, fontScale, steps, 100));

  ReaderPreferences copyWith({
    ReaderTheme? theme,
    ReaderFont? font,
    int? fontScale,
    int? lineSpacing,
    int? letterSpacing,
    bool? justify,
    PageLayout? layout,
  }) => ReaderPreferences(
    theme: theme ?? this.theme,
    font: font ?? this.font,
    fontScale: fontScale ?? this.fontScale,
    lineSpacing: lineSpacing ?? this.lineSpacing,
    letterSpacing: letterSpacing ?? this.letterSpacing,
    justify: justify ?? this.justify,
    layout: layout ?? this.layout,
  );

  Map<String, Object> toJson() => {
    'theme': theme.name,
    'font': font.name,
    'fontScale': fontScale,
    'lineSpacing': lineSpacing,
    'letterSpacing': letterSpacing,
    'justify': justify,
    'layout': layout.name,
  };

  /// Unknown or broken values fall back to the defaults, one by one. A
  /// size stored the old way (`fontSize` in pixels) becomes the nearest
  /// step; the old serif / sans choice is not kept (both were the system's
  /// generic faces, which the bundled ones replace).
  factory ReaderPreferences.fromJson(Map<String, dynamic> json) {
    int pick(String key, List<int> values, int fallback) {
      final v = json[key];
      return v is int && values.contains(v) ? v : fallback;
    }

    var fontScale = pick('fontScale', fontScales, 100);
    final oldSize = json['fontSize'];
    if (!json.containsKey('fontScale') && oldSize is num && oldSize > 0) {
      final percent = oldSize / baseFontSize * 100;
      fontScale = fontScales.reduce(
        (a, b) => (a - percent).abs() <= (b - percent).abs() ? a : b,
      );
    }
    return ReaderPreferences(
      theme: ReaderTheme.values.asNameMap()[json['theme']] ?? ReaderTheme.light,
      font: ReaderFont.values.asNameMap()[json['font']] ?? ReaderFont.notoSans,
      fontScale: fontScale,
      lineSpacing: pick('lineSpacing', lineSpacings, 100),
      letterSpacing: pick('letterSpacing', letterSpacings, 0),
      justify: json['justify'] != false,
      layout: PageLayout.values.asNameMap()[json['layout']] ?? PageLayout.auto,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReaderPreferences &&
      other.theme == theme &&
      other.font == font &&
      other.fontScale == fontScale &&
      other.lineSpacing == lineSpacing &&
      other.letterSpacing == letterSpacing &&
      other.justify == justify &&
      other.layout == layout;

  @override
  int get hashCode => Object.hash(
    theme,
    font,
    fontScale,
    lineSpacing,
    letterSpacing,
    justify,
    layout,
  );
}

final readerPreferencesProvider =
    AsyncNotifierProvider<ReaderPreferencesController, ReaderPreferences>(
      ReaderPreferencesController.new,
    );

/// The [ReaderPreferences], kept in the reader's store.
class ReaderPreferencesController extends AsyncNotifier<ReaderPreferences> {
  static const _key = 'preferences';

  @override
  Future<ReaderPreferences> build() async {
    final raw = await ref.read(readerStoreProvider).read(_key);
    if (raw == null) return const ReaderPreferences();
    try {
      return ReaderPreferences.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object catch (e) {
      log.warning('reader', 'preferences unreadable, using defaults', e);
      return const ReaderPreferences();
    }
  }

  /// Shows [preferences] at once; a failure to store them only means they
  /// are not remembered next time.
  Future<void> set(ReaderPreferences preferences) async {
    if (state.value == preferences) return;
    state = AsyncData(preferences);
    try {
      await ref
          .read(readerStoreProvider)
          .write(_key, jsonEncode(preferences.toJson()));
    } on Failure catch (e) {
      log.warning('reader', 'could not store the preferences', e);
    }
  }
}
