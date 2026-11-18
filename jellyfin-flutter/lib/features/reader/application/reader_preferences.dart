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

/// How the user likes to read, on this device, for every book: the theme
/// (any book), and the type an EPUB is set in.
@immutable
class ReaderPreferences {
  const ReaderPreferences({
    this.theme = ReaderTheme.light,
    this.fontSize = defaultFontSize,
    this.sansSerif = false,
  });

  /// The sizes offered, smallest to largest.
  static const fontSizes = [14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 28.0, 32.0];
  static const defaultFontSize = 18.0;

  final ReaderTheme theme;
  final double fontSize;
  final bool sansSerif;

  EpubTypography get typography => EpubTypography(
    fontSize: fontSize,
    fontFamily: sansSerif ? 'sans-serif' : 'serif',
  );

  /// One size step bigger ([steps] > 0) or smaller, within [fontSizes].
  ReaderPreferences resized(int steps) {
    var index = fontSizes.indexOf(fontSize);
    if (index < 0) index = fontSizes.indexOf(defaultFontSize);
    return copyWith(
      fontSize: fontSizes[(index + steps).clamp(0, fontSizes.length - 1)],
    );
  }

  ReaderPreferences copyWith({
    ReaderTheme? theme,
    double? fontSize,
    bool? sansSerif,
  }) => ReaderPreferences(
    theme: theme ?? this.theme,
    fontSize: fontSize ?? this.fontSize,
    sansSerif: sansSerif ?? this.sansSerif,
  );

  Map<String, Object> toJson() => {
    'theme': theme.name,
    'fontSize': fontSize,
    'sansSerif': sansSerif,
  };

  /// Unknown or broken values fall back to the defaults, one by one.
  factory ReaderPreferences.fromJson(Map<String, dynamic> json) {
    final size = json['fontSize'];
    return ReaderPreferences(
      theme: ReaderTheme.values.asNameMap()[json['theme']] ?? ReaderTheme.light,
      fontSize: size is num && fontSizes.contains(size.toDouble())
          ? size.toDouble()
          : defaultFontSize,
      sansSerif: json['sansSerif'] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReaderPreferences &&
      other.theme == theme &&
      other.fontSize == fontSize &&
      other.sansSerif == sansSerif;

  @override
  int get hashCode => Object.hash(theme, fontSize, sansSerif);
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
