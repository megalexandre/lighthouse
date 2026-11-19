import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/playback_report.dart';

import 'world.dart';

/// Usage: Given the movie plays as a transcode
///
/// The fake server plans every item as a transcode: a track change needs a
/// new stream from it.
Future<void> theMoviePlaysAsATranscode(WidgetTester tester) async {
  app.playback.method = PlayMethod.transcode;
}
