import 'package:material_ui/material_ui.dart';

import 'design_tokens.dart';

/// What a theme gives beyond Material's [ColorScheme] and [TextTheme]:
/// the player's fixed colours (`osd-*`), status colours, spacing, radii,
/// shadows and the timecode style. Widgets read it with [context.tokens].
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.bg000,
    required this.accent2,
    required this.success,
    required this.warning,
    required this.osdSurface,
    required this.osdHover,
    required this.osdScrim,
    required this.osdInk,
    required this.osdInkMuted,
    required this.osdTrack,
    required this.osdBuffer,
    required this.osdAccent,
    required this.osdAccentInk,
    required this.spacing,
    required this.radius,
    required this.shadows,
    required this.timecode,
    required this.overline,
    this.components = const ThemeComponents(),
  });

  /// The deepest background: behind the video, letterbox.
  final Color bg000;

  /// The rare second accent (favourites, collections).
  final Color accent2;
  final Color success;
  final Color warning;

  /// Over the video: always dark, whatever the mode.
  final Color osdSurface;
  final Color osdHover;

  /// The end colour of the gradient behind the player's controls.
  final Color osdScrim;
  final Color osdInk;
  final Color osdInkMuted;
  final Color osdTrack;
  final Color osdBuffer;
  final Color osdAccent;
  final Color osdAccentInk;

  /// `space-1` … `space-12`, `radius-sm` … `radius-pill`, by token name.
  final Map<String, double> spacing;
  final Map<String, double> radius;
  final Map<String, List<BoxShadow>> shadows;

  /// Elapsed / remaining time in the player (fixed-width digits).
  final TextStyle timecode;

  /// Short capitals: "UP NEXT", badges.
  final TextStyle overline;

  /// The forms of components the theme picks (top bar, home carousel, row
  /// arrows).
  final ThemeComponents components;

  /// `space-<step>` (4 px steps), e.g. `space(4)` = 16.
  double space(int step) => spacing['space-$step'] ?? step * 4.0;

  double get radiusSm => radius['radius-sm'] ?? 4;
  double get radiusMd => radius['radius-md'] ?? 8;
  double get radiusLg => radius['radius-lg'] ?? 12;
  double get radiusPill => radius['radius-pill'] ?? 999;

  List<BoxShadow> get shadowPoster => shadows['shadow-poster'] ?? const [];
  List<BoxShadow> get shadowMenu => shadows['shadow-menu'] ?? const [];

  /// The gradient behind the player's controls, from [osdScrim] at [from]
  /// to clear.
  LinearGradient scrim({required AlignmentGeometry from}) => LinearGradient(
    begin: from,
    end: from == Alignment.bottomCenter
        ? Alignment.topCenter
        : Alignment.bottomCenter,
    colors: [osdScrim, osdScrim.withValues(alpha: 0)],
  );

  /// Over a picture (the home carousel, the bar on top of it) the colours
  /// are the player's, dark whatever the mode, so white text stays
  /// readable: this is the opaque dark that the shades over a picture fade
  /// from.
  Color get mediaShade => osdScrim.withValues(alpha: 1);

  /// The bright button over a picture (Play in the carousel): [osdInk],
  /// with dark ink on it, and a shade of that ink on hover.
  Color get mediaButtonInk => osdAccentInk;
  Color get mediaButtonHover =>
      Color.alphaBlend(osdAccentInk.withValues(alpha: 0.09), osdInk);

  @override
  AppTokens copyWith() => this;

  /// Themes are swapped, not animated between.
  @override
  AppTokens lerp(AppTokens? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

extension AppTokensContext on BuildContext {
  /// The current theme's [AppTokens].
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
