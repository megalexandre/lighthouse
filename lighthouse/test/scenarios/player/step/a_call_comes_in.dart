import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/data/audio_focus.dart';

import 'world.dart';

/// Usage: When a call comes in
Future<void> aCallComesIn(WidgetTester tester) async {
  app.audioFocus.happen(AudioFocusEvent.lostForNow);
  await tester.pump();
}
