import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I use the notification's {'next'}
///
/// Or the lock screen's, or a headset's: the same buttons.
Future<void> iUseTheNotifications(WidgetTester tester, String button) async {
  final commands = app.mediaControls.commands!;
  await switch (button) {
    'play' => commands.play(),
    'pause' => commands.pause(),
    'next' => commands.next(),
    'previous' => commands.previous(),
    _ => throw ArgumentError.value(button),
  };
  await tester.pumpAndSettle();
}
