import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I make the type bigger
///
/// One step, in the open display settings.
Future<void> iMakeTheTypeBigger(WidgetTester tester) async {
  await tester.tap(find.byKey(ReaderScreen.fontBigger));
  await tester.pumpAndSettle();
}
