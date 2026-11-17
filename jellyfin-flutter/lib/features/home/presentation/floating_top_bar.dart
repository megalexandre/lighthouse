import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/appearance.dart';
import '../../../router.dart';
import '../../auth/application/auth_controller.dart';
import '../../library/application/library_providers.dart';

/// The top of the browsing screens when the theme asks for it
/// (`components.topBar: floating`): a mark, the libraries as tabs, search
/// that opens into a field, and a profile menu (theme mode, Settings, Sign
/// out). Always dark, whatever the mode.
///
/// Over the home carousel it is see-through; once the page scrolls
/// ([solid]) it floats: inset from the sides, rounded below, blurred, with
/// a shadow.
class FloatingTopBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const FloatingTopBar({super.key, required this.solid, this.activeView});

  /// The page has scrolled (or has no carousel under the bar).
  final bool solid;

  /// The library whose tab is on; null: Home.
  final String? activeView;

  static const height = 72.0;

  static const homeTab = Key('topBar.home');
  static Key tab(String viewId) => Key('topBar.tab.$viewId');
  static const searchButton = Key('topBar.search');
  static const searchField = Key('topBar.searchField');
  static const profileButton = Key('topBar.profile');
  static const themeItem = Key('topBar.theme');
  static const settingsItem = Key('topBar.settings');
  static const signOutItem = Key('topBar.signOut');

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  ConsumerState<FloatingTopBar> createState() => _FloatingTopBarState();
}

class _FloatingTopBarState extends ConsumerState<FloatingTopBar> {
  bool _searching = false;
  final _query = TextEditingController();
  final _queryFocus = FocusNode();

  @override
  void dispose() {
    _query.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searching = true);
    _queryFocus.requestFocus();
  }

  void _closeSearch() {
    _query.clear();
    setState(() => _searching = false);
  }

  void _search(String text) {
    final term = text.trim();
    if (term.isEmpty) return;
    _closeSearch();
    context.push(Routes.searchFor(term));
  }

  @override
  Widget build(BuildContext context) {
    final dark = ref.watch(appThemeProvider).dark;
    return Theme(
      data: dark,
      child: Builder(builder: _bar),
    );
  }

  Widget _bar(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width < 760;
    final views = ref.watch(userViewsProvider).value ?? const [];
    final solid = widget.solid;
    const night = Color(0xFF00050D);
    final inset = solid && !narrow ? 52.0 : 0.0;
    final side = narrow ? tokens.space(4) : (solid ? 20.0 : 72.0);

    final content = Row(
      children: [
        _Mark(onTap: () => context.go(Routes.home)),
        SizedBox(width: tokens.space(4)),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Tab(
                  key: FloatingTopBar.homeTab,
                  label: 'Home',
                  on: widget.activeView == null,
                  onTap: () => context.go(Routes.home),
                ),
                for (final view in views)
                  _Tab(
                    key: FloatingTopBar.tab(view.id),
                    label: view.name,
                    on: widget.activeView == view.id,
                    onTap: () => context.go(Routes.library(view.id)),
                  ),
              ],
            ),
          ),
        ),
        _searchBox(context),
        SizedBox(width: tokens.space(2)),
        _Profile(onSignOut: ref.read(authControllerProvider.notifier).logout),
      ],
    );

    return SizedBox(
      height: FloatingTopBar.height,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: inset),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(solid && !narrow ? 14 : 0),
          ),
          child: BackdropFilter(
            filter: solid
                ? ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14)
                : ui.ImageFilter.blur(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: solid ? const Color(0xEB121A22) : null,
                gradient: solid
                    ? null
                    : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          night.withValues(alpha: 0.85),
                          night.withValues(alpha: 0),
                        ],
                      ),
                boxShadow: solid
                    ? const [
                        BoxShadow(
                          color: Color(0x73000000),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              padding: EdgeInsets.symmetric(horizontal: side),
              child: SafeArea(
                bottom: false,
                child: IconTheme(
                  data: IconThemeData(color: theme.colorScheme.onSurface),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBox(BuildContext context) {
    final radius = BorderRadius.circular(context.tokens.radiusMd);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 40,
      decoration: BoxDecoration(
        color: _searching ? const Color(0xD900050D) : Colors.transparent,
        border: Border.all(
          color: _searching
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
        borderRadius: radius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: FloatingTopBar.searchButton,
            tooltip: 'Search (Ctrl+F)',
            icon: const Icon(Icons.search),
            onPressed: _searching ? () => _search(_query.text) : _openSearch,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: _searching ? 240 : 0,
              child: _searching
                  ? CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.escape):
                            _closeSearch,
                      },
                      child: TextField(
                        key: FloatingTopBar.searchField,
                        controller: _query,
                        focusNode: _queryFocus,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _search,
                        onTapOutside: (_) {
                          if (_query.text.isEmpty) _closeSearch();
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          isDense: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'Titles, people, genres',
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// The app's mark: a ring (the accent, open at one side) and the name.
class _Mark extends StatelessWidget {
  const _Mark({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      label: 'Home',
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: -0.785,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border(
                    top: BorderSide(color: accent, width: 3),
                    left: BorderSide(color: accent, width: 3),
                    bottom: BorderSide(color: accent, width: 3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'jellyfin',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    super.key,
    required this.label,
    required this.on,
    required this.onTap,
  });

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.tokens.radiusMd);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: TextButton(
        onPressed: onTap,
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: radius),
          ),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => on
                ? Colors.white.withValues(alpha: 0.18)
                : s.contains(WidgetState.hovered)
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          textStyle: WidgetStatePropertyAll(
            Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

/// The user's initial in a disc; its menu: name and server, the theme
/// mode, Settings, Sign out.
class _Profile extends ConsumerWidget {
  const _Profile({required this.onSignOut});

  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).value?.session;
    final name = session?.userName ?? '';
    final scheme = Theme.of(context).colorScheme;
    final appearance = ref.watch(appearanceProvider);
    final appTheme = ref.watch(appThemeProvider);
    final light = switch (appearance.mode) {
      ThemeMode.light => true,
      ThemeMode.dark => false,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.light,
    };
    final disc = Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.inversePrimary, scheme.primary],
        ),
      ),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return MenuAnchor(
      alignmentOffset: const Offset(-240, 8),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainer),
        minimumSize: const WidgetStatePropertyAll(Size(280, 0)),
      ),
      menuChildren: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              disc,
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleSmall),
                  if (session != null)
                    Text(
                      session.server.name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (appTheme.entry.tokens?.hasLightAndDark ?? false)
          MenuItemButton(
            key: FloatingTopBar.themeItem,
            leadingIcon: Icon(light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => ref
                .read(appearanceProvider.notifier)
                .set(
                  appearance.copyWith(
                    mode: light ? ThemeMode.dark : ThemeMode.light,
                  ),
                ),
            child: Text(light ? 'Dark theme' : 'Light theme'),
          ),
        MenuItemButton(
          key: FloatingTopBar.settingsItem,
          leadingIcon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push(Routes.settings),
          child: const Text('Settings'),
        ),
        MenuItemButton(
          key: FloatingTopBar.signOutItem,
          leadingIcon: const Icon(Icons.logout),
          onPressed: onSignOut,
          child: const Text('Sign out'),
        ),
      ],
      builder: (context, controller, _) => Tooltip(
        message: name.isEmpty ? 'Profile' : name,
        child: InkWell(
          key: FloatingTopBar.profileButton,
          customBorder: const CircleBorder(),
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: disc,
        ),
      ),
    );
  }
}
