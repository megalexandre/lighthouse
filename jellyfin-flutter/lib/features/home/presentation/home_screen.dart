import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../auth/application/auth_controller.dart';

/// Signed-in landing page. F2 fills it with Continue Watching, Next Up and
/// the libraries.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const signOutButton = Key('home.signOut');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).value?.session;
    return Scaffold(
      appBar: AppBar(
        title: Text(session?.server.name ?? 'Jellyfin'),
        actions: [
          IconButton(
            key: signOutButton,
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Text(session == null ? '' : 'Signed in as ${session.userName}'),
      ),
    );
  }
}
