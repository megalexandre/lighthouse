import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the server is told the {'Portuguese'} subtitle
Future<void> theServerIsToldTheSubtitle(
  WidgetTester tester,
  String language,
) async {
  expect(lastReport().subtitleStreamIndex, subtitleIndex[language]);
}
