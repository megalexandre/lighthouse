import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/theme/appearance.dart';
import 'features/server/presentation/connection_banner.dart';
import 'l10n/l10n.dart';
import 'router.dart';

/// Retry policy of the app's ProviderScope: none. Riverpod would otherwise
/// retry a failing request up to 10 times with growing delays, showing a
/// spinner for half a minute when the server is down; the screens show the
/// error with a Retry button instead.
Duration? noAutomaticRetry(int retryCount, Object error) => null;

class JellyfinApp extends ConsumerWidget {
  const JellyfinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The look comes from a design system's tokens (docs/THEMES.md).
    final theme = ref.watch(appThemeProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      locale: ref.watch(appLanguageProvider).locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: appLocalizationsDelegates,
      debugShowCheckedModeBanner: false,
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: theme.mode,
      routerConfig: ref.watch(routerProvider),
      builder: (_, child) =>
          ConnectionBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
