import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// What a key does in the player.
enum PlayerAction {
  playPause,
  pause,
  stop,
  back,
  seekBack,
  seekForward,
  seekBackLong,
  seekForwardLong,
  volumeUp,
  volumeDown,
  mute,
  nextAudio,
  previousAudio,
  nextSubtitle,
  previousSubtitle,
  toggleSubtitles,
  fullscreen,
}

/// The player's keys, ported from jellyfin-desktop's
/// resources/inputmaps/keyboard.json (the entries that apply to a video
/// player), plus arrows / M as on jellyfin-web's player. A modifier must
/// match exactly: Ctrl+A is not A.
const playerKeyBindings = <(SingleActivator, PlayerAction)>[
  (SingleActivator(LogicalKeyboardKey.space), PlayerAction.playPause),
  (SingleActivator(LogicalKeyboardKey.keyK), PlayerAction.playPause),
  (SingleActivator(LogicalKeyboardKey.keyP), PlayerAction.playPause),
  (SingleActivator(LogicalKeyboardKey.mediaPlayPause), PlayerAction.playPause),
  (SingleActivator(LogicalKeyboardKey.mediaPlay), PlayerAction.playPause),
  (
    SingleActivator(LogicalKeyboardKey.keyP, control: true, shift: true),
    PlayerAction.playPause,
  ),
  (SingleActivator(LogicalKeyboardKey.keyP, control: true), PlayerAction.pause),
  (SingleActivator(LogicalKeyboardKey.mediaPause), PlayerAction.pause),
  (SingleActivator(LogicalKeyboardKey.keyX), PlayerAction.stop),
  (SingleActivator(LogicalKeyboardKey.mediaStop), PlayerAction.stop),
  (
    SingleActivator(LogicalKeyboardKey.keyS, control: true, shift: true),
    PlayerAction.stop,
  ),
  (SingleActivator(LogicalKeyboardKey.escape), PlayerAction.back),
  (SingleActivator(LogicalKeyboardKey.backspace), PlayerAction.back),
  (SingleActivator(LogicalKeyboardKey.keyB), PlayerAction.back),
  (
    SingleActivator(LogicalKeyboardKey.arrowLeft, includeRepeats: true),
    PlayerAction.seekBack,
  ),
  (
    SingleActivator(LogicalKeyboardKey.arrowRight, includeRepeats: true),
    PlayerAction.seekForward,
  ),
  (SingleActivator(LogicalKeyboardKey.pageUp), PlayerAction.seekBackLong),
  (SingleActivator(LogicalKeyboardKey.mediaRewind), PlayerAction.seekBackLong),
  (
    SingleActivator(LogicalKeyboardKey.keyB, control: true, shift: true),
    PlayerAction.seekBackLong,
  ),
  (SingleActivator(LogicalKeyboardKey.pageDown), PlayerAction.seekForwardLong),
  (
    SingleActivator(LogicalKeyboardKey.mediaFastForward),
    PlayerAction.seekForwardLong,
  ),
  (
    SingleActivator(LogicalKeyboardKey.keyG, control: true, shift: true),
    PlayerAction.seekForwardLong,
  ),
  (
    SingleActivator(LogicalKeyboardKey.arrowUp, includeRepeats: true),
    PlayerAction.volumeUp,
  ),
  (
    SingleActivator(LogicalKeyboardKey.arrowDown, includeRepeats: true),
    PlayerAction.volumeDown,
  ),
  (SingleActivator(LogicalKeyboardKey.keyM), PlayerAction.mute),
  (SingleActivator(LogicalKeyboardKey.keyA), PlayerAction.nextAudio),
  (
    SingleActivator(LogicalKeyboardKey.keyA, control: true),
    PlayerAction.previousAudio,
  ),
  (SingleActivator(LogicalKeyboardKey.keyL), PlayerAction.nextSubtitle),
  (
    SingleActivator(LogicalKeyboardKey.keyL, control: true),
    PlayerAction.previousSubtitle,
  ),
  (SingleActivator(LogicalKeyboardKey.keyS), PlayerAction.toggleSubtitles),
  (SingleActivator(LogicalKeyboardKey.f11), PlayerAction.fullscreen),
  (
    SingleActivator(LogicalKeyboardKey.f11, shift: true),
    PlayerAction.fullscreen,
  ),
  (SingleActivator(LogicalKeyboardKey.keyF), PlayerAction.fullscreen),
  (
    SingleActivator(LogicalKeyboardKey.enter, alt: true),
    PlayerAction.fullscreen,
  ),
  (SingleActivator(LogicalKeyboardKey.backslash), PlayerAction.fullscreen),
  (
    SingleActivator(LogicalKeyboardKey.keyF, control: true, meta: true),
    PlayerAction.fullscreen,
  ),
];

/// The action [event] triggers, or null.
PlayerAction? playerActionFor(KeyEvent event, HardwareKeyboard keyboard) {
  for (final (activator, action) in playerKeyBindings) {
    if (activator.accepts(event, keyboard)) return action;
  }
  return null;
}
