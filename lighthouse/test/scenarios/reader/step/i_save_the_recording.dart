import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I save the recording
Future<void> iSaveTheRecording(WidgetTester tester) async {
  await tester.tap(find.byKey(ReaderScreen.saveRecordingButton));
  await tester.pumpAndSettle();
}
