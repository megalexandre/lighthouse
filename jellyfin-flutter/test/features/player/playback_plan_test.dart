import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/base_item_dto.dart';
import 'package:jellyfin_flutter/api/models/media_source_info.dart';
import 'package:jellyfin_flutter/api/models/media_stream.dart';
import 'package:jellyfin_flutter/api/models/playback_info_response.dart';
import 'package:jellyfin_flutter/api/models/playback_report.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/features/player/data/device_profile.dart';
import 'package:jellyfin_flutter/features/player/data/playback_plan.dart';

import '../../support/fakes.dart';

void main() {
  /// The Test Movie, as the 12.4 test server answered (token redacted).
  final captured = PlaybackInfoResponse.fromJson(
    jsonDecode(File('test/fixtures/api/playback_info.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  const auth = 'MediaBrowser Token="t"';

  PlaybackPlan plan(
    PlaybackInfoResponse response, {
    BaseItemDto item = TestItems.testMovie,
    Duration start = Duration.zero,
  }) => planPlayback(
    item,
    response,
    baseUrl: testUrl,
    authorization: auth,
    start: start,
  );

  test('the captured response: two audio tracks, two subtitles', () {
    final source = captured.mediaSources.single;
    expect(captured.playSessionId, isNotEmpty);
    expect(source.supportsDirectPlay, isTrue);
    expect(source.container, 'mkv');
    final p = plan(captured);
    expect(p.audioStreams.map((s) => s.language), ['eng', 'por']);
    expect(p.subtitleStreams.map((s) => (s.language, s.isExternal)), [
      ('por', true),
      ('eng', false),
    ]);
    final external = p.subtitleStreams.first;
    expect(external.deliveryMethod, SubtitleDeliveryMethod.external);
    expect(external.deliveryUrl, contains('/Subtitles/'));
  });

  test('direct play: the file itself, with the auth header', () {
    final p = plan(captured, start: const Duration(seconds: 4));
    final source = captured.mediaSources.single;
    expect(p.method, PlayMethod.directPlay);
    expect(p.url.path, '/Videos/${TestItems.testMovie.id}/stream');
    expect(p.url.queryParameters, {
      'static': 'true',
      'mediaSourceId': source.id,
      'playSessionId': captured.playSessionId,
    });
    expect(p.headers, {'Authorization': auth});
    expect(p.start, const Duration(seconds: 4));
    expect(p.audioStreamIndex, source.defaultAudioStreamIndex);
  });

  test('music uses the audio endpoint', () {
    final p = plan(captured, item: TestItems.tracks.first);
    expect(p.url.path, '/Audio/track-1/stream');
  });

  test('transcode: the server URL, made absolute', () {
    const response = PlaybackInfoResponse(
      playSessionId: 's',
      mediaSources: [
        MediaSourceInfo(
          id: 'src',
          supportsTranscoding: true,
          transcodingUrl: '/videos/x/master.m3u8?ApiKey=k&VideoCodec=h264',
        ),
      ],
    );
    final p = plan(response);
    expect(p.method, PlayMethod.transcode);
    expect(
      p.url.toString(),
      '$testUrl/videos/x/master.m3u8?ApiKey=k&VideoCodec=h264',
    );
  });

  test('direct stream when only that is allowed', () {
    const response = PlaybackInfoResponse(
      mediaSources: [MediaSourceInfo(id: 'src', supportsDirectStream: true)],
    );
    expect(plan(response).method, PlayMethod.directStream);
  });

  test('"no subtitle" (-1) is none', () {
    const response = PlaybackInfoResponse(
      mediaSources: [
        MediaSourceInfo(
          id: 'src',
          supportsDirectPlay: true,
          defaultSubtitleStreamIndex: -1,
        ),
      ],
    );
    expect(plan(response).subtitleStreamIndex, isNull);
  });

  test('not playable', () {
    expect(
      () => plan(const PlaybackInfoResponse(errorCode: 'NotAllowed')),
      throwsA(
        isA<NotPlayable>().having((e) => e.reason, 'reason', 'NotAllowed'),
      ),
    );
    expect(
      () => plan(const PlaybackInfoResponse()),
      throwsA(isA<NotPlayable>()),
    );
    expect(
      () => plan(
        const PlaybackInfoResponse(mediaSources: [MediaSourceInfo(id: 'x')]),
      ),
      throwsA(isA<NotPlayable>()),
    );
  });

  test('the device profile: direct play of anything, HLS fallback', () {
    final json = appDeviceProfile().toJson();
    expect(json['DirectPlayProfiles'], [
      {'Type': 'Video'},
      {'Type': 'Audio'},
    ]);
    final video = (json['TranscodingProfiles'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((p) => p['Type'] == 'Video');
    expect(video['Protocol'], 'hls');
    expect(video['VideoCodec'], startsWith('h264'));
    final subtitles = (json['SubtitleProfiles'] as List)
        .cast<Map<String, dynamic>>();
    expect(
      subtitles,
      contains(equals({'Format': 'subrip', 'Method': 'External'})),
    );
    expect(
      subtitles,
      contains(equals({'Format': 'pgssub', 'Method': 'Embed'})),
    );
  });
}
