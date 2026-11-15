import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../core/log.dart';

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

  /// mpv's id of the selected audio / subtitle track ("1", "2"...; "no"
  /// for none), and what the file says about it.
  EngineTrack get audioTrack;
  EngineTrack get subtitleTrack;

  /// Selects one of the file's own tracks by mpv id ("no": none).
  Future<void> selectAudioTrack(String mpvId);
  Future<void> selectSubtitleTrack(String mpvId);

  /// Loads a subtitle file and shows it.
  Future<void> addSubtitle(Uri url, {String? title, String? language});

  /// 0–100.
  double get volume;
  Stream<double> get volumeStream;
  Future<void> setVolume(double volume);

  bool get muted;
  Stream<bool> get mutedStream;
  Future<void> setMuted(bool muted);

  /// The picture. Empty for audio.
  Widget buildVideo();

  Future<void> dispose();
}

/// A track as the player sees it.
typedef EngineTrack = ({String id, String? language, String? title});

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
    // mpv's own warnings and errors, for the log (hardware decoders it
    // probes and drops are expected noise at "error" level too).
    _mpvLog = _player.stream.log.listen((line) {
      if (line.level == 'error' || line.level == 'warn') {
        log.debug('mpv', '${line.prefix}: ${line.text.trim()}');
      }
    });
  }

  late final StreamSubscription<PlayerLog> _mpvLog;

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
    // A short network drop: reconnect instead of ending the stream.
    await _mpv.setProperty('network-timeout', '20');
    await _mpv.setProperty(
      'stream-lavf-o',
      'reconnect=1,reconnect_streamed=1,reconnect_delay_max=5',
    );
    await _player.open(
      Media(url.toString(), httpHeaders: headers, start: start),
    );
    // Track changes only work once the file is loaded (its length known).
    try {
      await _player.stream.duration
          .firstWhere((d) => d > Duration.zero)
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      // Slow server or a live stream: carry on, the screen shows buffering.
    }
  }

  @override
  EngineTrack get audioTrack {
    final current = _player.state.track.audio;
    final known = _player.state.tracks.audio.where((t) => t.id == current.id);
    final t = known.isEmpty ? current : known.first;
    return (id: current.id, language: t.language, title: t.title);
  }

  @override
  EngineTrack get subtitleTrack {
    final current = _player.state.track.subtitle;
    final known = _player.state.tracks.subtitle.where(
      (t) => t.id == current.id,
    );
    final t = known.isEmpty ? current : known.first;
    return (id: current.id, language: t.language, title: t.title);
  }

  @override
  Future<void> selectAudioTrack(String mpvId) => _player.setAudioTrack(
    mpvId == 'no' ? AudioTrack.no() : AudioTrack(mpvId, null, null),
  );

  @override
  Future<void> selectSubtitleTrack(String mpvId) => _player.setSubtitleTrack(
    mpvId == 'no' ? SubtitleTrack.no() : SubtitleTrack(mpvId, null, null),
  );

  @override
  Future<void> addSubtitle(Uri url, {String? title, String? language}) =>
      _player.setSubtitleTrack(
        SubtitleTrack.uri(url.toString(), title: title, language: language),
      );

  @override
  double get volume => _player.state.volume;

  @override
  Stream<double> get volumeStream => _player.stream.volume;

  @override
  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0, 100).toDouble());

  bool _muted = false;
  final _mutedController = StreamController<bool>.broadcast();

  @override
  bool get muted => _muted;

  @override
  Stream<bool> get mutedStream => _mutedController.stream;

  @override
  Future<void> setMuted(bool muted) async {
    await _mpv.setProperty('mute', muted ? 'yes' : 'no');
    _muted = muted;
    _mutedController.add(muted);
  }

  /// An mpv property as text, e.g. `current-tracks/audio/lang` or
  /// `sub-text`. For tests that check what mpv really does.
  Future<String> mpvProperty(String name) => _mpv.getProperty(name);

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
  Future<void> dispose() async {
    await _mpvLog.cancel();
    await _mutedController.close();
    await _player.dispose();
  }
}
