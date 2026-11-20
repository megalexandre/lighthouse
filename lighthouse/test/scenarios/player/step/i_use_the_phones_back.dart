import 'package:flutter_test/flutter_test.dart';

/// Usage: When I use the phone's Back
///
/// Android's Back (the button or the edge swipe), as the system sends it
/// to the app.
Future<void> iUseThePhonesBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}
