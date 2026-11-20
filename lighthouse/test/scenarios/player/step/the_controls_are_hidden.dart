import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then the controls are hidden
Future<void> theControlsAreHidden(WidgetTester tester) async {
  expect(
    tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
    0,
  );
}
