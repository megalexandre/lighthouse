import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';

import '../../../support/fakes.dart';
import 'world.dart';

/// Usage: And the server cannot be told playback stopped
///
/// It is gone when the player leaves.
Future<void> theServerCannotBeToldPlaybackStopped(WidgetTester tester) async {
  app.playback.stopFailure = const ServerUnreachable(testUrl);
}
