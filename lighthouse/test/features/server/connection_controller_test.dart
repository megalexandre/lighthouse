import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/client_info.dart';
import 'package:lighthouse/api/models/playback_report.dart';
import 'package:lighthouse/app.dart';
import 'package:lighthouse/features/auth/application/auth_controller.dart';
import 'package:lighthouse/features/auth/data/session_client.dart';
import 'package:lighthouse/features/auth/data/session_store.dart';
import 'package:lighthouse/features/library/application/library_providers.dart';
import 'package:lighthouse/features/player/application/pending_reports.dart';
import 'package:lighthouse/features/server/application/connection_controller.dart';

import '../../support/fake_http.dart';
import '../../support/fakes.dart';

void main() {
  test('retry delays: 1, 2, 4... up to 30 s', () {
    expect(
      [for (var i = 0; i < 8; i++) retryDelay(i).inSeconds],
      [1, 2, 4, 8, 16, 30, 30, 30],
    );
  });

  group('the controller', () {
    late TestApp app;

    ProviderContainer start() {
      app = TestApp()
        ..signIn()
        ..serverUp = false;
      app.store.values[SessionStore.serverKey] = jsonEncode(
        testServer.toJson(),
      );
      return ProviderContainer.test(
        overrides: app.overrides,
        retry: noAutomaticRetry,
      );
    }

    test('down: tries again, slower and slower; up: online, reloads', () {
      fakeAsync((clock) {
        final c = start();
        c.read(authControllerProvider.future);
        clock.flushMicrotasks();
        var views = 0;
        c.listen(userViewsProvider, (_, _) => views++);
        clock.flushMicrotasks();
        final connection = c.read(connectionProvider.notifier);

        connection.report(reachable: false);
        expect(c.read(connectionProvider).reachable, isFalse);
        clock.elapse(const Duration(seconds: 1));
        expect(app.pings, [testUrl]);
        clock.elapse(const Duration(seconds: 1));
        expect(app.pings, hasLength(1)); // next after 2 s
        clock.elapse(const Duration(seconds: 1));
        expect(app.pings, hasLength(2));
        expect(c.read(connectionProvider).attempts, 2);

        app.serverUp = true;
        clock.elapse(const Duration(seconds: 4));
        expect(app.pings, hasLength(3));
        expect(c.read(connectionProvider).reachable, isTrue);
        clock.flushMicrotasks();
        expect(views, greaterThan(0), reason: 'the home rows reload');

        // No more tries once back.
        clock.elapse(const Duration(minutes: 1));
        expect(app.pings, hasLength(3));
      });
    });

    test('back at another address: calls and the next start go there', () {
      fakeAsync((clock) {
        final c = start();
        c.read(authControllerProvider.future);
        clock.flushMicrotasks();
        final away = testServer.copyWith(
          url: 'https://jellyfin.example.com',
          addresses: ['fedora.local', 'jellyfin.example.com'],
        );
        app
          ..serverUp = true
          ..serverMovedTo = away;

        c.read(connectionProvider.notifier).report(reachable: false);
        clock.elapse(const Duration(seconds: 1));
        clock.flushMicrotasks();

        expect(c.read(connectionProvider).reachable, isTrue);
        final auth = c.read(authControllerProvider).value!;
        expect(auth.session!.server, away);
        expect(auth.server, away);
        expect(app.store.values[SessionStore.sessionKey], contains(away.url));
      });
    });

    test('an answer from any call ends it, without waiting', () {
      fakeAsync((clock) {
        final c = start();
        final connection = c.read(connectionProvider.notifier)
          ..report(reachable: false)
          ..report(reachable: true);
        expect(c.read(connectionProvider).reachable, isTrue);
        clock.elapse(const Duration(minutes: 1));
        expect(app.pings, isEmpty);
        expect(connection, isNotNull);
      });
    });

    test('Retry now tries at once', () {
      fakeAsync((clock) {
        final c = start();
        c.read(authControllerProvider.future);
        clock.flushMicrotasks();
        app.serverUp = true;
        c.read(connectionProvider.notifier)
          ..report(reachable: false)
          ..retryNow();
        clock.flushMicrotasks();
        expect(app.pings, hasLength(1));
        expect(c.read(connectionProvider).reachable, isTrue);
      });
    });

    test('stop reports kept while down are sent when it is back', () {
      fakeAsync((clock) {
        final c = start();
        c.read(authControllerProvider.future);
        clock.flushMicrotasks();
        const kept = PlaybackStopInfo(
          itemId: 'movie-1',
          mediaSourceId: 'movie-1',
          positionTicks: 42,
        );
        c.read(pendingReportsProvider.notifier).add(kept);
        c.read(connectionProvider.notifier).report(reachable: false);
        app.serverUp = true;
        clock.elapse(const Duration(seconds: 1));
        clock.flushMicrotasks();
        expect(app.playback.stopped, [kept]);
        expect(c.read(pendingReportsProvider), isEmpty);
      });
    });
  });

  group('SessionClient tells whether the server answered', () {
    Future<List<bool>> after(int status) async {
      final seen = <bool>[];
      final client = SessionClient(
        testSession,
        () async => const ClientInfo(deviceId: 'd', device: 'pc'),
        onUnauthorized: () {},
        onReachability: ({required reachable}) => seen.add(reachable),
        adapter: FakeAdapter((_) async => json({}, status: status)),
      );
      try {
        await client.call((api) => api.getJson('/x', (j) => j));
      } on Object {
        // the outcome is what was reported
      }
      return seen;
    }

    test('200, 401, 500: it answered', () async {
      expect(await after(200), [true]);
      expect(await after(401), [true]);
      expect(await after(500), [true]);
    });

    test('nothing listening: it did not', () async {
      final seen = <bool>[];
      final client = SessionClient(
        testSession.copyWith(
          server: testServer.copyWith(url: 'http://127.0.0.1:9'),
        ),
        () async => const ClientInfo(deviceId: 'd', device: 'pc'),
        onUnauthorized: () {},
        onReachability: ({required reachable}) => seen.add(reachable),
      );
      await expectLater(
        client.call((api) => api.getJson('/x', (j) => j)),
        throwsA(anything),
      );
      expect(seen, [false]);
    });
  });
}
