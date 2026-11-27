import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/error_retry.dart';
import '../../../widgets/skeleton.dart';
import '../../home/presentation/browse_navigation.dart';
import '../../home/presentation/floating_top_bar.dart';
import '../application/library_providers.dart';
import 'item_card.dart';

/// The user's libraries as a grid: on a phone or a tablet, where the top
/// bar has no room for them as tabs (Libraries in the BrowseFrame).
class LibrariesScreen extends ConsumerWidget {
  const LibrariesScreen({super.key});

  static const grid = Key('libraries.grid');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final views = ref.watch(userViewsProvider);
    final body = switch (views) {
      AsyncData(value: final views) when views.isEmpty => Center(
        child: Text(context.l10n.noLibraries),
      ),
      // Clear of a notch at the sides.
      AsyncData(value: final views) => SafeArea(
        top: false,
        bottom: false,
        child: _Grid(views: views),
      ),
      AsyncError(:final error) => Center(
        child: ErrorRetry(
          error: error,
          onRetry: () => ref.invalidate(userViewsProvider),
        ),
      ),
      _ => const SafeArea(top: false, bottom: false, child: _Grid(views: null)),
    };
    if (context.tokens.components.topBar != TopBarStyle.floating) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.libraries)),
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
              child: FloatingTopBar(solid: true, title: context.l10n.libraries),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.views});

  /// Null while they load: the cards as a [Skeleton].
  final List<BaseItemDto>? views;

  static const minCardWidth = 140.0;
  static const spacing = 16.0;
  static const margin = 16.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final usable = constraints.maxWidth - 2 * margin;
      final columns = ((usable + spacing) / (minCardWidth + spacing))
          .floor()
          .clamp(1, 6);
      final cardWidth = (usable - (columns - 1) * spacing) / columns;
      const aspect = 16 / 9;
      final views = this.views;
      if (views == null) {
        return Skeleton(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(margin),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              mainAxisExtent: ItemCard.heightFor(context, cardWidth, aspect),
            ),
            // A few libraries: most servers have two to six.
            itemCount: columns.clamp(2, 4),
            itemBuilder: (_, _) =>
                CardSkeleton(width: cardWidth, aspectRatio: aspect),
          ),
        );
      }
      return GridView.builder(
        key: LibrariesScreen.grid,
        // Scrolls past the gesture bar.
        padding: const EdgeInsets.all(margin)
            .copyWith(bottom: margin + MediaQuery.paddingOf(context).bottom),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          mainAxisExtent: ItemCard.heightFor(context, cardWidth, aspect),
        ),
        itemCount: views.length,
        itemBuilder: (_, i) =>
            ItemCard(item: views[i], width: cardWidth, aspectRatio: aspect),
      );
    },
  );
}
