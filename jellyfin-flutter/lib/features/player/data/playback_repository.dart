import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/client_info.dart';
import '../../../api/models/base_item_dto.dart';
import '../../../api/models/playback_info_dto.dart';
import '../../../api/models/playback_report.dart';
import '../../../api/models/user_item_data_dto.dart';
import '../../../api/playback.dart';
import '../../../core/failure.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/data/session.dart';
import '../../auth/data/session_client.dart';
import '../../server/application/connection_controller.dart';
import '../../settings/data/settings_repository.dart';
import 'device_profile.dart';
import 'playback_plan.dart';

/// Starting playback and telling the server how it goes. Every method
/// throws a [Failure].
abstract interface class PlaybackRepository {
  /// Asks the server how to play [item] and picks the stream, with the
  /// given tracks (server indexes; subtitle -1 = none) or the defaults.
  Future<PlaybackPlan> prepare(
    BaseItemDto item, {
    Duration start,
    int? audioStreamIndex,
    int? subtitleStreamIndex,
  });

  Future<void> reportStart(PlaybackProgressInfo info);
  Future<void> reportProgress(PlaybackProgressInfo info);

  /// Saves the resume point (or marks watched near the end).
  Future<void> reportStopped(PlaybackStopInfo info);

  /// Marks [itemId] watched or not, by hand.
  Future<UserItemDataDto> setPlayed(String itemId, {required bool played});
}

final playbackRepositoryProvider = Provider<PlaybackRepository>((ref) {
  final session = ref.watch(
    authControllerProvider.select((auth) => auth.value?.session),
  );
  if (session == null) return const SignedOutPlaybackRepository();
  return JellyfinPlaybackRepository(
    session,
    () => ref.read(clientInfoProvider.future),
    onUnauthorized: () =>
        ref.read(authControllerProvider.notifier).sessionExpired(),
    onReachability: ({required reachable}) =>
        ref.read(connectionProvider.notifier).report(reachable: reachable),
    maxStreamingBitrate: () =>
        ref.read(settingsRepositoryProvider).maxStreamingBitrate(),
  );
});

class JellyfinPlaybackRepository implements PlaybackRepository {
  JellyfinPlaybackRepository(
    Session session,
    Future<ClientInfo> Function() client, {
    required void Function() onUnauthorized,
    void Function({required bool reachable})? onReachability,
    HttpClientAdapter? adapter,
    this.maxStreamingBitrate,
  }) : _client = SessionClient(
         session,
         client,
         onUnauthorized: onUnauthorized,
         onReachability: onReachability,
         adapter: adapter,
       );

  final SessionClient _client;

  /// The quality setting (bits/s, null = none), read at each playback.
  final Future<int?> Function()? maxStreamingBitrate;

  @override
  Future<PlaybackPlan> prepare(
    BaseItemDto item, {
    Duration start = Duration.zero,
    int? audioStreamIndex,
    int? subtitleStreamIndex,
  }) => _client.call((api) async {
    final maxBitrate = await maxStreamingBitrate?.call();
    final response = await api.playbackInfo(
      item.id,
      PlaybackInfoDto(
        userId: _client.userId,
        deviceProfile: appDeviceProfile(maxStreamingBitrate: maxBitrate),
        maxStreamingBitrate: maxBitrate,
        startTimeTicks: start.inMicroseconds * 10,
        audioStreamIndex: audioStreamIndex,
        subtitleStreamIndex: subtitleStreamIndex,
      ),
    );
    return planPlayback(
      item,
      response,
      baseUrl: _client.baseUrl,
      authorization: api.client.authorizationHeader(token: api.token),
      start: start,
      audioStreamIndex: audioStreamIndex,
      subtitleStreamIndex: subtitleStreamIndex,
    );
  });

  @override
  Future<void> reportStart(PlaybackProgressInfo info) =>
      _client.call((api) => api.reportPlaybackStart(info));

  @override
  Future<void> reportProgress(PlaybackProgressInfo info) =>
      _client.call((api) => api.reportPlaybackProgress(info));

  @override
  Future<void> reportStopped(PlaybackStopInfo info) =>
      _client.call((api) => api.reportPlaybackStopped(info));

  @override
  Future<UserItemDataDto> setPlayed(String itemId, {required bool played}) =>
      _client.call(
        (api) => played
            ? api.markPlayed(_client.userId, itemId)
            : api.markUnplayed(_client.userId, itemId),
      );
}

/// While nobody is signed in (see SignedOutLibraryRepository).
class SignedOutPlaybackRepository implements PlaybackRepository {
  const SignedOutPlaybackRepository();

  Future<T> _fail<T>() => Future.error(const Unauthorized());

  @override
  Future<PlaybackPlan> prepare(
    BaseItemDto item, {
    Duration start = .zero,
    int? audioStreamIndex,
    int? subtitleStreamIndex,
  }) => _fail();

  @override
  Future<void> reportStart(PlaybackProgressInfo info) => _fail();

  @override
  Future<void> reportProgress(PlaybackProgressInfo info) => _fail();

  @override
  Future<void> reportStopped(PlaybackStopInfo info) => _fail();

  @override
  Future<UserItemDataDto> setPlayed(String itemId, {required bool played}) =>
      _fail();
}
