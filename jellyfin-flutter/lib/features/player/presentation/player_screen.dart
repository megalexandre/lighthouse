import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/ticks.dart';
import '../../../widgets/error_retry.dart';
import '../../library/presentation/item_card.dart';
import '../application/player_controller.dart';
import '../data/player_engine.dart';

/// Full-window playback of one item, with an on-screen display (OSD) that
/// shows on mouse movement and hides after a few seconds of playing.
///
/// Keys: Space / K play-pause, Left / Right seek 10 s, Esc / Backspace
/// back (more come with F3b).
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key, required this.request});

  static const backButton = Key('player.back');
  static const playPauseButton = Key('player.playPause');
  static const seekBar = Key('player.seek');
  static const positionText = Key('player.position');

  final PlayRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = playerControllerProvider(request);
    final session = ref.watch(provider);

    // Played to the end: close (F3c plays the next episode instead).
    ref.listen(provider, (_, next) {
      if (next.value?.ended ?? false) _close(context, ref);
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_close(context, ref));
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: switch (session) {
          AsyncData(value: final session) => _Playing(
            session: session,
            onBack: () => _close(context, ref),
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
    );
  }

  /// Saves the resume point, then leaves.
  Future<void> _close(BuildContext context, WidgetRef ref) async {
    await ref.read(playerControllerProvider(request).notifier).stop();
    if (context.mounted && context.canPop()) context.pop();
  }
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

class _Playing extends StatefulWidget {
  const _Playing({required this.session, required this.onBack});

  final PlayerSession session;
  final VoidCallback onBack;

  @override
  State<_Playing> createState() => _PlayingState();
}

class _PlayingState extends State<_Playing> {
  static const hideAfter = Duration(seconds: 3);
  static const seekStep = Duration(seconds: 10);

  PlayerEngine get engine => widget.session.engine;

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

  void _show({bool hide = true}) {
    if (!_osdVisible) setState(() => _osdVisible = true);
    if (hide) _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
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

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.keyK) {
      if (event is KeyDownEvent) unawaited(engine.playOrPause());
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      unawaited(_seekBy(-seekStep));
    } else if (key == LogicalKeyboardKey.arrowRight) {
      unawaited(_seekBy(seekStep));
    } else if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.backspace) {
      if (event is KeyDownEvent) widget.onBack();
    } else {
      return KeyEventResult.ignored;
    }
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
              child: Center(child: engine.buildVideo()),
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
                  item: widget.session.item,
                  engine: engine,
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
    required this.item,
    required this.engine,
    required this.onBack,
    required this.onInteract,
  });

  final BaseItemDto item;
  final PlayerEngine engine;
  final VoidCallback onBack;
  final VoidCallback onInteract;

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
                  Expanded(
                    child: _SeekBar(engine: engine, onSeek: onInteract),
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
