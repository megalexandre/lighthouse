import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/application/pending_reports.dart';

import 'world.dart';

/// Usage: Then the server has not been told where it stopped
///
/// The app keeps the report for later.
Future<void> theServerHasNotBeenToldWhereItStopped(WidgetTester tester) async {
  expect(app.playback.stopped, isEmpty);
  expect(app.containerOf(tester).read(pendingReportsProvider), hasLength(1));
}
