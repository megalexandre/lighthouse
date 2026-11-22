import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given a call is on
///
/// The system refuses the sound to whoever asks.
Future<void> aCallIsOn(WidgetTester tester) async {
  app.audioFocus.refuses = true;
}
