import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../../auth/application/auth_controller.dart';
import '../data/server_info.dart';
import '../data/server_repository.dart';
import 'reload.dart';

/// Whether the server answers. Offline, the app tries again on its own
/// ([retryDelay]) and, once the server is back, reloads what the screens
/// show ([onRecovered]).
@immutable
class ConnectionStatus {
  const ConnectionStatus.online() : reachable = true, attempts = 0;
  const ConnectionStatus.offline({required this.attempts}) : reachable = false;

  final bool reachable;

  /// Failed tries since the server went away.
  final int attempts;
}

/// Wait before try [attempt] (0-based): 1 s, 2 s, 4 s... up to 30 s.
Duration retryDelay(int attempt) =>
    Duration(seconds: math.min(30, math.pow(2, math.min(attempt, 5)).toInt()));

/// Where [server] answers now (see [locateServer]); null when nothing
/// does.
typedef ServerLocator = Future<ServerInfo?> Function(ServerInfo server);

final serverLocatorProvider = Provider<ServerLocator>(
  (ref) => (server) async {
    try {
      return await locateServer(
        server,
        ref.read(serverRepositoryProvider).probe,
      );
    } on Failure {
      return null;
    }
  },
);

final connectionProvider =
    NotifierProvider<ConnectionController, ConnectionStatus>(
      ConnectionController.new,
    );

class ConnectionController extends Notifier<ConnectionStatus> {
  Timer? _timer;

  /// When the server last answered a call.
  DateTime? _lastAnswer;

  @override
  ConnectionStatus build() {
    ref.onDispose(() => _timer?.cancel());
    return const ConnectionStatus.online();
  }

  /// Every API call says how it went: [reachable] false only when nothing
  /// answered at all. A call that fails when the server has answered
  /// others since it was sent ([sentAt]) says nothing about the server:
  /// one stuck connection (a slow TLS handshake, a socket the network
  /// dropped) while the rest go through. Without [sentAt], it is gone.
  void report({required bool reachable, DateTime? sentAt}) {
    if (!ref.mounted) return; // a call that ended after the app scope
    if (reachable) {
      _lastAnswer = DateTime.now();
      if (!state.reachable) _recovered();
    } else if (state.reachable) {
      final answered = _lastAnswer;
      if (sentAt != null && answered != null && answered.isAfter(sentAt)) {
        log.info('connection', 'one call failed while others got through');
        return;
      }
      log.warning('connection', 'server unreachable, retrying');
      state = const ConnectionStatus.offline(attempts: 0);
      _schedule();
    }
  }

  /// "Retry now": a try right away, without waiting for the timer.
  Future<void> retryNow() async {
    if (state.reachable) return;
    _timer?.cancel();
    await _probe();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(retryDelay(state.attempts), () => unawaited(_probe()));
  }

  Future<void> _probe() async {
    final server = ref.read(authControllerProvider).value?.server;
    if (server == null) return;
    // Every address, not only the one in use: the home one may have gone
    // with the network it was on, and the fallback is there for that.
    final found = await ref.read(serverLocatorProvider)(server);
    if (!ref.mounted || state.reachable) return;
    if (found != null) {
      if (found.url != server.url) {
        await ref.read(authControllerProvider.notifier).moved(found);
        if (!ref.mounted) return;
      }
      _recovered();
    } else {
      state = ConnectionStatus.offline(attempts: state.attempts + 1);
      _schedule();
    }
  }

  void _recovered() {
    _timer?.cancel();
    log.info('connection', 'server reachable again');
    state = const ConnectionStatus.online();
    reloadAfterOutage(ref);
  }
}
