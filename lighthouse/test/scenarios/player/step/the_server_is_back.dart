import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/application/pending_reports.dart';
import 'package:lighthouse/features/server/application/connection_controller.dart';

import 'world.dart';

/// Usage: When the server is back
///
/// It answers again, and the app finds out (an API call that fails, then
/// one that goes through).
Future<void> theServerIsBack(WidgetTester tester) async {
  app.playback.stopFailure = null;
  app.containerOf(tester).read(connectionProvider.notifier)
    ..report(reachable: false)
    ..report(reachable: true);
  await tester.pumpAndSettle();
  expect(app.containerOf(tester).read(pendingReportsProvider), isEmpty);
}
