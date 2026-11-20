import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/l10n.dart';
import '../../../router.dart';
import '../../../widgets/error_retry.dart';
import '../../../widgets/row_arrows.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/data/session.dart';
import '../../library/application/library_providers.dart';
import '../../library/presentation/item_card.dart';
import 'floating_top_bar.dart';
import 'hero_carousel.dart';

/// Signed-in landing page: the user's libraries, then Continue watching,
/// Next up and what was added lately to each library. A row with nothing
/// in it is left out; a row that fails says so without hiding the others.
///
/// The theme picks its top (`components`): a plain app bar, or the
/// floating top bar with the libraries as tabs (then the libraries row is
/// left out); and maybe a carousel of what was added lately above the rows.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const signOutButton = Key('home.signOut');
  static const searchButton = Key('home.search');
  static const settingsButton = Key('home.settings');
  static const viewsRow = Key('home.views');
  static const hero = Key('home.hero');
  static const resumeRow = Key('home.resume');
  static const nextUpRow = Key('home.nextUp');
  static const resumeBooksRow = Key('home.resumeBooks');
  static Key latestRow(String viewId) => Key('home.latest.$viewId');

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scroll = ScrollController();

  /// The page scrolled: the floating top bar turns solid.
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final scrolled = _scroll.offset > 8;
      if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).value?.session;
    final views = ref.watch(userViewsProvider);

    void openSearch() => context.push(Routes.search);

    // Ctrl+F searches, as in jellyfin-desktop's keyboard.json.
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            openSearch,
      },
      child: Focus(
        autofocus: true,
        child: context.tokens.components.topBar == TopBarStyle.floating
            ? _floating(context, views)
            : _scaffold(context, ref, session, views, openSearch),
      ),
    );
  }

  /// The page under the floating top bar: the carousel (when the theme
  /// has one) runs under the bar, the rows follow.
  Widget _floating(BuildContext context, AsyncValue<List<BaseItemDto>> views) {
    final hero = context.tokens.components.homeHero == HomeHeroStyle.carousel
        ? ref.watch(featuredProvider).value
        : null;
    final withHero = hero != null && hero.isNotEmpty;
    final barExtent = FloatingTopBar.extentOf(context);
    return Scaffold(
      body: Stack(
        children: [
          switch (views) {
            AsyncData(value: final views) => RefreshIndicator(
              edgeOffset: barExtent,
              onRefresh: () async => _refresh(),
              child: ListView(
                controller: _scroll,
                padding: EdgeInsets.only(
                  top: withHero ? 0 : barExtent + 16,
                  // Scrolls past the gesture bar.
                  bottom: 16 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  if (withHero) HeroCarousel(key: HomeScreen.hero, items: hero),
                  // The libraries are the bar's tabs: no row for them.
                  if (views.isEmpty) _noLibraries,
                  ..._rows(views),
                ],
              ),
            ),
            AsyncError(:final error) => Center(
              child: ErrorRetry(
                error: error,
                onRetry: () => ref.invalidate(userViewsProvider),
              ),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FloatingTopBar(solid: _scrolled || !withHero),
          ),
        ],
      ),
    );
  }

  void _refresh() => ref
    ..invalidate(userViewsProvider)
    ..invalidate(featuredProvider)
    ..invalidate(resumeProvider)
    ..invalidate(resumeBooksProvider)
    ..invalidate(nextUpProvider)
    ..invalidate(continueSeriesProvider)
    ..invalidate(latestProvider);

  Widget get _noLibraries => Padding(
    padding: const EdgeInsets.all(24) + _sides(context),
    child: Text(context.l10n.noLibraries),
  );

  /// Continue watching, Next up, Continue reading, then each library's
  /// latest.
  List<Widget> _rows(List<BaseItemDto> views) => [
    ItemRow(
      key: HomeScreen.resumeRow,
      title: context.l10n.continueWatching,
      items: ref.watch(resumeProvider),
      onRetry: () => ref.invalidate(resumeProvider),
      cardWidth: 240,
      aspectRatio: 16 / 9,
    ),
    ItemRow(
      key: HomeScreen.nextUpRow,
      title: context.l10n.nextUp,
      items: ref.watch(nextUpProvider),
      onRetry: () => ref.invalidate(nextUpProvider),
      cardWidth: 240,
      aspectRatio: 16 / 9,
    ),
    ItemRow(
      key: HomeScreen.resumeBooksRow,
      title: context.l10n.continueReading,
      items: ref.watch(resumeBooksProvider),
      onRetry: () => ref.invalidate(resumeBooksProvider),
      aspectRatio: 2 / 3,
    ),
    for (final view in views)
      ItemRow(
        key: HomeScreen.latestRow(view.id),
        title: context.l10n.latestIn(view.name),
        items: ref.watch(latestProvider(view.id)),
        onRetry: () => ref.invalidate(latestProvider(view.id)),
        aspectRatio: view.collectionType == 'music' ? 1 : 2 / 3,
      ),
  ];

  Widget _scaffold(
    BuildContext context,
    WidgetRef ref,
    Session? session,
    AsyncValue<List<BaseItemDto>> views,
    VoidCallback openSearch,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(session?.server.name ?? context.l10n.appTitle),
        actions: [
          IconButton(
            key: HomeScreen.searchButton,
            tooltip: context.l10n.searchTooltip,
            icon: const Icon(Icons.search),
            onPressed: openSearch,
          ),
          if (session != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(child: Text(session.userName)),
            ),
          IconButton(
            key: HomeScreen.settingsButton,
            tooltip: context.l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
          IconButton(
            key: HomeScreen.signOutButton,
            tooltip: context.l10n.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: switch (views) {
        AsyncData(value: final views) => RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: EdgeInsets.only(
              top: 16,
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              if (views.isEmpty)
                _noLibraries
              else
                ItemRow(
                  key: HomeScreen.viewsRow,
                  title: context.l10n.myMedia,
                  items: AsyncData(views),
                  cardWidth: 240,
                ),
              ..._rows(views),
            ],
          ),
        ),
        AsyncError(:final error) => Center(
          child: ErrorRetry(
            error: error,
            onRetry: () => ref.invalidate(userViewsProvider),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// A titled, horizontally scrolling row of cards.
class ItemRow extends StatelessWidget {
  const ItemRow({
    super.key,
    required this.title,
    required this.items,
    this.onRetry,
    this.cardWidth = 140,
    this.aspectRatio,
  });

  final String title;
  final AsyncValue<List<BaseItemDto>> items;
  final VoidCallback? onRetry;
  final double cardWidth;

  /// Same for every card, so the row lines up; defaults to the first
  /// item's kind.
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final Widget body;
    switch (items) {
      case AsyncData(value: final items) when items.isEmpty:
        return const SizedBox.shrink();
      case AsyncData(value: final items):
        final aspect = aspectRatio ?? cardAspectRatio(items.first.type);
        // Room above and below: a card grows on hover.
        body = SizedBox(
          height:
              ItemCard.heightFor(context, cardWidth, aspect) +
              2 * ItemCard.hoverRoom,
          // Arrows at the ends, when the theme has them.
          child: RowArrows(
            inset: ItemCard.hoverRoom,
            builder: (controller) => ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: ItemCard.hoverRoom,
                  ) +
                  _sides(context),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (_, i) => ItemCard(
                item: items[i],
                width: cardWidth,
                aspectRatio: aspect,
              ),
            ),
          ),
        );
      case AsyncError(:final error):
        body = Padding(
          padding: _sides(context),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ErrorRetry(error: error, onRetry: onRetry ?? () {}),
          ),
        );
      default:
        body = const SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator()),
        );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8) + _sides(context),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          body,
        ],
      ),
    );
  }
}

/// What a notch or a rounded corner covers at the window's sides (a phone
/// on its side). The rows still scroll under it, edge to edge; their first
/// card and their title start clear of it.
EdgeInsets _sides(BuildContext context) {
  final padding = MediaQuery.paddingOf(context);
  return EdgeInsets.only(left: padding.left, right: padding.right);
}
