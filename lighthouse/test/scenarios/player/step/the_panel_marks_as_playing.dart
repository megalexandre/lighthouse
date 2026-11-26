import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the panel marks {'2. Episode 2'} as playing
///
/// That row says "Playing", and only that one.
Future<void> thePanelMarksAsPlaying(WidgetTester tester, String title) async {
  expect(
    find.descendant(of: panelRow(title), matching: find.text('Playing')),
    findsOneWidget,
  );
  expect(find.text('Playing'), findsOneWidget);
}
