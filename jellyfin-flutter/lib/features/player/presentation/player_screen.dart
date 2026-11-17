import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../api/models/media_stream.dart';
import '../../../api/models/playback_report.dart';
import '../../../core/failure.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/appearance.dart';
import '../../../core/ticks.dart';
import '../../../router.dart';
import '../../../widgets/error_retry.dart';
import '../../../widgets/media_badge.dart';
import '../../library/presentation/item_card.dart';
import '../../settings/application/settings_providers.dart';
import '../application/play_queue.dart';
import '../application/player_carry_over.dart';
import '../application/player_controller.dart';
import '../application/trickplay.dart';
import '../data/playback_repository.dart';
import '../data/player_engine.dart';
import '../data/tracks.dart';
import 'osd/control_button.dart';
import 'osd/seek_bar.dart';
import 'osd/settings_menu.dart';
import 'osd/up_next.dart';
import 'player_keys.dart';

/// Full-window playback of one item, with an on-screen display (OSD) that
/// shows on mouse movement and hides after a few seconds of playing.
///
/// Episodes and tracks play on: at the end the next one starts, and
/// Next / Previous step through the series or album. Music shows the
/// album cover, with the OSD always up.
///
/// Keys: see player_keys.dart (Space play/pause, arrows seek and volume,
/// A / L / S audio and subtitles, F11 full screen, Esc back...).
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key, required this.request});

  static const backButton = Key('player.back');
  static const playPauseButton = Key('player.playPause');
  static const seekBar = Key('player.seek');
  static const positionText = Key('player.position');
  static const muteButton = Key('player.mute');
  static const volumeSlider = Key('player.volume');

  /// The settings panel's Audio row (open the panel with [settingsButton]).
  static const audioMenu = SettingsMenu.audioRow;

  /// The bar's subtitles button: opens the panel on the subtitles.
  static const subtitleMenu = Key('player.subtitles');
  static const settingsButton = Key('player.settings');
  static const seekBackButton = Key('player.seekBack');
  static const seekForwardButton = Key('player.seekForward');
  static const centerPlayButton = Key('player.centerPlay');
  static const subtitleOff = Key('player.subtitle.off');
  static const fullscreenButton = Key('player.fullscreen');
  static const nextButton = Key('player.next');
  static const previousButton = Key('player.previous');
  static const cover = Key('player.cover');
  static const resumeAfterBreak = Key('player.resumeAfterBreak');
  static Key audioItem(int index) => Key('player.audio.$index');
  static Key subtitleItem(int index) => Key('player.subtitle.$index');

  final PlayRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = playerControllerProvider(request);
    final session = ref.watch(provider);
    final neighbors =
        ref.watch(playNeighborsProvider(request.itemId)).value ?? noNeighbors;
    // Loaded now, so the autoplay preference is known when the item ends.
    ref.watch(userConfigurationProvider);

    // Played to the end: on to the next episode / track, or close.
    ref.listen(provider, (_, now) {
      final session = now.value;
      if (session == null || !session.ended) return;
      // Episodes play on only if the user wants it (a server setting);
      // an album always does.
      final autoplay =
          session.item.type != BaseItemKind.episode ||
          (ref
                  .read(userConfigurationProvider)
                  .value
                  ?.enableNextEpisodeAutoPlay ??
              true);
      final next = autoplay
          ? ref.read(playNeighborsProvider(request.itemId)).value?.next
          : null;
      unawaited(
        next == null ? _close(context, ref) : _goTo(context, ref, next),
      );
    });

    // The player is always dark (the design system says so): its menus
    // and dialogs too, whatever the app's mode.
    final dark = ref.watch(appThemeProvider).dark;
    final osd = dark.extension<AppTokens>()!;
    return Theme(
      data: dark.copyWith(
        sliderTheme: dark.sliderTheme.copyWith(
          activeTrackColor: osd.osdAccent,
          thumbColor: osd.osdAccent,
          inactiveTrackColor: osd.osdTrack,
          trackHeight: 4,
        ),
      ),
      child: _FullscreenScope(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) unawaited(_close(context, ref));
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: switch (session) {
              AsyncData(value: final session) => _Playing(
                session: session,
                controller: ref.read(provider.notifier),
                upNext:
                    session.item.type == BaseItemKind.episode &&
                        (ref
                                .watch(userConfigurationProvider)
                                .value
                                ?.enableNextEpisodeAutoPlay ??
                            true)
                    ? neighbors.next
                    : null,
                onBack: () => _close(context, ref),
                onNext: neighbors.next == null
                    ? null
                    : () => _goTo(context, ref, neighbors.next!),
                onPrevious: neighbors.previous == null
                    ? null
                    : () => _goTo(context, ref, neighbors.previous!),
              ),
              AsyncError(:final error) => _Message(
                onBack: () => context.pop(),
                child: ErrorRetry(
                  error: error,
                  onRetry: () => ref.invalidate(provider),
                ),
              ),
              _ => _Message(
                onBack: () => context.pop(),
                child: const CircularProgressIndicator(),
              ),
            },
          ),
        ),
      ),
    );
  }

  /// Saves the resume point, then leaves.
  Future<void> _close(BuildContext context, WidgetRef ref) async {
    await ref.read(playerControllerProvider(request).notifier).stop();
    if (context.mounted && context.canPop()) context.pop();
  }

  /// Saves this one's position, then plays [item] in its place (Back still
  /// returns to the page playback started from).
  Future<void> _goTo(
    BuildContext context,
    WidgetRef ref,
    BaseItemDto item,
  ) async {
    await ref.read(playerControllerProvider(request).notifier).stop();
    if (context.mounted) {
      context.pushReplacement(Routes.play(item.id));
    }
  }
}

/// Counts this screen among the player screens open, so full screen
/// lasts from one item to the next and ends when the player closes (see
/// playerFullscreenProvider).
class _FullscreenScope extends ConsumerStatefulWidget {
  const _FullscreenScope({required this.child});

  final Widget child;

  @override
  ConsumerState<_FullscreenScope> createState() => _FullscreenScopeState();
}

class _FullscreenScopeState extends ConsumerState<_FullscreenScope> {
  late final PlayerFullscreenNotifier _fullscreen = ref.read(
    playerFullscreenProvider.notifier,
  );

  @override
  void initState() {
    super.initState();
    _fullscreen.enter();
  }

  @override
  void dispose() {
    _fullscreen.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _Message extends StatelessWidget {
  const _Message({required this.onBack, required this.child});

  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Center(child: child),
      SafeArea(
        child: IconButton(
          key: PlayerScreen.backButton,
          color: context.tokens.osdInk,
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
    ],
  );
}

class _Playing extends ConsumerStatefulWidget {
  const _Playing({
    required this.session,
    required this.controller,
    required this.onBack,
    this.onNext,
    this.onPrevious,
    this.upNext,
  });

  final PlayerSession session;
  final PlayerController controller;
  final VoidCallback onBack;

  /// Null when there is nothing after / before.
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  /// The episode that will play on at the end, for the "Up next" card
  /// (null: nothing plays on).
  final BaseItemDto? upNext;

  @override
  ConsumerState<_Playing> createState() => _PlayingState();
}

class _PlayingState extends ConsumerState<_Playing> {
  static const hideAfter = Duration(seconds: 3);
  static const seekStep = Duration(seconds: 10);
  static const longSeekStep = Duration(seconds: 60);
  static const volumeStep = 5.0;

  /// The subtitles rise this much while the controls are up: above the
  /// seek bar and the row of buttons (the design system says 48 px for its
  /// shorter bar).
  static const subtitleLift = 96.0;

  PlayerEngine get engine => widget.session.engine;

  /// Music: a cover instead of a picture, and the OSD stays up.
  bool get _isAudio => widget.session.item.type == BaseItemKind.audio;

  /// Previous restarts the current item when past this point, as music
  /// players do; before it, it goes to the previous item.
  static const restartThreshold = Duration(seconds: 3);

  bool _osdVisible = true;
  Timer? _hideTimer;
  StreamSubscription<bool>? _playing;

  /// The settings panel, while open, and the page it opened on.
  SettingsPage? _menu;
  final _menuKey = GlobalKey<SettingsMenuState>();

  /// The "Up next" card was dismissed (for this item).
  bool _upNextHidden = false;

  late final TrickplayThumbnails? _thumbnails = TrickplayThumbnails.of(
    widget.session.item,
    widget.session.plan.source.id,
    ref.read(playbackRepositoryProvider),
  );

  @override
  void initState() {
    super.initState();
    // Paused: keep the OSD up. Playing: hide it after a while.
    _playing = engine.playingStream.listen((playing) {
      playing ? _scheduleHide() : _show(hide: false);
    });
    _scheduleHide();
    engine.setSubtitleLift(subtitleLift);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    unawaited(_playing?.cancel());
    _thumbnails?.dispose();
    super.dispose();
  }

  void _toggleFullscreen() =>
      ref.read(playerFullscreenProvider.notifier).toggle();

  void _setOsd(bool visible) {
    if (_osdVisible == visible) return;
    setState(() => _osdVisible = visible);
    engine.setSubtitleLift(visible ? subtitleLift : 0);
  }

  void _show({bool hide = true}) {
    _setOsd(true);
    if (hide) _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (_isAudio) return;
    _hideTimer = Timer(hideAfter, () {
      // Not while a menu is open: the user is choosing.
      if (mounted && engine.playing && _menu == null) _setOsd(false);
    });
  }

  Future<void> _seekBy(Duration delta) async {
    final target = engine.position + delta;
    final end = engine.duration;
    await engine.seek(
      target < Duration.zero
          ? Duration.zero
          : (end > Duration.zero && target > end ? end : target),
    );
    _show();
  }

  Future<void> _previous() async {
    final previous = widget.onPrevious;
    if (previous == null || engine.position > restartThreshold) {
      await engine.seek(Duration.zero);
    } else {
      previous();
    }
  }

  Future<void> _next() async => widget.onNext?.call();

  void _openMenu(SettingsPage page) {
    setState(() => _menu = page);
    _show(hide: false);
  }

  void _closeMenu() {
    if (_menu == null) return;
    setState(() => _menu = null);
    _scheduleHide();
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    // Esc in the menu: one level up, then closed (not leaving the player).
    if (_menu != null &&
        event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      if (!(_menuKey.currentState?.back() ?? false)) _closeMenu();
      return KeyEventResult.handled;
    }
    final action = playerActionFor(event, HardwareKeyboard.instance);
    if (action == null) return KeyEventResult.ignored;
    final c = widget.controller;
    unawaited(switch (action) {
      PlayerAction.playPause => engine.playOrPause(),
      PlayerAction.pause => engine.pause(),
      PlayerAction.stop || PlayerAction.back => Future.sync(widget.onBack),
      PlayerAction.seekBack => _seekBy(-seekStep),
      PlayerAction.seekForward => _seekBy(seekStep),
      PlayerAction.seekBackLong => _seekBy(-longSeekStep),
      PlayerAction.seekForwardLong => _seekBy(longSeekStep),
      PlayerAction.volumeUp => c.changeVolume(volumeStep),
      PlayerAction.volumeDown => c.changeVolume(-volumeStep),
      PlayerAction.mute => c.toggleMute(),
      PlayerAction.nextAudio => c.cycleAudio(),
      PlayerAction.previousAudio => c.cycleAudio(back: true),
      PlayerAction.nextSubtitle => c.cycleSubtitles(),
      PlayerAction.previousSubtitle => c.cycleSubtitles(back: true),
      PlayerAction.toggleSubtitles => c.toggleSubtitles(),
      PlayerAction.fullscreen => Future.sync(_toggleFullscreen),
      PlayerAction.next => _next(),
      PlayerAction.previous => _previous(),
    });
    _show();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final c = widget.controller;
    final tokens = context.tokens;
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: MouseRegion(
        cursor: _osdVisible ? MouseCursor.defer : SystemMouseCursors.none,
        onHover: (_) => _show(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                unawaited(engine.playOrPause());
                _show();
              },
              onDoubleTap: _isAudio ? null : _toggleFullscreen,
              child: _isAudio
                  ? _Cover(item: session.item)
                  : Center(child: engine.buildVideo()),
            ),
            if (session.interruptedAt case final Duration at)
              _Interrupted(
                at: at,
                onResume: c.resumeAfterInterruption,
                onBack: widget.onBack,
              ),
            StreamBuilder<bool>(
              stream: engine.bufferingStream,
              builder: (_, snap) => (snap.data ?? false)
                  ? Center(
                      child: CircularProgressIndicator(color: tokens.osdAccent),
                    )
                  : const SizedBox.shrink(),
            ),
            AnimatedOpacity(
              opacity: _osdVisible ? 1 : 0,
              // In quickly, out slowly.
              duration: Duration(milliseconds: _osdVisible ? 200 : 400),
              child: IgnorePointer(
                ignoring: !_osdVisible,
                child: _Osd(
                  session: session,
                  controller: c,
                  chapters: [
                    for (final ch in session.item.chapters)
                      (
                        start: ticksToDuration(ch.startPositionTicks),
                        name: ch.name,
                      ),
                  ],
                  thumbnails: _thumbnails,
                  fullscreen: ref.watch(playerFullscreenProvider),
                  onFullscreen: _toggleFullscreen,
                  onNext: widget.onNext == null ? null : _next,
                  onPrevious: _previous,
                  onSeekBy: _seekBy,
                  onBack: widget.onBack,
                  onInteract: _show,
                  onMenu: _openMenu,
                  showCenterPlay: !_isAudio,
                ),
              ),
            ),
            if (widget.upNext case final BaseItemDto next when !_upNextHidden)
              StreamBuilder<Duration>(
                stream: engine.positionStream,
                builder: (context, _) {
                  final length = engine.duration;
                  final remaining = length - engine.position;
                  if (length <= Duration.zero ||
                      remaining > UpNextCard.countdown ||
                      remaining < Duration.zero) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    right: tokens.space(6),
                    // Above the controls when they are up.
                    bottom: _osdVisible ? 136 : tokens.space(6),
                    child: UpNextCard(
                      next: next,
                      remaining: remaining,
                      onWatchNow: () => unawaited(_next()),
                      onHide: () => setState(() => _upNextHidden = true),
                    ),
                  );
                },
              ),
            if (_menu case final SettingsPage page) ...[
              MenuBarrier(onDismiss: _closeMenu),
              Positioned(
                right: tokens.space(6),
                bottom: 88,
                child: SettingsMenu(
                  key: _menuKey,
                  initialPage: page,
                  audio: [
                    for (final s in session.plan.audioStreams)
                      (
                        value: s.index,
                        label: trackLabel(s),
                        detail: null,
                        key: PlayerScreen.audioItem(s.index),
                      ),
                  ],
                  selectedAudio: session.audioStreamIndex,
                  onAudio: (i) => reportFailure(
                    context,
                    c.selectAudio(i),
                    'Could not change the track.',
                  ),
                  subtitles: [
                    (
                      value: null,
                      label: 'Off',
                      detail: null,
                      key: PlayerScreen.subtitleOff,
                    ),
                    for (final s in session.plan.subtitleStreams)
                      (
                        value: s.index,
                        label: trackLabel(s),
                        detail: s.codec?.toUpperCase(),
                        key: PlayerScreen.subtitleItem(s.index),
                      ),
                  ],
                  selectedSubtitle: session.subtitleStreamIndex,
                  onSubtitle: (i) => reportFailure(
                    context,
                    c.selectSubtitle(i),
                    'Could not change the track.',
                  ),
                  rate: engine.rate,
                  onRate: (r) => unawaited(engine.setRate(r)),
                  onClose: _closeMenu,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The on-screen controls (the design system's VideoPlayer): the title
/// over a gradient at the top; at the bottom, over another, the seek bar
/// and a row of buttons. Paused, a big play button in the middle.
class _Osd extends StatelessWidget {
  const _Osd({
    required this.session,
    required this.controller,
    required this.chapters,
    required this.thumbnails,
    required this.fullscreen,
    required this.onFullscreen,
    required this.onNext,
    required this.onPrevious,
    required this.onSeekBy,
    required this.onBack,
    required this.onInteract,
    required this.onMenu,
    required this.showCenterPlay,
  });

  final PlayerSession session;
  final PlayerController controller;
  final List<SeekChapter> chapters;
  final TrickplayThumbnails? thumbnails;
  final bool fullscreen;
  final VoidCallback onFullscreen;
  final Future<void> Function()? onNext;
  final Future<void> Function() onPrevious;
  final Future<void> Function(Duration) onSeekBy;
  final VoidCallback onBack;
  final VoidCallback onInteract;
  final void Function(SettingsPage page) onMenu;
  final bool showCenterPlay;

  BaseItemDto get item => session.item;
  PlayerEngine get engine => session.engine;

  /// Do [action], keeping the controls up.
  VoidCallback _tap(FutureOr<void> Function() action) => () {
    unawaited(Future.sync(action));
    onInteract();
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final narrow = MediaQuery.sizeOf(context).width <= 720;
    final margin = narrow ? tokens.space(4) : tokens.space(6);
    // Episode: the series above, "S1:E3 · Name" under it.
    final (title, subtitle) = switch (item) {
      BaseItemDto(type: BaseItemKind.episode, :final seriesName?) => (
        seriesName,
        [?episodeNumber(item), item.name].join(' · '),
      ),
      _ => (item.name, cardSubtitle(item)),
    };
    final badges = qualityBadges(session);

    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            // Top: back and title, over a gradient so they read on any
            // frame.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: tokens.scrim(from: Alignment.topCenter),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    margin - 8,
                    tokens.space(3),
                    margin,
                    tokens.space(8),
                  ),
                  child: Row(
                    children: [
                      ControlButton(
                        key: PlayerScreen.backButton,
                        icon: Icons.arrow_back,
                        label: 'Back',
                        shortcut: 'Esc',
                        onPressed: onBack,
                      ),
                      SizedBox(width: tokens.space(2)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: tokens.osdInk,
                              ),
                            ),
                            if (subtitle != null && subtitle.isNotEmpty)
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: tokens.osdInkMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: tokens.scrim(from: Alignment.bottomCenter),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    margin,
                    tokens.space(12),
                    margin,
                    tokens.space(3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SeekBar(
                        key: PlayerScreen.seekBar,
                        engine: engine,
                        chapters: chapters,
                        thumbnails: thumbnails,
                        onInteract: onInteract,
                      ),
                      SizedBox(height: tokens.space(2)),
                      Row(
                        children: [
                          ControlButton(
                            key: PlayerScreen.previousButton,
                            icon: Icons.skip_previous,
                            label: 'Previous',
                            shortcut: 'Shift+P',
                            onPressed: _tap(onPrevious),
                          ),
                          ControlButton(
                            key: PlayerScreen.seekBackButton,
                            icon: Icons.replay_10,
                            label: 'Back 10 seconds',
                            shortcut: '←',
                            onPressed: _tap(
                              () => onSeekBy(const Duration(seconds: -10)),
                            ),
                          ),
                          StreamBuilder<bool>(
                            stream: engine.playingStream,
                            initialData: engine.playing,
                            builder: (_, snap) {
                              final playing = snap.data ?? false;
                              return ControlButton(
                                key: PlayerScreen.playPauseButton,
                                icon: playing ? Icons.pause : Icons.play_arrow,
                                label: playing ? 'Pause' : 'Play',
                                shortcut: 'Space',
                                size: 52,
                                iconSize: 32,
                                onPressed: _tap(engine.playOrPause),
                              );
                            },
                          ),
                          ControlButton(
                            key: PlayerScreen.seekForwardButton,
                            icon: Icons.forward_10,
                            label: 'Forward 10 seconds',
                            shortcut: '→',
                            onPressed: _tap(
                              () => onSeekBy(const Duration(seconds: 10)),
                            ),
                          ),
                          if (onNext != null)
                            ControlButton(
                              key: PlayerScreen.nextButton,
                              icon: Icons.skip_next,
                              label: 'Next',
                              shortcut: 'Shift+N',
                              onPressed: _tap(onNext!),
                            ),
                          SizedBox(width: tokens.space(2)),
                          _Time(engine: engine, showLength: !narrow),
                          const Spacer(),
                          _Volume(
                            engine: engine,
                            controller: controller,
                            onInteract: onInteract,
                            slider: !narrow,
                          ),
                          for (final b in badges)
                            Padding(
                              padding: EdgeInsets.only(left: tokens.space(1)),
                              child: MediaBadge(b, onVideo: true),
                            ),
                          SizedBox(width: tokens.space(1)),
                          if (session.plan.subtitleStreams.isNotEmpty)
                            ControlButton(
                              key: PlayerScreen.subtitleMenu,
                              icon: Icons.subtitles,
                              label: 'Subtitles',
                              shortcut: 'S',
                              active: session.subtitleStreamIndex != null,
                              onPressed: () => onMenu(SettingsPage.subtitles),
                            ),
                          ControlButton(
                            key: PlayerScreen.settingsButton,
                            icon: Icons.settings,
                            label: 'Settings',
                            onPressed: () => onMenu(SettingsPage.root),
                          ),
                          ControlButton(
                            key: PlayerScreen.fullscreenButton,
                            icon: fullscreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                            label: fullscreen
                                ? 'Exit full screen'
                                : 'Full screen',
                            shortcut: 'F',
                            onPressed: _tap(onFullscreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showCenterPlay)
          StreamBuilder<bool>(
            stream: engine.playingStream,
            initialData: engine.playing,
            builder: (_, snap) => (snap.data ?? false)
                ? const SizedBox.shrink()
                : Center(
                    child: CenterPlayButton(
                      key: PlayerScreen.centerPlayButton,
                      onPressed: _tap(engine.play),
                    ),
                  ),
          ),
      ],
    );
  }
}

/// What is shown over the video about the stream: its resolution, and
/// TRANSCODING when the server converts it.
List<String> qualityBadges(PlayerSession session) {
  final video = session.plan.source.mediaStreams
      .where((s) => s.type == MediaStreamType.video)
      .firstOrNull;
  final height = video?.height ?? 0;
  return [
    if (height >= 2000)
      '4K'
    else if (height >= 1000)
      '1080P'
    else if (height >= 700)
      '720P',
    if (session.plan.method == PlayMethod.transcode) 'Transcoding',
  ];
}

/// "0:01 / 1:52:07": elapsed and length, in fixed-width digits so the row
/// does not jiggle as it runs.
class _Time extends StatelessWidget {
  const _Time({required this.engine, required this.showLength});

  final PlayerEngine engine;
  final bool showLength;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final style = tokens.timecode.copyWith(color: tokens.osdInk);
    return StreamBuilder<Duration>(
      stream: engine.durationStream,
      initialData: engine.duration,
      builder: (_, durationSnap) => StreamBuilder<Duration>(
        stream: engine.positionStream,
        initialData: engine.position,
        builder: (_, positionSnap) {
          final duration = durationSnap.data ?? Duration.zero;
          final position = positionSnap.data ?? Duration.zero;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatPosition(position > duration ? duration : position),
                key: PlayerScreen.positionText,
                style: style,
              ),
              if (showLength)
                Text(
                  ' / ${formatPosition(duration)}',
                  style: style.copyWith(color: tokens.osdInkMuted),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Mute button and a short volume bar (the bar left out on narrow
/// windows).
class _Volume extends StatelessWidget {
  const _Volume({
    required this.engine,
    required this.controller,
    required this.onInteract,
    required this.slider,
  });

  final PlayerEngine engine;
  final PlayerController controller;
  final VoidCallback onInteract;
  final bool slider;

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
    stream: engine.mutedStream,
    initialData: engine.muted,
    builder: (_, mutedSnap) => StreamBuilder<double>(
      stream: engine.volumeStream,
      initialData: engine.volume,
      builder: (_, volumeSnap) {
        final muted = mutedSnap.data ?? false;
        final volume = muted ? 0.0 : (volumeSnap.data ?? 100).clamp(0, 100);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ControlButton(
              key: PlayerScreen.muteButton,
              icon: muted || volume == 0
                  ? Icons.volume_off
                  : (volume < 50 ? Icons.volume_down : Icons.volume_up),
              label: muted ? 'Unmute' : 'Mute',
              shortcut: 'M',
              active: false,
              onPressed: () {
                unawaited(controller.toggleMute());
                onInteract();
              },
            ),
            if (slider)
              SizedBox(
                width: 100,
                child: Slider(
                  key: PlayerScreen.volumeSlider,
                  max: 100,
                  value: volume.toDouble(),
                  onChanged: (v) {
                    unawaited(controller.setVolume(v));
                    onInteract();
                  },
                ),
              ),
          ],
        );
      },
    ),
  );
}

/// Music: the album cover, with the track, artist and album under it.
class _Cover extends StatelessWidget {
  const _Cover({required this.item});

  final BaseItemDto item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = (MediaQuery.sizeOf(context).shortestSide * 0.5).clamp(
      160.0,
      480.0,
    );
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            key: PlayerScreen.cover,
            dimension: size,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.tokens.radiusMd),
              child: ItemImage(item: item, width: size),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            item.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: context.tokens.osdInk,
            ),
          ),
          if ([?item.albumArtist, ?item.album] case final parts
              when parts.isNotEmpty)
            Text(
              parts.join(' · '),
              style: theme.textTheme.titleMedium?.copyWith(
                color: context.tokens.osdInkMuted,
              ),
            ),
        ],
      ),
    );
  }
}

/// The stream broke off before the end (connection lost): where it was,
/// and Resume from there once the server is reachable again.
class _Interrupted extends StatefulWidget {
  const _Interrupted({
    required this.at,
    required this.onResume,
    required this.onBack,
  });

  final Duration at;
  final Future<void> Function() onResume;
  final VoidCallback onBack;

  @override
  State<_Interrupted> createState() => _InterruptedState();
}

class _InterruptedState extends State<_Interrupted> {
  bool _resuming = false;
  String? _error;

  Future<void> _resume() async {
    setState(() {
      _resuming = true;
      _error = null;
    });
    try {
      await widget.onResume();
    } on Failure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _resuming = false);
    }
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.tokens.osdScrim,
    child: Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 40),
              const SizedBox(height: 12),
              Text(
                'Playback stopped at ${formatPosition(widget.at)}: the '
                'connection to the server was lost.',
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: widget.onBack,
                    child: const Text('Back'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    key: PlayerScreen.resumeAfterBreak,
                    onPressed: _resuming ? null : _resume,
                    icon: const Icon(Icons.play_arrow),
                    label: Text('Resume from ${formatPosition(widget.at)}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
