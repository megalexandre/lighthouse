import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/server/presentation/connection_banner.dart';

/// Usage: And I tap Retry now
///
/// On the banner.
Future<void> iTapRetryNow(WidgetTester tester) async {
  await tester.tap(find.byKey(ConnectionBanner.retryButton));
  await tester.pumpAndSettle();
}
