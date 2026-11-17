import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../api/models/user_item_data_dto.dart';
import '../../../core/theme/app_tokens.dart';
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
      // bg-200: the card's surface while its picture loads.
      color: Theme.of(context).colorScheme.surfaceContainer,
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
    BaseItemKind.book => Icons.menu_book_outlined,
    _ => switch (item.collectionType) {
      'movies' => Icons.movie_outlined,
      'tvshows' => Icons.tv_outlined,
      'music' => Icons.library_music_outlined,
      'books' => Icons.auto_stories_outlined,
      _ => Icons.folder_outlined,
    },
  };
}

/// Picture, title and a second line, with watch state on top (the
/// design system's MediaCard).
///
/// - Progress: a 4 px bar along the picture's bottom.
/// - Watched: a 24 px accent disc with a check; else unwatched episodes,
///   the same disc with their count.
/// - Hover or keyboard focus: the card grows a little (4 %, from its
///   bottom), lifts (`shadow-poster`), the picture gets the accent ring,
///   and a play disc shows on it: a click there plays (or reads) at once,
///   anywhere else opens the item.
class ItemCard extends StatefulWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.width,
    this.aspectRatio,
  });

  static Key keyFor(String itemId) => Key('item.$itemId');
  static Key playKeyFor(String itemId) => Key('item.$itemId.play');

  /// The progress bar along the picture's bottom (only when started).
  static const progressBar = Key('item.progress');

  /// Height of the two text lines under the picture.
  static const textHeight = 48.0;

  /// Room a row leaves above and below its cards, so a card that grows on
  /// hover (and its focus ring) is not cut.
  static const hoverRoom = 12.0;

  final BaseItemDto item;
  final double width;

  /// Defaults to [cardAspectRatio] of the item's kind.
  final double? aspectRatio;

  /// Total height of a card [width] wide.
  static double heightFor(double width, double aspectRatio) =>
      width / aspectRatio + textHeight;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _hovered = false;
  bool _focused = false;

  BaseItemDto get item => widget.item;
  double get _aspect => widget.aspectRatio ?? cardAspectRatio(item.type);

  bool get _keyboard =>
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
  bool get _lifted => _hovered || (_focused && _keyboard);

  /// Where the play disc goes: playback, or the reader; none for what
  /// opens as a page of its own (series, seasons, folders).
  String? get _playRoute => switch (item.type) {
    BaseItemKind.movie ||
    BaseItemKind.episode ||
    BaseItemKind.video ||
    BaseItemKind.audio => Routes.play(item.id),
    BaseItemKind.book => Routes.read(item.id),
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final subtitle = cardSubtitle(item);
    final data = item.userData;
    final progress = (data?.playedPercentage ?? 0) / 100;
    final unplayed = data?.unplayedItemCount ?? 0;
    final still = MediaQuery.disableAnimationsOf(context);
    // Posters (tall) get the small radius, landscape cards the medium.
    final radius = BorderRadius.circular(
      _aspect < 1 ? tokens.radiusSm : tokens.radiusMd,
    );
    final playRoute = _playRoute;

    final picture = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: _lifted ? tokens.shadowPoster : const [],
      ),
      foregroundDecoration: _lifted
          ? BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            )
          : null,
      child: ClipRRect(
        borderRadius: radius,
        child: AspectRatio(
          aspectRatio: _aspect,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ItemImage(item: item, width: widget.width),
              if (_lifted && playRoute != null)
                ColoredBox(
                  color: const Color(0x59000000),
                  child: Center(
                    child: _Disc(
                      key: ItemCard.playKeyFor(item.id),
                      size: 48,
                      tooltip: item.type == BaseItemKind.book ? 'Read' : 'Play',
                      onTap: () => context.push(playRoute),
                      child: Icon(
                        item.type == BaseItemKind.book
                            ? Icons.auto_stories
                            : Icons.play_arrow,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              if (data?.played ?? false)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: _Disc(size: 24, child: Icon(Icons.check, size: 16)),
                )
              else if (unplayed > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: _Disc(size: 24, child: Text('$unplayed')),
                ),
              if (progress > 0)
                Positioned(
                  key: ItemCard.progressBar,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 4,
                  child: ColoredBox(
                    color: const Color(0x80000000),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0, 1),
                      child: ColoredBox(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return SizedBox(
      key: ItemCard.keyFor(item.id),
      width: widget.width,
      child: AnimatedScale(
        scale: _lifted && !still ? 1.04 : 1,
        alignment: Alignment.bottomCenter,
        duration: const Duration(milliseconds: 150),
        child: InkWell(
          borderRadius: radius,
          // The lift is the hover and focus feedback; no grey wash.
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onHover: (h) => setState(() => _hovered = h),
          onFocusChange: (f) => setState(() => _focused = f),
          onTap: () => openItem(context, item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              picture,
              SizedBox(
                height: ItemCard.textHeight,
                child: Padding(
                  padding: EdgeInsets.only(top: tokens.space(2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Test Show · S1:E2" for an episode, the artist for an album, how much
/// is read for a book, the year otherwise.
String? cardSubtitle(BaseItemDto item) => switch (item.type) {
  BaseItemKind.episode => [?item.seriesName, ?episodeNumber(item)].join(' · '),
  BaseItemKind.musicAlbum || BaseItemKind.audio => item.albumArtist,
  BaseItemKind.book => switch (item.userData) {
    UserItemDataDto(played: true) => 'Read',
    UserItemDataDto(playedPercentage: final double p) when p > 0 =>
      '${p.round()}% read',
    _ => item.productionYear?.toString(),
  },
  _ => item.productionYear?.toString(),
};

/// "S1:E2", or null when the numbers are unknown.
String? episodeNumber(BaseItemDto item) {
  final (season, episode) = (item.parentIndexNumber, item.indexNumber);
  if (episode == null) return null;
  return season == null ? 'E$episode' : 'S$season:E$episode';
}

/// A round accent disc: the watched check, the unwatched count, the play
/// button on hover.
class _Disc extends StatelessWidget {
  const _Disc({
    super.key,
    required this.size,
    required this.child,
    this.onTap,
    this.tooltip,
  });

  final double size;
  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disc = SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.labelMedium!
                .copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w700),
            child: IconTheme.merge(
              data: IconThemeData(color: scheme.onPrimary),
              child: child,
            ),
          ),
        ),
      ),
    );
    if (onTap == null) return disc;
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(onTap: onTap, child: disc),
    );
  }
}
