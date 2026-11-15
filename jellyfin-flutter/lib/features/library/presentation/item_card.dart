import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../router.dart';
import '../data/library_repository.dart';

/// Shape of an item's picture: posters for movies and series, squares for
/// music, wide for episodes and libraries.
double cardAspectRatio(BaseItemKind kind) => switch (kind) {
  BaseItemKind.episode ||
  BaseItemKind.video ||
  BaseItemKind.collectionFolder ||
  BaseItemKind.userView => 16 / 9,
  BaseItemKind.musicAlbum ||
  BaseItemKind.musicArtist ||
  BaseItemKind.audio => 1,
  _ => 2 / 3,
};

/// Opens [item]: a library or folder as a grid, anything else as a detail
/// page. Pushed, so Back returns to where the user was.
void openItem(BuildContext context, BaseItemDto item) => context.push(
  item.type.isFolder ? Routes.library(item.id) : Routes.item(item.id),
);

/// The item's image, or an icon for its kind while there is none.
class ItemImage extends ConsumerWidget {
  const ItemImage({super.key, required this.item, required this.width});

  final BaseItemDto item;

  /// Logical width it is shown at; the server scales the image to fit.
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pixels = (width * MediaQuery.devicePixelRatioOf(context)).round();
    final url = ref
        .watch(libraryRepositoryProvider)
        .imageUrl(item, maxWidth: pixels);
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(child: Icon(_iconFor(item), size: width / 4)),
    );
    if (url == null) return placeholder;
    return Image.network(
      url.toString(),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
      frameBuilder: (_, child, frame, loaded) =>
          loaded || frame != null ? child : placeholder,
    );
  }

  static IconData _iconFor(BaseItemDto item) => switch (item.type) {
    BaseItemKind.movie || BaseItemKind.video => Icons.movie_outlined,
    BaseItemKind.series ||
    BaseItemKind.season ||
    BaseItemKind.episode => Icons.tv_outlined,
    BaseItemKind.musicAlbum ||
    BaseItemKind.musicArtist ||
    BaseItemKind.audio => Icons.album_outlined,
    _ => switch (item.collectionType) {
      'movies' => Icons.movie_outlined,
      'tvshows' => Icons.tv_outlined,
      'music' => Icons.library_music_outlined,
      _ => Icons.folder_outlined,
    },
  };
}

/// Picture, title and a second line, with watch state on top.
class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.width,
    this.aspectRatio,
  });

  static Key keyFor(String itemId) => Key('item.$itemId');

  /// Height of the two text lines under the picture.
  static const textHeight = 44.0;

  final BaseItemDto item;
  final double width;

  /// Defaults to [cardAspectRatio] of the item's kind.
  final double? aspectRatio;

  double get _aspect => aspectRatio ?? cardAspectRatio(item.type);

  /// Total height of a card [width] wide.
  static double heightFor(double width, double aspectRatio) =>
      width / aspectRatio + textHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = cardSubtitle(item);
    final data = item.userData;
    final progress = (data?.playedPercentage ?? 0) / 100;
    final unplayed = data?.unplayedItemCount ?? 0;

    return SizedBox(
      key: keyFor(item.id),
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => openItem(context, item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: _aspect,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ItemImage(item: item, width: width),
                    if (data?.played ?? false)
                      const Positioned(
                        top: 6,
                        right: 6,
                        child: _Badge(child: Icon(Icons.check, size: 14)),
                      )
                    else if (unplayed > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _Badge(child: Text('$unplayed')),
                      ),
                    if (progress > 0)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: LinearProgressIndicator(value: progress),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: textHeight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Test Show · S1:E2" for an episode, the artist for an album, the year
/// otherwise.
String? cardSubtitle(BaseItemDto item) => switch (item.type) {
  BaseItemKind.episode => [?item.seriesName, ?episodeNumber(item)].join(' · '),
  BaseItemKind.musicAlbum || BaseItemKind.audio => item.albumArtist,
  _ => item.productionYear?.toString(),
};

/// "S1:E2", or null when the numbers are unknown.
String? episodeNumber(BaseItemDto item) {
  final (season, episode) = (item.parentIndexNumber, item.indexNumber);
  if (episode == null) return null;
  return season == null ? 'E$episode' : 'S$season:E$episode';
}

class _Badge extends StatelessWidget {
  const _Badge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: scheme.onPrimary, fontSize: 12),
          child: IconTheme.merge(
            data: IconThemeData(color: scheme.onPrimary),
            child: child,
          ),
        ),
      ),
    );
  }
}
