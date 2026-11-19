import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/theme/design_tokens.dart';

void main() {
  final lanternaSource = File('assets/themes/lanterna.json').readAsStringSync();
  final lanterna = DesignTokens.parse(lanternaSource);

  /// A theme file: Lanterna with [change] applied to its JSON.
  String variant(void Function(Map<String, dynamic> json) change) {
    final json = jsonDecode(lanternaSource) as Map<String, dynamic>;
    change(json);
    return jsonEncode(json);
  }

  List<dynamic> colorTokens(Map<String, dynamic> json) =>
      (json['color'] as Map)['tokens'] as List;

  test('Lanterna, as exported from Claude Design, reads whole', () {
    expect(lanterna.name, 'Lanterna');
    expect(lanterna.warnings, isEmpty);
    expect(lanterna.modes, ['dark', 'light']);
    expect(lanterna.hasLightAndDark, isTrue);
    expect(lanterna.color('accent', 'dark'), const Color(0xFF00A4DC));
    expect(lanterna.color('accent', 'light'), const Color(0xFF0077A8));
    // One value for every mode: the player is always dark.
    expect(
      lanterna.color('osd-scrim', 'light'),
      const Color.fromARGB(184, 0, 0, 0),
    );
    expect(lanterna.families['sans'], ['Noto Sans', 'Segoe UI', 'Roboto']);
    expect(lanterna.families['mono']!.first, 'Noto Sans Mono');
    final hero = lanterna.textStyles['hero-title']!;
    expect(hero.fontSize, 40);
    expect(hero.height, closeTo(46 / 40, 1e-9));
    expect(hero.fontWeight, 700);
    expect(hero.letterSpacing, closeTo(-0.4, 1e-9));
    expect(lanterna.textStyles['timecode']!.family, 'mono');
    expect(lanterna.spacing['space-4'], 16);
    expect(lanterna.radius['radius-pill'], 999);
    final [menu] = lanterna.shadows['shadow-menu']!;
    expect(menu.offset, const Offset(0, 8));
    expect(menu.blur, 24);
    expect(menu.color, const Color.fromARGB(128, 0, 0, 0));
  });

  test('colours: hex of every length, rgb(a) both ways, aliases', () {
    expect(parseCssColor('#0af'), const Color(0xFF00AAFF));
    expect(parseCssColor('#0af8'), const Color(0x8800AAFF));
    expect(parseCssColor('#00A4DC'), const Color(0xFF00A4DC));
    expect(parseCssColor('#00a4dc80'), const Color(0x8000A4DC));
    expect(parseCssColor('rgba(255, 0, 0, 0.5)'), const Color(0x80FF0000));
    expect(parseCssColor('rgb(0 128 255 / 50%)'), const Color(0x800080FF));
    for (final bad in [
      'red',
      'transparent',
      '#12345',
      'rgb(1,2)',
      'hsl(0 0 0)',
    ]) {
      expect(parseCssColor(bad), isNull, reason: bad);
    }

    final tokens = DesignTokens.parse(
      variant((json) {
        colorTokens(json)
          ..add({'name': 'brand', 'value': '{accent}'})
          ..add({'name': 'loop-a', 'value': '{loop-b}'})
          ..add({'name': 'loop-b', 'value': '{loop-a}'});
      }),
      fallback: lanterna,
    );
    expect(tokens.color('brand', 'light'), tokens.color('accent', 'light'));
    expect(tokens.colorNames, isNot(contains('loop-a')));
    expect(tokens.warnings.join('\n'), contains('alias loop'));
  });

  test('what is missing or unreadable comes from the fallback, with a '
      'warning; nothing else changes', () {
    final tokens = DesignTokens.parse(
      variant((json) {
        final colors = colorTokens(json)
          ..removeWhere((t) => (t as Map)['name'] == 'accent');
        (colors.firstWhere((t) => (t as Map)['name'] == 'ink')
            as Map)['value'] = {
          'dark': 'not a colour',
          'light': '#000000',
        };
        (json['spacing'] as Map)['tokens'] = <Object>[];
        json['name'] = 'Mine';
      }),
      fallback: lanterna,
    );
    expect(tokens.name, 'Mine');
    expect(tokens.color('accent', 'dark'), lanterna.color('accent', 'dark'));
    expect(tokens.color('accent', 'light'), lanterna.color('accent', 'light'));
    expect(tokens.color('ink', 'dark'), lanterna.color('ink', 'dark'));
    expect(tokens.color('ink', 'light'), const Color(0xFF000000));
    expect(tokens.spacing['space-4'], 16);
    final warnings = tokens.warnings.join('\n');
    expect(warnings, contains('colour "accent" is missing'));
    expect(warnings, contains('"not a colour"'));
    expect(warnings, contains('spacing "space-4" is missing'));
  });

  test('without a fallback (the built-in theme) a gap is an error', () {
    expect(
      () =>
          DesignTokens.parse(variant((json) => colorTokens(json).removeAt(0))),
      throwsFormatException,
    );
  });

  test('not a tokens file at all: refused', () {
    expect(
      () => DesignTokens.parse('{not json', fallback: lanterna),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('not JSON'),
        ),
      ),
    );
    expect(
      () => DesignTokens.parse('[1, 2]', fallback: lanterna),
      throwsFormatException,
    );
  });

  test('one mode only: used for dark and light', () {
    final tokens = DesignTokens.parse(
      variant((json) {
        (json['color'] as Map)['themes'] = [
          {'id': 'night', 'name': 'Night'},
        ];
        for (final t in colorTokens(json)) {
          final value = (t as Map)['value'];
          if (value is Map) t['value'] = value['dark'];
        }
      }),
      fallback: lanterna,
    );
    expect(tokens.hasLightAndDark, isFalse);
    expect(tokens.modeFor(Brightness.light), 'night');
    expect(tokens.warnings, isEmpty);
  });

  test('lengths and shadows', () {
    expect(parseLength('12px'), 12);
    expect(parseLength('1.5rem'), 24);
    expect(parseLength('0.5em', em: 20), 10);
    expect(parseLength(8), 8);
    expect(parseLength('10%'), isNull);
    final layers = parseCssShadow(
      '0 1px 2px rgba(0, 0, 0, 0.3), 2px 4px 8px 1px #00000080',
    )!;
    expect(layers, hasLength(2));
    expect(layers[1].spread, 1);
    expect(parseCssShadow('inset 0 1px 2px #000'), isNull);
    expect(parseCssShadow('0 1px'), isNull);
  });
}
