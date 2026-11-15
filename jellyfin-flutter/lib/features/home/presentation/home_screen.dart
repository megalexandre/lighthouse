import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../router.dart';
import '../../../widgets/error_retry.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/data/session.dart';
import '../../library/application/library_providers.dart';
import '../../library/presentation/item_card.dart';

/// Signed-in landing page: the user's libraries, then Continue watching,
/// Next up and what was added lately to each library. A row with nothing
/// in it is left out; a row that fails says so without hiding the others.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const signOutButton = Key('home.signOut');
  static const searchButton = Key('home.search');
  static const settingsButton = Key('home.settings');
  static const viewsRow = Key('home.views');
  static const resumeRow = Key('home.resume');
  static const nextUpRow = Key('home.nextUp');
  static Key latestRow(String viewId) => Key('home.latest.$viewId');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        child: _scaffold(context, ref, session, views, openSearch),
      ),
    );
  }

  Widget _scaffold(
    BuildContext context,
    WidgetRef ref,
    Session? session,
    AsyncValue<List<BaseItemDto>> views,
    VoidCallback openSearch,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(session?.server.name ?? 'Jellyfin'),
        actions: [
          IconButton(
            key: searchButton,
            tooltip: 'Search (Ctrl+F)',
            icon: const Icon(Icons.search),
            onPressed: openSearch,
          ),
          if (session != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(child: Text(session.userName)),
            ),
          IconButton(
            key: settingsButton,
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
          IconButton(
            key: signOutButton,
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: switch (views) {
        AsyncData(value: final views) => RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(userViewsProvider)
              ..invalidate(resumeProvider)
              ..invalidate(nextUpProvider)
              ..invalidate(latestProvider);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              if (views.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No libraries yet. Add one on the server, or ask its '
                    'administrator for access.',
                  ),
                )
              else
                ItemRow(
                  key: viewsRow,
                  title: 'My media',
                  items: AsyncData(views),
                  cardWidth: 240,
                ),
              ItemRow(
                key: resumeRow,
                title: 'Continue watching',
                items: ref.watch(resumeProvider),
                onRetry: () => ref.invalidate(resumeProvider),
                cardWidth: 240,
                aspectRatio: 16 / 9,
              ),
              ItemRow(
                key: nextUpRow,
                title: 'Next up',
                items: ref.watch(nextUpProvider),
                onRetry: () => ref.invalidate(nextUpProvider),
                cardWidth: 240,
                aspectRatio: 16 / 9,
              ),
              for (final view in views)
                ItemRow(
                  key: latestRow(view.id),
                  title: 'Latest in ${view.name}',
                  items: ref.watch(latestProvider(view.id)),
                  onRetry: () => ref.invalidate(latestProvider(view.id)),
                  aspectRatio: view.collectionType == 'music' ? 1 : 2 / 3,
                ),
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
        body = SizedBox(
          height: ItemCard.heightFor(cardWidth, aspect),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (_, i) =>
                ItemCard(item: items[i], width: cardWidth, aspectRatio: aspect),
          ),
        );
      case AsyncError(:final error):
        body = Align(
          alignment: Alignment.centerLeft,
          child: ErrorRetry(error: error, onRetry: onRetry ?? () {}),
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
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          body,
        ],
      ),
    );
  }
}
