import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/failure.dart';
import '../../../widgets/error_retry.dart';
import '../application/library_providers.dart';
import 'item_card.dart';

/// A library or folder as a grid. Pages load as the end of the grid comes
/// near the viewport.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key, required this.parentId});

  static const emptyText = Key('library.empty');

  final String parentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = libraryControllerProvider(parentId);
    final page = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: Text(page.value?.parent.name ?? '')),
      body: switch (page) {
        AsyncData(value: final page) when page.items.isEmpty => const Center(
          child: Text('Nothing here yet.', key: emptyText),
        ),
        AsyncData(value: final page) => _Grid(
          page: page,
          loadMore: () => ref.read(provider.notifier).loadMore(),
        ),
        AsyncError(:final error) => Center(
          child: ErrorRetry(
            error: error,
            onRetry: () => ref.invalidate(provider),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.page, required this.loadMore});

  final LibraryPage page;
  final VoidCallback loadMore;

  static const maxCardWidth = 180.0;
  static const spacing = 16.0;

  /// How many cards before the end the next page is asked for.
  static const prefetch = 30;

  /// Asks for the next page after this frame (not during build: loading
  /// changes provider state). After a failure, only Retry asks again.
  void _requestMore() {
    if (!page.hasMore || page.loadingMore || page.moreError != null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => loadMore());
  }

  @override
  Widget build(BuildContext context) {
    final aspect = cardAspectRatio(page.items.first.type);
    return LayoutBuilder(
      builder: (context, constraints) {
        final usable = constraints.maxWidth - 2 * 24;
        final columns = ((usable + spacing) / (maxCardWidth + spacing))
            .ceil()
            .clamp(2, 12);
        final cardWidth = (usable - (columns - 1) * spacing) / columns;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  mainAxisExtent: ItemCard.heightFor(cardWidth, aspect),
                ),
                itemCount: page.items.length,
                itemBuilder: (_, i) {
                  // The grid only builds cards near the viewport: building
                  // one of the last ones means the end is in sight.
                  if (i >= page.items.length - prefetch) _requestMore();
                  return ItemCard(
                    item: page.items[i],
                    width: cardWidth,
                    aspectRatio: aspect,
                  );
                },
              ),
            ),
            // Not lazy (always built), so the spinner only exists while a
            // page loads: an idle one would animate off screen forever.
            if (page.moreError case final Failure error)
              SliverToBoxAdapter(
                child: Center(
                  child: ErrorRetry(error: error, onRetry: loadMore),
                ),
              )
            else if (page.loadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }
}
