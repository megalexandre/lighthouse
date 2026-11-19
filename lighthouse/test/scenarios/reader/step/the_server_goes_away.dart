import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/server/application/connection_controller.dart';

import '../../../support/fakes.dart';
import 'world.dart';

/// Usage: And the server goes away
///
/// Places and "read" cannot be saved, and the app learns the server is
/// gone (as a failed call tells it).
Future<void> theServerGoesAway(WidgetTester tester) async {
  const down = ServerUnreachable(testUrl);
  app.books.failures
    ..['save'] = down
    ..['read'] = down;
  app.serverUp = false;
  app
      .containerOf(tester)
      .read(connectionProvider.notifier)
      .report(reachable: false);
  await tester.pumpAndSettle();
}
