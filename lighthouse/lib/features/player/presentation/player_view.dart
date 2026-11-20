import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
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
import 'osd/player_osd.dart';
import 'osd/seek_bar.dart';
import 'osd/settings_menu.dart';
import 'osd/track_menu.dart';
import 'osd/up_next.dart';
import 'player_keys.dart';
import 'player_overlays.dart';

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

  /// The seek bar's chapter marks.
  late final List<SeekChapter> _chapters = [
    for (final ch in widget.session.item.chapters)
      (start: ticksToDuration(ch.startPositionTicks), name: ch.name),
  ];

  @override
  void initState() {
    super.initState();
    // Paused: keep the OSD up. Playing: hide it after a while.
    _playing = engine.playingStream.listen((playing) {
      playing ? _scheduleHide() : _show(hide: false);
    });
    _scheduleHide();
  }

  /// The window's size is known here (and changes land here): the lift
  /// follows the controls' height.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    engine.setSubtitleLift(_osdVisible ? _subtitleLift : 0);
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
    engine.setSubtitleLift(visible ? _subtitleLift : 0);
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

  /// Esc or the system's Back: in the menu one level up, then closed (not
  /// leaving the player); otherwise out of the player.
  void _back() {
    if (_menu == null) return widget.onBack();
    if (!(_menuKey.currentState?.back() ?? false)) _closeMenu();
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (_menu != null &&
        event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      _back();
      return KeyEventResult.handled;
    }
    final action = playerActionFor(event, HardwareKeyboard.instance);
    if (action == null) return KeyEventResult.ignored;
    final c = widget.controller;
    final done = switch (action) {
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
    // The system's Back (Android) does what Esc does; leaving saves the
    // resume point first (onBack), so the route is never popped directly.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: MouseRegion(
          cursor: _osdVisible ? MouseCursor.defer : SystemMouseCursors.none,
          onHover: (_) => _show(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isTouch(context) && !_isAudio)
                // As phone players do: a tap shows or hides the controls
                // (play / pause is their button), a double tap on either
                // half goes back or on 10 s.
                _Picture(
                  session: session,
                  onTap: () => _osdVisible ? _setOsd(false) : _show(),
                  onDoubleTapAt: (side) =>
                      unawaited(_seekBy(side < 0 ? -seekStep : seekStep)),
                )
              else
                _Picture(
                  session: session,
                  onTap: () {
                    unawaited(engine.playOrPause());
                    _show();
                  },
                  onDoubleTap: _isAudio ? null : _toggleFullscreen,
                ),
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
                  ),
                ),
              ),
              if (widget.upNext case final BaseItemDto next when !_upNextHidden)
                _UpNextLayer(
                  engine: engine,
                  next: next,
                  raised: _osdVisible,
                  onWatchNow: () => unawaited(_next()),
                  onHide: () => setState(() => _upNextHidden = true),
                ),
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
            ],
          ),
        ),
      ),
    );
  }
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
    required this.onWatchNow,
    required this.onHide,
  });

  final PlayerEngine engine;
  final BaseItemDto next;
  final bool raised;
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
          right: tokens.space(6),
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
