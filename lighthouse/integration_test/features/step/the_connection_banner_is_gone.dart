import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/server/presentation/connection_banner.dart';

import '../../support/app.dart';

/// Usage: And the connection banner is gone
Future<void> theConnectionBannerIsGone(WidgetTester tester) async {
  await waitUntil(
    tester,
    () => find.byKey(ConnectionBanner.banner).evaluate().isEmpty,
    reason: 'the banner gone',
  );
}
