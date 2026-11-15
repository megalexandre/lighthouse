import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../api/models/playback_report.dart';
import '../../../core/failure.dart';
import '../../../core/ticks.dart';
import '../data/playback_plan.dart';
import '../data/playback_repository.dart';

/// Tells the server how one playback goes: started, where it is every
/// [interval] and at every pause / resume, and where it stopped (the
/// resume point). A failed report is logged and dropped: it must never
/// interrupt playback.
class PlaybackReporter {
  PlaybackReporter(
    this._repository,
    this._plan, {
    required this.position,
    required this.paused,
    this.interval = const Duration(seconds: 10),
  });

  final PlaybackRepository _repository;
  final PlaybackPlan _plan;
  final Duration Function() position;
  final bool Function() paused;
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

  /// Reports the stop once; later calls wait for that same report.
  Future<void> stop({bool failed = false}) => _stopped ??= () async {
    _timer?.cancel();
    if (!_started) return;
    await _send(
      _repository.reportStopped(
        PlaybackStopInfo(
          itemId: _plan.item.id,
          mediaSourceId: _plan.source.id,
          playSessionId: _plan.playSessionId,
          positionTicks: durationToTicks(position()),
          failed: failed,
        ),
      ),
    );
  }();

  PlaybackProgressInfo _progress() => PlaybackProgressInfo(
    itemId: _plan.item.id,
    mediaSourceId: _plan.source.id,
    playSessionId: _plan.playSessionId,
    positionTicks: durationToTicks(position()),
    isPaused: paused(),
    playMethod: _plan.method,
    audioStreamIndex: _plan.audioStreamIndex,
    subtitleStreamIndex: _plan.subtitleStreamIndex,
  );

  Future<void> _send(Future<void> report) async {
    try {
      await report;
    } on Failure catch (e) {
      debugPrint('playback report failed: $e');
    }
  }
}
