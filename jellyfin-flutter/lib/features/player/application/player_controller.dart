import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/failure.dart';
import '../../library/application/library_providers.dart';
import '../../library/data/library_repository.dart';
import '../data/playback_plan.dart';
import '../data/playback_repository.dart';
import '../data/player_engine.dart';
import 'playback_reporter.dart';

/// What to play: an item, from a position (zero = from the start).
typedef PlayRequest = ({String itemId, Duration start});

/// A playback in progress.
@immutable
class PlayerSession {
  const PlayerSession({
    required this.item,
    required this.plan,
    required this.engine,
    this.ended = false,
  });

  final BaseItemDto item;
  final PlaybackPlan plan;
  final PlayerEngine engine;

  /// Played to the end; the screen closes.
  final bool ended;
}

final playerControllerProvider = AsyncNotifierProvider.autoDispose
    .family<PlayerController, PlayerSession, PlayRequest>(PlayerController.new);

/// Runs one playback: asks the server how to play, opens the stream,
/// reports progress, and stops cleanly (resume point saved) on [stop],
/// at the end of the media, or when the screen goes away.
class PlayerController extends AsyncNotifier<PlayerSession> {
  PlayerController(this.request);

  final PlayRequest request;

  PlaybackReporter? _reporter;
  PlayerEngine? _engine;
  final _subscriptions = <StreamSubscription<Object?>>[];

  @override
  Future<PlayerSession> build() async {
    ref.onDispose(_release);
    final item = await ref.read(libraryRepositoryProvider).item(request.itemId);
    final repository = ref.read(playbackRepositoryProvider);
    final plan = await repository.prepare(item, start: request.start);
    if (!ref.mounted) throw const PlayerError('closed while starting');

    final engine = _engine = ref.read(playerEngineFactoryProvider)();
    final reporter = _reporter = PlaybackReporter(
      repository,
      plan,
      position: () => engine.position,
      paused: () => !engine.playing,
    );
    _subscriptions
      ..add(
        // Pause / resume: report right away, not at the next tick.
        engine.playingStream.distinct().skip(1).listen((_) {
          unawaited(reporter.progress());
        }),
      )
      ..add(engine.completedStream.listen((_) => unawaited(_ended())));

    try {
      await engine.open(plan.url, headers: plan.headers, start: plan.start);
    } on Object catch (e) {
      throw PlayerError('$e');
    }
    unawaited(reporter.start());
    return PlayerSession(item: item, plan: plan, engine: engine);
  }

  /// Pauses and saves the resume point. The screen awaits this before
  /// closing, so the page it returns to shows the new position.
  Future<void> stop() async {
    await _engine?.pause();
    await _reporter?.stop();
    _invalidateWatchState();
  }

  Future<void> _ended() async {
    await _reporter?.stop();
    _invalidateWatchState();
    final session = state.value;
    if (session != null && ref.mounted) {
      state = AsyncData(
        PlayerSession(
          item: session.item,
          plan: session.plan,
          engine: session.engine,
          ended: true,
        ),
      );
    }
  }

  /// The item's position / watched state changed on the server.
  void _invalidateWatchState() {
    if (!ref.mounted) return;
    ref
      ..invalidate(itemProvider(request.itemId))
      ..invalidate(resumeProvider)
      ..invalidate(nextUpProvider);
  }

  void _release() {
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
