import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/playback_report.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/features/player/application/playback_reporter.dart';

import '../../support/fakes.dart';

void main() {
  late FakePlaybackRepository repo;
  late Duration position;
  late bool paused;

  setUp(() {
    repo = FakePlaybackRepository();
    position = Duration.zero;
    paused = false;
  });

  Future<PlaybackReporter> reporter() async => PlaybackReporter(
    repo,
    await repo.prepare(TestItems.testMovie),
    position: () => position,
    paused: () => paused,
  );

  int ticks(int seconds) => seconds * 10000000;

  test('start, progress every 10 s, stop with the last position', () {
    fakeAsync((clock) {
      late PlaybackReporter r;
      reporter().then((value) => r = value);
      clock.flushMicrotasks();
      r.start();
      clock.flushMicrotasks();

      final start = repo.started.single;
      expect(start.itemId, TestItems.testMovie.id);
      expect(start.playSessionId, 'play-session');
      expect(start.playMethod, PlayMethod.directPlay);
      expect(start.positionTicks, 0);

      position = const Duration(seconds: 9);
      clock.elapse(const Duration(seconds: 9));
      expect(repo.progress, isEmpty);

      position = const Duration(seconds: 10);
      clock.elapse(const Duration(seconds: 1));
      expect(repo.progress.map((p) => p.positionTicks), [ticks(10)]);

      position = const Duration(seconds: 30);
      clock.elapse(const Duration(seconds: 20));
      expect(repo.progress, hasLength(3));

      position = const Duration(seconds: 33);
      r.stop();
      clock.flushMicrotasks();
      expect(repo.stopped.single.positionTicks, ticks(33));
      expect(repo.stopped.single.failed, isFalse);

      // No more ticks after the stop.
      clock.elapse(const Duration(minutes: 1));
      expect(repo.progress, hasLength(3));
    });
  });

  test('a pause is reported as paused, right away', () async {
    final r = await reporter();
    await r.start();
    paused = true;
    position = const Duration(seconds: 4);
    await r.progress();
    expect(repo.progress.single.isPaused, isTrue);
    expect(repo.progress.single.positionTicks, ticks(4));
    await r.stop();
  });

  test('stop reports once, however often it is called', () async {
    final r = await reporter();
    await r.start();
    await Future.wait([r.stop(), r.stop()]);
    await r.stop();
    expect(repo.stopped, hasLength(1));
  });

  test('never started: nothing to stop', () async {
    final r = await reporter();
    await r.stop();
    expect(repo.stopped, isEmpty);
  });

  test('a failing report does not throw', () async {
    final failing = _FailingRepository();
    final r = PlaybackReporter(
      failing,
      await repo.prepare(TestItems.testMovie),
      position: () => position,
      paused: () => paused,
    );
    await r.start();
    await r.progress();
    await r.stop();
  });
}

class _FailingRepository extends FakePlaybackRepository {
  @override
  Future<void> reportStart(PlaybackProgressInfo info) =>
      Future.error(const ServerUnreachable(testUrl));

  @override
  Future<void> reportProgress(PlaybackProgressInfo info) =>
      Future.error(const ServerUnreachable(testUrl));

  @override
  Future<void> reportStopped(PlaybackStopInfo info) =>
      Future.error(const ServerUnreachable(testUrl));
}
