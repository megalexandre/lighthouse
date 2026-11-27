import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/floating_window.dart';

import 'world.dart';

/// Usage: When I use the floating window's {'play/pause'}
///
/// One of the system's buttons on Android: 'play/pause', '-10 s', '+10 s'.
Future<void> iUseTheFloatingWindows(WidgetTester tester, String button) async {
  app.floating.happen(switch (button) {
    'play/pause' => FloatingEvent.playPause,
    '-10 s' => FloatingEvent.seekBack,
    '+10 s' => FloatingEvent.seekForward,
    _ => throw ArgumentError(button),
  });
  await tester.pumpAndSettle();
}
