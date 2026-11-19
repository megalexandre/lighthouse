import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/client_info.dart';
import '../../../api/jellyfin_api.dart';
import '../../../api/system.dart';
import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../../auth/application/auth_controller.dart';
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

/// Asks [url] whether it is up. False only when nothing answers.
typedef ServerPing = Future<bool> Function(String url);

final serverPingProvider = Provider<ServerPing>(
  (ref) => (url) async {
    try {
      final client = await ref.read(clientInfoProvider.future);
      await JellyfinApi(baseUrl: url, client: client).publicSystemInfo();
      return true;
    } on ServerUnreachable {
      return false;
    } on Failure {
      return true; // it answered, if oddly
    }
  },
);

final connectionProvider =
    NotifierProvider<ConnectionController, ConnectionStatus>(
      ConnectionController.new,
    );

class ConnectionController extends Notifier<ConnectionStatus> {
  Timer? _timer;

  @override
  ConnectionStatus build() {
    ref.onDispose(() => _timer?.cancel());
    return const ConnectionStatus.online();
  }

  /// Every API call says how it went: [reachable] false only when nothing
  /// answered at all.
  void report({required bool reachable}) {
    if (!ref.mounted) return; // a call that ended after the app scope
    if (reachable) {
      if (!state.reachable) _recovered();
    } else if (state.reachable) {
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
    final url = ref.read(authControllerProvider).value?.server?.url;
    if (url == null) return;
    final up = await ref.read(serverPingProvider)(url);
    if (!ref.mounted || state.reachable) return;
    if (up) {
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
