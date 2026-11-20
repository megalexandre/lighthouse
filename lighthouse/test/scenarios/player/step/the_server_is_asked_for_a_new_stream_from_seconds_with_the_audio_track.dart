import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server is asked for a new stream from {30} seconds with the {'Portuguese'} audio track
///
/// A transcode carries only the tracks it was made with. The new stream
/// is opened, and reported as a new start.
Future<void> theServerIsAskedForANewStreamFromSecondsWithTheAudioTrack(
  WidgetTester tester,
  num seconds,
  String language,
) async {
  final index = audioIndex[language];
  expect(app.playback.prepareCalls.last, (
    Duration(seconds: seconds.toInt()),
    index,
    -1,
  ));
  expect(app.engine.opened, hasLength(2));
  expect(app.playback.started, hasLength(2));
  expect(app.playback.started.last.audioStreamIndex, index);
}
