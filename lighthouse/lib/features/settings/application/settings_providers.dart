import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/models/culture_dto.dart';
import '../../../api/models/user_configuration.dart';
import '../data/settings_repository.dart';

/// The signed-in user's server settings. Changing one saves it on the
/// server; the state follows once the server took it.
final userConfigurationProvider =
    AsyncNotifierProvider<UserConfigurationController, UserConfiguration>(
      UserConfigurationController.new,
    );

class UserConfigurationController extends AsyncNotifier<UserConfiguration> {
  @override
  Future<UserConfiguration> build() =>
      ref.watch(settingsRepositoryProvider).userConfiguration();

  Future<void> change({
    String? audioLanguage,
    String? subtitleLanguage,
    SubtitlePlaybackMode? subtitleMode,
    bool? nextEpisodeAutoPlay,
  }) async {
    final saved = await ref
        .read(settingsRepositoryProvider)
        .updateUserConfiguration(
          audioLanguage: audioLanguage,
          subtitleLanguage: subtitleLanguage,
          subtitleMode: subtitleMode,
          nextEpisodeAutoPlay: nextEpisodeAutoPlay,
        );
    if (ref.mounted) state = AsyncData(saved);
  }
}

final languagesProvider = FutureProvider.autoDispose<List<CultureDto>>(
  (ref) => ref.watch(settingsRepositoryProvider).languages(),
);

/// This device's streaming quality limit (bits/s; null = none).
final maxStreamingBitrateProvider =
    AsyncNotifierProvider<MaxStreamingBitrateController, int?>(
      MaxStreamingBitrateController.new,
    );

class MaxStreamingBitrateController extends AsyncNotifier<int?> {
  @override
  Future<int?> build() =>
      ref.watch(settingsRepositoryProvider).maxStreamingBitrate();

  Future<void> set(int? bitsPerSecond) async {
    await ref
        .read(settingsRepositoryProvider)
        .setMaxStreamingBitrate(bitsPerSecond);
    if (ref.mounted) state = AsyncData(bitsPerSecond);
  }
}

/// Which swipes the player answers on touch (this device's).
final swipeSettingsProvider =
    AsyncNotifierProvider<SwipeSettingsController, SwipeSettings>(
      SwipeSettingsController.new,
    );

class SwipeSettingsController extends AsyncNotifier<SwipeSettings> {
  @override
  Future<SwipeSettings> build() =>
      ref.watch(settingsRepositoryProvider).swipes();

  Future<void> set(SwipeSettings swipes) async {
    await ref.read(settingsRepositoryProvider).setSwipes(swipes);
    if (ref.mounted) state = AsyncData(swipes);
  }
}

/// The choices of the quality setting: (bits/s or null, label).
const qualityOptions = <(int?, String)>[
  (null, 'Maximum'),
  (60000000, '60 Mbps'),
  (40000000, '40 Mbps'),
  (20000000, '20 Mbps'),
  (10000000, '10 Mbps'),
  (8000000, '8 Mbps'),
  (4000000, '4 Mbps'),
  (2000000, '2 Mbps'),
  (1000000, '1 Mbps'),
  (720000, '720 kbps'),
  (420000, '420 kbps'),
];
