import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/appearance.dart';
import '../../../core/ticks.dart';
import '../../../router.dart';
import '../../../widgets/error_retry.dart';
import '../../settings/application/settings_providers.dart';
import '../application/play_queue.dart';
import '../application/player_carry_over.dart';
import '../application/player_controller.dart';
import '../application/trickplay.dart';
import '../data/playback_repository.dart';
import '../data/player_engine.dart';
import '../data/tracks.dart';
import 'osd/player_osd.dart';
import 'osd/settings_menu.dart';
import 'osd/up_next.dart';
import 'player_keys.dart';
import 'player_overlays.dart';

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
              AsyncError(:final error) => PlayerMessage(
                onBack: () => context.pop(),
                child: ErrorRetry(
                  error: error,
                  onRetry: () => ref.invalidate(provider),
                ),
              ),
              _ => PlayerMessage(
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
                  ? AudioCover(item: session.item)
                  : Center(child: engine.buildVideo()),
            ),
            if (session.interruptedAt case final Duration at)
              InterruptedNotice(
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
                child: PlayerOsd(
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
                child: _TrackMenu(
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
    );
  }
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
          bottom: raised ? 136 : tokens.space(6),
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

/// The settings panel with this item's tracks: audio, subtitles (Off
/// first) and speed. A failed track change says so.
class _TrackMenu extends StatelessWidget {
  const _TrackMenu({
    required this.menuKey,
    required this.page,
    required this.session,
    required this.controller,
    required this.onClose,
  });

  /// On the menu itself: Esc asks it to go back a level.
  final GlobalKey<SettingsMenuState> menuKey;
  final SettingsPage page;
  final PlayerSession session;
  final PlayerController controller;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final engine = session.engine;
    return SettingsMenu(
      key: menuKey,
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
        controller.selectAudio(i),
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
        controller.selectSubtitle(i),
        'Could not change the track.',
      ),
      rate: engine.rate,
      onRate: (r) => unawaited(engine.setRate(r)),
      onClose: onClose,
    );
  }
}
