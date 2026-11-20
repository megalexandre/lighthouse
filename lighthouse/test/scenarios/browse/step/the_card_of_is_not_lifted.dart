import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the card of {'Test Movie'} is not lifted
Future<void> theCardOfIsNotLifted(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  expect(cardScale(tester, name), 1);
}
