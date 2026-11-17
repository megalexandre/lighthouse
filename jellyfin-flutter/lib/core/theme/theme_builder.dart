import 'package:material_ui/material_ui.dart';

import 'app_tokens.dart';
import 'design_tokens.dart';

/// The app's [ThemeData] for [tokens] in [brightness]. Which token paints
/// what is in docs/THEMES.md; keep the two in step.
ThemeData buildTheme(DesignTokens tokens, Brightness brightness) {
  final mode = tokens.modeFor(brightness);
  Color c(String name) => tokens.color(name, mode);

  final bg000 = c('bg-000');
  final bg100 = c('bg-100');
  final bg200 = c('bg-200');
  final bg300 = c('bg-300');
  final ink = c('ink');
  final inkMuted = c('ink-muted');
  final line = c('line');
  final accent = c('accent');
  final accentInk = c('accent-ink');
  final accent2 = c('accent-2');
  final danger = c('danger');

  Color on(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
      ? Colors.white
      : Colors.black;
  Color tint(Color color, double amount) =>
      Color.alphaBlend(color.withValues(alpha: amount), bg200);

  final scheme = ColorScheme(
    brightness: brightness,
    primary: accent,
    onPrimary: accentInk,
    primaryContainer: tint(accent, 0.28),
    onPrimaryContainer: ink,
    secondary: accent2,
    onSecondary: on(accent2),
    // Selected chips and segments, the navigation indicator: a quiet
    // accent, so the one primary action stays the loudest thing.
    secondaryContainer: tint(accent, 0.24),
    onSecondaryContainer: ink,
    tertiary: accent2,
    onTertiary: on(accent2),
    tertiaryContainer: tint(accent2, 0.24),
    onTertiaryContainer: ink,
    error: danger,
    onError: on(danger),
    errorContainer: tint(danger, 0.28),
    onErrorContainer: ink,
    surface: bg100,
    onSurface: ink,
    onSurfaceVariant: inkMuted,
    surfaceDim: bg000,
    surfaceBright: bg300,
    surfaceContainerLowest: bg000,
    surfaceContainerLow: bg100,
    surfaceContainer: bg200,
    surfaceContainerHigh: bg300,
    surfaceContainerHighest: bg300,
    outline: line,
    outlineVariant: line,
    inverseSurface: ink,
    onInverseSurface: bg100,
    inversePrimary: c('accent-hover'),
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );

  final sans = tokens.families['sans']!;
  TextStyle style(String name, {FontWeight? weight}) {
    final t = tokens.textStyles[name]!;
    final family = tokens.families[t.family] ?? sans;
    return TextStyle(
      fontFamily: family.first,
      fontFamilyFallback: family.skip(1).toList(),
      fontSize: t.fontSize,
      height: t.height,
      fontWeight: weight ?? FontWeight.values[t.fontWeight ~/ 100 - 1],
      letterSpacing: t.letterSpacing,
      color: ink,
    );
  }

  final hero = style('hero-title');
  final section = style('section-title');
  final title = style('title');
  final body = style('body');
  final caption = style('caption');
  final textTheme = TextTheme(
    displayLarge: hero,
    displayMedium: hero,
    displaySmall: hero,
    headlineLarge: hero,
    headlineMedium: section,
    headlineSmall: section,
    titleLarge: section,
    titleMedium: title,
    titleSmall: title,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: caption.copyWith(color: inkMuted),
    labelLarge: body.copyWith(fontWeight: FontWeight.w600),
    labelMedium: caption.copyWith(fontWeight: FontWeight.w600),
    labelSmall: style('overline'),
  );

  final radii = tokens.radius;
  final radiusMd = BorderRadius.circular(radii['radius-md']!);
  final radiusLg = BorderRadius.circular(radii['radius-lg']!);
  List<BoxShadow> shadows(String name) => [
    for (final s in tokens.shadows[name]!)
      BoxShadow(
        offset: s.offset,
        blurRadius: s.blur,
        spreadRadius: s.spread,
        color: s.color,
      ),
  ];

  // Controls are at least 44 px high: comfortable with a pointer, a
  // finger or a remote.
  final buttonShape = WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: radiusMd),
  );
  const buttonSize = WidgetStatePropertyAll(Size(64, 44));

  return ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    textTheme: textTheme,
    fontFamily: sans.first,
    fontFamilyFallback: sans.skip(1).toList(),
    scaffoldBackgroundColor: bg100,
    canvasColor: bg100,
    dividerColor: line,
    focusColor: accent.withValues(alpha: 0.24),
    hoverColor: ink.withValues(alpha: 0.06),
    appBarTheme: AppBarTheme(
      backgroundColor: bg100,
      foregroundColor: ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: section,
    ),
    cardTheme: CardThemeData(
      color: bg200,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: radiusMd),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(shape: buttonShape, minimumSize: buttonSize),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: buttonShape,
        minimumSize: buttonSize,
        side: WidgetStatePropertyAll(BorderSide(color: line)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(shape: buttonShape, minimumSize: buttonSize),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(shape: buttonShape, minimumSize: buttonSize),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: bg200,
      shape: RoundedRectangleBorder(borderRadius: radiusLg),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: bg200,
      shape: RoundedRectangleBorder(borderRadius: radiusLg),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: bg200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: radiusLg.topLeft),
      ),
    ),
    drawerTheme: DrawerThemeData(backgroundColor: bg200),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: bg200,
      border: OutlineInputBorder(borderRadius: radiusMd),
      enabledBorder: OutlineInputBorder(
        borderRadius: radiusMd,
        borderSide: BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radiusMd,
        borderSide: BorderSide(color: accent, width: 2),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: accent,
      inactiveTrackColor: line,
      thumbColor: accent,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: accent,
      linearTrackColor: line,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: bg300,
      contentTextStyle: body,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: radiusMd),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: bg300, borderRadius: radiusMd),
      textStyle: caption,
    ),
    extensions: [
      AppTokens(
        bg000: bg000,
        accent2: accent2,
        success: c('success'),
        warning: c('warning'),
        osdSurface: c('osd-surface'),
        osdHover: c('osd-hover'),
        osdScrim: c('osd-scrim'),
        osdInk: c('osd-ink'),
        osdInkMuted: c('osd-ink-muted'),
        osdTrack: c('osd-track'),
        osdBuffer: c('osd-buffer'),
        osdAccent: c('osd-accent'),
        osdAccentInk: c('osd-accent-ink'),
        spacing: tokens.spacing,
        radius: radii,
        shadows: {for (final name in tokens.shadows.keys) name: shadows(name)},
        timecode: style('timecode'),
        overline: style('overline'),
      ),
    ],
  );
}
