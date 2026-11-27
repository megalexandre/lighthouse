import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the floating window's middle button is {'Pause'}
///
/// The system's buttons on Android: what the player offered them.
Future<void> theFloatingWindowsMiddleButtonIs(
  WidgetTester tester,
  String label,
) async {
  final offer = app.floating.offered!;
  expect(offer.playing ? offer.pause : offer.play, label);
}
