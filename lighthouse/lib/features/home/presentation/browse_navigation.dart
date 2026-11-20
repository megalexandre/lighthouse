import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/appearance.dart';
import '../../../core/window_size.dart';
import '../../../l10n/l10n.dart';
import '../../../router.dart';
import '../../auth/application/auth_controller.dart';
import 'floating_top_bar.dart';

/// The browsing page a [BrowseFrame] is on.
enum BrowseTab { home, libraries }

/// The browsing pages' navigation where the floating top bar has no room
/// for the library tabs (below [WindowSize.expanded]): a bar below on a
/// phone, a rail at the left on a tablet or a phone on its side. Home,
/// Libraries, Search and Profile; the top bar keeps only the mark. Wider
/// windows keep the top bar's tabs, and the frame adds nothing.
///
/// Dark whatever the mode, as the top bar is.
class BrowseFrame extends ConsumerWidget {
  const BrowseFrame({super.key, required this.tab, required this.child});

  final BrowseTab tab;
  final Widget child;

  static const homeItem = Key('nav.home');
  static const librariesItem = Key('nav.libraries');
  static const searchItem = Key('nav.search');
  static const profileItem = Key('nav.profile');

  /// Whether the window has this navigation instead of the top bar's tabs.
  static bool shown(BuildContext context) =>
      !WindowSize.of(context).atLeast(WindowSize.expanded);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!shown(context)) return child;
    final dark = ref.watch(appThemeProvider).dark;
    final l10n = context.l10n;
    final items = [
      (homeItem, Icons.home_outlined, Icons.home, l10n.home),
      (
        librariesItem,
        Icons.video_library_outlined,
        Icons.video_library,
        l10n.libraries,
      ),
      (searchItem, Icons.search, Icons.search, l10n.navSearch),
      (profileItem, Icons.person_outline, Icons.person, l10n.profile),
    ];

    void select(int index) => switch (index) {
      0 => context.go(Routes.home),
      1 => context.go(Routes.libraries),
      2 => unawaited(context.push(Routes.search)),
      _ => unawaited(showProfileSheet(context)),
    };

    if (WindowSize.of(context) == WindowSize.compact) {
      return Scaffold(
        body: child,
        bottomNavigationBar: Theme(
          data: dark,
          child: NavigationBar(
            selectedIndex: tab.index,
            onDestinationSelected: select,
            destinations: [
              for (final (key, icon, selected, label) in items)
                NavigationDestination(
                  key: key,
                  icon: Icon(icon),
                  selectedIcon: Icon(selected),
                  label: label,
                ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          Theme(
            data: dark,
            child: Builder(
              builder: (context) => ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                // Clear of a notch at the left (a phone on its side).
                child: SafeArea(
                  right: false,
                  child: NavigationRail(
                    selectedIndex: tab.index,
                    onDestinationSelected: select,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final (key, icon, selected, label) in items)
                        NavigationRailDestination(
                          // The rail's destinations are no widgets: the
                          // key goes on the icon.
                          icon: Icon(icon, key: key),
                          selectedIcon: Icon(selected, key: key),
                          label: Text(label),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            // The rail took the left side and its notch.
            child: MediaQuery.removePadding(
              context: context,
              removeLeft: true,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// The profile menu of the top bar, as a sheet from below: who is signed
/// in, the theme mode, Settings, Sign out.
Future<void> showProfileSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const ProfileSheet(),
    );

class ProfileSheet extends ConsumerWidget {
  const ProfileSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).value?.session;
    final appTheme = ref.watch(appThemeProvider);
    final light = showsLight(context, ref.watch(appearanceProvider).mode);
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeader(
            name: session?.userName ?? '',
            server: session?.server.name,
          ),
          const Divider(height: 1),
          if (appTheme.entry.tokens?.hasLightAndDark ?? false)
            ListTile(
              key: FloatingTopBar.themeItem,
              leading: Icon(light ? Icons.dark_mode : Icons.light_mode),
              title: Text(light ? l10n.darkTheme : l10n.lightTheme),
              onTap: () => switchThemeMode(ref, toLight: !light),
            ),
          ListTile(
            key: FloatingTopBar.settingsItem,
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.settings),
            onTap: () {
              // The sheet closes first: Settings opens on the page.
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              unawaited(router.push(Routes.settings));
            },
          ),
          ListTile(
            key: FloatingTopBar.signOutItem,
            leading: const Icon(Icons.logout),
            title: Text(l10n.signOut),
            onTap: () {
              Navigator.of(context).pop();
              unawaited(ref.read(authControllerProvider.notifier).logout());
            },
          ),
        ],
      ),
    );
  }
}
