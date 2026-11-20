import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: When the window becomes {900} by {1400}
///
/// The reader's sheet changes size with it.
Future<void> theWindowBecomesBy(
  WidgetTester tester,
  num width,
  num height,
) async {
  final before = tester.getSize(find.byKey(ReaderScreen.pages));
  tester.view.physicalSize = Size(width.toDouble(), height.toDouble());
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpAndSettle();
  expect(tester.getSize(find.byKey(ReaderScreen.pages)), isNot(before));
}
