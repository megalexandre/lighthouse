import 'package:flutter_test/flutter_test.dart';

import 'arrows.dart';

/// Usage: When I tap the {'next'} arrow of the {'Latest in Movies'} row
Future<void> iTapTheArrowOfTheRow(
  WidgetTester tester,
  String way,
  String row,
) async {
  await tester.tap(arrowOf(row, way));
  await tester.pumpAndSettle();
}
