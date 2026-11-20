import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';

import 'world.dart';

/// Usage: Given {'movie-1'} cannot be played
///
/// The server says so when asked for a stream (any item, in fact).
Future<void> cannotBePlayed(WidgetTester tester, String itemId) async {
  app.playback.failures['prepare'] = const NotPlayable('NotAllowed');
}
