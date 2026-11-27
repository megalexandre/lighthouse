import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/data/voice_note.dart';

import 'world.dart';

/// Usage: Given the microphone cannot be used
///
/// No permission, or none there.
Future<void> theMicrophoneCannotBeUsed(WidgetTester tester) async {
  app.noteRecorder.failure = const RecordingFailed('no microphone');
}
