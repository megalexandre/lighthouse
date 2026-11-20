import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then the contents are closed
Future<void> theContentsAreClosed(WidgetTester tester) async {
  expect(find.byType(Drawer), findsNothing);
}
