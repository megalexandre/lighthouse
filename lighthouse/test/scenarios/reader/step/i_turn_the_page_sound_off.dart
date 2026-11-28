import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: And I turn the page sound off
///
/// Its switch, in the display settings (open).
Future<void> iTurnThePageSoundOff(WidgetTester tester) async {
  final button = find.byKey(ReaderScreen.pageSoundSwitch);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}
