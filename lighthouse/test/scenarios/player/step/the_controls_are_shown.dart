import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then the controls are shown
Future<void> theControlsAreShown(WidgetTester tester) async {
  expect(
    tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
    1,
  );
}
