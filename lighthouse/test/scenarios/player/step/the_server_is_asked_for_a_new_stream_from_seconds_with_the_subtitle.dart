import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server is asked for a new stream from {30} seconds with the {'English'} subtitle
///
/// A subtitle inside the file, in a transcode, is burnt into the stream:
/// another one needs a new stream. The audio stays the same.
Future<void> theServerIsAskedForANewStreamFromSecondsWithTheSubtitle(
  WidgetTester tester,
  num seconds,
  String language,
) async {
  expect(app.playback.prepareCalls.last, (
    Duration(seconds: seconds.toInt()),
    audioIndex['English'],
    subtitleIndex[language],
  ));
  expect(app.engine.opened, hasLength(2));
}
