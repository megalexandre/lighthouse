import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: When I pull home down
///
/// From the top, to load it again.
Future<void> iPullHomeDown(WidgetTester tester) async {
  await tester.fling(find.byType(ListView).first, const Offset(0, 400), 1000);
  await tester.pumpAndSettle();
}
