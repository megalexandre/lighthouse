import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the server suggests the {'English'} subtitle
Future<void> theServerSuggestsTheSubtitle(
  WidgetTester tester,
  String language,
) async {
  app.playback.defaultSubtitle = subtitleIndex[language];
}
