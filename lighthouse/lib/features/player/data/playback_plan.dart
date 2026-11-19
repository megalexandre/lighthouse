import 'package:flutter/foundation.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../api/models/media_source_info.dart';
import '../../../api/models/media_stream.dart';
import '../../../api/models/playback_info_response.dart';
import '../../../api/models/playback_report.dart';
import '../../../api/playback.dart';
import '../../../core/failure.dart';

/// Everything needed to start playing one item: which source, how, from
/// which URL, and the tracks to start with.
@immutable
class PlaybackPlan {
  const PlaybackPlan({
    required this.item,
    required this.source,
    required this.playSessionId,
    required this.method,
    required this.url,
    required this.headers,
    required this.start,
    this.audioStreamIndex,
    this.subtitleStreamIndex,
  });

  final BaseItemDto item;
  final MediaSourceInfo source;
  final String? playSessionId;
  final PlayMethod method;

  /// Carries an access token in its query when transcoding: never log it.
  final Uri url;

  /// HTTP headers for the stream (the Authorization header).
  final Map<String, String> headers;
  final Duration start;

  /// Server stream indexes ([MediaStream.index]) to start with; null
  /// subtitle means none.
  final int? audioStreamIndex;
  final int? subtitleStreamIndex;

  List<MediaStream> get audioStreams => [
    for (final s in source.mediaStreams)
      if (s.type == MediaStreamType.audio) s,
  ];

  List<MediaStream> get subtitleStreams => [
    for (final s in source.mediaStreams)
      if (s.type == MediaStreamType.subtitle) s,
  ];
}

/// Picks how to play [item] from the server's [response]: direct play
/// when the server allows it (the usual case, mpv plays nearly anything),
/// else the server's transcode. Throws [NotPlayable] when neither works.
/// [subtitleStreamIndex] -1 asks for no subtitle.
PlaybackPlan planPlayback(
  BaseItemDto item,
  PlaybackInfoResponse response, {
  required String baseUrl,
  required String authorization,
  Duration start = Duration.zero,
  int? audioStreamIndex,
  int? subtitleStreamIndex,
}) {
  if (response.errorCode case final String code) throw NotPlayable(code);
  if (response.mediaSources.isEmpty) throw const NotPlayable('no source');
  final source = response.mediaSources.first;

  final (PlayMethod method, Uri url) = switch (source) {
    MediaSourceInfo(supportsDirectPlay: true) => (
      PlayMethod.directPlay,
      _static(item, source, response, baseUrl),
    ),
    MediaSourceInfo(supportsDirectStream: true) => (
      PlayMethod.directStream,
      _static(item, source, response, baseUrl),
    ),
    MediaSourceInfo(transcodingUrl: final String transcode) => (
      PlayMethod.transcode,
      serverUrl(baseUrl, transcode),
    ),
    _ => throw const NotPlayable('no compatible stream'),
  };

  // Asked for, else the server's default (which follows the user's
  // language preferences).
  final subtitle = subtitleStreamIndex ?? source.defaultSubtitleStreamIndex;
  return PlaybackPlan(
    item: item,
    source: source,
    playSessionId: response.playSessionId,
    method: method,
    url: url,
    headers: {'Authorization': authorization},
    start: start,
    audioStreamIndex: audioStreamIndex ?? source.defaultAudioStreamIndex,
    // -1 is the server's "none".
    subtitleStreamIndex: subtitle == null || subtitle < 0 ? null : subtitle,
  );
}

Uri _static(
  BaseItemDto item,
  MediaSourceInfo source,
  PlaybackInfoResponse response,
  String baseUrl,
) => staticStreamUrl(
  baseUrl,
  item.id,
  mediaSourceId: source.id,
  playSessionId: response.playSessionId,
  audio: item.type == BaseItemKind.audio,
);
