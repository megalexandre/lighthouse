import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I tap the full screen button
///
/// In the reader's top bar.
Future<void> iTapTheFullScreenButton(WidgetTester tester) async {
  await tester.tap(find.byKey(ReaderScreen.fullScreenButton));
  await tester.pumpAndSettle();
}
