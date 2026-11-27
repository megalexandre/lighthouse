import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I hold the word {'first'}
///
/// A finger held on it, then lifted: the word is selected.
Future<void> iHoldTheWord(WidgetTester tester, String word) async {
  await tester.longPressAt(wordOnPage(tester, word).center);
  await tester.pumpAndSettle();
}
