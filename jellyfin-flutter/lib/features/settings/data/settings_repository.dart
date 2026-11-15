import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/client_info.dart';
import '../../../api/localization.dart';
import '../../../api/models/culture_dto.dart';
import '../../../api/models/user_configuration.dart';
import '../../../api/users.dart';
import '../../../core/failure.dart';
import '../../../core/storage.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/data/session.dart';
import '../../auth/data/session_client.dart';
import '../../server/application/connection_controller.dart';

/// The user's playback settings. Languages, subtitles and autoplay live on
/// the server (every client of that user follows them); the quality limit
/// is this device's (it depends on its network).
abstract interface class SettingsRepository {
  Future<UserConfiguration> userConfiguration();

  /// Changes the given fields on the server, keeping every other setting.
  Future<UserConfiguration> updateUserConfiguration({
    String? audioLanguage,
    String? subtitleLanguage,
    SubtitlePlaybackMode? subtitleMode,
    bool? nextEpisodeAutoPlay,
  });

  Future<List<CultureDto>> languages();

  /// Bits per second, null = no limit.
  Future<int?> maxStreamingBitrate();
  Future<void> setMaxStreamingBitrate(int? bitsPerSecond);
}

/// Empty language = "no preference" (the server's own value for it).
const noLanguage = '';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final session = ref.watch(
    authControllerProvider.select((auth) => auth.value?.session),
  );
  final store = ref.watch(keyValueStoreProvider);
  if (session == null) return SignedOutSettingsRepository(store);
  return JellyfinSettingsRepository(
    session,
    () => ref.read(clientInfoProvider.future),
    store,
    onUnauthorized: () =>
        ref.read(authControllerProvider.notifier).sessionExpired(),
    onReachability: ({required reachable}) =>
        ref.read(connectionProvider.notifier).report(reachable: reachable),
  );
});

/// The device-local part, shared by the signed-in and signed-out versions.
mixin _LocalSettings {
  KeyValueStore get store;

  static const key = 'playback_settings';

  Future<Map<String, dynamic>> _read() async {
    final raw = await store.read(key);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      return {};
    }
  }

  Future<int?> maxStreamingBitrate() async =>
      (await _read())['maxStreamingBitrate'] as int?;

  Future<void> setMaxStreamingBitrate(int? bitsPerSecond) async {
    final settings = await _read()
      ..['maxStreamingBitrate'] = bitsPerSecond;
    await store.write(key, jsonEncode(settings));
  }
}

class JellyfinSettingsRepository
    with _LocalSettings
    implements SettingsRepository {
  JellyfinSettingsRepository(
    Session session,
    Future<ClientInfo> Function() client,
    this.store, {
    required void Function() onUnauthorized,
    void Function({required bool reachable})? onReachability,
    HttpClientAdapter? adapter,
  }) : _client = SessionClient(
         session,
         client,
         onUnauthorized: onUnauthorized,
         onReachability: onReachability,
         adapter: adapter,
       );

  final SessionClient _client;
  @override
  final KeyValueStore store;

  @override
  Future<UserConfiguration> userConfiguration() => _client.call(
    (api) async => UserConfiguration.fromJson(await api.myConfigurationJson()),
  );

  @override
  Future<UserConfiguration> updateUserConfiguration({
    String? audioLanguage,
    String? subtitleLanguage,
    SubtitlePlaybackMode? subtitleMode,
    bool? nextEpisodeAutoPlay,
  }) => _client.call((api) async {
    // Read-modify-write: the server replaces the whole configuration,
    // so everything the app does not model is sent back untouched.
    final json = await api.myConfigurationJson();
    if (audioLanguage != null) {
      json['AudioLanguagePreference'] = audioLanguage;
      // With PlayDefaultAudioTrack on, the server plays the file's default
      // track whatever the preference: choosing a language means playing
      // it; "the file's default" means the opposite.
      json['PlayDefaultAudioTrack'] = audioLanguage == noLanguage;
    }
    if (subtitleLanguage != null) {
      json['SubtitleLanguagePreference'] = subtitleLanguage;
    }
    if (subtitleMode != null) {
      json['SubtitleMode'] = UserConfiguration(subtitleMode: subtitleMode)
          .toJson()['SubtitleMode'];
    }
    if (nextEpisodeAutoPlay != null) {
      json['EnableNextEpisodeAutoPlay'] = nextEpisodeAutoPlay;
    }
    await api.updateConfiguration(_client.userId, json);
    return UserConfiguration.fromJson(json);
  });

  @override
  Future<List<CultureDto>> languages() => _client.call((api) async {
    final all = await api.cultures();
    return [
      for (final c in all)
        if (c.threeLetterIsoLanguageName case final String code
            when code.isNotEmpty)
          c,
    ]..sort((a, b) => a.displayName.compareTo(b.displayName));
  });
}

class SignedOutSettingsRepository
    with _LocalSettings
    implements SettingsRepository {
  SignedOutSettingsRepository(this.store);

  @override
  final KeyValueStore store;

  @override
  Future<UserConfiguration> userConfiguration() =>
      Future.error(const Unauthorized());

  @override
  Future<UserConfiguration> updateUserConfiguration({
    String? audioLanguage,
    String? subtitleLanguage,
    SubtitlePlaybackMode? subtitleMode,
    bool? nextEpisodeAutoPlay,
  }) => Future.error(const Unauthorized());

  @override
  Future<List<CultureDto>> languages() => Future.error(const Unauthorized());
}
