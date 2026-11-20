import 'package:flutter_test/flutter_test.dart';

import 'subtitle_modes.dart';
import 'world.dart';

/// Usage: Then the server keeps my subtitles as {'Never'}
Future<void> theServerKeepsMySubtitlesAs(
  WidgetTester tester,
  String mode,
) async {
  expect(app.settings.config.subtitleMode, subtitleModes[mode]);
}
