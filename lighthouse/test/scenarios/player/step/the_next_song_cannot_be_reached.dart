import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';

import 'world.dart';

/// Usage: And the next song cannot be reached
Future<void> theNextSongCannotBeReached(WidgetTester tester) async {
  app.playback.failures['prepare'] = const ServerUnreachable('http://test');
}
