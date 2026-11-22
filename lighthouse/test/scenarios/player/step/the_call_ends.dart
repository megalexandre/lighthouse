import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/data/audio_focus.dart';

import 'world.dart';

/// Usage: When the call ends
Future<void> theCallEnds(WidgetTester tester) async {
  app.audioFocus.happen(AudioFocusEvent.regained);
  await tester.pump();
}
