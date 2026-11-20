import 'package:flutter_test/flutter_test.dart';

import 'arrows.dart';

/// Usage: And the {'Latest in Movies'} row has no {'previous'} arrow
///
/// Nothing more that way.
Future<void> theRowHasNoArrow(
  WidgetTester tester,
  String row,
  String way,
) async {
  expect(arrowOf(row, way), findsNothing);
}
