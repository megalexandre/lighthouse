import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../l10n/l10n.dart';
import '../../data/player_engine.dart';
import '../player_screen.dart';
import 'control_button.dart';

/// The desktop's floating window, over the picture: dragged anywhere it
/// moves (it has no title bar), a click plays or pauses, a double click
/// gives the window back. On hover, and while paused: back to the window
/// and close at the top, −10 s, play / pause and +10 s in the middle.
class FloatingControls extends StatefulWidget {
  const FloatingControls({
    super.key,
    required this.engine,
    required this.onExpand,
    required this.onClose,
    required this.onSeekBy,
    required this.onDrag,
  });

  final PlayerEngine engine;
  final VoidCallback onExpand;
  final VoidCallback onClose;
  final Future<void> Function(Duration) onSeekBy;

  /// The mouse went down to move the window.
  final VoidCallback onDrag;

  @override
  State<FloatingControls> createState() => _FloatingControlsState();
}

class _FloatingControlsState extends State<FloatingControls> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final engine = widget.engine;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Behind the buttons: in front, it would wait out a double click
          // before letting one of them have a click.
          GestureDetector(
            key: PlayerScreen.floatingWindow,
            behavior: HitTestBehavior.opaque,
            onTap: () => unawaited(engine.playOrPause()),
            onDoubleTap: widget.onExpand,
            onPanStart: (_) => widget.onDrag(),
          ),
          StreamBuilder<bool>(
            stream: engine.playingStream,
            initialData: engine.playing,
            builder: (context, snap) {
              final playing = snap.data ?? false;
              final visible = _hovered || !playing;
              return AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: Duration(milliseconds: visible ? 150 : 300),
                child: IgnorePointer(
                  ignoring: !visible,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      IgnorePointer(child: ColoredBox(color: tokens.osdScrim)),
                      _buttons(context, playing),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buttons(BuildContext context, bool playing) {
    final tokens = context.tokens;
    final engine = widget.engine;
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.all(tokens.space(1)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ControlButton(
                  key: PlayerScreen.floatingExpand,
                  icon: Icons.open_in_full,
                  label: context.l10n.backToWindow,
                  shortcut: 'I',
                  onPressed: widget.onExpand,
                ),
                ControlButton(
                  key: PlayerScreen.floatingClose,
                  icon: Icons.close,
                  label: context.l10n.close,
                  shortcut: 'X',
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ControlButton(
                icon: Icons.replay_10,
                label: context.l10n.back10,
                shortcut: '←',
                onPressed: () =>
                    unawaited(widget.onSeekBy(const Duration(seconds: -10))),
              ),
              ControlButton(
                key: PlayerScreen.floatingPlayPause,
                icon: playing ? Icons.pause : Icons.play_arrow,
                label: playing ? context.l10n.pause : context.l10n.play,
                shortcut: context.l10n.keySpace,
                size: 52,
                iconSize: 32,
                onPressed: () => unawaited(engine.playOrPause()),
              ),
              ControlButton(
                icon: Icons.forward_10,
                label: context.l10n.forward10,
                shortcut: '→',
                onPressed: () =>
                    unawaited(widget.onSeekBy(const Duration(seconds: 10))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
