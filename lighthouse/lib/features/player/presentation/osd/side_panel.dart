import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../api/models/base_item_dto.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/ticks.dart';
import '../../../../core/touch.dart';
import '../../../../l10n/l10n.dart';
import '../../../../widgets/error_retry.dart';
import '../../../../widgets/skeleton.dart';
import '../../../library/presentation/item_card.dart';
import '../../application/play_queue.dart';
import '../../application/player_controller.dart';
import '../../application/trickplay.dart';
import '../../data/playback_repository.dart';
import '../player_screen.dart';
import 'control_button.dart';
import 'seek_bar.dart';

/// What the player's side panel shows for an item: an episode, its
/// series' episodes by season; a video with chapters, the chapters.
enum PanelContents {
  episodes,
  chapters;

  /// Null: nothing worth a panel (a movie with one chapter or none, a
  /// song).
  static PanelContents? of(BaseItemDto item, List<SeekChapter> chapters) =>
      switch (item) {
        BaseItemDto(type: BaseItemKind.episode, seriesId: String()) => episodes,
        BaseItemDto(type: BaseItemKind.audio) => null,
        _ when chapters.length > 1 => PanelContents.chapters,
        _ => null,
      };
}

/// The panel on the right of the player, over the picture: the series'
/// episodes (a tap plays one) or the movie's chapters (a tap goes there),
/// the one playing marked and scrolled to. Keys: the arrows move through
/// it, Enter picks, Esc closes.
class PlayerSidePanel extends StatelessWidget {
  const PlayerSidePanel({
    super.key,
    required this.contents,
    required this.session,
    required this.chapters,
    required this.onPlay,
    required this.onSeek,
    required this.onClose,
  });

  /// How wide it is: about four tenths of the window, between these.
  static const minWidth = 300.0;
  static const maxWidth = 400.0;

  /// Its pictures' width.
  static const thumbWidth = 112.0;

  final PanelContents contents;
  final PlayerSession session;
  final List<SeekChapter> chapters;
  final void Function(BaseItemDto episode) onPlay;
  final void Function(Duration start) onSeek;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final window = MediaQuery.sizeOf(context);
    final width = math.min(
      window.width - 2 * tokens.space(4),
      (window.width * 0.42).clamp(minWidth, maxWidth),
    );
    final theme = Theme.of(context);
    return SafeArea(
      left: false,
      child: Padding(
        padding: EdgeInsets.all(tokens.space(4)),
        child: Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            key: PlayerScreen.sidePanel,
            width: width,
            // The picture and controls behind it blurred, so its text
            // reads on any frame (its surface is see-through).
            child: ClipRRect(
              borderRadius: BorderRadius.circular(tokens.radiusLg),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Material(
                  color: tokens.osdSurface,
                  child: FocusScope(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            tokens.space(4),
                            tokens.space(2),
                            tokens.space(1),
                            0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  contents == PanelContents.episodes
                                      ? context.l10n.episodes
                                      : context.l10n.chapters,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: tokens.osdInk,
                                  ),
                                ),
                              ),
                              ControlButton(
                                key: PlayerScreen.sidePanelClose,
                                icon: Icons.close,
                                label: context.l10n.close,
                                shortcut: 'Esc',
                                onPressed: onClose,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: switch (contents) {
                            PanelContents.episodes => _Episodes(
                              playing: session.item,
                              onPlay: onPlay,
                              onClose: onClose,
                            ),
                            PanelContents.chapters => _Chapters(
                              session: session,
                              chapters: chapters,
                              onSeek: onSeek,
                            ),
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Scrolls the item [key] is on into the middle of the list, once laid
/// out.
void _scrollTo(GlobalKey key) =>
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = key.currentContext;
      if (context != null && context.mounted) {
        unawaited(Scrollable.ensureVisible(context, alignment: 0.4));
      }
    });

/// The series' episodes, a season at a time (the playing one's first).
class _Episodes extends ConsumerStatefulWidget {
  const _Episodes({
    required this.playing,
    required this.onPlay,
    required this.onClose,
  });

  final BaseItemDto playing;
  final void Function(BaseItemDto episode) onPlay;
  final VoidCallback onClose;

  @override
  ConsumerState<_Episodes> createState() => _EpisodesState();
}

class _EpisodesState extends ConsumerState<_Episodes> {
  /// The season shown: its key (see [_seasonOf]); null, the playing one's.
  String? _season;
  final _current = GlobalKey();

  /// Seasons by id; episodes without one by their number.
  static String _seasonOf(BaseItemDto e) =>
      e.seasonId ?? 'number:${e.parentIndexNumber}';

  @override
  void initState() {
    super.initState();
    _scrollTo(_current);
  }

  @override
  Widget build(BuildContext context) {
    final seriesId = widget.playing.seriesId!;
    final provider = seriesEpisodesProvider(seriesId);
    return switch (ref.watch(provider)) {
      AsyncData(value: final episodes) => _list(context, episodes),
      AsyncError(:final error) => Center(
        child: ErrorRetry(
          error: error,
          onRetry: () => ref.invalidate(provider),
        ),
      ),
      _ => const _PanelSkeleton(),
    };
  }

  Widget _list(BuildContext context, List<BaseItemDto> episodes) {
    final tokens = context.tokens;
    // In the series' order, which is the seasons' too.
    final seasons = <String, List<BaseItemDto>>{};
    for (final e in episodes) {
      (seasons[_seasonOf(e)] ??= []).add(e);
    }
    final shown =
        _season ??
        (seasons.containsKey(_seasonOf(widget.playing))
            ? _seasonOf(widget.playing)
            : seasons.keys.firstOrNull);
    final list = seasons[shown] ?? const <BaseItemDto>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (seasons.length > 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space(4),
              vertical: tokens.space(2),
            ),
            child: Row(
              children: [
                for (final MapEntry(:key, :value) in seasons.entries)
                  Padding(
                    padding: EdgeInsets.only(right: tokens.space(2)),
                    child: ChoiceChip(
                      key: PlayerScreen.panelSeason(key),
                      label: Text(_seasonName(context, value.first)),
                      selected: key == shown,
                      onSelected: (_) => setState(() => _season = key),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: tokens.space(3)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final episode in list)
                  _EpisodeTile(
                    key: episode.id == widget.playing.id ? _current : null,
                    episode: episode,
                    playing: episode.id == widget.playing.id,
                    // The one playing: the panel just closes.
                    onTap: episode.id == widget.playing.id
                        ? widget.onClose
                        : () => widget.onPlay(episode),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _seasonName(BuildContext context, BaseItemDto episode) =>
      episode.seasonName ??
      switch (episode.parentIndexNumber) {
        final int n => context.l10n.seasonNumber(n),
        null => context.l10n.seasons,
      };
}

/// A row of the list: a picture, two lines of text, the playing one
/// marked (an accent bar and "Playing").
class _Row extends StatelessWidget {
  const _Row({
    required this.itemKey,
    required this.picture,
    required this.title,
    required this.detail,
    required this.current,
    required this.onTap,
    this.trailing,
  });

  final Key itemKey;
  final Widget picture;
  final String title;
  final String? detail;
  final bool current;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return Material(
      color: current ? tokens.osdHover : Colors.transparent,
      child: InkWell(
        key: itemKey,
        autofocus: current,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: touchTarget),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: current ? tokens.osdAccent : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space(3),
            vertical: tokens.space(2),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                child: SizedBox(
                  width: PlayerSidePanel.thumbWidth,
                  child: AspectRatio(aspectRatio: 16 / 9, child: picture),
                ),
              ),
              SizedBox(width: tokens.space(3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.osdInk,
                      ),
                    ),
                    if (current || detail != null)
                      Text(
                        current ? context.l10n.playingNow : detail!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: current
                              ? tokens.osdAccent
                              : tokens.osdInkMuted,
                        ),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// The episodes while they load: rows shaped as [_Row]s, in the player's
/// dark colours.
class _PanelSkeleton extends StatelessWidget {
  const _PanelSkeleton();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    return Skeleton(
      onMedia: true,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 12,
        itemBuilder: (_, i) => Padding(
          // As a row: the 3 px of its "playing" border included.
          padding: EdgeInsets.fromLTRB(
            tokens.space(3) + 3,
            tokens.space(2),
            tokens.space(3),
            tokens.space(2),
          ),
          child: Row(
            children: [
              Bone(
                width: PlayerSidePanel.thumbWidth,
                height: PlayerSidePanel.thumbWidth * 9 / 16,
              ),
              SizedBox(width: tokens.space(3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: i.isEven ? 0.8 : 0.6,
                      child: Bone.text(context, text.bodyMedium),
                    ),
                    Bone.text(context, text.bodySmall, width: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({
    super.key,
    required this.episode,
    required this.playing,
    required this.onTap,
  });

  final BaseItemDto episode;
  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final progress = (episode.userData?.playedPercentage ?? 0) / 100;
    final number = episode.indexNumber;
    return _Row(
      itemKey: PlayerScreen.panelEpisode(episode.id),
      current: playing,
      onTap: onTap,
      title: number == null ? episode.name : '$number. ${episode.name}',
      detail: switch (episode.runTimeTicks) {
        final int ticks when ticks > 0 => formatRuntime(
          ticksToDuration(ticks),
          context.l10n,
        ),
        _ => null,
      },
      picture: Stack(
        fit: StackFit.expand,
        children: [
          ItemImage(item: episode, width: PlayerSidePanel.thumbWidth),
          if (progress > 0 && !playing)
            Align(
              alignment: Alignment.bottomCenter,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                color: tokens.osdAccent,
                backgroundColor: tokens.osdTrack,
              ),
            ),
        ],
      ),
      trailing: (episode.userData?.played ?? false)
          ? Padding(
              padding: EdgeInsets.only(left: tokens.space(2)),
              child: Icon(
                Icons.check_circle,
                key: PlayerScreen.panelWatched(episode.id),
                size: 18,
                color: tokens.osdAccent,
              ),
            )
          : null,
    );
  }
}

/// The video's chapters, each with the picture at its start (from the
/// seek bar's thumbnails, when the server made them); the one playing
/// follows the position.
class _Chapters extends ConsumerStatefulWidget {
  const _Chapters({
    required this.session,
    required this.chapters,
    required this.onSeek,
  });

  final PlayerSession session;
  final List<SeekChapter> chapters;
  final void Function(Duration start) onSeek;

  @override
  ConsumerState<_Chapters> createState() => _ChaptersState();
}

class _ChaptersState extends ConsumerState<_Chapters> {
  /// Its own: the seek bar's keeps few tiles, and this list needs many.
  late final TrickplayThumbnails? _thumbnails = TrickplayThumbnails.of(
    widget.session.item,
    widget.session.plan.source.id,
    ref.read(playbackRepositoryProvider),
  );
  final _stills = <int, ui.Image>{};
  final _current = GlobalKey();

  @override
  void initState() {
    super.initState();
    unawaited(_loadStills());
    _scrollTo(_current);
  }

  /// One after the other, in order: the first ones show first.
  Future<void> _loadStills() async {
    final thumbnails = _thumbnails;
    if (thumbnails == null) return;
    for (var i = 0; i < widget.chapters.length; i++) {
      final still = await thumbnails.still(widget.chapters[i].start);
      if (!mounted) {
        still?.dispose();
        return;
      }
      if (still != null) setState(() => _stills[i] = still);
    }
  }

  @override
  void dispose() {
    for (final still in _stills.values) {
      still.dispose();
    }
    _thumbnails?.dispose();
    super.dispose();
  }

  /// The last chapter started by [position].
  int _at(Duration position) {
    var at = 0;
    for (var i = 0; i < widget.chapters.length; i++) {
      if (widget.chapters[i].start <= position) at = i;
    }
    return at;
  }

  @override
  Widget build(BuildContext context) {
    final engine = widget.session.engine;
    final tokens = context.tokens;
    return StreamBuilder<Duration>(
      stream: engine.positionStream,
      initialData: engine.position,
      builder: (context, snap) {
        final at = _at(snap.data ?? engine.position);
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            top: tokens.space(2),
            bottom: tokens.space(3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, chapter) in widget.chapters.indexed)
                KeyedSubtree(
                  key: i == at ? _current : null,
                  child: _Row(
                    itemKey: PlayerScreen.panelChapter(i),
                    current: i == at,
                    onTap: () => widget.onSeek(chapter.start),
                    title: switch (chapter.name) {
                      final String name when name.isNotEmpty => name,
                      _ => context.l10n.chapterNumber(i + 1),
                    },
                    detail: formatPosition(chapter.start),
                    picture: switch (_stills[i]) {
                      final ui.Image still => RawImage(
                        image: still,
                        fit: BoxFit.cover,
                      ),
                      null => ColoredBox(
                        color: tokens.osdTrack,
                        child: Icon(
                          Icons.movie_outlined,
                          color: tokens.osdInkMuted,
                        ),
                      ),
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
