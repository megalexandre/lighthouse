import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/library/application/library_providers.dart';
import 'package:lighthouse/features/server/application/connection_controller.dart';

import '../../../support/fakes.dart';
import 'world.dart';

/// Usage: When the server goes away
///
/// Home's calls fail, the app hears so (as from any API call), and home
/// is loaded again.
Future<void> theServerGoesAway(WidgetTester tester) async {
  for (final key in ['views', 'latest', 'resume', 'nextUp']) {
    app.library.failures[key] = const ServerUnreachable(testUrl);
  }
  app.serverUp = false;
  app.containerOf(tester)
    ..read(connectionProvider.notifier).report(reachable: false)
    ..invalidate(userViewsProvider);
  await tester.pumpAndSettle();
}
