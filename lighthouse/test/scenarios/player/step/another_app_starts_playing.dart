import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/data/audio_focus.dart';

import 'world.dart';

/// Usage: When another app starts playing
Future<void> anotherAppStartsPlaying(WidgetTester tester) async {
  app.audioFocus.happen(AudioFocusEvent.lost);
  await tester.pump();
}
