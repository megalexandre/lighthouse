import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then the bars are shown
Future<void> theBarsAreShown(WidgetTester tester) async {
  expect(
    tester.widget<AnimatedOpacity>(find.byKey(ReaderScreen.chrome)).opacity,
    1,
  );
}
