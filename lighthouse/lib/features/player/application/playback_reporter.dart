import 'dart:async';

import '../../../api/models/playback_report.dart';
import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../../../core/ticks.dart';
import '../data/playback_plan.dart';
import '../data/playback_repository.dart';

/// Where a playback is, as the reports tell it.
typedef PlaybackStatus = ({
  Duration position,
  bool paused,
  int? audioStreamIndex,
  int? subtitleStreamIndex,
  double volume,
  bool muted,
});

/// Tells the server how one playback goes: started, where it is every
/// [interval] and at every pause / resume, and where it stopped (the
/// resume point). A failed report is logged and dropped: it must never
/// interrupt playback.
class PlaybackReporter {
  PlaybackReporter(
    this._repository,
    this._plan, {
    required this.status,
    this.interval = const Duration(seconds: 10),
    this.onStopUnsent,
  });

  /// Gets a stop report that could not reach the server (it holds the
  /// resume point, so it is kept and sent later).
  final void Function(PlaybackStopInfo report)? onStopUnsent;

  final PlaybackRepository _repository;
  final PlaybackPlan _plan;

  /// Read at each report.
  final PlaybackStatus Function() status;
  final Duration interval;

  Timer? _timer;
  bool _started = false;
  Future<void>? _stopped;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _send(_repository.reportStart(_progress()));
    _timer = Timer.periodic(interval, (_) => unawaited(progress()));
  }

  /// Reports the current position now (also called on pause / resume).
  Future<void> progress() async {
    if (!_started || _stopped != null) return;
    await _send(_repository.reportProgress(_progress()));
  }

  /// Reports the stop once; later calls wait for that same report. [at]
  /// overrides the position: at the end of the media it is the length,
  /// since the player's own position may already have moved on.
  Future<void> stop({bool failed = false, Duration? at}) =>
      _stopped ??= () async {
        _timer?.cancel();
        if (!_started) return;
        final report = PlaybackStopInfo(
          itemId: _plan.item.id,
          mediaSourceId: _plan.source.id,
          playSessionId: _plan.playSessionId,
          positionTicks: durationToTicks(at ?? status().position),
          failed: failed,
        );
        try {
          await _repository.reportStopped(report);
        } on ServerUnreachable catch (e) {
          log.warning('player', 'stop report kept until the server is back', e);
          onStopUnsent?.call(report);
        } on Failure catch (e) {
          log.warning('player', 'stop report failed', e);
        }
      }();

  PlaybackProgressInfo _progress() {
    final now = status();
    return PlaybackProgressInfo(
      itemId: _plan.item.id,
      mediaSourceId: _plan.source.id,
      playSessionId: _plan.playSessionId,
      positionTicks: durationToTicks(now.position),
      isPaused: now.paused,
      isMuted: now.muted,
      volumeLevel: now.volume.round(),
      playMethod: _plan.method,
      audioStreamIndex: now.audioStreamIndex,
      // The server's "none" is -1.
      subtitleStreamIndex: now.subtitleStreamIndex ?? -1,
    );
  }

  Future<void> _send(Future<void> report) async {
    try {
      await report;
    } on Failure catch (e) {
      log.warning('player', 'playback report failed', e);
    }
  }
}
