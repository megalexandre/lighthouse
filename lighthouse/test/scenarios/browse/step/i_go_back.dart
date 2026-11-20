import 'package:flutter_test/flutter_test.dart';

/// Usage: When I go back
///
/// The back arrow in the top bar.
Future<void> iGoBack(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}
