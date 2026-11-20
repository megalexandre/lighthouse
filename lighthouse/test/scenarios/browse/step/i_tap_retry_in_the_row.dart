import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/widgets/error_retry.dart';

import 'world.dart';

/// Usage: And I tap Retry in the {'Latest in Movies'} row
Future<void> iTapRetryInTheRow(WidgetTester tester, String title) async {
  await tester.tap(
    find.descendant(
      of: await rowOnScreen(tester, title),
      matching: find.byKey(ErrorRetry.retryButton),
    ),
  );
  await tester.pumpAndSettle();
}
