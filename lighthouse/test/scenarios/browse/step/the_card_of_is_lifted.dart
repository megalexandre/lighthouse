import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the card of {'Test Movie'} is lifted
///
/// It grows a little, as Lanterna's cards do under the mouse.
Future<void> theCardOfIsLifted(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  expect(cardScale(tester, name), 1.04);
}
