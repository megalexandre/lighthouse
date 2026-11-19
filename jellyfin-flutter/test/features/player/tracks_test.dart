import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/media_stream.dart';
import 'package:jellyfin_flutter/api/models/playback_info_response.dart';
import 'package:jellyfin_flutter/api/models/playback_report.dart';
import 'package:jellyfin_flutter/features/player/data/playback_plan.dart';
import 'package:jellyfin_flutter/features/player/data/tracks.dart';
import 'package:jellyfin_flutter/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  /// The Test Movie as the 12.4 server describes it: 0 external por .srt,
  /// 1 video, 2 eng audio, 3 por audio, 4 embedded eng subtitle. mpv sees
  /// aid 1 = eng, aid 2 = por, sid 1 = eng (checked on the real file by
  /// integration_test/playback_flow_test.dart).
  PlaybackPlan plan({PlayMethod method = PlayMethod.directPlay}) {
    final response = PlaybackInfoResponse.fromJson(
      jsonDecode(
        File('test/fixtures/api/playback_info.json').readAsStringSync(),
      ) as Map<String, dynamic>,
    );
    final p = planPlayback(
      TestItems.testMovie,
      response,
      baseUrl: testUrl,
      authorization: 'x',
    );
    return method == p.method
        ? p
        : PlaybackPlan(
            item: p.item,
            source: p.source,
            playSessionId: p.playSessionId,
            method: method,
            url: p.url,
            headers: p.headers,
            start: p.start,
          );
  }

  test("server indexes → mpv ids: the file's tracks, by kind, from 1", () {
    final p = plan();
    final byIndex = {for (final s in p.source.mediaStreams) s.index: s};
    expect(mpvTrackId(p, byIndex[2]!), '1');
    expect(mpvTrackId(p, byIndex[3]!), '2');
    expect(mpvTrackId(p, byIndex[4]!), '1');
    expect(mpvTrackId(p, byIndex[1]!), '1'); // the video
    expect(mpvTrackId(p, byIndex[0]!), isNull); // external file
  });

  test('audio: pick the track; in a transcode, ask for a new stream', () {
    expect(audioAction(plan(), 3), const SelectTrack('2'));
    expect(
      audioAction(plan(method: PlayMethod.transcode), 3),
      isA<RestartStream>(),
    );
    expect(() => audioAction(plan(), 4), throwsArgumentError);
  });

  test('subtitles: none, embedded, external file', () {
    final p = plan();
    expect(subtitleAction(p, null, baseUrl: testUrl), isA<HideSubtitles>());
    expect(subtitleAction(p, 4, baseUrl: testUrl), const SelectTrack('1'));

    final external = subtitleAction(p, 0, baseUrl: testUrl) as AddSubtitle;
    expect(external.url.origin, testUrl);
    expect(external.url.path, endsWith('/Subtitles/0/0/Stream.subrip'));
    expect(external.url.queryParameters, contains('ApiKey'));
    expect(external.language, 'por');

    // An external file still works in a transcode; an embedded one does
    // not (the server would have to burn it in).
    final transcode = plan(method: PlayMethod.transcode);
    expect(subtitleAction(transcode, 0, baseUrl: testUrl), isA<AddSubtitle>());
    expect(
      subtitleAction(transcode, 4, baseUrl: testUrl),
      isA<RestartStream>(),
    );
  });

  test('the external subtitle URL is never printed whole', () {
    final action = subtitleAction(plan(), 0, baseUrl: testUrl);
    expect('$action', isNot(contains('ApiKey')));
  });

  group('labels', () {
    final pt = lookupAppLocalizations(const Locale('pt', 'BR'));
    MediaStream audio({String? language, String? title, String? display}) =>
        MediaStream(
          index: 1,
          type: MediaStreamType.audio,
          codec: 'aac',
          language: language,
          title: title,
          displayTitle: display,
        );

    test('the language in the app language, not the server label', () {
      final s = audio(language: 'por', display: 'Portuguese - AAC - Mono');
      expect(trackLabel(s, pt), 'Português');
      expect(trackLabel(s, en), 'Portuguese');
      expect(trackDetail(s, pt), 'AAC');
    });

    test('B, T and two-letter codes name the same language', () {
      for (final code in ['ger', 'deu', 'de', 'de-AT']) {
        expect(trackLabel(audio(language: code), pt), 'Alemão');
      }
    });

    test('a title that only names the language is not repeated', () {
      expect(
        trackLabel(audio(language: 'por', title: 'Português'), en),
        'Portuguese',
      );
      expect(
        trackLabel(audio(language: 'eng', title: 'english'), pt),
        'Inglês',
      );
    });

    test('a title of its own follows the language', () {
      final s = audio(language: 'eng', title: "Director's commentary");
      expect(trackLabel(s, pt), "Inglês · Director's commentary");
    });

    test('without a known language: the server label, then the title', () {
      expect(
        trackLabel(audio(language: 'und', display: 'AAC - Mono'), pt),
        'AAC - Mono',
      );
      expect(trackLabel(audio(title: 'Mix'), pt), 'Mix');
      expect(trackLabel(audio(), pt), 'Faixa 1');
    });

    test('a forced subtitle says so, with the format people know', () {
      const s = MediaStream(
        index: 4,
        type: MediaStreamType.subtitle,
        codec: 'subrip',
        language: 'eng',
        isForced: true,
      );
      expect(trackDetail(s, pt), 'SRT · Forçada');
    });
  });

  group('cycling', () {
    test('wraps around', () {
      expect(cycle([2, 3], 2), 3);
      expect(cycle([2, 3], 3), 2);
      expect(cycleBack([2, 3], 2), 3);
      expect(cycle([2, 3], null), 2);
    });

    test('with "none" between the last and the first', () {
      expect(cycle([0, 4], null, includeNone: true), 0);
      expect(cycle([0, 4], 0, includeNone: true), 4);
      expect(cycle([0, 4], 4, includeNone: true), isNull);
      expect(cycleBack([0, 4], null, includeNone: true), 4);
      expect(cycleBack([0, 4], 0, includeNone: true), isNull);
    });

    test('nothing to cycle', () {
      expect(cycle([], null), isNull);
      expect(cycleBack([], 1), isNull);
    });
  });
}
