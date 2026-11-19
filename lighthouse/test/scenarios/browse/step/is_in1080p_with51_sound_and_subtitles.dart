import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/media_stream.dart';

import 'world.dart';

/// Usage: Given {'Test Movie'} is in 1080p, with 5.1 sound and subtitles
Future<void> isIn1080pWith51SoundAndSubtitles(
  WidgetTester tester,
  String name,
) async {
  final movie = itemNamed(name);
  app.library.movies = [
    for (final m in app.library.movies)
      if (m.id == movie.id)
        m.copyWith(
          mediaStreams: const [
            MediaStream(index: 0, type: MediaStreamType.video, width: 1920),
            MediaStream(index: 1, type: MediaStreamType.audio, channels: 6),
            MediaStream(index: 2, type: MediaStreamType.subtitle),
          ],
        )
      else
        m,
  ];
}
