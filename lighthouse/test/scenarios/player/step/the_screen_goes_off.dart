import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: When the screen goes off
///
/// The app goes to the background, where Flutter draws no frames.
Future<void> theScreenGoesOff(WidgetTester tester) async {
  for (final state in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
  addTearDown(
    () => tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    ),
  );
}
