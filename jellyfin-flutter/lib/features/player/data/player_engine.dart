import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// The video player itself, behind an interface so screens and the
/// player controller can be tested with a fake. The real one is
/// [MediaKitEngine] (libmpv).
abstract interface class PlayerEngine {
  /// Opens [url] and starts playing at [start].
  Future<void> open(
    Uri url, {
    Map<String, String> headers = const {},
    Duration start = Duration.zero,
  });

  Future<void> play();
  Future<void> pause();
  Future<void> playOrPause();
  Future<void> seek(Duration position);

  Duration get position;
  Duration get duration;
  bool get playing;

  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<bool> get playingStream;
  Stream<bool> get bufferingStream;

  /// Fires once when the media plays to its end.
  Stream<void> get completedStream;

  /// Playback errors (cannot open, cannot decode...).
  Stream<String> get errorStream;

  /// The picture. Empty for audio.
  Widget buildVideo();

  Future<void> dispose();
}

/// How mpv is set up. The defaults are for a desktop; the integration
/// tests turn sound and hardware decoding off (CI has neither).
class PlayerOptions {
  const PlayerOptions({this.hardwareDecoding = true, this.audio = true});

  final bool hardwareDecoding;
  final bool audio;
}

final playerOptionsProvider = Provider<PlayerOptions>(
  (_) => const PlayerOptions(),
);

/// Makes a new engine for each playback.
final playerEngineFactoryProvider = Provider<PlayerEngine Function()>((ref) {
  final options = ref.watch(playerOptionsProvider);
  return () => MediaKitEngine(options);
});

class MediaKitEngine implements PlayerEngine {
  MediaKitEngine(this.options)
    : _player = Player(
        configuration: const PlayerConfiguration(title: 'Jellyfin Flutter'),
      ) {
    _video = VideoController(
      _player,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: options.hardwareDecoding,
      ),
    );
    _completed = _player.stream.completed.where((done) => done);
  }

  final PlayerOptions options;
  final Player _player;
  late final VideoController _video;
  late final Stream<bool> _completed;

  NativePlayer get _mpv => _player.platform! as NativePlayer;

  @override
  Future<void> open(
    Uri url, {
    Map<String, String> headers = const {},
    Duration start = Duration.zero,
  }) async {
    // Options from jellyfin-desktop's PlayerComponent.cpp that matter
    // for streaming from a server.
    await _mpv.setProperty(
      'hwdec',
      options.hardwareDecoding ? 'auto-safe' : 'no',
    );
    if (!options.audio) await _mpv.setProperty('ao', 'null');
    await _mpv.setProperty('audio-fallback-to-null', 'yes');
    await _mpv.setProperty('demuxer-max-bytes', '${150 * 1024 * 1024}');
    await _player.open(
      Media(url.toString(), httpHeaders: headers, start: start),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> playOrPause() => _player.playOrPause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Duration get position => _player.state.position;

  @override
  Duration get duration => _player.state.duration;

  @override
  bool get playing => _player.state.playing;

  @override
  Stream<Duration> get positionStream => _player.stream.position;

  @override
  Stream<Duration> get durationStream => _player.stream.duration;

  @override
  Stream<bool> get playingStream => _player.stream.playing;

  @override
  Stream<bool> get bufferingStream => _player.stream.buffering;

  @override
  Stream<void> get completedStream => _completed;

  @override
  Stream<String> get errorStream => _player.stream.error;

  @override
  Widget buildVideo() =>
      Video(controller: _video, controls: null, fill: Colors.black);

  @override
  Future<void> dispose() => _player.dispose();
}
