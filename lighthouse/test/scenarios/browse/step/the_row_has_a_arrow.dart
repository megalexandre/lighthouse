import 'package:flutter_test/flutter_test.dart';

import 'arrows.dart';

/// Usage: Then the {'Latest in Movies'} row has a {'next'} arrow
Future<void> theRowHasAArrow(
  WidgetTester tester,
  String row,
  String way,
) async {
  expect(arrowOf(row, way), findsOneWidget);
}
