import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_keys.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  /// The action of pressing [key] with [modifiers] held.
  Future<PlayerAction?> press(
    WidgetTester tester,
    LogicalKeyboardKey key, [
    List<LogicalKeyboardKey> modifiers = const [],
  ]) async {
    PlayerAction? action;
    await tester.pumpWidget(
      Focus(
        autofocus: true,
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent) {
            action ??= playerActionFor(event, HardwareKeyboard.instance);
          }
          return KeyEventResult.handled;
        },
        child: const SizedBox(),
      ),
    );
    for (final m in modifiers) {
      await tester.sendKeyDownEvent(m);
    }
    await tester.sendKeyDownEvent(key);
    await tester.sendKeyUpEvent(key);
    for (final m in modifiers.reversed) {
      await tester.sendKeyUpEvent(m);
    }
    return action;
  }

  const ctrl = LogicalKeyboardKey.controlLeft;
  const shift = LogicalKeyboardKey.shiftLeft;
  const alt = LogicalKeyboardKey.altLeft;

  final cases = <(LogicalKeyboardKey, List<LogicalKeyboardKey>, PlayerAction?)>[
    (LogicalKeyboardKey.space, [], PlayerAction.playPause),
    (LogicalKeyboardKey.keyP, [], PlayerAction.playPause),
    (LogicalKeyboardKey.keyP, [ctrl], PlayerAction.pause),
    (LogicalKeyboardKey.mediaPlayPause, [], PlayerAction.playPause),
    (LogicalKeyboardKey.keyX, [], PlayerAction.stop),
    (LogicalKeyboardKey.escape, [], PlayerAction.back),
    (LogicalKeyboardKey.arrowLeft, [], PlayerAction.seekBack),
    (LogicalKeyboardKey.pageDown, [], PlayerAction.seekForwardLong),
    (LogicalKeyboardKey.arrowUp, [], PlayerAction.volumeUp),
    (LogicalKeyboardKey.keyM, [], PlayerAction.mute),
    (LogicalKeyboardKey.keyA, [], PlayerAction.nextAudio),
    (LogicalKeyboardKey.keyA, [ctrl], PlayerAction.previousAudio),
    (LogicalKeyboardKey.keyL, [], PlayerAction.nextSubtitle),
    (LogicalKeyboardKey.keyL, [ctrl], PlayerAction.previousSubtitle),
    (LogicalKeyboardKey.keyS, [], PlayerAction.toggleSubtitles),
    (LogicalKeyboardKey.keyS, [ctrl, shift], PlayerAction.stop),
    (LogicalKeyboardKey.f11, [], PlayerAction.fullscreen),
    (LogicalKeyboardKey.enter, [alt], PlayerAction.fullscreen),
    (LogicalKeyboardKey.mediaTrackNext, [], PlayerAction.next),
    (LogicalKeyboardKey.end, [], PlayerAction.next),
    (LogicalKeyboardKey.keyN, [shift], PlayerAction.next),
    (LogicalKeyboardKey.mediaTrackPrevious, [], PlayerAction.previous),
    (LogicalKeyboardKey.home, [], PlayerAction.previous),
    (LogicalKeyboardKey.keyP, [shift], PlayerAction.previous),
    // Modifiers must match: Alt+A is audio delay on the desktop, not here.
    (LogicalKeyboardKey.keyA, [alt], null),
    (LogicalKeyboardKey.keyQ, [], null),
  ];

  for (final (key, modifiers, expected) in cases) {
    final name = [...modifiers.map((m) => m.keyLabel), key.keyLabel].join('+');
    testWidgets('$name → ${expected?.name ?? 'nothing'}', (tester) async {
      expect(await press(tester, key, modifiers), expected);
    });
  }
}
