import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/culture_dto.dart';
import 'package:jellyfin_flutter/features/settings/presentation/settings_screen.dart';
import 'package:jellyfin_flutter/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  CultureDto c(String name, String code) =>
      CultureDto(displayName: name, threeLetterIsoLanguageName: code);

  test('one entry per code, the plain name (as the 12.4 server lists)', () {
    final options = languageOptions(
      [
        c('English', 'eng'),
        c('Portuguese', 'por'),
        c('Portuguese (Brazil)', 'por'),
        c('Portuguese (Portugal)', 'por'),
      ],
      const [],
      en,
    );
    expect(options, [('eng', 'English'), ('por', 'Portuguese')]);
  });

  test('the plain name wins whatever the order', () {
    final options = languageOptions(
      [c('Portuguese (Portugal)', 'por'), c('Portuguese', 'por')],
      const [],
      en,
    );
    expect(options, [('por', 'Portuguese')]);
  });

  test('a saved code the server does not list stays choosable', () {
    final options = languageOptions([c('English', 'eng')], ['xyz', ''], en);
    expect(options, [('eng', 'English'), ('xyz', 'xyz')]);
  });

  test('named in the app language and sorted by that name', () {
    final pt = lookupAppLocalizations(const Locale('pt', 'BR'));
    final options = languageOptions(
      [
        c('Portuguese', 'por'),
        c('Arabic', 'ara'),
        c('German', 'ger'),
        c('English', 'eng'),
      ],
      const [],
      pt,
    );
    expect(options, [
      ('ger', 'Alemão'),
      ('ara', 'Árabe'),
      ('eng', 'Inglês'),
      ('por', 'Português'),
    ]);
  });
}
