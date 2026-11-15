import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../auth/application/auth_controller.dart';
import '../application/connection_controller.dart';

/// Above every screen: a strip saying the server cannot be reached while
/// the app keeps trying, with "Retry now". Gone as soon as it answers.
class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({super.key, required this.child});

  static const banner = Key('connection.banner');
  static const retryButton = Key('connection.retry');

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionProvider);
    final server = ref.watch(authControllerProvider).value?.server;
    if (status.reachable) return child;

    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Material(
          key: banner,
          color: scheme.errorContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.cloud_off, color: scheme.onErrorContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Can't reach ${server?.name ?? 'the server'}. "
                      'Trying again…',
                      style: TextStyle(color: scheme.onErrorContainer),
                    ),
                  ),
                  TextButton(
                    key: retryButton,
                    onPressed: () => unawaited(
                      ref.read(connectionProvider.notifier).retryNow(),
                    ),
                    child: const Text('Retry now'),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
