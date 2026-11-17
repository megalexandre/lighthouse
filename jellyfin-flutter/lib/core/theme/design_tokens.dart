import 'dart:convert';
import 'dart:ui';

/// A design system's tokens, as Claude Design exports them
/// (`project/tokens.json`): the app's theme file. See docs/THEMES.md.
///
/// Read leniently: a value the app cannot read, or a token the app needs
/// that the file lacks, takes the [fallback]'s (the built-in Lanterna) and
/// is listed in [warnings]; only a file that is not a tokens object at all
/// is refused ([FormatException]).
class DesignTokens {
  DesignTokens._({
    required this.name,
    required this.modes,
    required this._colors,
    required this.families,
    required this.textStyles,
    required this.spacing,
    required this.radius,
    required this.shadows,
    required this.warnings,
  });

  /// The colour tokens the app paints with (docs/THEMES.md says where).
  static const requiredColors = [
    'bg-000', 'bg-100', 'bg-200', 'bg-300', 'line', 'ink', 'ink-muted', //
    'accent', 'accent-hover', 'accent-ink', 'accent-2',
    'success', 'warning', 'danger',
    'osd-surface', 'osd-hover', 'osd-scrim', 'osd-ink', 'osd-ink-muted',
    'osd-track', 'osd-buffer', 'osd-accent', 'osd-accent-ink',
  ];

  static const requiredTextStyles = [
    'hero-title', 'section-title', 'title', 'body', 'caption', 'overline', //
    'timecode',
  ];

  static const requiredSpacing = [
    'space-1', 'space-2', 'space-3', 'space-4', 'space-6', 'space-8', //
    'space-12',
  ];

  static const requiredRadius = [
    'radius-sm', 'radius-md', 'radius-lg', 'radius-pill', //
  ];

  static const requiredShadows = ['shadow-poster', 'shadow-menu'];

  /// The theme's name, as the file gives it.
  final String name;

  /// The colour modes, in the file's order (the first is the default):
  /// ids such as "dark" and "light".
  final List<String> modes;

  final Map<String, Map<String, Color>> _colors;

  /// Font family keys ("sans", "mono") to the families to ask for, in
  /// order (the first is the face, the rest fallbacks); CSS generic names
  /// (system-ui, sans-serif...) are left out.
  final Map<String, List<String>> families;
  final Map<String, TokenTextStyle> textStyles;
  final Map<String, double> spacing;
  final Map<String, double> radius;
  final Map<String, List<TokenShadow>> shadows;

  /// What could not be read and what was missing, for the person who
  /// wrote the file.
  final List<String> warnings;

  /// The mode used for [brightness]: the one whose id says so ("dark",
  /// "light"), else the first.
  String modeFor(Brightness brightness) {
    final word = brightness == Brightness.dark ? 'dark' : 'light';
    return modes.firstWhere(
      (m) => m.toLowerCase().contains(word),
      orElse: () => modes.first,
    );
  }

  /// Whether the file has a mode for each brightness.
  bool get hasLightAndDark =>
      modeFor(Brightness.dark) != modeFor(Brightness.light);

  /// Colour token [name] in [mode]. Throws [StateError] for one the theme
  /// does not have (every [requiredColors] one it has).
  Color color(String name, String mode) {
    final color = _colors[mode]?[name] ?? _colors[modes.first]?[name];
    if (color == null) throw StateError('No colour token "$name"');
    return color;
  }

  /// The colour token names the theme has.
  Iterable<String> get colorNames => _colors[modes.first]?.keys ?? const [];

  /// Reads a tokens file ([source], JSON). [fallback] fills in what it
  /// lacks; without one (the built-in theme) everything required must be
  /// there.
  factory DesignTokens.parse(String source, {DesignTokens? fallback}) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException catch (e) {
      throw FormatException('not JSON: ${e.message}');
    }
    if (json is! Map<String, dynamic>) {
      throw const FormatException('not a tokens object');
    }
    return _Reader(json, fallback).read();
  }
}

/// A text style from the file: [family] is a key of
/// [DesignTokens.families].
class TokenTextStyle {
  const TokenTextStyle({
    required this.family,
    required this.fontSize,
    required this.height,
    required this.fontWeight,
    this.letterSpacing = 0,
  });

  final String family;
  final double fontSize;

  /// Line height as a multiple of [fontSize] (what Flutter takes).
  final double height;
  final int fontWeight;

  /// In logical pixels.
  final double letterSpacing;
}

/// One shadow of a token (a token can stack several).
class TokenShadow {
  const TokenShadow({
    required this.offset,
    required this.blur,
    required this.spread,
    required this.color,
  });

  final Offset offset;
  final double blur;
  final double spread;
  final Color color;
}

class _Reader {
  _Reader(this.json, this.fallback);

  final Map<String, dynamic> json;
  final DesignTokens? fallback;
  final warnings = <String>[];

  DesignTokens read() {
    final name = switch (json['name']) {
      final String n when n.trim().isNotEmpty => n.trim(),
      _ => fallback == null ? 'Theme' : 'Untitled theme',
    };
    final modes = _modes();
    final colors = _readColors(modes);
    final families = _families();
    final textStyles = _textStyles(families);
    final spacing = _lengths('spacing', DesignTokens.requiredSpacing);
    final radius = _lengths('radius', DesignTokens.requiredRadius);
    final shadows = _shadows();
    return DesignTokens._(
      name: name,
      modes: modes,
      colors: colors,
      families: families,
      textStyles: textStyles,
      spacing: spacing,
      radius: radius,
      shadows: shadows,
      warnings: warnings,
    );
  }

  /// [what] is missing from the file: the fallback's, or an error when
  /// there is none.
  T _missing<T>(String what, T? Function(DesignTokens) fromFallback) {
    final fb = fallback;
    final value = fb == null ? null : fromFallback(fb);
    if (value == null) throw FormatException('$what is missing');
    warnings.add('$what is missing: using ${fb!.name}\'s');
    return value;
  }

  List<Map<String, dynamic>> _list(Object? value) => [
    if (value is List)
      for (final item in value)
        if (item is Map<String, dynamic>) item,
  ];

  Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : const {};

  // --- Colours --------------------------------------------------------------

  List<String> _modes() {
    final ids = [
      for (final theme in _list(_map(json['color'])['themes']))
        if (theme['id'] case final String id when id.isNotEmpty) id,
    ];
    return ids.isEmpty ? ['default'] : ids;
  }

  Map<String, Map<String, Color>> _readColors(List<String> modes) {
    final raw = <String, Object?>{
      for (final token in _list(_map(json['color'])['tokens']))
        if (token['name'] case final String name) name: token['value'],
    };
    // A token missing a mode's value takes the first mode's.
    String? rawIn(String token, String mode) => switch (raw[token]) {
      final String s => s,
      final Map<String, dynamic> m => switch (m[mode] ?? m[modes.first]) {
        final String s => s,
        _ => null,
      },
      _ => null,
    };

    final result = <String, Map<String, Color>>{};
    for (final mode in modes) {
      final colors = result[mode] = {};
      Color? resolve(String token, Set<String> seen) {
        if (colors[token] case final c?) return c;
        final value = rawIn(token, mode);
        if (value == null) return null;
        final alias = RegExp(r'^\{([^{}]+)\}$').firstMatch(value.trim());
        if (alias != null) {
          final target = alias.group(1)!;
          if (!seen.add(target)) {
            warnings.add('colour "$token": alias loop through "$target"');
            return null;
          }
          return resolve(target, seen);
        }
        return parseCssColor(value);
      }

      for (final token in raw.keys) {
        final color = resolve(token, {token});
        if (color != null) {
          colors[token] = color;
        } else if (mode == modes.first || raw[token] is Map) {
          warnings.add(
            'colour "$token" (${modes.length > 1 ? mode : 'all modes'}): '
            '"${rawIn(token, mode)}" is not a colour the app reads',
          );
        }
      }
    }

    // What the app needs and the file does not give.
    for (final token in DesignTokens.requiredColors) {
      for (final mode in modes) {
        if (result[mode]!.containsKey(token)) continue;
        final fb = fallback;
        if (fb == null) {
          throw FormatException('colour "$token" is missing');
        }
        result[mode]![token] = fb.color(
          token,
          fb.modeFor(_brightnessOf(mode, modes)),
        );
        if (mode == modes.first) {
          warnings.add('colour "$token" is missing: using ${fb.name}\'s');
        }
      }
    }
    return result;
  }

  static Brightness _brightnessOf(String mode, List<String> modes) {
    final id = mode.toLowerCase();
    if (id.contains('light')) return Brightness.light;
    if (id.contains('dark')) return Brightness.dark;
    return Brightness.dark;
  }

  // --- Type -----------------------------------------------------------------

  static const _generic = {
    'system-ui', '-apple-system', 'blinkmacsystemfont', 'ui-sans-serif', //
    'ui-serif', 'ui-monospace', 'ui-rounded', 'sans-serif', 'serif',
    'monospace', 'cursive', 'fantasy', 'emoji', 'math',
  };

  Map<String, List<String>> _families() {
    final result = <String, List<String>>{};
    final raw = _map(_map(json['type'])['families']);
    for (final MapEntry(:key, :value) in raw.entries) {
      if (value is! String) continue;
      final names = [
        for (final part in value.split(','))
          if (part.trim().replaceAll(RegExp('^["\']|["\']\$'), '')
              case final name
              when name.isNotEmpty && !_generic.contains(name.toLowerCase()))
            name,
      ];
      if (names.isNotEmpty) result[key] = names;
    }
    for (final key in ['sans', 'mono']) {
      if (result.containsKey(key)) continue;
      result[key] = _missing('font family "$key"', (fb) => fb.families[key]);
    }
    return result;
  }

  Map<String, TokenTextStyle> _textStyles(Map<String, List<String>> families) {
    final result = <String, TokenTextStyle>{};
    for (final group in _list(_map(json['type'])['groups'])) {
      final family = group['family'] is String
          ? group['family'] as String
          : 'sans';
      if (!families.containsKey(family)) {
        warnings.add('type group "${group['name']}": no family "$family"');
      }
      for (final style in _list(group['styles'])) {
        final name = style['name'];
        if (name is! String) continue;
        final size = parseLength(style['fontSize']);
        if (size == null || size <= 0) {
          warnings.add('text style "$name": fontSize unreadable');
          continue;
        }
        final lineHeight = style['lineHeight'];
        final height = switch (lineHeight) {
          num n => n.toDouble(), // Unitless: a multiple.
          String s when double.tryParse(s.trim()) != null => double.parse(s),
          _ => (parseLength(lineHeight, em: size) ?? size * 1.4) / size,
        };
        result[name] = TokenTextStyle(
          family: families.containsKey(family) ? family : 'sans',
          fontSize: size,
          height: height,
          fontWeight: _weight(style['fontWeight']),
          letterSpacing: parseLength(style['letterSpacing'], em: size) ?? 0,
        );
      }
    }
    for (final name in DesignTokens.requiredTextStyles) {
      if (result.containsKey(name)) continue;
      result[name] = _missing(
        'text style "$name"',
        (fb) => fb.textStyles[name],
      );
    }
    return result;
  }

  static int _weight(Object? value) {
    final n = switch (value) {
      num n => n.toInt(),
      String s => int.tryParse(s.trim().split(' ').first) ?? 400,
      _ => 400,
    };
    return ((n / 100).round() * 100).clamp(100, 900);
  }

  // --- Lengths and shadows --------------------------------------------------

  Map<String, double> _lengths(String family, List<String> required) {
    final result = <String, double>{};
    for (final token in _list(_map(json[family])['tokens'])) {
      final name = token['name'];
      if (name is! String) continue;
      final value = parseLength(token['value']);
      if (value == null) {
        warnings.add('$family "$name": "${token['value']}" unreadable');
      } else {
        result[name] = value;
      }
    }
    for (final name in required) {
      if (result.containsKey(name)) continue;
      result[name] = _missing(
        '$family "$name"',
        (fb) => (family == 'spacing' ? fb.spacing : fb.radius)[name],
      );
    }
    return result;
  }

  Map<String, List<TokenShadow>> _shadows() {
    final result = <String, List<TokenShadow>>{};
    for (final token in _list(_map(json['shadow'])['tokens'])) {
      final name = token['name'];
      if (name is! String) continue;
      final value = token['value'];
      final shadows = value is String ? parseCssShadow(value) : null;
      if (shadows == null) {
        warnings.add('shadow "$name": "$value" unreadable');
      } else {
        result[name] = shadows;
      }
    }
    for (final name in DesignTokens.requiredShadows) {
      if (result.containsKey(name)) continue;
      result[name] = _missing('shadow "$name"', (fb) => fb.shadows[name]);
    }
    return result;
  }
}

/// A CSS length as logical pixels: `12px`, `1.5rem` (16 px each), `0.5em`
/// (of [em]), or a bare number. Null when unreadable.
double? parseLength(Object? value, {double em = 16}) {
  if (value is num) return value.toDouble();
  if (value is! String) return null;
  final match = RegExp(r'^\s*(-?\d*\.?\d+)\s*(px|rem|em)?\s*$')
      .firstMatch(value);
  if (match == null) return null;
  final n = double.parse(match.group(1)!);
  return switch (match.group(2)) {
    'rem' => n * 16,
    'em' => n * em,
    _ => n,
  };
}

/// A CSS colour: `#rgb`, `#rgba`, `#rrggbb`, `#rrggbbaa`, `rgb()` or
/// `rgba()` (commas, or spaces and `/ alpha`). Null when unreadable.
Color? parseCssColor(String value) {
  final v = value.trim().toLowerCase();
  if (v.startsWith('#')) {
    var hex = v.substring(1);
    if (!RegExp(r'^[0-9a-f]+$').hasMatch(hex)) return null;
    if (hex.length == 3 || hex.length == 4) {
      hex = hex.split('').map((c) => '$c$c').join();
    }
    if (hex.length == 6) hex = '${hex}ff';
    if (hex.length != 8) return null;
    final rgba = int.parse(hex, radix: 16);
    return Color.fromARGB(
      rgba & 0xFF,
      rgba >> 24 & 0xFF,
      rgba >> 16 & 0xFF,
      rgba >> 8 & 0xFF,
    );
  }
  final fn = RegExp(r'^rgba?\((.*)\)$').firstMatch(v);
  if (fn == null) return null;
  final parts = fn
      .group(1)!
      .replaceAll('/', ' ')
      .split(RegExp(r'[\s,]+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.length != 3 && parts.length != 4) return null;
  double? channel(String p) => p.endsWith('%')
      ? double.tryParse(p.substring(0, p.length - 1)).let((n) => n * 2.55)
      : double.tryParse(p);
  final rgb = parts.take(3).map(channel).toList();
  if (rgb.any((c) => c == null || c < 0 || c > 255)) return null;
  var alpha = 1.0;
  if (parts.length == 4) {
    final a = parts[3];
    final parsed = a.endsWith('%')
        ? double.tryParse(a.substring(0, a.length - 1)).let((n) => n / 100)
        : double.tryParse(a);
    if (parsed == null || parsed < 0 || parsed > 1) return null;
    alpha = parsed;
  }
  return Color.fromARGB(
    (alpha * 255).round(),
    rgb[0]!.round(),
    rgb[1]!.round(),
    rgb[2]!.round(),
  );
}

/// A CSS box-shadow (`x y [blur [spread]] colour`, several separated by
/// commas). Null when unreadable; `inset` shadows are not supported.
List<TokenShadow>? parseCssShadow(String value) {
  // Commas inside rgba(...) do not separate shadows.
  final layers = <String>[];
  var depth = 0;
  var start = 0;
  for (var i = 0; i < value.length; i++) {
    final c = value[i];
    if (c == '(') depth++;
    if (c == ')') depth--;
    if (c == ',' && depth == 0) {
      layers.add(value.substring(start, i));
      start = i + 1;
    }
  }
  layers.add(value.substring(start));

  final result = <TokenShadow>[];
  for (final layer in layers) {
    final colorMatch = RegExp(r'(rgba?\([^)]*\)|#[0-9a-fA-F]+)')
        .firstMatch(layer);
    final color = colorMatch == null
        ? null
        : parseCssColor(colorMatch.group(0)!);
    final rest = colorMatch == null
        ? layer
        : layer.replaceRange(colorMatch.start, colorMatch.end, ' ');
    if (color == null || rest.contains('inset')) return null;
    final lengths = rest
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .map(parseLength)
        .toList();
    if (lengths.length < 2 || lengths.length > 4 || lengths.contains(null)) {
      return null;
    }
    result.add(
      TokenShadow(
        offset: Offset(lengths[0]!, lengths[1]!),
        blur: lengths.length > 2 ? lengths[2]! : 0,
        spread: lengths.length > 3 ? lengths[3]! : 0,
        color: color,
      ),
    );
  }
  return result;
}

extension<T extends Object> on T? {
  R? let<R>(R Function(T) f) {
    final self = this;
    return self == null ? null : f(self);
  }
}
