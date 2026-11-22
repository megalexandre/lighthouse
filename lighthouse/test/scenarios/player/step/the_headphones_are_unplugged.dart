import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/data/audio_focus.dart';

import 'world.dart';

/// Usage: When the headphones are unplugged
Future<void> theHeadphonesAreUnplugged(WidgetTester tester) async {
  app.audioFocus.happen(AudioFocusEvent.headphonesGone);
  await tester.pump();
}
