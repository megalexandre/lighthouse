import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: And the picture is as wide as the screen
///
/// A comic's page, grown to the screen when it is smaller.
Future<void> thePictureIsAsWideAsTheScreen(WidgetTester tester) async {
  final picture = find.descendant(
    of: find.byKey(ReaderScreen.pages),
    matching: find.byType(Image),
  );
  expect(
    tester.getSize(picture).width,
    tester.getSize(find.byType(ReaderScreen)).width,
  );
}
