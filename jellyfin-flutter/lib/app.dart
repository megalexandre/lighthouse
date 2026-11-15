import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'router.dart';

/// Retry policy of the app's ProviderScope: none. Riverpod would otherwise
/// retry a failing request up to 10 times with growing delays, showing a
/// spinner for half a minute when the server is down; the screens show the
/// error with a Retry button instead.
Duration? noAutomaticRetry(int retryCount, Object error) => null;

/// Jellyfin purple, as on the official clients.
const jellyfinPurple = Color(0xFFAA5CC3);

class JellyfinApp extends ConsumerWidget {
  const JellyfinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Jellyfin',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: jellyfinPurple,
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
