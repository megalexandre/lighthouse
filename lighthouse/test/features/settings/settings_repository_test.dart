import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/client_info.dart';
import 'package:lighthouse/api/models/user_configuration.dart';
import 'package:lighthouse/core/storage.dart';
import 'package:lighthouse/features/player/data/playback_repository.dart';
import 'package:lighthouse/features/settings/data/settings_repository.dart';

import '../../support/fake_http.dart';
import '../../support/fakes.dart';

void main() {
  const client = ClientInfo(deviceId: 'dev-1', device: 'pc');

  /// What GET /Users/Me returns: fields the app models and some it does not.
  final serverConfig = {
    'AudioLanguagePreference': 'eng',
    'SubtitleMode': 'Default',
    'EnableNextEpisodeAutoPlay': true,
    'OrderedViews': ['a', 'b'],
    'HidePlayedInLatest': true,
    'CastReceiverId': 'chromecast',
  };

  late FakeAdapter adapter;
  late MemoryKeyValueStore store;
  late JellyfinSettingsRepository repo;

  setUp(() {
    adapter = FakeAdapter((options) async {
      if (options.uri.path == '/Users/Me') {
        return json({
          'Id': 'user-id',
          'Name': 'alice',
          'Configuration': serverConfig,
        });
      }
      return json('', status: 204);
    });
    store = MemoryKeyValueStore();
    repo = JellyfinSettingsRepository(
      testSession,
      () async => client,
      store,
      onUnauthorized: () {},
      adapter: adapter,
    );
  });

  test('reads the user configuration', () async {
    final config = await repo.userConfiguration();
    expect(config.audioLanguagePreference, 'eng');
    expect(config.subtitleMode, SubtitlePlaybackMode.defaultMode);
  });

  test('an update sends every field back, the changed ones changed', () async {
    final saved = await repo.updateUserConfiguration(
      audioLanguage: 'por',
      subtitleMode: SubtitlePlaybackMode.onlyForced,
    );
    final post = adapter.requests.last;
    expect(post.method, 'POST');
    expect(post.uri.path, '/Users/Configuration');
    expect(post.uri.queryParameters, {'userId': testSession.userId});
    expect(post.data, {
      ...serverConfig,
      'AudioLanguagePreference': 'por',
      'PlayDefaultAudioTrack': false,
      'SubtitleMode': 'OnlyForced',
    });
    expect(saved.audioLanguagePreference, 'por');
  });

  test(
    '"no preference" is an empty language, and plays the default track',
    () async {
      await repo.updateUserConfiguration(audioLanguage: noLanguage);
      expect(
        (adapter.requests.last.data as Map)['AudioLanguagePreference'],
        '',
      );
    },
  );

  test('every subtitle mode has the server name', () {
    final names = {
      for (final m in SubtitlePlaybackMode.values)
        UserConfiguration(subtitleMode: m).toJson()['SubtitleMode'],
    };
    expect(names, {'Default', 'Always', 'OnlyForced', 'None', 'Smart'});
  });

  test('the quality limit stays on this device', () async {
    expect(await repo.maxStreamingBitrate(), isNull);
    await repo.setMaxStreamingBitrate(4000000);
    expect(await repo.maxStreamingBitrate(), 4000000);
    expect(adapter.requests, isEmpty);
    expect(jsonDecode(store.values['playback_settings']!), {
      'maxStreamingBitrate': 4000000,
    });
    await repo.setMaxStreamingBitrate(null);
    expect(await repo.maxStreamingBitrate(), isNull);
  });

  test('the quality limit goes into PlaybackInfo', () async {
    final http = FakeAdapter(
      (_) async => json({
        'MediaSources': [
          {'Id': 's', 'SupportsDirectPlay': true},
        ],
      }),
    );
    final playback = JellyfinPlaybackRepository(
      testSession,
      () async => client,
      onUnauthorized: () {},
      adapter: http,
      maxStreamingBitrate: () async => 2000000,
    );
    await playback.prepare(TestItems.testMovie);
    final body = http.requests.single.data as Map<String, dynamic>;
    expect(body['MaxStreamingBitrate'], 2000000);
    expect(
      (body['DeviceProfile'] as Map<String, dynamic>)['MaxStreamingBitrate'],
      2000000,
    );
  });
}
