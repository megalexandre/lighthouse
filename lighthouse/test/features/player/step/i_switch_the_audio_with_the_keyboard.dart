import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: And I switch the audio with the keyboard
///
/// The A key: the next audio track.
Future<void> iSwitchTheAudioWithTheKeyboard(WidgetTester tester) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
  await tester.pumpAndSettle();
}
