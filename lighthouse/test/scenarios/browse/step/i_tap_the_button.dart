import 'package:flutter_test/flutter_test.dart';

/// Usage: When I tap the button {'Mark as watched'}
///
/// By what it says under the mouse.
Future<void> iTapTheButton(WidgetTester tester, String tooltip) async {
  await tester.tap(find.byTooltip(tooltip));
  await tester.pumpAndSettle();
}
