import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: When I scroll to the end
///
/// Of the grid, letting pages load on the way.
Future<void> iScrollToTheEnd(WidgetTester tester) async {
  for (var i = 0; i < 50; i++) {
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
    await tester.pumpAndSettle();
  }
}
