import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: And I close the display settings
///
/// A tap on the book outside the panel: above it, near the left edge (on a
/// phone on its side the panel reaches the top, but is at most 480 wide).
Future<void> iCloseTheDisplaySettings(WidgetTester tester) async {
  final screen = tester.getRect(find.byType(ReaderScreen));
  await tester.tapAt(Offset(screen.left + 8, screen.top + 100));
  await tester.pumpAndSettle();
  expect(find.byType(BottomSheet), findsNothing);
}
