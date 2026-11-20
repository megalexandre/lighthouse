import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given my audio language on the server is {'por'}
Future<void> myAudioLanguageOnTheServerIs(
  WidgetTester tester,
  String code,
) async {
  app.settings.config = app.settings.config.copyWith(
    audioLanguagePreference: code,
  );
}
