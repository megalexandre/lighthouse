import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../../auth/application/auth_controller.dart';
import '../../library/application/library_providers.dart';
import '../../library/data/library_repository.dart';
import '../data/playback_plan.dart';
import '../data/playback_repository.dart';
import '../data/player_engine.dart';
import '../data/tracks.dart';
import 'pending_reports.dart';
import 'playback_reporter.dart';
import 'player_carry_over.dart';

/// What to play: an item, from a position (zero = from the start).
typedef PlayRequest = ({String itemId, Duration start});

/// A playback in progress.
@immutable
class PlayerSession {
  const PlayerSession({
    required this.item,
    required this.plan,
    required this.engine,
    this.audioStreamIndex,
    this.subtitleStreamIndex,
    this.ended = false,
    this.interruptedAt,
  });

  final BaseItemDto item;
  final PlaybackPlan plan;
  final PlayerEngine engine;

  /// The tracks shown now, as server indexes; null subtitle = none.
  final int? audioStreamIndex;
  final int? subtitleStreamIndex;

  /// Played to the end; the screen closes.
  final bool ended;

  /// The stream stopped short of the end, here (the connection was lost):
  /// the screen offers to resume from there.
  final Duration? interruptedAt;

  PlayerSession copyWith({
    PlaybackPlan? plan,
    int? Function()? audioStreamIndex,
    int? Function()? subtitleStreamIndex,
    bool? ended,
    Duration? Function()? interruptedAt,
  }) => PlayerSession(
    item: item,
    plan: plan ?? this.plan,
    engine: engine,
    audioStreamIndex: audioStreamIndex == null
        ? this.audioStreamIndex
        : audioStreamIndex(),
    subtitleStreamIndex: subtitleStreamIndex == null
        ? this.subtitleStreamIndex
        : subtitleStreamIndex(),
    ended: ended ?? this.ended,
    interruptedAt: interruptedAt == null ? this.interruptedAt : interruptedAt(),
  );
}

final playerControllerProvider = AsyncNotifierProvider.autoDispose
    .family<PlayerController, PlayerSession, PlayRequest>(PlayerController.new);

/// Runs one playback: asks the server how to play, opens the stream,
/// switches tracks, reports progress, and stops cleanly (resume point
/// saved) on [stop], at the end of the media, or when the screen goes.
class PlayerController extends AsyncNotifier<PlayerSession> {
  PlayerController(this.request);

  final PlayRequest request;

  PlaybackReporter? _reporter;
  PlayerEngine? _engine;
  final _subscriptions = <StreamSubscription<Object?>>[];

  /// The last position seen while playing: after the stream ends, the
  /// player's own position no longer tells where it stopped.
  Duration _lastPosition = Duration.zero;

  /// The subtitle [toggleSubtitles] brings back.
  int? _lastSubtitle;

  /// The session as last published; read by the reporter, which may run
  /// while the provider is being disposed (when `state` is off limits).
  PlayerSession? _session;

  void _publish(PlayerSession session) {
    _session = session;
    if (ref.mounted) state = AsyncData(session);
  }

  PlaybackRepository get _repository => ref.read(playbackRepositoryProvider);

  String get _baseUrl =>
      ref.read(authControllerProvider).value?.session?.server.url ?? '';

  @override
  Future<PlayerSession> build() async {
    ref.onDispose(_release);
    final item = await ref.read(libraryRepositoryProvider).item(request.itemId);
    final plan = await _repository.prepare(item, start: request.start);
    if (!ref.mounted) throw const PlayerError('closed while starting');

    final engine = _engine = ref.read(playerEngineFactoryProvider)();
    _subscriptions
      ..add(
        // Pause / resume: report right away, not at the next tick.
        engine.playingStream.distinct().skip(1).listen((_) {
          unawaited(_reporter?.progress());
        }),
      )
      ..add(engine.positionStream.listen((p) => _lastPosition = p))
      ..add(engine.completedStream.listen((_) => unawaited(_ended())));

    // The volume and mute the user left the last item at.
    final sound = ref.read(playerSoundProvider);
    if (sound != PlayerSoundNotifier.initial) {
      await engine.setVolume(sound.volume);
      await engine.setMuted(sound.muted);
    }
    await _open(engine, plan);
    var session = PlayerSession(item: item, plan: plan, engine: engine);
    session = _session = await _applyInitialTracks(session);
    _startReporting(session);
    _logDiagnostics(engine, item);
    return session;
  }

  Future<void> _open(PlayerEngine engine, PlaybackPlan plan) async {
    log.info(
      'player',
      '${plan.item.type.name} "${plan.item.name}": ${plan.method.name}, '
          'from ${plan.start}, audio ${plan.audioStreamIndex}, '
          'subtitle ${plan.subtitleStreamIndex}, ${plan.url.path}',
    );
    try {
      await engine.open(plan.url, headers: plan.headers, start: plan.start);
    } on Object catch (e) {
      log.error('player', 'could not open the stream', e);
      throw PlayerError('$e');
    }
  }

  /// Shows the tracks the plan starts with (the server's defaults or the
  /// ones asked for), so the player and the reports agree.
  Future<PlayerSession> _applyInitialTracks(PlayerSession session) async {
    final plan = session.plan;
    // In a transcode the server already put the right audio in.
    final audio = plan.audioStreamIndex;
    if (audio != null) {
      if (audioAction(plan, audio) case SelectTrack(:final mpvId)) {
        await session.engine.selectAudioTrack(mpvId);
      }
    }
    final subtitle = plan.subtitleStreamIndex;
    await _showSubtitle(session.engine, plan, subtitle);
    if (subtitle != null) _lastSubtitle = subtitle;
    return session.copyWith(
      audioStreamIndex: () => audio,
      subtitleStreamIndex: () => subtitle,
    );
  }

  Timer? _diagnostics;

  /// mpv's playback figures into the log: once it has settled (5 s), then
  /// every 30 s. What to look at when video is not smooth.
  void _logDiagnostics(PlayerEngine engine, BaseItemDto item) {
    _diagnostics?.cancel();
    if (item.type == BaseItemKind.audio) return;
    Future<void> write() async {
      final figures = await engine.diagnostics();
      if (figures.isEmpty) return;
      log.info(
        'player',
        'mpv: ${[for (final e in figures.entries) '${e.key}=${e.value}'].join(' ')}',
      );
    }

    _diagnostics = Timer(const Duration(seconds: 5), () {
      unawaited(write());
      _diagnostics = Timer.periodic(
        const Duration(seconds: 30),
        (_) => unawaited(write()),
      );
    });
  }

  void _startReporting(PlayerSession session) {
    final engine = session.engine;
    final pending = ref.read(pendingReportsProvider.notifier);
    final reporter = _reporter = PlaybackReporter(
      _repository,
      session.plan,
      onStopUnsent: pending.add,
      status: () {
        final now = _session ?? session;
        return (
          position: engine.position,
          paused: !engine.playing,
          audioStreamIndex: now.audioStreamIndex,
          subtitleStreamIndex: now.subtitleStreamIndex,
          volume: engine.volume,
          muted: engine.muted,
        );
      },
    );
    unawaited(reporter.start());
  }

  /// Switches to the audio track [streamIndex] (a server index).
  Future<void> selectAudio(int streamIndex) async {
    final session = state.value;
    if (session == null || session.audioStreamIndex == streamIndex) return;
    switch (audioAction(session.plan, streamIndex)) {
      case SelectTrack(:final mpvId):
        await session.engine.selectAudioTrack(mpvId);
        _update((s) => s.copyWith(audioStreamIndex: () => streamIndex));
      case _:
        await _restart(
          audio: streamIndex,
          subtitle: session.subtitleStreamIndex,
        );
    }
    unawaited(_reporter?.progress());
  }

  /// Shows the subtitle [streamIndex], or none when null.
  Future<void> selectSubtitle(int? streamIndex) async {
    final session = state.value;
    if (session == null || session.subtitleStreamIndex == streamIndex) return;
    if (streamIndex != null) _lastSubtitle = streamIndex;
    final action = subtitleAction(session.plan, streamIndex, baseUrl: _baseUrl);
    if (action is RestartStream) {
      await _restart(audio: session.audioStreamIndex, subtitle: streamIndex);
    } else {
      await _run(session.engine, action);
      _update((s) => s.copyWith(subtitleStreamIndex: () => streamIndex));
    }
    unawaited(_reporter?.progress());
  }

  /// Next audio track (A), or previous with [back] (Ctrl+A).
  Future<void> cycleAudio({bool back = false}) async {
    final session = state.value;
    if (session == null) return;
    final indexes = [for (final s in session.plan.audioStreams) s.index];
    final next = back
        ? cycleBack(indexes, session.audioStreamIndex)
        : cycle(indexes, session.audioStreamIndex);
    if (next != null) await selectAudio(next);
  }

  /// Next subtitle, "none" included (L), or previous with [back].
  Future<void> cycleSubtitles({bool back = false}) async {
    final session = state.value;
    if (session == null) return;
    final indexes = [for (final s in session.plan.subtitleStreams) s.index];
    if (indexes.isEmpty) return;
    final current = session.subtitleStreamIndex;
    await selectSubtitle(
      back
          ? cycleBack(indexes, current, includeNone: true)
          : cycle(indexes, current, includeNone: true),
    );
  }

  /// Subtitles off, or back on with the last one shown (S).
  Future<void> toggleSubtitles() async {
    final session = state.value;
    if (session == null || session.plan.subtitleStreams.isEmpty) return;
    if (session.subtitleStreamIndex != null) return selectSubtitle(null);
    await selectSubtitle(
      _lastSubtitle ?? session.plan.subtitleStreams.first.index,
    );
  }

  Future<void> setVolume(double volume) async {
    final engine = state.value?.engine;
    if (engine == null) return;
    await engine.setVolume(volume);
    if (engine.muted && volume > 0) await engine.setMuted(false);
    _rememberSound(engine);
  }

  /// Volume up / down by [delta] (0–100 scale).
  Future<void> changeVolume(double delta) async {
    final engine = state.value?.engine;
    if (engine != null) await setVolume((engine.volume + delta).clamp(0, 100));
  }

  Future<void> toggleMute() async {
    final engine = state.value?.engine;
    if (engine == null) return;
    await engine.setMuted(!engine.muted);
    _rememberSound(engine);
  }

  void _rememberSound(PlayerEngine engine) {
    if (ref.mounted) {
      ref
          .read(playerSoundProvider.notifier)
          .set(volume: engine.volume, muted: engine.muted);
    }
  }

  /// A new stream from the server with other tracks, at the same place
  /// (a transcode carries only the tracks it was made with).
  Future<void> _restart({int? audio, int? subtitle, Duration? at}) async {
    final session = state.value;
    if (session == null) return;
    final engine = session.engine;
    final position = at ?? engine.position;
    // The new stream first: if the server cannot give one, the old stream
    // keeps playing and keeps being reported (stopping the reporter first
    // lost the place on the server).
    final plan = await _repository.prepare(
      session.item,
      start: position,
      audioStreamIndex: audio,
      subtitleStreamIndex: subtitle ?? -1,
    );
    if (!ref.mounted) return;
    await _reporter?.stop();
    try {
      await _open(engine, plan);
    } catch (_) {
      // Whatever mpv now plays, the server hears about it again.
      if (ref.mounted) _startReporting(session);
      rethrow;
    }
    final next = session.copyWith(
      plan: plan,
      audioStreamIndex: () => audio,
      subtitleStreamIndex: () => subtitle,
      interruptedAt: () => null,
    );
    // Subtitles that are files on their own still have to be added.
    if (subtitle != null &&
        subtitleAction(plan, subtitle, baseUrl: _baseUrl) is AddSubtitle) {
      await _showSubtitle(engine, plan, subtitle);
    }
    _publish(next);
    _startReporting(next);
  }

  Future<void> _showSubtitle(
    PlayerEngine engine,
    PlaybackPlan plan,
    int? index,
  ) async {
    final action = subtitleAction(plan, index, baseUrl: _baseUrl);
    if (action is! RestartStream) await _run(engine, action);
  }

  Future<void> _run(PlayerEngine engine, TrackAction action) =>
      switch (action) {
        SelectTrack(:final mpvId) => engine.selectSubtitleTrack(mpvId),
        HideSubtitles() => engine.selectSubtitleTrack('no'),
        AddSubtitle(:final url, :final title, :final language) =>
          engine.addSubtitle(url, title: title, language: language),
        RestartStream() => Future.value(),
      };

  void _update(PlayerSession Function(PlayerSession) change) {
    final session = _session;
    if (session != null) _publish(change(session));
  }

  /// Pauses and saves the resume point. The screen awaits this before
  /// closing, so the page it returns to shows the new position.
  Future<void> stop() async {
    await _engine?.pause();
    await _reporter?.stop();
    _invalidateWatchState();
  }

  Future<void> _ended() async {
    final length = _engine?.duration ?? Duration.zero;
    final stoppedAt = _lastPosition;
    if (length > Duration.zero && !reachedTheEnd(stoppedAt, length)) {
      // Not the end: the stream broke off (server or network gone).
      // Keep the place, do not mark it watched, offer to resume.
      log.warning('player', 'stream ended at $stoppedAt of $length');
      await _reporter?.stop(at: stoppedAt);
      _update((s) => s.copyWith(interruptedAt: () => stoppedAt));
      return;
    }
    // Played to the end: report the end, so the server marks it watched
    // whatever position mpv shows after EOF.
    await _reporter?.stop(at: length > Duration.zero ? length : null);
    _invalidateWatchState();
    _update((s) => s.copyWith(ended: true));
  }

  /// After a lost connection: a new stream from where it stopped.
  Future<void> resumeAfterInterruption() async {
    final session = state.value;
    final at = session?.interruptedAt;
    if (session == null || at == null) return;
    await _restart(
      audio: session.audioStreamIndex,
      subtitle: session.subtitleStreamIndex,
      at: at,
    );
  }

  /// The item's position / watched state changed on the server.
  void _invalidateWatchState() {
    if (ref.mounted) ref.read(watchStateProvider.notifier).changed();
  }

  void _release() {
    _diagnostics?.cancel();
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    final engine = _engine;
    final reporter = _reporter;
    // Closed without stop() (e.g. the window): still save the position,
    // read before the engine goes.
    unawaited(() async {
      await reporter?.stop();
      await engine?.dispose();
    }());
  }
}

/// Whether a stream that stopped at [position] of [length] played to its
/// end, rather than broke off: within the last 10 s, or past 95 %.
bool reachedTheEnd(Duration position, Duration length) =>
    position >= length - const Duration(seconds: 10) ||
    position.inMilliseconds >= length.inMilliseconds * 0.95;
