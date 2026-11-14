import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const _Placeholder()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Replaced by the connect/login screens in F1.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Jellyfin')));
  }
}
