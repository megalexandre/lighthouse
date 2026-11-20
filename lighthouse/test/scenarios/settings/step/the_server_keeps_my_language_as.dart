import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server keeps my {'audio'} language as {'por'}
///
/// The 'audio' or 'subtitle' one.
Future<void> theServerKeepsMyLanguageAs(
  WidgetTester tester,
  String field,
  String code,
) async {
  final config = app.settings.config;
  expect(
    field == 'audio'
        ? config.audioLanguagePreference
        : config.subtitleLanguagePreference,
    code,
  );
}
