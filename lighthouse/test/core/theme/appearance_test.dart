import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/theme/appearance.dart';
import 'package:lighthouse/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('the language is stored only once chosen, by its code', () {
    expect(const Appearance().toJson(), isNot(contains('language')));
    const english = Appearance(language: AppLanguage.en);
    expect(english.toJson()['language'], 'en');
    expect(Appearance.fromJson(english.toJson()), english);
    expect(
      Appearance.fromJson(const {'language': 'pt_BR'}).language,
      AppLanguage.ptBR,
    );
  });

  test('an unknown language counts as none chosen (the default)', () {
    expect(Appearance.fromJson(const {'language': 'xx'}).language, isNull);
  });

  test('changing the mode keeps the language', () {
    const english = Appearance(language: AppLanguage.en);
    expect(english.copyWith(mode: ThemeMode.light).language, AppLanguage.en);
  });
}
