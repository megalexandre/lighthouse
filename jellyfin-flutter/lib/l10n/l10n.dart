import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'generated/app_localizations.dart';

export 'failure_text.dart';
export 'generated/app_localizations.dart';

/// The languages of the app's texts (lib/l10n/app_*.arb). Brazilian
/// Portuguese is the default; English is the template the others are
/// translated from.
enum AppLanguage {
  ptBR(Locale('pt', 'BR'), 'Português (Brasil)'),
  en(Locale('en'), 'English');

  const AppLanguage(this.locale, this.name);

  final Locale locale;

  /// In the language itself, as language pickers show it.
  final String name;

  /// As stored: `pt_BR`, `en`.
  String get code => locale.toString();

  static AppLanguage? fromCode(Object? code) =>
      values.where((l) => l.code == code).firstOrNull;
}

/// The language until the user picks one. Tests set English, which their
/// texts are written in.
final defaultLanguageProvider = Provider<AppLanguage>((_) => AppLanguage.ptBR);

/// What MaterialApp needs for the app's texts and Material's own (the back
/// button's tooltip, text selection, date pickers...).
const appLocalizationsDelegates = <LocalizationsDelegate<Object?>>[
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

extension AppLocalizationsContext on BuildContext {
  /// The app's texts in the current language.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
