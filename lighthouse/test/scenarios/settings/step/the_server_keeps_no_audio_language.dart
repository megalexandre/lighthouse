import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server keeps no audio language
///
/// Each file's own default plays.
Future<void> theServerKeepsNoAudioLanguage(WidgetTester tester) async {
  expect(app.settings.config.audioLanguagePreference, '');
}
