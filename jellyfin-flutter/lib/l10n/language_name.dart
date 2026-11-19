import 'generated/app_localizations.dart';
import 'language_names.dart';

/// The language [code] stands for (ISO 639-2/B or /T, or ISO 639-1; a
/// region such as "pt-BR" is ignored), named in [l10n]'s language: "por" is
/// "Português" in Portuguese, "Portuguese" in English.
///
/// Null without a code, for "und" and the other codes that are not a
/// language, and for one the table lacks: the caller falls back to what
/// the server says.
String? languageName(String? code, AppLocalizations l10n) {
  final main = _mainCode(code);
  if (main == null) return null;
  final names =
      languageNames[l10n.localeName.split('_').first] ?? languageNames['en']!;
  return names[main];
}

/// Whether [text] is only the name of [code]'s language, in any of the
/// app's languages (a track titled "English" or "Português").
bool namesLanguage(String text, String? code) {
  final main = _mainCode(code);
  if (main == null) return false;
  final t = text.trim().toLowerCase();
  return languageNames.values.any((names) => names[main]?.toLowerCase() == t);
}

String? _mainCode(String? code) {
  if (code == null) return null;
  final c = code.trim().toLowerCase().split(RegExp('[-_]')).first;
  if (c.isEmpty) return null;
  return languageAliases[c] ?? c;
}
