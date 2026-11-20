import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/appearance.dart';
import '../../../core/touch.dart';
import '../../../core/window_size.dart';
import '../../../l10n/l10n.dart';
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
///
/// Below [WindowSize.expanded] the navigation is a [BrowseFrame]'s (a bar
/// below, a rail), and this bar keeps only the mark and the page's title.
class FloatingTopBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const FloatingTopBar({
    super.key,
    required this.solid,
    this.activeView,
    this.title,
  });

  /// The page has scrolled (or has no carousel under the bar).
  final bool solid;

  /// The library whose tab is on; null: Home (unless [title] names
  /// another page).
  final String? activeView;

  /// The page's name, for a page that is no tab (Libraries). The tab's
  /// name otherwise; Home has none.
  final String? title;

  static const height = 72.0;

  /// The room the bar takes from the top of the window: [height] plus the
  /// status bar it reaches under on a phone.
  static double extentOf(BuildContext context) =>
      height + MediaQuery.paddingOf(context).top;

  static const homeTab = Key('topBar.home');
  static const mark = Key('topBar.mark');
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
    // The system's Back (Android) closes the open search field, as Esc
    // does, before it leaves the page (or the app, from Home).
    return PopScope(
      canPop: !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeSearch();
      },
      child: Theme(
        data: dark,
        child: Builder(builder: _bar),
      ),
    );
  }

  Widget _bar(BuildContext context) {
    final tokens = context.tokens;
    // Below expanded the library tabs do not fit.
    final narrow = !WindowSize.of(context).atLeast(WindowSize.expanded);
    final views = ref.watch(userViewsProvider).value ?? const [];

    if (narrow) return _frame(context, _narrowContent(context, views));
    final content = Row(
      children: [
        _Mark(
          onTap: () => context.go(Routes.home),
          // A phone has no room for the name beside the tabs and buttons.
          showName: WindowSize.of(context) != WindowSize.compact,
        ),
        SizedBox(width: tokens.space(4)),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Tab(
                  key: FloatingTopBar.homeTab,
                  label: context.l10n.home,
                  on: widget.activeView == null && widget.title == null,
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

    return _frame(context, content);
  }

  /// The mark and the page's title: the navigation is the BrowseFrame's.
  Widget _narrowContent(BuildContext context, List<BaseItemDto> views) {
    final title =
        widget.title ??
        views.where((v) => v.id == widget.activeView).firstOrNull?.name;
    return Row(
      children: [
        _Mark(onTap: () => context.go(Routes.home), showName: title == null),
        if (title != null) ...[
          SizedBox(width: context.tokens.space(3)),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: context.tokens.osdInk),
            ),
          ),
        ],
      ],
    );
  }

  /// The bar's surface around [content]: see-through over the carousel,
  /// floating once [FloatingTopBar.solid].
  Widget _frame(BuildContext context, Widget content) {
    final tokens = context.tokens;
    final narrow = !WindowSize.of(context).atLeast(WindowSize.expanded);
    final solid = widget.solid;
    // Over the carousel's pictures: the player's colours, dark whatever the
    // mode (context.tokens.mediaShade).
    final night = tokens.mediaShade;
    final inset = solid && !narrow ? 52.0 : 0.0;
    final side = narrow ? tokens.space(4) : (solid ? 20.0 : 72.0);
    return SizedBox(
      height: FloatingTopBar.extentOf(context),
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
                color: solid ? tokens.osdSurface : null,
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
                    ? [
                        BoxShadow(
                          color: night.withValues(alpha: 0.45),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              padding: EdgeInsets.symmetric(horizontal: side),
              child: SafeArea(
                bottom: false,
                child: IconTheme(
                  data: IconThemeData(color: tokens.osdInk),
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
    final tokens = context.tokens;
    final radius = BorderRadius.circular(tokens.radiusMd);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      // As tall as a finger needs on touch, inside the 1 px border.
      height: isTouch(context) ? touchTarget + 2 : 40,
      decoration: BoxDecoration(
        color: _searching ? tokens.osdSurface : Colors.transparent,
        border: Border.all(
          color: _searching
              ? tokens.osdInk.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
        borderRadius: radius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: FloatingTopBar.searchButton,
            tooltip: context.l10n.searchTooltip,
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
                        style: TextStyle(color: tokens.osdInk),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: context.l10n.searchHintShort,
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
  const _Mark({required this.onTap, required this.showName});

  final VoidCallback onTap;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      label: context.l10n.home,
      child: GestureDetector(
        key: FloatingTopBar.mark,
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          // The ring alone is too small to tap.
          constraints: isTouch(context)
              ? const BoxConstraints(
                  minWidth: touchTarget,
                  minHeight: touchTarget,
                )
              : const BoxConstraints(),
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
              if (showName) ...[
                const SizedBox(width: 8),
                Text(
                  context.l10n.appTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: context.tokens.osdInk,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ],
          ),
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
    final tokens = context.tokens;
    final radius = BorderRadius.circular(tokens.radiusMd);
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
          foregroundColor: WidgetStatePropertyAll(tokens.osdInk),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => on
                ? tokens.osdInk.withValues(alpha: 0.18)
                : s.contains(WidgetState.hovered)
                ? tokens.osdHover
                : Colors.transparent,
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          textStyle: WidgetStatePropertyAll(
            Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.2),
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
    final light = showsLight(context, appearance.mode);
    final disc = InitialDisc(name: name);
    return MenuAnchor(
      alignmentOffset: const Offset(-240, 8),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainer),
        minimumSize: const WidgetStatePropertyAll(Size(280, 0)),
      ),
      menuChildren: [
        ProfileHeader(name: name, server: session?.server.name),
        const Divider(height: 1),
        if (appTheme.entry.tokens?.hasLightAndDark ?? false)
          MenuItemButton(
            key: FloatingTopBar.themeItem,
            leadingIcon: Icon(light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => switchThemeMode(ref, toLight: !light),
            child: Text(
              light ? context.l10n.darkTheme : context.l10n.lightTheme,
            ),
          ),
        MenuItemButton(
          key: FloatingTopBar.settingsItem,
          leadingIcon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push(Routes.settings),
          child: Text(context.l10n.settings),
        ),
        MenuItemButton(
          key: FloatingTopBar.signOutItem,
          leadingIcon: const Icon(Icons.logout),
          onPressed: onSignOut,
          child: Text(context.l10n.signOut),
        ),
      ],
      builder: (context, controller, _) => Tooltip(
        message: name.isEmpty ? context.l10n.profile : name,
        child: InkWell(
          key: FloatingTopBar.profileButton,
          customBorder: const CircleBorder(),
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          // The disc is too small to tap: a ring of room around it.
          child: isTouch(context)
              ? Padding(
                  padding: EdgeInsets.all((touchTarget - InitialDisc.size) / 2),
                  child: disc,
                )
              : disc,
        ),
      ),
    );
  }
}

/// Whether the app shows its light side in [mode].
bool showsLight(BuildContext context, ThemeMode mode) => switch (mode) {
  ThemeMode.light => true,
  ThemeMode.dark => false,
  ThemeMode.system =>
    MediaQuery.platformBrightnessOf(context) == Brightness.light,
};

/// The theme mode the profile menu switches to.
void switchThemeMode(WidgetRef ref, {required bool toLight}) {
  // The appearance at the tap, not at a build.
  final appearance = ref.read(appearanceProvider);
  unawaited(
    ref
        .read(appearanceProvider.notifier)
        .set(
          appearance.copyWith(mode: toLight ? ThemeMode.light : ThemeMode.dark),
        ),
  );
}

/// The user's initial in a disc of the theme's primary gradient.
class InitialDisc extends StatelessWidget {
  const InitialDisc({super.key, required this.name});

  static const size = 36.0;

  final String name;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
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
        style: TextStyle(
          color: context.tokens.osdInk,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// The top of the profile menu: the disc, the user's name and the server.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.name, required this.server});

  final String name;
  final String? server;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          InitialDisc(name: name),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: text.titleSmall),
              if (server case final String server)
                Text(server, style: text.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
