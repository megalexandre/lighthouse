import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import '../../../core/log.dart';

/// The paper's sounds as pages move (assets/sounds/, made by
/// tool/gen_page_sounds.py).
abstract interface class PageSounds {
  /// Gets the sounds ready, so the first turn is not late.
  void warmUp();

  /// A dragged page moves at [speed]: 0 still, 1 fast (and louder). Called
  /// as it moves; when it stops being called, the rubbing fades out.
  void rub(double speed);

  /// The drag is over: no more rubbing.
  void stopRubbing();

  /// A page turns (once per turn).
  void turn();
}

/// No sound at all (the integration tests' machine).
class SilentPageSounds implements PageSounds {
  const SilentPageSounds();

  @override
  void warmUp() {}

  @override
  void rub(double speed) {}

  @override
  void stopRubbing() {}

  @override
  void turn() {}
}

/// Whether the reader offers the page sound at all. Off for now: the
/// sounds made so far (tool/gen_page_sounds.py) do not sound like paper
/// yet. Off, there is no switch in the display settings and nothing plays,
/// whatever the preferences say; the tests turn it on to keep the feature
/// working for when the sounds are right.
final pageSoundsAvailableProvider = Provider<bool>((_) => false);

final pageSoundsProvider = Provider<PageSounds>((ref) {
  final sounds = MpvPageSounds();
  ref.onDispose(() => unawaited(sounds.dispose()));
  return sounds;
});

/// The sounds through mpv (media_kit), as the app plays everything: one
/// player loops the rubbing, its volume following the page; another plays
/// the swish anew at each turn (mpv keeps a finished file "completed": a
/// seek back and play stay silent; opening it again takes ~30 ms). Neither
/// touches the video or music playing.
class MpvPageSounds implements PageSounds {
  static const _rustleFile = 'asset:///assets/sounds/page_rustle.ogg';
  static const _swishFile = 'asset:///assets/sounds/page_turn.ogg';

  /// The loudest the rubbing gets, and the swish (mpv's 0–100).
  static const _rubVolume = 55.0;
  static const _turnVolume = 80.0;

  /// No movement for this long: the rubbing fades out.
  static const _quiet = Duration(milliseconds: 90);

  Player? _rubber;
  Player? _swisher;
  double _volume = 0;
  bool _rubbing = false;
  Timer? _fade;

  Player _player(String what) =>
      Player(configuration: PlayerConfiguration(title: 'Lighthouse $what'));

  Player get _rub {
    final player = _rubber;
    if (player != null) return player;
    final made = _player('page');
    unawaited(
      _guard(() async {
        await made.setPlaylistMode(PlaylistMode.single); // Loops.
        await made.setVolume(0);
        await made.open(Media(_rustleFile), play: false);
      }),
    );
    return _rubber = made;
  }

  Player get _swish {
    final player = _swisher;
    if (player != null) return player;
    final made = _player('page turn');
    unawaited(
      _guard(() async {
        await made.setVolume(_turnVolume);
        // Read once now, so the first turn starts as fast as later ones.
        await made.open(Media(_swishFile), play: false);
      }),
    );
    return _swisher = made;
  }

  @override
  void warmUp() {
    _rub;
    _swish;
  }

  @override
  void rub(double speed) {
    // Up at once with the page, down more gently: paper does not stop dead.
    final target = _rubVolume * math.sqrt(speed.clamp(0.0, 1.0));
    _setVolume(math.max(target, _volume * 0.7));
    if (!_rubbing) {
      _rubbing = true;
      unawaited(_guard(_rub.play));
    }
    _fade?.cancel();
    _fade = Timer(_quiet, _fadeOut);
  }

  void _fadeOut() {
    if (_volume < 2) return stopRubbing();
    _setVolume(_volume * 0.5);
    _fade = Timer(const Duration(milliseconds: 30), _fadeOut);
  }

  @override
  void stopRubbing() {
    _fade?.cancel();
    if (!_rubbing) return;
    _rubbing = false;
    _setVolume(0);
    unawaited(_guard(_rub.pause));
  }

  void _setVolume(double volume) {
    // mpv takes it as a property: only real changes are sent.
    if ((volume - _volume).abs() < 1.5 && volume != 0) return;
    _volume = volume;
    unawaited(_guard(() => _rub.setVolume(volume)));
  }

  @override
  void turn() {
    final player = _swish;
    unawaited(_guard(() => player.open(Media(_swishFile))));
  }

  /// A sound that cannot play is not worth more than a line in the log.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (e) {
      log.debug('reader', 'page sound: $e');
    }
  }

  Future<void> dispose() async {
    _fade?.cancel();
    await _rubber?.dispose();
    await _swisher?.dispose();
  }
}
