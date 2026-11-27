import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/device_levels.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/ticks.dart';
import '../../settings/application/settings_providers.dart';
import '../../settings/data/settings_repository.dart';
import '../data/player_engine.dart';

/// How far a swipe sideways seeks, for [fraction] of the picture's width
/// (negative: back): a minute for half the width, three for all of it,
/// and finer steps for short moves (seven seconds for a tenth). Whole
/// seconds.
Duration swipeSeekOffset(double fraction) {
  final seconds = 60 * fraction + 120 * fraction * fraction.abs();
  return Duration(seconds: seconds.round());
}

/// The player's swipes on touch, as phone players have them: up and down
/// on the left half for the window's brightness, on the right half for
/// the phone's volume (the player's own where the app cannot set the
/// phone's), and sideways to seek, which happens when the finger lifts
/// (one seek, not one per move: each is a new request to a streaming
/// server). A swipe is one or the other, decided by its first moves.
/// Swipes from the edges are left to the system (Back, the notifications);
/// each kind can be turned off in Settings. The brightness goes back to
/// the screen's when the player closes.
class PlayerSwipes extends ConsumerStatefulWidget {
  const PlayerSwipes({
    super.key,
    required this.engine,
    required this.child,
    this.enabled = true,
  });

  /// The overlay showing the level, or where the seek goes.
  static const feedback = Key('player.swipeFeedback');

  /// A swipe from the whole range at the bottom to its top goes from 0 to
  /// 1: this share of the picture's height.
  static const fullRange = 0.6;

  /// Swipes starting this close to an edge (or inside the system's gesture
  /// insets) are not the player's.
  static const edge = 48.0;

  final PlayerEngine engine;
  final Widget child;

  /// Off while the player is locked; the child stays as it is (the video
  /// is not built again).
  final bool enabled;

  @override
  ConsumerState<PlayerSwipes> createState() => _PlayerSwipesState();
}

enum _Kind { brightness, volume, seek }

class _PlayerSwipesState extends ConsumerState<PlayerSwipes> {
  late final DeviceLevels _levels = ref.read(deviceLevelsProvider);

  /// The swipe under way: what it changes once known (null: not yet, or
  /// not the player's), where it started and how far it went.
  _Kind? _kind;
  bool _ignored = false;
  Offset _moved = Offset.zero;
  Size _size = Size.zero;

  /// Brightness or volume when the swipe started; null until read.
  double? _startLevel;

  /// The phone's volume is out of reach: the player's instead.
  bool _playerVolume = false;
  Duration _startPosition = Duration.zero;

  /// What the overlay shows: a level, or a seek's offset and target.
  _Kind? _shown;
  double? _level;
  Duration? _offset;
  Timer? _hide;

  bool _brightnessChanged = false;

  @override
  void dispose() {
    _hide?.cancel();
    if (_brightnessChanged) unawaited(_levels.resetBrightness());
    super.dispose();
  }

  SwipeSettings get _settings =>
      ref.read(swipeSettingsProvider).value ?? const SwipeSettings();

  void _onStart(DragStartDetails details) {
    _hide?.cancel();
    final insets = MediaQuery.systemGestureInsetsOf(context);
    final p = details.localPosition;
    _ignored =
        p.dx < math.max(PlayerSwipes.edge, insets.left) ||
        p.dx > _size.width - math.max(PlayerSwipes.edge, insets.right) ||
        p.dy < math.max(PlayerSwipes.edge, insets.top) ||
        p.dy > _size.height - math.max(PlayerSwipes.edge, insets.bottom);
    _kind = null;
    _moved = Offset.zero;
    _startLevel = null;
    _leftHalf = p.dx < _size.width / 2;
  }

  bool _leftHalf = false;

  void _onUpdate(DragUpdateDetails details) {
    if (_ignored) return;
    _moved += details.delta;
    final kind = _kind ?? _decide();
    if (kind == null) return;
    switch (kind) {
      case _Kind.seek:
        final offset = swipeSeekOffset(_moved.dx / _size.width);
        setState(() => _offset = offset);
      case _Kind.brightness || _Kind.volume:
        _applyLevel();
    }
  }

  /// Sideways or up and down, once the swipe clearly goes one way.
  _Kind? _decide() {
    final dx = _moved.dx.abs();
    final dy = _moved.dy.abs();
    final settings = _settings;
    if (dx > 2 * dy) {
      if (!settings.seek) return _ignore();
      _startPosition = widget.engine.position;
      _level = null;
      return _shown = _kind = _Kind.seek;
    }
    if (dy > 2 * dx) {
      if (!settings.levels) return _ignore();
      final kind = _leftHalf ? _Kind.brightness : _Kind.volume;
      _offset = null;
      _kind = _shown = kind;
      unawaited(_readStartLevel(kind));
      return kind;
    }
    return null;
  }

  _Kind? _ignore() {
    _ignored = true;
    return null;
  }

  Future<void> _readStartLevel(_Kind kind) async {
    double? level;
    if (kind == _Kind.brightness) {
      level = await _levels.brightness();
      // A window whose brightness cannot change: nothing to swipe.
      if (level == null) _ignored = true;
    } else {
      level = await _levels.volume();
      _playerVolume = level == null;
      level ??= widget.engine.volume / 100;
    }
    if (!mounted || _kind != kind) return;
    _startLevel = level;
    if (level != null) _applyLevel();
  }

  void _applyLevel() {
    final start = _startLevel;
    if (start == null || _ignored) return;
    final level = (start - _moved.dy / (_size.height * PlayerSwipes.fullRange))
        .clamp(0.0, 1.0);
    setState(() => _level = level);
    if (_kind == _Kind.brightness) {
      _brightnessChanged = true;
      unawaited(_levels.setBrightness(level));
    } else if (_playerVolume) {
      unawaited(widget.engine.setVolume(level * 100));
    } else {
      unawaited(_levels.setVolume(level));
    }
  }

  void _onEnd() {
    // Also called as the detector goes away with the player, after
    // [dispose]: nothing to seek or show then.
    if (!mounted) return;
    final offset = _offset;
    if (_kind == _Kind.seek && offset != null && offset != Duration.zero) {
      unawaited(widget.engine.seek(_target(offset)));
    }
    _kind = null;
    // A swipe that showed nothing leaves nothing to hide.
    if (_level == null && _offset == null) return;
    _hide?.cancel();
    _hide = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _level = _offset = null);
    });
  }

  Duration _target(Duration offset) {
    final target = _startPosition + offset;
    final end = widget.engine.duration;
    if (target < Duration.zero) return Duration.zero;
    if (end > Duration.zero && target > end) return end;
    return target;
  }

  @override
  Widget build(BuildContext context) {
    // Read at the swipe, but kept loaded meanwhile.
    ref.watch(swipeSettingsProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              // From where the finger came down, not from where the swipe
              // was recognised: that is what the edges are judged by.
              dragStartBehavior: DragStartBehavior.down,
              onPanStart: widget.enabled ? _onStart : null,
              onPanUpdate: widget.enabled ? _onUpdate : null,
              onPanEnd: widget.enabled ? (_) => _onEnd() : null,
              onPanCancel: widget.enabled ? _onEnd : null,
              child: widget.child,
            ),
            if (_level != null || _offset != null)
              IgnorePointer(
                child: Center(
                  child: _Feedback(
                    key: PlayerSwipes.feedback,
                    kind: _shown,
                    level: _level,
                    offset: _offset,
                    target: _offset == null ? null : _target(_offset!),
                    length: widget.engine.duration,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// The level being set (an icon and a bar), or the seek ("+1:00" over
/// "1:30 / 45:00").
class _Feedback extends StatelessWidget {
  const _Feedback({
    super.key,
    required this.kind,
    required this.level,
    required this.offset,
    required this.target,
    required this.length,
  });

  final _Kind? kind;
  final double? level;
  final Duration? offset;
  final Duration? target;
  final Duration length;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final ink = TextStyle(color: tokens.osdInk);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space(5),
        vertical: tokens.space(3),
      ),
      decoration: BoxDecoration(
        color: tokens.osdSurface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
      child: switch ((offset, level)) {
        (final Duration offset, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${offset.isNegative ? '-' : '+'}${formatPosition(offset.abs())}',
              style: ink.copyWith(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            if (target case final Duration target)
              Text(
                length > Duration.zero
                    ? '${formatPosition(target)} / ${formatPosition(length)}'
                    : formatPosition(target),
                style: TextStyle(color: tokens.osdInkMuted),
              ),
          ],
        ),
        (_, final double level) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              kind == _Kind.brightness
                  ? Icons.brightness_6
                  : level == 0
                  ? Icons.volume_off
                  : Icons.volume_up,
              color: tokens.osdInk,
            ),
            SizedBox(width: tokens.space(3)),
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                value: level,
                color: tokens.osdAccent,
                backgroundColor: tokens.osdTrack,
              ),
            ),
          ],
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
