import 'package:flutter_test/flutter_test.dart';

/// Usage: Then I see a button {'Unmute (M)'}
///
/// By what it says under the mouse.
Future<void> iSeeAButton(WidgetTester tester, String tooltip) async {
  expect(find.byTooltip(tooltip), findsWidgets);
}
