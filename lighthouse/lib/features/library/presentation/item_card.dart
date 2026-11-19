import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../api/models/user_item_data_dto.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/l10n.dart';
import '../../../router.dart';
import '../data/library_repository.dart';
import 'card_popover.dart';

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

  /// How long the mouse rests on a card before its panel opens (the
  /// theme's `cardHover: expand`).
  static const expandDelay = Duration(milliseconds: 450);

  /// Narrower windows keep the plain hover (no room for the panel).
  static const expandMinWidth = 800.0;

  /// Total height of a card [width] wide.
  static double heightFor(double width, double aspectRatio) =>
      width / aspectRatio + textHeight;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _hovered = false;
  bool _focused = false;

  // The expanding panel (CardPopover), when the theme has it.
  final _pictureKey = GlobalKey();
  final _popover = OverlayPortalController();
  Timer? _openTimer;
  Timer? _closeTimer;
  Rect? _origin;
  final _scrolls = <ScrollPosition>[];

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _stopWatchingScrolls();
    super.dispose();
  }

  /// Whether this card opens the panel under the mouse.
  bool _expands(BuildContext context) =>
      context.tokens.components.cardHover == CardHoverStyle.expand &&
      MediaQuery.sizeOf(context).width >= ItemCard.expandMinWidth &&
      switch (item.type) {
        BaseItemKind.movie ||
        BaseItemKind.episode ||
        BaseItemKind.series ||
        BaseItemKind.video ||
        BaseItemKind.book => true,
        _ => false,
      };

  void _mouseEnter(PointerEnterEvent event) {
    if (event.kind != PointerDeviceKind.mouse || !_expands(context)) return;
    _closeTimer?.cancel();
    if (_popover.isShowing) return;
    _openTimer?.cancel();
    _openTimer = Timer(ItemCard.expandDelay, _open);
  }

  void _mouseExit(PointerExitEvent _) {
    _openTimer?.cancel();
    if (_popover.isShowing) _closeSoon();
  }

  void _open() {
    if (!mounted) return;
    final box = _pictureKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached) return;
    _origin = box.localToGlobal(Offset.zero) & box.size;
    // Scrolling (the row or the page) closes it: it would float off its
    // card.
    for (
      var scrollable = Scrollable.maybeOf(context);
      scrollable != null;
      scrollable = Scrollable.maybeOf(scrollable.context)
    ) {
      _scrolls.add(scrollable.position..addListener(_close));
    }
    setState(_popover.show);
  }

  /// Leaving the card for the panel over it is not leaving.
  void _closeSoon() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 100), _close);
  }

  void _close() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _stopWatchingScrolls();
    if (mounted && _popover.isShowing) setState(_popover.hide);
  }

  void _stopWatchingScrolls() {
    for (final p in _scrolls) {
      p.removeListener(_close);
    }
    _scrolls.clear();
  }

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
    final tokens = context.tokens;
    final still = MediaQuery.disableAnimationsOf(context);
    // Posters (tall) get the small radius, landscape cards the medium.
    final radius = BorderRadius.circular(
      _aspect < 1 ? tokens.radiusSm : tokens.radiusMd,
    );

    final expands = _expands(context);
    final picture = _Picture(
      key: _pictureKey,
      item: item,
      width: widget.width,
      aspectRatio: _aspect,
      radius: radius,
      lifted: _lifted,
      playRoute: _playRoute,
    );

    final card = SizedBox(
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
          // With the panel, the mouse opens it instead of lifting the
          // card (the keyboard still lifts it).
          onHover: (h) => setState(() => _hovered = h && !expands),
          onFocusChange: (f) => setState(() => _focused = f),
          onTap: () => openItem(context, item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              picture,
              _Caption(item: item),
            ],
          ),
        ),
      ),
    );
    if (!expands) return card;
    return OverlayPortal(
      controller: _popover,
      overlayChildBuilder: (_) => CardPopover(
        item: item,
        origin: _origin ?? Rect.zero,
        onEnter: () => _closeTimer?.cancel(),
        onExit: _closeSoon,
        onDone: _close,
      ),
      child: MouseRegion(onEnter: _mouseEnter, onExit: _mouseExit, child: card),
    );
  }
}

/// The card's picture: rounded, lifted (shadow and focus ring) while
/// hovered or focused, with the play disc then, the watched check or the
/// count of unplayed episodes, and the progress bar once started.
class _Picture extends StatelessWidget {
  const _Picture({
    super.key,
    required this.item,
    required this.width,
    required this.aspectRatio,
    required this.radius,
    required this.lifted,
    required this.playRoute,
  });

  final BaseItemDto item;
  final double width;
  final double aspectRatio;
  final BorderRadius radius;
  final bool lifted;

  /// Where the play disc goes; null: no disc.
  final String? playRoute;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = Theme.of(context).colorScheme.primary;
    final data = item.userData;
    final progress = (data?.playedPercentage ?? 0) / 100;
    final unplayed = data?.unplayedItemCount ?? 0;
    final book = item.type == BaseItemKind.book;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: lifted ? tokens.shadowPoster : const [],
      ),
      foregroundDecoration: lifted
          ? BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: primary,
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            )
          : null,
      child: ClipRRect(
        borderRadius: radius,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ItemImage(item: item, width: width),
              if (playRoute case final route? when lifted)
                ColoredBox(
                  color: tokens.mediaShade.withValues(alpha: 0.35),
                  child: Center(
                    child: _Disc(
                      key: ItemCard.playKeyFor(item.id),
                      size: 48,
                      tooltip: book ? context.l10n.read : context.l10n.play,
                      onTap: () => context.push(route),
                      child: Icon(
                        book ? Icons.auto_stories : Icons.play_arrow,
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
                    color: tokens.mediaShade.withValues(alpha: 0.5),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0, 1),
                      child: ColoredBox(color: primary),
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

/// The two lines under the picture: the name, and the subtitle when the
/// item has one.
class _Caption extends StatelessWidget {
  const _Caption({required this.item});

  final BaseItemDto item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = cardSubtitle(item, context.l10n);
    return SizedBox(
      height: ItemCard.textHeight,
      child: Padding(
        padding: EdgeInsets.only(top: context.tokens.space(2)),
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
    );
  }
}

/// "Test Show · S1:E2" for an episode, the artist for an album, how much
/// is read for a book, the year otherwise.
String? cardSubtitle(BaseItemDto item, AppLocalizations l10n) =>
    switch (item.type) {
      BaseItemKind.episode => [
        ?item.seriesName,
        ?episodeNumber(item, l10n),
      ].join(' · '),
      BaseItemKind.musicAlbum || BaseItemKind.audio => item.albumArtist,
      BaseItemKind.book => switch (item.userData) {
        UserItemDataDto(played: true) => l10n.bookRead,
        UserItemDataDto(playedPercentage: final double p) when p > 0 =>
          l10n.bookPercentRead(p.round()),
        _ => item.productionYear?.toString(),
      },
      _ => item.productionYear?.toString(),
    };

/// "S1:E2", or null when the numbers are unknown.
String? episodeNumber(BaseItemDto item, AppLocalizations l10n) {
  final (season, episode) = (item.parentIndexNumber, item.indexNumber);
  if (episode == null) return null;
  return season == null
      ? l10n.episodeOnly(episode)
      : l10n.episodeNumber(season, episode);
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
