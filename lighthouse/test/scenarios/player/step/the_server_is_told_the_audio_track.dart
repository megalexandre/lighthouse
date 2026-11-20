import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the server is told the {'Portuguese'} audio track
Future<void> theServerIsToldTheAudioTrack(
  WidgetTester tester,
  String language,
) async {
  expect(lastReport().audioStreamIndex, audioIndex[language]);
}
