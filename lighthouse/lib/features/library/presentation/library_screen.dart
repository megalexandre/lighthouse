import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/failure.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/window_size.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/error_retry.dart';
import '../../../widgets/skeleton.dart';
import '../../home/presentation/browse_navigation.dart';
import '../../home/presentation/floating_top_bar.dart';
import '../application/library_providers.dart';
import 'item_card.dart';

/// A library or folder as a grid. Pages load as the end of the grid comes
/// near the viewport.
///
/// With the floating top bar (the theme's `components.topBar`), a library
/// opened from its tab keeps that bar, its tab on; a folder inside one has
/// the plain app bar with Back.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key, required this.parentId});

  static const emptyText = Key('library.empty');

  final String parentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = libraryControllerProvider(parentId);
    final page = ref.watch(provider);
    final isTab =
        context.tokens.components.topBar == TopBarStyle.floating &&
        (ref.watch(userViewsProvider).value ?? const []).any(
          (v) => v.id == parentId,
        );

    final body = switch (page) {
      AsyncData(value: final page) when page.items.isEmpty => Center(
        child: Text(context.l10n.nothingHere, key: emptyText),
      ),
      // Clear of a notch at the sides; the bottom (the gesture bar) is
      // scrolled past instead (_Grid).
      AsyncData(value: final page) => SafeArea(
        top: false,
        bottom: false,
        child: _Grid(
          page: page,
          loadMore: () => ref.read(provider.notifier).loadMore(),
        ),
      ),
      AsyncError(:final error) => Center(
        child: ErrorRetry(
          error: error,
          onRetry: () => ref.invalidate(provider),
        ),
      ),
      _ => const SafeArea(top: false, bottom: false, child: _Grid.skeleton()),
    };
    if (!isTab) {
      return Scaffold(
        appBar: AppBar(title: Text(page.value?.parent.name ?? '')),
        body: body,
      );
    }
    return BrowseFrame(
      tab: BrowseTab.libraries,
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: FloatingTopBar.extentOf(context)),
              child: body,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FloatingTopBar(solid: true, activeView: parentId),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required LibraryPage this.page, required this.loadMore});

  /// The first page still loading: the grid's cards as a [Skeleton].
  const _Grid.skeleton() : page = null, loadMore = _none;

  static void _none() {}

  final LibraryPage? page;
  final VoidCallback loadMore;

  static const maxCardWidth = 180.0;

  /// On a phone: three posters across.
  static const compactMaxCardWidth = 120.0;
  static const spacing = 16.0;

  /// How many cards before the end the next page is asked for.
  static const prefetch = 30;

  /// Asks for the next page after this frame (not during build: loading
  /// changes provider state). After a failure, only Retry asks again.
  void _requestMore(LibraryPage page) {
    if (!page.hasMore || page.loadingMore || page.moreError != null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => loadMore());
  }

  @override
  Widget build(BuildContext context) {
    final page = this.page;
    // Not known before the first page: posters, the most common.
    final aspect = page == null
        ? 2 / 3
        : cardAspectRatio(page.items.first.type);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = WindowSize.ofWidth(constraints.maxWidth);
        final margin = size.margin;
        final maxWidth = size == WindowSize.compact
            ? compactMaxCardWidth
            : maxCardWidth;
        final usable = constraints.maxWidth - 2 * margin;
        final columns = ((usable + spacing) / (maxWidth + spacing))
            .ceil()
            .clamp(2, 12);
        final cardWidth = (usable - (columns - 1) * spacing) / columns;
        final cardHeight = ItemCard.heightFor(context, cardWidth, aspect);
        Widget skeletonRow() => Skeleton(
          child: Row(
            spacing: spacing,
            children: [
              for (var i = 0; i < columns; i++)
                CardSkeleton(width: cardWidth, aspectRatio: aspect),
            ],
          ),
        );

        if (page == null) {
          // Enough rows to fill the window, not scrolling.
          final rows = (constraints.maxHeight / (cardHeight + spacing)).ceil();
          return ClipRect(
            child: OverflowBox(
              alignment: Alignment.topLeft,
              maxHeight: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(margin),
                child: Column(
                  spacing: spacing,
                  children: [for (var i = 0; i < rows; i++) skeletonRow()],
                ),
              ),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(
                margin,
              ).copyWith(bottom: margin + MediaQuery.paddingOf(context).bottom),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  mainAxisExtent: cardHeight,
                ),
                itemCount: page.items.length,
                itemBuilder: (_, i) {
                  // The grid only builds cards near the viewport: building
                  // one of the last ones means the end is in sight.
                  if (i >= page.items.length - prefetch) _requestMore(page);
                  return ItemCard(
                    item: page.items[i],
                    width: cardWidth,
                    aspectRatio: aspect,
                  );
                },
              ),
            ),
            // Not lazy (always built), so the skeleton only exists while a
            // page loads: an idle one would animate off screen forever.
            if (page.moreError case final Failure error)
              SliverToBoxAdapter(
                child: Center(
                  child: ErrorRetry(error: error, onRetry: loadMore),
                ),
              )
            else if (page.loadingMore)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: margin).copyWith(
                  bottom: margin + MediaQuery.paddingOf(context).bottom,
                ),
                sliver: SliverToBoxAdapter(child: skeletonRow()),
              ),
          ],
        );
      },
    );
  }
}
