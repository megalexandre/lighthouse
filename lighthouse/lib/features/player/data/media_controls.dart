import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/log.dart';
import '../../../core/theme/appearance.dart';
import '../../../l10n/l10n.dart';

/// What the system shows as playing.
typedef NowPlaying = ({
  String id,
  String title,
  String? artist,
  String? album,
  Uri? art,
  Duration? duration,
});

/// How it goes; the system moves the position on by itself while playing.
/// [locked]: the player is locked, and the controls show no buttons.
typedef PlayingState = ({
  bool playing,
  bool buffering,
  Duration position,
  double rate,
  bool hasNext,
  bool locked,
});

/// What the system's controls ask for (the notification, the lock screen,
/// a headset's buttons).
abstract interface class MediaCommands {
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> next();
  Future<void> previous();

  /// The user is done: the controls or the whole app dismissed.
  Future<void> stop();
}

/// The system's media controls, behind an interface so tests can use a
/// fake. On Android they also keep the app running with the screen off.
abstract interface class MediaControls {
  /// Shows [item], played by [commands].
  void show(MediaCommands commands, NowPlaying item, PlayingState state);

  /// Takes the controls down; nothing when they are not [commands]' any
  /// more.
  void clear(MediaCommands commands);
}

final mediaControlsProvider = Provider<MediaControls>(
  (ref) => Platform.isAndroid
      ? AndroidMediaControls(
          channelName: () =>
              lookupAppLocalizations(ref.read(appLanguageProvider).locale)
                  .mediaNotificationChannel,
        )
      : const NoMediaControls(),
);

/// Linux, until MPRIS.
class NoMediaControls implements MediaControls {
  const NoMediaControls();

  @override
  void show(MediaCommands commands, NowPlaying item, PlayingState state) {}

  @override
  void clear(MediaCommands commands) {}
}

/// Android's, over audio_service: a media foreground service with its
/// notification. Started at the first song.
class AndroidMediaControls implements MediaControls {
  AndroidMediaControls({required this.channelName});

  /// The notification channel's name, in the app's language.
  final String Function() channelName;

  Future<_Handler?>? _starting;
  ({MediaCommands commands, NowPlaying item, PlayingState state})? _shown;

  @override
  void show(MediaCommands commands, NowPlaying item, PlayingState state) {
    _shown = (commands: commands, item: item, state: state);
    unawaited(_apply());
  }

  @override
  void clear(MediaCommands commands) {
    if (!identical(_shown?.commands, commands)) return;
    _shown = null;
    unawaited(_apply());
  }

  Future<void> _apply() async {
    final handler = await (_starting ??= _start());
    // What is wanted now: it may have changed while the service started.
    handler?.apply(_shown);
  }

  Future<_Handler?> _start() async {
    try {
      return await AudioService.init(
        builder: _Handler.new,
        config: AudioServiceConfig(
          androidNotificationChannelId:
              'io.github.megalexandre.lighthouse.playback',
          androidNotificationChannelName: channelName(),
          androidNotificationIcon: 'drawable/ic_stat_playing',
          // Stays in the foreground while paused: Android 12+ lets no app
          // go back there from the background, as resuming after a call
          // with the screen off would.
          androidStopForegroundOnPause: false,
          artDownscaleWidth: 512,
          artDownscaleHeight: 512,
        ),
      );
    } on PlatformException catch (e) {
      // The music plays all the same, while the app is in front.
      log.error('player', 'no media controls', e.message);
      return null;
    }
  }
}

class _Handler extends BaseAudioHandler {
  MediaCommands? _commands;
  NowPlaying? _item;

  void apply(
    ({MediaCommands commands, NowPlaying item, PlayingState state})? shown,
  ) {
    _commands = shown?.commands;
    if (shown == null) {
      _item = null;
      // Idle ends the service and takes the notification with it.
      playbackState.add(PlaybackState());
      return;
    }
    final (:commands, :item, :state) = shown;
    if (item != _item) {
      _item = item;
      mediaItem.add(
        MediaItem(
          id: item.id,
          title: item.title,
          artist: item.artist,
          album: item.album,
          artUri: item.art,
          duration: item.duration,
        ),
      );
    }
    playbackState.add(
      PlaybackState(
        processingState: state.buffering
            ? AudioProcessingState.buffering
            : AudioProcessingState.ready,
        playing: state.playing,
        controls: [
          if (!state.locked) ...[
            MediaControl.skipToPrevious,
            state.playing ? MediaControl.pause : MediaControl.play,
            if (state.hasNext) MediaControl.skipToNext,
          ],
        ],
        androidCompactActionIndices: [
          if (!state.locked) ...[0, 1, if (state.hasNext) 2],
        ],
        // No seek bar either, locked.
        systemActions: state.locked ? const {} : const {MediaAction.seek},
        updatePosition: state.position,
        speed: state.rate,
      ),
    );
  }

  @override
  Future<void> play() async => _commands?.play();

  @override
  Future<void> pause() async => _commands?.pause();

  @override
  Future<void> seek(Duration position) async => _commands?.seek(position);

  @override
  Future<void> skipToNext() async => _commands?.next();

  @override
  Future<void> skipToPrevious() async => _commands?.previous();

  @override
  Future<void> stop() async => _commands?.stop();

  /// The app swiped away from the recent ones.
  @override
  Future<void> onTaskRemoved() => stop();
}
