import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I dismiss the notification
Future<void> iDismissTheNotification(WidgetTester tester) async {
  await app.mediaControls.commands!.stop();
  await tester.pumpAndSettle();
}
