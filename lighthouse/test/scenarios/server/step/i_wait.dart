import 'package:flutter_test/flutter_test.dart';

/// Usage: When I wait {'2 seconds'}
///
/// Time passes, for the app's tries to run.
Future<void> iWait(WidgetTester tester, String time) async {
  final seconds = int.parse(time.split(' ').first);
  await tester.pump(Duration(seconds: seconds));
  await tester.pumpAndSettle();
}
