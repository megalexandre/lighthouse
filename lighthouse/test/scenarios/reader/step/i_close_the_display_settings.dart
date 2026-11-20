import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: And I close the display settings
///
/// A tap above the panel, on the dimmed book.
Future<void> iCloseTheDisplaySettings(WidgetTester tester) async {
  final screen = tester.getRect(find.byType(ReaderScreen));
  await tester.tapAt(Offset(screen.center.dx, screen.top + 100));
  await tester.pumpAndSettle();
  expect(find.byType(BottomSheet), findsNothing);
}
