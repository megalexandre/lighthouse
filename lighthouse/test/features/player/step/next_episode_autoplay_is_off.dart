import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given next episode autoplay is off
///
/// The user's setting on the server.
Future<void> nextEpisodeAutoplayIsOff(WidgetTester tester) async {
  app.settings.config = app.settings.config.copyWith(
    enableNextEpisodeAutoPlay: false,
  );
}
