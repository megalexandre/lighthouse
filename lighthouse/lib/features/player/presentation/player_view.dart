import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../api/models/media_stream.dart';
import '../../../core/floating_window.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/ticks.dart';
import '../../../core/touch.dart';
import '../../../core/window_size.dart';
import '../../../l10n/l10n.dart';
import '../application/player_carry_over.dart';
import '../application/player_controller.dart';
import '../application/trickplay.dart';
import '../data/playback_repository.dart';
import '../data/player_engine.dart';
import 'osd/floating_controls.dart';
import 'osd/player_osd.dart';
import 'osd/seek_bar.dart';
import 'osd/settings_menu.dart';
import 'osd/side_panel.dart';
import 'osd/track_menu.dart';
import 'osd/up_next.dart';
import 'player_keys.dart';
import 'player_overlays.dart';
import 'player_swipes.dart';

/// The player while an item plays: the picture (or the album cover), the
/// on-screen controls that hide after a while, the keys, the "Up next"
/// card and the settings panel.
class PlayerView extends ConsumerStatefulWidget {
  const PlayerView({
    super.key,
    required this.session,
    required this.controller,
    required this.onBack,
    this.onNext,
    this.onPrevious,
    this.onPlay,
    this.upNext,
  });

  final PlayerSession session;
  final PlayerController controller;
  final VoidCallback onBack;

  /// Null when there is nothing after / before.
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  /// Plays another episode of the series in this one's place (the side
  /// panel's list).
  final void Function(BaseItemDto item)? onPlay;

  /// The episode that will play on at the end, for the "Up next" card
  /// (null: nothing plays on).
  final BaseItemDto? upNext;

  @override
  ConsumerState<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends ConsumerState<PlayerView> {
  static const hideAfter = Duration(seconds: 3);
  static const seekStep = Duration(seconds: 10);
  static const longSeekStep = Duration(seconds: 60);
  static const volumeStep = 5.0;

  /// The subtitles rise this much while the controls are up: above the
  /// seek bar and the row of buttons (the design system says 48 px for its
  /// shorter bar); on a phone, above both rows of buttons.
  double get _subtitleLift =>
      (WindowSize.of(context) == WindowSize.compact ? 148 : 96) +
      _touchRoom(context);

  /// What the controls gain in height on touch: the seek bar's 48 px to
  /// grab instead of 16.
  static double _touchRoom(BuildContext context) =>
      isTouch(context) ? touchTarget - 16 : 0;

  PlayerEngine get engine => widget.session.engine;

  /// Music: a cover instead of a picture, and the OSD stays up.
  bool get _isAudio => widget.session.item.type == BaseItemKind.audio;

  bool _osdVisible = true;
  Timer? _hideTimer;
  StreamSubscription<bool>? _playing;
  StreamSubscription<FloatingEvent>? _floatingEvents;

  bool get _floating => ref.read(playerFloatingProvider);

  /// The settings panel, while open, and the page it opened on.
  SettingsPage? _menu;
  final _menuKey = GlobalKey<SettingsMenuState>();

  /// The side panel this item has (null: none), and whether it is open.
  late final PanelContents? _panelContents = PanelContents.of(
    widget.session.item,
    _chapters,
  );
  bool _panelOpen = false;

  /// The player's keys: focus comes back here when the panel, which takes
  /// it for its list, closes.
  final _focus = FocusNode(debugLabel: 'player');

  /// The "Up next" card was dismissed (for this item).
  bool _upNextHidden = false;

  /// Made at the start, not when first used: floating, the seek bar may
  /// never ask, and dispose cannot read providers.
  late final TrickplayThumbnails? _thumbnails;

  /// The seek bar's chapter marks.
  late final List<SeekChapter> _chapters = [
    for (final ch in widget.session.item.chapters)
      (start: ticksToDuration(ch.startPositionTicks), name: ch.name),
  ];

  @override
  void initState() {
    super.initState();
    _thumbnails = TrickplayThumbnails.of(
      widget.session.item,
      widget.session.plan.source.id,
      ref.read(playbackRepositoryProvider),
    );
    // Paused: keep the OSD up. Playing: hide it after a while.
    _playing = engine.playingStream.listen((playing) {
      playing ? _scheduleHide() : _show(hide: false);
      _offerFloating();
    });
    _floatingEvents = ref
        .read(floatingWindowProvider)
        .events
        .listen(_onFloatingEvent);
    _scheduleHide();
    // Not now: providers cannot change while the tree builds.
    scheduleMicrotask(() {
      if (mounted && isTouch(context) && !_isAudio) {
        ref.read(playerFullscreenProvider.notifier).enterVideo();
      }
    });
  }

  /// The window's size is known here (and changes land here): the lift
  /// follows the controls' height.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    engine.setSubtitleLift(_osdVisible && !_floating ? _subtitleLift : 0);
    _offerFloating();
  }

  @override
  void dispose() {
    unawaited(_floatingEvents?.cancel());
    _focus.dispose();
    _hideTimer?.cancel();
    unawaited(_playing?.cancel());
    _thumbnails?.dispose();
    super.dispose();
  }

  /// Full screen; floating, back to the window it floated from.
  void _toggleFullscreen() => _floating
      ? unawaited(ref.read(playerFloatingProvider.notifier).expand())
      : ref.read(playerFullscreenProvider.notifier).toggle();

  /// The picture's width to its height, as the server describes the
  /// stream (16:9 when it does not say).
  double get _aspectRatio {
    final video = widget.session.plan.source.mediaStreams
        .where((s) => s.type == MediaStreamType.video)
        .firstOrNull;
    final (width, height) = (video?.width ?? 0, video?.height ?? 0);
    return width > 0 && height > 0 ? width / height : 16 / 9;
  }

  /// What the window floats with: a video only, and on Android, while it
  /// plays, it floats by itself when the user goes Home.
  void _offerFloating() {
    if (_isAudio || !mounted) return;
    final l10n = context.l10n;
    ref.read(floatingWindowProvider).offer((
      aspectRatio: _aspectRatio,
      playing: engine.playing,
      play: l10n.play,
      pause: l10n.pause,
      back10: l10n.back10,
      forward10: l10n.forward10,
    ));
  }

  Future<void> _toggleFloating() async {
    final floating = ref.read(playerFloatingProvider.notifier);
    if (_floating) return floating.expand();
    if (_isAudio || !(ref.read(floatingSupportedProvider).value ?? false)) {
      return;
    }
    // Nothing of the controls fits in there.
    setState(() {
      _menu = null;
      _panelOpen = false;
    });
    await floating.float(_aspectRatio);
  }

  /// The floating window's own buttons (Android's), and its X.
  void _onFloatingEvent(FloatingEvent event) {
    switch (event) {
      case FloatingEvent.closed:
        widget.onBack();
      case FloatingEvent.playPause:
        unawaited(engine.playOrPause());
      case FloatingEvent.seekBack:
        unawaited(_seekBy(-seekStep));
      case FloatingEvent.seekForward:
        unawaited(_seekBy(seekStep));
      case FloatingEvent.entered || FloatingEvent.expanded:
        // The subtitles sit low in the small window.
        engine.setSubtitleLift(
          event == FloatingEvent.expanded && _osdVisible ? _subtitleLift : 0,
        );
    }
  }

  void _setOsd(bool visible) {
    if (_osdVisible == visible) return;
    setState(() => _osdVisible = visible);
    engine.setSubtitleLift(visible && !_floating ? _subtitleLift : 0);
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
      if (mounted && engine.playing && _menu == null && !_panelOpen) {
        _setOsd(false);
      }
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
    if (previous == null ||
        engine.position > PlayerController.restartThreshold) {
      await engine.seek(Duration.zero);
    } else {
      previous();
    }
  }

  Future<void> _next() async => widget.onNext?.call();

  void _openMenu(SettingsPage page) {
    setState(() {
      _menu = page;
      _panelOpen = false;
    });
    _show(hide: false);
  }

  void _togglePanel() {
    if (_panelContents == null) return;
    if (_panelOpen) return _closePanel();
    setState(() {
      _panelOpen = true;
      _menu = null;
    });
    _show(hide: false);
  }

  void _closePanel() {
    if (!_panelOpen) return;
    setState(() => _panelOpen = false);
    _focus.requestFocus();
    _scheduleHide();
  }

  void _closeMenu() {
    if (_menu == null) return;
    setState(() => _menu = null);
    _scheduleHide();
  }

  /// Esc or the system's Back: in the menu one level up, then closed (not
  /// leaving the player); floating, back to the window; otherwise out of
  /// the player.
  void _back() {
    if (_floating) {
      return unawaited(ref.read(playerFloatingProvider.notifier).expand());
    }
    if (_panelOpen) return _closePanel();
    if (_menu == null) return widget.onBack();
    if (!(_menuKey.currentState?.back() ?? false)) _closeMenu();
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if ((_menu != null || _panelOpen) &&
        event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      _back();
      return KeyEventResult.handled;
    }
    // The panel's list takes the rest (arrows, Enter, Space), but for its
    // own key.
    if (_panelOpen &&
        !(event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.keyC)) {
      return KeyEventResult.ignored;
    }
    final action = playerActionFor(event, HardwareKeyboard.instance);
    if (action == null) return KeyEventResult.ignored;
    final c = widget.controller;
    final done = switch (action) {
      PlayerAction.playPause => engine.playOrPause(),
      PlayerAction.pause => engine.pause(),
      PlayerAction.stop => Future.sync(widget.onBack),
      PlayerAction.back => Future.sync(_floating ? _back : widget.onBack),
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
      PlayerAction.contents =>
        _floating ? Future<void>.value() : Future.sync(_togglePanel),
      PlayerAction.floating => _toggleFloating(),
    };
    switch (action) {
      // A track that needs a new stream can fail: said, as from the menu.
      case PlayerAction.nextAudio ||
          PlayerAction.previousAudio ||
          PlayerAction.nextSubtitle ||
          PlayerAction.previousSubtitle ||
          PlayerAction.toggleSubtitles:
        reportFailure(context, done, context.l10n.trackChangeFailed);
      case _:
        unawaited(done);
    }
    _show();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final c = widget.controller;
    final tokens = context.tokens;
    final floating = ref.watch(playerFloatingProvider);
    // The system's Back (Android) does what Esc does; leaving saves the
    // resume point first (onBack), so the route is never popped directly.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: MouseRegion(
          cursor: _osdVisible || floating
              ? MouseCursor.defer
              : SystemMouseCursors.none,
          onHover: floating ? null : (_) => _show(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isTouch(context) && !_isAudio)
                // As phone players do: a tap shows or hides the controls
                // (play / pause is their button), a double tap on either
                // half goes back or on 10 s, and swipes change the
                // brightness, the volume and the position.
                PlayerSwipes(
                  engine: engine,
                  child: _Picture(
                    session: session,
                    onTap: () => _osdVisible ? _setOsd(false) : _show(),
                    onDoubleTapAt: (side) =>
                        unawaited(_seekBy(side < 0 ? -seekStep : seekStep)),
                  ),
                )
              else
                // The mouse wheel over the picture: the volume, as the
                // up and down keys.
                Listener(
                  onPointerSignal: (event) {
                    if (event case PointerScrollEvent(:final scrollDelta)
                        when scrollDelta.dy != 0) {
                      unawaited(
                        c.changeVolume(
                          scrollDelta.dy < 0 ? volumeStep : -volumeStep,
                        ),
                      );
                      _show();
                    }
                  },
                  child: _Picture(
                    session: session,
                    onTap: () {
                      unawaited(engine.playOrPause());
                      _show();
                    },
                    onDoubleTap: _isAudio ? null : _toggleFullscreen,
                  ),
                ),
              // Android's floating window takes no touch: only the picture
              // (its buttons are the system's). The desktop's has a few
              // of its own, on hover.
              if (floating) ...[
                _Buffering(engine: engine),
                if (!isTouch(context))
                  FloatingControls(
                    engine: engine,
                    onExpand: () => unawaited(
                      ref.read(playerFloatingProvider.notifier).expand(),
                    ),
                    onClose: widget.onBack,
                    onSeekBy: _seekBy,
                    onDrag: ref.read(floatingWindowProvider).startDragging,
                  ),
              ] else
                ..._controls(session, c, tokens),
            ],
          ),
        ),
      ),
    );
  }

  /// Over the picture in the full window: the notice of a lost
  /// connection, the spinner, the controls, the "Up next" card, and the
  /// side panel or the settings, when open.
  List<Widget> _controls(
    PlayerSession session,
    PlayerController c,
    AppTokens tokens,
  ) => [
    if (session.interruptedAt case final Duration at)
      InterruptedNotice(
        at: at,
        onResume: c.resumeAfterInterruption,
        onBack: widget.onBack,
      ),
    _Buffering(engine: engine),
    AnimatedOpacity(
      opacity: _osdVisible ? 1 : 0,
      // In quickly, out slowly.
      duration: Duration(milliseconds: _osdVisible ? 200 : 400),
      child: IgnorePointer(
        ignoring: !_osdVisible,
        child: PlayerOsd(
          session: session,
          controller: c,
          chapters: _chapters,
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
          panel: _panelContents,
          onPanel: _togglePanel,
          onFloating:
              !_isAudio && (ref.watch(floatingSupportedProvider).value ?? false)
              ? () => unawaited(_toggleFloating())
              : null,
        ),
      ),
    ),
    if (widget.upNext case final BaseItemDto next
        // The panel lists what comes next anyway.
        when !_upNextHidden && !_panelOpen)
      _UpNextLayer(
        engine: engine,
        next: next,
        raised: _osdVisible,
        // Clear of the panel's tab on the right edge.
        besideTab: _panelContents != null && _osdVisible,
        onWatchNow: () => unawaited(_next()),
        onHide: () => setState(() => _upNextHidden = true),
      ),
    if (_panelContents case final PanelContents contents when _panelOpen) ...[
      MenuBarrier(onDismiss: _closePanel),
      PlayerSidePanel(
        contents: contents,
        session: session,
        chapters: _chapters,
        onClose: _closePanel,
        onSeek: (start) {
          unawaited(engine.seek(start));
          _show(hide: false);
        },
        onPlay: (episode) {
          _closePanel();
          widget.onPlay?.call(episode);
        },
      ),
    ],
    if (_menu case final SettingsPage page) ...[
      MenuBarrier(onDismiss: _closeMenu),
      Positioned(
        right: tokens.space(6),
        bottom: 88,
        child: TrackMenu(
          menuKey: _menuKey,
          page: page,
          session: session,
          controller: c,
          onClose: _closeMenu,
        ),
      ),
    ],
  ];
}

/// The video (or a song's cover), full size, and what a tap and a double
/// tap on it do: [onDoubleTapAt] is told the half, -1 left or 1 right.
class _Picture extends StatefulWidget {
  const _Picture({
    required this.session,
    required this.onTap,
    this.onDoubleTap,
    this.onDoubleTapAt,
  });

  final PlayerSession session;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final void Function(int side)? onDoubleTapAt;

  @override
  State<_Picture> createState() => _PictureState();
}

class _PictureState extends State<_Picture> {
  int _side = 1;

  @override
  Widget build(BuildContext context) {
    final at = widget.onDoubleTapAt;
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onDoubleTapDown: at == null
            ? null
            : (d) => _side = d.localPosition.dx < constraints.maxWidth / 2
                  ? -1
                  : 1,
        onDoubleTap: at == null ? widget.onDoubleTap : () => at(_side),
        child: widget.session.item.type == BaseItemKind.audio
            ? AudioCover(item: widget.session.item)
            : Center(child: widget.session.engine.buildVideo()),
      ),
    );
  }
}

/// A spinner while mpv waits for data.
class _Buffering extends StatelessWidget {
  const _Buffering({required this.engine});

  final PlayerEngine engine;

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
    stream: engine.bufferingStream,
    builder: (_, snap) => (snap.data ?? false)
        ? Center(
            child: CircularProgressIndicator(color: context.tokens.osdAccent),
          )
        : const SizedBox.shrink(),
  );
}

/// The "Up next" card, in the last seconds of an episode that plays on:
/// bottom right, [raised] above the controls while they are up.
class _UpNextLayer extends StatelessWidget {
  const _UpNextLayer({
    required this.engine,
    required this.next,
    required this.raised,
    required this.besideTab,
    required this.onWatchNow,
    required this.onHide,
  });

  final PlayerEngine engine;
  final BaseItemDto next;
  final bool raised;

  /// The side panel's tab is on the right edge: the card leaves it room.
  final bool besideTab;
  final VoidCallback onWatchNow;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return StreamBuilder<Duration>(
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
          right: tokens.space(6) + (besideTab ? touchTarget : 0),
          // Above the controls while they are up: on a phone they have a
          // second row, on touch a taller seek bar.
          bottom: raised
              ? 136 +
                    (WindowSize.of(context) == WindowSize.compact ? 52 : 0) +
                    _PlayerViewState._touchRoom(context)
              : tokens.space(6),
          child: UpNextCard(
            next: next,
            remaining: remaining,
            onWatchNow: onWatchNow,
            onHide: onHide,
          ),
        );
      },
    );
  }
}
