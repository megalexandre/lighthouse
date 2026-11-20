import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server keeps my audio language as {'por'}
Future<void> theServerKeepsMyAudioLanguageAs(
  WidgetTester tester,
  String code,
) async {
  expect(app.settings.config.audioLanguagePreference, code);
}
