import 'package:flutter_test/flutter_test.dart';

/// Usage: When I wait {3} seconds
Future<void> iWaitSeconds(WidgetTester tester, int seconds) async {
  for (var i = 0; i < seconds; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}
