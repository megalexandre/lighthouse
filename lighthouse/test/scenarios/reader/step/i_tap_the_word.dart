import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I tap the word {'first'}
Future<void> iTapTheWord(WidgetTester tester, String word) async {
  await tester.tapAt(wordOnPage(tester, word).center);
  await tester.pumpAndSettle();
}
