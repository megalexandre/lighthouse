import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'jellyfin_api.dart';
import 'models/playback_info_dto.dart';
import 'models/playback_info_response.dart';
import 'models/playback_report.dart';
import 'models/user_item_data_dto.dart';

extension PlaybackApi on JellyfinApi {
  /// How this client can play [itemId]: media sources, each with direct
  /// play / transcode decided by the server from [request]'s profile.
  Future<PlaybackInfoResponse> playbackInfo(
    String itemId,
    PlaybackInfoDto request,
  ) => postJson(
    '/Items/$itemId/PlaybackInfo',
    PlaybackInfoResponse.fromJson,
    body: request.toJson(),
    query: {'userId': request.userId},
  );

  Future<void> reportPlaybackStart(PlaybackProgressInfo info) =>
      post('/Sessions/Playing', body: info.toJson());

  Future<void> reportPlaybackProgress(PlaybackProgressInfo info) =>
      post('/Sessions/Playing/Progress', body: info.toJson());

  Future<void> reportPlaybackStopped(PlaybackStopInfo info) =>
      post('/Sessions/Playing/Stopped', body: info.toJson());

  Future<UserItemDataDto> markPlayed(String userId, String itemId) => postJson(
    '/UserPlayedItems/$itemId',
    UserItemDataDto.fromJson,
    query: {'userId': userId},
  );

  Future<UserItemDataDto> markUnplayed(String userId, String itemId) =>
      deleteJson(
        '/UserPlayedItems/$itemId',
        UserItemDataDto.fromJson,
        query: {'userId': userId},
      );
}

/// URL of the file itself, for direct play. [audio] picks the audio
/// endpoint (music); both serve the file untouched with `static=true`.
Uri staticStreamUrl(
  String baseUrl,
  String itemId, {
  required String mediaSourceId,
  String? playSessionId,
  bool audio = false,
}) {
  final base = Uri.parse(baseUrl);
  return base.replace(
    path: '${base.path}/${audio ? 'Audio' : 'Videos'}/$itemId/stream',
    queryParameters: {
      'static': 'true',
      'mediaSourceId': mediaSourceId,
      'playSessionId': ?playSessionId,
    },
  );
}

/// A server-relative URL from the API (TranscodingUrl, DeliveryUrl) made
/// absolute.
Uri serverUrl(String baseUrl, String relative) {
  final base = Uri.parse(baseUrl);
  final rel = Uri.parse(relative);
  return base.replace(
    path: '${base.path}${rel.path}',
    query: rel.hasQuery ? rel.query : null,
  );
}

extension TrickplayApi on JellyfinApi {
  /// Tile [index] of an item's seek-bar thumbnails at [width] (an encoded
  /// JPEG). Fetched with the session's credentials: the server wants them,
  /// and a token never goes in a URL.
  Future<Uint8List> trickplayTile(
    String itemId, {
    required String mediaSourceId,
    required int width,
    required int index,
  }) => guard((dio) async {
    final res = await dio.get<List<int>>(
      '/Videos/$itemId/Trickplay/$width/$index.jpg',
      queryParameters: {'mediaSourceId': mediaSourceId},
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(res.data!);
  });
}
