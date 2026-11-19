import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/theme/app_tokens.dart';
import 'package:lighthouse/core/theme/design_tokens.dart';
import 'package:lighthouse/core/theme/theme_builder.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final lanterna = DesignTokens.parse(
    File('assets/themes/lanterna.json').readAsStringSync(),
  );

  for (final brightness in Brightness.values) {
    test('${brightness.name}: the scheme is the tokens', () {
      final mode = lanterna.modeFor(brightness);
      final theme = buildTheme(lanterna, brightness);
      final scheme = theme.colorScheme;
      expect(scheme.brightness, brightness);
      expect(scheme.primary, lanterna.color('accent', mode));
      expect(scheme.onPrimary, lanterna.color('accent-ink', mode));
      expect(scheme.surface, lanterna.color('bg-100', mode));
      expect(scheme.surfaceContainer, lanterna.color('bg-200', mode));
      expect(scheme.onSurface, lanterna.color('ink', mode));
      expect(scheme.onSurfaceVariant, lanterna.color('ink-muted', mode));
      expect(scheme.outline, lanterna.color('line', mode));
      expect(scheme.error, lanterna.color('danger', mode));
      expect(theme.scaffoldBackgroundColor, lanterna.color('bg-100', mode));
    });
  }

  test('the player colours are the same in both modes', () {
    final dark = buildTheme(lanterna, Brightness.dark).extension<AppTokens>()!;
    final light = buildTheme(
      lanterna,
      Brightness.light,
    ).extension<AppTokens>()!;
    expect(light.osdInk, dark.osdInk);
    expect(light.osdScrim, dark.osdScrim);
    expect(light.osdAccent, const Color(0xFF00A4DC));
  });

  test('type and shapes come from the tokens', () {
    final theme = buildTheme(lanterna, Brightness.dark);
    final text = theme.textTheme;
    expect(text.headlineLarge!.fontSize, 40);
    expect(text.headlineLarge!.fontWeight, FontWeight.w700);
    expect(text.headlineLarge!.fontFamily, 'Noto Sans');
    expect(text.titleLarge!.fontSize, 22);
    expect(text.bodyMedium!.fontSize, 14);
    expect(text.bodySmall!.fontSize, 12);
    final tokens = theme.extension<AppTokens>()!;
    expect(tokens.timecode.fontFamily, 'Noto Sans Mono');
    expect(tokens.timecode.fontWeight, FontWeight.w500);
    expect(tokens.space(4), 16);
    expect(tokens.radiusMd, 8);
    expect(tokens.shadowMenu.single.blurRadius, 24);
    final card = theme.cardTheme.shape! as RoundedRectangleBorder;
    expect(card.borderRadius, BorderRadius.circular(8));
  });
}
