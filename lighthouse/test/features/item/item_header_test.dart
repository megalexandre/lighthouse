import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/media_stream.dart';
import 'package:lighthouse/features/item/presentation/item_header.dart';

import '../../support/fakes.dart';

// What a user sees on an item's page is in test/scenarios/browse/item.feature.
// Here: which streams earn a badge, case by case.
void main() {
  MediaStream video({int? width, String? range}) => MediaStream(
    index: 0,
    type: MediaStreamType.video,
    width: width,
    videoRangeType: range,
  );
  MediaStream audio(int channels) =>
      MediaStream(index: 1, type: MediaStreamType.audio, channels: channels);
  const subtitle = MediaStream(index: 2, type: MediaStreamType.subtitle);

  test('technical badges: resolution, dynamic range, surround, subtitles', () {
    List<String> of(List<MediaStream> streams) =>
        technicalBadges(TestItems.testMovie.copyWith(mediaStreams: streams));
    expect(of([video(width: 3840, range: 'HDR10'), audio(6), subtitle]), [
      '4K',
      'HDR10',
      '5.1',
      'CC',
    ]);
    expect(of([video(width: 1920, range: 'DOVIWithHDR10'), audio(8)]), [
      '1080P',
      'Dolby Vision',
      '7.1',
    ]);
    expect(of([video(width: 1280, range: 'HLG')]), ['720P', 'HLG']);
    // SD, SDR, stereo: nothing worth a badge.
    expect(of([video(width: 640, range: 'SDR'), audio(2)]), isEmpty);
    expect(of(const []), isEmpty);
  });
}
