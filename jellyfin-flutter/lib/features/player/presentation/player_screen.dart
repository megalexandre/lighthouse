import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/failure.dart';
import '../../../core/ticks.dart';
import '../../../router.dart';
import '../../../widgets/error_retry.dart';
import '../../library/presentation/item_card.dart';
import '../../settings/application/settings_providers.dart';
import '../application/play_queue.dart';
import '../application/player_carry_over.dart';
import '../application/player_controller.dart';
import '../data/player_engine.dart';
import '../data/tracks.dart';
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
  static const audioMenu = Key('player.audio');
  static const subtitleMenu = Key('player.subtitles');
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

    return _FullscreenScope(
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
          color: Colors.white,
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
  });

  final PlayerSession session;
  final PlayerController controller;
  final VoidCallback onBack;

  /// Null when there is nothing after / before.
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  @override
  ConsumerState<_Playing> createState() => _PlayingState();
}

class _PlayingState extends ConsumerState<_Playing> {
  static const hideAfter = Duration(seconds: 3);
  static const seekStep = Duration(seconds: 10);
  static const longSeekStep = Duration(seconds: 60);
  static const volumeStep = 5.0;

  PlayerEngine get engine => widget.session.engine;

  /// Music: a cover instead of a picture, and the OSD stays up.
  bool get _isAudio => widget.session.item.type == BaseItemKind.audio;

  /// Previous restarts the current item when past this point, as music
  /// players do; before it, it goes to the previous item.
  static const restartThreshold = Duration(seconds: 3);

  bool _osdVisible = true;
  Timer? _hideTimer;
  StreamSubscription<bool>? _playing;

  @override
  void initState() {
    super.initState();
    // Paused: keep the OSD up. Playing: hide it after a while.
    _playing = engine.playingStream.listen((playing) {
      playing ? _scheduleHide() : _show(hide: false);
    });
    _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    unawaited(_playing?.cancel());
    super.dispose();
  }

  void _toggleFullscreen() =>
      ref.read(playerFullscreenProvider.notifier).toggle();

  void _show({bool hide = true}) {
    if (!_osdVisible) setState(() => _osdVisible = true);
    if (hide) _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (_isAudio) return;
    _hideTimer = Timer(hideAfter, () {
      if (mounted && engine.playing) setState(() => _osdVisible = false);
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

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
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
              child: _isAudio
                  ? _Cover(item: widget.session.item)
                  : Center(child: engine.buildVideo()),
            ),
            if (widget.session.interruptedAt case final Duration at)
              _Interrupted(
                at: at,
                onResume: () => widget.controller.resumeAfterInterruption(),
                onBack: widget.onBack,
              ),
            StreamBuilder<bool>(
              stream: engine.bufferingStream,
              builder: (_, snap) => (snap.data ?? false)
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink(),
            ),
            AnimatedOpacity(
              opacity: _osdVisible ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_osdVisible,
                child: _Osd(
                  session: widget.session,
                  controller: widget.controller,
                  fullscreen: ref.watch(playerFullscreenProvider),
                  onFullscreen: _toggleFullscreen,
                  onNext: widget.onNext == null ? null : _next,
                  onPrevious: _previous,
                  onBack: widget.onBack,
                  onInteract: _show,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Osd extends StatelessWidget {
  const _Osd({
    required this.session,
    required this.controller,
    required this.fullscreen,
    required this.onFullscreen,
    required this.onNext,
    required this.onPrevious,
    required this.onBack,
    required this.onInteract,
  });

  final PlayerSession session;
  final PlayerController controller;
  final bool fullscreen;
  final VoidCallback onFullscreen;
  final Future<void> Function()? onNext;
  final Future<void> Function() onPrevious;
  final VoidCallback onBack;
  final VoidCallback onInteract;

  BaseItemDto get item => session.item;
  PlayerEngine get engine => session.engine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = cardSubtitle(item);
    return Column(
      children: [
        // Top: back and title, over a gradient so they read on any frame.
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 32),
              child: Row(
                children: [
                  IconButton(
                    key: PlayerScreen.backButton,
                    color: Colors.white,
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        if (subtitle != null && subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 24, 16),
              child: Row(
                children: [
                  IconButton(
                    key: PlayerScreen.previousButton,
                    color: Colors.white,
                    tooltip: 'Previous',
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () {
                      unawaited(onPrevious());
                      onInteract();
                    },
                  ),
                  StreamBuilder<bool>(
                    stream: engine.playingStream,
                    initialData: engine.playing,
                    builder: (_, snap) {
                      final playing = snap.data ?? false;
                      return IconButton(
                        key: PlayerScreen.playPauseButton,
                        color: Colors.white,
                        iconSize: 36,
                        tooltip: playing ? 'Pause' : 'Play',
                        icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                        onPressed: () {
                          unawaited(engine.playOrPause());
                          onInteract();
                        },
                      );
                    },
                  ),
                  if (onNext != null)
                    IconButton(
                      key: PlayerScreen.nextButton,
                      color: Colors.white,
                      tooltip: 'Next',
                      icon: const Icon(Icons.skip_next),
                      onPressed: () {
                        unawaited(onNext!());
                        onInteract();
                      },
                    ),
                  Expanded(
                    child: _SeekBar(engine: engine, onSeek: onInteract),
                  ),
                  _Volume(
                    engine: engine,
                    controller: controller,
                    onInteract: onInteract,
                  ),
                  if (session.plan.audioStreams.length > 1)
                    _TrackMenu(
                      key: PlayerScreen.audioMenu,
                      tooltip: 'Audio',
                      icon: Icons.audiotrack,
                      selected: session.audioStreamIndex,
                      options: [
                        for (final s in session.plan.audioStreams)
                          (
                            s.index,
                            trackLabel(s),
                            PlayerScreen.audioItem(s.index),
                          ),
                      ],
                      onSelected: (i) => controller.selectAudio(i!),
                      onInteract: onInteract,
                    ),
                  if (session.plan.subtitleStreams.isNotEmpty)
                    _TrackMenu(
                      key: PlayerScreen.subtitleMenu,
                      tooltip: 'Subtitles',
                      icon: Icons.subtitles,
                      selected: session.subtitleStreamIndex,
                      options: [
                        (null, 'Off', PlayerScreen.subtitleOff),
                        for (final s in session.plan.subtitleStreams)
                          (
                            s.index,
                            trackLabel(s),
                            PlayerScreen.subtitleItem(s.index),
                          ),
                      ],
                      onSelected: controller.selectSubtitle,
                      onInteract: onInteract,
                    ),
                  IconButton(
                    key: PlayerScreen.fullscreenButton,
                    color: Colors.white,
                    tooltip: fullscreen ? 'Exit full screen' : 'Full screen',
                    icon: Icon(
                      fullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    ),
                    onPressed: () {
                      onFullscreen();
                      onInteract();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Position, a draggable bar, and the length. While dragging, the bar
/// follows the pointer and the player seeks once, on release.
class _SeekBar extends StatefulWidget {
  const _SeekBar({required this.engine, required this.onSeek});

  final PlayerEngine engine;
  final VoidCallback onSeek;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _dragging;

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final style = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: Colors.white);
    return StreamBuilder<Duration>(
      stream: engine.durationStream,
      initialData: engine.duration,
      builder: (_, durationSnap) => StreamBuilder<Duration>(
        stream: engine.positionStream,
        initialData: engine.position,
        builder: (_, positionSnap) {
          final duration = durationSnap.data ?? Duration.zero;
          final position = positionSnap.data ?? Duration.zero;
          final max = duration.inMilliseconds.toDouble();
          final value =
              _dragging ??
              position.inMilliseconds
                  .clamp(0, duration.inMilliseconds)
                  .toDouble();
          return Row(
            children: [
              Text(
                formatPosition(Duration(milliseconds: value.round())),
                key: PlayerScreen.positionText,
                style: style,
              ),
              Expanded(
                child: Slider(
                  key: PlayerScreen.seekBar,
                  max: max > 0 ? max : 1,
                  value: max > 0 ? value : 0,
                  onChanged: max > 0
                      ? (v) {
                          setState(() => _dragging = v);
                          widget.onSeek();
                        }
                      : null,
                  onChangeEnd: (v) async {
                    await engine.seek(Duration(milliseconds: v.round()));
                    if (mounted) setState(() => _dragging = null);
                  },
                ),
              ),
              Text(formatPosition(duration), style: style),
            ],
          );
        },
      ),
    );
  }
}

/// Mute button and a short volume bar.
class _Volume extends StatelessWidget {
  const _Volume({
    required this.engine,
    required this.controller,
    required this.onInteract,
  });

  final PlayerEngine engine;
  final PlayerController controller;
  final VoidCallback onInteract;

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
            IconButton(
              key: PlayerScreen.muteButton,
              color: Colors.white,
              tooltip: muted ? 'Unmute' : 'Mute',
              icon: Icon(
                muted || volume == 0
                    ? Icons.volume_off
                    : (volume < 50 ? Icons.volume_down : Icons.volume_up),
              ),
              onPressed: () {
                unawaited(controller.toggleMute());
                onInteract();
              },
            ),
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

/// A menu of tracks (audio or subtitles), the current one checked.
class _TrackMenu extends StatelessWidget {
  const _TrackMenu({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.options,
    required this.onSelected,
    required this.onInteract,
  });

  final String tooltip;
  final IconData icon;
  final int? selected;

  /// (server index or null for "off", label, key).
  final List<(int?, String, Key)> options;
  final Future<void> Function(int? index) onSelected;
  final VoidCallback onInteract;

  @override
  Widget build(BuildContext context) => PopupMenuButton<(int?,)>(
    tooltip: tooltip,
    icon: Icon(icon, color: Colors.white),
    onOpened: onInteract,
    onSelected: (choice) {
      onInteract();
      final messenger = ScaffoldMessenger.maybeOf(context);
      unawaited(
        onSelected(choice.$1).catchError((Object e) {
          // A track that needs a new stream can fail (server gone): the
          // old one keeps playing; say so instead of doing nothing.
          messenger?.showSnackBar(
            SnackBar(
              content: Text(
                e is Failure ? e.message : 'Could not change the track.',
              ),
            ),
          );
        }),
      );
    },
    itemBuilder: (_) => [
      for (final (index, label, key) in options)
        CheckedPopupMenuItem<(int?,)>(
          key: key,
          value: (index,),
          checked: index == selected,
          child: Text(label),
        ),
    ],
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
              borderRadius: BorderRadius.circular(12),
              child: ItemImage(item: item, width: size),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            item.name,
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          if ([?item.albumArtist, ?item.album] case final parts
              when parts.isNotEmpty)
            Text(
              parts.join(' · '),
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white70,
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
    color: Colors.black54,
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
