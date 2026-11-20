import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I open the display settings
Future<void> iOpenTheDisplaySettings(WidgetTester tester) async {
  await tester.tap(find.byKey(ReaderScreen.displayButton));
  await tester.pumpAndSettle();
}
