import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/window.dart';

/// The volume and mute the user chose, kept while the app runs: the next
/// episode or track (a new player screen, a new engine) starts with them,
/// not at 100 %.
typedef PlayerSound = ({double volume, bool muted});

final playerSoundProvider = NotifierProvider<PlayerSoundNotifier, PlayerSound>(
  PlayerSoundNotifier.new,
);

class PlayerSoundNotifier extends Notifier<PlayerSound> {
  static const initial = (volume: 100.0, muted: false);

  @override
  PlayerSound build() => initial;

  void set({double? volume, bool? muted}) =>
      state = (volume: volume ?? state.volume, muted: muted ?? state.muted);
}

/// Full screen while playing, across items: the player screens alive
/// (the next episode's screen opens before the old one closes) share it,
/// and only the last one to close gives the window back.
final playerFullscreenProvider =
    NotifierProvider<PlayerFullscreenNotifier, bool>(
      PlayerFullscreenNotifier.new,
    );

class PlayerFullscreenNotifier extends Notifier<bool> {
  int _screens = 0;
  bool _sideways = false;

  AppWindow get _window => ref.read(appWindowProvider);

  @override
  bool build() => false;

  /// A player screen opened.
  void enter() => _screens++;

  /// A player screen closed: the last one undoes the full screen it made.
  /// Called from dispose, where providers cannot change: done right after,
  /// unless another player screen opened meanwhile.
  void leave() {
    if (_screens > 0) _screens--;
    if (_screens > 0) return;
    scheduleMicrotask(() {
      if (!ref.mounted || _screens > 0) return;
      if (_sideways) {
        _sideways = false;
        _window.isLandscape = false;
      }
      if (!state) return;
      state = false;
      _window.isFullScreen = false;
    });
  }

  /// A video plays on a phone: sideways and full screen, until the last
  /// player screen closes. Once: what the user changes meanwhile carries
  /// on to the next episode.
  void enterVideo() {
    if (_sideways || _screens == 0) return;
    _sideways = true;
    _window.isLandscape = true;
    if (!state) toggle();
  }

  void toggle() {
    state = !state;
    _window.isFullScreen = state;
  }
}
