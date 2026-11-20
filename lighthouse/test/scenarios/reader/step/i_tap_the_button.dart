import 'package:flutter_test/flutter_test.dart';

/// Usage: When I tap the button {'Remove bookmark'}
///
/// By what it says under the mouse.
Future<void> iTapTheButton(WidgetTester tester, String tooltip) async {
  final button = find.byTooltip(tooltip);
  // The display settings scroll on a small window.
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}
