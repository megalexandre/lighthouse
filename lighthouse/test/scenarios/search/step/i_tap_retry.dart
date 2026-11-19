import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/widgets/error_retry.dart';

/// Usage: And I tap Retry
Future<void> iTapRetry(WidgetTester tester) async {
  await tester.tap(find.byKey(ErrorRetry.retryButton));
  await tester.pumpAndSettle();
}
