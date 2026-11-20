import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/server/presentation/connection_banner.dart';

import '../../support/app.dart';

/// Usage: Then I see the connection banner
Future<void> iSeeTheConnectionBanner(WidgetTester tester) async {
  await waitFor(tester, find.byKey(ConnectionBanner.banner));
}
