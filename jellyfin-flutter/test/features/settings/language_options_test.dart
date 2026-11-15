import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/culture_dto.dart';
import 'package:jellyfin_flutter/features/settings/presentation/settings_screen.dart';

void main() {
  CultureDto c(String name, String code) =>
      CultureDto(displayName: name, threeLetterIsoLanguageName: code);

  test('one entry per code, the plain name (as the 12.4 server lists)', () {
    final options = languageOptions([
      c('English', 'eng'),
      c('Portuguese', 'por'),
      c('Portuguese (Brazil)', 'por'),
      c('Portuguese (Portugal)', 'por'),
    ], const []);
    expect(options, [('eng', 'English'), ('por', 'Portuguese')]);
  });

  test('the plain name wins whatever the order', () {
    final options = languageOptions([
      c('Portuguese (Portugal)', 'por'),
      c('Portuguese', 'por'),
    ], const []);
    expect(options, [('por', 'Portuguese')]);
  });

  test('a saved code the server does not list stays choosable', () {
    final options = languageOptions([c('English', 'eng')], ['xyz', '']);
    expect(options, [('eng', 'English'), ('xyz', 'xyz')]);
  });
}
