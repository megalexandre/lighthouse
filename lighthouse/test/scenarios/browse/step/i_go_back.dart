import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: When I go back
///
/// The back arrow in the top bar.
Future<void> iGoBack(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}
