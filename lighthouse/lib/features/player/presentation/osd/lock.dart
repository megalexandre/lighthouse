import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/ticks.dart';
import '../../../../l10n/l10n.dart';
import '../../../../widgets/loading_ring.dart';
import '../../data/player_engine.dart';
import '../player_screen.dart';
import 'control_button.dart';

/// The title bar's button that locks the controls.
class LockButton extends StatelessWidget {
  const LockButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => ControlButton(
    key: PlayerScreen.lockButton,
    icon: Icons.lock_open,
    label: context.l10n.lockControls,
    onPressed: onPressed,
  );
}

/// The locked player's padlock, in the top right corner, 48 px down, as
/// Jellyfin's Android app has it: across the screen from the button that
/// locked (bottom left), so a double tap does not lock and unlock. Held
/// for [hold] it unlocks, a ring filling round it meanwhile; let go
/// sooner, the ring runs back and nothing happens.
/// The mouse's button, or Enter or Space while it has the focus, hold it
/// too.
class UnlockButton extends StatefulWidget {
  const UnlockButton({
    super.key,
    required this.focusNode,
    required this.onUnlock,
    required this.onHolding,
  });

  static const hold = Duration(seconds: 1);

  final FocusNode focusNode;
  final VoidCallback onUnlock;

  /// Told when a hold starts (true) and ends (false): the padlock stays
  /// while held.
  final ValueChanged<bool> onHolding;

  @override
  State<UnlockButton> createState() => _UnlockButtonState();
}

class _UnlockButtonState extends State<UnlockButton>
    with SingleTickerProviderStateMixin {
  late final _ring =
      AnimationController(
        vsync: this,
        duration: UnlockButton.hold,
        reverseDuration: const Duration(milliseconds: 200),
      )..addStatusListener((status) {
        if (status != AnimationStatus.completed) return;
        unawaited(HapticFeedback.mediumImpact());
        widget.onUnlock();
      });

  bool _held = false;

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  void _press() {
    if (_held) return;
    _held = true;
    widget.onHolding(true);
    unawaited(_ring.forward());
  }

  void _release() {
    if (!_held) return;
    _held = false;
    widget.onHolding(false);
    if (!_ring.isCompleted) unawaited(_ring.reverse());
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    final key = event.logicalKey;
    if (key != LogicalKeyboardKey.enter &&
        key != LogicalKeyboardKey.numpadEnter &&
        key != LogicalKeyboardKey.space) {
      return KeyEventResult.ignored;
    }
    switch (event) {
      case KeyDownEvent():
        _press();
      case KeyUpEvent():
        _release();
      case _:
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    const size = 64.0;
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(top: 48, right: tokens.space(4)),
          child: Tooltip(
            message: context.l10n.holdToUnlock,
            child: Focus(
              focusNode: widget.focusNode,
              onKeyEvent: _onKey,
              child: Semantics(
                button: true,
                label: context.l10n.holdToUnlock,
                child: Listener(
                  key: PlayerScreen.unlockButton,
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => _press(),
                  onPointerUp: (_) => _release(),
                  onPointerCancel: (_) => _release(),
                  child: SizedBox.square(
                    dimension: size,
                    child: ListenableBuilder(
                      listenable: Listenable.merge([_ring, widget.focusNode]),
                      builder: (context, _) => Stack(
                        fit: StackFit.expand,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: tokens.osdSurface,
                              shape: BoxShape.circle,
                              border: widget.focusNode.hasFocus
                                  ? Border.all(color: tokens.osdAccent)
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3),
                            child: LoadingRing(
                              size: size - 6,
                              onMedia: true,
                              value: _ring.value,
                            ),
                          ),
                          Icon(Icons.lock, color: tokens.osdInk),
                        ],
                      ),
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

/// A locked song's time, under its cover: to look at, not to touch.
class LockedSongTime extends StatelessWidget {
  const LockedSongTime({super.key, required this.engine});

  final PlayerEngine engine;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: tokens.space(8)),
          child: StreamBuilder<Duration>(
            stream: engine.positionStream,
            builder: (context, _) => Text(
              engine.duration > Duration.zero
                  ? '${formatPosition(engine.position)} / '
                        '${formatPosition(engine.duration)}'
                  : formatPosition(engine.position),
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: tokens.osdInkMuted),
            ),
          ),
        ),
      ),
    );
  }
}
