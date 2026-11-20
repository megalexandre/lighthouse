import 'package:flutter_test/flutter_test.dart';

import 'subtitle_modes.dart';
import 'world.dart';

/// Usage: And my subtitles on the server are {'Always'}
Future<void> mySubtitlesOnTheServerAre(WidgetTester tester, String mode) async {
  app.settings.config = app.settings.config.copyWith(
    subtitleMode: subtitleModes[mode]!,
  );
}
