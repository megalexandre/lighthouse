import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/floating_window.dart';

import 'world.dart';

/// Usage: When I go to the phone's Home
///
/// As Android does: what plays in the player floats by itself.
Future<void> iGoToThePhonesHome(WidgetTester tester) async {
  if (app.floating.offered?.playing ?? false) {
    app.floating.happen(FloatingEvent.entered);
  }
  await tester.pumpAndSettle();
}
